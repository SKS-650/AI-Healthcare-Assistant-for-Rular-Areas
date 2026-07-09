"""
Configuration settings for Medical Chatbot Module
Uses os.getenv directly — no pydantic_settings dependency needed.
"""
import os
from typing import Optional


class ChatbotSettings:
    """Medical Chatbot configuration settings — reads from environment variables."""

    # Service Settings
    SERVICE_NAME: str = "Medical Chatbot"
    SERVICE_VERSION: str = "1.0.0"

    @property
    def DEBUG(self) -> bool:
        return os.getenv("CHATBOT_DEBUG", "false").lower() == "true"

    # Message Limits
    MAX_MESSAGE_LENGTH: int = 2000
    MIN_MESSAGE_LENGTH: int = 1
    MAX_CONVERSATION_MESSAGES: int = 100
    MAX_TOKENS_PER_REQUEST: int = 4000

    # Rate Limiting
    RATE_LIMIT_MESSAGES_PER_MINUTE: int = 10
    RATE_LIMIT_REQUESTS_PER_HOUR: int = 100
    RATE_LIMIT_CONVERSATIONS_PER_DAY: int = 20

    # Timeouts (seconds)
    @property
    def LLM_REQUEST_TIMEOUT(self) -> int:
        return int(os.getenv("CHATBOT_LLM_REQUEST_TIMEOUT", "30"))

    DATABASE_QUERY_TIMEOUT: int = 10
    CACHE_OPERATION_TIMEOUT: int = 5

    # Session
    SESSION_EXPIRY_HOURS: int = 24
    CONVERSATION_IDLE_TIMEOUT_HOURS: int = 2

    # Pagination
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100

    # Confidence Thresholds
    EMERGENCY_CONFIDENCE_THRESHOLD: float = 0.7
    LOW_CONFIDENCE_THRESHOLD: float = 0.5
    HIGH_CONFIDENCE_THRESHOLD: float = 0.8

    # Language Support
    DEFAULT_LANGUAGE: str = "en"
    SUPPORTED_LANGUAGES: list = [
        "en", "hi", "bn", "te", "ta", "mr", "gu", "kn", "ml", "pa"
    ]

    # LLM Configuration — reads CHATBOT_* env vars set in .env
    @property
    def LLM_PROVIDER(self) -> str:
        return os.getenv("CHATBOT_LLM_PROVIDER", "gemini")

    @property
    def LLM_MODEL(self) -> str:
        return os.getenv("CHATBOT_LLM_MODEL", "gemini-pro")

    @property
    def LLM_API_KEY(self) -> Optional[str]:
        return os.getenv("CHATBOT_LLM_API_KEY") or None

    @property
    def LLM_API_BASE(self) -> Optional[str]:
        return os.getenv("CHATBOT_LLM_API_BASE") or None

    @property
    def LLM_MAX_TOKENS(self) -> int:
        return int(os.getenv("CHATBOT_LLM_MAX_TOKENS", "1000"))

    @property
    def LLM_TEMPERATURE(self) -> float:
        return float(os.getenv("CHATBOT_LLM_TEMPERATURE", "0.7"))

    # Database
    @property
    def DATABASE_URL(self) -> Optional[str]:
        return os.getenv("DATABASE_URL") or None

    # Redis Cache
    @property
    def REDIS_URL(self) -> Optional[str]:
        return os.getenv("REDIS_URL") or None

    REDIS_ENABLED: bool = False

    # Cache TTL (seconds)
    CACHE_TTL_CONVERSATION: int = 3600
    CACHE_TTL_RATE_LIMIT: int = 60
    CACHE_TTL_SESSION: int = 86400

    # Security
    @property
    def JWT_SECRET_KEY(self) -> Optional[str]:
        return os.getenv("JWT_SECRET_KEY") or None

    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRY_MINUTES: int = 30

    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"

    # Medical Disclaimers
    MEDICAL_DISCLAIMER: str = (
        "⚠️ Important: I'm an AI assistant providing general health information only. "
        "I cannot diagnose conditions or prescribe treatments. "
        "Always consult qualified healthcare professionals for medical advice."
    )

    EMERGENCY_DISCLAIMER: str = (
        "🚨 EMERGENCY DETECTED: If this is a medical emergency, please call emergency services "
        "immediately (108 in India, 911 in US) or go to the nearest hospital. "
        "Do not rely solely on this chatbot in emergency situations."
    )


# Global settings instance
settings = ChatbotSettings()
