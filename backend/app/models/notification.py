"""Notification domain models."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class Notification:
    """Represents an in-app or push notification."""

    id: str
    user_id: str
    title: str
    message: str
    read: bool = False
    created_at: datetime = field(default_factory=datetime.utcnow)
