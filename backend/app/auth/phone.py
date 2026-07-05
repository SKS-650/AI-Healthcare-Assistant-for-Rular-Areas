"""SMS delivery for authentication flows.

Wraps the shared SmsService and provides auth-specific helpers
(phone OTP / verification SMS).
"""

from __future__ import annotations

import logging
from string import Template

from app.services.sms_service import SmsService

logger = logging.getLogger(__name__)

_sms_service = SmsService()

# ─── Templates ───────────────────────────────────────────────────────────────

_OTP_TEMPLATE = Template(
    "[$app_name] Your OTP is $otp. "
    "Valid for 10 minutes. Do not share with anyone."
)

_APP_NAME = "AI Healthcare"


# ─── Public helpers ──────────────────────────────────────────────────────────


def send_phone_otp(phone: str, otp: str) -> None:
    """Send an OTP SMS to the given phone number."""
    message = _OTP_TEMPLATE.substitute(app_name=_APP_NAME, otp=otp)
    result = _sms_service.send_sms(phone_number=phone, message=message)
    logger.info("Phone OTP sent to %s — status: %s", _mask_phone(phone), result.get("status"))


# ─── Utility ─────────────────────────────────────────────────────────────────


def _mask_phone(phone: str) -> str:
    """Mask a phone number for safe logging (e.g., +9198*****210)."""
    if len(phone) <= 5:
        return "***"
    return phone[:4] + "*" * (len(phone) - 7) + phone[-3:]
