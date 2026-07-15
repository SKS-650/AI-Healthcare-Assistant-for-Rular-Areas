"""
Speech-to-Text Service - Production STT pipeline.

Priority order:
  1. OpenAI Whisper API  (best quality, requires internet + API key)
  2. Local Whisper model (good quality, no internet, needs ~1-5 GB disk)
  3. Google SpeechRecognition (free, needs internet, no API key)
  4. Vosk               (fully offline, lightweight, needs model download)
  5. Stub fallback      (always works, returns empty string with warning)

Supports: English, Hindi, Nepali, Bhojpuri (via Hindi model)
"""

from __future__ import annotations

import io
import logging
import os
import tempfile
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)


# ─── Language → Whisper locale mapping ───────────────────────────────────────

_WHISPER_LANG: dict[str, str] = {
    "en":  "en",
    "hi":  "hi",
    "ne":  "ne",
    "bho": "hi",   # Bhojpuri → Hindi Whisper model
    "bn":  "bn",
    "ta":  "ta",
    "te":  "te",
    "mr":  "mr",
    "gu":  "gu",
    "kn":  "kn",
    "ml":  "ml",
    "pa":  "pa",
}

# Google SpeechRecognition BCP-47 tags
_GOOGLE_LANG: dict[str, str] = {
    "en":  "en-IN",
    "hi":  "hi-IN",
    "ne":  "ne-NP",
    "bho": "hi-IN",
    "bn":  "bn-IN",
    "ta":  "ta-IN",
    "te":  "te-IN",
    "mr":  "mr-IN",
    "gu":  "gu-IN",
    "kn":  "kn-IN",
    "ml":  "ml-IN",
    "pa":  "pa-Guru-IN",
}


# ─── Result dataclass ─────────────────────────────────────────────────────────

@dataclass
class STTResult:
    text: str
    language: str
    confidence: float
    engine: str         # "whisper_api" | "whisper_local" | "google" | "vosk" | "stub"
    duration_seconds: float = 0.0
    success: bool = True
    error: Optional[str] = None


# ─── Helper: audio normalisation ─────────────────────────────────────────────

def _to_wav_bytes(audio_bytes: bytes, input_format: str = "webm") -> bytes:
    """
    Convert arbitrary audio bytes (webm, ogg, mp3, m4a …) to 16-kHz mono WAV.
    Requires pydub + ffmpeg.  If unavailable, returns audio_bytes unchanged.
    """
    try:
        from pydub import AudioSegment  # type: ignore

        buf = io.BytesIO(audio_bytes)
        seg = AudioSegment.from_file(buf, format=input_format)
        seg = seg.set_frame_rate(16000).set_channels(1)

        out = io.BytesIO()
        seg.export(out, format="wav")
        return out.getvalue()
    except Exception as exc:
        logger.debug(f"Audio conversion skipped ({exc}), using raw bytes")
        return audio_bytes


# ─── STT Engines ─────────────────────────────────────────────────────────────

class _WhisperAPIEngine:
    """OpenAI Whisper API - best quality, requires OPENAI_API_KEY."""

    def __init__(self) -> None:
        self._api_key = os.getenv("OPENAI_API_KEY") or os.getenv("CHATBOT_LLM_API_KEY")
        self._available = bool(self._api_key)

    @property
    def available(self) -> bool:
        return self._available

    def transcribe(self, audio_bytes: bytes, language: str = "en") -> STTResult:
        import time
        t0 = time.time()
        try:
            from openai import OpenAI  # type: ignore

            client = OpenAI(api_key=self._api_key)
            lang_code = _WHISPER_LANG.get(language, "en")

            audio_file = io.BytesIO(audio_bytes)
            audio_file.name = "audio.wav"

            response = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                language=lang_code,
                response_format="verbose_json",
            )
            text = response.text.strip()
            return STTResult(
                text=text,
                language=language,
                confidence=0.92,
                engine="whisper_api",
                duration_seconds=time.time() - t0,
                success=bool(text),
            )
        except Exception as exc:
            logger.warning(f"Whisper API failed: {exc}")
            return STTResult(
                text="", language=language, confidence=0.0,
                engine="whisper_api", success=False, error=str(exc),
            )


