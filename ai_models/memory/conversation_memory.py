"""
Conversation Memory - Maintains rolling context for multi-turn conversations.

Stores the last N turns with metadata (intent, emergency, language) so the
chatbot can give contextually aware follow-up responses without re-reading
the full history from the database on every turn.
"""

from __future__ import annotations

import logging
import time
from collections import deque
from dataclasses import dataclass, field
from typing import Any, Deque, Dict, List, Optional

logger = logging.getLogger(__name__)

DEFAULT_MAX_TURNS = 12  # keep last 12 message pairs (~3-4 minutes of chat)
IDLE_TIMEOUT_SECONDS = 7200  # 2 hours — reset context after inactivity


@dataclass
class MemoryTurn:
    """One user + bot exchange stored in memory."""

    turn_id: int
    user_message: str
    bot_response: str
    language: str = "en"
    intent: str = "GENERAL_MEDICAL"
    is_emergency: bool = False
    timestamp: float = field(default_factory=time.time)
    metadata: Dict[str, Any] = field(default_factory=dict)


class ConversationMemory:
    """
    Rolling short-term memory for a single conversation.

    Usage
    -----
    mem = ConversationMemory(conversation_id="abc123")
    mem.add_turn("I have fever", "Drink plenty of fluids…", language="en")
    history = mem.get_history_for_prompt()   # list of dicts for LLM
    summary = mem.get_context_summary()      # compact string for RAG prompts
    """

    def __init__(
        self,
        conversation_id: str,
        max_turns: int = DEFAULT_MAX_TURNS,
    ) -> None:
        self.conversation_id = conversation_id
        self.max_turns = max_turns
        self._turns: Deque[MemoryTurn] = deque(maxlen=max_turns)
        self._turn_counter = 0
        self._last_active = time.time()
        self._primary_language = "en"
        self._detected_intents: List[str] = []

    # ─── Mutation ─────────────────────────────────────────────────────────────

    def add_turn(
        self,
        user_message: str,
        bot_response: str,
        language: str = "en",
        intent: str = "GENERAL_MEDICAL",
        is_emergency: bool = False,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> MemoryTurn:
        """Add a completed exchange to memory."""
        self._turn_counter += 1
        self._last_active = time.time()

        # Update primary language (last detected language wins)
        if language and language != "auto":
            self._primary_language = language

        # Track intent history
        self._detected_intents.append(intent)
        if len(self._detected_intents) > 20:
            self._detected_intents = self._detected_intents[-20:]

        turn = MemoryTurn(
            turn_id=self._turn_counter,
            user_message=user_message,
            bot_response=bot_response,
            language=language,
            intent=intent,
            is_emergency=is_emergency,
            metadata=metadata or {},
        )
        self._turns.append(turn)
        return turn

    def clear(self) -> None:
        """Wipe all memory (e.g. after a new topic)."""
        self._turns.clear()
        self._turn_counter = 0
        logger.info(f"Cleared memory for conversation {self.conversation_id}")

    # ─── Read ─────────────────────────────────────────────────────────────────

    def get_history_for_prompt(
        self, last_n: int = 6
    ) -> List[Dict[str, str]]:
        """
        Return the last N turns formatted for LLM prompt injection.

        Format: [{"sender": "user"|"assistant", "message": "…"}, …]
        """
        turns = list(self._turns)[-last_n:]
        history: List[Dict[str, str]] = []
        for t in turns:
            history.append({"sender": "user",      "message": t.user_message})
            history.append({"sender": "assistant", "message": t.bot_response})
        return history

    def get_context_summary(self) -> str:
        """
        One-paragraph narrative summary of recent context for RAG prompts.
        """
        if not self._turns:
            return ""

        recent = list(self._turns)[-4:]
        parts = [f"Recent conversation context ({len(self._turns)} turns total):"]
        for t in recent:
            # Truncate long messages to keep the summary compact
            user_short = t.user_message[:100] + ("…" if len(t.user_message) > 100 else "")
            bot_short  = t.bot_response[:120] + ("…" if len(t.bot_response) > 120 else "")
            parts.append(f"  User: {user_short}")
            parts.append(f"  Bot:  {bot_short}")
        return "\n".join(parts)

    def get_last_user_message(self) -> Optional[str]:
        return self._turns[-1].user_message if self._turns else None

    def get_last_intent(self) -> Optional[str]:
        return self._turns[-1].intent if self._turns else None

    def get_dominant_intent(self) -> str:
        """Return the most frequently seen intent in this session."""
        if not self._detected_intents:
            return "GENERAL_MEDICAL"
        counts: Dict[str, int] = {}
        for i in self._detected_intents:
            counts[i] = counts.get(i, 0) + 1
        return max(counts, key=counts.get)  # type: ignore[arg-type]

    def is_follow_up(self, current_message: str) -> bool:
        """
        Heuristic: message is a follow-up if it's short and there's
        existing context.
        """
        return bool(self._turns) and len(current_message.strip().split()) <= 8

    def is_idle(self) -> bool:
        return (time.time() - self._last_active) > IDLE_TIMEOUT_SECONDS

    @property
    def turn_count(self) -> int:
        return len(self._turns)

    @property
    def primary_language(self) -> str:
        return self._primary_language


# ─── Session-level Memory Store ───────────────────────────────────────────────

class MemoryStore:
    """
    In-process store for per-conversation memories.
    Keys are conversation_id strings.
    """

    def __init__(self, max_conversations: int = 500) -> None:
        self._store: Dict[str, ConversationMemory] = {}
        self._max = max_conversations

    def get(self, conversation_id: str) -> ConversationMemory:
        if conversation_id not in self._store:
            # Evict oldest if at capacity
            if len(self._store) >= self._max:
                oldest = min(
                    self._store.values(),
                    key=lambda m: m._last_active,
                )
                del self._store[oldest.conversation_id]
            self._store[conversation_id] = ConversationMemory(conversation_id)
        return self._store[conversation_id]

    def delete(self, conversation_id: str) -> None:
        self._store.pop(conversation_id, None)

    def cleanup_idle(self) -> int:
        """Remove idle conversations. Returns count removed."""
        idle = [cid for cid, mem in self._store.items() if mem.is_idle()]
        for cid in idle:
            del self._store[cid]
        if idle:
            logger.info(f"Removed {len(idle)} idle conversation memories")
        return len(idle)

    @property
    def active_count(self) -> int:
        return len(self._store)


# ─── Singletons ───────────────────────────────────────────────────────────────

_memory_store: Optional[MemoryStore] = None


def get_memory_store() -> MemoryStore:
    global _memory_store
    if _memory_store is None:
        _memory_store = MemoryStore()
    return _memory_store


def get_conversation_memory(conversation_id: str) -> ConversationMemory:
    return get_memory_store().get(conversation_id)
