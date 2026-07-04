"""Chat domain models."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class ChatMessage:
    role: str  # "user" | "assistant" | "system"
    content: str
    message_id: Optional[str] = None

    # Optional metadata (timestamps, tool calls, etc.)
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass
class ChatResponse:
    message: ChatMessage
    # Optional citations/references, used by medical chat.
    references: list[str] = field(default_factory=list)

