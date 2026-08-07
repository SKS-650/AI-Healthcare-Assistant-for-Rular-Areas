"""
Medical Chatbot API Routes

Endpoints
─────────
POST /api/v1/chatbot/chat            — Full chat with conversation memory (existing)
POST /api/v1/chatbot/simple-chat     — Simple Gemini chat (exact master-prompt schema)
GET  /api/v1/chatbot/conversations   — List conversations
GET  /api/v1/chatbot/conversations/{id} — Get one conversation
DELETE /api/v1/chatbot/conversations/{id} — Delete one conversation
DELETE /api/v1/chatbot/conversations — Clear all conversations
POST /api/v1/chatbot/feedback        — Submit feedback
GET  /api/v1/chatbot/health          — Health check
"""
from typing import Optional
from uuid import UUID
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field

from .dependencies import (
    get_chatbot_service,
    get_current_active_user,
    get_admin_user,
    get_user_id,
    is_admin,
)
from .controller import ChatbotController
from ..services.chatbot_service import ChatbotService
from ..services.gemini_service import get_gemini_service
from ..schemas.request import ChatRequest, ConversationListRequest, FeedbackRequest
from ..schemas.response import (
    ChatResponse,
    ConversationListResponse,
    ConversationDetailSchema,
    FeedbackResponse,
    HealthCheckResponse,
)


router = APIRouter(prefix="/chatbot", tags=["Medical Chatbot"])


# ─────────────────────────────────────────────────────────────────────────────
# Simple Gemini chat — exact schema from master prompt
# POST /api/v1/chatbot/simple-chat
# Request:  {"message": "I have headache for two days"}
# Response: {"success": true, "reply": "...", "timestamp": "..."}
# ─────────────────────────────────────────────────────────────────────────────

class SimpleChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000,
                         description="User message to the medical chatbot")

class SimpleChatResponse(BaseModel):
    success: bool
    reply: str
    timestamp: str


@router.post(
    "/simple-chat",
    response_model=SimpleChatResponse,
    status_code=status.HTTP_200_OK,
    summary="Simple Gemini chat",
    description=(
        "Send a message directly to Gemini. "
        "No conversation history — each request is independent. "
        "Requires JWT authentication."
    ),
)
async def simple_chat(
    request: SimpleChatRequest,
    user_id: str = Depends(get_user_id),
) -> SimpleChatResponse:
    """
    Lightweight endpoint — sends the message straight to GeminiService.
    No database writes.  Emergency detection runs first.
    """
    from fastapi import HTTPException

    try:
        gemini = get_gemini_service()
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        )

    try:
        result = await gemini.chat(user_message=request.message)
        return SimpleChatResponse(
            success=True,
            reply=result["reply"],
            timestamp=datetime.now(timezone.utc).isoformat(),
        )
    except TimeoutError as exc:
        raise HTTPException(status_code=status.HTTP_504_GATEWAY_TIMEOUT, detail=str(exc))
    except (ValueError, RuntimeError) as exc:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=str(exc))
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Unexpected error: {exc}",
        )


@router.post(
    "/chat",
    response_model=ChatResponse,
    status_code=status.HTTP_200_OK,
    summary="Chat with medical assistant",
    description="""
    Send a message to the medical chatbot and receive a response.
    
    **Important:**
    - The chatbot provides general health information only
    - It cannot diagnose conditions or prescribe treatments
    - Always consult healthcare professionals for medical advice
    - Emergency situations require immediate medical attention
    
    **Features:**
    - Create new conversation or continue existing one
    - Multi-language support
    - Context-aware responses
    - Emergency detection
    - Health recommendations
    - Follow-up suggestions
    """,
    responses={
        200: {"description": "Successful response"},
        400: {"description": "Invalid request"},
        401: {"description": "Unauthorized"},
        429: {"description": "Rate limit exceeded"},
        500: {"description": "Internal server error"}
    }
)
async def chat(
    request: ChatRequest,
    user_id: str = Depends(get_user_id),
    service: ChatbotService = Depends(get_chatbot_service)
) -> ChatResponse:
    """Chat with the medical assistant"""
    controller = ChatbotController(service)
    return await controller.chat(user_id, request)


