"""Emergency service."""

from __future__ import annotations

from typing import Any


class EmergencyService:
    """Service layer for emergency workflows."""

    def create_alert(self, payload: dict[str, Any]) -> dict[str, Any]:
        return {"status": "mocked", "alert": payload}
