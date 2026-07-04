"""Vector retrieval helpers."""

from __future__ import annotations

from ai_models.embeddings.similarity_search import cosine_similarity
from ai_models.vector_database.vector_store import VectorStore


def retrieve_nearest(store: VectorStore, query: list[float]) -> tuple[str | None, float]:
    """Retrieve the nearest vector key."""

    best_key: str | None = None
    best_score = -1.0
    for key, vector in store.vectors.items():
        score = cosine_similarity(query, vector)
        if score > best_score:
            best_key = key
            best_score = score
    return best_key, best_score
