"""Chatbot response generation."""

from __future__ import annotations


def generate_response(message: str) -> str:
    """Generate a safe placeholder response."""

    if not message.strip():
        return "Please describe your symptoms or question."
    return "I can help with general health information. Please consult a clinician for diagnosis."
