"""Application startup and shutdown orchestration."""

from __future__ import annotations

import logging
import pathlib

logger = logging.getLogger(__name__)


def initialize_application() -> None:
    """Synchronous setup — called before FastAPI app is created."""
    _load_env()                   # must be first
    _configure_logging()


def _load_env() -> None:
    """Load backend/.env into os.environ (python-dotenv)."""
    try:
        from dotenv import load_dotenv
        # Walk up to find backend/.env regardless of cwd
        candidates = [
            pathlib.Path(__file__).resolve().parent.parent.parent / ".env",  # backend/.env
            pathlib.Path.cwd() / "backend" / ".env",
            pathlib.Path.cwd() / ".env",
        ]
        for env_path in candidates:
            if env_path.exists():
                load_dotenv(dotenv_path=env_path, override=True)
                logger.debug("Loaded .env from %s", env_path)
                break
    except ImportError:
        pass  # python-dotenv not installed — rely on OS env vars


def _configure_logging() -> None:
    try:
        from backend.app.config.logging import configure_logging
        configure_logging()
    except Exception:
        import logging as _log
        _log.basicConfig(
            level=_log.INFO,
            format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
        )


async def on_startup() -> None:
    """Async tasks after server starts."""
    from backend.app.database.connection import init_db, _get_engine
    logger.info("Running startup tasks...")
    await init_db()

    # In development, auto-create all tables if they don't exist yet.
    # This avoids having to run alembic migrations manually during development.
    import os
    if os.getenv("ENVIRONMENT", "development").lower() in {"development", "test"}:
        try:
            # Import all models so SQLAlchemy knows every table
            import backend.app.auth.models   # noqa: F401
            import backend.app.users.models  # noqa: F401
            from backend.app.auth.models import Base
            engine = _get_engine()
            async with engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
            logger.info("Database tables created/verified (dev auto-create).")
        except Exception as e:
            logger.warning("Auto table creation failed (non-fatal): %s", e)

    logger.info("Startup complete.")


async def on_shutdown() -> None:
    """Async tasks on server shutdown."""
    from backend.app.database.connection import close_db
    logger.info("Shutting down...")
    await close_db()
    logger.info("Shutdown complete.")
