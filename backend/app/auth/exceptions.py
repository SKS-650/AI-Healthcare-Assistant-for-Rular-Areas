"""Custom exceptions for the authentication module."""

from __future__ import annotations

from fastapi import HTTPException, status


# ─── Base ────────────────────────────────────────────────────────────────────


class AuthError(Exception):
    """Base class for authentication errors."""


# ─── Registration ────────────────────────────────────────────────────────────


class EmailAlreadyExistsError(AuthError):
    """Raised when trying to register with an email already in use."""


class PhoneAlreadyExistsError(AuthError):
    """Raised when trying to register with a phone number already in use."""


class WeakPasswordError(AuthError):
    """Raised when the password does not meet strength requirements."""


# ─── Login / Credentials ─────────────────────────────────────────────────────


class InvalidCredentialsError(AuthError):
    """Raised when email/password combination is incorrect."""


class AccountInactiveError(AuthError):
    """Raised when the account has been disabled."""


class AccountNotVerifiedError(AuthError):
    """Raised when the account email has not been verified yet."""


# ─── Token ───────────────────────────────────────────────────────────────────


class TokenExpiredError(AuthError):
    """Raised when a JWT token has expired."""


class TokenInvalidError(AuthError):
    """Raised when a JWT token is malformed or signature is wrong."""


class TokenRevokedError(AuthError):
    """Raised when a token has been explicitly revoked (blacklisted)."""


class RefreshTokenNotFoundError(AuthError):
    """Raised when the refresh token is not found in the store."""


# ─── OTP ─────────────────────────────────────────────────────────────────────


class OTPExpiredError(AuthError):
    """Raised when the OTP has expired."""


class OTPInvalidError(AuthError):
    """Raised when the OTP value is wrong."""


class OTPMaxAttemptsError(AuthError):
    """Raised when too many wrong OTP attempts have been made."""


class OTPNotFoundError(AuthError):
    """Raised when no active OTP exists for the given target."""


# ─── Email / Phone Verification ──────────────────────────────────────────────


class EmailVerificationExpiredError(AuthError):
    """Raised when the email verification token has expired."""


class EmailAlreadyVerifiedError(AuthError):
    """Raised when email is already verified."""


class PhoneVerificationExpiredError(AuthError):
    """Raised when the phone verification OTP has expired."""


class PhoneAlreadyVerifiedError(AuthError):
    """Raised when phone is already verified."""


# ─── Password Reset ──────────────────────────────────────────────────────────


class PasswordResetTokenExpiredError(AuthError):
    """Raised when the password-reset token has expired."""


class PasswordResetTokenInvalidError(AuthError):
    """Raised when the password-reset token is invalid or already used."""


# ─── Session ─────────────────────────────────────────────────────────────────


class SessionExpiredError(AuthError):
    """Raised when the user session has expired."""


class SessionNotFoundError(AuthError):
    """Raised when the session ID is not found."""


# ─── Permissions ─────────────────────────────────────────────────────────────


class InsufficientPermissionsError(AuthError):
    """Raised when a user lacks the required permission."""


class InvalidRoleError(AuthError):
    """Raised when an unknown/invalid role is assigned."""


# ─── HTTP helpers ────────────────────────────────────────────────────────────


def auth_error_to_http(error: AuthError) -> HTTPException:
    """Convert a domain AuthError into a FastAPI HTTPException."""

    mapping: dict[type[AuthError], tuple[int, str]] = {
        EmailAlreadyExistsError: (status.HTTP_409_CONFLICT, "Email already registered."),
        PhoneAlreadyExistsError: (status.HTTP_409_CONFLICT, "Phone number already registered."),
        WeakPasswordError: (status.HTTP_422_UNPROCESSABLE_ENTITY, str(error) or "Password is too weak."),
        InvalidCredentialsError: (status.HTTP_401_UNAUTHORIZED, "Invalid email or password."),
        AccountInactiveError: (status.HTTP_403_FORBIDDEN, "Account is disabled."),
        AccountNotVerifiedError: (status.HTTP_403_FORBIDDEN, "Email not verified."),
        TokenExpiredError: (status.HTTP_401_UNAUTHORIZED, "Token has expired."),
        TokenInvalidError: (status.HTTP_401_UNAUTHORIZED, "Token is invalid."),
        TokenRevokedError: (status.HTTP_401_UNAUTHORIZED, "Token has been revoked."),
        RefreshTokenNotFoundError: (status.HTTP_401_UNAUTHORIZED, "Refresh token not found."),
        OTPExpiredError: (status.HTTP_400_BAD_REQUEST, "OTP has expired."),
        OTPInvalidError: (status.HTTP_400_BAD_REQUEST, "Invalid OTP."),
        OTPMaxAttemptsError: (status.HTTP_429_TOO_MANY_REQUESTS, "Too many OTP attempts. Request a new one."),
        OTPNotFoundError: (status.HTTP_404_NOT_FOUND, "No active OTP found."),
        EmailVerificationExpiredError: (status.HTTP_400_BAD_REQUEST, "Email verification link has expired."),
        EmailAlreadyVerifiedError: (status.HTTP_400_BAD_REQUEST, "Email is already verified."),
        PhoneVerificationExpiredError: (status.HTTP_400_BAD_REQUEST, "Phone verification OTP has expired."),
        PhoneAlreadyVerifiedError: (status.HTTP_400_BAD_REQUEST, "Phone is already verified."),
        PasswordResetTokenExpiredError: (status.HTTP_400_BAD_REQUEST, "Password reset link has expired."),
        PasswordResetTokenInvalidError: (status.HTTP_400_BAD_REQUEST, "Invalid or already used reset link."),
        SessionExpiredError: (status.HTTP_401_UNAUTHORIZED, "Session has expired."),
        SessionNotFoundError: (status.HTTP_401_UNAUTHORIZED, "Session not found."),
        InsufficientPermissionsError: (status.HTTP_403_FORBIDDEN, "Insufficient permissions."),
        InvalidRoleError: (status.HTTP_422_UNPROCESSABLE_ENTITY, "Invalid role."),
    }

    status_code, detail = mapping.get(type(error), (status.HTTP_500_INTERNAL_SERVER_ERROR, "Authentication error."))
    return HTTPException(status_code=status_code, detail=detail)
