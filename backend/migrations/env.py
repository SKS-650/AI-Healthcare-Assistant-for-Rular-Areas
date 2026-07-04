"""Alembic migration environment — async SQLAlchemy (asyncpg)."""

from __future__ import annotations

import asyncio
import pathlib
import sys
from logging.config import fileConfig

from alembic import context
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import create_async_engine

# ── sys.path: add project root so `import backend` works ─────────────────────
# Layout:  <project_root>/backend/migrations/env.py
_project_root = str(pathlib.Path(__file__).resolve().parent.parent.parent)
if _project_root not in sys.path:
    sys.path.insert(0, _project_root)

# ── Load backend/.env before importing settings ───────────────────────────────
try:
    from dotenv import load_dotenv
    _env_file = pathlib.Path(__file__).resolve().parent.parent / ".env"
    if _env_file.exists():
        load_dotenv(dotenv_path=_env_file, override=True)
except ImportError:
    pass

# ── Import all ORM models so Alembic sees every table ─────────────────────────
import backend.app.auth.models   # noqa: F401
import backend.app.users.models  # noqa: F401

from backend.app.auth.models import Base
from backend.app.config.settings import Settings

# Re-read settings after loading .env
_settings = Settings()

# Ensure asyncpg driver
_db_url: str = _settings.database_url
if not _db_url.startswith("postgresql+asyncpg"):
    _db_url = _db_url.replace("postgresql://", "postgresql+asyncpg://", 1)

# ── Alembic Config ────────────────────────────────────────────────────────────
config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# NOTE: We do NOT call config.set_main_option("sqlalchemy.url", ...) here
# because % characters in passwords cause configparser interpolation errors.
# Instead we pass the URL directly to create_async_engine() below.

target_metadata = Base.metadata


# ─── Offline mode (generates SQL without a live connection) ───────────────────

def run_migrations_offline() -> None:
    context.configure(
        url=_db_url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


# ─── Online (async) mode ──────────────────────────────────────────────────────

def do_run_migrations(connection: Connection) -> None:
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    # Build engine directly from URL — bypasses alembic.ini entirely
    engine = create_async_engine(_db_url, poolclass=pool.NullPool, echo=False)
    async with engine.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await engine.dispose()


def run_migrations_online() -> None:
    asyncio.run(run_async_migrations())


# ─── Entry point ──────────────────────────────────────────────────────────────

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
