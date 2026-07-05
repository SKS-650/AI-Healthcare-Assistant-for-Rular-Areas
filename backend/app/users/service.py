"""Business logic for the User Management module.

Public methods map 1-to-1 with API operations.
No HTTP objects here — only domain models and exceptions.
"""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.models import UserModel
from app.users import repository as repo
from app.users.constants import (
    MAX_ADDRESSES_PER_USER,
    MAX_EMERGENCY_CONTACTS_PER_USER,
)
from app.users.exceptions import (
    AddressLimitExceededError,
    AddressNotFoundError,
    AddressOwnershipError,
    CannotDeactivateSelfError,
    EmergencyContactLimitExceededError,
    EmergencyContactNotFoundError,
    EmergencyContactOwnershipError,
    MedicalInfoAlreadyExistsError,
    MedicalInfoNotFoundError,
    ProfileAlreadyExistsError,
    ProfileNotFoundError,
    UserNotFoundError,
)
from app.users.models import (
    EmergencyContactModel,
    MedicalInformationModel,
    UserAddressModel,
    UserProfileModel,
)
from app.users.schemas import (
    CreateAddressRequest,
    CreateEmergencyContactRequest,
    CreateMedicalInfoRequest,
    CreateProfileRequest,
    UpdateAddressRequest,
    UpdateEmergencyContactRequest,
    UpdateMedicalInfoRequest,
    UpdateProfileRequest,
    UpdateUserRequest,
)
from app.users.validators import (
    validate_blood_group,
    validate_coordinates,
    validate_date_of_birth,
    validate_gender,
    validate_height,
    validate_language,
    validate_marital_status,
    validate_phone,
    validate_priority,
    validate_relationship,
    validate_weight,
)

logger = logging.getLogger(__name__)


# ─── User Account ──────────────────────────────────────────────────────────────


async def get_user(db: AsyncSession, user_id: str) -> UserModel:
    user = await repo.get_user_by_id(db, user_id)
    if user is None:
        raise UserNotFoundError(f"User {user_id} not found.")
    return user


async def get_full_user_detail(db: AsyncSession, user_id: str):
    """Return user + all sub-records for the detail endpoint."""
    from app.users.utils import build_full_user_detail

    user = await get_user(db, user_id)
    profile = await repo.get_profile_by_user_id(db, user_id)
    addresses = await repo.list_addresses(db, user_id)
    contacts = await repo.list_emergency_contacts(db, user_id)
    medical_info = await repo.get_medical_info_by_user_id(db, user_id)

    return build_full_user_detail(user, profile, addresses, contacts, medical_info)


async def list_users(
    db: AsyncSession,
    *,
    role: str | None = None,
    is_active: bool | None = None,
    search: str | None = None,
    page: int = 1,
    page_size: int = 20,
):
    return await repo.list_users(
        db, role=role, is_active=is_active, search=search, page=page, page_size=page_size
    )


async def update_user(
    db: AsyncSession, user_id: str, payload: UpdateUserRequest
) -> UserModel:
    user = await get_user(db, user_id)

    fields: dict = {}

    if payload.full_name is not None:
        fields["full_name"] = payload.full_name

    if payload.phone is not None:
        validate_phone(payload.phone)
        # Uniqueness check
        existing = await repo.get_user_by_phone(db, payload.phone)
        if existing and existing.id != user_id:
            from app.users.exceptions import UserAlreadyExistsError
            raise UserAlreadyExistsError("Phone number already in use.")
        fields["phone"] = payload.phone

    if payload.preferred_language is not None:
        validate_language(payload.preferred_language)
        fields["language"] = payload.preferred_language

    if payload.profile_image is not None:
        fields["profile_image"] = payload.profile_image

    await repo.update_user_fields(db, user_id, **fields)
    return await get_user(db, user_id)


async def set_account_status(
    db: AsyncSession,
    admin_user_id: str,
    target_user_id: str,
    is_active: bool,
) -> None:
    if admin_user_id == target_user_id:
        raise CannotDeactivateSelfError()
    await get_user(db, target_user_id)  # raises if not found
    await repo.set_account_status(db, target_user_id, is_active)


async def update_profile_image(
    db: AsyncSession, user_id: str, image_url: str
) -> None:
    await get_user(db, user_id)
    await repo.update_profile_image(db, user_id, image_url)


