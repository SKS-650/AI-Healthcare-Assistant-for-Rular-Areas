"""Symptom domain models."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class Symptom:
    """Represents a symptom selected or described by a patient."""

    id: str
    name: str
    severity: int | None = None
    duration_days: int | None = None
