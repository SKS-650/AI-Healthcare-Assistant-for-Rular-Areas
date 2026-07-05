"""Business logic for the authentication module.

Each public method maps to one user-facing auth operation.
The service never touches HTTP — it only raises domain exceptions.
"""

from __future__ import annotations

import logging
import os
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import repository as repo
from app.auth.constants import (
    ACCESS_TOKEN_EXPIRE_SECONDS,
    EMAIL_VERIFICATION_EXPIRE_SECONDS,
    OTP_EXPIRE_SECONDS,
    OTP_MAX_ATTEMPTS,
    PASSWORD_RESET_EXPIRE_SECONDS,
    PHONE_VERIFICATION_EXPIRE_SECONDS,
    REFRESH_TOKEN_EXPIRE_SECONDS,
)
from app.auth.email import (
    send_email_verification,
    send_otp_email,
    send_password_reset_email,
)
from app.auth.exceptions import (
    AccountInactiveError,
    AccountNotVerifiedError,
    EmailAlreadyExistsError,
    EmailAlreadyVerifiedError,
    EmailVerificationExpiredError,
    InvalidCredentialsError,
    OTPExpiredError,
    OTPInvalidError,
    OTPMaxAttemptsError,
    OTPNotFoundError,
    PasswordResetTokenExpiredError,
    PasswordResetTokenInvalidError,
    PhoneAlreadyExistsError,
    PhoneAlreadyVerifiedError,
    PhoneVerificationExpiredError,
    RefreshTokenNotFoundError,
    TokenRevokedError,
)
from app.auth.jwt_handler import (
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
    hash_token,
    token_expires_at,
)
from app.auth.models import (
    EmailVerificationModel,
    OTPCodeModel,
    PasswordResetModel,
    PhoneVerificationModel,
    RefreshTokenModel,
    UserModel,
    UserSessionModel,
)
from app.auth.otp import (
    generate_otp,
    generate_secure_token,
    hash_otp,
    hash_secure_token,
    verify_otp,
    verify_secure_token,
)
from app.auth.password import hash_password, verify_password
from app.auth.phone import send_phone_otp
from app.auth.session import (
    create_session_record,
    invalidate_session,
    touch_session,
    validate_session,
)
from app.config.settings import settings

logger = logging.getLogger(__name__)

# Base URL for email links — read from env or default to localhost for dev
_BASE_URL = os.getenv("APP_BASE_URL", "http://localhost:8000")
_EMAIL_VERIFICATION_REQUIRED = os.getenv(
    "EMAIL_VERIFICATION_REQUIRED",
    "false" if settings.environment.lower() in {"development", "test"} else "true",
).lower() == "true"


# ─── Registration ─────────────────────────────────────────────────────────────


async def register_user(
    db: AsyncSession,
    full_name: str,
    email: str,
    phone: str | None,
    password: str,
    role: str = "patient",
    language: str = "en",
) -> UserModel:
    """Register a new user account and trigger email + phone verification."""

    email = email.lower().strip()

    # Check for duplicates
    if await repo.get_user_by_email(db, email):
        raise EmailAlreadyExistsError(f"Email already registered: {email}")
    if phone and await repo.get_user_by_phone(db, phone):
        raise PhoneAlreadyExistsError(f"Phone already registered: {phone}")

    user = UserModel(
        id=str(uuid.uuid4()),
        full_name=full_name,
        email=email,
        phone=phone,
        password_hash=hash_password(password),
        role=role,
        language=language,
        is_active=True,
        email_verified=False,
        phone_verified=False,
    )
    await repo.create_user(db, user)

    # Send email verification
    await _send_email_verification(db, user)

    # If phone provided, send OTP immediately
    if phone:
        await _send_phone_otp(db, user, phone)

    return user


# ─── Email Verification ──────────────────────────────────────────────────────


async def _send_email_verification(db: AsyncSession, user: UserModel) -> None:
    """Internal: create and email a verification token."""
    raw_token = generate_secure_token()
    token_hash = hash_secure_token(raw_token)
    expires_at = datetime.now(timezone.utc) + timedelta(seconds=EMAIL_VERIFICATION_EXPIRE_SECONDS)

    ev = EmailVerificationModel(
        id=str(uuid.uuid4()),
        user_id=user.id,
        token_hash=token_hash,
        expires_at=expires_at,
    )
    await repo.save_email_verification(db, ev)

    verify_url = f"{_BASE_URL}/api/v1/auth/verify-email?token={raw_token}"
    send_email_verification(
        to_email=user.email,
        full_name=user.full_name,
        verify_url=verify_url,
    )


