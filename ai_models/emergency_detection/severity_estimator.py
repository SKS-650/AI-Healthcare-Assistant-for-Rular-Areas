"""Severity estimation helpers."""

from __future__ import annotations


def estimate_severity(symptom_count: int, has_emergency_signal: bool) -> int:
    """Estimate severity on a 1 to 10 scale."""

    if has_emergency_signal:
        return 10
    return max(1, min(10, symptom_count * 2))
