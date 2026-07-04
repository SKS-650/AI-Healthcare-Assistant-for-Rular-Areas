"""Prediction API schemas.

Lightweight request/response payload shapes used by API layer code.
Kept framework-agnostic to match backend/app/models.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class PredictionRequestSchema:
    """Input payload for a prediction request."""

    patient_id: Optional[str] = None
    features: dict[str, Any] = field(default_factory=dict)


@dataclass
class PredictionResultSchema:
    """Output payload for a prediction request."""

    diagnosis: Optional[str] = None
    probability: Optional[float] = None

    evidence: dict[str, Any] = field(default_factory=dict)

    model_name: Optional[str] = None
    model_version: Optional[str] = None

