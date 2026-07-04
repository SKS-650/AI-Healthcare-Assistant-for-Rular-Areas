"""Storage service."""

from __future__ import annotations

from pathlib import Path


class StorageService:
    """Service layer for file storage."""

    def build_upload_path(self, category: str, filename: str) -> Path:
        return Path("backend") / "app" / "uploads" / category / filename
