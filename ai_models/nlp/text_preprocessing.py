"""Text preprocessing utilities."""

from __future__ import annotations


def clean_text(text: str) -> str:
    """Normalize whitespace and lowercase text."""

    return " ".join(text.lower().strip().split())
