"""Permission helpers for the User Management module.

These work on top of the auth module's RBAC and add
user-resource-specific ownership checks.
"""

from __future__ import annotations

from backend.app.auth.models import UserModel
from backend.app.users.constants import UserRole
from backend.app.users.exceptions import (
    AddressOwnershipError,
    EmergencyContactOwnershipError,
    UserInactiveError,
)


# ─── Ownership guards ─────────────────────────────────────────────────────────


def assert_owns_address(current_user: UserModel, address_user_id: str) -> None:
    """Raise if the current user doesn't own the address (admins bypass)."""
    if current_user.role in (UserRole.ADMIN, UserRole.SUPER_ADMIN):
        return
    if current_user.id != address_user_id:
        raise AddressOwnershipError("You do not own this address.")


def assert_owns_contact(current_user: UserModel, contact_user_id: str) -> None:
    """Raise if the current user doesn't own the emergency contact (admins bypass)."""
    if current_user.role in (UserRole.ADMIN, UserRole.SUPER_ADMIN):
        return
    if current_user.id != contact_user_id:
        raise EmergencyContactOwnershipError("You do not own this contact.")


def assert_can_view_user(current_user: UserModel, target_user_id: str) -> None:
    """
    A user can view their own record.
    Admins / doctors can view any record.
    """
    if current_user.role in (UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.DOCTOR):
        return
    if current_user.id != target_user_id:
        from fastapi import HTTPException, status
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to view this user.",
        )


def assert_can_update_user(current_user: UserModel, target_user_id: str) -> None:
    """
    A user can update their own record.
    Admins can update any record.
    """
    if current_user.role in (UserRole.ADMIN, UserRole.SUPER_ADMIN):
        return
    if current_user.id != target_user_id:
        from fastapi import HTTPException, status
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to update this user.",
        )


def assert_is_admin(current_user: UserModel) -> None:
    if current_user.role not in (UserRole.ADMIN, UserRole.SUPER_ADMIN):
        from fastapi import HTTPException, status
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required.",
        )


def assert_user_active(user: UserModel) -> None:
    if not user.is_active:
        raise UserInactiveError(f"User account {user.id} is inactive.")
