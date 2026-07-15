"""
Emergency API routes.

All routes mounted under /api/v1/emergency.

Endpoints:
  POST   /assessment                — Run AI emergency assessment
  GET    /history                   — Get user's assessment history
  GET    /assessment/{id}           — Get a specific assessment
  GET    /contacts                  — List emergency contacts
  POST   /contacts                  — Create emergency contact
  PUT    /contacts/{id}             — Update emergency contact
  DELETE /contacts/{id}             — Delete emergency contact
  POST   /sos                       — Trigger SOS alert
  GET    /first-aid                 — Get all first aid guides
  GET    /health                    — Module health check
"""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.dependencies import CurrentUser, OptionalUser
from app.database.connection import get_async_session as get_db
from app.emergency.schemas import (
    AssessmentHistoryResponse,
    EmergencyAssessmentRequest,
    EmergencyAssessmentResponse,
    EmergencyContactCreate,
    EmergencyContactResponse,
    EmergencyContactUpdate,
    FirstAidListResponse,
    SosRequest,
    SosResponse,
)
from app.emergency.services import (
    EmergencyAssessmentService,
    EmergencyContactService,
    FirstAidService,
    SosService,
)

router = APIRouter(prefix="/emergency", tags=["Emergency"])


# ─── Assessment ───────────────────────────────────────────────────────────────

@router.post(
    "/assessment",
    response_model=EmergencyAssessmentResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Run emergency assessment",
    description=(
        "Runs the AI emergency pipeline on the provided symptoms and patient data. "
        "Returns risk score, risk level, first aid guidance, and hospital recommendations. "
        "Authentication is optional — anonymous assessments are stored without a user link."
    ),
)
async def run_assessment(
    payload: EmergencyAssessmentRequest,
    current_user: OptionalUser,
    db: AsyncSession = Depends(get_db),
) -> EmergencyAssessmentResponse:
    user_id = current_user.id if current_user else None
    return await EmergencyAssessmentService.run_assessment(db, payload, user_id)


@router.get(
    "/history",
    response_model=AssessmentHistoryResponse,
    summary="Get assessment history",
    description="Returns the authenticated user's past emergency assessments.",
)
async def get_history(
    current_user: CurrentUser,
    limit: int  = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0,  ge=0),
    db: AsyncSession = Depends(get_db),
) -> AssessmentHistoryResponse:
    return await EmergencyAssessmentService.get_history(db, current_user.id, limit, offset)


@router.get(
    "/assessment/{assessment_id}",
    response_model=EmergencyAssessmentResponse,
    summary="Get assessment by ID",
    description="Retrieves a specific emergency assessment. Authenticated users can only see their own.",
)
async def get_assessment(
    assessment_id: str,
    current_user: OptionalUser,
    db: AsyncSession = Depends(get_db),
) -> EmergencyAssessmentResponse:
    user_id = current_user.id if current_user else None
    return await EmergencyAssessmentService.get_assessment(db, assessment_id, user_id)


# ─── Emergency Contacts ───────────────────────────────────────────────────────

@router.get(
    "/contacts",
    response_model=list[EmergencyContactResponse],
    summary="List emergency contacts",
)
async def list_contacts(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> list[EmergencyContactResponse]:
    return await EmergencyContactService.list_contacts(db, current_user.id)


@router.post(
    "/contacts",
    response_model=EmergencyContactResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create emergency contact",
)
async def create_contact(
    payload: EmergencyContactCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> EmergencyContactResponse:
    return await EmergencyContactService.create_contact(db, current_user.id, payload)


@router.put(
    "/contacts/{contact_id}",
    response_model=EmergencyContactResponse,
    summary="Update emergency contact",
)
async def update_contact(
    contact_id: str,
    payload: EmergencyContactUpdate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> EmergencyContactResponse:
    return await EmergencyContactService.update_contact(db, contact_id, current_user.id, payload)


@router.delete(
    "/contacts/{contact_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    response_model=None,
    summary="Delete emergency contact",
)
async def delete_contact(
    contact_id: str,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> None:
    await EmergencyContactService.delete_contact(db, contact_id, current_user.id)


# ─── SOS ─────────────────────────────────────────────────────────────────────

@router.post(
    "/sos",
    response_model=SosResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Trigger SOS alert",
    description=(
        "Sends an SOS alert to all registered emergency contacts. "
        "Rate-limited to prevent accidental triggers."
    ),
)
async def trigger_sos(
    payload: SosRequest,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> SosResponse:
    return await SosService.trigger_sos(db, current_user.id, payload)


# ─── First Aid ────────────────────────────────────────────────────────────────

@router.get(
    "/first-aid",
    response_model=FirstAidListResponse,
    summary="Get all first aid guides",
    description="Returns offline-safe first aid instructions for all emergency categories.",
)
async def get_first_aid_guides() -> FirstAidListResponse:
    return FirstAidService.get_all_guides()


# ─── Health ───────────────────────────────────────────────────────────────────

@router.get(
    "/health",
    summary="Emergency module health check",
    tags=["Health"],
)
async def health() -> dict[str, str]:
    return {"status": "ok", "module": "emergency"}
