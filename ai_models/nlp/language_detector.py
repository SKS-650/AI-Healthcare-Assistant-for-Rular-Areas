"""Language detection helpers."""

from __future__ import annotations


def detect_language(text: str) -> str:
    """Detect language placeholder."""

    return "en" if text else "unknown"
