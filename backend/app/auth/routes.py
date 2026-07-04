"""Authentication API endpoints.

All routes are mounted under /api/v1/auth.
"""

from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.auth import controller
from backend.app.auth.dependencies import (
    AdminUser,
    CurrentUser,
    get_current_user,
    require_role,
)
from backend.app.auth.constants import Role
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
    SessionListResponse,
    UserProfileResponse,
    VerifyOTPResponse,
    VerifyResetOTPRequest,
    VerifyResetOTPResponse,
)

from backend.app.database.connection import get_async_session as get_db

router = APIRouter(prefix="/auth", tags=["Authentication"])


# ─── Registration ─────────────────────────────────────────────────────────────


@router.post(
    "/register",
    response_model=RegisterResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
    description=(
        "Creates a new user account. "
        "A verification email (and phone OTP if provided) is sent automatically."
    ),
)
async def register(
    payload: RegisterRequest,
    db: AsyncSession = Depends(get_db),
) -> RegisterResponse:
    return await controller.handle_register(payload, db)


# ─── Email Verification ──────────────────────────────────────────────────────


@router.post(
    "/verify-email",
    response_model=EmailVerifyResponse,
    summary="Verify email address",
    description="Validates the email-verification token sent in the registration email.",
)
async def verify_email(
    payload: EmailVerifyRequest,
    db: AsyncSession = Depends(get_db),
) -> EmailVerifyResponse:
    return await controller.handle_verify_email(payload, db)


@router.post(
    "/resend-email-verification",
    summary="Resend email verification",
    description="Sends a fresh verification email. Silent if the address is unknown.",
)
async def resend_email_verification(
    email: str,
    db: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    return await controller.handle_resend_email_verification(email, db)


# ─── Phone Verification ──────────────────────────────────────────────────────


@router.post(
    "/send-phone-otp",
    summary="Send phone verification OTP",
    description="Sends a numeric OTP to the user's registered phone via SMS.",
)
async def send_phone_otp(
    payload: PhoneSendOTPRequest,
    db: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    return await controller.handle_send_phone_otp(payload, db)


@router.post(
    "/verify-phone",
    response_model=VerifyOTPResponse,
    summary="Verify phone OTP",
    description="Validates the OTP entered by the user to confirm their phone number.",
)
async def verify_phone(
    payload: PhoneVerifyOTPRequest,
    db: AsyncSession = Depends(get_db),
) -> VerifyOTPResponse:
    return await controller.handle_verify_phone_otp(payload, db)


# ─── Login ───────────────────────────────────────────────────────────────────


@router.post(
    "/login",
    response_model=LoginResponse,
    summary="Login",
    description=(
        "Authenticates a user with email + password. "
        "Returns an access token (15 min) and a refresh token (30 days)."
    ),
)
async def login(
    payload: LoginRequest,
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> LoginResponse:
    return await controller.handle_login(payload, request, db)


# ─── Token Refresh ───────────────────────────────────────────────────────────


@router.post(
    "/refresh",
    response_model=RefreshTokenResponse,
    summary="Refresh access token",
    description="Exchanges a valid refresh token for a new access token.",
)
async def refresh_token(
    payload: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
) -> RefreshTokenResponse:
    return await controller.handle_refresh_token(payload, db)


# ─── Logout ──────────────────────────────────────────────────────────────────


@router.post(
    "/logout",
    response_model=LogoutResponse,
    summary="Logout (current device)",
    description="Revokes the provided refresh token and invalidates the current session.",
)
async def logout(
    payload: LogoutRequest,
    db: AsyncSession = Depends(get_db),
) -> LogoutResponse:
    return await controller.handle_logout(payload, db)


@router.post(
    "/logout-all",
    response_model=LogoutResponse,
    summary="Logout all devices",
    description="Revokes ALL refresh tokens and sessions for the authenticated user.",
)
async def logout_all(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> LogoutResponse:
    return await controller.handle_logout_all(current_user.id, db)


# ─── Password Reset ──────────────────────────────────────────────────────────


@router.post(
    "/forgot-password",
    response_model=ForgotPasswordResponse,
    summary="Request password reset",
    description=(
        "Sends a password-reset link to the given email. "
        "Always returns success to avoid email enumeration."
    ),
)
async def forgot_password(
    payload: ForgotPasswordRequest,
    db: AsyncSession = Depends(get_db),
) -> ForgotPasswordResponse:
    return await controller.handle_forgot_password(payload, db)


@router.post(
    "/forgot-password-otp",
    summary="Request password reset via OTP (mobile-friendly)",
    description=(
        "Sends a 6-digit OTP to the user's email for password reset. "
        "Use this flow on mobile apps instead of the link-based flow. "
        "Always returns success to prevent email enumeration. "
        "In development mode the OTP is printed in the server logs."
    ),
)
async def forgot_password_otp(
    payload: ForgotPasswordOTPRequest,
    db: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    return await controller.handle_forgot_password_otp(payload, db)


@router.post(
    "/verify-reset-otp",
    response_model=VerifyResetOTPResponse,
    summary="Verify password-reset OTP and obtain a reset token",
    description=(
        "Verifies the 6-digit OTP sent to the user's email. "
        "On success returns a reset_token to be passed to POST /reset-password."
    ),
)
async def verify_reset_otp(
    payload: VerifyResetOTPRequest,
    db: AsyncSession = Depends(get_db),
) -> VerifyResetOTPResponse:
    result = await controller.handle_verify_reset_otp(payload, db)
    return VerifyResetOTPResponse(**result)


@router.post(
    "/reset-password",
    response_model=ResetPasswordResponse,
    summary="Reset password",
    description="Validates the reset token and sets the new password.",
)
async def reset_password(
    payload: ResetPasswordRequest,
    db: AsyncSession = Depends(get_db),
) -> ResetPasswordResponse:
    return await controller.handle_reset_password(payload, db)


# ─── Profile ─────────────────────────────────────────────────────────────────


@router.get(
    "/me",
    response_model=UserProfileResponse,
    summary="Get current user profile",
    description="Returns the profile of the currently authenticated user.",
)
async def get_profile(current_user: CurrentUser) -> UserProfileResponse:
    return await controller.handle_get_profile(current_user)


# ─── Session Management ──────────────────────────────────────────────────────


@router.get(
    "/sessions",
    response_model=SessionListResponse,
    summary="List active sessions",
    description="Returns all active sessions for the current user.",
)
async def list_sessions(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> SessionListResponse:
    return await controller.handle_list_sessions(current_user.id, db)


@router.post(
    "/sessions/revoke",
    summary="Revoke a specific session",
    description="Deactivates a specific session by its ID.",
)
async def revoke_session(
    payload: RevokeSessionRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    return await controller.handle_revoke_session(payload, current_user.id, db)


# ─── RBAC (admin only) ───────────────────────────────────────────────────────


@router.post(
    "/admin/change-role",
    summary="Change user role (admin)",
    description="Allows admins to assign a new role to any user.",
    dependencies=[Depends(require_role(Role.ADMIN, Role.SUPER_ADMIN))],
)
async def change_role(
    payload: ChangeRoleRequest,
    db: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    return await controller.handle_change_role(payload, db)
