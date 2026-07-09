"""
Repositories module for Medical Chatbot
"""
from .conversation_repository import ConversationRepository
from .feedback_repository import FeedbackRepository

__all__ = [
    "ConversationRepository",
    "FeedbackRepository",
]
