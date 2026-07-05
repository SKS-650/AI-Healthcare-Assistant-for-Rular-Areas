"""FastAPI application factory for the backend package."""

from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config.settings import settings
from app.core.startup import initialize_application, on_shutdown, on_startup


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle: startup → yield → shutdown."""
    await on_startup()
    yield
    await on_shutdown()


def create_app() -> FastAPI:
    """Create and configure the FastAPI app."""

    initialize_application()

    app = FastAPI(
        title=settings.app_name,
        description="AI-powered healthcare assistant backend API",
        version="1.0.0",
        debug=settings.debug,
        lifespan=lifespan,
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
    )

    # ── CORS ──────────────────────────────────────────────────────────────────
    # In production set CORS_ORIGINS env var to your real frontend URL(s)
    import os
    cors_origins = os.getenv("CORS_ORIGINS", "*").split(",")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ── Static files (profile images, etc.) ──────────────────────────────────
    import pathlib
    uploads_dir = pathlib.Path(__file__).parent / "uploads"
    uploads_dir.mkdir(parents=True, exist_ok=True)
    app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")

    # ── Register routers ──────────────────────────────────────────────────────
    from app.auth.routes import router as auth_router
    from app.users.routes import router as users_router
    from app.symptom_checker.routes import router as symptom_checker_router

    app.include_router(auth_router, prefix=settings.api_prefix)
    app.include_router(users_router, prefix=settings.api_prefix)
    app.include_router(symptom_checker_router, prefix=settings.api_prefix)

    # ── Health check ──────────────────────────────────────────────────────────
    @app.get("/health", tags=["Health"])
    async def health_check() -> dict[str, str]:
        return {"status": "ok", "version": "1.0.0"}

    return app


app = create_app()
