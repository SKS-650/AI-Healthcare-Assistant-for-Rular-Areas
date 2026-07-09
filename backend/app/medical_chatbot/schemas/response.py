"""
Response Schemas for Medical Chatbot API
"""
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, Field


class ChatResponse(BaseModel):
    """Response schema for chat endpoint"""
    assistant_message: str = Field(..., description="Assistant's response message")
    conversation_id: UUID = Field(..., description="Conversation UUID")
    message_id: int = Field(..., description="Message ID")
    timestamp: datetime = Field(..., description="Response timestamp")
    confidence: Optional[float] = Field(None, ge=0.0, le=1.0, description="Confidence score")
    citations: Optional[List[Dict[str, Any]]] = Field(None, description="Source citations")
    emergency_detected: bool = Field(default=False, description="Emergency situation detected")
    recommendations: Optional[List[str]] = Field(None, description="Health recommendations")
    follow_up_questions: Optional[List[str]] = Field(None, description="Suggested follow-up questions")
    response_time: Optional[float] = Field(None, description="Response time in seconds")
    tokens_used: Optional[int] = Field(None, description="Number of tokens used")

    class Config:
        json_schema_extra = {
            "example": {
                "assistant_message": "Diabetes is a chronic condition that affects how your body processes blood sugar (glucose)...",
                "conversation_id": "123e4567-e89b-12d3-a456-426614174000",
                "message_id": 42,
                "timestamp": "2026-07-06T12:00:00Z",
                "confidence": 0.92,
                "citations": [
                    {
                        "source": "WHO Diabetes Fact Sheet",
                        "url": "https://www.who.int/news-room/fact-sheets/detail/diabetes"
                    }
                ],
                "emergency_detected": False,
                "recommendations": [
                    "Consult a healthcare provider for blood sugar testing",
                    "Maintain a healthy diet and exercise regularly"
                ],
                "follow_up_questions": [
                    "What are the risk factors for diabetes?",
                    "How is diabetes diagnosed?",
                    "What lifestyle changes can help manage diabetes?"
                ],
                "response_time": 1.25,
                "tokens_used": 450
            }
        }


class MessageSchema(BaseModel):
    """Schema for a single message"""
    id: int
    sender: str  # 'user' or 'assistant'
    message: str
    confidence: Optional[float] = None
    emergency_detected: bool = False
    citations: Optional[Dict[str, Any]] = None
    recommendations: Optional[Dict[str, Any]] = None
    follow_up_questions: Optional[List[str]] = None
    tokens_used: Optional[int] = None
    response_time: Optional[float] = None
    created_at: datetime

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 42,
                "sender": "assistant",
                "message": "Diabetes is a chronic condition...",
                "confidence": 0.92,
                "emergency_detected": False,
                "citations": {},
                "recommendations": {},
                "follow_up_questions": [],
                "tokens_used": 450,
                "response_time": 1.25,
                "created_at": "2026-07-06T12:00:00Z"
            }
        }


class ConversationSchema(BaseModel):
    """Schema for a conversation"""
    id: int
    uuid: UUID
    user_id: int
    session_id: Optional[UUID]
    title: str
    language: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
    message_count: Optional[int] = None

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 1,
                "uuid": "123e4567-e89b-12d3-a456-426614174000",
                "user_id": 123,
                "session_id": "987e6543-e21b-12d3-a456-426614174000",
                "title": "Diabetes Information",
                "language": "en",
                "is_active": True,
                "created_at": "2026-07-06T10:00:00Z",
                "updated_at": "2026-07-06T12:00:00Z",
                "message_count": 8
            }
        }


class ConversationDetailSchema(ConversationSchema):
    """Schema for conversation with messages"""
    messages: List[MessageSchema] = []

    class Config:
        from_attributes = True


class ConversationListResponse(BaseModel):
    """Response schema for conversation list"""
    conversations: List[ConversationSchema]
    total: int
    page: int
    page_size: int
    total_pages: int

    class Config:
        json_schema_extra = {
            "example": {
                "conversations": [
                    {
                        "id": 1,
                        "uuid": "123e4567-e89b-12d3-a456-426614174000",
                        "user_id": 123,
                        "session_id": "987e6543-e21b-12d3-a456-426614174000",
                        "title": "Diabetes Information",
                        "language": "en",
                        "is_active": True,
                        "created_at": "2026-07-06T10:00:00Z",
                        "updated_at": "2026-07-06T12:00:00Z",
                        "message_count": 8
                    }
                ],
                "total": 50,
                "page": 1,
                "page_size": 20,
                "total_pages": 3
            }
        }


class FeedbackResponse(BaseModel):
    """Response schema for feedback submission"""
    id: int
    conversation_id: UUID
    message_id: Optional[int]
    rating: int
    feedback_text: Optional[str]
    feedback_type: Optional[str]
    created_at: datetime
    message: str = "Feedback submitted successfully"

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 1,
                "conversation_id": "123e4567-e89b-12d3-a456-426614174000",
                "message_id": 42,
                "rating": 5,
                "feedback_text": "Very helpful information",
                "feedback_type": "helpful",
                "created_at": "2026-07-06T12:00:00Z",
                "message": "Feedback submitted successfully"
            }
        }


class HealthCheckResponse(BaseModel):
    """Response schema for health check"""
    status: str = "healthy"
    service: str = "medical_chatbot"
    timestamp: datetime
    version: str = "1.0.0"
    components: Dict[str, str] = {
        "database": "healthy",
        "llm_service": "healthy",
        "cache": "healthy"
    }

    class Config:
        json_schema_extra = {
            "example": {
                "status": "healthy",
                "service": "medical_chatbot",
                "timestamp": "2026-07-06T12:00:00Z",
                "version": "1.0.0",
                "components": {
                    "database": "healthy",
                    "llm_service": "healthy",
                    "cache": "healthy"
                }
            }
        }


class ErrorResponse(BaseModel):
    """Standard error response schema"""
    error: str
    detail: Optional[str] = None
    code: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_schema_extra = {
            "example": {
                "error": "Invalid request",
                "detail": "Message cannot be empty",
                "code": "INVALID_MESSAGE",
                "timestamp": "2026-07-06T12:00:00Z"
            }
        }
