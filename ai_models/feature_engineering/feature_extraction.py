"""Feature extraction utilities."""

from __future__ import annotations

from typing import Any


def extract_symptom_features(record: dict[str, Any]) -> dict[str, Any]:
    """Extract normalized symptom features from a record."""

    symptoms = record.get("symptoms", [])
    if isinstance(symptoms, str):
        symptoms = [symptoms]
    return {"symptom_count": len(symptoms), "symptoms": symptoms}
