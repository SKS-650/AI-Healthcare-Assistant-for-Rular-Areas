"""Entity extraction helpers."""

from __future__ import annotations


def extract_entities(text: str) -> dict[str, list[str]]:
    """Extract placeholder entities from text."""

    return {"symptoms": [word for word in text.lower().split() if len(word) > 4]}
