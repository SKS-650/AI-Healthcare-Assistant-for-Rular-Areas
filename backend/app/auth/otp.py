"""OTP generation and verification utilities."""

from __future__ import annotations

import hashlib
import hmac
import os
import secrets
import string

from backend.app.auth.constants import OTP_LENGTH


def generate_otp(length: int = OTP_LENGTH) -> str:
    """Generate a cryptographically secure numeric OTP."""
    return "".join(secrets.choice(string.digits) for _ in range(length))


def hash_otp(otp: str) -> str:
    """Hash an OTP value for safe storage (SHA-256)."""
    return hashlib.sha256(otp.encode("utf-8")).hexdigest()


def verify_otp(plain_otp: str, stored_hash: str) -> bool:
    """Timing-safe comparison of a plain OTP against a stored hash."""
    candidate_hash = hash_otp(plain_otp)
    return hmac.compare_digest(candidate_hash, stored_hash)


def generate_secure_token(nbytes: int = 32) -> str:
    """Generate a URL-safe secure random token (for email/password-reset links)."""
    return secrets.token_urlsafe(nbytes)


def hash_secure_token(token: str) -> str:
    """Hash a secure token for storage."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def verify_secure_token(plain_token: str, stored_hash: str) -> bool:
    """Timing-safe comparison of a token against its stored hash."""
    candidate_hash = hash_secure_token(plain_token)
    return hmac.compare_digest(candidate_hash, stored_hash)
