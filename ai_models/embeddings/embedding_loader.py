"""Embedding loader helpers."""

from __future__ import annotations

from pathlib import Path


def load_embeddings(path: str | Path) -> dict[str, list[float]]:
    """Load embeddings placeholder."""

    return {"source": [float(len(str(path)))]}
