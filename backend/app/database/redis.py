"""Redis client helpers.

Provides a cached (async) Redis client.
"""

from __future__ import annotations

import os
from typing import Any


_redis_client: Any = None


def get_redis_client() -> Any:
    """Return a cached redis.asyncio client.

    Env vars:
      - REDIS_URL (default: redis://localhost:6379/0)
    """

    global _redis_client
    if _redis_client is not None:
        return _redis_client

    try:
        # redis-py >= 4 provides asyncio under redis.asyncio
        import redis.asyncio as redis_asyncio
    except ImportError as e:
        raise RuntimeError(
            "redis is not installed. Add it to backend/requirements.txt to use Redis."
        ) from e

    redis_url = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    _redis_client = redis_asyncio.from_url(redis_url, decode_responses=True)
    return _redis_client

