"""Database operations for the User Management module.

All methods are async and accept a SQLAlchemy AsyncSession.
The service layer is responsible for committing transactions.
"""

from __future__ import annotations

import logging
from typing import Optional

from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from backend.app.auth.models import UserModel
from backend.app.users.models import (
    EmergencyContactModel,
    MedicalInformationModel,
    UserAddressModel,
    UserProfileModel,
)

logger = logging.getLogger(__name__)


# ─── Users ────────────────────────────────────────────────────────────────────


async def get_user_by_id(db: AsyncSession, user_id: str) -> Optional[UserModel]:
    result = await db.execute(select(UserModel).where(UserModel.id == user_id))
    return result.scalar_one_or_none()


async def get_user_by_email(db: AsyncSession, email: str) -> Optional[UserModel]:
    result = await db.execute(
        select(UserModel).where(UserModel.email == email.lower().strip())
    )
    return result.scalar_one_or_none()


async def get_user_by_phone(db: AsyncSession, phone: str) -> Optional[UserModel]:
    result = await db.execute(select(UserModel).where(UserModel.phone == phone))
    return result.scalar_one_or_none()


async def list_users(
    db: AsyncSession,
    *,
    role: str | None = None,
    is_active: bool | None = None,
    search: str | None = None,
    page: int = 1,
    page_size: int = 20,
) -> tuple[list[UserModel], int]:
    """Return a paginated list of users with optional filters."""
    query = select(UserModel)

    if role:
        query = query.where(UserModel.role == role)
    if is_active is not None:
        query = query.where(UserModel.is_active == is_active)
    if search:
        term = f"%{search.lower()}%"
        query = query.where(
            (func.lower(UserModel.full_name).like(term))
            | (func.lower(UserModel.email).like(term))
        )

    # Total count
    count_q = select(func.count()).select_from(query.subquery())
    total = (await db.execute(count_q)).scalar_one()

    # Paginated records
    query = query.offset((page - 1) * page_size).limit(page_size).order_by(UserModel.created_at.desc())
    result = await db.execute(query)
    users = list(result.scalars().all())

    return users, total


async def update_user_fields(
    db: AsyncSession, user_id: str, **fields: object
) -> None:
    """Generic update of arbitrary UserModel columns."""
    if not fields:
        return
    from datetime import datetime, timezone
    fields["updated_at"] = datetime.now(timezone.utc)
    await db.execute(update(UserModel).where(UserModel.id == user_id).values(**fields))


async def set_account_status(db: AsyncSession, user_id: str, is_active: bool) -> None:
    await update_user_fields(db, user_id, is_active=is_active)


async def update_profile_image(db: AsyncSession, user_id: str, image_url: str) -> None:
    await update_user_fields(db, user_id, profile_image=image_url)


# ─── User Profile ─────────────────────────────────────────────────────────────


async def get_profile_by_user_id(
    db: AsyncSession, user_id: str
) -> Optional[UserProfileModel]:
    result = await db.execute(
        select(UserProfileModel).where(UserProfileModel.user_id == user_id)
    )
    return result.scalar_one_or_none()


async def create_profile(db: AsyncSession, profile: UserProfileModel) -> UserProfileModel:
    db.add(profile)
    await db.flush()
    return profile


async def update_profile_fields(
    db: AsyncSession, user_id: str, **fields: object
) -> None:
    if not fields:
        return
    from datetime import datetime, timezone
    fields["updated_at"] = datetime.now(timezone.utc)
    await db.execute(
        update(UserProfileModel)
        .where(UserProfileModel.user_id == user_id)
        .values(**fields)
    )


# ─── Addresses ────────────────────────────────────────────────────────────────


async def get_address_by_id(
    db: AsyncSession, address_id: str
) -> Optional[UserAddressModel]:
    result = await db.execute(
        select(UserAddressModel).where(UserAddressModel.id == address_id)
    )
    return result.scalar_one_or_none()


async def list_addresses(
    db: AsyncSession, user_id: str
) -> list[UserAddressModel]:
    result = await db.execute(
        select(UserAddressModel)
        .where(UserAddressModel.user_id == user_id)
        .order_by(UserAddressModel.is_primary.desc(), UserAddressModel.created_at.asc())
    )
    return list(result.scalars().all())


