"""Redis cache helpers."""

from __future__ import annotations

from typing import Any


class RedisCache:
    """Small wrapper around a Redis client."""

    def __init__(self, client: Any = None) -> None:
        self.client = client

    def get(self, key: str) -> Any:
        if self.client is None:
            return None
        return self.client.get(key)

    def set(self, key: str, value: Any, ttl_seconds: int | None = None) -> None:
        if self.client is not None:
            self.client.set(key, value, ex=ttl_seconds)
