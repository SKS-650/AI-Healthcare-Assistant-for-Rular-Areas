"""
Health Education API routes.

All routes mounted under /api/v1/education

Endpoints:
  GET  /dashboard                   — Full dashboard feed
  GET  /categories                  — List all categories
  GET  /articles                    — Paginated article list
  GET  /articles/{id}               — Article detail + view count bump
  GET  /featured                    — Featured articles
  GET  /search                      — Full-text search
  GET  /recommendations             — Personalised recommendations
  GET  /bookmarks                   — User's saved articles
  POST /bookmarks                   — Save an article
  DELETE /bookmarks/{id}            — Remove bookmark
  POST /reading-progress/{id}       — Update reading progress
  GET  /health                      — Module health check
"""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import CurrentUser
from app.database.connection import get_async_session as get_db
from app.health_education.schemas import (
    ArticleListResponse,
    BookmarkCreate,
    BookmarkResponse,
    EducationDashboard,
    HealthArticleDetail,
    HealthArticleSummary,
    HealthCategoryResponse,
    ReadingHistoryResponse,
    ReadingProgressUpdate,
    SearchResponse,
)
from app.health_education.services import (
    ArticleService,
    BookmarkService,
    CategoryService,
    DashboardService,
    ReadingHistoryService,
    SeedService,
)

router = APIRouter(prefix="/education", tags=["Health Education"])


# ─── Dashboard ────────────────────────────────────────────────────────────────

@router.get(
    "/dashboard",
    response_model=EducationDashboard,
    summary="Education dashboard feed",
    description="Returns featured articles, categories, recommendations, recent reading, and bookmarks.",
)
async def get_dashboard(
    current_user: CurrentUser,
    language: str = Query(default="en", description="Content language: en | ne | hi | bh"),
    db: AsyncSession = Depends(get_db),
) -> EducationDashboard:
    await SeedService.seed(db)
    return await DashboardService.get_dashboard(db, current_user.id, language=language)


# ─── Categories ───────────────────────────────────────────────────────────────

@router.get(
    "/categories",
    response_model=list[HealthCategoryResponse],
    summary="List health education categories",
)
async def list_categories(
    db: AsyncSession = Depends(get_db),
) -> list[HealthCategoryResponse]:
    await SeedService.seed(db)
    return await CategoryService.list_categories(db)


# ─── Articles ─────────────────────────────────────────────────────────────────

@router.get(
    "/articles",
    response_model=ArticleListResponse,
    summary="List health articles (paginated)",
)
async def list_articles(
    current_user: CurrentUser,
    category: Optional[str] = Query(default=None, description="Filter by category slug"),
    language: str           = Query(default="en"),
    page:     int           = Query(default=1, ge=1),
    per_page: int           = Query(default=20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
) -> ArticleListResponse:
    await SeedService.seed(db)
    return await ArticleService.list_articles(
        db, current_user.id, category_slug=category, language=language,
        page=page, per_page=per_page,
    )


@router.get(
    "/articles/{article_id}",
    response_model=HealthArticleDetail,
    summary="Get article detail",
)
async def get_article(
    article_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> HealthArticleDetail:
    detail = await ArticleService.get_article_detail(db, article_id, current_user.id)
    if not detail:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found")
    return detail


# ─── Featured ─────────────────────────────────────────────────────────────────

@router.get(
    "/featured",
    response_model=list[HealthArticleSummary],
    summary="Get featured articles",
)
async def get_featured(
    current_user: CurrentUser,
    language: str = Query(default="en"),
    limit:    int = Query(default=5, ge=1, le=20),
    db: AsyncSession = Depends(get_db),
) -> list[HealthArticleSummary]:
    await SeedService.seed(db)
    return await ArticleService.get_featured(db, current_user.id, language=language, limit=limit)


# ─── Search ───────────────────────────────────────────────────────────────────

@router.get(
    "/search",
    response_model=SearchResponse,
    summary="Search health articles",
)
async def search_articles(
    current_user: CurrentUser,
    q:        str = Query(min_length=1, description="Search query"),
    language: str = Query(default="en"),
    limit:    int = Query(default=20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
) -> SearchResponse:
    return await ArticleService.search(db, q, current_user.id, language=language, limit=limit)


# ─── Recommendations ──────────────────────────────────────────────────────────

@router.get(
    "/recommendations",
    response_model=list[HealthArticleSummary],
    summary="Personalised article recommendations",
)
async def get_recommendations(
    current_user: CurrentUser,
    language: str = Query(default="en"),
    limit:    int = Query(default=8, ge=1, le=20),
    db: AsyncSession = Depends(get_db),
) -> list[HealthArticleSummary]:
    return await ArticleService.get_recommendations(db, current_user.id, language=language, limit=limit)


# ─── Bookmarks ────────────────────────────────────────────────────────────────

@router.get(
    "/bookmarks",
    response_model=list[HealthArticleSummary],
    summary="List user bookmarks",
)
async def list_bookmarks(
    current_user: CurrentUser,
    language: str = Query(default="en"),
    db: AsyncSession = Depends(get_db),
) -> list[HealthArticleSummary]:
    return await BookmarkService.list_bookmarks(db, current_user.id, language=language)


@router.post(
    "/bookmarks",
    response_model=BookmarkResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Bookmark an article",
)
async def add_bookmark(
    payload: BookmarkCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> BookmarkResponse:
    return await BookmarkService.add_bookmark(db, current_user.id, payload.article_id)


@router.delete(
    "/bookmarks/{bookmark_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Remove bookmark",
)
async def remove_bookmark(
    bookmark_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    removed = await BookmarkService.remove_bookmark(db, current_user.id, bookmark_id)
    if not removed:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bookmark not found")


# ─── Reading Progress ─────────────────────────────────────────────────────────

@router.post(
    "/reading-progress/{article_id}",
    response_model=ReadingHistoryResponse,
    summary="Update reading progress for an article",
)
async def update_reading_progress(
    article_id: str,
    payload: ReadingProgressUpdate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> ReadingHistoryResponse:
    return await ReadingHistoryService.update_progress(
        db, current_user.id, article_id,
        position=payload.last_read_position,
        is_completed=payload.is_completed,
    )


# ─── Health check ─────────────────────────────────────────────────────────────

@router.get("/health", summary="Health Education module health check", tags=["Health"])
async def health() -> dict:
    return {"status": "ok", "module": "health_education"}
