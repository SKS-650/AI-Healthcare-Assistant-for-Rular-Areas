from typing import Any

from .service import PredictionService


class PredictionController:
    def __init__(self, service: PredictionService) -> None:
        self.service = service

    def predict(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Controller layer.

        This is a thin wrapper around the service layer.
        """
        return self.service.predict(payload=payload)

