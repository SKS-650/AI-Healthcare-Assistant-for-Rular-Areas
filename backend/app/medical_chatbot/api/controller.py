"""
Medical Chatbot API Controller
Handles request validation, error handling, and response formatting
"""
from typing import Optional
from uuid import UUID
from fastapi import HTTPException, status
from datetime import datetime
import math

from ..services.chatbot_service import ChatbotService
from ..schemas.request import ChatRequest, ConversationListRequest, FeedbackRequest
from ..schemas.response import (
    ChatResponse,
    ConversationSchema,
    ConversationDetailSchema,
    ConversationListResponse,
    FeedbackResponse,
    HealthCheckResponse,
    ErrorResponse
)
from ..utils.exceptions import (
    ChatbotException,
    ConversationNotFoundException,
    ConversationAccessDeniedException,
    RateLimitExceededException,
    ConversationLimitException,
    InvalidMessageException
)
from ..utils.logger import logger


class ChatbotController:
    """Controller for chatbot API endpoints"""
    
    def __init__(self, service: ChatbotService):
        self.service = service
    
    async def chat(
        self,
        user_id: int,
        request: ChatRequest
    ) -> ChatResponse:
        """Process chat request"""
        try:
            response = await self.service.process_chat(user_id, request)
            return response
            
        except InvalidMessageException as e:
            logger.log_validation_error(user_id, "invalid_message", {"error": str(e)})
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )
        except ConversationNotFoundException as e:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=str(e)
            )
        except ConversationAccessDeniedException as e:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=str(e)
            )
        except RateLimitExceededException as e:
            logger.log_rate_limit_exceeded(user_id, "chat_request")
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=str(e)
            )
        except ConversationLimitException as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )
        except ChatbotException as e:
            logger.error(f"Chatbot error: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=str(e)
            )
        except Exception as e:
            logger.error(f"Unexpected error in chat: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="An unexpected error occurred"
            )
    
    async def get_conversations(
        self,
        user_id: int,
        request: ConversationListRequest
    ) -> ConversationListResponse:
        """Get user's conversations"""
        try:
            conversations, total = await self.service.get_user_conversations(
                user_id=user_id,
                page=request.page,
                page_size=request.page_size,
                search=request.search,
                language=request.language,
                is_active=request.is_active
            )
            
            # Add message count to each conversation
            conversation_schemas = []
            for conv in conversations:
                conv_dict = {
                    "id": conv.id,
                    "uuid": conv.uuid,
                    "user_id": conv.user_id,
                    "session_id": conv.session_id,
                    "title": conv.title,
                    "language": conv.language,
                    "is_active": conv.is_active,
                    "created_at": conv.created_at,
                    "updated_at": conv.updated_at,
                    "message_count": len(conv.messages) if hasattr(conv, 'messages') else 0
                }
                conversation_schemas.append(ConversationSchema(**conv_dict))
            
            total_pages = math.ceil(total / request.page_size) if total > 0 else 0
            
            return ConversationListResponse(
                conversations=conversation_schemas,
                total=total,
                page=request.page,
                page_size=request.page_size,
                total_pages=total_pages
            )
            
        except ChatbotException as e:
            logger.error(f"Error getting conversations: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=str(e)
            )
        except Exception as e:
            logger.error(f"Unexpected error getting conversations: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="An unexpected error occurred"
            )
    
    async def get_conversation(
        self,
        user_id: int,
        conversation_id: UUID,
        is_admin: bool = False
    ) -> ConversationDetailSchema:
        """Get conversation by ID"""
        try:
            conversation = await self.service.get_conversation(
                user_id=user_id,
                conversation_uuid=conversation_id,
                is_admin=is_admin
            )
            
            return ConversationDetailSchema.model_validate(conversation)
            
        except ConversationNotFoundException as e:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=str(e)
            )
        except ConversationAccessDeniedException as e:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=str(e)
            )
        except ChatbotException as e:
            logger.error(f"Error getting conversation: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=str(e)
            )
        except Exception as e:
            logger.error(f"Unexpected error getting conversation: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="An unexpected error occurred"
            )
    
    async def delete_conversation(
        self,
        user_id: int,
        conversation_id: UUID,
        is_admin: bool = False
    ) -> dict:
        """Delete conversation"""
        try:
            deleted = await self.service.delete_conversation(
                user_id=user_id,
                conversation_uuid=conversation_id,
                is_admin=is_admin
            )
            
            if not deleted:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Conversation not found"
                )
            
            return {
                "message": "Conversation deleted successfully",
                "conversation_id": str(conversation_id)
            }
            
        except ConversationNotFoundException as e:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=str(e)
            )
        except ConversationAccessDeniedException as e:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=str(e)
            )
        except ChatbotException as e:
            logger.error(f"Error deleting conversation: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=str(e)
            )
        except Exception as e:
            logger.error(f"Unexpected error deleting conversation: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="An unexpected error occurred"
            )
    
    async def submit_feedback(
        self,
        user_id: int,
        request: FeedbackRequest
    ) -> FeedbackResponse:
        """Submit feedback for conversation"""
        try:
            feedback = await self.service.submit_feedback(
                user_id=user_id,
                conversation_uuid=request.conversation_id,
                rating=request.rating,
                message_id=request.message_id,
                feedback_text=request.feedback_text,
                feedback_type=request.feedback_type
            )
            
            return FeedbackResponse(
                id=feedback.id,
                conversation_id=request.conversation_id,
                message_id=feedback.message_id,
                rating=feedback.rating,
                feedback_text=feedback.feedback_text,
                feedback_type=feedback.feedback_type,
                created_at=feedback.created_at,
                message="Feedback submitted successfully"
            )
            
        except ConversationNotFoundException as e:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=str(e)
            )
        except ConversationAccessDeniedException as e:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=str(e)
            )
        except ChatbotException as e:
            logger.error(f"Error submitting feedback: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=str(e)
            )
        except Exception as e:
            logger.error(f"Unexpected error submitting feedback: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="An unexpected error occurred"
            )
    
    async def health_check(self) -> HealthCheckResponse:
        """Health check endpoint with real component status"""
        components = {}
        overall_status = "healthy"
        
        try:
            # Check Database
            try:
                # Try a simple query to verify database connection
                from sqlalchemy import text
                result = await self.service.conversation_repo.session.execute(
                    text("SELECT 1")
                )
                components["database"] = "connected"
            except Exception as db_error:
                logger.error(f"Database health check failed: {str(db_error)}")
                components["database"] = "disconnected"
                overall_status = "unhealthy"
            
            # Check LLM Service
            try:
                llm_provider = getattr(self.service.llm_service, "provider_name", "unknown")
                llm_available = self.service.llm_service is not None
                components["llm"] = f"available ({llm_provider})" if llm_available else "unavailable"
                
                if not llm_available:
                    overall_status = "degraded"
            except Exception as llm_error:
                logger.error(f"LLM health check failed: {str(llm_error)}")
                components["llm"] = "unavailable"
                overall_status = "degraded"
            
            # Check Knowledge Service (Datasets)
            try:
                datasets_loaded = hasattr(self.service.knowledge_service, "_disease_data")
                components["datasets"] = "loaded" if datasets_loaded else "not_loaded"
                
                if not datasets_loaded:
                    overall_status = "degraded"
            except Exception as dataset_error:
                logger.error(f"Dataset health check failed: {str(dataset_error)}")
                components["datasets"] = "not_loaded"
                overall_status = "degraded"
            
            # Check Response Validator
            try:
                validator_available = self.service.response_validator is not None
                components["validator"] = "active" if validator_available else "inactive"
            except Exception:
                components["validator"] = "inactive"
            
            # Check Emergency Detector
            try:
                emergency_available = self.service.emergency_detector is not None
                components["emergency_detector"] = "active" if emergency_available else "inactive"
            except Exception:
                components["emergency_detector"] = "inactive"
            
            return HealthCheckResponse(
                status=overall_status,
                service="medical_chatbot",
                timestamp=datetime.utcnow(),
                version="1.0.0",
                components=components
            )
            
        except Exception as e:
            logger.error(f"Health check failed: {str(e)}", exc_info=True)
            return HealthCheckResponse(
                status="unhealthy",
                service="medical_chatbot",
                timestamp=datetime.utcnow(),
                version="1.0.0",
                components={
                    "database": "unknown",
                    "llm": "unknown",
                    "datasets": "unknown",
                    "validator": "unknown",
                    "emergency_detector": "unknown"
                }
            )
