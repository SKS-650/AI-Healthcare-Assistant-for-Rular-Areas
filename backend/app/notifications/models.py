"""SQLAlchemy ORM models for the Notifications module."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, String, Text
from app.auth.models import Base


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _uuid4() -> str:
    return str(uuid.uuid4())


class UserNotification(Base):
    """In-app notification delivered to a specific user."""

    __tablename__ = "user_notifications"
    __allow_unmapped__ = True

    id           = Column(String(36),  primary_key=True, default=_uuid4)
    user_id      = Column(String(36),  ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title        = Column(String(255), nullable=False)
    body         = Column(Text,        nullable=False)
    ntype        = Column(String(50),  nullable=False, default="info")   # info|warning|success|alert
    module       = Column(String(50),  nullable=True)                    # chatbot|emergency|education|system
    reference_id = Column(String(100), nullable=True)                    # ID of related object
    is_read      = Column(Boolean,     nullable=False, default=False)
    created_at   = Column(DateTime(timezone=True), default=_utcnow, nullable=False, index=True)

    def __repr__(self) -> str:
        return f"<UserNotification {self.title!r} user={self.user_id}>"
