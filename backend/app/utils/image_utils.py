"""Image utility helpers."""

from __future__ import annotations

from pathlib import Path


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}


def is_supported_image(filename: str) -> bool:
    """Return whether a filename has a supported image extension."""

    return Path(filename).suffix.lower() in IMAGE_EXTENSIONS
