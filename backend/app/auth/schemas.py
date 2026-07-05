"""Pydantic request/response schemas for the authentication module."""

from __future__ import annotations

import re
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator

from app.auth.constants import ALL_ROLES, Role

# ─── Helpers ─────────────────────────────────────────────────────────────────

_PHONE_RE = re.compile(r"^\+?[1-9]\d{7,14}$")
_PASSWORD_MIN = 8


def _validate_phone(v: str | None) -> str | None:
    if v and not _PHONE_RE.match(v):
        raise ValueError("Phone must be in E.164 format, e.g. +919876543210")
    return v


def _validate_password_strength(v: str) -> str:
    if len(v) < _PASSWORD_MIN:
        raise ValueError(f"Password must be at least {_PASSWORD_MIN} characters.")
    if not re.search(r"[A-Z]", v):
        raise ValueError("Password must contain at least one uppercase letter.")
    if not re.search(r"[a-z]", v):
        raise ValueError("Password must contain at least one lowercase letter.")
    if not re.search(r"\d", v):
        raise ValueError("Password must contain at least one digit.")
    if not re.search(r"[!@#$%^&*(),.?\":{}|<>_\-]", v):
        raise ValueError("Password must contain at least one special character.")
    return v


# ─── Registration ────────────────────────────────────────────────────────────


class RegisterRequest(BaseModel):
    """User registration payload."""

    full_name: str = Field(..., min_length=2, max_length=255, examples=["Ramesh Sharma"])
    email: EmailStr = Field(..., examples=["ramesh@example.com"])
    phone: Optional[str] = Field(None, examples=["+919876543210"])
    password: str = Field(..., min_length=8, examples=["SecurePass@123"])
    confirm_password: str = Field(..., examples=["SecurePass@123"])
    role: str = Field(default=Role.PATIENT, examples=["patient"])
    language: str = Field(default="en", max_length=10, examples=["en"])

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str | None) -> str | None:
        return _validate_phone(v)

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        return _validate_password_strength(v)

    @field_validator("role")
    @classmethod
    def validate_role(cls, v: str) -> str:
        if v not in ALL_ROLES:
            raise ValueError(f"Role must be one of: {', '.join(ALL_ROLES)}")
        return v

    @model_validator(mode="after")
    def passwords_match(self) -> RegisterRequest:
        if self.password != self.confirm_password:
            raise ValueError("Passwords do not match.")
        return self


class RegisterResponse(BaseModel):
    """Registration success response."""

    user_id: str
    email: str
    message: str = "Registration successful. Please verify your email."


# ─── OTP Verification ────────────────────────────────────────────────────────


class VerifyOTPRequest(BaseModel):
    """OTP verification payload (email or phone)."""

    user_id: str
    otp: str = Field(..., min_length=4, max_length=10, examples=["123456"])
    purpose: str = Field(..., examples=["phone_verify"])


class VerifyOTPResponse(BaseModel):
    user_id: str
    verified: bool
    message: str


# ─── Email Verification ──────────────────────────────────────────────────────


class EmailVerifyRequest(BaseModel):
    """Email verification via token link."""

    token: str = Field(..., min_length=10)


class EmailVerifyResponse(BaseModel):
    message: str = "Email verified successfully."


# ─── Phone Verification ──────────────────────────────────────────────────────


class PhoneSendOTPRequest(BaseModel):
    user_id: str
    phone: str

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        return _validate_phone(v)  # type: ignore[return-value]


class PhoneVerifyOTPRequest(BaseModel):
    user_id: str
    otp: str = Field(..., min_length=4, max_length=10)


# ─── Login ───────────────────────────────────────────────────────────────────


class LoginRequest(BaseModel):
    """Login payload."""

    email: EmailStr = Field(..., examples=["ramesh@example.com"])
    password: str = Field(..., examples=["SecurePass@123"])
    device_info: Optional[str] = Field(None, max_length=512)


class TokenPair(BaseModel):
    """Access + refresh token pair."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds


class LoginResponse(BaseModel):
    """Login success response."""

    user_id: str
    email: str
    role: str
    tokens: TokenPair


# ─── Token Refresh ───────────────────────────────────────────────────────────


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class RefreshTokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int


# ─── Logout ──────────────────────────────────────────────────────────────────


class LogoutRequest(BaseModel):
    refresh_token: str


class LogoutResponse(BaseModel):
    message: str = "Logged out successfully."


# ─── Password Reset ──────────────────────────────────────────────────────────


class ForgotPasswordRequest(BaseModel):
    email: EmailStr = Field(..., examples=["ramesh@example.com"])


class ForgotPasswordResponse(BaseModel):
    message: str = "If that email exists, a reset link has been sent."


# ─── OTP-based Password Reset (mobile-friendly) ──────────────────────────────


class ForgotPasswordOTPRequest(BaseModel):
    """Request an OTP code to be sent to the user's email (mobile flow)."""
    email: EmailStr = Field(..., examples=["ramesh@example.com"])


class ForgotPasswordOTPResponse(BaseModel):
    message: str = "If that email exists, a 6-digit OTP has been sent."


class VerifyResetOTPRequest(BaseModel):
    """Verify the OTP received via email and obtain a password-reset token."""
    email: EmailStr = Field(..., examples=["ramesh@example.com"])
    otp: str = Field(..., min_length=6, max_length=6, examples=["123456"])


class VerifyResetOTPResponse(BaseModel):
    reset_token: str
    message: str = "OTP verified. Use the reset_token to set a new password."


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str = Field(..., min_length=8)
    confirm_password: str

    @field_validator("new_password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        return _validate_password_strength(v)

    @model_validator(mode="after")
    def passwords_match(self) -> ResetPasswordRequest:
        if self.new_password != self.confirm_password:
            raise ValueError("Passwords do not match.")
        return self


class ResetPasswordResponse(BaseModel):
    message: str = "Password reset successful. Please log in."


# ─── User Profile (lightweight) ──────────────────────────────────────────────


class UserProfileResponse(BaseModel):
    """Minimal user info returned after login / in token payloads."""

    user_id: str
    full_name: str
    email: str
    phone: Optional[str]
    role: str
    is_active: bool
    email_verified: bool
    phone_verified: bool
    language: str
    profile_image: Optional[str]
    last_login: Optional[datetime]
    created_at: datetime


# ─── Session ─────────────────────────────────────────────────────────────────


class SessionInfo(BaseModel):
    session_id: str
    device_info: Optional[str]
    ip_address: Optional[str]
    is_active: bool
    created_at: datetime
    last_active_at: datetime


class SessionListResponse(BaseModel):
    sessions: list[SessionInfo]


class RevokeSessionRequest(BaseModel):
    session_id: str


# ─── RBAC ────────────────────────────────────────────────────────────────────


class RoleInfo(BaseModel):
    name: str
    description: Optional[str]
    permissions: list[str]


class ChangeRoleRequest(BaseModel):
    user_id: str
    new_role: str

    @field_validator("new_role")
    @classmethod
    def validate_role(cls, v: str) -> str:
        if v not in ALL_ROLES:
            raise ValueError(f"Role must be one of: {', '.join(ALL_ROLES)}")
        return v
