"""Disease domain models."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Disease:
    """Represents a disease or medical condition."""

    id: str
    name: str
    description: str | None = None
    symptoms: list[str] = field(default_factory=list)
    severity: str | None = None
