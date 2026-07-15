"""Pydantic schemas for the offline_sync API."""

from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


# ── Queue item ────────────────────────────────────────────────────────────────

class QueueItemIn(BaseModel):
    id:             str
    operation_type: str
    endpoint:       str
    payload:        str          # JSON string
    retry_count:    int = 0
    created_at:     datetime
    updated_at:     datetime


class QueueItemOut(QueueItemIn):
    status:        str
    error_message: Optional[str] = None

    model_config = {"from_attributes": True}


# ── Sync request / response ───────────────────────────────────────────────────

class SyncUploadRequest(BaseModel):
    """Payload sent by the mobile client to upload pending operations."""

    items: List[QueueItemIn] = Field(..., description="Pending queue items to process")


class SyncUploadResponse(BaseModel):
    status:       str
    synced_items: int
    failed_items: int
    results:      List[Dict[str, Any]] = []
    last_sync:    datetime


class SyncDownloadResponse(BaseModel):
    """Data the server sends down to the mobile client."""

    status:        str
    synced_items:  int
    last_sync:     datetime
    symptom_data:  Optional[Dict[str, Any]] = None
    articles_meta: Optional[List[Dict[str, Any]]] = None


class FullSyncResponse(BaseModel):
    status:       str
    synced_items: int
    failed_items: int
    last_sync:    datetime
    message:      str = ""


# ── Sync history ──────────────────────────────────────────────────────────────

class SyncHistoryOut(BaseModel):
    id:           str
    sync_type:    str
    status:       str
    synced_items: int
    failed_items: int
    duration_ms:  Optional[int] = None
    details:      Optional[str] = None
    created_at:   datetime

    model_config = {"from_attributes": True}


class SyncHistoryListResponse(BaseModel):
    history: List[SyncHistoryOut]
    total:   int


# ── Settings ──────────────────────────────────────────────────────────────────

class LocalSettingsIn(BaseModel):
    offline_mode_enabled: bool = True
    auto_sync_enabled:    bool = True
    sync_on_wifi_only:    bool = False
    cache_articles:       bool = True
    max_cache_age_days:   int  = Field(7, ge=1, le=90)


class LocalSettingsOut(LocalSettingsIn):
    id:          str
    user_id:     str
    last_sync_at: Optional[datetime] = None
    updated_at:  datetime

    model_config = {"from_attributes": True}
