"""Voice/Audio service.

This service encapsulates audio capture/transcription and related utilities.

Current implementation is placeholder-only.
"""

from __future__ import annotations

from dataclasses import asdict
from typing import Any, Optional


class VoiceService:
    """Service layer for voice processing."""

    def transcribe(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Transcribe an audio payload.

        Args:
            payload: Expected to contain an audio reference (e.g., base64,
                     URL, or file metadata).

        Returns:
            Serializable dict with transcription text.
        """

        audio_ref = payload.get("audio") or payload.get("audio_ref")
        # Placeholder transcription.
        transcription = "[transcription unavailable - mocked]"

        return {
            "status": "mocked",
            "result": {"transcription": transcription, "audio_ref": audio_ref},
        }

    def synthesize(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Convert text to speech (placeholder)."""

        text = payload.get("text")
        return {
            "status": "mocked",
            "result": {
                "audio": "[tts-audio-unavailable - mocked]",
                "text": text,
            },
        }

