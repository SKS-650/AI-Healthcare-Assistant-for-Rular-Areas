"""Utility helpers for the User Management module."""

from __future__ import annotations

import os
import uuid
from datetime import date, datetime, timezone
from typing import Any

from backend.app.auth.models import UserModel
from backend.app.users.constants import ALLOWED_IMAGE_EXTENSIONS, MAX_PROFILE_IMAGE_SIZE_MB
from backend.app.users.exceptions import ImageTooLargeError, InvalidImageTypeError
from backend.app.users.models import (
    EmergencyContactModel,
    MedicalInformationModel,
    UserAddressModel,
    UserProfileModel,
)
from backend.app.users.schemas import (
    AddressResponse,
    EmergencyContactResponse,
    FullUserDetailResponse,
    MedicalInfoResponse,
    UserProfileResponse,
    UserSummary,
)


# ─── Model → Schema converters ────────────────────────────────────────────────


def user_to_summary(user: UserModel) -> UserSummary:
    return UserSummary(
        user_id=user.id,
        full_name=user.full_name,
        email=user.email,
        phone=user.phone,
        role=user.role,
        preferred_language=user.language,
        profile_image=user.profile_image,
        is_active=user.is_active,
        email_verified=user.email_verified,
        phone_verified=user.phone_verified,
        created_at=user.created_at,
        updated_at=user.updated_at,
    )


def profile_to_response(profile: UserProfileModel) -> UserProfileResponse:
    return UserProfileResponse(
        profile_id=profile.id,
        user_id=profile.user_id,
        date_of_birth=profile.date_of_birth,
        gender=profile.gender,
        blood_group=profile.blood_group,
        height_cm=profile.height_cm,
        weight_kg=profile.weight_kg,
        occupation=profile.occupation,
        marital_status=profile.marital_status,
        bio=profile.bio,
        created_at=profile.created_at,
        updated_at=profile.updated_at,
    )


def address_to_response(addr: UserAddressModel) -> AddressResponse:
    return AddressResponse(
        address_id=addr.id,
        user_id=addr.user_id,
        address_type=addr.address_type,
        label=addr.label,
        country=addr.country,
        state=addr.state,
        district=addr.district,
        municipality=addr.municipality,
        ward_number=addr.ward_number,
        street=addr.street,
        postal_code=addr.postal_code,
        latitude=float(addr.latitude) if addr.latitude is not None else None,
        longitude=float(addr.longitude) if addr.longitude is not None else None,
        is_primary=addr.is_primary,
        created_at=addr.created_at,
        updated_at=addr.updated_at,
    )


def contact_to_response(c: EmergencyContactModel) -> EmergencyContactResponse:
    return EmergencyContactResponse(
        contact_id=c.id,
        user_id=c.user_id,
        contact_name=c.contact_name,
        relationship=c.contact_relationship,
        phone=c.phone,
        email=c.email,
        priority=c.priority,
        created_at=c.created_at,
        updated_at=c.updated_at,
    )


def medical_info_to_response(m: MedicalInformationModel) -> MedicalInfoResponse:
    return MedicalInfoResponse(
        info_id=m.id,
        user_id=m.user_id,
        blood_group=m.blood_group,
        allergies=m.allergies or [],
        chronic_diseases=m.chronic_diseases or [],
        disabilities=m.disabilities or [],
        current_medications=m.current_medications or [],
        smoking_status=m.smoking_status,
        alcohol_consumption=m.alcohol_consumption,
        notes=m.notes,
        created_at=m.created_at,
        updated_at=m.updated_at,
    )


def build_full_user_detail(
    user: UserModel,
    profile: UserProfileModel | None,
    addresses: list[UserAddressModel],
    contacts: list[EmergencyContactModel],
    medical_info: MedicalInformationModel | None,
) -> FullUserDetailResponse:
    return FullUserDetailResponse(
        account=user_to_summary(user),
        profile=profile_to_response(profile) if profile else None,
        addresses=[address_to_response(a) for a in addresses],
        emergency_contacts=[contact_to_response(c) for c in contacts],
        medical_info=medical_info_to_response(medical_info) if medical_info else None,
    )


# ─── Profile image validation ─────────────────────────────────────────────────


def validate_image_upload(filename: str, size_bytes: int) -> None:
    """Raise domain errors if the uploaded image fails constraints."""
    ext = os.path.splitext(filename.lower())[1]
    if ext not in ALLOWED_IMAGE_EXTENSIONS:
        raise InvalidImageTypeError(
            f"Image must be one of: {', '.join(ALLOWED_IMAGE_EXTENSIONS)}."
        )
    max_bytes = MAX_PROFILE_IMAGE_SIZE_MB * 1024 * 1024
    if size_bytes > max_bytes:
        raise ImageTooLargeError(
            f"Image must not exceed {MAX_PROFILE_IMAGE_SIZE_MB} MB."
        )


# ─── Age calculation ──────────────────────────────────────────────────────────


def calculate_age(date_of_birth: date | None) -> int | None:
    if date_of_birth is None:
        return None
    today = date.today()
    age = today.year - date_of_birth.year
    if (today.month, today.day) < (date_of_birth.month, date_of_birth.day):
        age -= 1
    return age
