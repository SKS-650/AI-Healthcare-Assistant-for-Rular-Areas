"""
Medical Records (PHR) API routes.

All routes mounted under /api/v1/health-records.

Endpoints:
  GET    /summary                     — Dashboard summary
  GET    /profile                     — Get medical profile
  PUT    /profile                     — Upsert medical profile

  GET    /history                     — List medical history entries
  POST   /history                     — Create history entry
  PUT    /history/{id}                — Update history entry
  DELETE /history/{id}                — Delete history entry

  GET    /prescriptions               — List prescriptions
  POST   /prescriptions               — Create prescription (+ optional file)
  DELETE /prescriptions/{id}          — Delete prescription

  GET    /images                      — List medical images
  POST   /images                      — Upload medical image
  DELETE /images/{id}                 — Delete medical image

  GET    /timeline                    — Get unified medical timeline
  POST   /timeline/external           — Push external event (inter-module)
  GET    /health                      — Module health check
"""

from __future__ import annotations

import json
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, Query, Request, Response, UploadFile, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import CurrentUser
from app.database.connection import get_async_session as get_db
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
from app.health_records.services import (
    HealthRecordsSummaryService,
    MedicalHistoryService,
    MedicalImageService,
    MedicalProfileService,
    PrescriptionService,
    TimelineService,
)

router = APIRouter(prefix="/health-records", tags=["Medical Records"])


# ─── Helper: detect JSON vs multipart ────────────────────────────────────────

def _is_json(request: Request) -> bool:
    ct = request.headers.get("content-type", "")
    return "application/json" in ct


# ─── Dashboard summary ────────────────────────────────────────────────────────

