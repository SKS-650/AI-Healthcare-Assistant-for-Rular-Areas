"""
Text-to-Speech Service - Production TTS pipeline.

Priority order:
  1. Edge TTS   (Microsoft Azure neural voices, free, needs internet, best quality)
  2. gTTS       (Google TTS, free, needs internet, good quality)
  3. pyttsx3    (Offline system TTS, no internet, basic quality)
  4. Stub       (returns empty audio path with warning)

Supports: English, Hindi, Nepali, Bhojpuri
Outputs:  MP3 bytes (returned in-memory) + optional file save
"""

from __future__ import annotations

import asyncio
import io
import logging
import os
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)


# ─── Voice mappings ───────────────────────────────────────────────────────────

# Edge TTS neural voice names — highest quality
_EDGE_VOICES: dict[str, str] = {
    "en":  "en-IN-NeerjaNeural",      # Indian English — friendly female
    "hi":  "hi-IN-SwaraNeural",       # Hindi female
    "ne":  "ne-NP-HemkalaNeural",     # Nepali female
    "bho": "hi-IN-MadhurNeural",      # Bhojpuri → Hindi male (closest)
    "bn":  "bn-IN-TanishaaNeural",
    "ta":  "ta-IN-PallaviNeural",
    "te":  "te-IN-ShrutiNeural",
    "mr":  "mr-IN-AarohiNeural",
    "gu":  "gu-IN-DhwaniNeural",
    "kn":  "kn-IN-SapnaNeural",
    "ml":  "ml-IN-SobhanaNeural",
    "pa":  "pa-IN-OjasNeural",
}

# Edge TTS alternate (male) voices
_EDGE_VOICES_MALE: dict[str, str] = {
    "en":  "en-IN-PrabhatNeural",
    "hi":  "hi-IN-MadhurNeural",
    "ne":  "ne-NP-SagarNeural",
    "bho": "hi-IN-MadhurNeural",
}

# gTTS language codes
_GTTS_LANG: dict[str, str] = {
    "en":  "en",
    "hi":  "hi",
    "ne":  "ne",
    "bho": "hi",
    "bn":  "bn",
    "ta":  "ta",
    "te":  "te",
    "mr":  "mr",
    "gu":  "gu",
    "kn":  "kn",
    "ml":  "ml",
    "pa":  "pa",
}


# ─── Result ───────────────────────────────────────────────────────────────────

@dataclass
class TTSResult:
    audio_bytes: bytes          # raw MP3/WAV bytes
    language: str
    engine: str                 # "edge_tts" | "gtts" | "pyttsx3" | "stub"
    format: str = "mp3"         # audio format
    duration_hint_seconds: float = 0.0
    success: bool = True
    saved_path: Optional[str] = None
    error: Optional[str] = None


# ─── TTS Engines ─────────────────────────────────────────────────────────────

class _EdgeTTSEngine:
    """Microsoft Edge TTS — neural voices, free, needs internet."""

    @property
    def available(self) -> bool:
        try:
            import edge_tts  # noqa: F401 type: ignore
            return True
        except ImportError:
            return False

    def synthesize(self, text: str, language: str = "en", gender: str = "female") -> TTSResult:
        try:
            import edge_tts  # type: ignore

            voice = (
                _EDGE_VOICES_MALE.get(language, _EDGE_VOICES.get(language, "en-IN-PrabhatNeural"))
                if gender == "male"
                else _EDGE_VOICES.get(language, "en-IN-NeerjaNeural")
            )

            audio_buf = io.BytesIO()

            async def _run():
                communicate = edge_tts.Communicate(text, voice)
                async for chunk in communicate.stream():
                    if chunk["type"] == "audio":
                        audio_buf.write(chunk["data"])

            # Run in a fresh event loop (works even inside async FastAPI context
            # via run_in_executor call from caller)
            try:
                loop = asyncio.get_event_loop()
                if loop.is_running():
                    # We're inside an async context — use a thread
                    import concurrent.futures
                    with concurrent.futures.ThreadPoolExecutor() as pool:
                        pool.submit(asyncio.run, _run()).result()
                else:
                    loop.run_until_complete(_run())
            except RuntimeError:
                asyncio.run(_run())

            audio_bytes = audio_buf.getvalue()
            if not audio_bytes:
                raise ValueError("Edge TTS produced no audio")

            return TTSResult(
                audio_bytes=audio_bytes,
                language=language,
                engine="edge_tts",
                format="mp3",
                success=True,
            )
        except Exception as exc:
            logger.warning(f"Edge TTS failed: {exc}")
            return TTSResult(
                audio_bytes=b"", language=language, engine="edge_tts",
                success=False, error=str(exc),
            )


