"""Authentication-related constants."""

from __future__ import annotations

# Token lifetimes (seconds)
ACCESS_TOKEN_EXPIRE_SECONDS: int = 15 * 60          # 15 minutes
REFRESH_TOKEN_EXPIRE_SECONDS: int = 30 * 24 * 60 * 60  # 30 days

# OTP
OTP_LENGTH: int = 6
OTP_EXPIRE_SECONDS: int = 10 * 60  # 10 minutes
OTP_MAX_ATTEMPTS: int = 5

# Email / phone verification
EMAIL_VERIFICATION_EXPIRE_SECONDS: int = 24 * 60 * 60   # 24 hours
PHONE_VERIFICATION_EXPIRE_SECONDS: int = 10 * 60        # 10 minutes

# Password reset
PASSWORD_RESET_EXPIRE_SECONDS: int = 60 * 60  # 1 hour
PASSWORD_RESET_TOKEN_BYTES: int = 32

# Session
SESSION_EXPIRE_SECONDS: int = 30 * 24 * 60 * 60  # 30 days

# Roles
class Role:
    PATIENT = "patient"
    DOCTOR = "doctor"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"

ALL_ROLES: tuple[str, ...] = (Role.PATIENT, Role.DOCTOR, Role.ADMIN, Role.SUPER_ADMIN)

# Permissions
class Permission:
    READ_OWN_RECORDS = "read:own_records"
    WRITE_OWN_RECORDS = "write:own_records"
    READ_ANY_RECORDS = "read:any_records"
    WRITE_ANY_RECORDS = "write:any_records"
    MANAGE_USERS = "manage:users"
    MANAGE_SYSTEM = "manage:system"
    VIEW_ANALYTICS = "view:analytics"
    MANAGE_DOCTORS = "manage:doctors"

# Default permissions per role
ROLE_PERMISSIONS: dict[str, list[str]] = {
    Role.PATIENT: [
        Permission.READ_OWN_RECORDS,
        Permission.WRITE_OWN_RECORDS,
    ],
    Role.DOCTOR: [
        Permission.READ_OWN_RECORDS,
        Permission.WRITE_OWN_RECORDS,
        Permission.READ_ANY_RECORDS,
        Permission.VIEW_ANALYTICS,
    ],
    Role.ADMIN: [
        Permission.READ_OWN_RECORDS,
        Permission.WRITE_OWN_RECORDS,
        Permission.READ_ANY_RECORDS,
        Permission.WRITE_ANY_RECORDS,
        Permission.MANAGE_USERS,
        Permission.VIEW_ANALYTICS,
        Permission.MANAGE_DOCTORS,
    ],
    Role.SUPER_ADMIN: [
        Permission.READ_OWN_RECORDS,
        Permission.WRITE_OWN_RECORDS,
        Permission.READ_ANY_RECORDS,
        Permission.WRITE_ANY_RECORDS,
        Permission.MANAGE_USERS,
        Permission.MANAGE_SYSTEM,
        Permission.VIEW_ANALYTICS,
        Permission.MANAGE_DOCTORS,
    ],
}

# Token type claim values
TOKEN_TYPE_ACCESS = "access"
TOKEN_TYPE_REFRESH = "refresh"
TOKEN_TYPE_EMAIL_VERIFY = "email_verify"
TOKEN_TYPE_PHONE_VERIFY = "phone_verify"
TOKEN_TYPE_PASSWORD_RESET = "password_reset"
