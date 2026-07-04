"""Notification WebSocket endpoint helpers."""

from __future__ import annotations

from fastapi import WebSocket


async def notification_socket(websocket: WebSocket) -> None:
    """Accept a notification WebSocket connection."""

    await websocket.accept()
    await websocket.send_json({"status": "connected", "type": "notification"})
    await websocket.close()
