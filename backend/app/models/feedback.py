"""Feedback domain models."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class Feedback:
    """Represents user feedback."""

    id: str
    user_id: str | None
    message: str
    rating: int | None = None
    created_at: datetime = field(default_factory=datetime.utcnow)
