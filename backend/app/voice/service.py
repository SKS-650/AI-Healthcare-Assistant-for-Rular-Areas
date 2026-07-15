"""
Voice Service — bridges STT / TTS AI modules with FastAPI route handlers.
"""
from __future__ import annotations

import base64
import logging
import os
import time
import uuid
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)

# Directory for persisted TTS audio files
_AUDIO_DIR = Path(__file__).parent.parent / "uploads" / "audio"
_AUDIO_DIR.mkdir(parents=True, exist_ok=True)


class VoiceService:
    """Thin wrapper that lazily loads the AI speech modules."""

    def __init__(self) -> None:
        self._stt = None
        self._tts = None
        self._engine = None

    # ── lazy loaders ─────────────────────────────────────────────────────────

    def _stt_service(self):
        if self._stt is None:
            try:
                import sys
                # Ensure project root is importable
                root = str(Path(__file__).parent.parent.parent.parent)
                if root not in sys.path:
                    sys.path.insert(0, root)
                from ai_models.speech.speech_to_text import get_stt_service
                self._stt = get_stt_service()
            except Exception as exc:
                logger.error(f"Failed to load STT service: {exc}")
        return self._stt

    def _tts_service(self):
        if self._tts is None:
            try:
                import sys
                root = str(Path(__file__).parent.parent.parent.parent)
                if root not in sys.path:
                    sys.path.insert(0, root)
                from ai_models.speech.text_to_speech import get_tts_service
                self._tts = get_tts_service()
            except Exception as exc:
                logger.error(f"Failed to load TTS service: {exc}")
        return self._tts

    def _chatbot_engine(self):
        if self._engine is None:
            try:
                import sys
                root = str(Path(__file__).parent.parent.parent.parent)
                if root not in sys.path:
                    sys.path.insert(0, root)
                from ai_models.chatbot.chatbot_engine import get_chatbot_engine
                self._engine = get_chatbot_engine(enable_tts=False)
            except Exception as exc:
                logger.error(f"Failed to load chatbot engine: {exc}")
        return self._engine

    # ── STT ──────────────────────────────────────────────────────────────────

    async def transcribe(
        self,
        audio_bytes: bytes,
        language: str = "en",
        audio_format: str = "wav",
    ) -> dict:
        stt = self._stt_service()
        if stt is None:
            return {"success": False, "text": "", "language": language,
                    "confidence": 0.0, "engine": "stub",
                    "error": "STT service unavailable"}
        try:
            result = stt.transcribe(
                audio_bytes, language=language, input_format=audio_format
            )
            return {
                "success": result.success,
                "text": result.text,
                "language": result.language,
                "confidence": result.confidence,
                "engine": result.engine,
                "duration_seconds": result.duration_seconds,
                "error": result.error,
            }
        except Exception as exc:
            logger.error(f"STT error: {exc}")
            return {"success": False, "text": "", "language": language,
                    "confidence": 0.0, "engine": "stub", "error": str(exc)}

    # ── TTS ──────────────────────────────────────────────────────────────────

    async def synthesize(
        self,
        text: str,
        language: str = "en",
        gender: str = "female",
        return_base64: bool = True,
    ) -> dict:
        tts = self._tts_service()
        if tts is None:
            return {"success": False, "engine": "stub",
                    "error": "TTS service unavailable"}
        try:
            result = tts.synthesize(text, language=language, gender=gender)
            if not result.success or not result.audio_bytes:
                return {"success": False, "engine": result.engine,
                        "error": result.error or "Empty audio"}

            audio_url = None
            audio_b64  = None

            if return_base64:
                audio_b64 = base64.b64encode(result.audio_bytes).decode()
            else:
                fname = f"{uuid.uuid4().hex}.{result.format}"
                fpath = _AUDIO_DIR / fname
                fpath.write_bytes(result.audio_bytes)
                audio_url = f"/uploads/audio/{fname}"

            return {
                "success": True,
                "audio_url": audio_url,
                "audio_base64": audio_b64,
                "format": result.format,
                "engine": result.engine,
                "language": language,
            }
        except Exception as exc:
            logger.error(f"TTS error: {exc}")
            return {"success": False, "engine": "stub", "error": str(exc)}

    # ── Voice Chat (STT → AI → TTS) ───────────────────────────────────────────

    async def voice_chat(
        self,
        audio_bytes: bytes,
        language: str = "auto",
        audio_format: str = "wav",
        conversation_id: Optional[str] = None,
        return_audio: bool = True,
    ) -> dict:
        t0 = time.time()
        conv_id = conversation_id or str(uuid.uuid4())

        # Step 1 — STT
        stt_result = await self.transcribe(audio_bytes, language, audio_format)
        transcript = stt_result.get("text", "")

        if not transcript:
            return {
                "success": False,
                "transcript": "",
                "stt_engine": stt_result.get("engine", "stub"),
                "response_text": "I could not understand the audio. Please try again.",
                "response_language": language,
                "intent": "GENERAL_CHAT",
                "is_emergency": False,
                "emergency_category": None,
                "follow_up_questions": [],
                "mode": "offline",
                "conversation_id": conv_id,
                "error": stt_result.get("error"),
                "response_time": time.time() - t0,
            }

        # Detected language from STT (use it for response)
        detected_lang = stt_result.get("language", language)
        if detected_lang in ("auto", ""):
            detected_lang = language

        # Step 2 — Chatbot
        engine = self._chatbot_engine()
        if engine is None:
            resp_text = (
                "I'm sorry, the AI service is currently unavailable. "
                "Please consult a healthcare professional for medical advice."
            )
            intent = "GENERAL_MEDICAL"
            is_emergency = False
            emergency_category = None
            follow_ups: list = []
            mode = "offline"
        else:
            chat_result = engine.process(
                user_input=transcript,
                conversation_id=conv_id,
                language_hint=detected_lang if detected_lang != "auto" else None,
            )
            resp_text = chat_result.text
            intent = chat_result.intent
            is_emergency = chat_result.is_emergency
            emergency_category = chat_result.emergency_category
            follow_ups = chat_result.follow_up_questions
            mode = chat_result.mode.value

        # Step 3 — TTS
        audio_url = None
        audio_b64 = None
        audio_format_out = "mp3"

        if return_audio and resp_text:
            tts_result = await self.synthesize(resp_text, detected_lang, return_base64=True)
            if tts_result.get("success"):
                audio_b64 = tts_result.get("audio_base64")
                audio_format_out = tts_result.get("format", "mp3")

        return {
            "success": True,
            "transcript": transcript,
            "stt_engine": stt_result.get("engine", "stub"),
            "response_text": resp_text,
            "response_language": detected_lang,
            "intent": intent,
            "is_emergency": is_emergency,
            "emergency_category": emergency_category,
            "follow_up_questions": follow_ups,
            "mode": mode,
            "audio_url": audio_url,
            "audio_base64": audio_b64,
            "audio_format": audio_format_out,
            "response_time": time.time() - t0,
            "conversation_id": conv_id,
        }


# singleton
_svc: VoiceService | None = None


def get_voice_service() -> VoiceService:
    global _svc
    if _svc is None:
        _svc = VoiceService()
    return _svc
