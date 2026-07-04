"""Symptom API schemas."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class SymptomRequest:
    name: str
    severity: int | None = None
    duration_days: int | None = None


@dataclass
class SymptomResponse:
    id: str
    name: str
    severity: int | None = None
