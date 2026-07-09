"""
Conversation Repository - Data access layer for conversations
"""
from typing import Optional, List, Tuple
from uuid import UUID
from datetime import datetime
from sqlalchemy import select, func, or_, and_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..database.models import Conversation, Message, ChatbotSession
from ..utils.exceptions import DatabaseException
from ..utils.logger import logger


class ConversationRepository:
    """Repository for conversation database operations"""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def create_conversation(
        self,
        user_id: str,
        title: str,
        language: str = "en",
        session_id: Optional[UUID] = None,
        metadata: Optional[dict] = None
    ) -> Conversation:
        """Create a new conversation"""
        try:
            conversation = Conversation(
                user_id=str(user_id),
                title=title,
                language=language,
                session_id=session_id,
                is_active=True,
                extra_data=metadata or {}
            )
            
            self.session.add(conversation)
            await self.session.commit()
            await self.session.refresh(conversation)
            
            logger.log_conversation_started(
                str(conversation.uuid),
                user_id,
                language
            )
            
            return conversation
            
        except Exception as e:
            await self.session.rollback()
            logger.log_database_error("create_conversation", str(e))
            raise DatabaseException("create", str(e))
    
    async def get_conversation_by_uuid(
        self,
        conversation_uuid: UUID,
        load_messages: bool = True
    ) -> Optional[Conversation]:
        """Get conversation by UUID"""
        try:
            query = select(Conversation).where(Conversation.uuid == conversation_uuid)
            
            if load_messages:
                query = query.options(selectinload(Conversation.messages))
            
            result = await self.session.execute(query)
            return result.scalar_one_or_none()
            
        except Exception as e:
            logger.log_database_error("get_conversation_by_uuid", str(e))
            raise DatabaseException("read", str(e))
    
    async def get_conversation_by_id(
        self,
        conversation_id: int,
        load_messages: bool = True
    ) -> Optional[Conversation]:
        """Get conversation by ID"""
        try:
            query = select(Conversation).where(Conversation.id == conversation_id)
            
            if load_messages:
                query = query.options(selectinload(Conversation.messages))
            
            result = await self.session.execute(query)
            return result.scalar_one_or_none()
            
        except Exception as e:
            logger.log_database_error("get_conversation_by_id", str(e))
            raise DatabaseException("read", str(e))
    
    async def get_user_conversations(
        self,
        user_id: str,
        page: int = 1,
        page_size: int = 20,
        search: Optional[str] = None,
        language: Optional[str] = None,
        is_active: Optional[bool] = None
    ) -> Tuple[List[Conversation], int]:
        """Get user's conversations with pagination and filters"""
        try:
            # Build base query
            query = select(Conversation).where(Conversation.user_id == user_id)
            
            # Apply filters
            if search:
                query = query.where(Conversation.title.ilike(f"%{search}%"))
            
            if language:
                query = query.where(Conversation.language == language)
            
            if is_active is not None:
                query = query.where(Conversation.is_active == is_active)
            
            # Get total count
            count_query = select(func.count()).select_from(query.subquery())
            total_result = await self.session.execute(count_query)
            total = total_result.scalar()
            
            # Apply pagination and ordering
            query = query.order_by(Conversation.updated_at.desc())
            query = query.offset((page - 1) * page_size).limit(page_size)
            
            # Execute query
            result = await self.session.execute(query)
            conversations = list(result.scalars().all())
            
            return conversations, total
            
        except Exception as e:
            logger.log_database_error("get_user_conversations", str(e))
            raise DatabaseException("read", str(e))
    
    async def update_conversation(
        self,
        conversation_id: int,
        **kwargs
    ) -> Optional[Conversation]:
        """Update conversation fields"""
        try:
            conversation = await self.get_conversation_by_id(conversation_id, load_messages=False)
            
            if not conversation:
                return None
            
            for key, value in kwargs.items():
                if hasattr(conversation, key):
                    setattr(conversation, key, value)
            
            conversation.updated_at = datetime.utcnow()
            
            await self.session.commit()
            await self.session.refresh(conversation)
            
            return conversation
            
        except Exception as e:
            await self.session.rollback()
            logger.log_database_error("update_conversation", str(e))
            raise DatabaseException("update", str(e))
    
    async def delete_conversation(self, conversation_id: int) -> bool:
        """Delete conversation"""
        try:
            conversation = await self.get_conversation_by_id(conversation_id, load_messages=False)
            
            if not conversation:
                return False
            
            await self.session.delete(conversation)
            await self.session.commit()
            
            return True
            
        except Exception as e:
            await self.session.rollback()
            logger.log_database_error("delete_conversation", str(e))
            raise DatabaseException("delete", str(e))
    
    async def add_message(
        self,
        conversation_id: int,
        sender: str,
        message: str,
        tokens_used: Optional[int] = None,
        response_time: Optional[float] = None,
        confidence: Optional[float] = None,
        emergency_detected: bool = False,
        citations: Optional[dict] = None,
        recommendations: Optional[dict] = None,
        follow_up_questions: Optional[list] = None,
        metadata: Optional[dict] = None
    ) -> Message:
        """Add message to conversation"""
        try:
            msg = Message(
                conversation_id=conversation_id,
                sender=sender,
                message=message,
                tokens_used=tokens_used,
                response_time=response_time,
                confidence=confidence,
                emergency_detected=emergency_detected,
                citations=citations,
                recommendations=recommendations,
                follow_up_questions=follow_up_questions,
                metadata=metadata
            )
            
            self.session.add(msg)
            
            # Update conversation's updated_at timestamp
            conversation = await self.get_conversation_by_id(conversation_id, load_messages=False)
            if conversation:
                conversation.updated_at = datetime.utcnow()
            
            await self.session.commit()
            await self.session.refresh(msg)
            
            return msg
            
        except Exception as e:
            await self.session.rollback()
            logger.log_database_error("add_message", str(e))
            raise DatabaseException("create", str(e))
    
    async def get_conversation_messages(
        self,
        conversation_id: int,
        limit: Optional[int] = None
    ) -> List[Message]:
        """Get messages for a conversation"""
        try:
            query = select(Message).where(Message.conversation_id == conversation_id)
            query = query.order_by(Message.created_at.asc())
            
            if limit:
                query = query.limit(limit)
            
            result = await self.session.execute(query)
            return list(result.scalars().all())
            
        except Exception as e:
            logger.log_database_error("get_conversation_messages", str(e))
            raise DatabaseException("read", str(e))
    
    async def get_conversation_message_count(self, conversation_id: int) -> int:
        """Get message count for a conversation"""
        try:
            query = select(func.count()).where(Message.conversation_id == conversation_id)
            result = await self.session.execute(query)
            return result.scalar() or 0
            
        except Exception as e:
            logger.log_database_error("get_conversation_message_count", str(e))
            raise DatabaseException("read", str(e))
    
    async def get_user_message_count_today(self, user_id: str) -> int:
        """Get user's message count for today"""
        try:
            today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
            
            query = select(func.count()).select_from(Message).join(Conversation).where(
                and_(
                    Conversation.user_id == user_id,
                    Message.sender == "user",
                    Message.created_at >= today_start
                )
            )
            
            result = await self.session.execute(query)
            return result.scalar() or 0
            
        except Exception as e:
            logger.log_database_error("get_user_message_count_today", str(e))
            raise DatabaseException("read", str(e))
    
    async def create_session(
        self,
        user_id: str,
        device: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        location: Optional[dict] = None,
        metadata: Optional[dict] = None
    ) -> ChatbotSession:
        """Create a new chatbot session"""
        try:
            session = ChatbotSession(
                user_id=user_id,
                device=device,
                ip_address=ip_address,
                user_agent=user_agent,
                location=location,
                is_active=True,
                metadata=metadata
            )
            
            self.session.add(session)
            await self.session.commit()
            await self.session.refresh(session)
            
            return session
            
        except Exception as e:
            await self.session.rollback()
            logger.log_database_error("create_session", str(e))
            raise DatabaseException("create", str(e))
    
    async def get_active_session(
        self,
        user_id: int,
        session_uuid: UUID
    ) -> Optional[ChatbotSession]:
        """Get active session"""
        try:
            query = select(ChatbotSession).where(
                and_(
                    ChatbotSession.user_id == user_id,
                    ChatbotSession.session_uuid == session_uuid,
                    ChatbotSession.is_active == True
                )
            )
            
            result = await self.session.execute(query)
            return result.scalar_one_or_none()
            
        except Exception as e:
            logger.log_database_error("get_active_session", str(e))
            raise DatabaseException("read", str(e))
    
    async def update_session_activity(self, session_id: int) -> bool:
        """Update session last activity timestamp"""
        try:
            query = select(ChatbotSession).where(ChatbotSession.id == session_id)
            result = await self.session.execute(query)
            session = result.scalar_one_or_none()
            
            if not session:
                return False
            
            session.last_activity = datetime.utcnow()
            await self.session.commit()
            
            return True
            
        except Exception as e:
            await self.session.rollback()
            logger.log_database_error("update_session_activity", str(e))
            raise DatabaseException("update", str(e))
