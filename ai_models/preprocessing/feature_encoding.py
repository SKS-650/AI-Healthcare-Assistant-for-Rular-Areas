"""Feature encoding helpers."""

from __future__ import annotations


def one_hot_encode(value: str, categories: list[str]) -> dict[str, int]:
    """Encode a category as a one-hot dictionary."""

    return {category: int(value == category) for category in categories}
