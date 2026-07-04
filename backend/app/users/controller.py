"""User Management controller — HTTP adapter layer.

Converts validated Pydantic schemas → service calls → response schemas.
All DB commit/rollback lives here.
"""

from __future__ import annotations

import logging

from fastapi import HTTPException, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.auth.models import UserModel
from backend.app.users import service
from backend.app.users.exceptions import UserError, user_error_to_http
from backend.app.users.permissions import (
    assert_can_update_user,
    assert_can_view_user,
    assert_is_admin,
)
from backend.app.users.schemas import (
    AddressListResponse,
    AddressResponse,
    CreateAddressRequest,
    CreateEmergencyContactRequest,
    CreateMedicalInfoRequest,
    CreateProfileRequest,
    EmergencyContactListResponse,
    EmergencyContactResponse,
    FullUserDetailResponse,
    MedicalInfoResponse,
    UpdateAccountStatusRequest,
    UpdateAddressRequest,
    UpdateEmergencyContactRequest,
    UpdateMedicalInfoRequest,
    UpdateProfileRequest,
    UpdateUserRequest,
    UserListResponse,
    UserProfileResponse,
    UserSummary,
)
from backend.app.users.utils import (
    address_to_response,
    contact_to_response,
    medical_info_to_response,
    profile_to_response,
    user_to_summary,
    validate_image_upload,
)

logger = logging.getLogger(__name__)


# ─── Helpers ──────────────────────────────────────────────────────────────────

async def _commit_or_rollback(db: AsyncSession, coro):
    """Run a coroutine and commit; rollback + re-raise on any error."""
    try:
        result = await coro
        await db.commit()
        return result
    except UserError as e:
        await db.rollback()
        raise user_error_to_http(e)
    except HTTPException:
        await db.rollback()
        raise
    except Exception:
        await db.rollback()
        logger.exception("Unexpected error in user management")
        raise HTTPException(status_code=500, detail="Internal server error.")


# ─── User Account ──────────────────────────────────────────────────────────────


async def handle_get_me(current_user: UserModel) -> UserSummary:
    return user_to_summary(current_user)


async def handle_get_user(
    user_id: str, current_user: UserModel, db: AsyncSession
) -> FullUserDetailResponse:
    assert_can_view_user(current_user, user_id)
    try:
        return await service.get_full_user_detail(db, user_id)
    except UserError as e:
        raise user_error_to_http(e)


async def handle_list_users(
    current_user: UserModel,
    db: AsyncSession,
    role: str | None,
    is_active: bool | None,
    search: str | None,
    page: int,
    page_size: int,
) -> UserListResponse:
    assert_is_admin(current_user)
    try:
        users, total = await service.list_users(
            db,
            role=role,
            is_active=is_active,
            search=search,
            page=page,
            page_size=page_size,
        )
        return UserListResponse(
            users=[user_to_summary(u) for u in users],
            total=total,
            page=page,
            page_size=page_size,
        )
    except UserError as e:
        raise user_error_to_http(e)