class _GTTSEngine:
    """Google TTS (gTTS) — free, needs internet."""

    @property
    def available(self) -> bool:
        try:
            import gtts  # noqa: F401 type: ignore
            return True
        except ImportError:
            return False

    def synthesize(self, text: str, language: str = "en", **_) -> TTSResult:
        try:
            from gtts import gTTS  # type: ignore

            lang = _GTTS_LANG.get(language, "en")
            tts_obj = gTTS(text=text, lang=lang, slow=False)

            buf = io.BytesIO()
            tts_obj.write_to_fp(buf)
            audio_bytes = buf.getvalue()

            return TTSResult(
                audio_bytes=audio_bytes,
                language=language,
                engine="gtts",
                format="mp3",
                success=bool(audio_bytes),
            )
        except Exception as exc:
            logger.warning(f"gTTS failed: {exc}")
            return TTSResult(
                audio_bytes=b"", language=language, engine="gtts",
                success=False, error=str(exc),
            )


class _Pyttsx3Engine:
    """pyttsx3 — offline system TTS. English-only on most systems."""

    @property
    def available(self) -> bool:
        try:
            import pyttsx3  # noqa: F401 type: ignore
            return True
        except ImportError:
            return False

    def synthesize(self, text: str, language: str = "en", **_) -> TTSResult:
        try:
            import pyttsx3  # type: ignore

            engine = pyttsx3.init()
            engine.setProperty("rate", 150)
            engine.setProperty("volume", 1.0)

            with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
                tmp_path = tmp.name

            engine.save_to_file(text, tmp_path)
            engine.runAndWait()
            engine.stop()

            audio_bytes = Path(tmp_path).read_bytes()
            os.unlink(tmp_path)

            return TTSResult(
                audio_bytes=audio_bytes,
                language=language,
                engine="pyttsx3",
                format="wav",
                success=bool(audio_bytes),
            )
        except Exception as exc:
            logger.warning(f"pyttsx3 failed: {exc}")
            return TTSResult(
                audio_bytes=b"", language=language, engine="pyttsx3",
                success=False, error=str(exc),
            )


# ─── Main TTS Service ─────────────────────────────────────────────────────────

