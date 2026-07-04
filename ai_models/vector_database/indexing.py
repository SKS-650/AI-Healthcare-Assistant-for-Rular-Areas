"""Vector indexing helpers."""

from __future__ import annotations

from ai_models.vector_database.vector_store import VectorStore


def build_index(items: dict[str, list[float]]) -> VectorStore:
    """Build an in-memory vector index."""

    store = VectorStore()
    for key, vector in items.items():
        store.upsert(key, vector)
    return store
