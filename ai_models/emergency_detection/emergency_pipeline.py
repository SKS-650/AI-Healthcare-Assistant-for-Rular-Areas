"""Emergency detection pipeline."""

from __future__ import annotations

from ai_models.emergency_detection.emergency_classifier import is_emergency
from ai_models.emergency_detection.severity_estimator import estimate_severity


def run_emergency_pipeline(text: str, symptom_count: int = 0) -> dict[str, object]:
    """Run emergency detection on user text."""

    emergency = is_emergency(text)
    return {"is_emergency": emergency, "severity": estimate_severity(symptom_count, emergency)}
