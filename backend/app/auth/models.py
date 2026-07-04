"""SQLAlchemy ORM models for the authentication module.

Tables: users, roles, permissions, role_permissions,
        refresh_tokens, otp_codes, email_verification,
        phone_verification, password_reset, user_sessions
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import DeclarativeBase, relationship


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _uuid4() -> str:
    return str(uuid.uuid4())


class Base(DeclarativeBase):
    __allow_unmapped__ = True


# ─── roles ────────────────────────────────────────────────────────────────────


class RoleModel(Base):
    __tablename__ = "roles"
    __allow_unmapped__ = True

    id          = Column(String(36),  primary_key=True, default=_uuid4)
    name        = Column(String(50),  unique=True, nullable=False)
    description = Column(Text,        nullable=True)
    created_at  = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    role_permissions = relationship(
        "RolePermissionModel", back_populates="role", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Role {self.name}>"


# ─── permissions ──────────────────────────────────────────────────────────────


class PermissionModel(Base):
    __tablename__ = "permissions"
    __allow_unmapped__ = True

    id          = Column(String(36),  primary_key=True, default=_uuid4)
    name        = Column(String(100), unique=True, nullable=False)
    description = Column(Text,        nullable=True)
    created_at  = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    role_permissions = relationship(
        "RolePermissionModel", back_populates="permission", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Permission {self.name}>"


# ─── role_permissions ─────────────────────────────────────────────────────────


class RolePermissionModel(Base):
    __tablename__ = "role_permissions"
    __allow_unmapped__ = True
    __table_args__ = (
        UniqueConstraint("role_id", "permission_id", name="uq_role_permission"),
    )

    id            = Column(String(36), primary_key=True, default=_uuid4)
    role_id       = Column(String(36), ForeignKey("roles.id",       ondelete="CASCADE"), nullable=False)
    permission_id = Column(String(36), ForeignKey("permissions.id", ondelete="CASCADE"), nullable=False)

    role       = relationship("RoleModel",       back_populates="role_permissions")
    permission = relationship("PermissionModel", back_populates="role_permissions")


# ─── users ────────────────────────────────────────────────────────────────────


class UserModel(Base):
    __tablename__ = "users"
    __allow_unmapped__ = True

    id            = Column(String(36),  primary_key=True, default=_uuid4)
    full_name     = Column(String(255), nullable=False)
    email         = Column(String(320), unique=True,  nullable=False, index=True)
    phone         = Column(String(20),  unique=True,  nullable=True,  index=True)
    password_hash = Column(Text,        nullable=False)
    profile_image = Column(Text,        nullable=True)

    # Plain VARCHAR — no FK to roles table (roles table is for RBAC permissions only)
    role     = Column(String(50), nullable=False, default="patient")
    language = Column(String(10), nullable=False, default="en")

    is_active      = Column(Boolean, nullable=False, default=True)
    email_verified = Column(Boolean, nullable=False, default=False)
    phone_verified = Column(Boolean, nullable=False, default=False)

    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)
    last_login = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    refresh_tokens     = relationship("RefreshTokenModel",     back_populates="user", cascade="all, delete-orphan")
    otp_codes          = relationship("OTPCodeModel",          back_populates="user", cascade="all, delete-orphan")
    email_verifications= relationship("EmailVerificationModel",back_populates="user", cascade="all, delete-orphan")
    phone_verifications= relationship("PhoneVerificationModel",back_populates="user", cascade="all, delete-orphan")
    password_resets    = relationship("PasswordResetModel",    back_populates="user", cascade="all, delete-orphan")
    sessions           = relationship("UserSessionModel",      back_populates="user", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<User {self.email}>"


# ─── refresh_tokens ───────────────────────────────────────────────────────────


class RefreshTokenModel(Base):
    __tablename__ = "refresh_tokens"
    __allow_unmapped__ = True

    id           = Column(String(36), primary_key=True, default=_uuid4)
    user_id      = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    token_hash   = Column(Text,       nullable=False, unique=True)
    device_info  = Column(Text,       nullable=True)
    ip_address   = Column(String(45), nullable=True)
    is_revoked   = Column(Boolean,    nullable=False, default=False)
    expires_at   = Column(DateTime(timezone=True), nullable=False)
    created_at   = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    last_used_at = Column(DateTime(timezone=True), nullable=True)

    user = relationship("UserModel", back_populates="refresh_tokens")

    def __repr__(self) -> str:
        return f"<RefreshToken user={self.user_id} revoked={self.is_revoked}>"


# ─── otp_codes ────────────────────────────────────────────────────────────────


class OTPCodeModel(Base):
    __tablename__ = "otp_codes"
    __allow_unmapped__ = True

    id         = Column(String(36), primary_key=True, default=_uuid4)
    user_id    = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    purpose    = Column(String(50), nullable=False)
    code_hash  = Column(Text,       nullable=False)
    attempts   = Column(Integer,    nullable=False, default=0)
    is_used    = Column(Boolean,    nullable=False, default=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    user = relationship("UserModel", back_populates="otp_codes")


# ─── email_verification ───────────────────────────────────────────────────────


class EmailVerificationModel(Base):
    __tablename__ = "email_verification"
    __allow_unmapped__ = True

    id         = Column(String(36), primary_key=True, default=_uuid4)
    user_id    = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    token_hash = Column(Text,       nullable=False, unique=True)
    is_used    = Column(Boolean,    nullable=False, default=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    user = relationship("UserModel", back_populates="email_verifications")


# ─── phone_verification ───────────────────────────────────────────────────────


class PhoneVerificationModel(Base):
    __tablename__ = "phone_verification"
    __allow_unmapped__ = True

    id         = Column(String(36), primary_key=True, default=_uuid4)
    user_id    = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    phone      = Column(String(20), nullable=False)
    code_hash  = Column(Text,       nullable=False)
    attempts   = Column(Integer,    nullable=False, default=0)
    is_used    = Column(Boolean,    nullable=False, default=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    user = relationship("UserModel", back_populates="phone_verifications")


# ─── password_reset ───────────────────────────────────────────────────────────


class PasswordResetModel(Base):
    __tablename__ = "password_reset"
    __allow_unmapped__ = True

    id         = Column(String(36), primary_key=True, default=_uuid4)
    user_id    = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    token_hash = Column(Text,       nullable=False, unique=True)
    is_used    = Column(Boolean,    nullable=False, default=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    user = relationship("UserModel", back_populates="password_resets")


# ─── user_sessions ────────────────────────────────────────────────────────────


class UserSessionModel(Base):
    __tablename__ = "user_sessions"
    __allow_unmapped__ = True

    id                = Column(String(36), primary_key=True, default=_uuid4)
    user_id           = Column(String(36), ForeignKey("users.id",          ondelete="CASCADE"),   nullable=False, index=True)
    refresh_token_id  = Column(String(36), ForeignKey("refresh_tokens.id", ondelete="SET NULL"),  nullable=True)
    device_info       = Column(Text,       nullable=True)
    ip_address        = Column(String(45), nullable=True)
    is_active         = Column(Boolean,    nullable=False, default=True)
    expires_at        = Column(DateTime(timezone=True), nullable=False)
    created_at        = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    last_active_at    = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    user = relationship("UserModel", back_populates="sessions")
