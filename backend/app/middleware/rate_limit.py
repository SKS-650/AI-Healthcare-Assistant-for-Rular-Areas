"""Rate limiting middleware placeholder."""

from __future__ import annotations

from starlette.middleware.base import BaseHTTPMiddleware


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Placeholder middleware for rate limiting."""

    async def dispatch(self, request, call_next):
        return await call_next(request)