class _WhisperLocalEngine:
    """Local OpenAI Whisper model - good quality, no internet needed."""

    def __init__(self) -> None:
        self._model = None
        self._model_size = os.getenv("WHISPER_MODEL_SIZE", "base")

    def _load(self) -> bool:
        if self._model is not None:
            return True
        try:
            import whisper  # type: ignore
            logger.info(f"Loading local Whisper model: {self._model_size}")
            self._model = whisper.load_model(self._model_size)
            return True
        except ImportError:
            logger.warning("openai-whisper not installed. Run: pip install openai-whisper")
            return False
        except Exception as exc:
            logger.warning(f"Could not load local Whisper: {exc}")
            return False

    @property
    def available(self) -> bool:
        try:
            import whisper  # noqa: F401 type: ignore
            return True
        except ImportError:
            return False

    def transcribe(self, audio_bytes: bytes, language: str = "en") -> STTResult:
        import time
        t0 = time.time()

        if not self._load():
            return STTResult(
                text="", language=language, confidence=0.0,
                engine="whisper_local", success=False,
                error="Whisper model not available",
            )
        try:
            # Write to temp file (whisper needs a file path)
            suffix = ".wav"
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
                tmp.write(audio_bytes)
                tmp_path = tmp.name

            lang_code = _WHISPER_LANG.get(language, "en")
            result = self._model.transcribe(
                tmp_path,
                language=lang_code,
                fp16=False,
                verbose=False,
            )
            os.unlink(tmp_path)

            text = result.get("text", "").strip()
            return STTResult(
                text=text,
                language=language,
                confidence=0.88,
                engine="whisper_local",
                duration_seconds=time.time() - t0,
                success=bool(text),
            )
        except Exception as exc:
            logger.error(f"Local Whisper transcription failed: {exc}")
            return STTResult(
                text="", language=language, confidence=0.0,
                engine="whisper_local", success=False, error=str(exc),
            )


class _GoogleSpeechEngine:
    """Google SpeechRecognition - free, needs internet, no API key."""

    @property
    def available(self) -> bool:
        try:
            import speech_recognition  # noqa: F401 type: ignore
            return True
        except ImportError:
            return False

    def transcribe(self, audio_bytes: bytes, language: str = "en") -> STTResult:
        import time
        t0 = time.time()
        try:
            import speech_recognition as sr  # type: ignore

            lang_tag = _GOOGLE_LANG.get(language, "en-IN")
            audio_data = sr.AudioData(audio_bytes, sample_rate=16000, sample_width=2)

            recognizer = sr.Recognizer()
            text = recognizer.recognize_google(audio_data, language=lang_tag)

            return STTResult(
                text=text.strip(),
                language=language,
                confidence=0.80,
                engine="google",
                duration_seconds=time.time() - t0,
                success=bool(text),
            )
        except Exception as exc:
            logger.warning(f"Google STT failed: {exc}")
            return STTResult(
                text="", language=language, confidence=0.0,
                engine="google", success=False, error=str(exc),
            )


class _VoskEngine:
    """Vosk - fully offline STT. Requires vosk package + model download."""

    def __init__(self) -> None:
        self._models: dict[str, object] = {}
        self._vosk_model_dir = Path(
            os.getenv("VOSK_MODEL_DIR", "ai_models/saved_models/vosk")
        )

    @property
    def available(self) -> bool:
        try:
            import vosk  # noqa: F401 type: ignore
            return self._vosk_model_dir.exists()
        except ImportError:
            return False

    def _get_model(self, language: str):
        if language in self._models:
            return self._models[language]
        try:
            from vosk import Model  # type: ignore
            lang_dir = self._vosk_model_dir / language
            if not lang_dir.exists():
                lang_dir = self._vosk_model_dir / "en"  # fallback
            if not lang_dir.exists():
                return None
            model = Model(str(lang_dir))
            self._models[language] = model
            return model
        except Exception as exc:
            logger.warning(f"Vosk model load failed for {language}: {exc}")
            return None

    def transcribe(self, audio_bytes: bytes, language: str = "en") -> STTResult:
        import json, time
        t0 = time.time()
        try:
            from vosk import KaldiRecognizer  # type: ignore

            model = self._get_model(language)
            if model is None:
                return STTResult(
                    text="", language=language, confidence=0.0,
                    engine="vosk", success=False, error="Model not found",
                )

            rec = KaldiRecognizer(model, 16000)
            rec.AcceptWaveform(audio_bytes)
            result = json.loads(rec.FinalResult())
            text = result.get("text", "").strip()

            return STTResult(
                text=text,
                language=language,
                confidence=0.75,
                engine="vosk",
                duration_seconds=time.time() - t0,
                success=bool(text),
            )
        except Exception as exc:
            logger.error(f"Vosk transcription failed: {exc}")
            return STTResult(
                text="", language=language, confidence=0.0,
                engine="vosk", success=False, error=str(exc),
            )


