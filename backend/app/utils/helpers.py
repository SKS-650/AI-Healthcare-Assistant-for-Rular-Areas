"""General utility helpers."""

from __future__ import annotations

from uuid import uuid4


def generate_id() -> str:
    """Generate a unique string id."""

    return str(uuid4())