async def handle_update_user(
    user_id: str,
    payload: UpdateUserRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> UserSummary:
    assert_can_update_user(current_user, user_id)
    user = await _commit_or_rollback(db, service.update_user(db, user_id, payload))
    return user_to_summary(user)


async def handle_set_account_status(
    target_user_id: str,
    payload: UpdateAccountStatusRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> dict:
    assert_is_admin(current_user)
    await _commit_or_rollback(
        db,
        service.set_account_status(db, current_user.id, target_user_id, payload.is_active),
    )
    status_str = "activated" if payload.is_active else "deactivated"
    return {"message": f"User account {status_str}."}


async def handle_upload_profile_image(
    user_id: str,
    file: UploadFile,
    current_user: UserModel,
    db: AsyncSession,
) -> dict:
    assert_can_update_user(current_user, user_id)

    content = await file.read()
    validate_image_upload(file.filename or "upload", len(content))

    # In production: upload to S3/GCS and get back a URL.
    # Here we store a local path stub for now.
    import os, uuid as _uuid
    ext = os.path.splitext(file.filename or ".jpg")[1]
    filename = f"{_uuid.uuid4()}{ext}"
    upload_dir = "backend/app/uploads/profile_images"
    os.makedirs(upload_dir, exist_ok=True)
    file_path = os.path.join(upload_dir, filename)

    with open(file_path, "wb") as f:
        f.write(content)

    image_url = f"/uploads/profile_images/{filename}"
    await _commit_or_rollback(db, service.update_profile_image(db, user_id, image_url))
    return {"profile_image": image_url, "message": "Profile image updated."}


# ─── User Profile ──────────────────────────────────────────────────────────────


async def handle_create_profile(
    payload: CreateProfileRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> UserProfileResponse:
    profile = await _commit_or_rollback(
        db, service.create_profile(db, current_user.id, payload)
    )
    return profile_to_response(profile)


async def handle_get_profile(
    user_id: str, current_user: UserModel, db: AsyncSession
) -> UserProfileResponse:
    assert_can_view_user(current_user, user_id)
    try:
        profile = await service.get_profile(db, user_id)
        return profile_to_response(profile)
    except UserError as e:
        raise user_error_to_http(e)


async def handle_update_profile(
    payload: UpdateProfileRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> UserProfileResponse:
    profile = await _commit_or_rollback(
        db, service.update_profile(db, current_user.id, payload)
    )
    return profile_to_response(profile)


# ─── Addresses ────────────────────────────────────────────────────────────────


async def handle_create_address(
    payload: CreateAddressRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> AddressResponse:
    address = await _commit_or_rollback(
        db, service.create_address(db, current_user.id, payload)
    )
    return address_to_response(address)


async def handle_get_addresses(
    current_user: UserModel, db: AsyncSession
) -> AddressListResponse:
    try:
        addresses = await service.get_addresses(db, current_user.id)
        return AddressListResponse(
            addresses=[address_to_response(a) for a in addresses],
            total=len(addresses),
        )
    except UserError as e:
        raise user_error_to_http(e)


async def handle_update_address(
    address_id: str,
    payload: UpdateAddressRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> AddressResponse:
    address = await _commit_or_rollback(
        db,
        service.update_address(db, current_user.id, address_id, payload, current_user),
    )
    return address_to_response(address)


async def handle_delete_address(
    address_id: str, current_user: UserModel, db: AsyncSession
) -> dict:
    await _commit_or_rollback(
        db, service.delete_address(db, current_user.id, address_id, current_user)
    )
    return {"message": "Address deleted."}


# ─── Emergency Contacts ───────────────────────────────────────────────────────


async def handle_create_contact(
    payload: CreateEmergencyContactRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> EmergencyContactResponse:
    contact = await _commit_or_rollback(
        db, service.create_emergency_contact(db, current_user.id, payload)
    )
    return contact_to_response(contact)


async def handle_get_contacts(
    current_user: UserModel, db: AsyncSession
) -> EmergencyContactListResponse:
    try:
        contacts = await service.get_emergency_contacts(db, current_user.id)
        return EmergencyContactListResponse(
            contacts=[contact_to_response(c) for c in contacts],
            total=len(contacts),
        )
    except UserError as e:
        raise user_error_to_http(e)


async def handle_update_contact(
    contact_id: str,
    payload: UpdateEmergencyContactRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> EmergencyContactResponse:
    contact = await _commit_or_rollback(
        db,
        service.update_emergency_contact(
            db, current_user.id, contact_id, payload, current_user
        ),
    )
    return contact_to_response(contact)


async def handle_delete_contact(
    contact_id: str, current_user: UserModel, db: AsyncSession
) -> dict:
    await _commit_or_rollback(
        db,
        service.delete_emergency_contact(db, current_user.id, contact_id, current_user),
    )
    return {"message": "Emergency contact deleted."}


# ─── Medical Information ──────────────────────────────────────────────────────


async def handle_create_medical_info(
    payload: CreateMedicalInfoRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> MedicalInfoResponse:
    info = await _commit_or_rollback(
        db, service.create_medical_info(db, current_user.id, payload)
    )
    return medical_info_to_response(info)


async def handle_get_medical_info(
    user_id: str, current_user: UserModel, db: AsyncSession
) -> MedicalInfoResponse:
    assert_can_view_user(current_user, user_id)
    try:
        info = await service.get_medical_info(db, user_id)
        return medical_info_to_response(info)
    except UserError as e:
        raise user_error_to_http(e)


async def handle_update_medical_info(
    payload: UpdateMedicalInfoRequest,
    current_user: UserModel,
    db: AsyncSession,
) -> MedicalInfoResponse:
    info = await _commit_or_rollback(
        db, service.update_medical_info(db, current_user.id, payload)
    )
    return medical_info_to_response(info)
