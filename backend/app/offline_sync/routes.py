"""FastAPI router for offline sync endpoints.

Endpoints:
    POST /offline/sync/      – full bidirectional sync
    POST /offline/upload/    – upload pending queue items
    GET  /offline/download/  – download updates from server
    GET  /offline/history/   – sync history for the current user
    GET  /offline/settings/  – get offline settings
    PUT  /offline/settings/  – update offline settings
    GET  /offline/health/    – module health check
"""

from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.connection import get_async_session as get_db
from app.auth.dependencies import get_current_user

from .schemas import (
    FullSyncResponse,
    LocalSettingsIn,
    LocalSettingsOut,
    SyncDownloadResponse,
    SyncHistoryListResponse,
    SyncUploadRequest,
    SyncUploadResponse,
)
from .services import OfflineSyncService

router = APIRouter(prefix="/offline", tags=["Offline Sync"])

_service = OfflineSyncService()


# ── Upload ────────────────────────────────────────────────────────────────────

@router.post(
    "/upload/",
    response_model=SyncUploadResponse,
    status_code=status.HTTP_200_OK,
    summary="Upload pending offline operations to the server",
)
async def upload_queue(
    body: SyncUploadRequest,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> SyncUploadResponse:
    """Process a batch of queue items from the mobile client."""
    return await _service.process_upload(
        db=db,
        user_id=str(current_user.id),
        items=body.items,
    )


# ── Download ──────────────────────────────────────────────────────────────────

@router.get(
    "/download/",
    response_model=SyncDownloadResponse,
    summary="Download updated data from the server",
)
async def download_updates(
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> SyncDownloadResponse:
    """Fetch the latest data that the mobile client should cache."""
    return await _service.build_download_payload(
        db=db,
        user_id=str(current_user.id),
    )


# ── Full sync ─────────────────────────────────────────────────────────────────

@router.post(
    "/sync/",
    response_model=FullSyncResponse,
    summary="Trigger a full bidirectional sync",
)
async def full_sync(
    body: SyncUploadRequest,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> FullSyncResponse:
    """Upload pending items then return updated data in one round-trip."""
    upload_result = await _service.process_upload(
        db=db,
        user_id=str(current_user.id),
        items=body.items,
    )
    return FullSyncResponse(
        status=upload_result.status,
        synced_items=upload_result.synced_items,
        failed_items=upload_result.failed_items,
        last_sync=datetime.now(timezone.utc),
        message=(
            f"Synced {upload_result.synced_items} items"
            + (
                f", {upload_result.failed_items} failed"
                if upload_result.failed_items
                else ""
            )
        ),
    )


# ── History ───────────────────────────────────────────────────────────────────

@router.get(
    "/history/",
    response_model=SyncHistoryListResponse,
    summary="Get sync history for the current user",
)
async def get_sync_history(
    limit: int = 30,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> SyncHistoryListResponse:
    history = await _service.get_history(
        db=db,
        user_id=str(current_user.id),
        limit=min(limit, 100),
    )
    return SyncHistoryListResponse(history=history, total=len(history))


# ── Settings ──────────────────────────────────────────────────────────────────

@router.get(
    "/settings/",
    response_model=LocalSettingsOut,
    summary="Get offline settings for the current user",
)
async def get_settings(
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> LocalSettingsOut:
    row = await _service.get_or_create_settings(
        db=db, user_id=str(current_user.id)
    )
    return LocalSettingsOut.model_validate(row)


@router.put(
    "/settings/",
    response_model=LocalSettingsOut,
    summary="Update offline settings for the current user",
)
async def update_settings(
    body: LocalSettingsIn,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> LocalSettingsOut:
    row = await _service.update_settings(
        db=db, user_id=str(current_user.id), data=body
    )
    return LocalSettingsOut.model_validate(row)


# ── Health ────────────────────────────────────────────────────────────────────

@router.get(
    "/health/",
    summary="Offline sync module health check",
)
async def health() -> dict:
    return {
        "status":  "ok",
        "module":  "offline_sync",
        "version": "1.0.0",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
