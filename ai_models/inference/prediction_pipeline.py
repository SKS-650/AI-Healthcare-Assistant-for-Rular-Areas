"""Prediction pipeline."""

from __future__ import annotations

from typing import Any

from ai_models.inference.inference_engine import InferenceEngine


class PredictionPipeline:
    """End-to-end prediction pipeline."""

    def __init__(self, engine: InferenceEngine | None = None) -> None:
        self.engine = engine or InferenceEngine()

    def run(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Run prediction for a request payload."""

        return self.engine.predict(payload)
