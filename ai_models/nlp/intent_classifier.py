"""Intent classification helpers."""

from __future__ import annotations


def classify_intent(text: str) -> str:
    """Classify user intent with placeholder rules."""

    normalized = text.lower()
    if "hospital" in normalized or "nearby" in normalized:
        return "find_healthcare"
    if "medicine" in normalized or "reminder" in normalized:
        return "medicine_reminder"
    return "health_question"
