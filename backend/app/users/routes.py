"""User Management API endpoints.

All routes mounted under /api/v1/users.
"""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, Depends, File, Query, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.auth.dependencies import CurrentUser, get_current_user, require_role
from backend.app.auth.constants import Role
from backend.app.users import controller
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

from backend.app.database.connection import get_async_session as get_db

router = APIRouter(prefix="/users", tags=["User Management"])

# ─────────────────────────────────────────────────────────────────────────────
# IMPORTANT: All static/fixed paths MUST be registered BEFORE the wildcard
# "/{user_id}" route, otherwise FastAPI matches them as user IDs.
# Order: /me, /profile, /address, /emergency-contact, /medical-info, /
#        THEN /{user_id} and /{user_id}/...
# ─────────────────────────────────────────────────────────────────────────────


# ─── Account (/me) ────────────────────────────────────────────────────────────


@router.get(
    "/me",
    response_model=UserSummary,
    summary="Get my account",
    description="Returns the authenticated user's account summary.",
)
async def get_me(current_user: CurrentUser) -> UserSummary:
    return await controller.handle_get_me(current_user)


@router.put(
    "/me",
    response_model=UserSummary,
    summary="Update my account",
    description="Update full name, phone, preferred language, or profile image URL.",
)
async def update_me(
    payload: UpdateUserRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> UserSummary:
    return await controller.handle_update_user(current_user.id, payload, current_user, db)


@router.post(
    "/me/profile-image",
    summary="Upload profile image",
    description="Upload a JPEG/PNG/WebP profile image (max 5 MB).",
)
async def upload_profile_image(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
    file: UploadFile = File(...),
) -> dict:
    return await controller.handle_upload_profile_image(
        current_user.id, file, current_user, db
    )


# ─── Admin: user list ─────────────────────────────────────────────────────────


@router.get(
    "/",
    response_model=UserListResponse,
    summary="List users (admin)",
    description="Paginated, filterable list of all users. Admin only.",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def list_users(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
    role: Optional[str] = Query(None, description="Filter by role"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    search: Optional[str] = Query(None, description="Search by name or email"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
) -> UserListResponse:
    return await controller.handle_list_users(
        current_user, db, role, is_active, search, page, page_size
    )


# ─── Profile (static paths before /{user_id}) ─────────────────────────────────


@router.post(
    "/profile",
    response_model=UserProfileResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create user profile",
    description="Creates the personal profile record for the authenticated user.",
)
async def create_profile(
    payload: CreateProfileRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> UserProfileResponse:
    return await controller.handle_create_profile(payload, current_user, db)


@router.get(
    "/profile",
    response_model=UserProfileResponse,
    summary="Get my profile",
)
async def get_my_profile(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> UserProfileResponse:
    return await controller.handle_get_profile(current_user.id, current_user, db)


@router.put(
    "/profile",
    response_model=UserProfileResponse,
    summary="Update my profile",
    description="Full or partial update of the authenticated user's profile.",
)
async def update_profile(
    payload: UpdateProfileRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> UserProfileResponse:
    return await controller.handle_update_profile(payload, current_user, db)


# ─── Addresses (static paths before /{user_id}) ───────────────────────────────


@router.post(
    "/address",
    response_model=AddressResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add address",
)
async def create_address(
    payload: CreateAddressRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> AddressResponse:
    return await controller.handle_create_address(payload, current_user, db)


@router.get(
    "/address",
    response_model=AddressListResponse,
    summary="Get my addresses",
)
async def get_addresses(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> AddressListResponse:
    return await controller.handle_get_addresses(current_user, db)


@router.put(
    "/address/{address_id}",
    response_model=AddressResponse,
    summary="Update address",
)
async def update_address(
    address_id: str,
    payload: UpdateAddressRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> AddressResponse:
    return await controller.handle_update_address(address_id, payload, current_user, db)


@router.delete(
    "/address/{address_id}",
    summary="Delete address",
    status_code=status.HTTP_200_OK,
)
async def delete_address(
    address_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    return await controller.handle_delete_address(address_id, current_user, db)


# ─── Emergency Contacts (static paths before /{user_id}) ─────────────────────


@router.post(
    "/emergency-contact",
    response_model=EmergencyContactResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add emergency contact",
)
async def create_emergency_contact(
    payload: CreateEmergencyContactRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> EmergencyContactResponse:
    return await controller.handle_create_contact(payload, current_user, db)


@router.get(
    "/emergency-contact",
    response_model=EmergencyContactListResponse,
    summary="Get emergency contacts",
)
async def get_emergency_contacts(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> EmergencyContactListResponse:
    return await controller.handle_get_contacts(current_user, db)


@router.put(
    "/emergency-contact/{contact_id}",
    response_model=EmergencyContactResponse,
    summary="Update emergency contact",
)
async def update_emergency_contact(
    contact_id: str,
    payload: UpdateEmergencyContactRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> EmergencyContactResponse:
    return await controller.handle_update_contact(
        contact_id, payload, current_user, db
    )


@router.delete(
    "/emergency-contact/{contact_id}",
    summary="Delete emergency contact",
    status_code=status.HTTP_200_OK,
)
async def delete_emergency_contact(
    contact_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    return await controller.handle_delete_contact(contact_id, current_user, db)


# ─── Medical Information (static paths before /{user_id}) ────────────────────


@router.post(
    "/medical-info",
    response_model=MedicalInfoResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create medical information",
)
async def create_medical_info(
    payload: CreateMedicalInfoRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> MedicalInfoResponse:
    return await controller.handle_create_medical_info(payload, current_user, db)


@router.get(
    "/medical-info",
    response_model=MedicalInfoResponse,
    summary="Get my medical information",
)
async def get_medical_info(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> MedicalInfoResponse:
    return await controller.handle_get_medical_info(current_user.id, current_user, db)


@router.put(
    "/medical-info",
    response_model=MedicalInfoResponse,
    summary="Update medical information",
)
async def update_medical_info(
    payload: UpdateMedicalInfoRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> MedicalInfoResponse:
    return await controller.handle_update_medical_info(payload, current_user, db)


# ─── Dynamic user routes (MUST come AFTER all static routes above) ────────────


@router.get(
    "/{user_id}",
    response_model=FullUserDetailResponse,
    summary="Get full user detail",
    description=(
        "Returns the complete user record (account + profile + addresses + "
        "emergency contacts + medical info). "
        "Users can only view their own record; doctors and admins can view any."
    ),
)
async def get_user(
    user_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> FullUserDetailResponse:
    return await controller.handle_get_user(user_id, current_user, db)


@router.patch(
    "/{user_id}/status",
    summary="Set account status (admin)",
    description="Activate or deactivate a user account. Admin only.",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def set_account_status(
    user_id: str,
    payload: UpdateAccountStatusRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> dict:
    return await controller.handle_set_account_status(user_id, payload, current_user, db)


@router.get(
    "/{user_id}/profile",
    response_model=UserProfileResponse,
    summary="Get user profile (admin/doctor)",
)
async def get_user_profile(
    user_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> UserProfileResponse:
    return await controller.handle_get_profile(user_id, current_user, db)
