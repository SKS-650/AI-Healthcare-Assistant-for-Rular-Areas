"""Evaluation metrics."""

from __future__ import annotations


def accuracy_score(y_true: list[object], y_pred: list[object]) -> float:
    """Calculate classification accuracy."""

    if not y_true:
        return 0.0
    matches = sum(1 for expected, actual in zip(y_true, y_pred) if expected == actual)
    return matches / len(y_true)
