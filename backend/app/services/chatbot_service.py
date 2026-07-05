"""Medical chatbot service.

Provides business logic for handling medical chat requests.

Current implementation is a lightweight placeholder that keeps the module
import-safe and framework-agnostic.
"""

from __future__ import annotations

from dataclasses import asdict
from typing import Any, Optional

from app.models.chat import ChatMessage, ChatResponse


class ChatbotService:
    """Service layer for medical chat."""

    def chat(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Generate a medical chat response.

        Args:
            payload: Free-form dictionary coming from API/WebSocket layer.

        Returns:
            Serializable dict response.
        """

        user_message = payload.get("message") or payload.get("content")
        if not isinstance(user_message, str) or not user_message.strip():
            user_message = ""

        # Placeholder response.
        response_text = (
            "I can help with medical information. "
            "This is a placeholder response—connect your AI model here."
        )

        msg = ChatMessage(role="assistant", content=response_text)
        resp = ChatResponse(message=msg, references=[])

        return {
            "status": "mocked",
            "result": asdict(resp),
            "echo": {"user_message": user_message} if user_message else {},
        }

    def summarize(self, payload: dict[str, Any]) -> dict[str, Any]:
        """Optional helper to summarize a chat context.

        Kept for future extension.
        """

        text = payload.get("text")
        if isinstance(text, str) and text.strip():
            summary = text[:200] + ("..." if len(text) > 200 else "")
        else:
            summary = ""

        return {"status": "mocked", "summary": summary}

