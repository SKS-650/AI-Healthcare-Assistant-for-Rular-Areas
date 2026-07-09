"""
Request Schemas for Medical Chatbot API
"""
from typing import Optional, Dict, Any
from uuid import UUID
from pydantic import BaseModel, Field, validator, field_validator
from datetime import datetime


class ChatRequest(BaseModel):
    """Request schema for chat endpoint"""
    message: str = Field(
        ..., 
        min_length=1, 
        max_length=2000,
        description="User message to the chatbot"
    )
    conversation_id: Optional[UUID] = Field(
        None,
        description="Existing conversation ID to continue the conversation"
    )
    language: str = Field(
        default="en",
        description="Language code (en, hi, etc.)"
    )
    context: Optional[Dict[str, Any]] = Field(
        None,
        description="Additional context like symptom checker results"
    )
    user_location: Optional[Dict[str, Any]] = Field(
        None,
        description="User location data for location-based recommendations"
    )
    device: Optional[str] = Field(
        None,
        max_length=100,
        description="Device information"
    )

    @field_validator('message')
    @classmethod
    def validate_message(cls, v: str) -> str:
        """Validate and sanitize message"""
        if not v or not v.strip():
            raise ValueError("Message cannot be empty")
        
        # Remove excessive whitespace
        v = ' '.join(v.split())
        
        # Check for suspicious patterns
        suspicious_patterns = [
            'DROP TABLE',
            'DELETE FROM',
            '<script>',
            'javascript:',
            'eval(',
            'exec(',
        ]
        
        v_upper = v.upper()
        for pattern in suspicious_patterns:
            if pattern in v_upper:
                raise ValueError("Message contains invalid content")
        
        return v.strip()

    @field_validator('language')
    @classmethod
    def validate_language(cls, v: str) -> str:
        """Validate language code"""
        valid_languages = ['en', 'hi', 'bn', 'te', 'ta', 'mr', 'gu', 'kn', 'ml', 'pa']
        if v not in valid_languages:
            raise ValueError(f"Language must be one of: {', '.join(valid_languages)}")
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "message": "What are the symptoms of diabetes?",
                "conversation_id": None,
                "language": "en",
                "context": {
                    "symptom_check_result": {
                        "predicted_disease": "Type 2 Diabetes",
                        "confidence": 0.85
                    }
                },
                "user_location": {
                    "latitude": 28.6139,
                    "longitude": 77.2090,
                    "city": "New Delhi"
                },
                "device": "mobile"
            }
        }


class ConversationListRequest(BaseModel):
    """Request schema for listing conversations"""
    page: int = Field(default=1, ge=1, description="Page number")
    page_size: int = Field(default=20, ge=1, le=100, description="Items per page")
    search: Optional[str] = Field(None, max_length=255, description="Search in conversation titles")
    language: Optional[str] = Field(None, description="Filter by language")
    is_active: Optional[bool] = Field(None, description="Filter by active status")

    class Config:
        json_schema_extra = {
            "example": {
                "page": 1,
                "page_size": 20,
                "search": "diabetes",
                "language": "en",
                "is_active": True
            }
        }


class FeedbackRequest(BaseModel):
    """Request schema for submitting feedback"""
    conversation_id: UUID = Field(..., description="Conversation UUID")
    message_id: Optional[int] = Field(None, description="Specific message ID for feedback")
    rating: int = Field(..., ge=1, le=5, description="Rating from 1 to 5")
    feedback_text: Optional[str] = Field(
        None,
        max_length=1000,
        description="Optional feedback text"
    )
    feedback_type: Optional[str] = Field(
        None,
        description="Type of feedback: helpful, inaccurate, inappropriate, other"
    )

    @field_validator('feedback_type')
    @classmethod
    def validate_feedback_type(cls, v: Optional[str]) -> Optional[str]:
        """Validate feedback type"""
        if v is None:
            return v
        
        valid_types = ['helpful', 'inaccurate', 'inappropriate', 'incomplete', 'other']
        if v not in valid_types:
            raise ValueError(f"Feedback type must be one of: {', '.join(valid_types)}")
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "conversation_id": "123e4567-e89b-12d3-a456-426614174000",
                "message_id": 42,
                "rating": 5,
                "feedback_text": "Very helpful information about diabetes management",
                "feedback_type": "helpful"
            }
        }


class ConversationUpdateRequest(BaseModel):
    """Request schema for updating conversation"""
    title: Optional[str] = Field(None, max_length=255, description="New conversation title")
    is_active: Optional[bool] = Field(None, description="Active status")

    class Config:
        json_schema_extra = {
            "example": {
                "title": "Diabetes Information - Updated",
                "is_active": True
            }
        }
