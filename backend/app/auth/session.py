"""Session management utilities for the authentication module."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from backend.app.auth.constants import SESSION_EXPIRE_SECONDS
from backend.app.auth.exceptions import SessionExpiredError, SessionNotFoundError
from backend.app.auth.models import UserSessionModel


def create_session_record(
    user_id: str,
    refresh_token_id: str | None = None,
    device_info: str | None = None,
    ip_address: str | None = None,
) -> UserSessionModel:
    """Build (but do not persist) a new UserSessionModel."""
    now = datetime.now(timezone.utc)
    from datetime import timedelta

    return UserSessionModel(
        id=str(uuid.uuid4()),
        user_id=user_id,
        refresh_token_id=refresh_token_id,
        device_info=device_info,
        ip_address=ip_address,
        is_active=True,
        expires_at=now + timedelta(seconds=SESSION_EXPIRE_SECONDS),
        created_at=now,
        last_active_at=now,
    )


def is_session_valid(session: UserSessionModel) -> bool:
    """Return True if the session is active and not expired."""
    now = datetime.now(timezone.utc)
    expires = session.expires_at
    if expires.tzinfo is None:
        # Treat naïve datetimes as UTC
        from datetime import timezone as tz
        expires = expires.replace(tzinfo=tz.utc)
    return session.is_active and now < expires


def validate_session(session: UserSessionModel | None) -> UserSessionModel:
    """Validate a session record, raising domain errors on failure."""
    if session is None:
        raise SessionNotFoundError("Session not found.")
    if not is_session_valid(session):
        raise SessionExpiredError("Session has expired.")
    return session


def touch_session(session: UserSessionModel) -> None:
    """Update last_active_at to now (call before commit)."""
    session.last_active_at = datetime.now(timezone.utc)


def invalidate_session(session: UserSessionModel) -> None:
    """Mark a session as inactive (call before commit)."""
    session.is_active = False
