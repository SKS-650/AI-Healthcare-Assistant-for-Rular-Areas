"""
Pytest fixtures shared across the entire test suite.

Uses SQLite (aiosqlite) so no PostgreSQL is needed during testing.
"""

from __future__ import annotations

import asyncio
import sys
from collections.abc import AsyncGenerator
from pathlib import Path
from typing import Any

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

BACKEND_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = BACKEND_ROOT.parent
for path in (REPO_ROOT, BACKEND_ROOT):
    path_str = str(path)
    if path_str not in sys.path:
        sys.path.insert(0, path_str)

# ─── In-memory SQLite engine (test isolation) ─────────────────────────────────

TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

test_engine = create_async_engine(TEST_DATABASE_URL, echo=False)
TestSessionLocal = async_sessionmaker(
    bind=test_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
)


@pytest_asyncio.fixture(scope="session", autouse=True)
async def create_tables():
    """Create all ORM tables once per test session."""
    import app.auth.models  # noqa: F401
    import app.users.models  # noqa: F401
    import app.symptom_checker.models  # noqa: F401
    from app.auth.models import Base

    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest_asyncio.fixture()
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    """Yield a fresh session that rolls back after each test."""
    async with TestSessionLocal() as session:
        yield session
        await session.rollback()


# ─── FastAPI test client ───────────────────────────────────────────────────────


@pytest_asyncio.fixture()
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """HTTP test client wired to the test database."""
    from app.database.connection import get_async_session
    from app.main import app

    # Override the DB dependency with the test session
    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_async_session] = override_get_db

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac

    app.dependency_overrides.clear()


# ─── Helpers ──────────────────────────────────────────────────────────────────

REGISTER_PAYLOAD = {
    "full_name": "Test User",
    "email": "test@example.com",
    "phone": "+919876543210",
    "password": "SecurePass@123",
    "confirm_password": "SecurePass@123",
    "role": "patient",
    "language": "en",
}


async def register_and_verify(client: AsyncClient) -> dict:
    """Register a user and manually mark email as verified, return user data."""
    r = await client.post("/api/v1/auth/register", json=REGISTER_PAYLOAD)
    assert r.status_code == 201, r.text
    data = r.json()

    # Manually mark email verified in DB (bypasses email flow in tests)
    from app.auth import repository as auth_repo
    from app.database.connection import get_async_session

    # Use the actual DB override from conftest
    async for session in get_async_session():
        await auth_repo.set_email_verified(session, data["user_id"])
        await session.commit()

    return data
