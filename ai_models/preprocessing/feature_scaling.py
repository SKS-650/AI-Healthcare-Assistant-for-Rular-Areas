"""Feature scaling helpers."""

from __future__ import annotations


def min_max_scale(values: list[float]) -> list[float]:
    """Scale numeric values to the range 0..1."""

    if not values:
        return []
    minimum = min(values)
    maximum = max(values)
    if minimum == maximum:
        return [0.0 for _ in values]
    return [(value - minimum) / (maximum - minimum) for value in values]
