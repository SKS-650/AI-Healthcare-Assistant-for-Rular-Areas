"""SQLAlchemy ORM models for the offline_sync module.

Tables:
    offline_queue        – pending operations waiting to be processed
    cached_api_response  – server-side response cache with TTL
    sync_history         – audit log of every sync attempt
    local_settings       – per-user offline preferences
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import (
    Boolean, Column, DateTime, ForeignKey,
    Integer, String, Text,
)
from sqlalchemy.orm import relationship

from app.auth.models import Base


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _uuid4() -> str:
    return str(uuid.uuid4())


# ── OfflineQueue ──────────────────────────────────────────────────────────────

class OfflineQueueModel(Base):
    """A single pending operation uploaded from a mobile client."""

    __tablename__ = "offline_queue"
    __allow_unmapped__ = True

    id             = Column(String(36),  primary_key=True, default=_uuid4)
    user_id        = Column(String(36),  ForeignKey("users.id", ondelete="CASCADE"),
                            nullable=False, index=True)
    operation_type = Column(String(50),  nullable=False)   # e.g. save_assessment
    endpoint       = Column(String(255), nullable=False)
    payload        = Column(Text,        nullable=False)   # JSON string
    status         = Column(String(20),  nullable=False, default="pending", index=True)
    retry_count    = Column(Integer,     nullable=False, default=0)
    error_message  = Column(Text,        nullable=True)
    created_at     = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at     = Column(DateTime(timezone=True), default=_utcnow,
                            onupdate=_utcnow, nullable=False)

    user = relationship("UserModel", back_populates=None, lazy="noload")

    def __repr__(self) -> str:
        return f"<OfflineQueue {self.operation_type} [{self.status}]>"


# ── CachedApiResponse ─────────────────────────────────────────────────────────

class CachedApiResponseModel(Base):
    """Server-side cache of expensive API responses."""

    __tablename__ = "cached_api_response"
    __allow_unmapped__ = True

    id              = Column(String(36),  primary_key=True, default=_uuid4)
    cache_key       = Column(String(255), nullable=False, unique=True, index=True)
    response        = Column(Text,        nullable=False)   # JSON string
    expiration_time = Column(DateTime(timezone=True), nullable=False)
    created_at      = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    @property
    def is_expired(self) -> bool:
        return datetime.now(timezone.utc) > self.expiration_time

    def __repr__(self) -> str:
        return f"<CachedApiResponse {self.cache_key}>"


# ── SyncHistory ───────────────────────────────────────────────────────────────

class SyncHistoryModel(Base):
    """Audit record for every synchronisation attempt."""

    __tablename__ = "sync_history"
    __allow_unmapped__ = True

    id           = Column(String(36),  primary_key=True, default=_uuid4)
    user_id      = Column(String(36),  ForeignKey("users.id", ondelete="CASCADE"),
                          nullable=False, index=True)
    sync_type    = Column(String(30),  nullable=False)   # full | upload | download
    status       = Column(String(20),  nullable=False)   # success | failed | partial
    synced_items = Column(Integer,     nullable=False, default=0)
    failed_items = Column(Integer,     nullable=False, default=0)
    duration_ms  = Column(Integer,     nullable=True)
    details      = Column(Text,        nullable=True)
    created_at   = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<SyncHistory {self.sync_type} [{self.status}]>"


# ── LocalSettings ─────────────────────────────────────────────────────────────

class LocalSettingsModel(Base):
    """Per-user offline preferences stored server-side for cross-device sync."""

    __tablename__ = "local_settings"
    __allow_unmapped__ = True

    id                      = Column(String(36),  primary_key=True, default=_uuid4)
    user_id                 = Column(String(36),  ForeignKey("users.id", ondelete="CASCADE"),
                                     nullable=False, unique=True, index=True)
    offline_mode_enabled    = Column(Boolean,     nullable=False, default=True)
    auto_sync_enabled       = Column(Boolean,     nullable=False, default=True)
    sync_on_wifi_only       = Column(Boolean,     nullable=False, default=False)
    cache_articles          = Column(Boolean,     nullable=False, default=True)
    max_cache_age_days      = Column(Integer,     nullable=False, default=7)
    last_sync_at            = Column(DateTime(timezone=True), nullable=True)
    created_at              = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at              = Column(DateTime(timezone=True), default=_utcnow,
                                     onupdate=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<LocalSettings user={self.user_id}>"
