"""Pydantic request/response schemas for the User Management module."""

from __future__ import annotations

import re
from datetime import date, datetime
from typing import Any, List, Optional

from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator

from backend.app.users.constants import (
    ADDRESS_TYPES,
    ALL_ROLES,
    BLOOD_GROUPS,
    GENDERS,
    MARITAL_STATUSES,
    MAX_ADDRESSES_PER_USER,
    MAX_HEIGHT_CM,
    MAX_WEIGHT_KG,
    MIN_HEIGHT_CM,
    MIN_WEIGHT_KG,
    RELATIONSHIPS,
    SUPPORTED_LANGUAGES,
)

_PHONE_RE = re.compile(r"^\+?[1-9]\d{7,14}$")


def _check_phone(v: str | None) -> str | None:
    if v and not _PHONE_RE.match(v):
        raise ValueError("Phone must be in E.164 format, e.g. +919876543210")
    return v


# ─── User (account-level) ─────────────────────────────────────────────────────


class UserSummary(BaseModel):
    """Minimal user info used across modules."""

    user_id: str
    full_name: str
    email: str
    phone: Optional[str]
    role: str
    preferred_language: str
    profile_image: Optional[str]
    is_active: bool
    email_verified: bool
    phone_verified: bool
    created_at: datetime
    updated_at: datetime


class UpdateUserRequest(BaseModel):
    """Fields the user themselves can update on their account."""

    full_name: Optional[str] = Field(None, min_length=2, max_length=100)
    phone: Optional[str] = None
    preferred_language: Optional[str] = None
    profile_image: Optional[str] = None

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str | None) -> str | None:
        return _check_phone(v)

    @field_validator("preferred_language")
    @classmethod
    def validate_language(cls, v: str | None) -> str | None:
        if v and v not in SUPPORTED_LANGUAGES:
            raise ValueError(f"Language must be one of: {', '.join(SUPPORTED_LANGUAGES)}")
        return v


class UpdateAccountStatusRequest(BaseModel):
    """Admin action: activate or deactivate an account."""

    is_active: bool
    reason: Optional[str] = Field(None, max_length=500)


# ─── User Profile ─────────────────────────────────────────────────────────────


class CreateProfileRequest(BaseModel):
    date_of_birth: Optional[date] = Field(None, examples=["2000-01-15"])
    gender: Optional[str] = Field(None, examples=["male"])
    blood_group: Optional[str] = Field(None, examples=["B+"])
    height_cm: Optional[float] = Field(None, ge=MIN_HEIGHT_CM, le=MAX_HEIGHT_CM, examples=[172])
    weight_kg: Optional[float] = Field(None, ge=MIN_WEIGHT_KG, le=MAX_WEIGHT_KG, examples=[68])
    occupation: Optional[str] = Field(None, max_length=100, examples=["Student"])
    marital_status: Optional[str] = Field(None, examples=["single"])
    bio: Optional[str] = Field(None, max_length=1000)

    @field_validator("date_of_birth")
    @classmethod
    def dob_not_future(cls, v: date | None) -> date | None:
        if v and v > date.today():
            raise ValueError("Date of birth cannot be in the future.")
        return v

    @field_validator("gender")
    @classmethod
    def validate_gender(cls, v: str | None) -> str | None:
        if v and v.lower() not in GENDERS:
            raise ValueError(f"Gender must be one of: {', '.join(GENDERS)}")
        return v.lower() if v else v

    @field_validator("blood_group")
    @classmethod
    def validate_blood_group(cls, v: str | None) -> str | None:
        if v and v.upper() not in BLOOD_GROUPS:
            raise ValueError(f"Blood group must be one of: {', '.join(BLOOD_GROUPS)}")
        return v.upper() if v else v

    @field_validator("marital_status")
    @classmethod
    def validate_marital_status(cls, v: str | None) -> str | None:
        if v and v.lower() not in MARITAL_STATUSES:
            raise ValueError(f"Marital status must be one of: {', '.join(MARITAL_STATUSES)}")
        return v.lower() if v else v


class UpdateProfileRequest(CreateProfileRequest):
    """Same fields as create — all optional for partial update."""
    pass


class UserProfileResponse(BaseModel):
    profile_id: str
    user_id: str
    date_of_birth: Optional[date]
    gender: Optional[str]
    blood_group: Optional[str]
    height_cm: Optional[float]
    weight_kg: Optional[float]
    occupation: Optional[str]
    marital_status: Optional[str]
    bio: Optional[str]
    created_at: datetime
    updated_at: datetime


# ─── Address ──────────────────────────────────────────────────────────────────


