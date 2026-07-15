"""Pydantic request/response schemas for the Emergency module."""

from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field, field_validator


# ─── Assessment Request ───────────────────────────────────────────────────────

class EmergencyAssessmentRequest(BaseModel):
    """Payload sent by the Flutter app to request an assessment."""

    # Free-text description
    description: str = Field(default="", max_length=2000)

    # Demographics
    age:    Optional[int]   = Field(default=None, ge=0, le=130)
    gender: Optional[str]   = Field(default=None, pattern="^(male|female|other)$")
    weight: Optional[float] = Field(default=None, ge=1.0, le=500.0)

    # Symptom data
    symptoms:       List[str] = Field(default_factory=list, max_length=30)
    severity_level: int       = Field(default=1, ge=1, le=5)
    duration_hours: float     = Field(default=0.0, ge=0.0, le=720.0)

    # Medical history flags
    has_cardiac_history:     bool = False
    has_diabetes:            bool = False
    has_hypertension:        bool = False
    has_respiratory_disease: bool = False
    is_immunocompromised:    bool = False
    is_pregnant:             bool = False

    # Context flags
    recent_accident:    bool = False
    recent_surgery:     bool = False
    recent_travel:      bool = False
    snake_bite:         bool = False
    exposure_to_poison: bool = False

    # Response language
    language: str = Field(default="en", pattern="^(en|hi|ne|bho)$")

    @field_validator("symptoms")
    @classmethod
    def clean_symptoms(cls, v: List[str]) -> List[str]:
        return [s.strip() for s in v if s.strip()]


# ─── First Aid Schema ─────────────────────────────────────────────────────────

class FirstAidResponse(BaseModel):
    title:          str
    emoji:          str
    steps:          List[str]
    do_not_steps:   List[str]
    call_to_action: str

    model_config = {"from_attributes": True}


# ─── Hospital Recommendation ─────────────────────────────────────────────────

class HospitalRecommendation(BaseModel):
    id:                   str
    name:                 str
    address:              str
    distance_km:          float
    phone_number:         str
    emergency_available:  bool = True


# ─── Assessment Response ──────────────────────────────────────────────────────

class EmergencyAssessmentResponse(BaseModel):
    id:                 str
    is_emergency:       bool
    risk_score:         int              # 0-100
    risk_level:         str              # LOW / MODERATE / HIGH / CRITICAL
    risk_level_color:   str              # hex colour
    risk_level_emoji:   str              # 🟢🟡🟠🔴
    possible_emergency: str
    emergency_type:     Optional[str]
    recommended_dept:   str
    warning_message:    str
    sos_required:       bool
    first_aid:          Optional[FirstAidResponse]
    hospital_recommendation: List[HospitalRecommendation] = Field(default_factory=list)
    matched_keywords:   List[str]        = Field(default_factory=list)
    ml_confidence:      float
    created_at:         datetime

    model_config = {"from_attributes": True}


# ─── Assessment History ───────────────────────────────────────────────────────

class AssessmentHistoryItem(BaseModel):
    id:                str
    is_emergency:      bool
    risk_level:        str
    risk_score:        int
    possible_emergency:str
    emergency_type:    Optional[str]
    created_at:        datetime

    model_config = {"from_attributes": True}


class AssessmentHistoryResponse(BaseModel):
    total:       int
    assessments: List[AssessmentHistoryItem]


# ─── Emergency Contacts ───────────────────────────────────────────────────────

class EmergencyContactCreate(BaseModel):
    name:         str  = Field(min_length=1, max_length=255)
    phone_number: str  = Field(min_length=5, max_length=30)
    relation:     str  = Field(default="", max_length=100)
    is_primary:   bool = False


class EmergencyContactUpdate(BaseModel):
    name:         Optional[str]  = Field(default=None, min_length=1, max_length=255)
    phone_number: Optional[str]  = Field(default=None, min_length=5, max_length=30)
    relation:     Optional[str]  = Field(default=None, max_length=100)
    is_primary:   Optional[bool] = None


class EmergencyContactResponse(BaseModel):
    id:           str
    name:         str
    phone_number: str
    relation:     str
    is_primary:   bool
    created_at:   datetime

    model_config = {"from_attributes": True}


# ─── SOS ─────────────────────────────────────────────────────────────────────

class SosRequest(BaseModel):
    emergency_type: str  = Field(default="general_emergency")
    location_lat:   Optional[float] = Field(default=None, ge=-90.0,  le=90.0)
    location_lng:   Optional[float] = Field(default=None, ge=-180.0, le=180.0)
    location_text:  Optional[str]   = Field(default=None, max_length=500)
    assessment_id:  Optional[str]   = None


class SosResponse(BaseModel):
    id:                   str
    status:               str
    contacts_notified:    int
    emergency_numbers:    Dict[str, str]
    message:              str
    created_at:           datetime

    model_config = {"from_attributes": True}


# ─── First Aid List ───────────────────────────────────────────────────────────

class FirstAidListResponse(BaseModel):
    guides: List[FirstAidResponse]
