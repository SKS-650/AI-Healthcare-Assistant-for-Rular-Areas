"""Emergency domain models."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class EmergencyRequest:
    """Input for emergency assistance."""

    location: dict[str, Any] = field(default_factory=dict)  # {lat, lon, address}
    symptoms: list[str] = field(default_factory=list)
    severity_hint: Optional[str] = None
    patient_id: Optional[str] = None


@dataclass
class EmergencyDispatch:
    """Output for emergency assistance dispatch."""

    recommended_service: Optional[str] = None  # ambulance/hospital/etc.
    hospital_id: Optional[str] = None
    contact_phone: Optional[str] = None

    # Additional guidance/instructions (if any).
    instructions: Optional[str] = None

    # Evidence/features leading to dispatch.
    evidence: dict[str, Any] = field(default_factory=dict)

