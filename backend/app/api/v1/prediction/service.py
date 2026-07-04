from typing import Any


class PredictionService:
    def predict(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Service layer placeholder.

        Replace the mocked output with model inference logic later.
        """
        return {
            "status": "mocked",
            "input": payload,
            "prediction": None,
        }

