"""Dataset balancing helpers."""

from __future__ import annotations

from collections import defaultdict
from typing import Any


def group_by_label(records: list[dict[str, Any]], label_key: str) -> dict[str, list[dict[str, Any]]]:
    """Group records by their label value."""

    groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for record in records:
        groups[str(record.get(label_key, "unknown"))].append(record)
    return dict(groups)
