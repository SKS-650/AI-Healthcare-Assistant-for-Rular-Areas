"""Emergency classifier."""

from __future__ import annotations

from ai_models.emergency_detection.emergency_rules import EMERGENCY_KEYWORDS


def is_emergency(text: str) -> bool:
    """Detect emergency keywords in text."""

    normalized = text.lower()
    return any(keyword in normalized for keyword in EMERGENCY_KEYWORDS)
