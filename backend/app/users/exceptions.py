"""Custom exceptions for the User Management module."""

from __future__ import annotations

from fastapi import HTTPException, status


# ─── Base ─────────────────────────────────────────────────────────────────────

class UserError(Exception):
    """Base exception for user management errors."""


# ─── User ─────────────────────────────────────────────────────────────────────

class UserNotFoundError(UserError):
    """Raised when a user cannot be found by the given identifier."""


class UserAlreadyExistsError(UserError):
    """Raised when trying to create a user that already exists."""


class UserInactiveError(UserError):
    """Raised when trying to operate on a deactivated user."""


# ─── Profile ──────────────────────────────────────────────────────────────────

class ProfileNotFoundError(UserError):
    """Raised when a user profile record does not exist."""


class ProfileAlreadyExistsError(UserError):
    """Raised when trying to create a profile that already exists."""


class InvalidProfileDataError(UserError):
    """Raised when profile data fails business-rule validation."""


# ─── Address ──────────────────────────────────────────────────────────────────

class AddressNotFoundError(UserError):
    """Raised when an address record cannot be found."""


class AddressLimitExceededError(UserError):
    """Raised when the user has reached the maximum number of addresses."""


class AddressOwnershipError(UserError):
    """Raised when a user tries to modify another user's address."""


# ─── Emergency Contacts ───────────────────────────────────────────────────────

class EmergencyContactNotFoundError(UserError):
    """Raised when an emergency contact record cannot be found."""


class EmergencyContactLimitExceededError(UserError):
    """Raised when the user has reached the maximum number of emergency contacts."""


class EmergencyContactOwnershipError(UserError):
    """Raised when a user tries to modify another user's contact."""


# ─── Medical Information ──────────────────────────────────────────────────────

class MedicalInfoNotFoundError(UserError):
    """Raised when the medical information record does not exist."""


class MedicalInfoAlreadyExistsError(UserError):
    """Raised when trying to create medical info that already exists."""


# ─── Profile Image ────────────────────────────────────────────────────────────

class InvalidImageTypeError(UserError):
    """Raised when the uploaded file is not an allowed image type."""


class ImageTooLargeError(UserError):
    """Raised when the uploaded image exceeds the size limit."""


# ─── Account Status ───────────────────────────────────────────────────────────

class CannotDeactivateSelfError(UserError):
    """Raised when an admin tries to deactivate their own account."""


# ─── HTTP helpers ─────────────────────────────────────────────────────────────

def user_error_to_http(error: UserError) -> HTTPException:
    """Convert a domain UserError into a FastAPI HTTPException."""

    mapping: dict[type[UserError], tuple[int, str]] = {
        UserNotFoundError: (status.HTTP_404_NOT_FOUND, str(error) or "User not found."),
        UserAlreadyExistsError: (status.HTTP_409_CONFLICT, str(error) or "User already exists."),
        UserInactiveError: (status.HTTP_403_FORBIDDEN, "User account is inactive."),
        ProfileNotFoundError: (status.HTTP_404_NOT_FOUND, "Profile not found."),
        ProfileAlreadyExistsError: (status.HTTP_409_CONFLICT, "Profile already exists."),
        InvalidProfileDataError: (status.HTTP_422_UNPROCESSABLE_ENTITY, str(error) or "Invalid profile data."),
        AddressNotFoundError: (status.HTTP_404_NOT_FOUND, "Address not found."),
        AddressLimitExceededError: (status.HTTP_400_BAD_REQUEST, str(error) or "Address limit reached."),
        AddressOwnershipError: (status.HTTP_403_FORBIDDEN, "You do not own this address."),
        EmergencyContactNotFoundError: (status.HTTP_404_NOT_FOUND, "Emergency contact not found."),
        EmergencyContactLimitExceededError: (status.HTTP_400_BAD_REQUEST, str(error) or "Contact limit reached."),
        EmergencyContactOwnershipError: (status.HTTP_403_FORBIDDEN, "You do not own this contact."),
        MedicalInfoNotFoundError: (status.HTTP_404_NOT_FOUND, "Medical information not found."),
        MedicalInfoAlreadyExistsError: (status.HTTP_409_CONFLICT, "Medical information already exists."),
        InvalidImageTypeError: (status.HTTP_415_UNSUPPORTED_MEDIA_TYPE, str(error) or "Invalid image type."),
        ImageTooLargeError: (status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, str(error) or "Image too large."),
        CannotDeactivateSelfError: (status.HTTP_400_BAD_REQUEST, "You cannot deactivate your own account."),
    }

    status_code, detail = mapping.get(
        type(error), (status.HTTP_500_INTERNAL_SERVER_ERROR, "User management error.")
    )
    return HTTPException(status_code=status_code, detail=detail)
