"""Emergency API schemas."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class EmergencyRequest:
    user_id: str | None = None
    location: str | None = None
    description: str | None = None


@dataclass
class EmergencyResponse:
    status: str
    message: str
