"""
SQLAlchemy ORM models for the Health Education module.

Tables:
  - health_categories
  - health_articles
  - disease_education
  - nutrition_education
  - vaccination_education
  - user_bookmarks
  - reading_history
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
    UniqueConstraint,
)

from app.auth.models import Base


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _uuid4() -> str:
    return str(uuid.uuid4())


# ─── HealthCategory ───────────────────────────────────────────────────────────

class HealthCategory(Base):
    """
    Top-level education category (Diseases, Nutrition, Vaccination, etc.).
    Categories are seeded once and rarely changed.
    """
    __tablename__ = "health_categories"
    __allow_unmapped__ = True

    id          = Column(String(36),  primary_key=True, default=_uuid4)
    name        = Column(String(100), nullable=False, unique=True)
    slug        = Column(String(100), nullable=False, unique=True, index=True)
    icon        = Column(String(10),  nullable=True)   # emoji
    description = Column(Text,        nullable=True)
    color_hex   = Column(String(9),   nullable=True)   # e.g. #926EFF
    sort_order  = Column(Integer,     nullable=False, default=0)
    is_active   = Column(Boolean,     nullable=False, default=True)
    created_at  = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<HealthCategory {self.name}>"


# ─── HealthArticle ────────────────────────────────────────────────────────────

class HealthArticle(Base):
    """
    Core educational article.  Covers all content types (disease info,
    nutrition, hygiene, lifestyle, etc.) via category FK.
    """
    __tablename__ = "health_articles"
    __allow_unmapped__ = True

    id            = Column(String(36),  primary_key=True, default=_uuid4)
    category_id   = Column(String(36),  ForeignKey("health_categories.id", ondelete="SET NULL"),
                           nullable=True, index=True)

    # ── Content ───────────────────────────────────────────────────────────────
    title         = Column(String(300), nullable=False)
    slug          = Column(String(320), nullable=False, unique=True, index=True)
    summary       = Column(String(600), nullable=True)
    content       = Column(Text,        nullable=False)
    # content is stored as rich markdown / structured JSON text.

    # ── Meta ──────────────────────────────────────────────────────────────────
    language      = Column(String(10),  nullable=False, default="en")
    # supported: en | ne | hi | bh  (English / Nepali / Hindi / Bhojpuri)
    author        = Column(String(255), nullable=True)
    source        = Column(String(255), nullable=True)   # WHO / CDC / etc.
    read_time_min = Column(Integer,     nullable=False, default=3)
    cover_image   = Column(String(500), nullable=True)   # relative path or URL
    emoji         = Column(String(10),  nullable=True)   # display emoji
    tags          = Column(JSON,        nullable=False, default=list)
    # ["diabetes", "nutrition", "rural"] for search

    # ── Visibility ────────────────────────────────────────────────────────────
    is_featured   = Column(Boolean,     nullable=False, default=False)
    is_published  = Column(Boolean,     nullable=False, default=True)

    # ── Engagement ────────────────────────────────────────────────────────────
    view_count    = Column(Integer,     nullable=False, default=0)
    bookmark_count= Column(Integer,     nullable=False, default=0)

    published_at  = Column(DateTime(timezone=True), nullable=True, default=_utcnow)
    created_at    = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at    = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<HealthArticle '{self.title[:40]}' lang={self.language}>"


# ─── DiseaseEducation ─────────────────────────────────────────────────────────

class DiseaseEducation(Base):
    """
    Detailed structured disease education record.
    Linked optionally to a HealthArticle for the narrative content;
    also carries its own structured sections for disease-specific UI.
    """
    __tablename__ = "disease_education"
    __allow_unmapped__ = True

    id             = Column(String(36),  primary_key=True, default=_uuid4)
    article_id     = Column(String(36),  ForeignKey("health_articles.id", ondelete="SET NULL"),
                            nullable=True, index=True)

    disease_name   = Column(String(255), nullable=False, index=True)
    language       = Column(String(10),  nullable=False, default="en")
    overview       = Column(Text,        nullable=True)
    causes         = Column(JSON,        nullable=False, default=list)   # list[str]
    symptoms       = Column(JSON,        nullable=False, default=list)   # list[str]
    risk_factors   = Column(JSON,        nullable=False, default=list)
    complications  = Column(JSON,        nullable=False, default=list)
    prevention     = Column(JSON,        nullable=False, default=list)
    home_care      = Column(JSON,        nullable=False, default=list)
    emergency_signs= Column(JSON,        nullable=False, default=list)
    when_to_visit  = Column(Text,        nullable=True)
    treatments     = Column(Text,        nullable=True)

    created_at     = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at     = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<DiseaseEducation {self.disease_name}>"


# ─── NutritionEducation ───────────────────────────────────────────────────────

class NutritionEducation(Base):
    """Structured nutrition education entries."""
    __tablename__ = "nutrition_education"
    __allow_unmapped__ = True

    id                   = Column(String(36),  primary_key=True, default=_uuid4)
    article_id           = Column(String(36),  ForeignKey("health_articles.id", ondelete="SET NULL"),
                                  nullable=True, index=True)

    title                = Column(String(255), nullable=False)
    language             = Column(String(10),  nullable=False, default="en")
    target_group         = Column(String(100), nullable=True)
    # e.g. "Pregnant Women", "Children 0-5", "Diabetics"

    description          = Column(Text,        nullable=True)
    recommended_foods    = Column(JSON,        nullable=False, default=list)
    foods_to_avoid       = Column(JSON,        nullable=False, default=list)
    meal_plan            = Column(JSON,        nullable=False, default=list)
    # [{"meal":"Breakfast","items":["Oats","Banana"]}]

    nutritional_benefits = Column(Text,        nullable=True)
    lifestyle_tips       = Column(JSON,        nullable=False, default=list)

    created_at           = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<NutritionEducation {self.title}>"


# ─── VaccinationEducation ─────────────────────────────────────────────────────

class VaccinationEducation(Base):
    """Vaccination schedule and information."""
    __tablename__ = "vaccination_education"
    __allow_unmapped__ = True

    id              = Column(String(36),  primary_key=True, default=_uuid4)
    article_id      = Column(String(36),  ForeignKey("health_articles.id", ondelete="SET NULL"),
                             nullable=True, index=True)

    vaccine_name    = Column(String(255), nullable=False)
    language        = Column(String(10),  nullable=False, default="en")
    purpose         = Column(Text,        nullable=True)
    recommended_age = Column(String(100), nullable=True)   # "0-6 months", "Adults"
    schedule        = Column(JSON,        nullable=False, default=list)
    # [{"dose":"1st","timing":"At birth"},{"dose":"2nd","timing":"6 weeks"}]

    side_effects    = Column(JSON,        nullable=False, default=list)
    contraindications = Column(JSON,      nullable=False, default=list)
    important_notes = Column(Text,        nullable=True)
    target_group    = Column(String(100), nullable=True)
    # "Children", "Maternal", "Adults", "Elderly"

    created_at      = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<VaccinationEducation {self.vaccine_name}>"


# ─── UserBookmark ─────────────────────────────────────────────────────────────

class UserBookmark(Base):
    """User saved (bookmarked) articles."""
    __tablename__ = "user_bookmarks"
    __allow_unmapped__ = True
    __table_args__ = (
        UniqueConstraint("user_id", "article_id", name="uq_user_article_bookmark"),
    )

    id         = Column(String(36), primary_key=True, default=_uuid4)
    user_id    = Column(String(36), ForeignKey("users.id",         ondelete="CASCADE"), nullable=False, index=True)
    article_id = Column(String(36), ForeignKey("health_articles.id", ondelete="CASCADE"), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<UserBookmark user={self.user_id} article={self.article_id}>"


# ─── ReadingHistory ───────────────────────────────────────────────────────────

class ReadingHistory(Base):
    """Track per-user article reading progress."""
    __tablename__ = "reading_history"
    __allow_unmapped__ = True
    __table_args__ = (
        UniqueConstraint("user_id", "article_id", name="uq_user_article_reading"),
    )

    id                 = Column(String(36), primary_key=True, default=_uuid4)
    user_id            = Column(String(36), ForeignKey("users.id",           ondelete="CASCADE"), nullable=False, index=True)
    article_id         = Column(String(36), ForeignKey("health_articles.id", ondelete="CASCADE"), nullable=False, index=True)
    last_read_position = Column(Integer,    nullable=False, default=0)
    # scroll position in pixels or character offset
    is_completed       = Column(Boolean,    nullable=False, default=False)
    read_count         = Column(Integer,    nullable=False, default=1)
    created_at         = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at         = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<ReadingHistory user={self.user_id} article={self.article_id}>"
