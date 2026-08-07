"""Pydantic schemas for the Feedback module."""

from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


# ── Mobile-app submission ─────────────────────────────────────────────────────

class FeedbackCreate(BaseModel):
    category: str = "general"
    rating: Optional[int] = Field(None, ge=1, le=5)
    title: Optional[str] = None
    message: str = Field(..., min_length=5)
    module: Optional[str] = None
    app_version: Optional[str] = None
    platform: Optional[str] = None
    is_anonymous: bool = False


# ── Admin response models ─────────────────────────────────────────────────────

class FeedbackItem(BaseModel):
    id: str
    user_id: Optional[str]
    user_name: Optional[str] = None
    user_email: Optional[str] = None
    category: str
    rating: Optional[int]
    title: Optional[str]
    message: str
    module: Optional[str]
    status: str
    priority: str
    admin_notes: Optional[str]
    resolved_by: Optional[str]
    resolved_at: Optional[datetime]
    app_version: Optional[str]
    platform: Optional[str]
    is_anonymous: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class FeedbackListResponse(BaseModel):
    feedback: list[FeedbackItem]
    total: int
    page: int
    page_size: int
    total_pages: int


class FeedbackStatsResponse(BaseModel):
    total: int
    pending: int
    reviewed: int
    in_progress: int
    resolved: int
    dismissed: int
    avg_rating: float
    today_count: int
    this_week_count: int
    by_category: dict[str, int]
    by_priority: dict[str, int]


class AdminUpdateFeedbackRequest(BaseModel):
    status: Optional[str] = Field(
        None,
        pattern="^(pending|reviewed|in_progress|resolved|dismissed)$"
    )
    priority: Optional[str] = Field(
        None,
        pattern="^(low|normal|high|critical)$"
    )
    admin_notes: Optional[str] = None
