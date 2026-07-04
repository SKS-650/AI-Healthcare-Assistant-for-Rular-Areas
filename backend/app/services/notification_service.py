"""Notification service.

Handles sending notifications (push/SMS/email) and notification persistence.

Current implementation is placeholder-only and safe to import.
"""

from __future__ import annotations

from typing import Any, Optional


class NotificationService:
    """Service layer for notifications."""

    def send(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Send a notification.

        Args:
            payload: Expected keys (optional):
              - user_id
              - channel: 'push' | 'sms' | 'email'
              - title
              - message
              - metadata

        Returns:
            Serializable dict.
        """

        channel = payload.get("channel") or "push"
        user_id = payload.get("user_id")

        # Placeholder sending.
        return {
            "status": "mocked",
            "result": {
                "channel": channel,
                "user_id": user_id,
                "title": payload.get("title"),
                "message": payload.get("message"),
            },
        }

    def schedule(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Schedule a notification for later (placeholder)."""

        return {
            "status": "mocked",
            "result": {
                "scheduled_for": payload.get("scheduled_for"),
                "payload": payload,
            },
        }

