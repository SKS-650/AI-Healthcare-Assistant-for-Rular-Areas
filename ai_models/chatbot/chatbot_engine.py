"""Medical chatbot engine."""

from __future__ import annotations

from ai_models.chatbot.response_generator import generate_response


class ChatbotEngine:
    """Simple chatbot engine placeholder."""

    def reply(self, message: str) -> str:
        """Generate a chatbot reply."""

        return generate_response(message)
