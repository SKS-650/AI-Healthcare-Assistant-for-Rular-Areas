"""
Medical Chatbot Database Models
Works with SQLite (development) and PostgreSQL (production).
"""
from datetime import datetime, timezone
from typing import Optional
import uuid as uuid_module
import os

from sqlalchemy import String, Text, Integer, Float, Boolean, DateTime, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

# Cross-database JSON + UUID helpers
from sqlalchemy import JSON
from sqlalchemy.types import TypeDecorator, String as SAString


class UUIDType(TypeDecorator):
    """Store UUID as VARCHAR(36) for SQLite compatibility; native UUID on Postgres."""
    impl = SAString(36)
    cache_ok = True

    def process_bind_param(self, value, dialect):
        if value is None:
            return None
        return str(value)

    def process_result_value(self, value, dialect):
        if value is None:
            return None
        return uuid_module.UUID(str(value))

    def process_literal_param(self, value, dialect):
        return str(value) if value is not None else None


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


# Import shared Base from auth.models
from app.auth.models import Base


class Conversation(Base):
    """Conversation - stores user chat sessions."""
    __tablename__ = "conversations"
    __allow_unmapped__ = True

    id = mapped_column(Integer, primary_key=True, index=True)
    uuid = mapped_column(UUIDType, default=uuid_module.uuid4, unique=True, nullable=False, index=True)
    user_id = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    session_id = mapped_column(UUIDType, nullable=True, index=True)
    title = mapped_column(String(255), nullable=False)
    language = mapped_column(String(10), default="en", nullable=False)
    is_active = mapped_column(Boolean, default=True, nullable=False)
    extra_data = mapped_column(JSON, nullable=True)

    created_at = mapped_column(DateTime(timezone=True), default=_utcnow, nullable=False)
    updated_at = mapped_column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)

    messages = relationship("Message", back_populates="conversation", cascade="all, delete-orphan", lazy="selectin")
    feedbacks = relationship("ChatbotFeedback", back_populates="conversation", cascade="all, delete-orphan")
    user = relationship("UserModel", back_populates="conversations")

    __table_args__ = (
        Index("idx_conversation_user_created", "user_id", "created_at"),
        Index("idx_conversation_session", "session_id"),
    )

    def __repr__(self) -> str:
        return f"<Conversation(id={self.id}, user_id={self.user_id})>"


class Message(Base):
    """Message - stores individual chat messages."""
    __tablename__ = "messages"
    __allow_unmapped__ = True

    id = mapped_column(Integer, primary_key=True, index=True)
    conversation_id = mapped_column(Integer, ForeignKey("conversations.id", ondelete="CASCADE"), nullable=False, index=True)
    sender = mapped_column(String(20), nullable=False)  # 'user' or 'assistant'
    message = mapped_column(Text, nullable=False)

    tokens_used = mapped_column(Integer, nullable=True)
    response_time = mapped_column(Float, nullable=True)
    confidence = mapped_column(Float, nullable=True)
    emergency_detected = mapped_column(Boolean, default=False, nullable=False)

    citations = mapped_column(JSON, nullable=True)
    recommendations = mapped_column(JSON, nullable=True)
    follow_up_questions = mapped_column(JSON, nullable=True)
    extra_data = mapped_column(JSON, nullable=True)

    created_at = mapped_column(DateTime(timezone=True), default=_utcnow, nullable=False)

    conversation = relationship("Conversation", back_populates="messages")

    __table_args__ = (
        Index("idx_message_conversation_created", "conversation_id", "created_at"),
        Index("idx_message_sender", "sender"),
        Index("idx_message_emergency", "emergency_detected"),
    )

    def __repr__(self) -> str:
        return f"<Message(id={self.id}, sender={self.sender})>"


class ChatbotFeedback(Base):
    """Chatbot Feedback - stores user ratings."""
    __tablename__ = "chatbot_feedback"
    __allow_unmapped__ = True

    id = mapped_column(Integer, primary_key=True, index=True)
    conversation_id = mapped_column(Integer, ForeignKey("conversations.id", ondelete="CASCADE"), nullable=False, index=True)
    message_id = mapped_column(Integer, ForeignKey("messages.id", ondelete="SET NULL"), nullable=True)
    rating = mapped_column(Integer, nullable=False)  # 1-5
    feedback_text = mapped_column(Text, nullable=True)
    feedback_type = mapped_column(String(50), nullable=True)
    extra_data = mapped_column(JSON, nullable=True)

    created_at = mapped_column(DateTime(timezone=True), default=_utcnow, nullable=False)

    conversation = relationship("Conversation", back_populates="feedbacks")

    __table_args__ = (
        Index("idx_feedback_conversation", "conversation_id"),
        Index("idx_feedback_rating", "rating"),
    )

    def __repr__(self) -> str:
        return f"<ChatbotFeedback(id={self.id}, rating={self.rating})>"


class ChatbotSession(Base):
    """Chatbot Session - tracks active sessions."""
    __tablename__ = "chatbot_sessions"
    __allow_unmapped__ = True

    id = mapped_column(Integer, primary_key=True, index=True)
    session_uuid = mapped_column(UUIDType, default=uuid_module.uuid4, unique=True, nullable=False, index=True)
    user_id = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    device = mapped_column(String(100), nullable=True)
    ip_address = mapped_column(String(45), nullable=True)
    user_agent = mapped_column(Text, nullable=True)
    location = mapped_column(JSON, nullable=True)

    started_at = mapped_column(DateTime(timezone=True), default=_utcnow, nullable=False)
    last_activity = mapped_column(DateTime(timezone=True), default=_utcnow, onupdate=_utcnow, nullable=False)
    ended_at = mapped_column(DateTime(timezone=True), nullable=True)
    is_active = mapped_column(Boolean, default=True, nullable=False)
    extra_data = mapped_column(JSON, nullable=True)

    user = relationship("UserModel", back_populates="chatbot_sessions")

    __table_args__ = (
        Index("idx_session_user_activity", "user_id", "last_activity"),
        Index("idx_session_active", "is_active"),
    )

    def __repr__(self) -> str:
        return f"<ChatbotSession(id={self.id}, user_id={self.user_id})>"