# ─── User Profile ──────────────────────────────────────────────────────────────


async def create_profile(
    db: AsyncSession, user_id: str, payload: CreateProfileRequest
) -> UserProfileModel:
    await get_user(db, user_id)

    existing = await repo.get_profile_by_user_id(db, user_id)
    if existing:
        raise ProfileAlreadyExistsError("Profile already exists. Use PUT to update.")

    profile = UserProfileModel(
        id=str(uuid.uuid4()),
        user_id=user_id,
        date_of_birth=payload.date_of_birth,
        gender=payload.gender,
        blood_group=payload.blood_group,
        height_cm=payload.height_cm,
        weight_kg=payload.weight_kg,
        occupation=payload.occupation,
        marital_status=payload.marital_status,
        bio=payload.bio,
    )
    return await repo.create_profile(db, profile)


async def get_profile(db: AsyncSession, user_id: str) -> UserProfileModel:
    profile = await repo.get_profile_by_user_id(db, user_id)
    if profile is None:
        raise ProfileNotFoundError("Profile not found.")
    return profile


async def update_profile(
    db: AsyncSession, user_id: str, payload: UpdateProfileRequest
) -> UserProfileModel:
    await get_user(db, user_id)
    existing = await repo.get_profile_by_user_id(db, user_id)
    if existing is None:
        raise ProfileNotFoundError("Profile not found. Create it first.")

    fields = payload.model_dump(exclude_none=True)

    # Re-run business validators on the incoming fields
    if "date_of_birth" in fields:
        validate_date_of_birth(fields["date_of_birth"])
    if "gender" in fields:
        fields["gender"] = validate_gender(fields["gender"])
    if "blood_group" in fields:
        fields["blood_group"] = validate_blood_group(fields["blood_group"])
    if "height_cm" in fields:
        validate_height(fields["height_cm"])
    if "weight_kg" in fields:
        validate_weight(fields["weight_kg"])
    if "marital_status" in fields:
        fields["marital_status"] = validate_marital_status(fields["marital_status"])

    await repo.update_profile_fields(db, user_id, **fields)
    return await repo.get_profile_by_user_id(db, user_id)  # type: ignore[return-value]


# ─── Addresses ────────────────────────────────────────────────────────────────


async def create_address(
    db: AsyncSession, user_id: str, payload: CreateAddressRequest
) -> UserAddressModel:
    await get_user(db, user_id)

    count = await repo.count_addresses(db, user_id)
    if count >= MAX_ADDRESSES_PER_USER:
        raise AddressLimitExceededError(
            f"Maximum of {MAX_ADDRESSES_PER_USER} addresses allowed."
        )

    validate_coordinates(payload.latitude, payload.longitude)

    address = UserAddressModel(
        id=str(uuid.uuid4()),
        user_id=user_id,
        address_type=payload.address_type,
        label=payload.label,
        country=payload.country,
        state=payload.state,
        district=payload.district,
        municipality=payload.municipality,
        ward_number=payload.ward_number,
        street=payload.street,
        postal_code=payload.postal_code,
        latitude=payload.latitude,
        longitude=payload.longitude,
        is_primary=payload.is_primary,
    )
    return await repo.create_address(db, address)


async def get_addresses(db: AsyncSession, user_id: str) -> list[UserAddressModel]:
    await get_user(db, user_id)
    return await repo.list_addresses(db, user_id)


async def update_address(
    db: AsyncSession,
    user_id: str,
    address_id: str,
    payload: UpdateAddressRequest,
    current_user: UserModel,
) -> UserAddressModel:
    address = await repo.get_address_by_id(db, address_id)
    if address is None:
        raise AddressNotFoundError("Address not found.")

    from app.users.permissions import assert_owns_address
    assert_owns_address(current_user, address.user_id)

    validate_coordinates(payload.latitude, payload.longitude)

    fields = payload.model_dump(exclude_none=True)
    await repo.update_address_fields(db, address_id, user_id, **fields)

    updated = await repo.get_address_by_id(db, address_id)
    return updated  # type: ignore[return-value]


async def delete_address(
    db: AsyncSession, user_id: str, address_id: str, current_user: UserModel
) -> None:
    address = await repo.get_address_by_id(db, address_id)
    if address is None:
        raise AddressNotFoundError("Address not found.")

    from app.users.permissions import assert_owns_address
    assert_owns_address(current_user, address.user_id)

    await repo.delete_address(db, address_id)


