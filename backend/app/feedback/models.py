"""SQLAlchemy ORM model for user feedback."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text

from app.auth.models import Base


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _uuid4() -> str:
    return str(uuid.uuid4())


class UserFeedback(Base):
    """Feedback submitted by mobile-app users."""

    __tablename__ = "user_feedback"
    __allow_unmapped__ = True

    id           = Column(String(36),  primary_key=True, default=_uuid4)
    user_id      = Column(String(36),  ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)

    # Core feedback fields
    category     = Column(String(50),  nullable=False, default="general")
    # category: general | bug_report | feature_request | chatbot | emergency |
    #           health_records | symptom_checker | ui_ux | performance | other

    rating       = Column(Integer,     nullable=True)          # 1-5 stars (optional)
    title        = Column(String(255), nullable=True)
    message      = Column(Text,        nullable=False)
    module       = Column(String(50),  nullable=True)          # which app module

    # Admin management
    status       = Column(String(30),  nullable=False, default="pending")
    # status: pending | reviewed | in_progress | resolved | dismissed

    priority     = Column(String(20),  nullable=False, default="normal")
    # priority: low | normal | high | critical

    admin_notes  = Column(Text,        nullable=True)          # internal admin notes
    resolved_by  = Column(String(36),  ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    resolved_at  = Column(DateTime(timezone=True), nullable=True)

    # Metadata
    app_version  = Column(String(20),  nullable=True)
    platform     = Column(String(20),  nullable=True)          # android | ios | web
    is_anonymous = Column(Boolean,     nullable=False, default=False)

    created_at   = Column(DateTime(timezone=True), default=_utcnow, nullable=False, index=True)
    updated_at   = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<UserFeedback {self.category} status={self.status}>"
