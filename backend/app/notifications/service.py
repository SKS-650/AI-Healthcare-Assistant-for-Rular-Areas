"""Notification service — business logic for creating and fetching notifications."""

from __future__ import annotations

import math
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import func, select, desc, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.notifications.models import UserNotification
from app.notifications import schemas


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


class NotificationService:

    # ── Create ────────────────────────────────────────────────────────────────

    @staticmethod
    async def create(
        db: AsyncSession,
        user_id: str,
        title: str,
        body: str,
        ntype: str = "info",
        module: Optional[str] = None,
        reference_id: Optional[str] = None,
    ) -> schemas.NotificationItem:
        notif = UserNotification(
            user_id=user_id,
            title=title,
            body=body,
            ntype=ntype,
            module=module,
            reference_id=reference_id,
        )
        db.add(notif)
        await db.commit()
        await db.refresh(notif)
        return schemas.NotificationItem.model_validate(notif)

    # ── List ──────────────────────────────────────────────────────────────────

    @staticmethod
    async def list_for_user(
        db: AsyncSession,
        user_id: str,
        page: int = 1,
        page_size: int = 20,
        unread_only: bool = False,
    ) -> schemas.NotificationListResponse:
        q = select(UserNotification).where(UserNotification.user_id == user_id)
        if unread_only:
            q = q.where(UserNotification.is_read == False)

        total = (
            await db.execute(select(func.count()).select_from(q.subquery()))
        ).scalar_one()

        unread_count = (
            await db.execute(
                select(func.count(UserNotification.id)).where(
                    and_(
                        UserNotification.user_id == user_id,
                        UserNotification.is_read == False,
                    )
                )
            )
        ).scalar_one()

        offset = (page - 1) * page_size
        result = await db.execute(
            q.order_by(desc(UserNotification.created_at))
            .offset(offset)
            .limit(page_size)
        )
        items = [
            schemas.NotificationItem.model_validate(n)
            for n in result.scalars().all()
        ]

        return schemas.NotificationListResponse(
            notifications=items,
            total=total,
            unread_count=unread_count,
            page=page,
            page_size=page_size,
            total_pages=math.ceil(total / page_size) if total else 1,
        )

    # ── Mark read ─────────────────────────────────────────────────────────────

    @staticmethod
    async def mark_read(
        db: AsyncSession,
        user_id: str,
        notification_ids: list[str],
    ) -> int:
        """Mark specific notifications as read. Returns count updated."""
        result = await db.execute(
            select(UserNotification).where(
                and_(
                    UserNotification.user_id == user_id,
                    UserNotification.id.in_(notification_ids),
                )
            )
        )
        rows = result.scalars().all()
        for n in rows:
            n.is_read = True
        await db.commit()
        return len(rows)

    @staticmethod
    async def mark_all_read(db: AsyncSession, user_id: str) -> int:
        result = await db.execute(
            select(UserNotification).where(
                and_(
                    UserNotification.user_id == user_id,
                    UserNotification.is_read == False,
                )
            )
        )
        rows = result.scalars().all()
        for n in rows:
            n.is_read = True
        await db.commit()
        return len(rows)

    # ── Delete ────────────────────────────────────────────────────────────────

    @staticmethod
    async def delete(
        db: AsyncSession, user_id: str, notification_id: str
    ) -> bool:
        n = await db.get(UserNotification, notification_id)
        if not n or n.user_id != user_id:
            return False
        await db.delete(n)
        await db.commit()
        return True

    @staticmethod
    async def delete_all_read(db: AsyncSession, user_id: str) -> int:
        result = await db.execute(
            select(UserNotification).where(
                and_(
                    UserNotification.user_id == user_id,
                    UserNotification.is_read == True,
                )
            )
        )
        rows = result.scalars().all()
        for n in rows:
            await db.delete(n)
        await db.commit()
        return len(rows)

    # ── Unread count (lightweight) ────────────────────────────────────────────

    @staticmethod
    async def unread_count(db: AsyncSession, user_id: str) -> int:
        return (
            await db.execute(
                select(func.count(UserNotification.id)).where(
                    and_(
                        UserNotification.user_id == user_id,
                        UserNotification.is_read == False,
                    )
                )
            )
        ).scalar_one()
