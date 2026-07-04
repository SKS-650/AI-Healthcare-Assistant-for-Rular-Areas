"""Model report helpers."""

from __future__ import annotations

from typing import Any


def create_model_report(metrics: dict[str, Any]) -> dict[str, Any]:
    """Create a serializable model report."""

    return {"status": "generated", "metrics": metrics}
