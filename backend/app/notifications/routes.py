"""
Notifications API routes.

All routes mounted under /api/v1/notifications

Endpoints:
  GET    /                      — List notifications (paginated)
  GET    /unread-count          — Number of unread notifications
  POST   /mark-read             — Mark specific notifications as read
  POST   /mark-all-read         — Mark all notifications as read
  DELETE /{notification_id}     — Delete a single notification
  DELETE /read                  — Delete all read notifications
  GET    /health                — Module health check
"""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import CurrentUser
from app.database.connection import get_async_session as get_db
from app.notifications import schemas
from app.notifications.service import NotificationService

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get(
    "/",
    response_model=schemas.NotificationListResponse,
    summary="List my notifications",
)
async def list_notifications(
    current_user: CurrentUser,
    page:         int  = Query(1, ge=1),
    page_size:    int  = Query(20, ge=1, le=100),
    unread_only:  bool = Query(False),
    db: AsyncSession = Depends(get_db),
) -> schemas.NotificationListResponse:
    return await NotificationService.list_for_user(
        db, current_user.id, page=page, page_size=page_size, unread_only=unread_only
    )


@router.get(
    "/unread-count",
    summary="Get unread notification count",
)
async def unread_count(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> dict[str, int]:
    count = await NotificationService.unread_count(db, current_user.id)
    return {"unread_count": count}


@router.post(
    "/mark-read",
    summary="Mark specific notifications as read",
)
async def mark_read(
    payload: schemas.MarkReadRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> dict[str, int]:
    updated = await NotificationService.mark_read(
        db, current_user.id, payload.notification_ids
    )
    return {"updated": updated}


@router.post(
    "/mark-all-read",
    summary="Mark all notifications as read",
)
async def mark_all_read(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> dict[str, int]:
    updated = await NotificationService.mark_all_read(db, current_user.id)
    return {"updated": updated}


@router.delete(
    "/read",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete all read notifications",
)
async def delete_read_notifications(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    await NotificationService.delete_all_read(db, current_user.id)


@router.delete(
    "/{notification_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete a notification",
)
async def delete_notification(
    notification_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    ok = await NotificationService.delete(db, current_user.id, notification_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Notification not found")


@router.get("/health", tags=["Health"])
async def health() -> dict[str, str]:
    return {"status": "ok", "module": "notifications"}
