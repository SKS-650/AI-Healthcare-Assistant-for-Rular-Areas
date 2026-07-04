"""Prediction domain models.

These models provide a clear boundary between the API layer and any ML/
heuristic inference implemented in the service layer.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class PredictionResult:
    """Unified result for a medical prediction task."""

    diagnosis: Optional[str] = None
    probability: Optional[float] = None

    # Optional structured evidence / features used.
    evidence: dict[str, Any] = field(default_factory=dict)

    # Model/model-version info for auditability.
    model_name: Optional[str] = None
    model_version: Optional[str] = None


@dataclass
class PredictionRequest:
    """Input payload for a prediction request."""

    patient_id: Optional[str] = None
    features: dict[str, Any] = field(default_factory=dict)

