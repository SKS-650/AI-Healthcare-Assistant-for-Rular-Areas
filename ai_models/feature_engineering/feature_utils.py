"""Shared feature engineering helpers."""

from __future__ import annotations


def safe_float(value: object, default: float = 0.0) -> float:
    """Convert a value to float with fallback."""

    try:
        return float(value)
    except (TypeError, ValueError):
        return default
