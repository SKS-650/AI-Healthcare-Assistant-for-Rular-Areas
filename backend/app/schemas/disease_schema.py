"""Disease API schemas."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class DiseaseResponse:
    id: str
    name: str
    description: str | None = None
    symptoms: list[str] = field(default_factory=list)
