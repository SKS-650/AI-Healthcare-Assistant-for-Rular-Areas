"""Application settings — loaded from environment variables.

.env is loaded by startup.py BEFORE this module is used.
All values are read via os.getenv() at access time so they always
reflect the current environment, even if .env is loaded after import.
"""

from __future__ import annotations

import os


class Settings:
    """Reads every value directly from os.environ at access time."""

    # ── App ───────────────────────────────────────────────────────────────────
    @property
    def app_name(self) -> str:
        return os.getenv("APP_NAME", "AI Healthcare Assistant API")

    @property
    def environment(self) -> str:
        return os.getenv("ENVIRONMENT", "development")

    @property
    def api_prefix(self) -> str:
        return os.getenv("API_PREFIX", "/api/v1")

    @property
    def debug(self) -> bool:
        return os.getenv("DEBUG", "false").lower() == "true"

    @property
    def app_base_url(self) -> str:
        return os.getenv("APP_BASE_URL", "http://localhost:8000")

    # ── Database ──────────────────────────────────────────────────────────────
    @property
    def database_url(self) -> str:
        url = os.getenv(
            "DATABASE_URL",
            "postgresql+asyncpg://postgres:postgres@localhost:5432/healthcare_db",
        )
        # Ensure asyncpg driver
        if url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+asyncpg://", 1)
        return url

    @property
    def mongodb_url(self) -> str:
        return os.getenv("MONGODB_URL", "mongodb://localhost:27017")

    @property
    def redis_url(self) -> str:
        return os.getenv("REDIS_URL", "redis://localhost:6379/0")

    # ── JWT ───────────────────────────────────────────────────────────────────
    @property
    def jwt_secret_key(self) -> str:
        return os.getenv("JWT_SECRET_KEY", "change-me")

    @property
    def jwt_algorithm(self) -> str:
        return os.getenv("JWT_ALGORITHM", "HS256")

    # ── Firebase ──────────────────────────────────────────────────────────────
    @property
    def firebase_project_id(self) -> str | None:
        return os.getenv("FIREBASE_PROJECT_ID") or None

    # ── Email (SMTP) ──────────────────────────────────────────────────────────
    @property
    def smtp_host(self) -> str:
        return os.getenv("SMTP_HOST", "smtp.gmail.com")

    @property
    def smtp_port(self) -> int:
        return int(os.getenv("SMTP_PORT", "587"))

    @property
    def smtp_user(self) -> str | None:
        return os.getenv("SMTP_USER") or None

    @property
    def smtp_password(self) -> str | None:
        return os.getenv("SMTP_PASSWORD") or None

    @property
    def smtp_from(self) -> str:
        return os.getenv("SMTP_FROM", "noreply@healthcareai.com")

    # ── SMS ───────────────────────────────────────────────────────────────────
    @property
    def sms_provider(self) -> str:
        return os.getenv("SMS_PROVIDER", "mock")

    @property
    def twilio_account_sid(self) -> str | None:
        return os.getenv("TWILIO_ACCOUNT_SID") or None

    @property
    def twilio_auth_token(self) -> str | None:
        return os.getenv("TWILIO_AUTH_TOKEN") or None

    @property
    def twilio_from_number(self) -> str | None:
        return os.getenv("TWILIO_FROM_NUMBER") or None


# Singleton — safe because all values are read from os.environ on every access
settings = Settings()
