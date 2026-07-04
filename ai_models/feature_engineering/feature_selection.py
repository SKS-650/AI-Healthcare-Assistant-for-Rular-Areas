"""Feature selection helpers."""

from __future__ import annotations

from typing import Any


def select_features(record: dict[str, Any], feature_names: list[str]) -> dict[str, Any]:
    """Return only selected features from a record."""

    return {name: record.get(name) for name in feature_names}
