"""
Voice API Routes
================
POST /api/v1/voice/stt          — upload audio → transcript
POST /api/v1/voice/tts          — text → audio (base64 MP3)
POST /api/v1/voice/chat         — audio → transcript → AI → audio response
GET  /api/v1/voice/languages    — supported language list
GET  /api/v1/voice/health       — engine availability
"""
from __future__ import annotations

import logging
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status

from .schemas import STTResponse, TTSRequest, TTSResponse, VoiceChatResponse
from .service import get_voice_service, VoiceService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/voice", tags=["Voice Assistant"])

_MAX_AUDIO_BYTES = 25 * 1024 * 1024  # 25 MB


# ─── Dependency ───────────────────────────────────────────────────────────────

def _svc() -> VoiceService:
    return get_voice_service()


# ─── STT ─────────────────────────────────────────────────────────────────────

@router.post(
    "/stt",
    response_model=STTResponse,
    summary="Speech-to-Text",
    description="""
Convert uploaded audio to text.

**Supported formats:** wav, mp3, webm, ogg, m4a, flac

**Supported languages:** en, hi, ne, bho, bn, ta, te, mr, gu, kn, ml, pa
    """,
)
async def speech_to_text(
    audio: UploadFile = File(..., description="Audio file to transcribe"),
    language: str = Form("en", description="Expected language code"),
    svc: VoiceService = Depends(_svc),
) -> STTResponse:
    """Transcribe an audio file to text."""
    content = await audio.read()
    if len(content) > _MAX_AUDIO_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Audio file too large (max 25 MB)",
        )
    if not content:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Empty audio file",
        )

    # Detect format from filename
    ext = (audio.filename or "audio.wav").rsplit(".", 1)[-1].lower()
    result = await svc.transcribe(content, language=language, audio_format=ext)

    return STTResponse(
        success=result["success"],
        text=result.get("text", ""),
        language=result.get("language", language),
        confidence=result.get("confidence", 0.0),
        engine=result.get("engine", "stub"),
        duration_seconds=result.get("duration_seconds", 0.0),
        error=result.get("error"),
    )


# ─── TTS ─────────────────────────────────────────────────────────────────────

@router.post(
    "/tts",
    response_model=TTSResponse,
    summary="Text-to-Speech",
    description="""
Convert text to speech audio (returned as base64 MP3).

**Supported voices:** en-IN, hi-IN, ne-NP (Microsoft Edge TTS neural voices)

**Fallback:** Google TTS → pyttsx3 system voice
    """,
)
async def text_to_speech(
    request: TTSRequest,
    svc: VoiceService = Depends(_svc),
) -> TTSResponse:
    """Convert text to speech."""
    result = await svc.synthesize(
        text=request.text,
        language=request.language,
        gender=request.gender,
        return_base64=True,
    )
    return TTSResponse(
        success=result["success"],
        audio_url=result.get("audio_url"),
        audio_base64=result.get("audio_base64"),
        format=result.get("format", "mp3"),
        engine=result.get("engine", "stub"),
        language=request.language,
        error=result.get("error"),
    )


# ─── Voice Chat ───────────────────────────────────────────────────────────────

@router.post(
    "/chat",
    response_model=VoiceChatResponse,
    summary="Voice Chat (full pipeline)",
    description="""
Full voice conversation pipeline:

```
Audio Upload → STT → Language Detection → Intent → AI Response → TTS → Audio Response
```

Returns both text transcript and base64-encoded audio response.
The AI automatically selects online (LLM) or offline (FAISS) mode.
    """,
)
async def voice_chat(
    audio: UploadFile = File(..., description="User's voice audio"),
    language: str = Form("auto", description="Language hint (auto = detect)"),
    conversation_id: Optional[str] = Form(None, description="Continue existing conversation"),
    return_audio: bool = Form(True, description="Include TTS audio in response"),
    svc: VoiceService = Depends(_svc),
) -> VoiceChatResponse:
    """Process a voice message end-to-end."""
    content = await audio.read()
    if len(content) > _MAX_AUDIO_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Audio file too large (max 25 MB)",
        )
    if not content:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Empty audio file",
        )

    ext = (audio.filename or "audio.wav").rsplit(".", 1)[-1].lower()

    result = await svc.voice_chat(
        audio_bytes=content,
        language=language,
        audio_format=ext,
        conversation_id=conversation_id,
        return_audio=return_audio,
    )

    return VoiceChatResponse(
        success=result["success"],
        transcript=result.get("transcript", ""),
        stt_engine=result.get("stt_engine", "stub"),
        response_text=result.get("response_text", ""),
        response_language=result.get("response_language", "en"),
        intent=result.get("intent", "GENERAL_MEDICAL"),
        is_emergency=result.get("is_emergency", False),
        emergency_category=result.get("emergency_category"),
        follow_up_questions=result.get("follow_up_questions", []),
        mode=result.get("mode", "offline"),
        audio_url=result.get("audio_url"),
        audio_base64=result.get("audio_base64"),
        audio_format=result.get("audio_format", "mp3"),
        response_time=result.get("response_time", 0.0),
        conversation_id=result.get("conversation_id"),
        error=result.get("error"),
    )


# ─── Supported Languages ──────────────────────────────────────────────────────

@router.get("/languages", summary="Supported languages")
async def get_languages() -> dict:
    return {
        "languages": [
            {"code": "en",  "name": "English",   "flag": "🇬🇧", "stt": True,  "tts": True},
            {"code": "hi",  "name": "Hindi",     "flag": "🇮🇳", "stt": True,  "tts": True},
            {"code": "ne",  "name": "Nepali",    "flag": "🇳🇵", "stt": True,  "tts": True},
            {"code": "bho", "name": "Bhojpuri",  "flag": "🗣️",  "stt": True,  "tts": True},
            {"code": "bn",  "name": "Bengali",   "flag": "🇧🇩", "stt": True,  "tts": True},
            {"code": "ta",  "name": "Tamil",     "flag": "🇮🇳", "stt": True,  "tts": True},
            {"code": "te",  "name": "Telugu",    "flag": "🇮🇳", "stt": True,  "tts": True},
            {"code": "mr",  "name": "Marathi",   "flag": "🇮🇳", "stt": True,  "tts": True},
        ],
        "default": "en",
        "auto_detect": True,
    }


# ─── Health ───────────────────────────────────────────────────────────────────

@router.get("/health", summary="Voice service health")
async def voice_health(svc: VoiceService = Depends(_svc)) -> dict:
    stt = svc._stt_service()
    tts = svc._tts_service()
    return {
        "status": "ok",
        "stt_engines": stt.get_available_engines() if stt else ["unavailable"],
        "tts_engines": tts.get_available_engines() if tts else ["unavailable"],
    }
