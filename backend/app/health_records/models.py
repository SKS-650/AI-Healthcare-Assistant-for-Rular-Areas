"""
SQLAlchemy ORM models for the Medical Records (PHR) module.

Tables:
  - user_medical_profiles
  - medical_history
  - prescriptions
  - medical_images
  - timeline_events
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    JSON,
    String,
    Text,
)
from sqlalchemy.orm import relationship

from app.auth.models import Base


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _uuid4() -> str:
    return str(uuid.uuid4())


# ─── UserMedicalProfile ───────────────────────────────────────────────────────

class UserMedicalProfile(Base):
    """
    One-row-per-user personal health baseline.
    Created on first access, updated freely.
    """
    __tablename__ = "user_medical_profiles"
    __allow_unmapped__ = True

    id         = Column(String(36), primary_key=True, default=_uuid4)
    user_id    = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"),
                        nullable=False, unique=True, index=True)

    # ── Vitals ────────────────────────────────────────────────────────────────
    blood_group      = Column(String(10),  nullable=True)   # A+, B-, O+, AB+, …
    height_cm        = Column(Float,       nullable=True)
    weight_kg        = Column(Float,       nullable=True)
    bmi              = Column(Float,       nullable=True)    # computed or stored

    # ── Lifestyle ─────────────────────────────────────────────────────────────
    smoking_status   = Column(String(30),  nullable=True)   # never / former / current
    alcohol_status   = Column(String(30),  nullable=True)   # never / occasional / regular
    activity_level   = Column(String(30),  nullable=True)   # sedentary / moderate / active

    # ── Medical flags (JSON lists) ────────────────────────────────────────────
    allergies         = Column(JSON, nullable=False, default=list)   # ["Penicillin", "Peanuts"]
    chronic_diseases  = Column(JSON, nullable=False, default=list)   # ["Diabetes", "Hypertension"]
    current_medications = Column(JSON, nullable=False, default=list) # ["Metformin 500mg"]
    family_history    = Column(JSON, nullable=False, default=list)   # ["Heart disease (father)"]
    vaccination_history = Column(JSON, nullable=False, default=list) # [{"name":"COVID-19","date":"2022"}]

    # ── Meta ──────────────────────────────────────────────────────────────────
    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<UserMedicalProfile user_id={self.user_id} blood={self.blood_group}>"


# ─── MedicalHistory ───────────────────────────────────────────────────────────

class MedicalHistory(Base):
    """
    Individual medical history entries (diseases, surgeries, conditions).
    Each row is one item in the patient's health history.
    """
    __tablename__ = "medical_history"
    __allow_unmapped__ = True

    id             = Column(String(36),  primary_key=True, default=_uuid4)
    user_id        = Column(String(36),  ForeignKey("users.id", ondelete="CASCADE"),
                            nullable=False, index=True)

    disease_name   = Column(String(255), nullable=False)
    category       = Column(String(50),  nullable=False, default="current")
    # category options: current | past | surgery | allergy | chronic | family

    diagnosis_date = Column(DateTime(timezone=True), nullable=True)
    status         = Column(String(30),  nullable=False, default="active")
    # status options: active | resolved | managed

    doctor_name    = Column(String(255), nullable=True)
    hospital_name  = Column(String(255), nullable=True)
    notes          = Column(Text,        nullable=True)

    created_at     = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at     = Column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<MedicalHistory {self.disease_name} ({self.category})>"


# ─── Prescription ─────────────────────────────────────────────────────────────

class Prescription(Base):
    """Uploaded prescriptions and their metadata."""
    __tablename__ = "prescriptions"
    __allow_unmapped__ = True

    id                = Column(String(36),  primary_key=True, default=_uuid4)
    user_id           = Column(String(36),  ForeignKey("users.id", ondelete="CASCADE"),
                               nullable=False, index=True)

    doctor_name       = Column(String(255), nullable=True)
    hospital_name     = Column(String(255), nullable=True)
    diagnosis         = Column(String(500), nullable=True)
    prescription_date = Column(DateTime(timezone=True), nullable=True)
    valid_until       = Column(DateTime(timezone=True), nullable=True)

    medicines         = Column(JSON, nullable=False, default=list)
    # [{"name":"Metformin","dose":"500mg","frequency":"Twice daily","duration":"30 days"}]

    instructions      = Column(Text,        nullable=True)
    file_path         = Column(String(500), nullable=True)   # relative to uploads/
    file_original_name= Column(String(255), nullable=True)
    file_mime_type    = Column(String(100), nullable=True)
    notes             = Column(Text,        nullable=True)

    created_at        = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<Prescription id={self.id} diag={self.diagnosis}>"


# ─── MedicalImage ─────────────────────────────────────────────────────────────

class MedicalImage(Base):
    """
    Uploaded medical images / scans (X-Ray, MRI, CT, blood reports, ECG, skin).
    Stored in category sub-folders under media/medical_records/.
    """
    __tablename__ = "medical_images"
    __allow_unmapped__ = True

    id               = Column(String(36),  primary_key=True, default=_uuid4)
    user_id          = Column(String(36),  ForeignKey("users.id", ondelete="CASCADE"),
                              nullable=False, index=True)

    title            = Column(String(255), nullable=False)
    image_type       = Column(String(50),  nullable=False, default="other")
    # image_type options: xray | mri | ct_scan | blood_report | ecg | skin | other

    file_path        = Column(String(500), nullable=True)
    file_original_name = Column(String(255), nullable=True)
    file_mime_type   = Column(String(100), nullable=True)
    file_size_bytes  = Column(Integer,     nullable=True)

    description      = Column(Text,        nullable=True)
    body_part        = Column(String(100), nullable=True)  # chest, knee, brain …
    doctor_name      = Column(String(255), nullable=True)
    hospital_name    = Column(String(255), nullable=True)
    scan_date        = Column(DateTime(timezone=True), nullable=True)

    tags             = Column(JSON, nullable=False, default=list)

    created_at       = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<MedicalImage id={self.id} type={self.image_type}>"


# ─── TimelineEvent ────────────────────────────────────────────────────────────

class TimelineEvent(Base):
    """
    Unified medical timeline combining all record types into a single feed.
    Rows are created automatically by the service layer whenever a relevant
    record is created (prescription upload, symptom assessment, chat, etc.).
    """
    __tablename__ = "timeline_events"
    __allow_unmapped__ = True

    id           = Column(String(36), primary_key=True, default=_uuid4)
    user_id      = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"),
                          nullable=False, index=True)

    event_type   = Column(String(50),  nullable=False)
    # options: medical_history | prescription | medical_image |
    #          symptom_assessment | chat_conversation | emergency_assessment

    title        = Column(String(255), nullable=False)
    description  = Column(Text,        nullable=True)
    reference_id = Column(String(36),  nullable=True)   # FK into the source table
    icon_emoji   = Column(String(10),  nullable=True, default="📋")
    event_date   = Column(DateTime(timezone=True), nullable=False, default=_utcnow)

    created_at   = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<TimelineEvent {self.event_type} on {self.event_date}>"
