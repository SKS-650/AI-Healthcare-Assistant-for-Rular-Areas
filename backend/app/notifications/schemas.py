"""Pydantic schemas for the Notifications module."""

from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class NotificationItem(BaseModel):
    id:           str
    user_id:      str
    title:        str
    body:         str
    ntype:        str
    module:       Optional[str]
    reference_id: Optional[str]
    is_read:      bool
    created_at:   datetime

    class Config:
        from_attributes = True


class NotificationListResponse(BaseModel):
    notifications:  list[NotificationItem]
    total:          int
    unread_count:   int
    page:           int
    page_size:      int
    total_pages:    int


class NotificationCreate(BaseModel):
    title:        str
    body:         str
    ntype:        str = "info"
    module:       Optional[str] = None
    reference_id: Optional[str] = None


class MarkReadRequest(BaseModel):
    notification_ids: list[str]
