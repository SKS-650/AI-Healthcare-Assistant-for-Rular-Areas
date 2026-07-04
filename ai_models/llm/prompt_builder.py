"""Prompt builder helpers."""

from __future__ import annotations


def build_prompt(system_prompt: str, user_message: str) -> str:
    """Build a prompt from system and user messages."""

    return f"System: {system_prompt}\nUser: {user_message}"
