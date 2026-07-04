"""General AI model helpers."""

from __future__ import annotations

from uuid import uuid4


def generate_run_id() -> str:
    """Generate a unique model run id."""

    return str(uuid4())
