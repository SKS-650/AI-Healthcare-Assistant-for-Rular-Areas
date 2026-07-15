"""
Medical Records Services — all business logic for the PHR module.

Services:
  MedicalProfileService   — get/upsert personal health baseline
  MedicalHistoryService   — CRUD for health history entries
  PrescriptionService     — upload + manage prescriptions
  MedicalImageService     — upload + manage medical images/scans
  TimelineService         — unified event feed
  HealthRecordsSummaryService — lightweight dashboard summary
"""

from __future__ import annotations

import logging
import os
import pathlib
import uuid
from datetime import datetime, timezone
from typing import List, Optional

from fastapi import UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from app.health_records.exceptions import (
    FileTooLargeError,
    RecordNotFoundError,
    UnauthorizedRecordAccessError,
    UnsupportedFileTypeError,
)
from app.health_records.models import (
    MedicalHistory,
    MedicalImage,
    Prescription,
    TimelineEvent,
    UserMedicalProfile,
)
from app.health_records.repositories import (
    MedicalHistoryRepository,
    MedicalImageRepository,
    MedicalProfileRepository,
    PrescriptionRepository,
    TimelineRepository,
)
from app.health_records.schemas import (
    HealthRecordsSummary,
    MedicalHistoryCreate,
    MedicalHistoryResponse,
    MedicalHistoryUpdate,
    MedicalImageCreate,
    MedicalImageResponse,
    MedicalProfileResponse,
    MedicalProfileUpsert,
    PrescriptionCreate,
    PrescriptionResponse,
    TimelineEventResponse,
    TimelineResponse,
)

logger = logging.getLogger(__name__)

# ─── Constants ────────────────────────────────────────────────────────────────

MAX_FILE_SIZE_BYTES = 20 * 1024 * 1024   # 20 MB

ALLOWED_DOCUMENT_MIMES = {
    "application/pdf",
    "image/png",
    "image/jpeg",
    "image/jpg",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
}
ALLOWED_IMAGE_MIMES = {"image/png", "image/jpeg", "image/jpg", "image/webp"}

# Map event_type → emoji
_TIMELINE_EMOJIS = {
    "medical_history":    "🩺",
    "prescription":       "💊",
    "medical_image":      "🩻",
    "symptom_assessment": "🤒",
    "chat_conversation":  "💬",
    "emergency_assessment": "🚨",
}

# Base uploads directory (relative to this file: backend/app/health_records/services.py)
_UPLOADS_BASE = pathlib.Path(__file__).parent.parent / "uploads" / "medical_records"


def _build_uploads_dir(sub: str) -> pathlib.Path:
    d = _UPLOADS_BASE / sub
    d.mkdir(parents=True, exist_ok=True)
    return d


def _file_url(relative_path: str, base_url: str = "") -> str:
    """Convert stored relative path to a URL the client can fetch."""
    # In production, prepend the server origin.  For now return the path
    # relative to the /uploads static mount so the Flutter client can
    # prefix the API base URL.
    return f"/uploads/{relative_path}"


async def _save_upload(
    file: UploadFile,
    sub_folder: str,
    allowed_mimes: set,
) -> tuple[str, str, int]:
    """
    Validate and persist an UploadFile.

    Returns: (relative_path, original_filename, size_bytes)
    """
    mime = file.content_type or ""
    if mime not in allowed_mimes:
        raise UnsupportedFileTypeError(mime)

    content = await file.read()
    if len(content) > MAX_FILE_SIZE_BYTES:
        raise FileTooLargeError(max_mb=20)

    ext = pathlib.Path(file.filename or "file").suffix or ".bin"
    safe_name = f"{uuid.uuid4().hex}{ext}"
    dest_dir = _build_uploads_dir(sub_folder)
    dest_path = dest_dir / safe_name

    with open(dest_path, "wb") as f:
        f.write(content)

    relative = f"medical_records/{sub_folder}/{safe_name}"
    return relative, file.filename or safe_name, len(content)


