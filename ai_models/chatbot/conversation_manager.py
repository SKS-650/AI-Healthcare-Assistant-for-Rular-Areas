"""Conversation state management."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class ConversationManager:
    """Stores conversation messages in memory."""

    messages: list[dict[str, str]] = field(default_factory=list)

    def add_message(self, role: str, content: str) -> None:
        """Add a message to the conversation."""

        self.messages.append({"role": role, "content": content})
