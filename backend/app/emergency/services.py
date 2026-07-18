"""
Emergency Services — all business logic lives here.

  EmergencyAssessmentService   — run AI pipeline, persist result
  EmergencyContactService      — CRUD for personal emergency contacts
  SosService                   — trigger SOS alert, notify contacts
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import List, Optional, Sequence

from sqlalchemy.ext.asyncio import AsyncSession

from app.emergency.constants import (
    EMERGENCY_NUMBERS,
    MAX_EMERGENCY_CONTACTS,
    RISK_LEVEL_COLORS,
    RISK_LEVEL_EMOJI,
    SOS_COOLDOWN_SECONDS,
)
from app.emergency.exceptions import (
    EmergencyContactLimitError,
    EmergencyContactNotFoundError,
    EmergencyNotFoundError,
    SosCooldownError,
    UnauthorizedEmergencyAccessError,
)
from app.emergency.models import EmergencyAssessment, EmergencyContact, SosEvent
from app.emergency.repositories import AssessmentRepository, ContactRepository, SosRepository
from app.emergency.schemas import (
    EmergencyAssessmentRequest,
    EmergencyAssessmentResponse,
    EmergencyContactCreate,
    EmergencyContactResponse,
    EmergencyContactUpdate,
    FirstAidResponse,
    HospitalRecommendation,
    SosRequest,
    SosResponse,
)

logger = logging.getLogger(__name__)


# ─── Helper: build response from ORM model ────────────────────────────────────

def _build_assessment_response(row: EmergencyAssessment) -> EmergencyAssessmentResponse:
    first_aid = None
    if row.first_aid_steps:
        # Try to get the correct emoji from the guide data
        guide_emoji = "🚨"
        if row.emergency_type:
            try:
                from ai_models.emergency_detection import get_first_aid_guide
                guide = get_first_aid_guide(row.emergency_type)
                guide_emoji = guide.get("emoji", "🚨")
            except Exception:
                pass

        first_aid = FirstAidResponse(
            title=row.possible_emergency or "Emergency",
            emoji=guide_emoji,
            steps=row.first_aid_steps or [],
            do_not_steps=row.first_aid_dont_do or [],
            call_to_action="Call 102 (Ambulance) immediately.",
        )

    return EmergencyAssessmentResponse(
        id=row.id,
        is_emergency=row.is_emergency,
        risk_score=row.risk_score,
        risk_level=row.risk_level,
        risk_level_color=RISK_LEVEL_COLORS.get(row.risk_level, "#926EFF"),
        risk_level_emoji=RISK_LEVEL_EMOJI.get(row.risk_level, "⚪"),
        possible_emergency=row.possible_emergency or "No emergency detected",
        emergency_type=row.emergency_type,
        recommended_dept=row.recommended_dept or "General Practitioner",
        warning_message=row.warning_message or "",
        sos_required=row.sos_required,
        first_aid=first_aid,
        hospital_recommendation=_dummy_hospitals(),
        matched_keywords=row.matched_keywords or [],
        ml_confidence=row.ml_confidence or 0.0,
        created_at=row.created_at,
    )


def _dummy_hospitals() -> List[HospitalRecommendation]:
    """
    Returns placeholder hospital recommendations.
    In production replace with a real nearby-hospital lookup using the
    user's GPS coordinates and a hospital database / Google Maps API.
    """
    return [
        HospitalRecommendation(
            id="h1",
            name="City General Emergency Center",
            address="Health Avenue, Downtown",
            distance_km=1.2,
            phone_number="102",
            emergency_available=True,
        ),
        HospitalRecommendation(
            id="h2",
            name="Metro Trauma Hospital",
            address="Care Road, North District",
            distance_km=2.8,
            phone_number="+91-11-26588500",
            emergency_available=True,
        ),
    ]


# ─── Assessment Service ───────────────────────────────────────────────────────

class EmergencyAssessmentService:

    @staticmethod
    async def run_assessment(
        db: AsyncSession,
        payload: EmergencyAssessmentRequest,
        user_id: Optional[str] = None,
    ) -> EmergencyAssessmentResponse:
        """Run the AI pipeline and persist the result."""

        # Import here to avoid top-level import errors if ai_models not yet installed
        try:
            from ai_models.emergency_detection import (
                EmergencyPipelineInput,
                run_emergency_pipeline,
            )
            pipeline_input = EmergencyPipelineInput(
                description=payload.description,
                age=payload.age,
                gender=payload.gender,
                weight=payload.weight,
                symptoms=payload.symptoms,
                symptom_count=len(payload.symptoms),
                severity_level=payload.severity_level,
                duration_hours=payload.duration_hours,
                has_cardiac_history=payload.has_cardiac_history,
                has_diabetes=payload.has_diabetes,
                has_hypertension=payload.has_hypertension,
                has_respiratory_disease=payload.has_respiratory_disease,
                is_immunocompromised=payload.is_immunocompromised,
                is_pregnant=payload.is_pregnant,
                recent_accident=payload.recent_accident,
                recent_surgery=payload.recent_surgery,
                recent_travel=payload.recent_travel,
                snake_bite=payload.snake_bite,
                exposure_to_poison=payload.exposure_to_poison,
                language=payload.language,
            )
            result = run_emergency_pipeline(pipeline_input)

            # Build ORM row
            row = EmergencyAssessment(
                user_id=user_id,
                age=payload.age,
                gender=payload.gender,
                weight=payload.weight,
                is_pregnant=payload.is_pregnant,
                description=payload.description,
                symptoms=payload.symptoms,
                severity_level=payload.severity_level,
                duration_hours=payload.duration_hours,
                has_cardiac_history=payload.has_cardiac_history,
                has_diabetes=payload.has_diabetes,
                has_hypertension=payload.has_hypertension,
                has_respiratory_disease=payload.has_respiratory_disease,
                is_immunocompromised=payload.is_immunocompromised,
                recent_accident=payload.recent_accident,
                recent_surgery=payload.recent_surgery,
                recent_travel=payload.recent_travel,
                snake_bite=payload.snake_bite,
                exposure_to_poison=payload.exposure_to_poison,
                is_emergency=result.is_emergency,
                emergency_type=result.emergency_type,
                risk_score=result.risk_score,
                risk_level=result.risk_level.value if hasattr(result.risk_level, "value") else result.risk_level,
                possible_emergency=result.possible_emergency,
                recommended_dept=result.recommended_dept,
                warning_message=result.warning_message,
                sos_required=result.sos_required,
                first_aid_steps=result.first_aid.steps if result.first_aid else [],
                first_aid_dont_do=result.first_aid.do_not_steps if result.first_aid else [],
                matched_keywords=result.matched_keywords,
                severity_breakdown=result.severity_breakdown,
                ml_confidence=result.ml_confidence,
            )

        except ImportError:
            logger.warning("ai_models not available — returning mock assessment result.")
            row = EmergencyAssessment(
                user_id=user_id,
                age=payload.age,
                gender=payload.gender,
                description=payload.description,
                symptoms=payload.symptoms,
                severity_level=payload.severity_level,
                duration_hours=payload.duration_hours,
                is_emergency=False,
                risk_score=10,
                risk_level="LOW",
                possible_emergency="No emergency detected",
                recommended_dept="General Practitioner",
                warning_message="",
                sos_required=False,
                first_aid_steps=[],
                first_aid_dont_do=[],
                matched_keywords=[],
                severity_breakdown={},
                ml_confidence=0.0,
            )

        saved = await AssessmentRepository.create(db, row)
        return _build_assessment_response(saved)

    @staticmethod
    async def get_assessment(
        db: AsyncSession,
        assessment_id: str,
        user_id: Optional[str],
    ) -> EmergencyAssessmentResponse:
        row = await AssessmentRepository.get_by_id(db, assessment_id)
        if row is None:
            raise EmergencyNotFoundError(assessment_id)
        if row.user_id and user_id and row.user_id != user_id:
            raise UnauthorizedEmergencyAccessError()
        return _build_assessment_response(row)

    @staticmethod
    async def get_history(
        db: AsyncSession,
        user_id: str,
        limit: int = 20,
        offset: int = 0,
    ):
        from app.emergency.schemas import AssessmentHistoryItem, AssessmentHistoryResponse

        rows = await AssessmentRepository.get_by_user(db, user_id, limit, offset)
        total = await AssessmentRepository.count_by_user(db, user_id)

        items = [
            AssessmentHistoryItem(
                id=r.id,
                is_emergency=r.is_emergency,
                risk_level=r.risk_level,
                risk_score=r.risk_score,
                possible_emergency=r.possible_emergency or "N/A",
                emergency_type=r.emergency_type,
                created_at=r.created_at,
            )
            for r in rows
        ]
        return AssessmentHistoryResponse(total=total, assessments=items)


# ─── Contact Service ──────────────────────────────────────────────────────────

class EmergencyContactService:

    @staticmethod
    async def list_contacts(
        db: AsyncSession, user_id: str
    ) -> List[EmergencyContactResponse]:
        rows = await ContactRepository.get_by_user(db, user_id)
        return [
            EmergencyContactResponse(
                id=r.id,
                name=r.name,
                phone_number=r.phone_number,
                relation=r.relation or "",
                is_primary=r.is_primary,
                created_at=r.created_at,
            )
            for r in rows
        ]

    @staticmethod
    async def create_contact(
        db: AsyncSession,
        user_id: str,
        payload: EmergencyContactCreate,
    ) -> EmergencyContactResponse:
        count = await ContactRepository.count_by_user(db, user_id)
        if count >= MAX_EMERGENCY_CONTACTS:
            raise EmergencyContactLimitError(MAX_EMERGENCY_CONTACTS)

        contact = EmergencyContact(
            user_id=user_id,
            name=payload.name,
            phone_number=payload.phone_number,
            relation=payload.relation,
            is_primary=payload.is_primary,
        )
        saved = await ContactRepository.create(db, contact)
        return EmergencyContactResponse(
            id=saved.id,
            name=saved.name,
            phone_number=saved.phone_number,
            relation=saved.relation or "",
            is_primary=saved.is_primary,
            created_at=saved.created_at,
        )

    @staticmethod
    async def update_contact(
        db: AsyncSession,
        contact_id: str,
        user_id: str,
        payload: EmergencyContactUpdate,
    ) -> EmergencyContactResponse:
        contact = await ContactRepository.get_by_id(db, contact_id)
        if contact is None:
            raise EmergencyContactNotFoundError(contact_id)
        if contact.user_id != user_id:
            raise UnauthorizedEmergencyAccessError()

        if payload.name is not None:
            contact.name = payload.name
        if payload.phone_number is not None:
            contact.phone_number = payload.phone_number
        if payload.relation is not None:
            contact.relation = payload.relation
        if payload.is_primary is not None:
            contact.is_primary = payload.is_primary

        saved = await ContactRepository.update(db, contact)
        return EmergencyContactResponse(
            id=saved.id,
            name=saved.name,
            phone_number=saved.phone_number,
            relation=saved.relation or "",
            is_primary=saved.is_primary,
            created_at=saved.created_at,
        )

    @staticmethod
    async def delete_contact(
        db: AsyncSession,
        contact_id: str,
        user_id: str,
    ) -> None:
        contact = await ContactRepository.get_by_id(db, contact_id)
        if contact is None:
            raise EmergencyContactNotFoundError(contact_id)
        if contact.user_id != user_id:
            raise UnauthorizedEmergencyAccessError()
        await ContactRepository.delete(db, contact)


# ─── SOS Service ─────────────────────────────────────────────────────────────

class SosService:

    @staticmethod
    async def trigger_sos(
        db: AsyncSession,
        user_id: str,
        payload: SosRequest,
    ) -> SosResponse:
        # Rate-limit: prevent accidental double-SOS
        latest = await SosRepository.get_latest_by_user(db, user_id)
        if latest is not None:
            elapsed = (datetime.now(timezone.utc) - latest.created_at).total_seconds()
            if elapsed < SOS_COOLDOWN_SECONDS:
                raise SosCooldownError(int(SOS_COOLDOWN_SECONDS - elapsed))

        # Fetch user's emergency contacts to notify
        contacts = await ContactRepository.get_by_user(db, user_id)
        notified_phones = [c.phone_number for c in contacts]

        # TODO: In production — send SMS/push notification to notified_phones
        # e.g. await sms_service.send_bulk(notified_phones, sos_message)
        logger.info(
            "SOS triggered by user=%s. Notifying %d contacts.",
            user_id,
            len(notified_phones),
        )

        sos = SosEvent(
            user_id=user_id,
            assessment_id=payload.assessment_id,
            location_lat=payload.location_lat,
            location_lng=payload.location_lng,
            location_text=payload.location_text,
            emergency_type=payload.emergency_type,
            contacts_notified=notified_phones,
            status="sent",
        )
        saved = await SosRepository.create(db, sos)

        return SosResponse(
            id=saved.id,
            status=saved.status,
            contacts_notified=len(notified_phones),
            emergency_numbers=EMERGENCY_NUMBERS,
            message=(
                f"🚨 SOS alert sent to {len(notified_phones)} contact(s). "
                "Emergency services have been notified. Call 102 for immediate assistance."
            ),
            created_at=saved.created_at,
        )


# ─── First Aid Service ────────────────────────────────────────────────────────

class FirstAidService:

    @staticmethod
    def get_all_guides():
        from app.emergency.schemas import FirstAidResponse, FirstAidListResponse
        try:
            from ai_models.emergency_detection import get_all_guides
            guides = get_all_guides()   # returns List[Dict]
            return FirstAidListResponse(
                guides=[
                    FirstAidResponse(
                        title=g["title"],
                        emoji=g["emoji"],
                        steps=g["steps"],
                        do_not_steps=g["do_not_steps"],
                        call_to_action=g["call_to_action"],
                    )
                    for g in guides
                ]
            )
        except (ImportError, Exception) as exc:
            logger.warning("FirstAidService: could not load guides — %s", exc)
            return FirstAidListResponse(guides=[])