# ─── Response builders ────────────────────────────────────────────────────────

def _build_profile_response(row: UserMedicalProfile) -> MedicalProfileResponse:
    bmi = row.bmi
    if bmi is None and row.height_cm and row.weight_kg:
        h_m = row.height_cm / 100
        bmi = round(row.weight_kg / (h_m * h_m), 1)
    return MedicalProfileResponse(
        id=row.id,
        user_id=row.user_id,
        blood_group=row.blood_group,
        height_cm=row.height_cm,
        weight_kg=row.weight_kg,
        bmi=bmi,
        smoking_status=row.smoking_status,
        alcohol_status=row.alcohol_status,
        activity_level=row.activity_level,
        allergies=row.allergies or [],
        chronic_diseases=row.chronic_diseases or [],
        current_medications=row.current_medications or [],
        family_history=row.family_history or [],
        vaccination_history=row.vaccination_history or [],
        created_at=row.created_at,
        updated_at=row.updated_at,
    )


def _build_history_response(row: MedicalHistory) -> MedicalHistoryResponse:
    return MedicalHistoryResponse(
        id=row.id,
        user_id=row.user_id,
        disease_name=row.disease_name,
        category=row.category,
        diagnosis_date=row.diagnosis_date,
        status=row.status,
        doctor_name=row.doctor_name,
        hospital_name=row.hospital_name,
        notes=row.notes,
        created_at=row.created_at,
        updated_at=row.updated_at,
    )


def _build_prescription_response(row: Prescription) -> PrescriptionResponse:
    return PrescriptionResponse(
        id=row.id,
        user_id=row.user_id,
        doctor_name=row.doctor_name,
        hospital_name=row.hospital_name,
        diagnosis=row.diagnosis,
        prescription_date=row.prescription_date,
        valid_until=row.valid_until,
        medicines=row.medicines or [],
        instructions=row.instructions,
        notes=row.notes,
        file_url=_file_url(row.file_path) if row.file_path else None,
        file_original_name=row.file_original_name,
        created_at=row.created_at,
    )


def _build_image_response(row: MedicalImage) -> MedicalImageResponse:
    return MedicalImageResponse(
        id=row.id,
        user_id=row.user_id,
        title=row.title,
        image_type=row.image_type,
        description=row.description,
        body_part=row.body_part,
        doctor_name=row.doctor_name,
        hospital_name=row.hospital_name,
        scan_date=row.scan_date,
        tags=row.tags or [],
        file_url=_file_url(row.file_path) if row.file_path else None,
        file_original_name=row.file_original_name,
        file_size_bytes=row.file_size_bytes,
        created_at=row.created_at,
    )


def _build_timeline_response(row: TimelineEvent) -> TimelineEventResponse:
    return TimelineEventResponse(
        id=row.id,
        event_type=row.event_type,
        title=row.title,
        description=row.description,
        reference_id=row.reference_id,
        icon_emoji=row.icon_emoji,
        event_date=row.event_date,
        created_at=row.created_at,
    )


# ─── Timeline helper ──────────────────────────────────────────────────────────

async def _add_timeline_event(
    db: AsyncSession,
    user_id: str,
    event_type: str,
    title: str,
    description: Optional[str] = None,
    reference_id: Optional[str] = None,
    event_date: Optional[datetime] = None,
) -> None:
    """Fire-and-forget timeline insertion (non-fatal on failure)."""
    try:
        emoji = _TIMELINE_EMOJIS.get(event_type, "📋")
        event = TimelineEvent(
            user_id=user_id,
            event_type=event_type,
            title=title,
            description=description,
            reference_id=reference_id,
            icon_emoji=emoji,
            event_date=event_date or datetime.now(timezone.utc),
        )
        await TimelineRepository.create(db, event)
    except Exception as exc:
        logger.warning("Timeline event creation failed: %s", exc)


# ─── Medical Profile Service ──────────────────────────────────────────────────

