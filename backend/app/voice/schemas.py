"""Pydantic schemas for voice endpoints."""
from __future__ import annotations

from typing import Optional
from pydantic import BaseModel, Field


class TTSRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000,
                      description="Text to convert to speech")
    language: str = Field("en", description="Language code: en | hi | ne | bho | ...")
    gender: str = Field("female", description="Voice gender: female | male")
    conversation_id: Optional[str] = Field(None)


class TTSResponse(BaseModel):
    success: bool
    audio_url: Optional[str] = None     # URL if audio was saved to disk
    audio_base64: Optional[str] = None  # base64 MP3 if returned inline
    format: str = "mp3"
    engine: str
    language: str
    error: Optional[str] = None


class STTResponse(BaseModel):
    success: bool
    text: str
    language: str
    confidence: float
    engine: str
    duration_seconds: float = 0.0
    error: Optional[str] = None


class VoiceChatResponse(BaseModel):
    success: bool
    # STT result
    transcript: str
    stt_engine: str
    # Chatbot result
    response_text: str
    response_language: str
    intent: str
    is_emergency: bool
    emergency_category: Optional[str]
    follow_up_questions: list[str]
    mode: str                       # "online" | "offline"
    # TTS result
    audio_url: Optional[str] = None
    audio_base64: Optional[str] = None
    audio_format: str = "mp3"
    # Meta
    response_time: float = 0.0
    conversation_id: Optional[str] = None
    error: Optional[str] = None
