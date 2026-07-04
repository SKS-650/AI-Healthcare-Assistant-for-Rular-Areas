"""Permission helpers."""

from __future__ import annotations


def has_permission(user_roles: list[str], required_role: str) -> bool:
    """Return whether a user has the required role."""

    return "admin" in user_roles or required_role in user_roles
