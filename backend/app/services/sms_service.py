"""SMS service."""

from __future__ import annotations


class SmsService:
    """Service layer for SMS notifications."""

    def send_sms(self, phone_number: str, message: str) -> dict[str, str]:
        return {"status": "mocked", "to": phone_number, "message": message}
