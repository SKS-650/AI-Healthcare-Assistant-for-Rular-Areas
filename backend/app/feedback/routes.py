"""Feedback API routes.

Public (authenticated users):
  POST /feedback          — submit feedback

Admin-only:
  GET  /admin/feedback              — list all feedback
  GET  /admin/feedback/stats        — stats overview
  GET  /admin/feedback/{id}         — get single feedback
  PATCH /admin/feedback/{id}        — update status / priority / notes
  DELETE /admin/feedback/{id}       — delete feedback
"""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import CurrentUser, AdminUser, require_role
from app.auth.constants import Role
from app.database.connection import get_async_session as get_db
from app.feedback import schemas
from app.feedback.service import FeedbackService
from app.admin.service import ActivityLogService

router = APIRouter(tags=["Feedback"])

# ── Public: submit ────────────────────────────────────────────────────────────

@router.post(
    "/feedback",
    response_model=schemas.FeedbackItem,
    status_code=status.HTTP_201_CREATED,
    summary="Submit user feedback",
)
async def submit_feedback(
    payload: schemas.FeedbackCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> schemas.FeedbackItem:
    fb = await FeedbackService.create(db, payload, user_id=current_user.id)
    return await FeedbackService.get_feedback(db, fb.id)


# ── Admin: list ───────────────────────────────────────────────────────────────

@router.get(
    "/admin/feedback",
    response_model=schemas.FeedbackListResponse,
    summary="List all feedback (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_feedback(
    search:    Optional[str] = Query(None),
    category:  Optional[str] = Query(None),
    status_f:  Optional[str] = Query(None, alias="status"),
    priority:  Optional[str] = Query(None),
    rating:    Optional[int] = Query(None, ge=1, le=5),
    page:      int           = Query(1, ge=1),
    page_size: int           = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
) -> schemas.FeedbackListResponse:
    return await FeedbackService.list_feedback(
        db, search, category, status_f, priority, rating, page, page_size
    )


# ── Admin: stats ──────────────────────────────────────────────────────────────

@router.get(
    "/admin/feedback/stats",
    response_model=schemas.FeedbackStatsResponse,
    summary="Feedback statistics (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def feedback_stats(db: AsyncSession = Depends(get_db)) -> schemas.FeedbackStatsResponse:
    return await FeedbackService.get_stats(db)


# ── Admin: get single ─────────────────────────────────────────────────────────

@router.get(
    "/admin/feedback/{feedback_id}",
    response_model=schemas.FeedbackItem,
    summary="Get single feedback item (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def get_feedback(
    feedback_id: str,
    db: AsyncSession = Depends(get_db),
) -> schemas.FeedbackItem:
    fb = await FeedbackService.get_feedback(db, feedback_id)
    if not fb:
        raise HTTPException(status_code=404, detail="Feedback not found")
    return fb


# ── Admin: update ─────────────────────────────────────────────────────────────

@router.patch(
    "/admin/feedback/{feedback_id}",
    response_model=schemas.FeedbackItem,
    summary="Update feedback status / priority / notes (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def update_feedback(
    feedback_id: str,
    payload: schemas.AdminUpdateFeedbackRequest,
    current_user: AdminUser,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> schemas.FeedbackItem:
    fb = await FeedbackService.update_feedback(db, feedback_id, payload, current_user.id)
    if not fb:
        raise HTTPException(status_code=404, detail="Feedback not found")
    await ActivityLogService.log(
        db,
        current_user.id,
        "feedback.update",
        "feedback",
        feedback_id,
        "UserFeedback",
        description=f"Status → {payload.status or 'unchanged'}",
        ip_address=request.client.host if request.client else None,
    )
    return fb


# ── Admin: delete ─────────────────────────────────────────────────────────────

@router.delete(
    "/admin/feedback/{feedback_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete feedback (admin)",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def delete_feedback(
    feedback_id: str,
    current_user: AdminUser,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> None:
    deleted = await FeedbackService.delete_feedback(db, feedback_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Feedback not found")
    await ActivityLogService.log(
        db,
        current_user.id,
        "feedback.delete",
        "feedback",
        feedback_id,
        "UserFeedback",
        severity="warning",
        ip_address=request.client.host if request.client else None,
    )
