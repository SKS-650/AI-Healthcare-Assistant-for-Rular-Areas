"""Inference utility helpers."""

from __future__ import annotations


def format_confidence(value: float) -> str:
    """Format a confidence score as a percentage string."""

    return f"{value * 100:.1f}%"
