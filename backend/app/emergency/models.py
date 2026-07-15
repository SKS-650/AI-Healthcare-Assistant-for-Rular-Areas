"""
SQLAlchemy ORM models for the Emergency module.

Tables:
  - emergency_assessments
  - emergency_module_contacts
  - sos_events
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


# ─── EmergencyAssessment ─────────────────────────────────────────────────────

class EmergencyAssessment(Base):
    """
    Stores every emergency assessment result.
    One row per assessment, linked to an optional authenticated user.
    """
    __tablename__ = "emergency_assessments"
    __allow_unmapped__ = True

    id              = Column(String(36),  primary_key=True, default=_uuid4)
    user_id         = Column(String(36),  ForeignKey("users.id", ondelete="SET NULL"),
                             nullable=True, index=True)

    # ── Patient info ──────────────────────────────────────────────────────────
    age             = Column(Integer,     nullable=True)
    gender          = Column(String(10),  nullable=True)   # male/female/other
    weight          = Column(Float,       nullable=True)   # kg
    is_pregnant     = Column(Boolean,     nullable=False, default=False)

    # ── Symptom data ──────────────────────────────────────────────────────────
    description     = Column(Text,        nullable=False, default="")
    symptoms        = Column(JSON,        nullable=False, default=list)  # list[str]
    severity_level  = Column(Integer,     nullable=False, default=1)     # 1-5
    duration_hours  = Column(Float,       nullable=False, default=0.0)

    # ── Medical history flags (stored as booleans) ────────────────────────────
    has_cardiac_history      = Column(Boolean, default=False)
    has_diabetes             = Column(Boolean, default=False)
    has_hypertension         = Column(Boolean, default=False)
    has_respiratory_disease  = Column(Boolean, default=False)
    is_immunocompromised     = Column(Boolean, default=False)
    recent_accident          = Column(Boolean, default=False)
    recent_surgery           = Column(Boolean, default=False)
    recent_travel            = Column(Boolean, default=False)
    snake_bite               = Column(Boolean, default=False)
    exposure_to_poison       = Column(Boolean, default=False)

    # ── AI result ─────────────────────────────────────────────────────────────
    is_emergency        = Column(Boolean,     nullable=False, default=False)
    emergency_type      = Column(String(50),  nullable=True)
    risk_score          = Column(Integer,     nullable=False, default=0)
    risk_level          = Column(String(20),  nullable=False, default="LOW")
    possible_emergency  = Column(String(200), nullable=True)
    recommended_dept    = Column(String(200), nullable=True)
    warning_message     = Column(Text,        nullable=True)
    sos_required        = Column(Boolean,     nullable=False, default=False)

    # ── Detailed AI output (JSON blobs) ────────────────────────────────────────
    first_aid_steps     = Column(JSON,  nullable=False, default=list)   # list[str]
    first_aid_dont_do   = Column(JSON,  nullable=False, default=list)   # list[str]
    matched_keywords    = Column(JSON,  nullable=False, default=list)   # list[str]
    severity_breakdown  = Column(JSON,  nullable=False, default=dict)   # score dict
    ml_confidence       = Column(Float, nullable=False, default=0.0)

    # ── Meta ──────────────────────────────────────────────────────────────────
    created_at = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    # ── Relationships ─────────────────────────────────────────────────────────
    sos_events = relationship(
        "SosEvent",
        back_populates="assessment",
        cascade="all, delete-orphan",
    )

    def __repr__(self) -> str:
        return f"<EmergencyAssessment id={self.id} risk={self.risk_level}>"


# ─── EmergencyContact ─────────────────────────────────────────────────────────

class EmergencyContact(Base):
    """Personal emergency contacts saved by a user."""
    # The Users module already owns a legacy ``emergency_contacts`` table.
    # Keep the emergency feature's richer contact records in its own table so
    # importing both modules does not prevent the application from starting.
    __tablename__ = "emergency_module_contacts"
    __allow_unmapped__ = True

    id           = Column(String(36), primary_key=True, default=_uuid4)
    user_id      = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"),
                          nullable=False, index=True)

    name         = Column(String(255), nullable=False)
    phone_number = Column(String(30),  nullable=False)
    relation     = Column(String(100), nullable=True)
    is_primary   = Column(Boolean,     nullable=False, default=False)

    created_at   = Column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at   = Column(DateTime(timezone=True), default=_utcnow,
                          onupdate=_utcnow, nullable=False)

    def __repr__(self) -> str:
        return f"<EmergencyContact {self.name} ({self.phone_number})>"


# ─── SosEvent ────────────────────────────────────────────────────────────────

class SosEvent(Base):
    """Records every SOS trigger for audit and analytics."""
    __tablename__ = "sos_events"
    __allow_unmapped__ = True

    id            = Column(String(36), primary_key=True, default=_uuid4)
    user_id       = Column(String(36), ForeignKey("users.id",  ondelete="SET NULL"),
                           nullable=True, index=True)
    assessment_id = Column(String(36), ForeignKey("emergency_assessments.id",
                           ondelete="SET NULL"), nullable=True)

    location_lat  = Column(Float,       nullable=True)
    location_lng  = Column(Float,       nullable=True)
    location_text = Column(String(500), nullable=True)
    emergency_type= Column(String(50),  nullable=True)
    contacts_notified = Column(JSON,    nullable=False, default=list)  # list[str] phone numbers
    status        = Column(String(30),  nullable=False, default="sent")  # sent/acknowledged/resolved

    created_at    = Column(DateTime(timezone=True), default=_utcnow, nullable=False)

    # ── Relationships ─────────────────────────────────────────────────────────
    assessment = relationship("EmergencyAssessment", back_populates="sos_events")

    def __repr__(self) -> str:
        return f"<SosEvent id={self.id} status={self.status}>"
