"""Auth controller — handles HTTP request/response conversion.

All domain logic lives in service.py. The controller:
1. Unpacks validated Pydantic schemas
2. Calls service methods
3. Maps domain exceptions to HTTP responses via auth_error_to_http()
4. Returns Pydantic response schemas
"""

from __future__ import annotations

import logging
from typing import Any

from fastapi import HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.auth import service
from backend.app.auth.constants import ACCESS_TOKEN_EXPIRE_SECONDS
from backend.app.auth.exceptions import AuthError, auth_error_to_http
from backend.app.auth.models import UserModel
from backend.app.auth.schemas import (
    ChangeRoleRequest,
    EmailVerifyRequest,
    EmailVerifyResponse,
    ForgotPasswordOTPRequest,
    ForgotPasswordRequest,
    ForgotPasswordResponse,
    LoginRequest,
    LoginResponse,
    LogoutRequest,
    LogoutResponse,
    PhoneSendOTPRequest,
    PhoneVerifyOTPRequest,
    RefreshTokenRequest,
    RefreshTokenResponse,
    RegisterRequest,
    RegisterResponse,
    ResetPasswordRequest,
    ResetPasswordResponse,
    RevokeSessionRequest,
    SessionInfo,
    SessionListResponse,
    TokenPair,
    UserProfileResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
    VerifyResetOTPRequest,
    VerifyResetOTPResponse,
)

logger = logging.getLogger(__name__)


def _ip(request: Request) -> str | None:
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None


def _device(request: Request) -> str | None:
    return request.headers.get("User-Agent")


def _user_to_profile(user: UserModel) -> UserProfileResponse:
    return UserProfileResponse(
        user_id=user.id,
        full_name=user.full_name,
        email=user.email,
        phone=user.phone,
        role=user.role,
        is_active=user.is_active,
        email_verified=user.email_verified,
        phone_verified=user.phone_verified,
        language=user.language,
        profile_image=user.profile_image,
        last_login=user.last_login,
        created_at=user.created_at,
    )


# ─── Registration ─────────────────────────────────────────────────────────────


async def handle_register(
    payload: RegisterRequest, db: AsyncSession
) -> RegisterResponse:
    try:
        user = await service.register_user(
            db=db,
            full_name=payload.full_name,
            email=payload.email,
            phone=payload.phone,
            password=payload.password,
            role=payload.role,
            language=payload.language,
        )
        await db.commit()
        return RegisterResponse(user_id=user.id, email=user.email)
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)
    except Exception:
        await db.rollback()
        logger.exception("Unexpected error during registration")
        raise HTTPException(status_code=500, detail="Registration failed.")


# ─── Email Verification ──────────────────────────────────────────────────────


async def handle_verify_email(
    payload: EmailVerifyRequest, db: AsyncSession
) -> EmailVerifyResponse:
    try:
        await service.verify_email_token(db, payload.token)
        await db.commit()
        return EmailVerifyResponse()
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


async def handle_resend_email_verification(email: str, db: AsyncSession) -> dict[str, str]:
    try:
        await service.resend_email_verification(db, email)
        await db.commit()
        return {"message": "Verification email sent if the address exists."}
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


# ─── Phone Verification ──────────────────────────────────────────────────────


async def handle_send_phone_otp(
    payload: PhoneSendOTPRequest, db: AsyncSession
) -> dict[str, str]:
    try:
        await service.send_phone_verification_otp(db, payload.user_id, payload.phone)
        await db.commit()
        return {"message": "OTP sent to your phone."}
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


async def handle_verify_phone_otp(
    payload: PhoneVerifyOTPRequest, db: AsyncSession
) -> VerifyOTPResponse:
    try:
        await service.verify_phone_otp(db, payload.user_id, payload.otp)
        await db.commit()
        return VerifyOTPResponse(user_id=payload.user_id, verified=True, message="Phone verified.")
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


# ─── Login ───────────────────────────────────────────────────────────────────


async def handle_login(
    payload: LoginRequest, request: Request, db: AsyncSession
) -> LoginResponse:
    try:
        access, refresh, user = await service.login(
            db=db,
            email=payload.email,
            password=payload.password,
            device_info=payload.device_info or _device(request),
            ip_address=_ip(request),
        )
        await db.commit()
        return LoginResponse(
            user_id=user.id,
            email=user.email,
            role=user.role,
            tokens=TokenPair(
                access_token=access,
                refresh_token=refresh,
                expires_in=ACCESS_TOKEN_EXPIRE_SECONDS,
            ),
        )
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


