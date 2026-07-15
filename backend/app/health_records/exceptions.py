"""Medical Records module custom exceptions."""

from __future__ import annotations

from fastapi import HTTPException, status


class RecordNotFoundError(HTTPException):
    def __init__(self, record_id: str, record_type: str = "Record") -> None:
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{record_type} '{record_id}' not found.",
        )


class UnauthorizedRecordAccessError(HTTPException):
    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this medical record.",
        )


class FileTooLargeError(HTTPException):
    def __init__(self, max_mb: int = 20) -> None:
        super().__init__(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"File exceeds the maximum allowed size of {max_mb} MB.",
        )


class UnsupportedFileTypeError(HTTPException):
    def __init__(self, mime: str) -> None:
        super().__init__(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"File type '{mime}' is not supported. Allowed: PDF, PNG, JPG, JPEG, DOCX.",
        )


class MedicalProfileAlreadyExistsError(HTTPException):
    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            detail="A medical profile already exists for this user. Use PUT to update.",
        )
