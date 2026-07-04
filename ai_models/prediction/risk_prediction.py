"""Risk prediction helpers."""

from __future__ import annotations


def predict_risk(severity: int, emergency_flags: int = 0) -> str:
    """Predict risk level from severity and emergency signals."""

    if emergency_flags > 0 or severity >= 8:
        return "high"
    if severity >= 4:
        return "medium"
    return "low"
