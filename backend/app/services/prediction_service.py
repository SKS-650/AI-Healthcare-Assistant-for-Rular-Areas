"""Prediction service.

This module contains the business logic for performing medical predictions.

Note:
- Current API endpoints may use mocked output until ML/model inference is
  implemented.
- Keep this service framework-agnostic so it can be reused by REST,
  WebSocket, and mobile backends.
"""

from __future__ import annotations

from dataclasses import asdict
from typing import Any, Optional

from app.models.prediction import PredictionResult


class PredictionService:
    """Service layer for prediction tasks."""

    def predict(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Predict medical outcome from the given payload.

        Args:
            payload: Free-form dictionary coming from API layer.

        Returns:
            Dictionary that can be serialized by FastAPI.
        """

        # TODO: Replace mocked output with model inference.
        result = PredictionResult(
            diagnosis=None,
            probability=None,
            evidence=payload.get("features") or {},
            model_name=None,
            model_version=None,
        )

        return {
            "status": "mocked",
            "result": asdict(result),
        }

