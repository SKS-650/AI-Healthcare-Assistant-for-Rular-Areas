"""Validation helpers for AI modules."""

from __future__ import annotations


def has_required_fields(record: dict[str, object], fields: list[str]) -> bool:
    """Check whether a record has all required fields."""

    return all(field in record and record[field] not in (None, "") for field in fields)
