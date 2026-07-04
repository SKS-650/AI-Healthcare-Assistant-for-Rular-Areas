"""Script to create the demo user for testing.

Run from project root:
    python -m backend.scripts.create_demo_user
"""

from __future__ import annotations

import asyncio
import pathlib
import sys

# ── ensure project root is on sys.path ───────────────────────────────────────
_project_root = str(pathlib.Path(__file__).resolve().parent.parent.parent)
if _project_root not in sys.path:
    sys.path.insert(0, _project_root)

# ── load .env ─────────────────────────────────────────────────────────────────
from dotenv import load_dotenv
load_dotenv(pathlib.Path(__file__).resolve().parent.parent / ".env", override=True)

from sqlalchemy import select
from backend.app.database.connection import _get_session_factory, init_db
from backend.app.auth.models import UserModel
from backend.app.security.password import hash_password
import uuid
from datetime import datetime, timezone


_DEMO_USERS = [
    {
        "email": "demo@health.ai",
        "password": "Password@1",
        "full_name": "Demo User",
        "role": "patient",
    },
    {
        "email": "admin@health.ai",
        "password": "Admin@123",
        "full_name": "Admin User",
        "role": "admin",
    },
]


async def main() -> None:
    await init_db()
    factory = _get_session_factory()

    async with factory() as session:
        for data in _DEMO_USERS:
            result = await session.execute(
                select(UserModel).where(UserModel.email == data["email"])
            )
            existing = result.scalar_one_or_none()
            if existing:
                print(f"  [SKIP] {data['email']} already exists (id={existing.id})")
                continue

            user = UserModel(
                id=str(uuid.uuid4()),
                full_name=data["full_name"],
                email=data["email"],
                phone=None,
                password_hash=hash_password(data["password"]),
                role=data["role"],
                language="en",
                is_active=True,
                email_verified=True,   # skip email verification for demo users
                phone_verified=False,
                created_at=datetime.now(timezone.utc),
                updated_at=datetime.now(timezone.utc),
            )
            session.add(user)
            print(f"  [CREATE] {data['email']} / {data['password']}  (role={data['role']})")

        await session.commit()
        print("\nDone.")


if __name__ == "__main__":
    asyncio.run(main())
