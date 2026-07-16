"""Pydantic schemas for the Admin module."""

from __future__ import annotations

from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel, Field


# ─── Dashboard Analytics ─────────────────────────────────────────────────────

class DashboardStats(BaseModel):
    total_users: int
    active_users: int
    new_users_today: int
    new_users_this_week: int
    total_chatbot_conversations: int
    chatbot_conversations_today: int
    total_emergency_assessments: int
    emergency_assessments_today: int
    high_risk_emergencies: int
    total_health_articles: int
    published_articles: int
    total_symptom_checks: int
    symptom_checks_today: int
    total_sos_events: int


class RecentUser(BaseModel):
    id: str
    full_name: str
    email: str
    role: str
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class RecentEmergency(BaseModel):
    id: str
    user_id: Optional[str]
    user_name: Optional[str]
    risk_level: str
    risk_score: int
    possible_emergency: Optional[str]
    is_emergency: bool
    created_at: datetime

    class Config:
        from_attributes = True


class SystemHealth(BaseModel):
    database: str
    api: str
    chatbot: str
    emergency_system: str
    overall: str


class DashboardResponse(BaseModel):
    stats: DashboardStats
    recent_users: list[RecentUser]
    recent_emergencies: list[RecentEmergency]
    system_health: SystemHealth
    user_growth: list[dict[str, Any]]
    emergency_trend: list[dict[str, Any]]
    chatbot_trend: list[dict[str, Any]]


# ─── User Management ─────────────────────────────────────────────────────────

class AdminUserItem(BaseModel):
    id: str
    full_name: str
    email: str
    phone: Optional[str]
    role: str
    is_active: bool
    email_verified: bool
    phone_verified: bool
    language: str
    created_at: datetime
    last_login: Optional[datetime]

    class Config:
        from_attributes = True


class AdminUserDetail(AdminUserItem):
    total_conversations: int = 0
    total_symptom_checks: int = 0
    total_emergency_assessments: int = 0
    total_education_bookmarks: int = 0


class AdminUserListResponse(BaseModel):
    users: list[AdminUserItem]
    total: int
    page: int
    page_size: int
    total_pages: int


class UpdateUserStatusRequest(BaseModel):
    is_active: bool


class UpdateUserRoleRequest(BaseModel):
    role: str = Field(..., pattern="^(patient|doctor|admin|super_admin)$")


# ─── Emergency Monitoring ────────────────────────────────────────────────────

class AdminEmergencyItem(BaseModel):
    id: str
    user_id: Optional[str]
    user_name: Optional[str]
    user_email: Optional[str]
    age: Optional[int]
    gender: Optional[str]
    symptoms: list[str]
    risk_level: str
    risk_score: int
    is_emergency: bool
    emergency_type: Optional[str]
    possible_emergency: Optional[str]
    sos_required: bool
    sos_count: int = 0
    created_at: datetime

    class Config:
        from_attributes = True


class AdminEmergencyListResponse(BaseModel):
    emergencies: list[AdminEmergencyItem]
    total: int
    page: int
    page_size: int
    total_pages: int


class EmergencyStatsResponse(BaseModel):
    total: int
    critical: int
    high: int
    medium: int
    low: int
    sos_triggered: int
    today_count: int
    this_week: int


# ─── Chatbot Monitoring ───────────────────────────────────────────────────────

class AdminConversationItem(BaseModel):
    id: int
    user_id: str
    user_name: Optional[str]
    title: str
    language: str
    message_count: int
    emergency_count: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class AdminConversationListResponse(BaseModel):
    conversations: list[AdminConversationItem]
    total: int
    page: int
    page_size: int
    total_pages: int


class ChatbotStatsResponse(BaseModel):
    total_conversations: int
    active_conversations: int
    total_messages: int
    emergency_messages: int
    avg_messages_per_conversation: float
    today_conversations: int
    language_distribution: dict[str, int]


# ─── Health Education ─────────────────────────────────────────────────────────

class AdminArticleCreate(BaseModel):
    title: str
    summary: Optional[str] = None
    content: str
    category_id: Optional[str] = None
    language: str = "en"
    author: Optional[str] = None
    source: Optional[str] = None
    read_time_min: int = 3
    tags: list[str] = []
    is_featured: bool = False
    is_published: bool = True
    emoji: Optional[str] = None


class AdminArticleUpdate(BaseModel):
    title: Optional[str] = None
    summary: Optional[str] = None
    content: Optional[str] = None
    category_id: Optional[str] = None
    language: Optional[str] = None
    author: Optional[str] = None
    source: Optional[str] = None
    read_time_min: Optional[int] = None
    tags: Optional[list[str]] = None
    is_featured: Optional[bool] = None
    is_published: Optional[bool] = None
    emoji: Optional[str] = None


class AdminArticleResponse(BaseModel):
    id: str
    title: str
    summary: Optional[str]
    content: str
    category_id: Optional[str]
    category_name: Optional[str]
    language: str
    author: Optional[str]
    source: Optional[str]
    read_time_min: int
    tags: list[str]
    is_featured: bool
    is_published: bool
    view_count: int
    bookmark_count: int
    emoji: Optional[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class AdminArticleListResponse(BaseModel):
    articles: list[AdminArticleResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ─── Activity Logs ────────────────────────────────────────────────────────────

class ActivityLogItem(BaseModel):
    id: str
    admin_id: Optional[str]
    admin_name: Optional[str]
    action: str
    module: str
    target_id: Optional[str]
    target_type: Optional[str]
    description: Optional[str]
    ip_address: Optional[str]
    severity: str
    created_at: datetime

    class Config:
        from_attributes = True


class ActivityLogListResponse(BaseModel):
    logs: list[ActivityLogItem]
    total: int
    page: int
    page_size: int
    total_pages: int


# ─── System Settings ─────────────────────────────────────────────────────────

class SystemSettingItem(BaseModel):
    id: str
    key: str
    value: Optional[str]
    value_type: str
    category: str
    description: Optional[str]
    is_public: bool
    updated_at: datetime

    class Config:
        from_attributes = True


class SystemSettingUpdate(BaseModel):
    value: Optional[str] = None
    description: Optional[str] = None


class SystemSettingsResponse(BaseModel):
    settings: list[SystemSettingItem]
    categories: list[str]


# ─── Reports ─────────────────────────────────────────────────────────────────

class UserRegistrationTrend(BaseModel):
    date: str
    count: int


class SymptomFrequency(BaseModel):
    symptom: str
    count: int


class RiskDistribution(BaseModel):
    risk_level: str
    count: int
    percentage: float


class ReportsResponse(BaseModel):
    user_registration_trend: list[UserRegistrationTrend]
    symptom_frequency: list[SymptomFrequency]
    risk_distribution: list[RiskDistribution]
    chatbot_daily_usage: list[dict[str, Any]]
    emergency_weekly: list[dict[str, Any]]
    education_engagement: list[dict[str, Any]]


# ─── Dataset Management ───────────────────────────────────────────────────────

class DatasetVersionItem(BaseModel):
    id: str
    name: str
    dataset_type: str
    version: str
    file_size_kb: Optional[int]
    record_count: Optional[int]
    description: Optional[str]
    is_active: bool
    uploaded_by: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class DatasetVersionCreate(BaseModel):
    name: str
    dataset_type: str
    version: str = "1.0.0"
    description: Optional[str] = None


# ─── Notifications ────────────────────────────────────────────────────────────

class NotificationItem(BaseModel):
    id: str
    title: str
    message: str
    ntype: str
    module: Optional[str]
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True


class NotificationListResponse(BaseModel):
    notifications: list[NotificationItem]
    unread_count: int
