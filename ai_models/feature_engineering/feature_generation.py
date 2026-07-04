"""Generated feature helpers."""

from __future__ import annotations


def generate_risk_score(severity: int | float | None, symptom_count: int) -> float:
    """Generate a simple placeholder risk score."""

    base = float(severity or 0)
    return min(1.0, (base / 10.0) + (symptom_count * 0.05))