# ─── Main STT Service ─────────────────────────────────────────────────────────

class SpeechToTextService:
    """
    Multi-engine STT with automatic fallback chain.

    Usage
    -----
    stt = SpeechToTextService()
    result = stt.transcribe(audio_bytes, language="hi")
    print(result.text)
    """

    def __init__(self) -> None:
        self._whisper_api   = _WhisperAPIEngine()
        self._whisper_local = _WhisperLocalEngine()
        self._google        = _GoogleSpeechEngine()
        self._vosk          = _VoskEngine()

        available = []
        if self._whisper_api.available:    available.append("whisper_api")
        if self._whisper_local.available:  available.append("whisper_local")
        if self._google.available:         available.append("google")
        if self._vosk.available:           available.append("vosk")
        logger.info(f"STT engines available: {available or ['stub']}")

    def transcribe(
        self,
        audio_bytes: bytes,
        language: str = "en",
        input_format: str = "wav",
        prefer_offline: bool = False,
    ) -> STTResult:
        """
        Transcribe audio bytes → text.

        Parameters
        ----------
        audio_bytes   : raw audio file content
        language      : BCP-47 code ("en", "hi", "ne", "bho", …)
        input_format  : audio container format ("wav", "webm", "mp3", …)
        prefer_offline: if True, skip Whisper API and go straight to local
        """
        # Normalise to WAV if needed
        if input_format.lower() != "wav":
            audio_bytes = _to_wav_bytes(audio_bytes, input_format)

        # Build ordered fallback chain
        chain = []
        if not prefer_offline and self._whisper_api.available:
            chain.append(("whisper_api", self._whisper_api))
        if self._whisper_local.available:
            chain.append(("whisper_local", self._whisper_local))
        if self._google.available:
            chain.append(("google", self._google))
        if self._vosk.available:
            chain.append(("vosk", self._vosk))

        for name, engine in chain:
            result = engine.transcribe(audio_bytes, language)
            if result.success and result.text:
                logger.info(f"STT [{name}] → '{result.text[:60]}…'")
                return result
            logger.debug(f"STT [{name}] failed or empty, trying next…")

        # Stub fallback
        logger.warning("All STT engines failed — returning empty transcription")
        return STTResult(
            text="",
            language=language,
            confidence=0.0,
            engine="stub",
            success=False,
            error="No STT engine available",
        )

    def transcribe_file(
        self,
        file_path: str | Path,
        language: str = "en",
        prefer_offline: bool = False,
    ) -> STTResult:
        """Convenience wrapper that reads a file and transcribes it."""
        path = Path(file_path)
        audio_bytes = path.read_bytes()
        fmt = path.suffix.lstrip(".").lower() or "wav"
        return self.transcribe(audio_bytes, language, fmt, prefer_offline)

    def get_available_engines(self) -> list[str]:
        engines = []
        if self._whisper_api.available:    engines.append("whisper_api")
        if self._whisper_local.available:  engines.append("whisper_local")
        if self._google.available:         engines.append("google")
        if self._vosk.available:           engines.append("vosk")
        return engines or ["stub"]


# ─── Singleton ────────────────────────────────────────────────────────────────

_instance: Optional[SpeechToTextService] = None


def get_stt_service() -> SpeechToTextService:
    global _instance
    if _instance is None:
        _instance = SpeechToTextService()
    return _instance


# Legacy shim (keeps old callers working)
def transcribe_audio(audio_path: str, language: str = "en") -> dict:
    result = get_stt_service().transcribe_file(audio_path, language)
    return {"audio_path": audio_path, "text": result.text, "engine": result.engine}