@router.get(
    "/summary",
    response_model=HealthRecordsSummary,
    summary="Health records dashboard summary",
)
async def get_summary(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> HealthRecordsSummary:
    return await HealthRecordsSummaryService.get_summary(db, current_user.id)


# ─── Medical Profile ──────────────────────────────────────────────────────────

@router.get(
    "/profile",
    response_model=MedicalProfileResponse,
    summary="Get medical profile",
    description="Returns the user's health baseline. Creates an empty one on first access.",
)
async def get_profile(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> MedicalProfileResponse:
    return await MedicalProfileService.get_or_create(db, current_user.id)


@router.put(
    "/profile",
    response_model=MedicalProfileResponse,
    summary="Create or update medical profile",
)
async def upsert_profile(
    payload: MedicalProfileUpsert,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> MedicalProfileResponse:
    return await MedicalProfileService.upsert(db, current_user.id, payload)


# ─── Medical History ──────────────────────────────────────────────────────────

@router.get(
    "/history",
    response_model=list[MedicalHistoryResponse],
    summary="List medical history",
)
async def list_history(
    current_user: CurrentUser,
    category: Optional[str] = Query(default=None),
    limit:    int           = Query(default=100, ge=1, le=200),
    offset:   int           = Query(default=0, ge=0),
    db: AsyncSession = Depends(get_db),
) -> list[MedicalHistoryResponse]:
    return await MedicalHistoryService.list_history(
        db, current_user.id, category=category, limit=limit, offset=offset
    )


@router.post(
    "/history",
    response_model=MedicalHistoryResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add medical history entry",
)
async def create_history(
    payload: MedicalHistoryCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> MedicalHistoryResponse:
    return await MedicalHistoryService.create(db, current_user.id, payload)


@router.put(
    "/history/{history_id}",
    response_model=MedicalHistoryResponse,
    summary="Update medical history entry",
)
async def update_history(
    history_id: str,
    payload: MedicalHistoryUpdate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> MedicalHistoryResponse:
    return await MedicalHistoryService.update(db, history_id, current_user.id, payload)


@router.delete(
    "/history/{history_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete medical history entry",
)
async def delete_history(
    history_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    await MedicalHistoryService.delete(db, history_id, current_user.id)


# ─── Prescriptions ────────────────────────────────────────────────────────────

@router.get(
    "/prescriptions",
    response_model=list[PrescriptionResponse],
    summary="List prescriptions",
)
async def list_prescriptions(
    current_user: CurrentUser,
    limit:  int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    db: AsyncSession = Depends(get_db),
) -> list[PrescriptionResponse]:
    return await PrescriptionService.list_prescriptions(
        db, current_user.id, limit=limit, offset=offset
    )


@router.post(
    "/prescriptions",
    response_model=PrescriptionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload prescription",
    description=(
        "Create a prescription record with an optional PDF/image file. "
        "Accepts application/json (no file) or multipart/form-data "
        "(metadata JSON string in the 'metadata' field, optional file)."
    ),
)
async def create_prescription(
    request: Request,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> PrescriptionResponse:
    """
    Dual content-type handler — avoids the FastAPI limitation that prevents
    mixing a Pydantic body parameter with Form fields in the same function.
    """
    file: Optional[UploadFile] = None

    if _is_json(request):
        # Mobile app path: application/json body
        raw = await request.json()
        payload = PrescriptionCreate.model_validate(raw)
    else:
        # Multipart path: metadata field (JSON string) + optional file
        form = await request.form()
        metadata_str = form.get("metadata", "{}")
        payload = PrescriptionCreate.model_validate_json(
            metadata_str if metadata_str else "{}"
        )
        uploaded = form.get("file")
        if uploaded and hasattr(uploaded, "filename"):
            file = uploaded  # type: ignore[assignment]

    return await PrescriptionService.create(db, current_user.id, payload, file=file)


@router.delete(
    "/prescriptions/{prescription_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete prescription",
)
async def delete_prescription(
    prescription_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    await PrescriptionService.delete(db, prescription_id, current_user.id)


# ─── Medical Images ───────────────────────────────────────────────────────────

@router.get(
    "/images",
    response_model=list[MedicalImageResponse],
    summary="List medical images",
)
async def list_images(
    current_user: CurrentUser,
    image_type: Optional[str] = Query(default=None),
    limit:      int           = Query(default=50, ge=1, le=100),
    offset:     int           = Query(default=0, ge=0),
    db: AsyncSession = Depends(get_db),
) -> list[MedicalImageResponse]:
    return await MedicalImageService.list_images(
        db, current_user.id, image_type=image_type, limit=limit, offset=offset
    )


@router.post(
    "/images",
    response_model=MedicalImageResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload medical image / scan",
    description=(
        "Upload a medical image (X-Ray, MRI, CT, etc.) with metadata. "
        "Accepts application/json (no file) or multipart/form-data "
        "(metadata JSON string in the 'metadata' field, optional file)."
    ),
)
async def upload_image(
    request: Request,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> MedicalImageResponse:
    """Dual content-type handler — same pattern as create_prescription."""
    file: Optional[UploadFile] = None

    if _is_json(request):
        raw = await request.json()
        image_meta = MedicalImageCreate.model_validate(raw)
    else:
        form = await request.form()
        metadata_str = form.get("metadata", "{}")
        image_meta = MedicalImageCreate.model_validate_json(
            metadata_str if metadata_str else "{}"
        )
        uploaded = form.get("file")
        if uploaded and hasattr(uploaded, "filename"):
            file = uploaded  # type: ignore[assignment]

    return await MedicalImageService.upload(db, current_user.id, image_meta, file=file)


@router.delete(
    "/images/{image_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete medical image",
)
async def delete_image(
    image_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    await MedicalImageService.delete(db, image_id, current_user.id)


# ─── Timeline ─────────────────────────────────────────────────────────────────

@router.get(
    "/timeline",
    response_model=TimelineResponse,
    summary="Get unified medical timeline",
    description="Returns all health events in reverse chronological order.",
)
async def get_timeline(
    current_user: CurrentUser,
    event_type: Optional[str] = Query(default=None),
    limit:      int           = Query(default=50, ge=1, le=200),
    offset:     int           = Query(default=0, ge=0),
    db: AsyncSession = Depends(get_db),
) -> TimelineResponse:
    return await TimelineService.get_timeline(
        db, current_user.id, limit=limit, offset=offset, event_type=event_type
    )


@router.post(
    "/timeline/external",
    response_model=TimelineEventResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Push external timeline event",
    description=(
        "Called by mobile app or other backend modules to append an event to "
        "the authenticated user's medical timeline. Accepts application/json "
        "or application/x-www-form-urlencoded."
    ),
)
async def push_external_event(
    request: Request,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> TimelineEventResponse:
    """Dual content-type handler for timeline push."""
    if _is_json(request):
        data = await request.json()
        ev_type   = data.get("event_type", "")
        ev_title  = data.get("title", "")
        ev_desc   = data.get("description")
        ev_ref    = data.get("reference_id")
    else:
        form = await request.form()
        ev_type   = form.get("event_type", "")
        ev_title  = form.get("title", "")
        ev_desc   = form.get("description") or None
        ev_ref    = form.get("reference_id") or None

    return await TimelineService.record_external_event(
        db,
        user_id=current_user.id,
        event_type=str(ev_type),
        title=str(ev_title),
        description=ev_desc,
        reference_id=ev_ref,
    )


# ─── Health ───────────────────────────────────────────────────────────────────

@router.get(
    "/health",
    summary="Medical records module health check",
    tags=["Health"],
)
async def health() -> dict[str, str]:
    return {"status": "ok", "module": "health_records"}
