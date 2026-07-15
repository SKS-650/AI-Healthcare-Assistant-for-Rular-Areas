"""Business logic for the offline_sync module."""

from __future__ import annotations

import json
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from .constants import (
    DEFAULT_CACHE_TTL_HOURS,
    MAX_HISTORY_ENTRIES,
    STATUS_FAILED,
    STATUS_PARTIAL,
    STATUS_SUCCESS,
    VALID_OPERATION_TYPES,
)
from .exceptions import InvalidPayloadError
from .models import (
    CachedApiResponseModel,
    LocalSettingsModel,
    OfflineQueueModel,
    SyncHistoryModel,
)
from .schemas import (
    LocalSettingsIn,
    QueueItemIn,
    SyncDownloadResponse,
    SyncHistoryOut,
    SyncUploadResponse,
)


class OfflineSyncService:
    """Handles all server-side sync operations."""

    # ── Upload (client → server) ──────────────────────────────────────────────

    async def process_upload(
        self,
        db: AsyncSession,
        user_id: str,
        items: list[QueueItemIn],
    ) -> SyncUploadResponse:
        """Process a batch of pending operations from the mobile client."""

        start    = datetime.now(timezone.utc)
        synced   = 0
        failed   = 0
        results  = []

        for item in items:
            try:
                # Validate operation type
                if item.operation_type not in VALID_OPERATION_TYPES:
                    raise InvalidPayloadError(
                        f"Unknown operation_type: {item.operation_type}"
                    )

                # Parse payload
                try:
                    payload = json.loads(item.payload)
                except json.JSONDecodeError as exc:
                    raise InvalidPayloadError(
                        f"Invalid JSON payload for item {item.id}"
                    ) from exc

                # Dispatch to the right handler
                await self._dispatch(db, user_id, item.operation_type, payload)

                # Mark completed in queue table (upsert)
                await self._upsert_queue_item(db, user_id, item, status="completed")
                synced += 1
                results.append({"id": item.id, "status": "completed"})

            except Exception as exc:  # noqa: BLE001
                failed += 1
                results.append({"id": item.id, "status": "failed", "error": str(exc)})
                await self._upsert_queue_item(
                    db, user_id, item, status="failed", error=str(exc)
                )

        # Persist sync history
        duration_ms = int(
            (datetime.now(timezone.utc) - start).total_seconds() * 1000
        )
        status = (
            STATUS_SUCCESS if failed == 0
            else STATUS_PARTIAL if synced > 0
            else STATUS_FAILED
        )
        await self._add_history(
            db, user_id,
            sync_type="upload",
            status=status,
            synced=synced,
            failed=failed,
            duration_ms=duration_ms,
        )

        # Update last_sync_at in settings
        await self._touch_last_sync(db, user_id)
        await db.commit()

        return SyncUploadResponse(
            status=status,
            synced_items=synced,
            failed_items=failed,
            results=results,
            last_sync=datetime.now(timezone.utc),
        )

    # ── Download (server → client) ────────────────────────────────────────────

    async def build_download_payload(
        self,
        db: AsyncSession,
        user_id: str,
    ) -> SyncDownloadResponse:
        """Assemble data the client should pull down."""

        # Record download history
        await self._add_history(
            db, user_id,
            sync_type="download",
            status=STATUS_SUCCESS,
            synced=1,
            failed=0,
        )
        await self._touch_last_sync(db, user_id)
        await db.commit()

        return SyncDownloadResponse(
            status="success",
            synced_items=1,
            last_sync=datetime.now(timezone.utc),
            # Extend here to include updated records / articles
            symptom_data=None,
            articles_meta=[],
        )

    # ── Sync history ──────────────────────────────────────────────────────────

    async def get_history(
        self,
        db: AsyncSession,
        user_id: str,
        limit: int = 30,
    ) -> list[SyncHistoryOut]:
        result = await db.execute(
            select(SyncHistoryModel)
            .where(SyncHistoryModel.user_id == user_id)
            .order_by(SyncHistoryModel.created_at.desc())
            .limit(limit)
        )
        rows = result.scalars().all()
        return [SyncHistoryOut.model_validate(r) for r in rows]

    # ── Settings ──────────────────────────────────────────────────────────────

    async def get_or_create_settings(
        self, db: AsyncSession, user_id: str
    ) -> LocalSettingsModel:
        result = await db.execute(
            select(LocalSettingsModel).where(
                LocalSettingsModel.user_id == user_id
            )
        )
        row = result.scalar_one_or_none()
        if row is None:
            row = LocalSettingsModel(
                id=str(uuid.uuid4()), user_id=user_id
            )
            db.add(row)
            await db.commit()
            await db.refresh(row)
        return row

    async def update_settings(
        self,
        db: AsyncSession,
        user_id: str,
        data: LocalSettingsIn,
    ) -> LocalSettingsModel:
        row = await self.get_or_create_settings(db, user_id)
        for field, value in data.model_dump().items():
            setattr(row, field, value)
        await db.commit()
        await db.refresh(row)
        return row

    # ── Response cache ─────────────────────────────────────────────────────────

    async def get_cached_response(
        self, db: AsyncSession, cache_key: str
    ) -> CachedApiResponseModel | None:
        result = await db.execute(
            select(CachedApiResponseModel).where(
                CachedApiResponseModel.cache_key == cache_key
            )
        )
        row = result.scalar_one_or_none()
        if row and row.is_expired:
            await db.delete(row)
            await db.commit()
            return None
        return row

    async def set_cached_response(
        self,
        db: AsyncSession,
        cache_key: str,
        response_body: str,
        ttl_hours: int = DEFAULT_CACHE_TTL_HOURS,
    ) -> CachedApiResponseModel:
        # Remove old entry if present
        await db.execute(
            delete(CachedApiResponseModel).where(
                CachedApiResponseModel.cache_key == cache_key
            )
        )
        expiry = datetime.now(timezone.utc) + timedelta(hours=ttl_hours)
        row = CachedApiResponseModel(
            id=str(uuid.uuid4()),
            cache_key=cache_key,
            response=response_body,
            expiration_time=expiry,
        )
        db.add(row)
        await db.commit()
        await db.refresh(row)
        return row

    # ── Private helpers ───────────────────────────────────────────────────────

    async def _dispatch(
        self,
        db: AsyncSession,
        user_id: str,
        operation_type: str,
        payload: dict,
    ) -> None:
        """Route an operation to the appropriate handler.

        Extend this with real persistence logic per operation type.
        Currently a no-op placeholder — the queue item is marked
        completed so the client removes it from its own queue.
        """
        # Map operation types to handlers as the feature set grows.
        handlers = {
            "save_assessment":  self._noop,
            "save_chat_message": self._noop,
            "save_bookmark":    self._noop,
            "update_profile":   self._noop,
            "save_preference":  self._noop,
            "create_record":    self._noop,
            "update_record":    self._noop,
            "delete_record":    self._noop,
            "upload_report":    self._noop,
        }
        handler = handlers.get(operation_type, self._noop)
        await handler(db, user_id, payload)

    @staticmethod
    async def _noop(
        _db: AsyncSession, _user_id: str, _payload: dict
    ) -> None:
        """Placeholder — operation acknowledged, no server action required."""

    async def _upsert_queue_item(
        self,
        db: AsyncSession,
        user_id: str,
        item: QueueItemIn,
        status: str,
        error: str | None = None,
    ) -> None:
        result = await db.execute(
            select(OfflineQueueModel).where(OfflineQueueModel.id == item.id)
        )
        row = result.scalar_one_or_none()
        if row is None:
            row = OfflineQueueModel(
                id=item.id,
                user_id=user_id,
                operation_type=item.operation_type,
                endpoint=item.endpoint,
                payload=item.payload,
            )
            db.add(row)
        row.status        = status
        row.retry_count   = item.retry_count
        row.error_message = error

    async def _add_history(
        self,
        db: AsyncSession,
        user_id: str,
        sync_type: str,
        status: str,
        synced: int,
        failed: int,
        duration_ms: int | None = None,
        details: str | None = None,
    ) -> None:
        row = SyncHistoryModel(
            id=str(uuid.uuid4()),
            user_id=user_id,
            sync_type=sync_type,
            status=status,
            synced_items=synced,
            failed_items=failed,
            duration_ms=duration_ms,
            details=details,
        )
        db.add(row)

        # Trim history to cap
        result = await db.execute(
            select(SyncHistoryModel.id)
            .where(SyncHistoryModel.user_id == user_id)
            .order_by(SyncHistoryModel.created_at.asc())
        )
        ids = result.scalars().all()
        if len(ids) > MAX_HISTORY_ENTRIES:
            to_delete = ids[: len(ids) - MAX_HISTORY_ENTRIES]
            await db.execute(
                delete(SyncHistoryModel).where(SyncHistoryModel.id.in_(to_delete))
            )

    async def _touch_last_sync(self, db: AsyncSession, user_id: str) -> None:
        settings = await self.get_or_create_settings(db, user_id)
        settings.last_sync_at = datetime.now(timezone.utc)
