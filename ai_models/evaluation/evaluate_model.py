"""Model evaluation entrypoint."""

from __future__ import annotations

from ai_models.evaluation.metrics import accuracy_score


def evaluate(y_true: list[str], y_pred: list[str]) -> dict[str, float]:
    """Evaluate predictions with basic metrics."""

    return {"accuracy": accuracy_score(y_true, y_pred)}
