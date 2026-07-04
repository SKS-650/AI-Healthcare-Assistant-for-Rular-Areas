"""LLM context management."""

from __future__ import annotations


def trim_context(messages: list[str], max_messages: int = 10) -> list[str]:
    """Keep only the most recent messages."""

    return messages[-max_messages:]
