"""
FAISS Engine - Production vector database for semantic search.

Indexes MedQuAD + DiseaseSymptomPrediction datasets for offline
knowledge retrieval without needing an LLM call.
"""

from __future__ import annotations

import json
import logging
import os
import pickle
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import numpy as np

logger = logging.getLogger(__name__)


@dataclass
class IndexedDocument:
    """A document stored inside the FAISS index."""

    doc_id: str
    text: str
    answer: Optional[str] = None
    category: str = "general"
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class SearchResult:
    """A single search result from FAISS retrieval."""

    doc: IndexedDocument
    score: float  # cosine similarity (0–1, higher = more similar)
    rank: int


class FAISSEngine:
    """
    FAISS-backed semantic search engine.

    Usage
    -----
    engine = FAISSEngine()
    engine.build_index(documents, embeddings)  # once
    engine.save(index_dir)                     # persist
    engine.load(index_dir)                     # restore
    results = engine.search("What is diabetes?", top_k=3)
    """

    def __init__(self, dim: int = 384) -> None:
        self.dim = dim
        self._index = None          # faiss.Index
        self._documents: List[IndexedDocument] = []
        self._is_loaded = False

    # ─── Build ────────────────────────────────────────────────────────────────

    def build_index(
        self, documents: List[IndexedDocument], embeddings: np.ndarray
    ) -> None:
        """
        Build a flat L2 index (with inner-product normalisation = cosine).

        Parameters
        ----------
        documents:  list of IndexedDocument objects
        embeddings: float32 matrix shape (N, dim)
        """
        if len(documents) != embeddings.shape[0]:
            raise ValueError("documents and embeddings must have the same length")

        try:
            import faiss  # type: ignore
        except ImportError:
            logger.error(
                "faiss-cpu is not installed. "
                "Install it with: pip install faiss-cpu"
            )
            raise

        if embeddings.dtype != np.float32:
            embeddings = embeddings.astype(np.float32)

        # Normalise rows → cosine via inner product search
        faiss.normalize_L2(embeddings)

        index = faiss.IndexFlatIP(self.dim)  # Inner Product = cosine after norm
        index.add(embeddings)  # type: ignore[arg-type]

        self._index = index
        self._documents = documents
        self._is_loaded = True

        logger.info(f"FAISS index built: {index.ntotal} vectors, dim={self.dim}")

    # ─── Persist ──────────────────────────────────────────────────────────────

    def save(self, directory: str | Path) -> None:
        """Persist index + documents to disk."""
        import faiss  # type: ignore

        directory = Path(directory)
        directory.mkdir(parents=True, exist_ok=True)

        faiss.write_index(self._index, str(directory / "index.faiss"))

        with open(directory / "documents.pkl", "wb") as f:
            pickle.dump(self._documents, f)

        # Also write a human-readable manifest
        manifest = {
            "dim": self.dim,
            "total": len(self._documents),
            "categories": list({d.category for d in self._documents}),
        }
        with open(directory / "manifest.json", "w") as f:
            json.dump(manifest, f, indent=2)

        logger.info(f"FAISS index saved to {directory}. Total: {len(self._documents)}")

    def load(self, directory: str | Path) -> bool:
        """Load persisted index. Returns True on success."""
        import faiss  # type: ignore

        directory = Path(directory)
        index_path = directory / "index.faiss"
        docs_path = directory / "documents.pkl"

        if not index_path.exists() or not docs_path.exists():
            logger.warning(f"FAISS index not found at {directory}")
            return False

        try:
            self._index = faiss.read_index(str(index_path))
            with open(docs_path, "rb") as f:
                self._documents = pickle.load(f)

            # Read manifest for dim
            manifest_path = directory / "manifest.json"
            if manifest_path.exists():
                with open(manifest_path) as f:
                    manifest = json.load(f)
                self.dim = manifest.get("dim", self.dim)

            self._is_loaded = True
            logger.info(
                f"FAISS index loaded from {directory}. "
                f"Vectors: {self._index.ntotal}, dim={self.dim}"
            )
            return True

        except Exception as exc:
            logger.error(f"Failed to load FAISS index: {exc}", exc_info=True)
            return False

    # ─── Search ───────────────────────────────────────────────────────────────

    def search(
        self,
        query_embedding: np.ndarray,
        top_k: int = 5,
        min_score: float = 0.30,
        category_filter: Optional[str] = None,
    ) -> List[SearchResult]:
        """
        Search for top-k most similar documents.

        Parameters
        ----------
        query_embedding: 1-D float32 array of length dim
        top_k:           number of results
        min_score:       minimum cosine similarity threshold (0–1)
        category_filter: if set, only return documents of that category

        Returns
        -------
        List of SearchResult sorted by score desc
        """
        if not self._is_loaded or self._index is None:
            return []

        import faiss  # type: ignore

        q = query_embedding.astype(np.float32).reshape(1, -1)
        faiss.normalize_L2(q)

        # Fetch extra to account for category filter
        fetch_k = min(top_k * 4, self._index.ntotal)
        scores, ids = self._index.search(q, fetch_k)  # type: ignore[arg-type]

        results: List[SearchResult] = []
        for rank, (idx, score) in enumerate(zip(ids[0], scores[0])):
            if idx < 0 or float(score) < min_score:
                continue
            doc = self._documents[idx]
            if category_filter and doc.category != category_filter:
                continue
            results.append(SearchResult(doc=doc, score=float(score), rank=rank))
            if len(results) >= top_k:
                break

        return results

    # ─── Helpers ──────────────────────────────────────────────────────────────

    @property
    def is_loaded(self) -> bool:
        return self._is_loaded

    @property
    def total_documents(self) -> int:
        return len(self._documents) if self._documents else 0

    def get_stats(self) -> Dict[str, Any]:
        if not self._is_loaded:
            return {"loaded": False}
        cats: Dict[str, int] = {}
        for d in self._documents:
            cats[d.category] = cats.get(d.category, 0) + 1
        return {
            "loaded": True,
            "total_documents": self.total_documents,
            "dim": self.dim,
            "categories": cats,
        }


# ─── Singleton ────────────────────────────────────────────────────────────────

_instance: Optional[FAISSEngine] = None


def get_faiss_engine() -> FAISSEngine:
    global _instance
    if _instance is None:
        _instance = FAISSEngine()
    return _instance
