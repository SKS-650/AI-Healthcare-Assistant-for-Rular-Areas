"""
ChatbotService — Core business logic for the AI Medical Chatbot.
"""
from __future__ import annotations

import logging
import time
from typing import Any, Dict, List, Optional, Tuple
from uuid import UUID

from ..repositories.conversation_repository import ConversationRepository
from ..repositories.feedback_repository import FeedbackRepository
from ..schemas.request import ChatRequest
from ..schemas.response import ChatResponse
from ..utils.constants import MessageSender, MAX_CONVERSATION_MESSAGES
from ..utils.exceptions import (
    ConversationNotFoundException,
    ConversationAccessDeniedException,
    ConversationLimitException,
    RateLimitExceededException,
)
from ..utils.helpers import validate_message, generate_conversation_title
from ..utils.logger import logger

_log = logging.getLogger(__name__)

# ── AI service singleton ──────────────────────────────────────────────────────
from .gemini_service import GeminiService, get_gemini_service


class ChatbotService:
    """Orchestrates the full chat pipeline."""

    def __init__(
        self,
        conversation_repo: ConversationRepository,
        feedback_repo: FeedbackRepository,
    ) -> None:
        self.conversation_repo = conversation_repo
        self.feedback_repo = feedback_repo

        # Initialize GeminiService immediately — dotenv is loaded at startup
        try:
            self.gemini: Optional[GeminiService] = get_gemini_service()
            _log.info(
                "✅ ChatbotService ready: provider=%s model=%s",
                self.gemini._provider,
                self.gemini.model,
            )
        except Exception as exc:
            _log.error("❌ GeminiService init failed: %s", exc)
            self.gemini = None

        # Keep these attributes so the old health_check controller doesn't crash
        self.llm_service = self.gemini
        self.knowledge_service = None
        self.response_validator = None
        self.emergency_detector = None

    # ─────────────────────────────────────────────────────────────────────────
    # Main entry point
    # ─────────────────────────────────────────────────────────────────────────

    async def process_chat(
        self,
        user_id: str,
        request: ChatRequest,
    ) -> ChatResponse:
        start_time = time.time()

        # 1. Validate message
        try:
            validated_message = validate_message(request.message)
        except Exception as exc:
            validated_message = str(request.message).strip()[:2000] or "Hello"

        # 2. Rate-limit check (non-blocking)
        try:
            await self._check_rate_limits(user_id)
        except RateLimitExceededException:
            raise
        except Exception:
            pass

        # 3. Get or create DB conversation
        conversation = await self._get_or_create_conversation(
            user_id,
            request.conversation_id,
            request.language or "en",
            validated_message,
        )

        # 4. Conversation size check
        try:
            msg_count = await self.conversation_repo.get_conversation_message_count(
                conversation.id
            )
            if msg_count >= MAX_CONVERSATION_MESSAGES:
                raise ConversationLimitException(MAX_CONVERSATION_MESSAGES)
        except ConversationLimitException:
            raise
        except Exception:
            pass

        # 5. Save user message
        try:
            await self.conversation_repo.add_message(
                conversation_id=conversation.id,
                sender=MessageSender.USER,
                message=validated_message,
            )
        except Exception as exc:
            _log.warning("Could not save user message: %s", exc)

        # 6. Load history
        history = await self._load_history_for_gemini(conversation.id)

        # 7. Call AI
        is_emergency = False
        reply_text = ""
        tokens_used = 0
        response_time = 0.0
        confidence = 0.85

        if self.gemini is None:
            _log.error("GeminiService is None — check CHATBOT_OPENROUTER_API_KEY in .env")
            reply_text = (
                "⚙️ The AI assistant is not configured on this server.\n\n"
                "⚠️ For medical concerns, please consult a qualified healthcare professional."
            )
            confidence = 0.0
        else:
            try:
                result = await self.gemini.chat(
                    user_message=validated_message,
                    history=history,
                    language=request.language or "en",
                )
                reply_text = result["reply"]
                is_emergency = result.get("emergency", False)
                tokens_used = result.get("tokens_used", 0)
                response_time = result.get("response_time", 0.0)
                confidence = 0.5 if is_emergency else 0.85
                _log.info(
                    "AI replied in %.2fs | emergency=%s | tokens~%d",
                    response_time, is_emergency, tokens_used,
                )
            except TimeoutError as exc:
                _log.error("AI timeout: %s", exc)
                reply_text = "⌛ The AI response timed out. Please try again.\n\n⚠️ For urgent concerns, consult a doctor."
                confidence = 0.3
            except RuntimeError as exc:
                err = str(exc).lower()
                _log.error("AI RuntimeError: %s", exc)
                if "quota" in err or "rate" in err or "busy" in err:
                    reply_text = (
                        "⏳ The AI service is temporarily busy. Please try again in a moment.\n\n"
                        "⚠️ For urgent medical concerns, consult a healthcare professional."
                    )
                else:
                    reply_text = (
                        "⚠️ The AI service encountered an error. Please try again.\n\n"
                        "For urgent medical concerns, consult a healthcare professional."
                    )
                confidence = 0.3
            except ValueError as exc:
                _log.error("AI ValueError (bad key?): %s", exc)
                reply_text = (
                    "🔑 AI authentication failed. Please contact the administrator.\n\n"
                    "⚠️ For medical concerns, please consult a qualified healthcare professional."
                )
                confidence = 0.0
            except Exception as exc:
                _log.error("Unexpected AI error: %s", exc, exc_info=True)
                reply_text = (
                    "⚠️ An unexpected error occurred. Please try again.\n\n"
                    "For urgent medical concerns, consult a healthcare professional."
                )
                confidence = 0.3

        # 8. Save assistant reply
        try:
            assistant_msg = await self.conversation_repo.add_message(
                conversation_id=conversation.id,
                sender=MessageSender.ASSISTANT,
                message=reply_text,
                response_time=response_time,
                confidence=confidence,
                emergency_detected=is_emergency,
                tokens_used=tokens_used,
                metadata={"ai_generated": True, "provider": getattr(self.gemini, "_provider", "none")},
            )
            msg_id = assistant_msg.id
            msg_ts = assistant_msg.created_at
        except Exception as exc:
            _log.warning("Could not save assistant message: %s", exc)
            import uuid
            from datetime import datetime, timezone
            msg_id = 0
            msg_ts = datetime.now(timezone.utc)

        return ChatResponse(
            assistant_message=reply_text,
            conversation_id=conversation.uuid,
            message_id=msg_id,
            timestamp=msg_ts,
            confidence=confidence,
            citations=None,
            emergency_detected=is_emergency,
            recommendations=self._recommendations(is_emergency),
            follow_up_questions=[],
            response_time=time.time() - start_time,
            tokens_used=tokens_used,
        )

    # ─────────────────────────────────────────────────────────────────────────
    # Helpers
    # ─────────────────────────────────────────────────────────────────────────

    async def _get_or_create_conversation(self, user_id, conversation_id, language, first_message):
        if conversation_id is not None:
            conv = await self.conversation_repo.get_conversation_by_uuid(
                conversation_id, load_messages=False
            )
            if conv is None:
                raise ConversationNotFoundException(conversation_id)
            if conv.user_id != str(user_id):
                raise ConversationAccessDeniedException(conversation_id)
            return conv
        title = generate_conversation_title(first_message)
        return await self.conversation_repo.create_conversation(
            user_id=str(user_id),
            title=title,
            language=language,
        )

    async def _load_history_for_gemini(self, conversation_id: int) -> List[Dict[str, str]]:
        try:
            messages = await self.conversation_repo.get_conversation_messages(
                conversation_id, limit=20
            )
            return [
                {
                    "role": "user" if msg.sender == MessageSender.USER else "assistant",
                    "content": msg.message,
                }
                for msg in messages
            ]
        except Exception as exc:
            _log.warning("Could not load history: %s", exc)
            return []

    async def _check_rate_limits(self, user_id: str) -> None:
        try:
            count = await self.conversation_repo.get_user_message_count_today(user_id)
            if count > 500:
                raise RateLimitExceededException("Daily message limit reached.")
        except RateLimitExceededException:
            raise
        except Exception:
            pass

    @staticmethod
    def _recommendations(is_emergency: bool) -> List[str]:
        if is_emergency:
            return [
                "Call emergency services: 108 (India) / 102 (Nepal) / 112 (Global)",
                "Go to the nearest hospital emergency room immediately.",
            ]
        return ["Consult a qualified healthcare professional for personalized medical advice."]

    # ─────────────────────────────────────────────────────────────────────────
    # CRUD wrappers
    # ─────────────────────────────────────────────────────────────────────────

    async def get_conversation(self, user_id, conversation_uuid, is_admin=False):
        conv = await self.conversation_repo.get_conversation_by_uuid(
            conversation_uuid, load_messages=True
        )
        if conv is None:
            raise ConversationNotFoundException(conversation_uuid)
        if not is_admin and conv.user_id != str(user_id):
            raise ConversationAccessDeniedException(conversation_uuid)
        return conv

    async def get_user_conversations(
        self, user_id, page=1, page_size=20,
        search=None, language=None, is_active=None
    ) -> Tuple[List, int]:
        return await self.conversation_repo.get_user_conversations(
            user_id=user_id, page=page, page_size=page_size,
            search=search, language=language, is_active=is_active,
        )

    async def delete_conversation(self, user_id, conversation_uuid, is_admin=False) -> bool:
        conv = await self.conversation_repo.get_conversation_by_uuid(
            conversation_uuid, load_messages=False
        )
        if conv is None:
            raise ConversationNotFoundException(conversation_uuid)
        if not is_admin and conv.user_id != str(user_id):
            raise ConversationAccessDeniedException(conversation_uuid)
        return await self.conversation_repo.delete_conversation(conv.id)

    async def submit_feedback(
        self, user_id, conversation_uuid,
        rating, message_id=None, feedback_text=None, feedback_type=None,
    ):
        conv = await self.conversation_repo.get_conversation_by_uuid(
            conversation_uuid, load_messages=False
        )
        if conv is None:
            raise ConversationNotFoundException(conversation_uuid)
        if conv.user_id != str(user_id):
            raise ConversationAccessDeniedException(conversation_uuid)
        return await self.feedback_repo.create_feedback(
            conversation_id=conv.id, rating=rating,
            message_id=message_id, feedback_text=feedback_text,
            feedback_type=feedback_type,
        )
