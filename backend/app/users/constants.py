"""Constants for the User Management module."""

from __future__ import annotations

# ─── Roles ────────────────────────────────────────────────────────────────────

class UserRole:
    PATIENT = "patient"
    DOCTOR = "doctor"
    HEALTH_WORKER = "health_worker"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"

ALL_ROLES: tuple[str, ...] = (
    UserRole.PATIENT,
    UserRole.DOCTOR,
    UserRole.HEALTH_WORKER,
    UserRole.ADMIN,
    UserRole.SUPER_ADMIN,
)

# ─── Blood Groups ─────────────────────────────────────────────────────────────

BLOOD_GROUPS: tuple[str, ...] = ("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")

# ─── Gender ──────────────────────────────────────────────────────────────────

GENDERS: tuple[str, ...] = ("male", "female", "other", "prefer_not_to_say")

# ─── Marital Status ──────────────────────────────────────────────────────────

MARITAL_STATUSES: tuple[str, ...] = ("single", "married", "divorced", "widowed", "separated")

# ─── Languages ───────────────────────────────────────────────────────────────

SUPPORTED_LANGUAGES: tuple[str, ...] = (
    "en",    # English
    "hi",    # Hindi
    "ne",    # Nepali
    "bho",   # Bhojpuri
    "bn",    # Bengali
    "te",    # Telugu
    "mr",    # Marathi
    "ta",    # Tamil
    "gu",    # Gujarati
    "kn",    # Kannada
    "pa",    # Punjabi
    "other", # Other
)

# ─── Address ─────────────────────────────────────────────────────────────────

MAX_ADDRESSES_PER_USER: int = 5

ADDRESS_TYPES: tuple[str, ...] = ("home", "work", "other")

# ─── Emergency Contacts ──────────────────────────────────────────────────────

MAX_EMERGENCY_CONTACTS_PER_USER: int = 5

RELATIONSHIPS: tuple[str, ...] = (
    "father", "mother", "spouse", "sibling", "child",
    "friend", "relative", "guardian", "other",
)

# ─── Profile Image ───────────────────────────────────────────────────────────

ALLOWED_IMAGE_EXTENSIONS: tuple[str, ...] = (".jpg", ".jpeg", ".png", ".webp")
MAX_PROFILE_IMAGE_SIZE_MB: int = 5

# ─── Validation ──────────────────────────────────────────────────────────────

MIN_HEIGHT_CM: float = 30.0
MAX_HEIGHT_CM: float = 300.0
MIN_WEIGHT_KG: float = 1.0
MAX_WEIGHT_KG: float = 500.0
