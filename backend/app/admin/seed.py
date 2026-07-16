"""
Admin seed script.

Creates a default super_admin account and seeds system settings.

Usage (from backend/ directory):
    python -m app.admin.seed
"""

from __future__ import annotations

import asyncio
import os
import sys

# Ensure the backend/ directory is on sys.path when run directly
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", ".."))

# ── Load .env before any app imports ─────────────────────────────────────────
import pathlib
try:
    from dotenv import load_dotenv
    for _candidate in [
        pathlib.Path(__file__).resolve().parent.parent.parent / ".env",
        pathlib.Path.cwd() / ".env",
    ]:
        if _candidate.exists():
            load_dotenv(dotenv_path=_candidate, override=True)
            break
except ImportError:
    pass

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

# ── Import ALL models so SQLAlchemy relationship resolution succeeds ──────────
import app.auth.models                           # UserModel + token tables
import app.users.models                          # UserProfileModel etc.
import app.symptom_checker.models                # SymptomCheckHistory
import app.medical_chatbot.database.models       # Conversation, Message, etc.
import app.emergency.models                      # EmergencyAssessment, SosEvent
import app.health_records.models                 # MedicalHistory, Prescription
import app.health_education.models               # HealthArticle, HealthCategory
import app.admin.models                          # AdminActivityLog, SystemSetting
import app.notifications.models                  # UserNotification

from app.auth.models import UserModel
from app.admin.service import SystemSettingsService
from app.security.password import hash_password

# ─── Default admin credentials (override via env) ────────────────────────────
ADMIN_EMAIL    = os.getenv("ADMIN_EMAIL",    "admin@healthcare.ai")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "Admin@123456")
ADMIN_NAME     = os.getenv("ADMIN_NAME",     "System Administrator")


async def seed_admin(db: AsyncSession) -> None:
    existing = (await db.execute(
        select(UserModel).where(UserModel.email == ADMIN_EMAIL)
    )).scalar_one_or_none()

    if existing:
        print(f"[seed] Admin already exists: {ADMIN_EMAIL}")
        if existing.role != "super_admin":
            existing.role = "super_admin"
            await db.commit()
            print("[seed] Updated role → super_admin.")
        else:
            print("[seed] Role is already super_admin. Nothing to change.")
        return

    admin = UserModel(
        full_name=ADMIN_NAME,
        email=ADMIN_EMAIL,
        password_hash=hash_password(ADMIN_PASSWORD),
        role="super_admin",
        is_active=True,
        email_verified=True,
        phone_verified=False,
        language="en",
    )
    db.add(admin)
    await db.commit()
    print(f"[seed] ✓ Created super_admin: {ADMIN_EMAIL}  /  {ADMIN_PASSWORD}")


async def seed_settings(db: AsyncSession) -> None:
    await SystemSettingsService.seed_defaults(db)
    print("[seed] ✓ System settings seeded.")


async def run_seed() -> None:
    # Create all missing tables first
    from app.database.connection import _get_engine, _get_session_factory
    from app.auth.models import Base

    engine = _get_engine()
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("[seed] ✓ Database tables verified / created.")

    factory = _get_session_factory()
    async with factory() as db:
        await seed_admin(db)
        await seed_settings(db)
    print("[seed] Done.")


if __name__ == "__main__":
    asyncio.run(run_seed())
