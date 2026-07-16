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
        from app.config.logging import configure_logging
        configure_logging()
    except Exception:
        import logging as _log
        _log.basicConfig(
            level=_log.INFO,
            format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
        )


async def on_startup() -> None:
    """Async tasks after server starts."""
    from app.database.connection import init_db, _get_engine
    logger.info("Running startup tasks...")

    try:
        await init_db()
    except Exception as e:
        logger.warning("Database initialization skipped during startup: %s", e)

    # In development, auto-create all tables if they don't exist yet.
    import os
    if os.getenv("ENVIRONMENT", "development").lower() in {"development", "test"}:
        try:
            import app.auth.models   # noqa: F401
            import app.users.models  # noqa: F401
            import app.symptom_checker.models  # noqa: F401
            # Chatbot tables — import models so metadata is populated
            import app.medical_chatbot.database.models  # noqa: F401
            # Emergency tables
            import app.emergency.models  # noqa: F401
            # Medical Records (PHR) tables
            import app.health_records.models  # noqa: F401
            # Health Education tables
            import app.health_education.models  # noqa: F401
            # Admin tables
            import app.admin.models  # noqa: F401
            from app.auth.models import Base
            engine = _get_engine()
            async with engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
            logger.info("Database tables created/verified (dev auto-create).")
            # Auto-seed admin defaults
            try:
                from app.database.connection import _get_session_factory
                from app.admin.service import SystemSettingsService
                factory = _get_session_factory()
                async with factory() as db:
                    await SystemSettingsService.seed_defaults(db)
                logger.info("System settings seeded.")
            except Exception as seed_err:
                logger.warning("Settings seed skipped: %s", seed_err)
        except Exception as e:
            logger.warning("Auto table creation failed (non-fatal): %s", e)

    # ── Validate symptom checker model on every startup ──────────────────
    _validate_symptom_model()

    logger.info("Startup complete.")


def _validate_symptom_model() -> None:
    """Ensure the loaded symptom checker model has exactly 230 features.

    If the model is not loaded or has wrong feature count, log a clear error
    so the operator knows to restart after running train_large_dataset.py.
    This prevents the '15 vs 230 features' runtime error reaching users.
    """
    try:
        from app.symptom_checker.service import symptom_checker_service
        if not symptom_checker_service.is_model_loaded():
            logger.error(
                "Symptom checker model failed to load on startup. "
                "Run train_large_dataset.py then restart the server."
            )
            return

        n = len(symptom_checker_service.predictor.feature_names)
        expected = 230
        if n != expected:
            logger.error(
                "STARTUP MISMATCH: symptom model has %d features, expected %d. "
                "Artifacts were likely overwritten by the legacy train.py. "
                "Re-run train_large_dataset.py, then restart.", n, expected
            )
            # Force a fresh reload from disk to pick up any corrected artifacts
            symptom_checker_service.reload_model()
            n2 = len(symptom_checker_service.predictor.feature_names)
            if n2 == expected:
                logger.info("Model reloaded successfully: %d features.", n2)
            else:
                logger.error(
                    "Reload still has %d features. "
                    "Please regenerate artifacts with train_large_dataset.py.", n2
                )
        else:
            logger.info(
                "Symptom checker model OK: %d features, %d diseases.",
                n, len(symptom_checker_service._get_classes())
            )
    except Exception as e:
        logger.warning("Could not validate symptom checker model: %s", e)


async def on_shutdown() -> None:
    """Async tasks on server shutdown."""
    from app.database.connection import close_db
    logger.info("Shutting down...")
    await close_db()
    logger.info("Shutdown complete.")
