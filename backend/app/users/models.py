"""SQLAlchemy ORM models for the User Management module.

Tables
------
- user_profiles      (1:1 with users)
- user_addresses     (1:N with users)
- emergency_contacts (1:N with users)
- medical_information (1:1 with users)
"""

from __future__ import annotations

import uuid
from datetime import date, datetime, timezone

from sqlalchemy import (
    JSON,
    Boolean,
    Column,
    Date,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
)
from sqlalchemy.orm import relationship

# Re-use the shared Base from auth so Alembic sees all tables together
from app.auth.models import Base, UserModel


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _uuid4() -> str:
    return str(uuid.uuid4())


# ─── User Profile (1:1) ───────────────────────────────────────────────────────


class UserProfileModel(Base):
    __tablename__ = "user_profiles"
    __allow_unmapped__ = True

    id = Column(String(36), primary_key=True, default=_uuid4)
    user_id = Column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    date_of_birth = Column(Date, nullable=True)
    gender = Column(String(20), nullable=True)
    blood_group = Column(String(5), nullable=True)
    height_cm = Column(Float, nullable=True)
    weight_kg = Column(Float, nullable=True)
    occupation = Column(String(100), nullable=True)
    marital_status = Column(String(20), nullable=True)
    bio = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    user = relationship("UserModel", backref="profile_detail", uselist=False)

    def __repr__(self) -> str:
        return f"<UserProfile user={self.user_id}>"


# ─── User Addresses (1:N) ─────────────────────────────────────────────────────


class UserAddressModel(Base):
    __tablename__ = "user_addresses"
    __allow_unmapped__ = True

    id = Column(String(36), primary_key=True, default=_uuid4)
    user_id = Column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )

    address_type = Column(String(20), nullable=False, default="home")
    label = Column(String(100), nullable=True)

    country = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    district = Column(String(100), nullable=True)
    municipality = Column(String(100), nullable=True)
    ward_number = Column(String(20), nullable=True)
    street = Column(String(255), nullable=True)
    postal_code = Column(String(20), nullable=True)

    latitude = Column(Numeric(precision=10, scale=7), nullable=True)
    longitude = Column(Numeric(precision=10, scale=7), nullable=True)

    is_primary = Column(Boolean, nullable=False, default=False)

    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    user = relationship("UserModel", backref="address_list")

    def __repr__(self) -> str:
        return f"<UserAddress user={self.user_id} type={self.address_type}>"


# ─── Emergency Contacts (1:N) ─────────────────────────────────────────────────


class EmergencyContactModel(Base):
    __tablename__ = "emergency_contacts"
    __allow_unmapped__ = True

    id = Column(String(36), primary_key=True, default=_uuid4)
    user_id = Column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )

    contact_name = Column(String(150), nullable=False)
    contact_relationship = Column(String(50), nullable=False)
    phone = Column(String(20), nullable=False)
    email = Column(String(320), nullable=True)
    priority = Column(Integer, nullable=False, default=1)

    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    user = relationship("UserModel", backref="emergency_contact_list")

    def __repr__(self) -> str:
        return f"<EmergencyContact user={self.user_id} name={self.contact_name}>"


# ─── Medical Information (1:1) ────────────────────────────────────────────────


class MedicalInformationModel(Base):
    __tablename__ = "medical_information"
    __allow_unmapped__ = True

    id = Column(String(36), primary_key=True, default=_uuid4)
    user_id = Column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    blood_group = Column(String(5), nullable=True)

    allergies = Column(JSON, nullable=True, default=list)
    chronic_diseases = Column(JSON, nullable=True, default=list)
    disabilities = Column(JSON, nullable=True, default=list)
    current_medications = Column(JSON, nullable=True, default=list)

    smoking_status = Column(Boolean, nullable=False, default=False)
    alcohol_consumption = Column(Boolean, nullable=False, default=False)
    notes = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    user = relationship("UserModel", backref="medical_info_detail", uselist=False)

    def __repr__(self) -> str:
        return f"<MedicalInformation user={self.user_id}>"
