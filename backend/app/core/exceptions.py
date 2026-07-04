"""Custom application exceptions."""

from __future__ import annotations


class AppError(Exception):
    """Base exception for application-specific errors."""


class NotFoundError(AppError):
    """Raised when a requested resource does not exist."""


class PermissionDeniedError(AppError):
    """Raised when a user cannot access a resource."""
