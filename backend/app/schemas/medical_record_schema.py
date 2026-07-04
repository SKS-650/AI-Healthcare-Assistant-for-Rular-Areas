"""Medical record API schemas."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass
class MedicalRecordCreateRequest:
    patient_id: str
    title: str
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass
class MedicalRecordResponse:
    id: str
    patient_id: str
    title: str
    metadata: dict[str, Any] = field(default_factory=dict)
