"""
Chatbot Service - Main business logic for chatbot operations
UPDATED: Now includes AI functionality with LLM integration
"""
from typing import Optional, Dict, Any, Tuple, List
from uuid import UUID
from datetime import datetime
import time

from ..repositories.conversation_repository import ConversationRepository
from ..repositories.feedback_repository import FeedbackRepository
from ..schemas.request import ChatRequest
from ..schemas.response import ChatResponse, MessageSchema
from ..utils.exceptions import (
    ConversationNotFoundException,
    ConversationAccessDeniedException,
    ConversationLimitException,
    RateLimitExceededException,
    LLMServiceException
)
from ..utils.logger import logger
from ..utils.helpers import (
    validate_message,
    generate_conversation_title,
    detect_emergency_keywords,
    calculate_confidence
)
from ..utils.constants import (
    MAX_CONVERSATION_MESSAGES,
    RATE_LIMIT_MESSAGES_PER_MINUTE,
    MessageSender
)

# Import AI services
from .llm_service import get_llm_service, LLMService
from .knowledge_service import get_knowledge_service, KnowledgeService
from .prompt_builder import PromptBuilder
from .response_validator import ResponseValidator, EmergencyDetector

# Import enhanced AI modules (lazy — don't crash if not installed)
import sys as _sys
from pathlib import Path as _Path
_PROJECT_ROOT = str(_Path(__file__).parent.parent.parent.parent.parent)
if _PROJECT_ROOT not in _sys.path:
    _sys.path.insert(0, _PROJECT_ROOT)

def _get_translator():
    try:
        from ai_models.translation.translator import get_translator
        return get_translator()
    except Exception:
        return None

def _get_memory(conversation_id: str):
    try:
        from ai_models.memory.conversation_memory import get_conversation_memory
        return get_conversation_memory(conversation_id)
    except Exception:
        return None


