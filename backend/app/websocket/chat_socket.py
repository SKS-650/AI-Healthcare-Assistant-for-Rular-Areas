"""Chat WebSocket endpoint helpers."""

from __future__ import annotations

from fastapi import WebSocket


async def chat_socket(websocket: WebSocket) -> None:
    """Accept a chat WebSocket connection."""

    await websocket.accept()
    await websocket.send_json({"status": "connected", "type": "chat"})
    await websocket.close()
