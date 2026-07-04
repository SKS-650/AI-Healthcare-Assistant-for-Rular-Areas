"""Symptom classification logic."""

from __future__ import annotations


def classify_symptom(symptom: str) -> str:
    """Classify symptom category."""

    return "general" if symptom else "unknown"
