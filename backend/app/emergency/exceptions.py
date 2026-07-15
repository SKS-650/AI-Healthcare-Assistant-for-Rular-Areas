"""Emergency module custom exceptions."""

from __future__ import annotations

from fastapi import HTTPException, status


class EmergencyNotFoundError(HTTPException):
    def __init__(self, assessment_id: str) -> None:
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Emergency assessment '{assessment_id}' not found.",
        )


class EmergencyContactNotFoundError(HTTPException):
    def __init__(self, contact_id: str) -> None:
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Emergency contact '{contact_id}' not found.",
        )


class EmergencyContactLimitError(HTTPException):
    def __init__(self, limit: int) -> None:
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Maximum of {limit} emergency contacts allowed.",
        )


class SosCooldownError(HTTPException):
    def __init__(self, seconds_remaining: int) -> None:
        super().__init__(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"SOS was triggered recently. Please wait {seconds_remaining} seconds.",
        )


class InvalidSeverityLevelError(HTTPException):
    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Severity level must be between 1 and 5.",
        )


class UnauthorizedEmergencyAccessError(HTTPException):
    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this emergency record.",
        )
