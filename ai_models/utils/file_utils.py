"""File helpers for AI modules."""

from __future__ import annotations

from pathlib import Path


def ensure_parent_dir(path: str | Path) -> Path:
    """Create a file path parent directory if needed."""

    file_path = Path(path)
    file_path.parent.mkdir(parents=True, exist_ok=True)
    return file_path
