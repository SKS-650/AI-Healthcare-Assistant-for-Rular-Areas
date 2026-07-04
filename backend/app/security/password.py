"""backend/app/security/password.py

Password hashing utilities using only the Python standard library.

Implements
-----------
- PBKDF2-HMAC-SHA256
- Per-password random salt
- Format: pbkdf2_sha256$<iterations>$<salt_b64>$<hash_b64>

This is suitable for prototyping. For production, prefer a mature library
(e.g., passlib/bcrypt/argon2).
"""

from __future__ import annotations

import base64
import hashlib
import hmac
import os
from typing import Tuple


class PasswordHashError(ValueError):
    pass


def _b64e(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).decode("utf-8").rstrip("=")


def _b64d(s: str) -> bytes:
    padding = "=" * (-len(s) % 4)
    return base64.urlsafe_b64decode((s + padding).encode("utf-8"))


def hash_password(password: str, *, iterations: int = 200_000, salt_bytes: int = 16) -> str:
    """Hash a password and return the stored representation."""

    if password is None:
        raise PasswordHashError("Password must not be None")

    salt = os.urandom(salt_bytes)
    dk = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt,
        iterations,
    )

    return f"pbkdf2_sha256${iterations}${_b64e(salt)}${_b64e(dk)}"


def _parse_hash(stored: str) -> Tuple[int, bytes, bytes]:
    parts = (stored or "").split("$")
    if len(parts) != 4 or parts[0] != "pbkdf2_sha256":
        raise PasswordHashError("Invalid stored password hash format")

    try:
        iterations = int(parts[1])
        salt = _b64d(parts[2])
        digest = _b64d(parts[3])
    except Exception as e:  # noqa: BLE001
        raise PasswordHashError(f"Invalid stored password hash: {e}") from e

    return iterations, salt, digest


def verify_password(plain_password: str, stored_hash: str) -> bool:
    """Verify a plaintext password against a stored hash."""

    iterations, salt, digest = _parse_hash(stored_hash)

    candidate = hashlib.pbkdf2_hmac(
        "sha256",
        plain_password.encode("utf-8"),
        salt,
        iterations,
    )

    return hmac.compare_digest(candidate, digest)

