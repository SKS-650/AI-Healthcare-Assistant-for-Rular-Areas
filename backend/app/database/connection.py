"""Async SQLAlchemy database session factory (lazy engine init)."""

from __future__ import annotations

import logging
from collections.abc import AsyncGenerator
from typing import Any

from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

logger = logging.getLogger(__name__)

_engine: AsyncEngine | None = None
_AsyncSessionLocal: async_sessionmaker | None = None


def _get_engine() -> AsyncEngine:
    global _engine
    if _engine is None:
        from app.config.settings import settings
        db_url = settings.database_url
        if db_url.startswith("postgresql://"):
            db_url = db_url.replace("postgresql://", "postgresql+asyncpg://", 1)

        engine_kwargs: dict[str, Any] = {
            "echo": settings.debug,
        }
        if db_url.startswith("sqlite"):
            engine_kwargs["connect_args"] = {"check_same_thread": False}
        else:
            engine_kwargs.update({
                "pool_pre_ping": True,
                "pool_size": 5,
                "max_overflow": 10,
            })

        _engine = create_async_engine(db_url, **engine_kwargs)
    return _engine


def _get_session_factory() -> async_sessionmaker:
    global _AsyncSessionLocal
    if _AsyncSessionLocal is None:
        _AsyncSessionLocal = async_sessionmaker(
            bind=_get_engine(),
            class_=AsyncSession,
            expire_on_commit=False,
            autoflush=False,
            autocommit=False,
        )
    return _AsyncSessionLocal


# ─── FastAPI dependency ───────────────────────────────────────────────────────

async def get_async_session() -> AsyncGenerator[AsyncSession, None]:
    async with _get_session_factory()() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


# Alias for backward compatibility
get_session = get_async_session


# ─── Lifecycle ────────────────────────────────────────────────────────────────

async def init_db() -> None:
    """Verify DB connectivity on startup. Tables are managed by Alembic."""
    from sqlalchemy import text

    try:
        async with _get_engine().connect() as conn:
            await conn.execute(text("SELECT 1"))
        logger.info("Database connection verified.")
    except Exception as e:
        logger.warning("Database connection check failed: %s", e)
        raise


async def close_db() -> None:
    global _engine
    if _engine:
        await _engine.dispose()
        _engine = None
        logger.info("Database engine disposed.")


# ─── Legacy compat ────────────────────────────────────────────────────────────

class DatabaseConnections:
    firebase: Any = None
    mongodb: Any = None
    redis: Any = None

connections = DatabaseConnections()