class CreateAddressRequest(BaseModel):
    address_type: str = Field(default="home", examples=["home"])
    label: Optional[str] = Field(None, max_length=100, examples=["My Home"])
    country: Optional[str] = Field(None, max_length=100, examples=["Nepal"])
    state: Optional[str] = Field(None, max_length=100, examples=["Bagmati"])
    district: Optional[str] = Field(None, max_length=100, examples=["Kathmandu"])
    municipality: Optional[str] = Field(None, max_length=100, examples=["KMC"])
    ward_number: Optional[str] = Field(None, max_length=20, examples=["10"])
    street: Optional[str] = Field(None, max_length=255, examples=["Thamel Marg"])
    postal_code: Optional[str] = Field(None, max_length=20, examples=["44600"])
    latitude: Optional[float] = Field(None, ge=-90.0, le=90.0)
    longitude: Optional[float] = Field(None, ge=-180.0, le=180.0)
    is_primary: bool = False

    @field_validator("address_type")
    @classmethod
    def validate_type(cls, v: str) -> str:
        if v not in ADDRESS_TYPES:
            raise ValueError(f"Address type must be one of: {', '.join(ADDRESS_TYPES)}")
        return v

    @model_validator(mode="after")
    def coords_both_or_none(self) -> CreateAddressRequest:
        if (self.latitude is None) != (self.longitude is None):
            raise ValueError("Both latitude and longitude must be provided together.")
        return self


class UpdateAddressRequest(CreateAddressRequest):
    pass


class AddressResponse(BaseModel):
    address_id: str
    user_id: str
    address_type: str
    label: Optional[str]
    country: Optional[str]
    state: Optional[str]
    district: Optional[str]
    municipality: Optional[str]
    ward_number: Optional[str]
    street: Optional[str]
    postal_code: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    is_primary: bool
    created_at: datetime
    updated_at: datetime


class AddressListResponse(BaseModel):
    addresses: list[AddressResponse]
    total: int


# ─── Emergency Contact ────────────────────────────────────────────────────────


class CreateEmergencyContactRequest(BaseModel):
    contact_name: str = Field(..., min_length=2, max_length=150, examples=["Ramesh Sharma"])
    relationship: str = Field(..., examples=["father"])
    phone: str = Field(..., examples=["+919876543210"])
    email: Optional[EmailStr] = None
    priority: int = Field(default=1, ge=1, examples=[1])

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        return _check_phone(v)  # type: ignore[return-value]

    @field_validator("relationship")
    @classmethod
    def validate_relationship(cls, v: str) -> str:
        if v.lower() not in RELATIONSHIPS:
            raise ValueError(f"Relationship must be one of: {', '.join(RELATIONSHIPS)}")
        return v.lower()


class UpdateEmergencyContactRequest(BaseModel):
    contact_name: Optional[str] = Field(None, min_length=2, max_length=150)
    relationship: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    priority: Optional[int] = Field(None, ge=1)

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str | None) -> str | None:
        return _check_phone(v)

    @field_validator("relationship")
    @classmethod
    def validate_relationship(cls, v: str | None) -> str | None:
        if v and v.lower() not in RELATIONSHIPS:
            raise ValueError(f"Relationship must be one of: {', '.join(RELATIONSHIPS)}")
        return v.lower() if v else v


class EmergencyContactResponse(BaseModel):
    contact_id: str
    user_id: str
    contact_name: str
    relationship: str
    phone: str
    email: Optional[str]
    priority: int
    created_at: datetime
    updated_at: datetime


class EmergencyContactListResponse(BaseModel):
    contacts: list[EmergencyContactResponse]
    total: int


# ─── Medical Information ──────────────────────────────────────────────────────


class CreateMedicalInfoRequest(BaseModel):
    blood_group: Optional[str] = Field(None, examples=["B+"])
    allergies: Optional[List[str]] = Field(default_factory=list, examples=[["Penicillin"]])
    chronic_diseases: Optional[List[str]] = Field(default_factory=list, examples=[["Diabetes"]])
    disabilities: Optional[List[str]] = Field(default_factory=list, examples=[["None"]])
    current_medications: Optional[List[str]] = Field(default_factory=list, examples=[["Metformin 500mg"]])
    smoking_status: bool = False
    alcohol_consumption: bool = False
    notes: Optional[str] = Field(None, max_length=2000)

    @field_validator("blood_group")
    @classmethod
    def validate_blood_group(cls, v: str | None) -> str | None:
        if v and v.upper() not in BLOOD_GROUPS:
            raise ValueError(f"Blood group must be one of: {', '.join(BLOOD_GROUPS)}")
        return v.upper() if v else v


class UpdateMedicalInfoRequest(CreateMedicalInfoRequest):
    pass


class MedicalInfoResponse(BaseModel):
    info_id: str
    user_id: str
    blood_group: Optional[str]
    allergies: List[str]
    chronic_diseases: List[str]
    disabilities: List[str]
    current_medications: List[str]
    smoking_status: bool
    alcohol_consumption: bool
    notes: Optional[str]
    created_at: datetime
    updated_at: datetime


# ─── Full User Detail (aggregated) ────────────────────────────────────────────


class FullUserDetailResponse(BaseModel):
    """Complete user detail — returned by GET /users/{id} for the user or admin."""

    account: UserSummary
    profile: Optional[UserProfileResponse]
    addresses: List[AddressResponse]
    emergency_contacts: List[EmergencyContactResponse]
    medical_info: Optional[MedicalInfoResponse]


# ─── Admin: list users ────────────────────────────────────────────────────────


class UserListResponse(BaseModel):
    users: list[UserSummary]
    total: int
    page: int
    page_size: int
