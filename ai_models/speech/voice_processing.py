"""
Voice Processing - Audio utilities: chunking, noise reduction, format detection.
"""

from __future__ import annotations

import io
import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)


@dataclass
class AudioInfo:
    duration_seconds: float
    sample_rate: int
    channels: int
    format: str
    size_bytes: int


def get_audio_info(audio_bytes: bytes, fmt: str = "wav") -> Optional[AudioInfo]:
    """Return basic audio metadata. Requires pydub."""
    try:
        from pydub import AudioSegment  # type: ignore

        seg = AudioSegment.from_file(io.BytesIO(audio_bytes), format=fmt)
        return AudioInfo(
            duration_seconds=len(seg) / 1000.0,
            sample_rate=seg.frame_rate,
            channels=seg.channels,
            format=fmt,
            size_bytes=len(audio_bytes),
        )
    except Exception as exc:
        logger.debug(f"get_audio_info failed: {exc}")
        return None


def validate_audio(
    audio_bytes: bytes,
    max_duration: float = 60.0,
    min_duration: float = 0.2,
) -> tuple[bool, str]:
    """
    Validate audio for STT processing.

    Returns (is_valid, reason_if_invalid).
    """
    if not audio_bytes:
        return False, "Empty audio data"

    size_kb = len(audio_bytes) / 1024
    if size_kb > 25_000:
        return False, f"Audio too large: {size_kb:.0f} KB (max 25 MB)"

    info = get_audio_info(audio_bytes)
    if info:
        if info.duration_seconds < min_duration:
            return False, f"Audio too short: {info.duration_seconds:.1f}s"
        if info.duration_seconds > max_duration:
            return False, f"Audio too long: {info.duration_seconds:.1f}s (max {max_duration}s)"

    return True, ""


def detect_format(audio_bytes: bytes) -> str:
    """Detect audio format from magic bytes."""
    if len(audio_bytes) < 4:
        return "wav"

    magic = audio_bytes[:4]
    if magic[:3] == b"ID3" or magic[:2] == b"\xff\xfb":
        return "mp3"
    if magic == b"fLaC":
        return "flac"
    if magic[:4] == b"OggS":
        return "ogg"
    if magic[:4] == b"RIFF":
        return "wav"
    if magic[:4] in (b"\x1a\x45\xdf\xa3", b"\x1f\x43\xb6\x75"):
        return "webm"
    # Default
    return "wav"


def split_audio_chunks(
    audio_bytes: bytes,
    chunk_ms: int = 30_000,
    fmt: str = "wav",
) -> list[bytes]:
    """
    Split long audio into chunks for processing.
    Falls back to returning the full audio if pydub not available.
    """
    try:
        from pydub import AudioSegment  # type: ignore

        seg = AudioSegment.from_file(io.BytesIO(audio_bytes), format=fmt)
        chunks = []
        for start_ms in range(0, len(seg), chunk_ms):
            chunk = seg[start_ms: start_ms + chunk_ms]
            buf = io.BytesIO()
            chunk.export(buf, format="wav")
            chunks.append(buf.getvalue())
        return chunks
    except Exception as exc:
        logger.debug(f"Audio chunking skipped: {exc}")
        return [audio_bytes]
