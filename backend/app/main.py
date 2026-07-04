"""FastAPI application factory for the backend package."""

from __future__ import annotations

from fastapi import FastAPI

from backend.app.config.settings import settings
from backend.app.core.startup import initialize_application


def create_app() -> FastAPI:
    """Create and configure the FastAPI app."""

    initialize_application()
    app = FastAPI(title=settings.app_name, debug=settings.debug)

    @app.get("/health")
    def health_check() -> dict[str, str]:
        return {"status": "ok"}

    return app


app = create_app()