# ─── Emergency Contacts ───────────────────────────────────────────────────────


async def create_emergency_contact(
    db: AsyncSession, user_id: str, payload: CreateEmergencyContactRequest
) -> EmergencyContactModel:
    await get_user(db, user_id)

    count = await repo.count_emergency_contacts(db, user_id)
    if count >= MAX_EMERGENCY_CONTACTS_PER_USER:
        raise EmergencyContactLimitExceededError(
            f"Maximum of {MAX_EMERGENCY_CONTACTS_PER_USER} emergency contacts allowed."
        )

    contact = EmergencyContactModel(
        id=str(uuid.uuid4()),
        user_id=user_id,
        contact_name=payload.contact_name,
        contact_relationship=payload.relationship,
        phone=payload.phone,
        email=str(payload.email) if payload.email else None,
        priority=payload.priority,
    )
    return await repo.create_emergency_contact(db, contact)


async def get_emergency_contacts(
    db: AsyncSession, user_id: str
) -> list[EmergencyContactModel]:
    await get_user(db, user_id)
    return await repo.list_emergency_contacts(db, user_id)


async def update_emergency_contact(
    db: AsyncSession,
    user_id: str,
    contact_id: str,
    payload: UpdateEmergencyContactRequest,
    current_user: UserModel,
) -> EmergencyContactModel:
    contact = await repo.get_contact_by_id(db, contact_id)
    if contact is None:
        raise EmergencyContactNotFoundError("Emergency contact not found.")

    from app.users.permissions import assert_owns_contact
    assert_owns_contact(current_user, contact.user_id)

    fields = payload.model_dump(exclude_none=True)
    if "email" in fields and fields["email"]:
        fields["email"] = str(fields["email"])

    await repo.update_contact_fields(db, contact_id, **fields)
    updated = await repo.get_contact_by_id(db, contact_id)
    return updated  # type: ignore[return-value]


async def delete_emergency_contact(
    db: AsyncSession,
    user_id: str,
    contact_id: str,
    current_user: UserModel,
) -> None:
    contact = await repo.get_contact_by_id(db, contact_id)
    if contact is None:
        raise EmergencyContactNotFoundError("Emergency contact not found.")

    from app.users.permissions import assert_owns_contact
    assert_owns_contact(current_user, contact.user_id)

    await repo.delete_emergency_contact(db, contact_id)


# ─── Medical Information ──────────────────────────────────────────────────────


async def create_medical_info(
    db: AsyncSession, user_id: str, payload: CreateMedicalInfoRequest
) -> MedicalInformationModel:
    await get_user(db, user_id)

    existing = await repo.get_medical_info_by_user_id(db, user_id)
    if existing:
        raise MedicalInfoAlreadyExistsError(
            "Medical information already exists. Use PUT to update."
        )

    info = MedicalInformationModel(
        id=str(uuid.uuid4()),
        user_id=user_id,
        blood_group=payload.blood_group,
        allergies=payload.allergies or [],
        chronic_diseases=payload.chronic_diseases or [],
        disabilities=payload.disabilities or [],
        current_medications=payload.current_medications or [],
        smoking_status=payload.smoking_status,
        alcohol_consumption=payload.alcohol_consumption,
        notes=payload.notes,
    )
    return await repo.create_medical_info(db, info)


async def get_medical_info(db: AsyncSession, user_id: str) -> MedicalInformationModel:
    await get_user(db, user_id)
    info = await repo.get_medical_info_by_user_id(db, user_id)
    if info is None:
        raise MedicalInfoNotFoundError("Medical information not found.")
    return info


async def update_medical_info(
    db: AsyncSession, user_id: str, payload: UpdateMedicalInfoRequest
) -> MedicalInformationModel:
    await get_user(db, user_id)
    existing = await repo.get_medical_info_by_user_id(db, user_id)
    if existing is None:
        raise MedicalInfoNotFoundError(
            "Medical information not found. Create it first."
        )

    fields = payload.model_dump(exclude_none=True)
    await repo.update_medical_info_fields(db, user_id, **fields)
    updated = await repo.get_medical_info_by_user_id(db, user_id)
    return updated  # type: ignore[return-value]