async def verify_email_token(db: AsyncSession, raw_token: str) -> None:
    """Verify the user's email using the token from the link."""
    token_hash = hash_secure_token(raw_token)
    ev = await repo.get_email_verification_by_hash(db, token_hash)

    if ev is None:
        raise EmailVerificationExpiredError("Email verification link is invalid or has expired.")

    user = await repo.get_user_by_id(db, ev.user_id)
    if user and user.email_verified:
        raise EmailAlreadyVerifiedError("Email is already verified.")

    await repo.mark_email_verification_used(db, ev.id)
    await repo.set_email_verified(db, ev.user_id)


async def resend_email_verification(db: AsyncSession, email: str) -> None:
    """Resend a verification email to the user."""
    user = await repo.get_user_by_email(db, email)
    if user is None:
        return  # Silent — don't reveal whether email exists
    if user.email_verified:
        raise EmailAlreadyVerifiedError("Email is already verified.")
    await _send_email_verification(db, user)


# ─── Phone Verification ──────────────────────────────────────────────────────


async def _send_phone_otp(db: AsyncSession, user: UserModel, phone: str) -> None:
    """Internal: create and SMS an OTP for phone verification."""
    otp = generate_otp()
    otp_hash = hash_otp(otp)
    expires_at = datetime.now(timezone.utc) + timedelta(seconds=PHONE_VERIFICATION_EXPIRE_SECONDS)

    pv = PhoneVerificationModel(
        id=str(uuid.uuid4()),
        user_id=user.id,
        phone=phone,
        code_hash=otp_hash,
        expires_at=expires_at,
    )
    await repo.save_phone_verification(db, pv)
    send_phone_otp(phone=phone, otp=otp)


async def send_phone_verification_otp(db: AsyncSession, user_id: str, phone: str) -> None:
    """Send a phone-verification OTP to the given number."""
    user = await repo.get_user_by_id(db, user_id)
    if not user:
        raise InvalidCredentialsError("User not found.")
    if user.phone_verified:
        raise PhoneAlreadyVerifiedError("Phone is already verified.")
    await _send_phone_otp(db, user, phone)


async def verify_phone_otp(db: AsyncSession, user_id: str, otp: str) -> None:
    """Verify a phone OTP entered by the user."""
    pv = await repo.get_latest_phone_verification(db, user_id)

    if pv is None:
        raise OTPNotFoundError("No active phone OTP found.")

    now = datetime.now(timezone.utc)
    expires = pv.expires_at if pv.expires_at.tzinfo else pv.expires_at.replace(tzinfo=timezone.utc)
    if now >= expires:
        raise OTPExpiredError("Phone OTP has expired.")

    if pv.attempts >= OTP_MAX_ATTEMPTS:
        raise OTPMaxAttemptsError("Too many OTP attempts.")

    if not verify_otp(otp, pv.code_hash):
        pv.attempts += 1
        raise OTPInvalidError("Invalid OTP.")

    await repo.mark_phone_verification_used(db, pv.id)
    await repo.set_phone_verified(db, user_id)


# ─── OTP (general — e.g. 2FA / login OTP) ───────────────────────────────────


async def send_login_otp(db: AsyncSession, user: UserModel) -> None:
    """Send a 2FA OTP via email."""
    otp = generate_otp()
    otp_hash = hash_otp(otp)
    expires_at = datetime.now(timezone.utc) + timedelta(seconds=OTP_EXPIRE_SECONDS)

    otp_record = OTPCodeModel(
        id=str(uuid.uuid4()),
        user_id=user.id,
        purpose="login_2fa",
        code_hash=otp_hash,
        expires_at=expires_at,
    )
    await repo.save_otp(db, otp_record)
    send_otp_email(to_email=user.email, full_name=user.full_name, otp=otp)


async def verify_login_otp(db: AsyncSession, user_id: str, otp: str) -> None:
    """Verify a login 2FA OTP."""
    otp_record = await repo.get_latest_otp(db, user_id, "login_2fa")

    if otp_record is None:
        raise OTPNotFoundError("No active OTP found.")

    if otp_record.attempts >= OTP_MAX_ATTEMPTS:
        raise OTPMaxAttemptsError("Too many OTP attempts.")

    if not verify_otp(otp, otp_record.code_hash):
        await repo.increment_otp_attempts(db, otp_record.id)
        raise OTPInvalidError("Invalid OTP.")

    await repo.mark_otp_used(db, otp_record.id)


# ─── Login ───────────────────────────────────────────────────────────────────