async def count_addresses(db: AsyncSession, user_id: str) -> int:
    result = await db.execute(
        select(func.count()).where(UserAddressModel.user_id == user_id)
    )
    return result.scalar_one()


async def create_address(
    db: AsyncSession, address: UserAddressModel
) -> UserAddressModel:
    # If this is primary, demote all others
    if address.is_primary:
        await db.execute(
            update(UserAddressModel)
            .where(UserAddressModel.user_id == address.user_id)
            .values(is_primary=False)
        )
    db.add(address)
    await db.flush()
    return address


async def update_address_fields(
    db: AsyncSession, address_id: str, user_id: str, **fields: object
) -> None:
    if not fields:
        return
    from datetime import datetime, timezone
    fields["updated_at"] = datetime.now(timezone.utc)
    # If setting as primary, demote others first
    if fields.get("is_primary"):
        await db.execute(
            update(UserAddressModel)
            .where(UserAddressModel.user_id == user_id)
            .values(is_primary=False)
        )
    await db.execute(
        update(UserAddressModel)
        .where(UserAddressModel.id == address_id)
        .values(**fields)
    )


async def delete_address(db: AsyncSession, address_id: str) -> None:
    result = await db.execute(
        select(UserAddressModel).where(UserAddressModel.id == address_id)
    )
    address = result.scalar_one_or_none()
    if address:
        await db.delete(address)


# ─── Emergency Contacts ───────────────────────────────────────────────────────


async def get_contact_by_id(
    db: AsyncSession, contact_id: str
) -> Optional[EmergencyContactModel]:
    result = await db.execute(
        select(EmergencyContactModel).where(EmergencyContactModel.id == contact_id)
    )
    return result.scalar_one_or_none()


async def list_emergency_contacts(
    db: AsyncSession, user_id: str
) -> list[EmergencyContactModel]:
    result = await db.execute(
        select(EmergencyContactModel)
        .where(EmergencyContactModel.user_id == user_id)
        .order_by(EmergencyContactModel.priority.asc())
    )
    return list(result.scalars().all())


async def count_emergency_contacts(db: AsyncSession, user_id: str) -> int:
    result = await db.execute(
        select(func.count()).where(EmergencyContactModel.user_id == user_id)
    )
    return result.scalar_one()


async def create_emergency_contact(
    db: AsyncSession, contact: EmergencyContactModel
) -> EmergencyContactModel:
    db.add(contact)
    await db.flush()
    return contact


async def update_contact_fields(
    db: AsyncSession, contact_id: str, **fields: object
) -> None:
    if not fields:
        return
    from datetime import datetime, timezone
    fields["updated_at"] = datetime.now(timezone.utc)
    await db.execute(
        update(EmergencyContactModel)
        .where(EmergencyContactModel.id == contact_id)
        .values(**fields)
    )


async def delete_emergency_contact(db: AsyncSession, contact_id: str) -> None:
    result = await db.execute(
        select(EmergencyContactModel).where(EmergencyContactModel.id == contact_id)
    )
    contact = result.scalar_one_or_none()
    if contact:
        await db.delete(contact)


# ─── Medical Information ──────────────────────────────────────────────────────


async def get_medical_info_by_user_id(
    db: AsyncSession, user_id: str
) -> Optional[MedicalInformationModel]:
    result = await db.execute(
        select(MedicalInformationModel).where(MedicalInformationModel.user_id == user_id)
    )
    return result.scalar_one_or_none()


async def create_medical_info(
    db: AsyncSession, info: MedicalInformationModel
) -> MedicalInformationModel:
    db.add(info)
    await db.flush()
    return info


async def update_medical_info_fields(
    db: AsyncSession, user_id: str, **fields: object
) -> None:
    if not fields:
        return
    from datetime import datetime, timezone
    fields["updated_at"] = datetime.now(timezone.utc)
    await db.execute(
        update(MedicalInformationModel)
        .where(MedicalInformationModel.user_id == user_id)
        .values(**fields)
    )