# ─── Token Refresh ───────────────────────────────────────────────────────────


async def handle_refresh_token(
    payload: RefreshTokenRequest, db: AsyncSession
) -> RefreshTokenResponse:
    try:
        access, _ = await service.refresh_access_token(db, payload.refresh_token)
        await db.commit()
        return RefreshTokenResponse(
            access_token=access,
            expires_in=ACCESS_TOKEN_EXPIRE_SECONDS,
        )
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


# ─── Logout ──────────────────────────────────────────────────────────────────


async def handle_logout(
    payload: LogoutRequest, db: AsyncSession
) -> LogoutResponse:
    try:
        await service.logout(db, payload.refresh_token)
        await db.commit()
        return LogoutResponse()
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


async def handle_logout_all(user_id: str, db: AsyncSession) -> LogoutResponse:
    try:
        await service.logout_all_devices(db, user_id)
        await db.commit()
        return LogoutResponse(message="Logged out from all devices.")
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


# ─── Password Reset ──────────────────────────────────────────────────────────


async def handle_forgot_password(
    payload: ForgotPasswordRequest, db: AsyncSession
) -> ForgotPasswordResponse:
    try:
        await service.request_password_reset(db, payload.email)
        await db.commit()
        return ForgotPasswordResponse()
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


async def handle_forgot_password_otp(
    payload: Any, db: AsyncSession
) -> dict[str, str]:
    """Send a 6-digit OTP to the user's email (mobile-friendly password reset).

    In development mode the OTP is returned in the response body under the
    key 'dev_otp' so the mobile app can display it without needing a working
    SMTP server.
    """
    try:
        from backend.app.auth.schemas import ForgotPasswordOTPRequest as _Req
        email = payload.email if hasattr(payload, "email") else payload["email"]
        dev_otp = await service.send_password_reset_otp(db, email)
        await db.commit()
        response: dict[str, str] = {
            "message": "If that email exists, a 6-digit OTP has been sent."
        }
        if dev_otp is not None:
            # Only returned in development/test — never in production
            response["dev_otp"] = dev_otp
        return response
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


async def handle_verify_reset_otp(
    payload: Any, db: AsyncSession
) -> dict[str, str]:
    """Verify the password-reset OTP and return a reset token."""
    try:
        email = payload.email if hasattr(payload, "email") else payload["email"]
        otp = payload.otp if hasattr(payload, "otp") else payload["otp"]
        raw_token = await service.verify_reset_otp_and_get_token(db, email, otp)
        await db.commit()
        return {
            "reset_token": raw_token,
            "message": "OTP verified. Use the reset_token to set a new password.",
        }
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


async def handle_reset_password(
    payload: ResetPasswordRequest, db: AsyncSession
) -> ResetPasswordResponse:
    try:
        await service.reset_password(db, payload.token, payload.new_password)
        await db.commit()
        return ResetPasswordResponse()
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


# ─── Profile ─────────────────────────────────────────────────────────────────


async def handle_get_profile(user: UserModel) -> UserProfileResponse:
    return _user_to_profile(user)


# ─── Session Management ──────────────────────────────────────────────────────


async def handle_list_sessions(user_id: str, db: AsyncSession) -> SessionListResponse:
    sessions = await service.get_user_sessions(db, user_id)
    return SessionListResponse(
        sessions=[
            SessionInfo(
                session_id=s.id,
                device_info=s.device_info,
                ip_address=s.ip_address,
                is_active=s.is_active,
                created_at=s.created_at,
                last_active_at=s.last_active_at,
            )
            for s in sessions
        ]
    )


async def handle_revoke_session(
    payload: RevokeSessionRequest, user_id: str, db: AsyncSession
) -> dict[str, str]:
    try:
        await service.revoke_session(db, user_id, payload.session_id)
        await db.commit()
        return {"message": "Session revoked."}
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)


# ─── RBAC ────────────────────────────────────────────────────────────────────


async def handle_change_role(
    payload: ChangeRoleRequest, db: AsyncSession
) -> dict[str, str]:
    try:
        await service.change_user_role(db, payload.user_id, payload.new_role)
        await db.commit()
        return {"message": f"Role updated to '{payload.new_role}'."}
    except AuthError as e:
        await db.rollback()
        raise auth_error_to_http(e)
