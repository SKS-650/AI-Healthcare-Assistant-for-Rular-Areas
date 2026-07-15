"""
Medical Records Repositories — async data-access layer over SQLAlchemy.

All methods accept an AsyncSession and return ORM model instances.
Business logic lives in services.py.
"""

from __future__ import annotations

from typing import List, Optional, Sequence

from sqlalchemy import desc, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.health_records.models import (
    MedicalHistory,
    MedicalImage,
    Prescription,
    TimelineEvent,
    UserMedicalProfile,
)


# ─── Medical Profile ──────────────────────────────────────────────────────────

class MedicalProfileRepository:

    @staticmethod
    async def get_by_user(
        db: AsyncSession, user_id: str
    ) -> Optional[UserMedicalProfile]:
        result = await db.execute(
            select(UserMedicalProfile).where(UserMedicalProfile.user_id == user_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def create(
        db: AsyncSession, profile: UserMedicalProfile
    ) -> UserMedicalProfile:
        db.add(profile)
        await db.commit()
        await db.refresh(profile)
        return profile

    @staticmethod
    async def update(
        db: AsyncSession, profile: UserMedicalProfile
    ) -> UserMedicalProfile:
        await db.commit()
        await db.refresh(profile)
        return profile


# ─── Medical History ──────────────────────────────────────────────────────────

class MedicalHistoryRepository:

    @staticmethod
    async def get_by_user(
        db: AsyncSession,
        user_id: str,
        category: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> Sequence[MedicalHistory]:
        stmt = (
            select(MedicalHistory)
            .where(MedicalHistory.user_id == user_id)
            .order_by(desc(MedicalHistory.created_at))
            .limit(limit)
            .offset(offset)
        )
        if category:
            stmt = stmt.where(MedicalHistory.category == category)
        result = await db.execute(stmt)
        return result.scalars().all()

    @staticmethod
    async def count_by_user(db: AsyncSession, user_id: str) -> int:
        result = await db.execute(
            select(func.count()).where(MedicalHistory.user_id == user_id)
        )
        return result.scalar_one() or 0

    @staticmethod
    async def get_by_id(
        db: AsyncSession, history_id: str
    ) -> Optional[MedicalHistory]:
        result = await db.execute(
            select(MedicalHistory).where(MedicalHistory.id == history_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def create(
        db: AsyncSession, record: MedicalHistory
    ) -> MedicalHistory:
        db.add(record)
        await db.commit()
        await db.refresh(record)
        return record

    @staticmethod
    async def update(
        db: AsyncSession, record: MedicalHistory
    ) -> MedicalHistory:
        await db.commit()
        await db.refresh(record)
        return record

    @staticmethod
    async def delete(db: AsyncSession, record: MedicalHistory) -> None:
        await db.delete(record)
        await db.commit()


# ─── Prescription ─────────────────────────────────────────────────────────────

class PrescriptionRepository:

    @staticmethod
    async def get_by_user(
        db: AsyncSession,
        user_id: str,
        limit: int = 50,
        offset: int = 0,
    ) -> Sequence[Prescription]:
        result = await db.execute(
            select(Prescription)
            .where(Prescription.user_id == user_id)
            .order_by(desc(Prescription.created_at))
            .limit(limit)
            .offset(offset)
        )
        return result.scalars().all()

    @staticmethod
    async def count_by_user(db: AsyncSession, user_id: str) -> int:
        result = await db.execute(
            select(func.count()).where(Prescription.user_id == user_id)
        )
        return result.scalar_one() or 0

    @staticmethod
    async def get_by_id(
        db: AsyncSession, prescription_id: str
    ) -> Optional[Prescription]:
        result = await db.execute(
            select(Prescription).where(Prescription.id == prescription_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def create(
        db: AsyncSession, prescription: Prescription
    ) -> Prescription:
        db.add(prescription)
        await db.commit()
        await db.refresh(prescription)
        return prescription

    @staticmethod
    async def delete(db: AsyncSession, prescription: Prescription) -> None:
        await db.delete(prescription)
        await db.commit()


# ─── Medical Image ────────────────────────────────────────────────────────────

class MedicalImageRepository:

    @staticmethod
    async def get_by_user(
        db: AsyncSession,
        user_id: str,
        image_type: Optional[str] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> Sequence[MedicalImage]:
        stmt = (
            select(MedicalImage)
            .where(MedicalImage.user_id == user_id)
            .order_by(desc(MedicalImage.created_at))
            .limit(limit)
            .offset(offset)
        )
        if image_type:
            stmt = stmt.where(MedicalImage.image_type == image_type)
        result = await db.execute(stmt)
        return result.scalars().all()

    @staticmethod
    async def count_by_user(db: AsyncSession, user_id: str) -> int:
        result = await db.execute(
            select(func.count()).where(MedicalImage.user_id == user_id)
        )
        return result.scalar_one() or 0

    @staticmethod
    async def get_by_id(
        db: AsyncSession, image_id: str
    ) -> Optional[MedicalImage]:
        result = await db.execute(
            select(MedicalImage).where(MedicalImage.id == image_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def create(db: AsyncSession, image: MedicalImage) -> MedicalImage:
        db.add(image)
        await db.commit()
        await db.refresh(image)
        return image

    @staticmethod
    async def delete(db: AsyncSession, image: MedicalImage) -> None:
        await db.delete(image)
        await db.commit()


# ─── Timeline ─────────────────────────────────────────────────────────────────

class TimelineRepository:

    @staticmethod
    async def get_by_user(
        db: AsyncSession,
        user_id: str,
        limit: int = 50,
        offset: int = 0,
        event_type: Optional[str] = None,
    ) -> Sequence[TimelineEvent]:
        stmt = (
            select(TimelineEvent)
            .where(TimelineEvent.user_id == user_id)
            .order_by(desc(TimelineEvent.event_date))
            .limit(limit)
            .offset(offset)
        )
        if event_type:
            stmt = stmt.where(TimelineEvent.event_type == event_type)
        result = await db.execute(stmt)
        return result.scalars().all()

    @staticmethod
    async def count_by_user(db: AsyncSession, user_id: str) -> int:
        result = await db.execute(
            select(func.count()).where(TimelineEvent.user_id == user_id)
        )
        return result.scalar_one() or 0

    @staticmethod
    async def create(db: AsyncSession, event: TimelineEvent) -> TimelineEvent:
        db.add(event)
        await db.commit()
        await db.refresh(event)
        return event

    @staticmethod
    async def get_recent(
        db: AsyncSession, user_id: str, limit: int = 10
    ) -> Sequence[TimelineEvent]:
        result = await db.execute(
            select(TimelineEvent)
            .where(TimelineEvent.user_id == user_id)
            .order_by(desc(TimelineEvent.event_date))
            .limit(limit)
        )
        return result.scalars().all()
