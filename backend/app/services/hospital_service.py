"""Hospital lookup service.

Business logic for retrieving hospital information.

This module is currently a safe placeholder; production code can integrate
MongoDB/Firestore/Redis caches.
"""

from __future__ import annotations

from dataclasses import asdict
from typing import Any, Optional

from app.models.hospital import Hospital


class HospitalService:
    """Service layer for hospitals."""

    def find_nearby(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Find nearby hospitals.

        Args:
            payload: Expected keys (optional):
              - latitude (float)
              - longitude (float)
              - radius_km (float)

        Returns:
            Serializable dict.
        """

        # Placeholder: return a single mock hospital.
        hospital = Hospital(
            id="mock-hospital-1",
            name="Mock General Hospital",
            address=payload.get("address") or None,
            phone=payload.get("phone") or None,
            latitude=payload.get("latitude"),
            longitude=payload.get("longitude"),
        )

        return {
            "status": "mocked",
            "result": asdict(hospital),
        }

    def get_hospital(self, hospital_id: str) -> dict[str, Any]:
        """Fetch hospital by id (placeholder)."""

        hospital = Hospital(
            id=hospital_id,
            name="Mock Hospital",
            address=None,
            phone=None,
        )

        return {"status": "mocked", "result": asdict(hospital)}

