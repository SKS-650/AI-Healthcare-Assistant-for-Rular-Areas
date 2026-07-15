"""
Emergency Repositories — thin async data-access layer over SQLAlchemy.

All methods accept a db: AsyncSession and return model instances.
Business logic lives in services.py, not here.
"""

from __future__ import annotations

from typing import List, Optional, Sequence

from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.emergency.models import EmergencyAssessment, EmergencyContact, SosEvent


# ─── Assessment Repository ────────────────────────────────────────────────────

class AssessmentRepository:

    @staticmethod
    async def create(db: AsyncSession, assessment: EmergencyAssessment) -> EmergencyAssessment:
        db.add(assessment)
        await db.commit()
        await db.refresh(assessment)
        return assessment

    @staticmethod
    async def get_by_id(db: AsyncSession, assessment_id: str) -> Optional[EmergencyAssessment]:
        result = await db.execute(
            select(EmergencyAssessment).where(EmergencyAssessment.id == assessment_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def get_by_user(
        db: AsyncSession,
        user_id: str,
        limit: int = 20,
        offset: int = 0,
    ) -> Sequence[EmergencyAssessment]:
        result = await db.execute(
            select(EmergencyAssessment)
            .where(EmergencyAssessment.user_id == user_id)
            .order_by(desc(EmergencyAssessment.created_at))
            .limit(limit)
            .offset(offset)
        )
        return result.scalars().all()

    @staticmethod
    async def count_by_user(db: AsyncSession, user_id: str) -> int:
        from sqlalchemy import func
        result = await db.execute(
            select(func.count()).where(EmergencyAssessment.user_id == user_id)
        )
        return result.scalar_one() or 0


# ─── Emergency Contact Repository ────────────────────────────────────────────

class ContactRepository:

    @staticmethod
    async def get_by_user(
        db: AsyncSession, user_id: str
    ) -> Sequence[EmergencyContact]:
        result = await db.execute(
            select(EmergencyContact)
            .where(EmergencyContact.user_id == user_id)
            .order_by(desc(EmergencyContact.is_primary), EmergencyContact.name)
        )
        return result.scalars().all()

    @staticmethod
    async def count_by_user(db: AsyncSession, user_id: str) -> int:
        from sqlalchemy import func
        result = await db.execute(
            select(func.count()).where(EmergencyContact.user_id == user_id)
        )
        return result.scalar_one() or 0

    @staticmethod
    async def get_by_id(
        db: AsyncSession, contact_id: str
    ) -> Optional[EmergencyContact]:
        result = await db.execute(
            select(EmergencyContact).where(EmergencyContact.id == contact_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def create(
        db: AsyncSession, contact: EmergencyContact
    ) -> EmergencyContact:
        db.add(contact)
        await db.commit()
        await db.refresh(contact)
        return contact

    @staticmethod
    async def update(
        db: AsyncSession, contact: EmergencyContact
    ) -> EmergencyContact:
        await db.commit()
        await db.refresh(contact)
        return contact

    @staticmethod
    async def delete(db: AsyncSession, contact: EmergencyContact) -> None:
        await db.delete(contact)
        await db.commit()


# ─── SOS Repository ──────────────────────────────────────────────────────────

class SosRepository:

    @staticmethod
    async def create(db: AsyncSession, sos: SosEvent) -> SosEvent:
        db.add(sos)
        await db.commit()
        await db.refresh(sos)
        return sos

    @staticmethod
    async def get_latest_by_user(
        db: AsyncSession, user_id: str
    ) -> Optional[SosEvent]:
        result = await db.execute(
            select(SosEvent)
            .where(SosEvent.user_id == user_id)
            .order_by(desc(SosEvent.created_at))
            .limit(1)
        )
        return result.scalar_one_or_none()