async def login(
    db: AsyncSession,
    email: str,
    password: str,
    device_info: str | None = None,
    ip_address: str | None = None,
) -> tuple[str, str, UserModel]:
    """
    Authenticate a user and return (access_token, refresh_token, user).
    Raises domain exceptions on failure.
    """
    email = email.lower().strip()
    user = await repo.get_user_by_email(db, email)

    if user is None or not verify_password(password, user.password_hash):
        raise InvalidCredentialsError("Invalid email or password.")

    if not user.is_active:
        raise AccountInactiveError("Account is disabled.")

    if not user.email_verified and _EMAIL_VERIFICATION_REQUIRED:
        raise AccountNotVerifiedError("Please verify your email before logging in.")

    # Generate tokens
    access_token = create_access_token(user_id=user.id, role=user.role)
    raw_refresh = create_refresh_token(user_id=user.id, role=user.role)
    refresh_hash = hash_token(raw_refresh)

    rt = RefreshTokenModel(
        id=str(uuid.uuid4()),
        user_id=user.id,
        token_hash=refresh_hash,
        device_info=device_info,
        ip_address=ip_address,
        expires_at=token_expires_at(REFRESH_TOKEN_EXPIRE_SECONDS),
    )
    await repo.save_refresh_token(db, rt)

    # Create session
    session = create_session_record(
        user_id=user.id,
        refresh_token_id=rt.id,
        device_info=device_info,
        ip_address=ip_address,
    )
    await repo.save_session(db, session)

    # Update last login
    await repo.update_user_last_login(db, user.id)

    return access_token, raw_refresh, user


# ─── Token Refresh ───────────────────────────────────────────────────────────


async def refresh_access_token(
    db: AsyncSession, raw_refresh_token: str
) -> tuple[str, UserModel]:
    """
    Validate a refresh token and issue a new access token.
    Returns (new_access_token, user).
    """
    payload = decode_refresh_token(raw_refresh_token)  # raises TokenExpiredError / TokenInvalidError

    token_hash = hash_token(raw_refresh_token)
    rt = await repo.get_refresh_token_by_hash(db, token_hash)

    if rt is None:
        raise RefreshTokenNotFoundError("Refresh token not found.")
    if rt.is_revoked:
        raise TokenRevokedError("Refresh token has been revoked.")

    # Touch last_used
    rt.last_used_at = datetime.now(timezone.utc)

    user = await repo.get_user_by_id(db, rt.user_id)
    if user is None or not user.is_active:
        raise AccountInactiveError("Account not found or inactive.")

    new_access = create_access_token(user_id=user.id, role=user.role)
    return new_access, user


# ─── Logout ──────────────────────────────────────────────────────────────────


async def logout(db: AsyncSession, raw_refresh_token: str) -> None:
    """Revoke a refresh token and deactivate the associated session."""
    token_hash = hash_token(raw_refresh_token)
    rt = await repo.get_refresh_token_by_hash(db, token_hash)

    if rt:
        await repo.revoke_refresh_token(db, token_hash)
        # Deactivate the session tied to this refresh token
        if rt.id:
            from sqlalchemy import update as _update
            from app.auth.models import UserSessionModel as _SM
            await db.execute(
                _update(_SM)
                .where(_SM.refresh_token_id == rt.id)
                .values(is_active=False)
            )


async def logout_all_devices(db: AsyncSession, user_id: str) -> None:
    """Revoke ALL refresh tokens and sessions for the user."""
    await repo.revoke_all_refresh_tokens(db, user_id)
    await repo.deactivate_all_sessions(db, user_id)


# ─── Password Reset ──────────────────────────────────────────────────────────


async def request_password_reset(db: AsyncSession, email: str) -> None:
    """Generate a reset token and email it. Silent if email not found."""
    email = email.lower().strip()
    user = await repo.get_user_by_email(db, email)
    if user is None:
        return  # Don't reveal whether the email exists

    raw_token = generate_secure_token()
    token_hash = hash_secure_token(raw_token)
    expires_at = datetime.now(timezone.utc) + timedelta(seconds=PASSWORD_RESET_EXPIRE_SECONDS)

    pr = PasswordResetModel(
        id=str(uuid.uuid4()),
        user_id=user.id,
        token_hash=token_hash,
        expires_at=expires_at,
    )
    await repo.save_password_reset(db, pr)

    reset_url = f"{_BASE_URL}/api/v1/auth/reset-password?token={raw_token}"
    send_password_reset_email(
        to_email=user.email,
        full_name=user.full_name,
        reset_url=reset_url,
    )


async def reset_password(db: AsyncSession, raw_token: str, new_password: str) -> None:
    """Validate a reset token and update the user's password."""
    token_hash = hash_secure_token(raw_token)
    pr = await repo.get_password_reset_by_hash(db, token_hash)

    if pr is None:
        raise PasswordResetTokenInvalidError("Invalid or expired reset token.")

    new_hash = hash_password(new_password)
    await repo.update_password_hash(db, pr.user_id, new_hash)
    await repo.mark_password_reset_used(db, pr.id)

    # Revoke all existing refresh tokens for security
    await repo.revoke_all_refresh_tokens(db, pr.user_id)


