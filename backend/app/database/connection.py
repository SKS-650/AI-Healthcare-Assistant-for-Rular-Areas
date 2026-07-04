"""Database connection orchestration."""

from __future__ import annotations

from typing import Any


class DatabaseConnections:
    """Container for database clients initialized by the application."""

    firebase: Any = None
    mongodb: Any = None
    redis: Any = None


connections = DatabaseConnections()
