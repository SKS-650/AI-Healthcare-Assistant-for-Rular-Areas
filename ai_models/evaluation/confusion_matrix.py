"""Confusion matrix helpers."""

from __future__ import annotations


def build_confusion_matrix(y_true: list[str], y_pred: list[str]) -> dict[str, dict[str, int]]:
    """Build a simple label-based confusion matrix."""

    matrix: dict[str, dict[str, int]] = {}
    labels = sorted(set(y_true) | set(y_pred))
    for label in labels:
        matrix[label] = {predicted: 0 for predicted in labels}
    for expected, actual in zip(y_true, y_pred):
        matrix.setdefault(expected, {}).setdefault(actual, 0)
        matrix[expected][actual] += 1
    return matrix
