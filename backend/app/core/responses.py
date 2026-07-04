"""Response helpers."""

from __future__ import annotations

from typing import Any


def success_response(data: Any = None, message: str = "success") -> dict[str, Any]:
    """Return a consistent success response payload."""

    return {"status": "success", "message": message, "data": data}


def error_response(message: str, code: str = "error") -> dict[str, Any]:
    """Return a consistent error response payload."""

    return {"status": "error", "code": code, "message": message}
