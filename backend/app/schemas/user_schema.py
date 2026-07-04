"""User API schemas.

These schemas are lightweight Python data structures intended to be used by
API layer code for request/response payload validation/transport.

They are kept framework-agnostic (no FastAPI/Pydantic dependency) to match
the style used by backend/app/models.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class UserCreateRequest:
    """Payload for creating or registering a user."""

    email: Optional[str] = None
    display_name: Optional[str] = None
    roles: list[str] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass
class UserUpdateRequest:
    """Payload for updating user profile fields."""

    display_name: Optional[str] = None
    roles: Optional[list[str]] = None
    metadata: Optional[dict[str, Any]] = None


@dataclass
class UserResponse:
    """Payload returned for user profile endpoints."""

    id: str
    email: Optional[str] = None
    display_name: Optional[str] = None
    roles: list[str] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)