class MedicalProfileService:

    @staticmethod
    async def get_or_create(
        db: AsyncSession, user_id: str
    ) -> MedicalProfileResponse:
        row = await MedicalProfileRepository.get_by_user(db, user_id)
        if row is None:
            row = UserMedicalProfile(user_id=user_id)
            row = await MedicalProfileRepository.create(db, row)
        return _build_profile_response(row)

    @staticmethod
    async def upsert(
        db: AsyncSession,
        user_id: str,
        payload: MedicalProfileUpsert,
    ) -> MedicalProfileResponse:
        row = await MedicalProfileRepository.get_by_user(db, user_id)
        if row is None:
            row = UserMedicalProfile(user_id=user_id)
            db.add(row)

        # Apply updates
        if payload.blood_group is not None:
            row.blood_group = payload.blood_group
        if payload.height_cm is not None:
            row.height_cm = payload.height_cm
        if payload.weight_kg is not None:
            row.weight_kg = payload.weight_kg
        if payload.smoking_status is not None:
            row.smoking_status = payload.smoking_status
        if payload.alcohol_status is not None:
            row.alcohol_status = payload.alcohol_status
        if payload.activity_level is not None:
            row.activity_level = payload.activity_level

        row.allergies            = payload.allergies
        row.chronic_diseases     = payload.chronic_diseases
        row.current_medications  = payload.current_medications
        row.family_history       = payload.family_history
        row.vaccination_history  = payload.vaccination_history

        # Compute BMI if both values are present
        if row.height_cm and row.weight_kg:
            h_m = row.height_cm / 100
            row.bmi = round(row.weight_kg / (h_m * h_m), 1)

        await db.commit()
        await db.refresh(row)
        return _build_profile_response(row)


# ─── Medical History Service ──────────────────────────────────────────────────

