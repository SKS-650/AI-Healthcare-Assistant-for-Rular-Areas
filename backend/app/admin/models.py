"""
SQLAlchemy ORM models for the Admin module.

Tables:
  - admin_activity_logs
  - system_settings
  - dataset_versions
  - admin_notifications
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    ForeignKey,
    Integer,
    JSON,
    String,
    Text,
)

from app.auth.models import Base


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _uuid4() -> str:
    return str(uuid.uuid4())


# ─── AdminActivityLog ─────────────────────────────────────────────────────────

class AdminActivityLog(Base):
    """Records every admin action for audit trails."""
    __tablename__ = "admin_activity_logs"
    __allow_unmapped__ = True

    id          = Column(String(36), primary_key=True, default=_uuid4)
    admin_id    = Column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    action      = Column(String(100), nullable=False)       # e.g. "user.deactivate"
    module      = Column(String(50),  nullable=False)       # e.g. "users"
    target_id   = Column(String(100), nullable=True)        # ID of affected resource
    target_type = Column(String(50),  nullable=True)        # e.g. "User"
    description = Column(Text,        nullable=True)
    ip_address  = Column(String(45),  nullable=True)
    user_agent  = Column(Text,        nullable=True)
    extra_data  = Column(JSON,        nullable=True)
    severity    = Column(String(20),  nullable=False, default="info")  # info|warning|error|critical
    created_at  = Column(DateTime(timezone=True), default=_utcnow, nullable=False, index=True)

    def __repr__(self) -> str:
        return f"<AdminActivityLog {self.action} by={self.admin_id}>"


# ─── SystemSetting ────────────────────────────────────────────────────────────

class SystemSetting(Base):
    """Key-value store for system-wide settings."""
    __tablename__ = "system_settings"
    __allow_unmapped__ = True

    id          = Column(String(36),  primary_key=True, default=_uuid4)
    key         = Column(String(100), unique=True, nullable=False, index=True)
    value       = Column(Text,        nullable=True)
    value_type  = Column(String(20),  nullable=False, default="string")  # string|int|float|bool|json
    category    = Column(String(50),  nullable=False, default="general")
    description = Column(Text,        nullable=True)
    is_public   = Column(Boolean,     nullable=False, default=False)
    updated_by  = Column(String(36),  ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    updated_at  = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)
    created_at  = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<SystemSetting {self.key}={self.value}>"


# ─── DatasetVersion ───────────────────────────────────────────────────────────

class DatasetVersion(Base):
    """Tracks uploaded dataset versions."""
    __tablename__ = "dataset_versions"
    __allow_unmapped__ = True

    id           = Column(String(36),  primary_key=True, default=_uuid4)
    name         = Column(String(255), nullable=False)
    dataset_type = Column(String(50),  nullable=False)   # symptom|chatbot|disease|faq
    version      = Column(String(20),  nullable=False, default="1.0.0")
    file_path    = Column(String(500), nullable=True)
    file_size_kb = Column(Integer,     nullable=True)
    record_count = Column(Integer,     nullable=True)
    description  = Column(Text,        nullable=True)
    is_active    = Column(Boolean,     nullable=False, default=False)
    uploaded_by  = Column(String(36),  ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    created_at   = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<DatasetVersion {self.name} v{self.version}>"


# ─── AdminNotification ────────────────────────────────────────────────────────

class AdminNotification(Base):
    """System-generated notifications shown in the admin dashboard."""
    __tablename__ = "admin_notifications"
    __allow_unmapped__ = True

    id          = Column(String(36),  primary_key=True, default=_uuid4)
    title       = Column(String(255), nullable=False)
    message     = Column(Text,        nullable=False)
    ntype       = Column(String(50),  nullable=False, default="info")  # info|warning|error|success
    module      = Column(String(50),  nullable=True)
    reference_id= Column(String(100), nullable=True)
    is_read     = Column(Boolean,     nullable=False, default=False)
    created_at  = Column(DateTime(timezone=True), default=_utcnow, nullable=False, index=True)

    def __repr__(self) -> str:
        return f"<AdminNotification {self.title}>"