class TextToSpeechService:
    """
    Multi-engine TTS with automatic fallback.

    Usage
    -----
    tts = TextToSpeechService()
    result = tts.synthesize("नमस्ते, आप कैसे हैं?", language="hi")
    # result.audio_bytes contains MP3 data
    with open("response.mp3", "wb") as f:
        f.write(result.audio_bytes)
    """

    def __init__(self) -> None:
        self._edge  = _EdgeTTSEngine()
        self._gtts  = _GTTSEngine()
        self._pytts = _Pyttsx3Engine()

        avail = []
        if self._edge.available:   avail.append("edge_tts")
        if self._gtts.available:   avail.append("gtts")
        if self._pytts.available:  avail.append("pyttsx3")
        logger.info(f"TTS engines available: {avail or ['stub']}")

    def synthesize(
        self,
        text: str,
        language: str = "en",
        gender: str = "female",
        save_to: Optional[str] = None,
        prefer_offline: bool = False,
    ) -> TTSResult:
        """
        Convert text to audio.

        Parameters
        ----------
        text         : text to speak
        language     : language code ("en", "hi", "ne", "bho", …)
        gender       : "female" | "male"
        save_to      : optional file path to persist the audio
        prefer_offline: if True skip Edge/gTTS and use pyttsx3 first
        """
        if not text or not text.strip():
            return TTSResult(
                audio_bytes=b"", language=language, engine="stub",
                success=False, error="Empty text",
            )

        # Truncate very long responses to ~800 chars for TTS
        if len(text) > 800:
            text = text[:797] + "…"

        # Clean markdown before TTS
        text = _strip_markdown(text)

        # Build fallback chain
        chain = []
        if prefer_offline:
            if self._pytts.available:  chain.append(self._pytts)
            if self._gtts.available:   chain.append(self._gtts)
            if self._edge.available:   chain.append(self._edge)
        else:
            if self._edge.available:   chain.append(self._edge)
            if self._gtts.available:   chain.append(self._gtts)
            if self._pytts.available:  chain.append(self._pytts)

        for engine in chain:
            result = engine.synthesize(text, language, gender=gender)
            if result.success and result.audio_bytes:
                logger.info(f"TTS [{result.engine}] → {len(result.audio_bytes)} bytes")
                if save_to:
                    result = _save_audio(result, save_to)
                return result
            logger.debug(f"TTS [{engine.__class__.__name__}] failed, trying next…")

        logger.warning("All TTS engines failed")
        return TTSResult(
            audio_bytes=b"", language=language, engine="stub",
            success=False, error="No TTS engine available",
        )

    async def synthesize_async(
        self,
        text: str,
        language: str = "en",
        gender: str = "female",
        save_to: Optional[str] = None,
    ) -> TTSResult:
        """
        Async wrapper — runs Edge TTS natively in async context,
        falls back to thread-pool for blocking engines.
        """
        if not text or not text.strip():
            return TTSResult(
                audio_bytes=b"", language=language, engine="stub",
                success=False, error="Empty text",
            )

        text = _strip_markdown(text[:800])

        # Try Edge TTS natively async
        if self._edge.available:
            try:
                import edge_tts  # type: ignore

                voice = _EDGE_VOICES.get(language, "en-IN-NeerjaNeural")
                if gender == "male":
                    voice = _EDGE_VOICES_MALE.get(language, voice)

                audio_buf = io.BytesIO()
                communicate = edge_tts.Communicate(text, voice)
                async for chunk in communicate.stream():
                    if chunk["type"] == "audio":
                        audio_buf.write(chunk["data"])

                audio_bytes = audio_buf.getvalue()
                if audio_bytes:
                    result = TTSResult(
                        audio_bytes=audio_bytes, language=language,
                        engine="edge_tts", format="mp3", success=True,
                    )
                    if save_to:
                        result = _save_audio(result, save_to)
                    return result
            except Exception as exc:
                logger.warning(f"Async Edge TTS failed: {exc}")

        # Fall back to blocking engines in thread pool
        loop = asyncio.get_event_loop()
        result = await loop.run_in_executor(
            None, lambda: self.synthesize(text, language, gender, save_to)
        )
        return result

    def get_available_engines(self) -> list[str]:
        engines = []
        if self._edge.available:   engines.append("edge_tts")
        if self._gtts.available:   engines.append("gtts")
        if self._pytts.available:  engines.append("pyttsx3")
        return engines or ["stub"]


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _strip_markdown(text: str) -> str:
    """Remove common markdown so TTS reads clean prose."""
    import re
    text = re.sub(r"\*\*(.+?)\*\*", r"\1", text)          # **bold**
    text = re.sub(r"\*(.+?)\*",     r"\1", text)           # *italic*
    text = re.sub(r"#{1,6}\s?",     "",    text)           # headings
    text = re.sub(r"`(.+?)`",       r"\1", text)           # `code`
    text = re.sub(r"\[(.+?)\]\(.+?\)", r"\1", text)        # [link](url)
    text = re.sub(r"^\s*[-*+]\s+",  "",    text, flags=re.MULTILINE)  # bullets
    text = re.sub(r"\n{2,}",        " ",   text)           # double newlines
    text = re.sub(r"\s{2,}",        " ",   text)           # extra spaces
    return text.strip()


def _save_audio(result: TTSResult, path: str) -> TTSResult:
    try:
        save_path = Path(path)
        save_path.parent.mkdir(parents=True, exist_ok=True)
        save_path.write_bytes(result.audio_bytes)
        result.saved_path = str(save_path)
        logger.debug(f"TTS audio saved to {path}")
    except Exception as exc:
        logger.warning(f"Could not save TTS audio: {exc}")
    return result


# ─── Singleton ────────────────────────────────────────────────────────────────

_instance: Optional[TextToSpeechService] = None


def get_tts_service() -> TextToSpeechService:
    global _instance
    if _instance is None:
        _instance = TextToSpeechService()
    return _instance


# Legacy shim
def synthesize_speech(text: str, language: str = "en") -> dict:
    result = get_tts_service().synthesize(text, language)
    return {"text": text, "audio_bytes": result.audio_bytes, "engine": result.engine}
