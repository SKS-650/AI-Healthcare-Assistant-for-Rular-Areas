"""Application settings."""

from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    """Runtime configuration loaded from environment variables."""

    app_name: str = "AI Healthcare Assistant API"
    environment: str = os.getenv("ENVIRONMENT", "development")
    api_prefix: str = os.getenv("API_PREFIX", "/api/v1")
    debug: bool = os.getenv("DEBUG", "false").lower() == "true"
    firebase_project_id: str | None = os.getenv("FIREBASE_PROJECT_ID")
    mongodb_url: str = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    jwt_secret_key: str = os.getenv("JWT_SECRET_KEY", "change-me")


settings = Settings()
