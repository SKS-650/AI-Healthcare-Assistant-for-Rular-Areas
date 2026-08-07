"""Business logic for the Feedback module."""

from __future__ import annotations

import math
from datetime import datetime, timedelta, timezone
from typing import Optional

from sqlalchemy import func, select, desc, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.models import UserModel
from app.feedback.models import UserFeedback
from app.feedback import schemas


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


class FeedbackService:

    # ── Public: submit feedback ───────────────────────────────────────────────

    @staticmethod
    async def create(
        db: AsyncSession,
        payload: schemas.FeedbackCreate,
        user_id: Optional[str] = None,
    ) -> UserFeedback:
        fb = UserFeedback(
            user_id=user_id,
            category=payload.category,
            rating=payload.rating,
            title=payload.title,
            message=payload.message,
            module=payload.module,
            app_version=payload.app_version,
            platform=payload.platform,
            is_anonymous=payload.is_anonymous,
        )
        db.add(fb)
        await db.commit()
        await db.refresh(fb)
        return fb

    # ── Admin: list ───────────────────────────────────────────────────────────

    @staticmethod
    async def list_feedback(
        db: AsyncSession,
        search: Optional[str] = None,
        category: Optional[str] = None,
        status: Optional[str] = None,
        priority: Optional[str] = None,
        rating: Optional[int] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> schemas.FeedbackListResponse:
        q = select(UserFeedback)

        if search:
            term = f"%{search}%"
            q = q.where(
                or_(
                    UserFeedback.title.ilike(term),
                    UserFeedback.message.ilike(term),
                )
            )
        if category:
            q = q.where(UserFeedback.category == category)
        if status:
            q = q.where(UserFeedback.status == status)
        if priority:
            q = q.where(UserFeedback.priority == priority)
        if rating is not None:
            q = q.where(UserFeedback.rating == rating)

        total = (
            await db.execute(select(func.count()).select_from(q.subquery()))
        ).scalar_one()

        offset = (page - 1) * page_size
        result = await db.execute(
            q.order_by(desc(UserFeedback.created_at))
            .offset(offset)
            .limit(page_size)
        )
        rows = result.scalars().all()

        items: list[schemas.FeedbackItem] = []
        for fb in rows:
            user_name = user_email = None
            if fb.user_id and not fb.is_anonymous:
                u = await db.get(UserModel, fb.user_id)
                if u:
                    user_name = u.full_name
                    user_email = u.email
            items.append(
                schemas.FeedbackItem(
                    id=fb.id,
                    user_id=fb.user_id if not fb.is_anonymous else None,
                    user_name=user_name,
                    user_email=user_email,
                    category=fb.category,
                    rating=fb.rating,
                    title=fb.title,
                    message=fb.message,
                    module=fb.module,
                    status=fb.status,
                    priority=fb.priority,
                    admin_notes=fb.admin_notes,
                    resolved_by=fb.resolved_by,
                    resolved_at=fb.resolved_at,
                    app_version=fb.app_version,
                    platform=fb.platform,
                    is_anonymous=fb.is_anonymous,
                    created_at=fb.created_at,
                    updated_at=fb.updated_at,
                )
            )

        return schemas.FeedbackListResponse(
            feedback=items,
            total=total,
            page=page,
            page_size=page_size,
            total_pages=math.ceil(total / page_size) if total else 1,
        )

    # ── Admin: stats ──────────────────────────────────────────────────────────

    @staticmethod
    async def get_stats(db: AsyncSession) -> schemas.FeedbackStatsResponse:
        now = _utcnow()
        today = now.replace(hour=0, minute=0, second=0, microsecond=0)
        week = today - timedelta(days=7)

        total = (
            await db.execute(select(func.count(UserFeedback.id)))
        ).scalar_one()

        pending = (
            await db.execute(
                select(func.count(UserFeedback.id)).where(
                    UserFeedback.status == "pending"
                )
            )
        ).scalar_one()

        reviewed = (
            await db.execute(
                select(func.count(UserFeedback.id)).where(
                    UserFeedback.status == "reviewed"
                )
            )
        ).scalar_one()

        in_progress = (
            await db.execute(
                select(func.count(UserFeedback.id)).where(
                    UserFeedback.status == "in_progress"
                )
            )
        ).scalar_one()

        resolved = (
            await db.execute(
                select(func.count(UserFeedback.id)).where(
                    UserFeedback.status == "resolved"
                )
            )
        ).scalar_one()

        dismissed = (
            await db.execute(
                select(func.count(UserFeedback.id)).where(
                    UserFeedback.status == "dismissed"
                )
            )
        ).scalar_one()

        avg_rating_row = (
            await db.execute(
                select(func.avg(UserFeedback.rating)).where(
                    UserFeedback.rating.isnot(None)
                )
            )
        ).scalar_one()
        avg_rating = round(float(avg_rating_row or 0), 2)

        today_count = (
            await db.execute(
                select(func.count(UserFeedback.id)).where(
                    UserFeedback.created_at >= today
                )
            )
        ).scalar_one()

        week_count = (
            await db.execute(
                select(func.count(UserFeedback.id)).where(
                    UserFeedback.created_at >= week
                )
            )
        ).scalar_one()

        # by category
        cat_rows = await db.execute(
            select(UserFeedback.category, func.count(UserFeedback.id)).group_by(
                UserFeedback.category
            )
        )
        by_category = {r[0]: r[1] for r in cat_rows.all()}

        # by priority
        pri_rows = await db.execute(
            select(UserFeedback.priority, func.count(UserFeedback.id)).group_by(
                UserFeedback.priority
            )
        )
        by_priority = {r[0]: r[1] for r in pri_rows.all()}

        return schemas.FeedbackStatsResponse(
            total=total,
            pending=pending,
            reviewed=reviewed,
            in_progress=in_progress,
            resolved=resolved,
            dismissed=dismissed,
            avg_rating=avg_rating,
            today_count=today_count,
            this_week_count=week_count,
            by_category=by_category,
            by_priority=by_priority,
        )

    # ── Admin: update ─────────────────────────────────────────────────────────

    @staticmethod
    async def update_feedback(
        db: AsyncSession,
        feedback_id: str,
        payload: schemas.AdminUpdateFeedbackRequest,
        admin_id: str,
    ) -> Optional[schemas.FeedbackItem]:
        fb = await db.get(UserFeedback, feedback_id)
        if not fb:
            return None

        if payload.status is not None:
            fb.status = payload.status
            if payload.status == "resolved":
                fb.resolved_by = admin_id
                fb.resolved_at = _utcnow()
        if payload.priority is not None:
            fb.priority = payload.priority
        if payload.admin_notes is not None:
            fb.admin_notes = payload.admin_notes

        await db.commit()
        await db.refresh(fb)

        user_name = user_email = None
        if fb.user_id and not fb.is_anonymous:
            u = await db.get(UserModel, fb.user_id)
            if u:
                user_name = u.full_name
                user_email = u.email

        return schemas.FeedbackItem(
            id=fb.id,
            user_id=fb.user_id if not fb.is_anonymous else None,
            user_name=user_name,
            user_email=user_email,
            category=fb.category,
            rating=fb.rating,
            title=fb.title,
            message=fb.message,
            module=fb.module,
            status=fb.status,
            priority=fb.priority,
            admin_notes=fb.admin_notes,
            resolved_by=fb.resolved_by,
            resolved_at=fb.resolved_at,
            app_version=fb.app_version,
            platform=fb.platform,
            is_anonymous=fb.is_anonymous,
            created_at=fb.created_at,
            updated_at=fb.updated_at,
        )

    # ── Admin: delete ─────────────────────────────────────────────────────────

    @staticmethod
    async def delete_feedback(db: AsyncSession, feedback_id: str) -> bool:
        fb = await db.get(UserFeedback, feedback_id)
        if not fb:
            return False
        await db.delete(fb)
        await db.commit()
        return True

    # ── Admin: get single ─────────────────────────────────────────────────────

    @staticmethod
    async def get_feedback(
        db: AsyncSession, feedback_id: str
    ) -> Optional[schemas.FeedbackItem]:
        fb = await db.get(UserFeedback, feedback_id)
        if not fb:
            return None

        user_name = user_email = None
        if fb.user_id and not fb.is_anonymous:
            u = await db.get(UserModel, fb.user_id)
            if u:
                user_name = u.full_name
                user_email = u.email

        return schemas.FeedbackItem(
            id=fb.id,
            user_id=fb.user_id if not fb.is_anonymous else None,
            user_name=user_name,
            user_email=user_email,
            category=fb.category,
            rating=fb.rating,
            title=fb.title,
            message=fb.message,
            module=fb.module,
            status=fb.status,
            priority=fb.priority,
            admin_notes=fb.admin_notes,
            resolved_by=fb.resolved_by,
            resolved_at=fb.resolved_at,
            app_version=fb.app_version,
            platform=fb.platform,
            is_anonymous=fb.is_anonymous,
            created_at=fb.created_at,
            updated_at=fb.updated_at,
        )
