"""Password hashing utilities for the auth module.

Re-exports the core implementation from backend.app.security.password
and adds any auth-specific helpers.
"""

from __future__ import annotations

from backend.app.security.password import hash_password, verify_password

__all__ = ["hash_password", "verify_password"]
