"""
Pydantic request/response schemas for the Medical Records (PHR) module.

All dates are returned as ISO-8601 strings.  File URLs are absolute paths
that the Flutter client can fetch from the /uploads static mount.
"""

from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field, field_validator


# ─── Shared building blocks ───────────────────────────────────────────────────

class MedicineDosageSchema(BaseModel):
    name:      str = Field(min_length=1, max_length=200)
    dose:      str = Field(default="", max_length=100)
    frequency: str = Field(default="", max_length=100)
    duration:  str = Field(default="", max_length=100)


class VaccinationRecordSchema(BaseModel):
    name:           str            = Field(min_length=1, max_length=200)
    date_given:     Optional[str]  = None
    dose:           Optional[str]  = None
    next_due:       Optional[str]  = None


# ─── Medical Profile ──────────────────────────────────────────────────────────

class MedicalProfileUpsert(BaseModel):
    blood_group:          Optional[str]  = Field(default=None, max_length=10)
    height_cm:            Optional[float] = Field(default=None, ge=30.0,  le=300.0)
    weight_kg:            Optional[float] = Field(default=None, ge=1.0,   le=600.0)
    smoking_status:       Optional[str]  = Field(default=None, max_length=30)
    alcohol_status:       Optional[str]  = Field(default=None, max_length=30)
    activity_level:       Optional[str]  = Field(default=None, max_length=30)
    allergies:            List[str]      = Field(default_factory=list)
    chronic_diseases:     List[str]      = Field(default_factory=list)
    current_medications:  List[str]      = Field(default_factory=list)
    family_history:       List[str]      = Field(default_factory=list)
    vaccination_history:  List[Dict[str, Any]] = Field(default_factory=list)


class MedicalProfileResponse(BaseModel):
    id:                   str
    user_id:              str
    blood_group:          Optional[str]
    height_cm:            Optional[float]
    weight_kg:            Optional[float]
    bmi:                  Optional[float]
    smoking_status:       Optional[str]
    alcohol_status:       Optional[str]
    activity_level:       Optional[str]
    allergies:            List[str]
    chronic_diseases:     List[str]
    current_medications:  List[str]
    family_history:       List[str]
    vaccination_history:  List[Dict[str, Any]]
    created_at:           datetime
    updated_at:           datetime

    model_config = {"from_attributes": True}


# ─── Medical History ──────────────────────────────────────────────────────────

class MedicalHistoryCreate(BaseModel):
    disease_name:   str            = Field(min_length=1, max_length=255)
    category:       str            = Field(default="current", max_length=50)
    diagnosis_date: Optional[datetime] = None
    status:         str            = Field(default="active", max_length=30)
    doctor_name:    Optional[str]  = Field(default=None, max_length=255)
    hospital_name:  Optional[str]  = Field(default=None, max_length=255)
    notes:          Optional[str]  = Field(default=None, max_length=2000)

    @field_validator("category")
    @classmethod
    def validate_category(cls, v: str) -> str:
        allowed = {"current", "past", "surgery", "allergy", "chronic", "family"}
        if v not in allowed:
            raise ValueError(f"category must be one of {allowed}")
        return v

    @field_validator("status")
    @classmethod
    def validate_status(cls, v: str) -> str:
        allowed = {"active", "resolved", "managed"}
        if v not in allowed:
            raise ValueError(f"status must be one of {allowed}")
        return v


class MedicalHistoryUpdate(BaseModel):
    disease_name:   Optional[str]      = Field(default=None, min_length=1, max_length=255)
    category:       Optional[str]      = Field(default=None, max_length=50)
    diagnosis_date: Optional[datetime] = None
    status:         Optional[str]      = Field(default=None, max_length=30)
    doctor_name:    Optional[str]      = Field(default=None, max_length=255)
    hospital_name:  Optional[str]      = Field(default=None, max_length=255)
    notes:          Optional[str]      = Field(default=None, max_length=2000)


class MedicalHistoryResponse(BaseModel):
    id:             str
    user_id:        str
    disease_name:   str
    category:       str
    diagnosis_date: Optional[datetime]
    status:         str
    doctor_name:    Optional[str]
    hospital_name:  Optional[str]
    notes:          Optional[str]
    created_at:     datetime
    updated_at:     datetime

    model_config = {"from_attributes": True}


# ─── Prescription ─────────────────────────────────────────────────────────────

class PrescriptionCreate(BaseModel):
    doctor_name:        Optional[str]  = Field(default=None, max_length=255)
    hospital_name:      Optional[str]  = Field(default=None, max_length=255)
    diagnosis:          Optional[str]  = Field(default=None, max_length=500)
    prescription_date:  Optional[datetime] = None
    valid_until:        Optional[datetime] = None
    medicines:          List[MedicineDosageSchema] = Field(default_factory=list)
    instructions:       Optional[str]  = Field(default=None, max_length=2000)
    notes:              Optional[str]  = Field(default=None, max_length=2000)


class PrescriptionResponse(BaseModel):
    id:                 str
    user_id:            str
    doctor_name:        Optional[str]
    hospital_name:      Optional[str]
    diagnosis:          Optional[str]
    prescription_date:  Optional[datetime]
    valid_until:        Optional[datetime]
    medicines:          List[Dict[str, Any]]
    instructions:       Optional[str]
    notes:              Optional[str]
    file_url:           Optional[str]          # absolute URL if file uploaded
    file_original_name: Optional[str]
    created_at:         datetime

    model_config = {"from_attributes": True}


# ─── Medical Image ────────────────────────────────────────────────────────────

class MedicalImageCreate(BaseModel):
    title:         str            = Field(min_length=1, max_length=255)
    image_type:    str            = Field(default="other", max_length=50)
    description:   Optional[str] = Field(default=None, max_length=2000)
    body_part:     Optional[str] = Field(default=None, max_length=100)
    doctor_name:   Optional[str] = Field(default=None, max_length=255)
    hospital_name: Optional[str] = Field(default=None, max_length=255)
    scan_date:     Optional[datetime] = None
    tags:          List[str]     = Field(default_factory=list)

    @field_validator("image_type")
    @classmethod
    def validate_image_type(cls, v: str) -> str:
        allowed = {"xray", "mri", "ct_scan", "blood_report", "ecg", "skin", "other"}
        if v not in allowed:
            raise ValueError(f"image_type must be one of {allowed}")
        return v


class MedicalImageResponse(BaseModel):
    id:               str
    user_id:          str
    title:            str
    image_type:       str
    description:      Optional[str]
    body_part:        Optional[str]
    doctor_name:      Optional[str]
    hospital_name:    Optional[str]
    scan_date:        Optional[datetime]
    tags:             List[str]
    file_url:         Optional[str]
    file_original_name: Optional[str]
    file_size_bytes:  Optional[int]
    created_at:       datetime

    model_config = {"from_attributes": True}


# ─── Timeline ─────────────────────────────────────────────────────────────────

class TimelineEventResponse(BaseModel):
    id:           str
    event_type:   str
    title:        str
    description:  Optional[str]
    reference_id: Optional[str]
    icon_emoji:   Optional[str]
    event_date:   datetime
    created_at:   datetime

    model_config = {"from_attributes": True}


class TimelineResponse(BaseModel):
    total:  int
    events: List[TimelineEventResponse]


# ─── Dashboard summary ────────────────────────────────────────────────────────

class HealthRecordsSummary(BaseModel):
    """Lightweight summary returned by the dashboard endpoint."""
    has_profile:         bool
    medical_history_count: int
    prescription_count:  int
    medical_image_count: int
    recent_timeline:     List[TimelineEventResponse]
