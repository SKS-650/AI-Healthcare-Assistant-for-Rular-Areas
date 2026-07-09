"""
Schemas module for Medical Chatbot
"""
from .request import (
    ChatRequest,
    ConversationListRequest,
    FeedbackRequest,
    ConversationUpdateRequest
)
from .response import (
    ChatResponse,
    MessageSchema,
    ConversationSchema,
    ConversationDetailSchema,
    ConversationListResponse,
    FeedbackResponse,
    HealthCheckResponse,
    ErrorResponse
)

__all__ = [
    # Request schemas
    "ChatRequest",
    "ConversationListRequest",
    "FeedbackRequest",
    "ConversationUpdateRequest",
    
    # Response schemas
    "ChatResponse",
    "MessageSchema",
    "ConversationSchema",
    "ConversationDetailSchema",
    "ConversationListResponse",
    "FeedbackResponse",
    "HealthCheckResponse",
    "ErrorResponse",
]
