"""Healthcare recommendation engine."""

from __future__ import annotations


def recommend_next_steps(risk_level: str) -> list[str]:
    """Recommend next steps based on risk level."""

    if risk_level == "high":
        return ["Seek emergency care", "Contact a nearby healthcare provider"]
    if risk_level == "medium":
        return ["Schedule a consultation", "Monitor symptoms"]
    return ["Rest", "Stay hydrated", "Monitor symptoms"]
