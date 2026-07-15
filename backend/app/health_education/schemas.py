"""
Pydantic request/response schemas for the Health Education module.
"""

from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


# ─── HealthCategory ───────────────────────────────────────────────────────────

class HealthCategoryResponse(BaseModel):
    id:          str
    name:        str
    slug:        str
    icon:        Optional[str]
    description: Optional[str]
    color_hex:   Optional[str]
    sort_order:  int
    is_active:   bool

    model_config = {"from_attributes": True}


# ─── HealthArticle ────────────────────────────────────────────────────────────

class HealthArticleSummary(BaseModel):
    """Lightweight card used in list views."""
    id:            str
    category_id:   Optional[str]
    category_name: Optional[str]    # joined
    category_slug: Optional[str]
    category_color: Optional[str]
    title:         str
    slug:          str
    summary:       Optional[str]
    language:      str
    author:        Optional[str]
    read_time_min: int
    cover_image:   Optional[str]
    emoji:         Optional[str]
    tags:          List[str]
    is_featured:   bool
    view_count:    int
    bookmark_count: int
    published_at:  Optional[datetime]
    is_bookmarked: bool = False     # resolved per-user at query time

    model_config = {"from_attributes": True}


class HealthArticleDetail(BaseModel):
    """Full article payload returned by the detail endpoint."""
    id:            str
    category_id:   Optional[str]
    category_name: Optional[str]
    category_slug: Optional[str]
    category_color: Optional[str]
    title:         str
    slug:          str
    summary:       Optional[str]
    content:       str
    language:      str
    author:        Optional[str]
    source:        Optional[str]
    read_time_min: int
    cover_image:   Optional[str]
    emoji:         Optional[str]
    tags:          List[str]
    is_featured:   bool
    view_count:    int
    bookmark_count: int
    published_at:  Optional[datetime]
    created_at:    datetime
    updated_at:    datetime
    is_bookmarked: bool = False

    # Related structured data (optional enrichment)
    disease_info:    Optional["DiseaseEducationResponse"]    = None
    nutrition_info:  Optional["NutritionEducationResponse"]  = None
    vaccination_info: Optional["VaccinationEducationResponse"] = None

    model_config = {"from_attributes": True}


# ─── DiseaseEducation ─────────────────────────────────────────────────────────

class DiseaseEducationResponse(BaseModel):
    id:              str
    article_id:      Optional[str]
    disease_name:    str
    language:        str
    overview:        Optional[str]
    causes:          List[str]
    symptoms:        List[str]
    risk_factors:    List[str]
    complications:   List[str]
    prevention:      List[str]
    home_care:       List[str]
    emergency_signs: List[str]
    when_to_visit:   Optional[str]
    treatments:      Optional[str]
    created_at:      datetime

    model_config = {"from_attributes": True}


# ─── NutritionEducation ───────────────────────────────────────────────────────

class NutritionEducationResponse(BaseModel):
    id:                   str
    article_id:           Optional[str]
    title:                str
    language:             str
    target_group:         Optional[str]
    description:          Optional[str]
    recommended_foods:    List[str]
    foods_to_avoid:       List[str]
    meal_plan:            List[Dict[str, Any]]
    nutritional_benefits: Optional[str]
    lifestyle_tips:       List[str]
    created_at:           datetime

    model_config = {"from_attributes": True}


# ─── VaccinationEducation ─────────────────────────────────────────────────────

class VaccinationEducationResponse(BaseModel):
    id:                 str
    article_id:         Optional[str]
    vaccine_name:       str
    language:           str
    purpose:            Optional[str]
    recommended_age:    Optional[str]
    schedule:           List[Dict[str, Any]]
    side_effects:       List[str]
    contraindications:  List[str]
    important_notes:    Optional[str]
    target_group:       Optional[str]
    created_at:         datetime

    model_config = {"from_attributes": True}


# ─── Bookmarks ────────────────────────────────────────────────────────────────

class BookmarkCreate(BaseModel):
    article_id: str = Field(min_length=1)


class BookmarkResponse(BaseModel):
    id:         str
    user_id:    str
    article_id: str
    created_at: datetime

    model_config = {"from_attributes": True}


# ─── Reading History ──────────────────────────────────────────────────────────

class ReadingProgressUpdate(BaseModel):
    last_read_position: int  = Field(ge=0, default=0)
    is_completed:       bool = False


class ReadingHistoryResponse(BaseModel):
    id:                 str
    user_id:            str
    article_id:         str
    last_read_position: int
    is_completed:       bool
    read_count:         int
    updated_at:         datetime

    model_config = {"from_attributes": True}


# ─── Dashboard / Feed ─────────────────────────────────────────────────────────

class EducationDashboard(BaseModel):
    featured_articles:      List[HealthArticleSummary]
    categories:             List[HealthCategoryResponse]
    recommended_articles:   List[HealthArticleSummary]
    recent_articles:        List[HealthArticleSummary]
    bookmarks:              List[HealthArticleSummary]


# ─── Paginated list ───────────────────────────────────────────────────────────

class ArticleListResponse(BaseModel):
    total:    int
    page:     int
    per_page: int
    articles: List[HealthArticleSummary]


# ─── Search ───────────────────────────────────────────────────────────────────

class SearchResponse(BaseModel):
    query:    str
    total:    int
    articles: List[HealthArticleSummary]