@router.get(
    "/conversations",
    response_model=ConversationListResponse,
    status_code=status.HTTP_200_OK,
    summary="Get user's conversations",
    description="""
    Retrieve a paginated list of user's conversations.
    
    **Features:**
    - Pagination support
    - Search by conversation title
    - Filter by language
    - Filter by active status
    - Sorted by most recent first
    """,
    responses={
        200: {"description": "Successful response"},
        401: {"description": "Unauthorized"},
        500: {"description": "Internal server error"}
    }
)
async def get_conversations(
    page: int = 1,
    page_size: int = 20,
    search: Optional[str] = None,
    language: Optional[str] = None,
    is_active: Optional[bool] = None,
    user_id: str = Depends(get_user_id),
    service: ChatbotService = Depends(get_chatbot_service)
) -> ConversationListResponse:
    """Get user's conversations"""
    controller = ChatbotController(service)
    request = ConversationListRequest(
        page=page,
        page_size=page_size,
        search=search,
        language=language,
        is_active=is_active
    )
    return await controller.get_conversations(user_id, request)


@router.get(
    "/conversations/{conversation_id}",
    response_model=ConversationDetailSchema,
    status_code=status.HTTP_200_OK,
    summary="Get conversation details",
    description="""
    Retrieve a specific conversation with all messages.
    
    **Access Control:**
    - Users can only access their own conversations
    - Admins can access any conversation
    """,
    responses={
        200: {"description": "Successful response"},
        401: {"description": "Unauthorized"},
        403: {"description": "Access denied"},
        404: {"description": "Conversation not found"},
        500: {"description": "Internal server error"}
    }
)
async def get_conversation(
    conversation_id: UUID,
    user_id: str = Depends(get_user_id),
    admin: bool = Depends(is_admin),
    service: ChatbotService = Depends(get_chatbot_service)
) -> ConversationDetailSchema:
    """Get conversation by ID"""
    controller = ChatbotController(service)
    return await controller.get_conversation(user_id, conversation_id, admin)


@router.delete(
    "/conversations/{conversation_id}",
    status_code=status.HTTP_200_OK,
    summary="Delete conversation",
    description="""
    Delete a conversation and all its messages.
    
    **Warning:** This action cannot be undone.
    
    **Access Control:**
    - Users can only delete their own conversations
    - Admins can delete any conversation
    """,
    responses={
        200: {"description": "Successfully deleted"},
        401: {"description": "Unauthorized"},
        403: {"description": "Access denied"},
        404: {"description": "Conversation not found"},
        500: {"description": "Internal server error"}
    }
)
async def delete_conversation(
    conversation_id: UUID,
    user_id: str = Depends(get_user_id),
    admin: bool = Depends(is_admin),
    service: ChatbotService = Depends(get_chatbot_service)
) -> dict:
    """Delete conversation"""
    controller = ChatbotController(service)
    return await controller.delete_conversation(user_id, conversation_id, admin)


@router.delete(
    "/conversations",
    status_code=status.HTTP_200_OK,
    summary="Delete ALL conversations for the current user",
    description="Permanently removes every conversation belonging to the authenticated user.",
)
async def delete_all_conversations(
    user_id: str = Depends(get_user_id),
    service: ChatbotService = Depends(get_chatbot_service),
) -> dict:
    """Delete all conversations for the current user."""
    from fastapi import HTTPException
    try:
        conversations, _ = await service.get_user_conversations(
            user_id=user_id, page=1, page_size=500
        )
        deleted = 0
        for conv in conversations:
            try:
                await service.conversation_repo.delete_conversation(conv.id)
                deleted += 1
            except Exception:
                pass
        return {"message": f"Deleted {deleted} conversation(s).", "deleted_count": deleted}
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post(
    "/feedback",
    response_model=FeedbackResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Submit feedback",
    description="""
    Submit feedback for a conversation or specific message.
    
    **Feedback helps improve the service:**
    - Rate from 1 (poor) to 5 (excellent)
    - Provide optional text feedback
    - Specify feedback type
    """,
    responses={
        201: {"description": "Feedback submitted"},
        400: {"description": "Invalid request"},
        401: {"description": "Unauthorized"},
        403: {"description": "Access denied"},
        404: {"description": "Conversation not found"},
        500: {"description": "Internal server error"}
    }
)
async def submit_feedback(
    request: FeedbackRequest,
    user_id: str = Depends(get_user_id),
    service: ChatbotService = Depends(get_chatbot_service)
) -> FeedbackResponse:
    """Submit feedback"""
    controller = ChatbotController(service)
    return await controller.submit_feedback(user_id, request)


@router.get(
    "/health",
    response_model=HealthCheckResponse,
    status_code=status.HTTP_200_OK,
    summary="Health check",
    description="""
    Check the health status of the medical chatbot service.
    
    **Returns:**
    - Service status
    - Component health
    - Version information
    """,
    responses={
        200: {"description": "Service is healthy"}
    }
)
async def health_check(
    service: ChatbotService = Depends(get_chatbot_service)
) -> HealthCheckResponse:
    """Health check endpoint"""
    controller = ChatbotController(service)
    return await controller.health_check()
