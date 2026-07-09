"""
Feedback Repository - Data access layer for feedback
"""
from typing import Optional, List
from uuid import UUID
from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession

from ..database.models import ChatbotFeedback, Conversation
from ..utils.exceptions import DatabaseException
from ..utils.logger import logger


class FeedbackRepository:
    """Repository for feedback database operations"""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def create_feedback(
        self,
        conversation_id: int,
        rating: int,
        message_id: Optional[int] = None,
        feedback_text: Optional[str] = None,
        feedback_type: Optional[str] = None,
        metadata: Optional[dict] = None
    ) -> ChatbotFeedback:
        """Create new feedback"""
        try:
            feedback = ChatbotFeedback(
                conversation_id=conversation_id,
                message_id=message_id,
                rating=rating,
                feedback_text=feedback_text,
                feedback_type=feedback_type,
                metadata=metadata
            )
            
            self.session.add(feedback)
            await self.session.commit()
            await self.session.refresh(feedback)
            
            return feedback
            
        except Exception as e:
            await self.session.rollback()
            logger.log_database_error("create_feedback", str(e))
            raise DatabaseException("create", str(e))
    
    async def get_feedback_by_id(self, feedback_id: int) -> Optional[ChatbotFeedback]:
        """Get feedback by ID"""
        try:
            query = select(ChatbotFeedback).where(ChatbotFeedback.id == feedback_id)
            result = await self.session.execute(query)
            return result.scalar_one_or_none()
            
        except Exception as e:
            logger.log_database_error("get_feedback_by_id", str(e))
            raise DatabaseException("read", str(e))
    
    async def get_conversation_feedback(
        self,
        conversation_id: int
    ) -> List[ChatbotFeedback]:
        """Get all feedback for a conversation"""
        try:
            query = select(ChatbotFeedback).where(
                ChatbotFeedback.conversation_id == conversation_id
            ).order_by(ChatbotFeedback.created_at.desc())
            
            result = await self.session.execute(query)
            return list(result.scalars().all())
            
        except Exception as e:
            logger.log_database_error("get_conversation_feedback", str(e))
            raise DatabaseException("read", str(e))
    
    async def get_user_feedback(
        self,
        user_id: int,
        limit: Optional[int] = None
    ) -> List[ChatbotFeedback]:
        """Get all feedback from a user"""
        try:
            query = select(ChatbotFeedback).join(Conversation).where(
                Conversation.user_id == user_id
            ).order_by(ChatbotFeedback.created_at.desc())
            
            if limit:
                query = query.limit(limit)
            
            result = await self.session.execute(query)
            return list(result.scalars().all())
            
        except Exception as e:
            logger.log_database_error("get_user_feedback", str(e))
            raise DatabaseException("read", str(e))
    
    async def get_average_rating(self, conversation_id: Optional[int] = None) -> float:
        """Get average rating for conversation or overall"""
        try:
            query = select(func.avg(ChatbotFeedback.rating))
            
            if conversation_id:
                query = query.where(ChatbotFeedback.conversation_id == conversation_id)
            
            result = await self.session.execute(query)
            avg = result.scalar()
            
            return float(avg) if avg else 0.0
            
        except Exception as e:
            logger.log_database_error("get_average_rating", str(e))
            raise DatabaseException("read", str(e))
    
    async def get_feedback_stats(self) -> dict:
        """Get feedback statistics"""
        try:
            # Total feedback count
            total_query = select(func.count()).select_from(ChatbotFeedback)
            total_result = await self.session.execute(total_query)
            total = total_result.scalar() or 0
            
            # Average rating
            avg_query = select(func.avg(ChatbotFeedback.rating))
            avg_result = await self.session.execute(avg_query)
            avg_rating = float(avg_result.scalar() or 0.0)
            
            # Rating distribution
            distribution = {}
            for rating in range(1, 6):
                count_query = select(func.count()).where(ChatbotFeedback.rating == rating)
                count_result = await self.session.execute(count_query)
                distribution[rating] = count_result.scalar() or 0
            
            return {
                "total_feedback": total,
                "average_rating": round(avg_rating, 2),
                "rating_distribution": distribution
            }
            
        except Exception as e:
            logger.log_database_error("get_feedback_stats", str(e))
            raise DatabaseException("read", str(e))
    
    async def delete_feedback(self, feedback_id: int) -> bool:
        """Delete feedback"""
        try:
            feedback = await self.get_feedback_by_id(feedback_id)
            
            if not feedback:
                return False
            
            await self.session.delete(feedback)
            await self.session.commit()
            
            return True
            
        except Exception as e:
            await self.session.rollback()
            logger.log_database_error("delete_feedback", str(e))
            raise DatabaseException("delete", str(e))
