"""Email service."""

from __future__ import annotations


class EmailService:
    """Service layer for email notifications."""

    def send_email(self, to_email: str, subject: str, body: str) -> dict[str, str]:
        return {"status": "mocked", "to": to_email, "subject": subject}
