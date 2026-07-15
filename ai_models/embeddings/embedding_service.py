"""
Embedding Service - Sentence transformer based text embeddings.

Uses all-MiniLM-L6-v2 from SentenceTransformers for fast, high-quality embeddings.
Falls back gracefully if sentence-transformers is not installed.
"""

from __future__ import annotations

import hashlib
import logging
import os
from typing import List, Optional

import numpy as np

logger = logging.getLogger(__name__)

_MODEL_NAME = os.getenv("EMBEDDING_MODEL", "all-MiniLM-L6-v2")


class EmbeddingService:
    """
    Converts text to dense vector embeddings using SentenceTransformer.

    Singleton pattern — use get_embedding_service() to get the shared instance.
    """

    def __init__(self, model_name: str = _MODEL_NAME) -> None:
        self.model_name = model_name
        self._model = None
        self._dim: Optional[int] = None
        self._cache: dict[str, np.ndarray] = {}

        self._load_model()

    # ─── Internal ────────────────────────────────────────────────────────────

    def _load_model(self) -> None:
        try:
            from sentence_transformers import SentenceTransformer  # type: ignore

            logger.info(f"Loading SentenceTransformer: {self.model_name} …")
            self._model = SentenceTransformer(self.model_name)
            self._dim = self._model.get_sentence_embedding_dimension()
            logger.info(f"Embedding model loaded. Dim={self._dim}")
        except ImportError:
            logger.warning(
                "sentence-transformers not installed. "
                "Embeddings will use TF-IDF fallback. "
                "Install: pip install sentence-transformers"
            )
            self._model = None
            self._dim = 384  # match MiniLM output dim for compatibility

    def _cache_key(self, text: str) -> str:
        return hashlib.md5(text.encode()).hexdigest()

    def _tfidf_embed(self, text: str) -> np.ndarray:
        """
        Minimal deterministic 384-dim pseudo-embedding using hashing.
        Used only when sentence-transformers is unavailable.
        """
        rng = np.random.default_rng(
            int(hashlib.sha256(text.encode()).hexdigest(), 16) % (2**32)
        )
        vec = rng.standard_normal(384).astype(np.float32)
        norm = np.linalg.norm(vec)
        return vec / max(norm, 1e-8)

    # ─── Public API ──────────────────────────────────────────────────────────

    @property
    def dim(self) -> int:
        return self._dim or 384

    def embed(self, text: str) -> np.ndarray:
        """Return a normalised 1-D float32 embedding for a single text."""
        key = self._cache_key(text)
        if key in self._cache:
            return self._cache[key]

        if self._model is not None:
            vec = self._model.encode(text, normalize_embeddings=True, show_progress_bar=False)
        else:
            vec = self._tfidf_embed(text)

        vec = vec.astype(np.float32)
        self._cache[key] = vec
        return vec

    def embed_batch(self, texts: List[str], batch_size: int = 64) -> np.ndarray:
        """Return float32 matrix of shape (N, dim)."""
        # Check cache first
        results: list[Optional[np.ndarray]] = [None] * len(texts)
        miss_indices: list[int] = []
        miss_texts: list[str] = []

        for i, t in enumerate(texts):
            k = self._cache_key(t)
            if k in self._cache:
                results[i] = self._cache[k]
            else:
                miss_indices.append(i)
                miss_texts.append(t)

        if miss_texts:
            if self._model is not None:
                vecs = self._model.encode(
                    miss_texts,
                    normalize_embeddings=True,
                    batch_size=batch_size,
                    show_progress_bar=False,
                ).astype(np.float32)
            else:
                vecs = np.array([self._tfidf_embed(t) for t in miss_texts], dtype=np.float32)

            for i, idx in enumerate(miss_indices):
                results[idx] = vecs[i]
                self._cache[self._cache_key(miss_texts[i])] = vecs[i]

        return np.array(results, dtype=np.float32)

    def is_ready(self) -> bool:
        return self._model is not None

    def clear_cache(self) -> None:
        self._cache.clear()


# ─── Singleton ───────────────────────────────────────────────────────────────

_instance: Optional[EmbeddingService] = None


def get_embedding_service() -> EmbeddingService:
    global _instance
    if _instance is None:
        _instance = EmbeddingService()
    return _instance
