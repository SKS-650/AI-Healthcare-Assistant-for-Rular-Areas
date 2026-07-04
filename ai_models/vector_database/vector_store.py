"""Vector store abstraction."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class VectorStore:
    """In-memory vector store for development."""

    vectors: dict[str, list[float]] = field(default_factory=dict)

    def upsert(self, key: str, vector: list[float]) -> None:
        """Insert or update a vector."""

        self.vectors[key] = vector