class ChatbotService:
    """Service for chatbot business logic with AI integration"""
    
    def __init__(
        self,
        conversation_repo: ConversationRepository,
        feedback_repo: FeedbackRepository,
        llm_service: Optional[LLMService] = None,
        knowledge_service: Optional[KnowledgeService] = None
    ):
        self.conversation_repo = conversation_repo
        self.feedback_repo = feedback_repo
        
        # AI services — wrap LLM init so an invalid key doesn't crash server startup
        if llm_service is not None:
            self.llm_service = llm_service
        else:
            try:
                self.llm_service = get_llm_service()
            except Exception as _llm_err:
                import logging as _log
                _log.getLogger(__name__).error(
                    "LLM service unavailable (chatbot will use fallback responses): %s", _llm_err
                )
                self.llm_service = None
        self.knowledge_service = knowledge_service or get_knowledge_service()
        self.prompt_builder = PromptBuilder()
        self.response_validator = ResponseValidator()
        self.emergency_detector = EmergencyDetector()
        
        logger.info("ChatbotService initialized with AI functionality")
    
    async def process_chat(
        self,
        user_id: str,
        request: ChatRequest
    ) -> ChatResponse:
        """
        Process chat request and generate response
        
        This is a placeholder implementation. Full LLM integration will be
        implemented in Phase 05 Part 2.
        
        Args:
            user_id: User ID
            request: Chat request
            
        Returns:
            Chat response
            
        Raises:
            ConversationNotFoundException: If conversation not found
            ConversationAccessDeniedException: If user doesn't have access
            RateLimitExceededException: If rate limit exceeded
            ConversationLimitException: If conversation size limit exceeded
        """
        start_time = time.time()
        
        # Validate message
        validated_message = validate_message(request.message)

        # ── Language detection + translation to English for NLP pipeline ──
        detected_language = request.language or "en"
        english_message   = validated_message
        translator = _get_translator()
        if translator:
            try:
                det = translator.detect(validated_message)
                detected_language = det.language_code
                if detected_language not in ("en", "auto"):
                    tr = translator.translate_to_english(validated_message)
                    if tr.success and tr.translated_text:
                        english_message = tr.translated_text
            except Exception as _tr_err:
                logger.debug(f"Translation detection failed: {_tr_err}")
        
        logger.log_message_received(
            str(request.conversation_id) if request.conversation_id else "new",
            user_id,
            len(validated_message)
        )
        
        # Check rate limits
        await self._check_rate_limits(user_id)
        
        # Get or create conversation
        conversation = await self._get_or_create_conversation(
            user_id,
            request.conversation_id,
            request.language,
            validated_message
        )
        
        # Check conversation message limit
        message_count = await self.conversation_repo.get_conversation_message_count(
            conversation.id
        )
        if message_count >= MAX_CONVERSATION_MESSAGES:
            raise ConversationLimitException(MAX_CONVERSATION_MESSAGES)
        
        # Save user message
        user_message = await self.conversation_repo.add_message(
            conversation_id=conversation.id,
            sender=MessageSender.USER,
            message=validated_message
        )
        
        # Check for emergency keywords FIRST
        is_emergency, emergency_type, emergency_keyword = self.emergency_detector.detect_emergency(validated_message)
        
        if is_emergency:
            logger.log_emergency_detected(
                str(conversation.uuid),
                user_id,
                emergency_type or emergency_keyword or "unknown",
                1.0
            )
        
        # Generate AI response
        try:
            # 1. Get conversation history (from DB + in-memory)
            conversation_history = await self._get_conversation_history(conversation.id)
            # Merge in-memory memory turns for richer context
            memory = _get_memory(str(conversation.uuid))
            if memory:
                mem_history = memory.get_history_for_prompt(last_n=4)
                if mem_history:
                    conversation_history = mem_history + conversation_history

            # 2. Get relevant knowledge — use English-translated message for better search
            knowledge_context = self.knowledge_service.get_relevant_knowledge(english_message)

            # 3. Build context from user's request
            user_context = self._build_user_context(request)

            # 4. Build AI prompt (pass detected language for multilingual instruction)
            if is_emergency:
                prompt = self.prompt_builder.build_chat_prompt(
                    user_question=english_message,
                    conversation_history=conversation_history,
                    knowledge_context=knowledge_context,
                    user_context=user_context,
                    language=detected_language,
                )
                prompt = self.prompt_builder.add_emergency_context(prompt)
            else:
                prompt = self.prompt_builder.build_chat_prompt(
                    user_question=english_message,
                    conversation_history=conversation_history,
                    knowledge_context=knowledge_context,
                    user_context=user_context,
                    language=detected_language,
                )
            
            # Guard: if LLM service unavailable, raise LLMServiceException to hit fallback
            if self.llm_service is None:
                raise LLMServiceException("LLM service not available. Using fallback response.")
            
            # 5. Generate AI response
            llm_result = await self.llm_service.generate_response(
                prompt=prompt,
                temperature=0.7,
                max_tokens=1000,
                conversation_id=str(conversation.uuid)
            )
            
            ai_response_text = llm_result["response"]
            
            # 6. Validate response
            is_valid, error_reason, validation_metadata = self.response_validator.validate_response(
                ai_response_text,
                validated_message
            )
            
            if not is_valid:
                logger.warning(f"Response validation failed: {error_reason}")
                # Use sanitized version or fallback
                ai_response_text = self.response_validator.sanitize_response(ai_response_text)
            
            # 7. If emergency, prepend localised emergency message
            if is_emergency:
                # Use enhanced emergency detector for localised message
                try:
                    from ai_models.emergency_detection.emergency_detector import get_emergency_detector
                    em_det = get_emergency_detector()
                    em_result = em_det.detect(english_message, detected_language)
                    if em_result.is_emergency and em_result.warning_message:
                        ai_response_text = f"{em_result.warning_message}\n\n{ai_response_text}"
                    else:
                        emergency_message = self.emergency_detector.get_emergency_response(emergency_type or "cardiac")
                        ai_response_text = f"{emergency_message}\n\n{ai_response_text}"
                except Exception:
                    emergency_message = self.emergency_detector.get_emergency_response(emergency_type or "cardiac")
                    ai_response_text = f"{emergency_message}\n\n{ai_response_text}"

            # 7b. Translate response back to user's language (if non-English)
            if detected_language not in ("en", "auto") and translator:
                try:
                    tr_resp = translator.translate_response(ai_response_text, detected_language)
                    if tr_resp.success and tr_resp.translated_text:
                        ai_response_text = tr_resp.translated_text
                except Exception as _te:
                    logger.debug(f"Response translation failed: {_te}")
            
            # 8. Calculate confidence
            confidence = calculate_confidence({
                "llm_confidence": 0.85,
                "validation_score": 1.0 if is_valid else 0.7,
                "knowledge_available": 0.9 if knowledge_context.get("disease_info") else 0.6
            })
            
            # 9. Generate recommendations
            recommendations = self._generate_recommendations(
                validated_message,
                is_emergency,
                knowledge_context
            )
            
            # 10. Generate follow-up questions
            follow_up_questions = self._generate_followup_questions(
                validated_message,
                knowledge_context
            )
            
            response_time = time.time() - start_time
            tokens_used = llm_result.get("tokens_used", 0)

            # Save to in-memory conversation memory
            if memory:
                try:
                    memory.add_turn(
                        user_message=validated_message,
                        bot_response=ai_response_text,
                        language=detected_language,
                        intent="GENERAL_MEDICAL",
                        is_emergency=is_emergency,
                    )
                except Exception:
                    pass
            
        except LLMServiceException as e:
            logger.error(f"LLM service error: {str(e)}")
            # Fallback response
            ai_response_text = self.response_validator.get_fallback_response("validation_failed")
            confidence = 0.5
            response_time = time.time() - start_time
            tokens_used = 0
            recommendations = ["Please consult a healthcare professional for medical advice."]
            follow_up_questions = []
        
        except Exception as e:
            logger.error(f"Error generating AI response: {str(e)}", exc_info=True)
            # Fallback response
            ai_response_text = self.response_validator.get_fallback_response("validation_failed")
            confidence = 0.5
            response_time = time.time() - start_time
            tokens_used = 0
            recommendations = ["Please consult a healthcare professional for medical advice."]
            follow_up_questions = []
        
        # Save assistant message
        assistant_message = await self.conversation_repo.add_message(
            conversation_id=conversation.id,
            sender=MessageSender.ASSISTANT,
            message=ai_response_text,
            response_time=response_time,
            confidence=confidence,
            emergency_detected=is_emergency,
            recommendations={"list": recommendations},
            follow_up_questions=follow_up_questions,
            tokens_used=tokens_used,
            metadata={"ai_generated": True, "provider": getattr(self.llm_service, "provider_name", "unknown")}
        )
        
        logger.log_llm_response(
            str(conversation.uuid),
            response_time,
            tokens_used=tokens_used,
            confidence=confidence
        )
        
        return ChatResponse(
            assistant_message=ai_response_text,
            conversation_id=conversation.uuid,
            message_id=assistant_message.id,
            timestamp=assistant_message.created_at,
            confidence=confidence,
            citations=None,
            emergency_detected=is_emergency,
            recommendations=recommendations,
            follow_up_questions=follow_up_questions,
            response_time=response_time,
            tokens_used=tokens_used
        )
    
    async def get_conversation(
        self,
        user_id: str,
        conversation_uuid: UUID,
        is_admin: bool = False
    ) -> Optional[Dict[str, Any]]:
        """Get conversation by UUID"""
        conversation = await self.conversation_repo.get_conversation_by_uuid(
            conversation_uuid,
            load_messages=True
        )
        
        if not conversation:
            raise ConversationNotFoundException(conversation_uuid)
        
        # Check access
        if not is_admin and conversation.user_id != user_id:
            raise ConversationAccessDeniedException(conversation_uuid)
        
        return conversation
    
    async def get_user_conversations(
        self,
        user_id: str,
        page: int = 1,
        page_size: int = 20,
        search: Optional[str] = None,
        language: Optional[str] = None,
        is_active: Optional[bool] = None
    ) -> Tuple[List, int]:
        """Get user's conversations"""
        return await self.conversation_repo.get_user_conversations(
            user_id=user_id,
            page=page,
            page_size=page_size,
            search=search,
            language=language,
            is_active=is_active
        )
    
    async def delete_conversation(
        self,
        user_id: str,
        conversation_uuid: UUID,
        is_admin: bool = False
    ) -> bool:
        """Delete conversation"""
        conversation = await self.conversation_repo.get_conversation_by_uuid(
            conversation_uuid,
            load_messages=False
        )
        
        if not conversation:
            raise ConversationNotFoundException(conversation_uuid)
        
        # Check access
        if not is_admin and conversation.user_id != user_id:
            raise ConversationAccessDeniedException(conversation_uuid)
        
        return await self.conversation_repo.delete_conversation(conversation.id)
    
    async def submit_feedback(
        self,
        user_id: str,
        conversation_uuid: UUID,
        rating: int,
        message_id: Optional[int] = None,
        feedback_text: Optional[str] = None,
        feedback_type: Optional[str] = None
    ) -> Any:
        """Submit feedback for conversation"""
        conversation = await self.conversation_repo.get_conversation_by_uuid(
            conversation_uuid,
            load_messages=False
        )
        
        if not conversation:
            raise ConversationNotFoundException(conversation_uuid)
        
        # Check access
        if conversation.user_id != user_id:
            raise ConversationAccessDeniedException(conversation_uuid)
        
        feedback = await self.feedback_repo.create_feedback(
            conversation_id=conversation.id,
            message_id=message_id,
            rating=rating,
            feedback_text=feedback_text,
            feedback_type=feedback_type
        )
        
        logger.log_feedback_submitted(
            str(conversation_uuid),
            user_id,
            rating,
            feedback_type
        )
        
        return feedback
    
    async def _check_rate_limits(self, user_id: str):
        """Check if user has exceeded rate limits"""
        # This is a simple implementation
        # In production, use Redis for distributed rate limiting
        message_count = await self.conversation_repo.get_user_message_count_today(user_id)
        
        # For now, just log warning if too many messages
        # Full rate limiting will be implemented with Redis in Part 2
        if message_count > RATE_LIMIT_MESSAGES_PER_MINUTE * 60:  # Very high limit for now
            logger.log_rate_limit_exceeded(user_id, "messages_per_day")
    
    async def _get_or_create_conversation(
        self,
        user_id: str,
        conversation_uuid: Optional[UUID],
        language: str,
        first_message: str
    ):
        """Get existing conversation or create new one"""
        if conversation_uuid:
            conversation = await self.conversation_repo.get_conversation_by_uuid(
                conversation_uuid,
                load_messages=False
            )
            
            if not conversation:
                raise ConversationNotFoundException(conversation_uuid)
            
            if conversation.user_id != user_id:
                raise ConversationAccessDeniedException(conversation_uuid)
            
            return conversation
        
        # Create new conversation
        title = generate_conversation_title(first_message)
        return await self.conversation_repo.create_conversation(
            user_id=user_id,
            title=title,
            language=language
        )
    
    async def _get_conversation_history(self, conversation_id: int) -> List[Dict[str, str]]:
        """Get recent conversation history"""
        messages = await self.conversation_repo.get_conversation_messages(
            conversation_id,
            limit=20  # Last 20 messages
        )
        
        history = []
        for msg in messages:
            history.append({
                "sender": msg.sender,
                "message": msg.message,
                "created_at": msg.created_at.isoformat() if msg.created_at else None
            })
        
        return history
    
    def _build_user_context(self, request: ChatRequest) -> Dict[str, Any]:
        """Build user context from request"""
        context = {}
        
        if request.context:
            context = request.context
        
        if request.user_location:
            context["location"] = request.user_location
        
        return context
    
    def _generate_recommendations(
        self,
        user_message: str,
        is_emergency: bool,
        knowledge_context: Dict[str, Any]
    ) -> List[str]:
        """Generate health recommendations"""
        recommendations = []
        
        if is_emergency:
            recommendations.append("Call emergency services immediately (108 in India)")
            recommendations.append("Do not wait - seek immediate medical attention")
            return recommendations
        
        # General recommendations
        recommendations.append("Consult a qualified healthcare professional for proper evaluation")
        
        # Add context-specific recommendations
        if knowledge_context.get("disease_info"):
            disease = knowledge_context["disease_info"]
            if disease.get("precautions"):
                recommendations.extend(disease["precautions"][:2])
        
        # Add general health advice
        recommendations.append("Maintain a healthy lifestyle with proper diet and exercise")
        
        return recommendations[:5]  # Limit to 5 recommendations
    
    def _generate_followup_questions(
        self,
        user_message: str,
        knowledge_context: Dict[str, Any]
    ) -> List[str]:
        """Generate follow-up questions"""
        questions = []
        
        # Disease-specific follow-ups
        if knowledge_context.get("disease_info"):
            disease = knowledge_context["disease_info"]
            disease_name = disease.get("name", "this condition")
            questions.append(f"Would you like to know more about {disease_name}?")
            questions.append(f"What are the risk factors for {disease_name}?")
            questions.append("How can this condition be prevented?")
        
        # General health follow-ups
        if "symptom" in user_message.lower():
            questions.append("Would you like information about when to see a doctor?")
            questions.append("Do you need first aid guidance?")
        
        if "medicine" in user_message.lower() or "drug" in user_message.lower():
            questions.append("Would you like general information about medication safety?")
        
        # Lifestyle follow-ups
        questions.append("Would you like tips for a healthy lifestyle?")
        questions.append("Do you have questions about nutrition or exercise?")
        
        return questions[:5]  # Limit to 5 questions
