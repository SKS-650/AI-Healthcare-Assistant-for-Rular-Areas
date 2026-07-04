"""Role-based permission helpers for the authentication module."""

from __future__ import annotations

from backend.app.auth.constants import ROLE_PERMISSIONS, Role
from backend.app.auth.exceptions import InsufficientPermissionsError, InvalidRoleError


def get_permissions_for_role(role: str) -> list[str]:
    """Return the list of permissions assigned to a role."""
    if role not in ROLE_PERMISSIONS:
        raise InvalidRoleError(f"Unknown role: {role!r}")
    return list(ROLE_PERMISSIONS[role])


def has_permission(role: str, permission: str) -> bool:
    """Return True if the given role includes the requested permission."""
    perms = ROLE_PERMISSIONS.get(role, [])
    return permission in perms


def require_permission(role: str, permission: str) -> None:
    """Raise InsufficientPermissionsError if the role lacks the permission."""
    if not has_permission(role, permission):
        raise InsufficientPermissionsError(
            f"Role '{role}' does not have permission '{permission}'."
        )


def is_admin(role: str) -> bool:
    return role in (Role.ADMIN, Role.SUPER_ADMIN)


def is_doctor(role: str) -> bool:
    return role == Role.DOCTOR


def is_patient(role: str) -> bool:
    return role == Role.PATIENT
