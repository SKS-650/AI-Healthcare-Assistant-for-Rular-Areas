"""Embedding generation helpers."""

from __future__ import annotations


def generate_embedding(text: str, dimensions: int = 8) -> list[float]:
    """Generate a deterministic placeholder embedding."""

    seed = sum(ord(char) for char in text)
    return [float((seed + index) % 10) / 10.0 for index in range(dimensions)]
