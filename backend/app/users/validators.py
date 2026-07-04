"""Business-rule validators for the User Management module.

These are plain functions — no FastAPI / Pydantic dependency —
so they can be called from the service layer as well as schema validators.
"""

from __future__ import annotations

import re
from datetime import date

from backend.app.users.constants import (
    BLOOD_GROUPS,
    GENDERS,
    MARITAL_STATUSES,
    MAX_HEIGHT_CM,
    MAX_WEIGHT_KG,
    MIN_HEIGHT_CM,
    MIN_WEIGHT_KG,
    RELATIONSHIPS,
    SUPPORTED_LANGUAGES,
)
from backend.app.users.exceptions import InvalidProfileDataError

_PHONE_RE = re.compile(r"^\+?[1-9]\d{7,14}$")
_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


# ─── Primitives ───────────────────────────────────────────────────────────────

def validate_phone(phone: str | None) -> str | None:
    """Validate E.164 phone format. Returns the value or raises."""
    if phone and not _PHONE_RE.match(phone):
        raise InvalidProfileDataError(
            "Phone must be in E.164 format (e.g. +919876543210)."
        )
    return phone


def validate_email(email: str | None) -> str | None:
    if email and not _EMAIL_RE.match(email):
        raise InvalidProfileDataError("Invalid email address format.")
    return email


def validate_language(language: str | None) -> str | None:
    if language and language not in SUPPORTED_LANGUAGES:
        raise InvalidProfileDataError(
            f"Language must be one of: {', '.join(SUPPORTED_LANGUAGES)}."
        )
    return language


# ─── Profile ──────────────────────────────────────────────────────────────────

def validate_date_of_birth(dob: date | None) -> date | None:
    """Date of birth must not be in the future."""
    if dob and dob > date.today():
        raise InvalidProfileDataError("Date of birth cannot be in the future.")
    return dob


def validate_gender(gender: str | None) -> str | None:
    if gender and gender.lower() not in GENDERS:
        raise InvalidProfileDataError(
            f"Gender must be one of: {', '.join(GENDERS)}."
        )
    return gender.lower() if gender else gender


def validate_blood_group(blood_group: str | None) -> str | None:
    if blood_group and blood_group.upper() not in BLOOD_GROUPS:
        raise InvalidProfileDataError(
            f"Blood group must be one of: {', '.join(BLOOD_GROUPS)}."
        )
    return blood_group.upper() if blood_group else blood_group


def validate_height(height_cm: float | None) -> float | None:
    if height_cm is not None and not (MIN_HEIGHT_CM <= height_cm <= MAX_HEIGHT_CM):
        raise InvalidProfileDataError(
            f"Height must be between {MIN_HEIGHT_CM} and {MAX_HEIGHT_CM} cm."
        )
    return height_cm


def validate_weight(weight_kg: float | None) -> float | None:
    if weight_kg is not None and not (MIN_WEIGHT_KG <= weight_kg <= MAX_WEIGHT_KG):
        raise InvalidProfileDataError(
            f"Weight must be between {MIN_WEIGHT_KG} and {MAX_WEIGHT_KG} kg."
        )
    return weight_kg


def validate_marital_status(status: str | None) -> str | None:
    if status and status.lower() not in MARITAL_STATUSES:
        raise InvalidProfileDataError(
            f"Marital status must be one of: {', '.join(MARITAL_STATUSES)}."
        )
    return status.lower() if status else status


# ─── Emergency Contact ────────────────────────────────────────────────────────

def validate_relationship(relationship: str) -> str:
    if relationship.lower() not in RELATIONSHIPS:
        raise InvalidProfileDataError(
            f"Relationship must be one of: {', '.join(RELATIONSHIPS)}."
        )
    return relationship.lower()


def validate_priority(priority: int) -> int:
    if priority < 1:
        raise InvalidProfileDataError("Priority must be a positive integer (1 = highest).")
    return priority


# ─── Address ──────────────────────────────────────────────────────────────────

def validate_coordinates(
    latitude: float | None, longitude: float | None
) -> tuple[float | None, float | None]:
    """If either coordinate is given, both must be present and in valid range."""
    if (latitude is None) != (longitude is None):
        raise InvalidProfileDataError(
            "Both latitude and longitude must be provided together."
        )
    if latitude is not None and not (-90.0 <= latitude <= 90.0):
        raise InvalidProfileDataError("Latitude must be between -90 and 90.")
    if longitude is not None and not (-180.0 <= longitude <= 180.0):
        raise InvalidProfileDataError("Longitude must be between -180 and 180.")
    return latitude, longitude