class MedicalHistoryService:

    @staticmethod
    async def list_history(
        db: AsyncSession,
        user_id: str,
        category: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> List[MedicalHistoryResponse]:
        rows = await MedicalHistoryRepository.get_by_user(
            db, user_id, category=category, limit=limit, offset=offset
        )
        return [_build_history_response(r) for r in rows]

    @staticmethod
    async def create(
        db: AsyncSession,
        user_id: str,
        payload: MedicalHistoryCreate,
    ) -> MedicalHistoryResponse:
        row = MedicalHistory(
            user_id=user_id,
            disease_name=payload.disease_name,
            category=payload.category,
            diagnosis_date=payload.diagnosis_date,
            status=payload.status,
            doctor_name=payload.doctor_name,
            hospital_name=payload.hospital_name,
            notes=payload.notes,
        )
        saved = await MedicalHistoryRepository.create(db, row)
        await _add_timeline_event(
            db,
            user_id=user_id,
            event_type="medical_history",
            title=f"Medical history added: {payload.disease_name}",
            description=payload.notes,
            reference_id=saved.id,
            event_date=payload.diagnosis_date,
        )
        return _build_history_response(saved)

    @staticmethod
    async def update(
        db: AsyncSession,
        history_id: str,
        user_id: str,
        payload: MedicalHistoryUpdate,
    ) -> MedicalHistoryResponse:
        row = await MedicalHistoryRepository.get_by_id(db, history_id)
        if row is None:
            raise RecordNotFoundError(history_id, "Medical history")
        if row.user_id != user_id:
            raise UnauthorizedRecordAccessError()

        if payload.disease_name is not None:
            row.disease_name = payload.disease_name
        if payload.category is not None:
            row.category = payload.category
        if payload.diagnosis_date is not None:
            row.diagnosis_date = payload.diagnosis_date
        if payload.status is not None:
            row.status = payload.status
        if payload.doctor_name is not None:
            row.doctor_name = payload.doctor_name
        if payload.hospital_name is not None:
            row.hospital_name = payload.hospital_name
        if payload.notes is not None:
            row.notes = payload.notes

        saved = await MedicalHistoryRepository.update(db, row)
        return _build_history_response(saved)

    @staticmethod
    async def delete(
        db: AsyncSession, history_id: str, user_id: str
    ) -> None:
        row = await MedicalHistoryRepository.get_by_id(db, history_id)
        if row is None:
            raise RecordNotFoundError(history_id, "Medical history")
        if row.user_id != user_id:
            raise UnauthorizedRecordAccessError()
        await MedicalHistoryRepository.delete(db, row)


# ─── Prescription Service ─────────────────────────────────────────────────────

class PrescriptionService:

    @staticmethod
    async def list_prescriptions(
        db: AsyncSession,
        user_id: str,
        limit: int = 50,
        offset: int = 0,
    ) -> List[PrescriptionResponse]:
        rows = await PrescriptionRepository.get_by_user(db, user_id, limit, offset)
        return [_build_prescription_response(r) for r in rows]

    @staticmethod
    async def create(
        db: AsyncSession,
        user_id: str,
        payload: PrescriptionCreate,
        file: Optional[UploadFile] = None,
    ) -> PrescriptionResponse:
        file_path = None
        file_original_name = None
        file_mime = None

        if file and file.filename:
            file_path, file_original_name, _ = await _save_upload(
                file, "prescriptions", ALLOWED_DOCUMENT_MIMES
            )
            file_mime = file.content_type

        row = Prescription(
            user_id=user_id,
            doctor_name=payload.doctor_name,
            hospital_name=payload.hospital_name,
            diagnosis=payload.diagnosis,
            prescription_date=payload.prescription_date,
            valid_until=payload.valid_until,
            medicines=[m.model_dump() for m in payload.medicines],
            instructions=payload.instructions,
            notes=payload.notes,
            file_path=file_path,
            file_original_name=file_original_name,
            file_mime_type=file_mime,
        )
        saved = await PrescriptionRepository.create(db, row)
        await _add_timeline_event(
            db,
            user_id=user_id,
            event_type="prescription",
            title=f"Prescription added: {payload.diagnosis or 'New prescription'}",
            description=f"Dr. {payload.doctor_name}" if payload.doctor_name else None,
            reference_id=saved.id,
            event_date=payload.prescription_date,
        )
        return _build_prescription_response(saved)

    @staticmethod
    async def delete(
        db: AsyncSession, prescription_id: str, user_id: str
    ) -> None:
        row = await PrescriptionRepository.get_by_id(db, prescription_id)
        if row is None:
            raise RecordNotFoundError(prescription_id, "Prescription")
        if row.user_id != user_id:
            raise UnauthorizedRecordAccessError()
        # Remove file if stored
        if row.file_path:
            full = _UPLOADS_BASE.parent.parent / "uploads" / row.file_path.lstrip("/uploads/")
            try:
                if full.exists():
                    full.unlink()
            except OSError:
                pass
        await PrescriptionRepository.delete(db, row)


# ─── Medical Image Service ────────────────────────────────────────────────────

class MedicalImageService:

    @staticmethod
    async def list_images(
        db: AsyncSession,
        user_id: str,
        image_type: Optional[str] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[MedicalImageResponse]:
        rows = await MedicalImageRepository.get_by_user(
            db, user_id, image_type=image_type, limit=limit, offset=offset
        )
        return [_build_image_response(r) for r in rows]

    @staticmethod
    async def upload(
        db: AsyncSession,
        user_id: str,
        metadata: MedicalImageCreate,
        file: Optional[UploadFile] = None,
    ) -> MedicalImageResponse:
        file_path = None
        file_original_name = None
        file_size = None

        # Map image_type to sub-folder
        _type_folder = {
            "xray": "xray",
            "mri": "mri",
            "ct_scan": "ct_scan",
            "blood_report": "blood_reports",
            "ecg": "reports",
            "skin": "reports",
            "other": "reports",
        }
        sub = _type_folder.get(metadata.image_type, "reports")

        if file and file.filename:
            file_path, file_original_name, file_size = await _save_upload(
                file, sub, ALLOWED_IMAGE_MIMES | ALLOWED_DOCUMENT_MIMES
            )

        row = MedicalImage(
            user_id=user_id,
            title=metadata.title,
            image_type=metadata.image_type,
            description=metadata.description,
            body_part=metadata.body_part,
            doctor_name=metadata.doctor_name,
            hospital_name=metadata.hospital_name,
            scan_date=metadata.scan_date,
            tags=metadata.tags,
            file_path=file_path,
            file_original_name=file_original_name,
            file_mime_type=file.content_type if file else None,
            file_size_bytes=file_size,
        )
        saved = await MedicalImageRepository.create(db, row)
        await _add_timeline_event(
            db,
            user_id=user_id,
            event_type="medical_image",
            title=f"{metadata.image_type.upper()} uploaded: {metadata.title}",
            description=metadata.description,
            reference_id=saved.id,
            event_date=metadata.scan_date,
        )
        return _build_image_response(saved)

    @staticmethod
    async def delete(
        db: AsyncSession, image_id: str, user_id: str
    ) -> None:
        row = await MedicalImageRepository.get_by_id(db, image_id)
        if row is None:
            raise RecordNotFoundError(image_id, "Medical image")
        if row.user_id != user_id:
            raise UnauthorizedRecordAccessError()
        if row.file_path:
            full = _UPLOADS_BASE.parent.parent / "uploads" / row.file_path.lstrip("/uploads/")
            try:
                if full.exists():
                    full.unlink()
            except OSError:
                pass
        await MedicalImageRepository.delete(db, row)


# ─── Timeline Service ─────────────────────────────────────────────────────────

class TimelineService:

    @staticmethod
    async def get_timeline(
        db: AsyncSession,
        user_id: str,
        limit: int = 50,
        offset: int = 0,
        event_type: Optional[str] = None,
    ) -> TimelineResponse:
        rows = await TimelineRepository.get_by_user(
            db, user_id, limit=limit, offset=offset, event_type=event_type
        )
        total = await TimelineRepository.count_by_user(db, user_id)
        return TimelineResponse(
            total=total,
            events=[_build_timeline_response(r) for r in rows],
        )

    @staticmethod
    async def record_external_event(
        db: AsyncSession,
        user_id: str,
        event_type: str,
        title: str,
        description: Optional[str] = None,
        reference_id: Optional[str] = None,
        event_date: Optional[datetime] = None,
    ) -> TimelineEventResponse:
        """
        Called by other modules (symptom checker, chatbot, emergency)
        to push an event onto the user's medical timeline.
        """
        emoji = _TIMELINE_EMOJIS.get(event_type, "📋")
        event = TimelineEvent(
            user_id=user_id,
            event_type=event_type,
            title=title,
            description=description,
            reference_id=reference_id,
            icon_emoji=emoji,
            event_date=event_date or datetime.now(timezone.utc),
        )
        saved = await TimelineRepository.create(db, event)
        return _build_timeline_response(saved)


# ─── Summary Service ──────────────────────────────────────────────────────────

class HealthRecordsSummaryService:

    @staticmethod
    async def get_summary(
        db: AsyncSession, user_id: str
    ) -> HealthRecordsSummary:
        profile = await MedicalProfileRepository.get_by_user(db, user_id)
        history_count = await MedicalHistoryRepository.count_by_user(db, user_id)
        rx_count      = await PrescriptionRepository.count_by_user(db, user_id)
        img_count     = await MedicalImageRepository.count_by_user(db, user_id)
        recent        = await TimelineRepository.get_recent(db, user_id, limit=5)

        return HealthRecordsSummary(
            has_profile=profile is not None,
            medical_history_count=history_count,
            prescription_count=rx_count,
            medical_image_count=img_count,
            recent_timeline=[_build_timeline_response(r) for r in recent],
        )