# ─── OTP-based Password Reset (mobile-friendly) ──────────────────────────────


async def send_password_reset_otp(db: AsyncSession, email: str) -> str | None:
    """Send a 6-digit OTP to the user's email for password reset (mobile flow).

    Stores the OTP in otp_codes with purpose='password_reset'.
    Silent if email not found — do not reveal whether the email exists.

    Returns the raw OTP string in development/test mode so the API can
    surface it in the response (no working SMTP needed for dev testing).
    Returns None in production.
    """
    email = email.lower().strip()
    user = await repo.get_user_by_email(db, email)
    if user is None:
        logger.info("Password reset OTP requested for unknown email: %s", email)
        return None  # Silent — don't reveal whether the email exists

    otp = generate_otp()
    otp_hash = hash_otp(otp)
    expires_at = datetime.now(timezone.utc) + timedelta(seconds=OTP_EXPIRE_SECONDS)

    otp_record = OTPCodeModel(
        id=str(uuid.uuid4()),
        user_id=user.id,
        purpose="password_reset",
        code_hash=otp_hash,
        expires_at=expires_at,
    )
    await repo.save_otp(db, otp_record)

    _is_dev = settings.environment.lower() in {"development", "test"}

    # Always log in dev/test so the terminal shows it
    if _is_dev:
        logger.info(
            "DEV MODE — Password reset OTP for %s: %s (expires in 10 min)",
            email, otp
        )

    # Try to send the real email; silently ignore if SMTP is not configured
    try:
        send_otp_email(to_email=user.email, full_name=user.full_name, otp=otp)
    except Exception as exc:
        logger.warning("OTP email failed (non-fatal in dev): %s", exc)

    # Return OTP in dev so the controller can include it in the response
    return otp if _is_dev else None


async def verify_reset_otp_and_get_token(
    db: AsyncSession, email: str, otp_code: str
) -> str:
    """Verify a password-reset OTP and return a one-time reset token.

    Returns a raw reset token that the client uses to call reset_password().
    Raises OTP-related domain errors on failure.
    """
    email = email.lower().strip()
    user = await repo.get_user_by_email(db, email)
    if user is None:
        raise InvalidCredentialsError("Invalid OTP.")  # Don't reveal email existence

    otp_record = await repo.get_latest_otp(db, user.id, "password_reset")
    if otp_record is None:
        raise OTPNotFoundError("No active OTP found. Please request a new code.")

    if otp_record.attempts >= OTP_MAX_ATTEMPTS:
        raise OTPMaxAttemptsError("Too many attempts. Please request a new OTP.")

    if not verify_otp(otp_code, otp_record.code_hash):
        await repo.increment_otp_attempts(db, otp_record.id)
        raise OTPInvalidError("Invalid OTP code.")

    # OTP is valid — mark it used and create a password-reset token
    await repo.mark_otp_used(db, otp_record.id)

    raw_token = generate_secure_token()
    token_hash = hash_secure_token(raw_token)
    reset_expires_at = datetime.now(timezone.utc) + timedelta(seconds=PASSWORD_RESET_EXPIRE_SECONDS)

    pr = PasswordResetModel(
        id=str(uuid.uuid4()),
        user_id=user.id,
        token_hash=token_hash,
        expires_at=reset_expires_at,
    )
    await repo.save_password_reset(db, pr)

    return raw_token


# ─── Session Management ──────────────────────────────────────────────────────


async def get_user_sessions(db: AsyncSession, user_id: str) -> list[UserSessionModel]:
    return await repo.get_active_sessions_for_user(db, user_id)


async def revoke_session(db: AsyncSession, user_id: str, session_id: str) -> None:
    """Deactivate a specific session belonging to the user."""
    session = await repo.get_session_by_id(db, session_id)
    if session is None or session.user_id != user_id:
        from app.auth.exceptions import SessionNotFoundError
        raise SessionNotFoundError("Session not found.")
    await repo.deactivate_session(db, session_id)


# ─── Role Management ─────────────────────────────────────────────────────────


async def change_user_role(db: AsyncSession, user_id: str, new_role: str) -> None:
    """Update the role for a given user (admin action)."""
    user = await repo.get_user_by_id(db, user_id)
    if user is None:
        raise InvalidCredentialsError("User not found.")
    await repo.update_user_role(db, user_id, new_role)


async def get_current_user(db: AsyncSession, user_id: str) -> UserModel:
    """Fetch the user record by ID (used by auth dependencies)."""
    user = await repo.get_user_by_id(db, user_id)
    if user is None:
        raise InvalidCredentialsError("User not found.")
    if not user.is_active:
        raise AccountInactiveError("Account is disabled.")
    return user
