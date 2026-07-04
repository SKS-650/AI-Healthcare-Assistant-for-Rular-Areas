"""Speech utility helpers."""

from __future__ import annotations

from pathlib import Path


AUDIO_EXTENSIONS = {".wav", ".mp3", ".m4a", ".ogg"}


def is_supported_audio(filename: str) -> bool:
    """Return whether an audio filename is supported."""

    return Path(filename).suffix.lower() in AUDIO_EXTENSIONS
