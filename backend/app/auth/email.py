"""Email delivery for authentication flows.

Wraps the shared EmailService and provides auth-specific helpers
(verification links, OTP emails, password-reset emails).
"""

from __future__ import annotations

import logging
from string import Template

from app.services.email_service import EmailService

logger = logging.getLogger(__name__)

_email_service = EmailService()

# ─── Templates ───────────────────────────────────────────────────────────────

_VERIFY_EMAIL_SUBJECT = "Verify your AI Healthcare Assistant account"
_VERIFY_EMAIL_BODY = Template(
    "Hi $full_name,\n\n"
    "Please verify your email by clicking the link below:\n\n"
    "$verify_url\n\n"
    "This link expires in 24 hours.\n\n"
    "If you didn't create an account, please ignore this email.\n\n"
    "— AI Healthcare Assistant Team"
)

_OTP_SUBJECT = "Your AI Healthcare Assistant OTP"
_OTP_BODY = Template(
    "Hi $full_name,\n\n"
    "Your one-time password (OTP) is:\n\n"
    "    $otp\n\n"
    "It expires in 10 minutes. Do not share it with anyone.\n\n"
    "— AI Healthcare Assistant Team"
)

_PASSWORD_RESET_SUBJECT = "Reset your AI Healthcare Assistant password"
_PASSWORD_RESET_BODY = Template(
    "Hi $full_name,\n\n"
    "We received a request to reset your password. Click the link below:\n\n"
    "$reset_url\n\n"
    "This link expires in 1 hour.\n\n"
    "If you did not request a password reset, please ignore this email.\n\n"
    "— AI Healthcare Assistant Team"
)


# ─── Public helpers ──────────────────────────────────────────────────────────


def send_email_verification(to_email: str, full_name: str, verify_url: str) -> None:
    """Send an email-verification link to the user."""
    body = _VERIFY_EMAIL_BODY.substitute(full_name=full_name, verify_url=verify_url)
    result = _email_service.send_email(
        to_email=to_email,
        subject=_VERIFY_EMAIL_SUBJECT,
        body=body,
    )
    logger.info("Email verification sent to %s — status: %s", to_email, result.get("status"))


def send_otp_email(to_email: str, full_name: str, otp: str) -> None:
    """Send a plain-text OTP to the user's email."""
    body = _OTP_BODY.substitute(full_name=full_name, otp=otp)
    result = _email_service.send_email(
        to_email=to_email,
        subject=_OTP_SUBJECT,
        body=body,
    )
    logger.info("OTP email sent to %s — status: %s", to_email, result.get("status"))


def send_password_reset_email(to_email: str, full_name: str, reset_url: str) -> None:
    """Send a password-reset link to the user."""
    body = _PASSWORD_RESET_BODY.substitute(full_name=full_name, reset_url=reset_url)
    result = _email_service.send_email(
        to_email=to_email,
        subject=_PASSWORD_RESET_SUBJECT,
        body=body,
    )
    logger.info("Password reset email sent to %s — status: %s", to_email, result.get("status"))
