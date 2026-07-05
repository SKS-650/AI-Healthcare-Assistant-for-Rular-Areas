"""Database operations for the authentication module.

All methods accept a SQLAlchemy AsyncSession and return ORM model instances.
The service layer is responsible for committing transactions.
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.models import (
    EmailVerificationModel,
    OTPCodeModel,
    PasswordResetModel,
    PhoneVerificationModel,
    RefreshTokenModel,
    RoleModel,
    UserModel,
    UserSessionModel,
)

logger = logging.getLogger(__name__)


# ─── Users ───────────────────────────────────────────────────────────────────


async def get_user_by_id(db: AsyncSession, user_id: str) -> Optional[UserModel]:
    result = await db.execute(select(UserModel).where(UserModel.id == user_id))
    return result.scalar_one_or_none()


async def get_user_by_email(db: AsyncSession, email: str) -> Optional[UserModel]:
    result = await db.execute(
        select(UserModel).where(UserModel.email == email.lower().strip())
    )
    return result.scalar_one_or_none()


async def get_user_by_phone(db: AsyncSession, phone: str) -> Optional[UserModel]:
    result = await db.execute(select(UserModel).where(UserModel.phone == phone))
    return result.scalar_one_or_none()


async def create_user(db: AsyncSession, user: UserModel) -> UserModel:
    db.add(user)
    await db.flush()  # get PK without committing
    logger.info("User created: id=%s email=%s", user.id, user.email)
    return user


async def update_user_last_login(db: AsyncSession, user_id: str) -> None:
    await db.execute(
        update(UserModel)
        .where(UserModel.id == user_id)
        .values(last_login=datetime.now(timezone.utc))
    )


async def set_email_verified(db: AsyncSession, user_id: str) -> None:
    await db.execute(
        update(UserModel).where(UserModel.id == user_id).values(email_verified=True)
    )


async def set_phone_verified(db: AsyncSession, user_id: str) -> None:
    await db.execute(
        update(UserModel).where(UserModel.id == user_id).values(phone_verified=True)
    )


async def update_password_hash(db: AsyncSession, user_id: str, new_hash: str) -> None:
    await db.execute(
        update(UserModel)
        .where(UserModel.id == user_id)
        .values(password_hash=new_hash, updated_at=datetime.now(timezone.utc))
    )


async def update_user_role(db: AsyncSession, user_id: str, new_role: str) -> None:
    await db.execute(
        update(UserModel)
        .where(UserModel.id == user_id)
        .values(role=new_role, updated_at=datetime.now(timezone.utc))
    )


# ─── Refresh Tokens ──────────────────────────────────────────────────────────


async def save_refresh_token(db: AsyncSession, token: RefreshTokenModel) -> RefreshTokenModel:
    db.add(token)
    await db.flush()
    return token


async def get_refresh_token_by_hash(
    db: AsyncSession, token_hash: str
) -> Optional[RefreshTokenModel]:
    result = await db.execute(
        select(RefreshTokenModel).where(RefreshTokenModel.token_hash == token_hash)
    )
    return result.scalar_one_or_none()


async def revoke_refresh_token(db: AsyncSession, token_hash: str) -> None:
    await db.execute(
        update(RefreshTokenModel)
        .where(RefreshTokenModel.token_hash == token_hash)
        .values(is_revoked=True)
    )


async def revoke_all_refresh_tokens(db: AsyncSession, user_id: str) -> None:
    """Revoke every refresh token belonging to a user (full logout)."""
    await db.execute(
        update(RefreshTokenModel)
        .where(RefreshTokenModel.user_id == user_id)
        .values(is_revoked=True)
    )


# ─── OTP Codes ───────────────────────────────────────────────────────────────


async def save_otp(db: AsyncSession, otp: OTPCodeModel) -> OTPCodeModel:
    db.add(otp)
    await db.flush()
    return otp


async def get_latest_otp(
    db: AsyncSession, user_id: str, purpose: str
) -> Optional[OTPCodeModel]:
    """Return the most recent, unused, non-expired OTP for a user+purpose."""
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(OTPCodeModel)
        .where(
            OTPCodeModel.user_id == user_id,
            OTPCodeModel.purpose == purpose,
            OTPCodeModel.is_used == False,  # noqa: E712
            OTPCodeModel.expires_at > now,
        )
        .order_by(OTPCodeModel.created_at.desc())
        .limit(1)
    )
    return result.scalar_one_or_none()


async def increment_otp_attempts(db: AsyncSession, otp_id: str) -> None:
    result = await db.execute(select(OTPCodeModel).where(OTPCodeModel.id == otp_id))
    otp = result.scalar_one_or_none()
    if otp:
        otp.attempts += 1


async def mark_otp_used(db: AsyncSession, otp_id: str) -> None:
    await db.execute(
        update(OTPCodeModel).where(OTPCodeModel.id == otp_id).values(is_used=True)
    )


# ─── Email Verification ──────────────────────────────────────────────────────


async def save_email_verification(
    db: AsyncSession, ev: EmailVerificationModel
) -> EmailVerificationModel:
    db.add(ev)
    await db.flush()
    return ev


async def get_email_verification_by_hash(
    db: AsyncSession, token_hash: str
) -> Optional[EmailVerificationModel]:
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(EmailVerificationModel).where(
            EmailVerificationModel.token_hash == token_hash,
            EmailVerificationModel.is_used == False,  # noqa: E712
            EmailVerificationModel.expires_at > now,
        )
    )
    return result.scalar_one_or_none()


async def mark_email_verification_used(db: AsyncSession, ev_id: str) -> None:
    await db.execute(
        update(EmailVerificationModel)
        .where(EmailVerificationModel.id == ev_id)
        .values(is_used=True)
    )


# ─── Phone Verification ──────────────────────────────────────────────────────


async def save_phone_verification(
    db: AsyncSession, pv: PhoneVerificationModel
) -> PhoneVerificationModel:
    db.add(pv)
    await db.flush()
    return pv


async def get_latest_phone_verification(
    db: AsyncSession, user_id: str
) -> Optional[PhoneVerificationModel]:
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(PhoneVerificationModel)
        .where(
            PhoneVerificationModel.user_id == user_id,
            PhoneVerificationModel.is_used == False,  # noqa: E712
            PhoneVerificationModel.expires_at > now,
        )
        .order_by(PhoneVerificationModel.created_at.desc())
        .limit(1)
    )
    return result.scalar_one_or_none()


async def mark_phone_verification_used(db: AsyncSession, pv_id: str) -> None:
    await db.execute(
        update(PhoneVerificationModel)
        .where(PhoneVerificationModel.id == pv_id)
        .values(is_used=True)
    )


# ─── Password Reset ──────────────────────────────────────────────────────────


async def save_password_reset(db: AsyncSession, pr: PasswordResetModel) -> PasswordResetModel:
    db.add(pr)
    await db.flush()
    return pr


async def get_password_reset_by_hash(
    db: AsyncSession, token_hash: str
) -> Optional[PasswordResetModel]:
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(PasswordResetModel).where(
            PasswordResetModel.token_hash == token_hash,
            PasswordResetModel.is_used == False,  # noqa: E712
            PasswordResetModel.expires_at > now,
        )
    )
    return result.scalar_one_or_none()


async def mark_password_reset_used(db: AsyncSession, pr_id: str) -> None:
    await db.execute(
        update(PasswordResetModel)
        .where(PasswordResetModel.id == pr_id)
        .values(is_used=True)
    )


# ─── Sessions ────────────────────────────────────────────────────────────────


async def save_session(db: AsyncSession, session: UserSessionModel) -> UserSessionModel:
    db.add(session)
    await db.flush()
    return session


async def get_session_by_id(
    db: AsyncSession, session_id: str
) -> Optional[UserSessionModel]:
    result = await db.execute(
        select(UserSessionModel).where(UserSessionModel.id == session_id)
    )
    return result.scalar_one_or_none()


async def get_active_sessions_for_user(
    db: AsyncSession, user_id: str
) -> list[UserSessionModel]:
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(UserSessionModel).where(
            UserSessionModel.user_id == user_id,
            UserSessionModel.is_active == True,  # noqa: E712
            UserSessionModel.expires_at > now,
        )
    )
    return list(result.scalars().all())


async def deactivate_session(db: AsyncSession, session_id: str) -> None:
    await db.execute(
        update(UserSessionModel)
        .where(UserSessionModel.id == session_id)
        .values(is_active=False)
    )


async def deactivate_all_sessions(db: AsyncSession, user_id: str) -> None:
    await db.execute(
        update(UserSessionModel)
        .where(UserSessionModel.user_id == user_id)
        .values(is_active=False)
    )


# ─── Roles ───────────────────────────────────────────────────────────────────


async def get_role_by_name(db: AsyncSession, name: str) -> Optional[RoleModel]:
    result = await db.execute(select(RoleModel).where(RoleModel.name == name))
    return result.scalar_one_or_none()
