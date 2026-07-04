"""Validation helpers."""

from __future__ import annotations

import re


EMAIL_PATTERN = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def is_valid_email(email: str) -> bool:
    """Return whether an email address has a valid basic format."""

    return bool(EMAIL_PATTERN.match(email))
