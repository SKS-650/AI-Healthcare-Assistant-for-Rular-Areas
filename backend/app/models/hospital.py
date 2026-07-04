"""Hospital domain models."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional


@dataclass
class Hospital:
    id: str
    name: str
    address: Optional[str] = None
    phone: Optional[str] = None

    latitude: Optional[float] = None
    longitude: Optional[float] = None

