"""Data cleaning helpers for healthcare datasets."""

from __future__ import annotations

from typing import Any


def remove_empty_records(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Remove records that have no useful values."""

    return [record for record in records if any(value not in (None, "") for value in record.values())]


def normalize_text(value: str) -> str:
    """Normalize text fields used by symptom and disease datasets."""

    return " ".join(value.strip().lower().split())
