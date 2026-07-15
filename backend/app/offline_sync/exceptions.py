"""Custom exceptions for the offline_sync module."""

from fastapi import HTTPException, status


class SyncConflictError(HTTPException):
    def __init__(self, detail: str = "Sync conflict detected"):
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            detail=detail,
        )


class SyncUnavailableError(HTTPException):
    def __init__(self, detail: str = "Sync service temporarily unavailable"):
        super().__init__(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=detail,
        )


class InvalidPayloadError(HTTPException):
    def __init__(self, detail: str = "Invalid sync payload"):
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=detail,
        )
