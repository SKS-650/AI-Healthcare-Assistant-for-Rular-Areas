"""JWT utilities for the authentication module.

Wraps backend.app.security.jwt and adds healthcare-specific claims
(role, token_type, jti for revocation).
"""

from __future__ import annotations

import hashlib
import os
import uuid
from datetime import datetime, timezone
from typing import Any

from app.auth.constants import (
    ACCESS_TOKEN_EXPIRE_SECONDS,
    REFRESH_TOKEN_EXPIRE_SECONDS,
    TOKEN_TYPE_ACCESS,
    TOKEN_TYPE_REFRESH,
)
from app.auth.exceptions import TokenExpiredError, TokenInvalidError
from app.config.settings import settings
from app.security.jwt import (
    JWTExpiredError,
    JWTInvalidError,
    create_access_token as _create_jwt,
    decode_token as _decode_jwt,
)


def _secret() -> str:
    s = settings.jwt_secret_key
    if not s or s == "change-me":
        raise RuntimeError("JWT_SECRET_KEY is not configured. Set it in your .env file.")
    return s


def _jti() -> str:
    """Generate a unique JWT ID."""
    return str(uuid.uuid4())


# ─── Token Creation ──────────────────────────────────────────────────────────


def create_access_token(user_id: str, role: str, extra: dict[str, Any] | None = None) -> str:
    """Create a signed access JWT for the given user."""
    claims: dict[str, Any] = {
        "token_type": TOKEN_TYPE_ACCESS,
        "role": role,
        "jti": _jti(),
        **(extra or {}),
    }
    return _create_jwt(
        subject=user_id,
        secret=_secret(),
        expires_in_seconds=ACCESS_TOKEN_EXPIRE_SECONDS,
        additional_claims=claims,
    )


def create_refresh_token(user_id: str, role: str, extra: dict[str, Any] | None = None) -> str:
    """Create a signed refresh JWT for the given user."""
    claims: dict[str, Any] = {
        "token_type": TOKEN_TYPE_REFRESH,
        "role": role,
        "jti": _jti(),
        **(extra or {}),
    }
    return _create_jwt(
        subject=user_id,
        secret=_secret(),
        expires_in_seconds=REFRESH_TOKEN_EXPIRE_SECONDS,
        additional_claims=claims,
    )


# ─── Token Decoding ──────────────────────────────────────────────────────────


def decode_access_token(token: str) -> dict[str, Any]:
    """Decode and validate an access token. Raises domain errors on failure."""
    try:
        payload = _decode_jwt(token, secret=_secret())
    except JWTExpiredError as e:
        raise TokenExpiredError("Access token has expired.") from e
    except JWTInvalidError as e:
        raise TokenInvalidError(str(e)) from e

    if payload.get("token_type") != TOKEN_TYPE_ACCESS:
        raise TokenInvalidError("Token is not an access token.")
    return payload


def decode_refresh_token(token: str) -> dict[str, Any]:
    """Decode and validate a refresh token. Raises domain errors on failure."""
    try:
        payload = _decode_jwt(token, secret=_secret())
    except JWTExpiredError as e:
        raise TokenExpiredError("Refresh token has expired.") from e
    except JWTInvalidError as e:
        raise TokenInvalidError(str(e)) from e

    if payload.get("token_type") != TOKEN_TYPE_REFRESH:
        raise TokenInvalidError("Token is not a refresh token.")
    return payload


# ─── Token Hashing ───────────────────────────────────────────────────────────


def hash_token(token: str) -> str:
    """SHA-256 hash of a raw token string — used to store refresh tokens safely."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def token_expires_at(expires_in_seconds: int) -> datetime:
    """Return an aware UTC datetime for token expiry."""
    import time
    return datetime.fromtimestamp(time.time() + expires_in_seconds, tz=timezone.utc)
