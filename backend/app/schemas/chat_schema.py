"""Chat API schemas.

Lightweight request/response payload shapes used by API layer code.
Kept framework-agnostic to match backend/app/models.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class ChatMessageSchema:
    """A single chat message."""

    role: str  # "user" | "assistant" | "system"
    content: str
    message_id: Optional[str] = None
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass
class ChatResponseSchema:
    """Response returned for medical chat."""

    message: ChatMessageSchema
    references: list[str] = field(default_factory=list)

