"""Startup orchestration."""

from __future__ import annotations

from backend.app.config.logging import configure_logging


def initialize_application() -> None:
    """Initialize app-level services."""

    configure_logging()
