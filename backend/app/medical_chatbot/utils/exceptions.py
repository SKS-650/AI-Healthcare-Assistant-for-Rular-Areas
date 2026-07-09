"""
Custom Exceptions for Medical Chatbot Module
"""
from typing import Optional, Any, Dict


class ChatbotException(Exception):
    """Base exception for chatbot module"""
    def __init__(
        self,
        message: str,
        code: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        self.message = message
        self.code = code
        self.details = details or {}
        super().__init__(self.message)


class ConversationNotFoundException(ChatbotException):
    """Raised when conversation is not found"""
    def __init__(self, conversation_id: Any):
        super().__init__(
            message=f"Conversation not found: {conversation_id}",
            code="CONVERSATION_NOT_FOUND"
        )


class ConversationAccessDeniedException(ChatbotException):
    """Raised when user doesn't have access to conversation"""
    def __init__(self, conversation_id: Any):
        super().__init__(
            message=f"Access denied to conversation: {conversation_id}",
            code="CONVERSATION_ACCESS_DENIED"
        )


class InvalidMessageException(ChatbotException):
    """Raised when message validation fails"""
    def __init__(self, reason: str):
        super().__init__(
            message=f"Invalid message: {reason}",
            code="INVALID_MESSAGE"
        )


class EmptyMessageException(InvalidMessageException):
    """Raised when message is empty"""
    def __init__(self):
        super().__init__(reason="Message cannot be empty")


class MessageTooLongException(InvalidMessageException):
    """Raised when message exceeds maximum length"""
    def __init__(self, max_length: int):
        super().__init__(reason=f"Message exceeds maximum length of {max_length} characters")


class SuspiciousContentException(InvalidMessageException):
    """Raised when message contains suspicious content"""
    def __init__(self, pattern: str):
        super().__init__(reason=f"Message contains suspicious pattern: {pattern}")


class RateLimitExceededException(ChatbotException):
    """Raised when rate limit is exceeded"""
    def __init__(self, limit: int, window: str):
        super().__init__(
            message=f"Rate limit exceeded: {limit} requests per {window}",
            code="RATE_LIMIT_EXCEEDED"
        )


class LLMServiceException(ChatbotException):
    """Raised when LLM service encounters an error"""
    def __init__(self, reason: str):
        super().__init__(
            message=f"LLM service error: {reason}",
            code="LLM_SERVICE_ERROR"
        )


class LLMTimeoutException(LLMServiceException):
    """Raised when LLM request times out"""
    def __init__(self):
        super().__init__(reason="Request timed out")


class LLMResponseException(LLMServiceException):
    """Raised when LLM returns invalid response"""
    def __init__(self, reason: str):
        super().__init__(reason=f"Invalid LLM response: {reason}")


class PromptBuildException(ChatbotException):
    """Raised when prompt building fails"""
    def __init__(self, reason: str):
        super().__init__(
            message=f"Failed to build prompt: {reason}",
            code="PROMPT_BUILD_ERROR"
        )


class ResponseValidationException(ChatbotException):
    """Raised when response validation fails"""
    def __init__(self, reason: str):
        super().__init__(
            message=f"Response validation failed: {reason}",
            code="RESPONSE_VALIDATION_ERROR"
        )


class SafetyFilterException(ChatbotException):
    """Raised when safety filter blocks content"""
    def __init__(self, reason: str):
        super().__init__(
            message=f"Content blocked by safety filter: {reason}",
            code="SAFETY_FILTER_BLOCKED"
        )


class EmergencyDetectedException(ChatbotException):
    """Raised when emergency situation is detected"""
    def __init__(self, emergency_type: str, confidence: float):
        super().__init__(
            message=f"Emergency detected: {emergency_type} (confidence: {confidence})",
            code="EMERGENCY_DETECTED",
            details={
                "emergency_type": emergency_type,
                "confidence": confidence
            }
        )


class SessionExpiredException(ChatbotException):
    """Raised when session has expired"""
    def __init__(self):
        super().__init__(
            message="Session has expired",
            code="SESSION_EXPIRED"
        )


class DatabaseException(ChatbotException):
    """Raised when database operation fails"""
    def __init__(self, operation: str, reason: str):
        super().__init__(
            message=f"Database {operation} failed: {reason}",
            code="DATABASE_ERROR"
        )


class CacheException(ChatbotException):
    """Raised when cache operation fails"""
    def __init__(self, operation: str, reason: str):
        super().__init__(
            message=f"Cache {operation} failed: {reason}",
            code="CACHE_ERROR"
        )


class AuthenticationException(ChatbotException):
    """Raised when authentication fails"""
    def __init__(self, reason: str = "Authentication failed"):
        super().__init__(
            message=reason,
            code="AUTHENTICATION_FAILED"
        )


class AuthorizationException(ChatbotException):
    """Raised when authorization fails"""
    def __init__(self, reason: str = "Authorization failed"):
        super().__init__(
            message=reason,
            code="AUTHORIZATION_FAILED"
        )


class ValidationException(ChatbotException):
    """Raised when data validation fails"""
    def __init__(self, field: str, reason: str):
        super().__init__(
            message=f"Validation failed for {field}: {reason}",
            code="VALIDATION_ERROR",
            details={"field": field}
        )


class ConversationLimitException(ChatbotException):
    """Raised when conversation size limit is exceeded"""
    def __init__(self, limit: int):
        super().__init__(
            message=f"Conversation exceeds maximum size of {limit} messages",
            code="CONVERSATION_LIMIT_EXCEEDED"
        )


class TokenLimitException(ChatbotException):
    """Raised when token limit is exceeded"""
    def __init__(self, used: int, limit: int):
        super().__init__(
            message=f"Token limit exceeded: {used}/{limit}",
            code="TOKEN_LIMIT_EXCEEDED",
            details={"used": used, "limit": limit}
        )


class FeedbackNotFoundException(ChatbotException):
    """Raised when feedback is not found"""
    def __init__(self, feedback_id: Any):
        super().__init__(
            message=f"Feedback not found: {feedback_id}",
            code="FEEDBACK_NOT_FOUND"
        )


class ServiceUnavailableException(ChatbotException):
    """Raised when service is temporarily unavailable"""
    def __init__(self, service: str):
        super().__init__(
            message=f"Service temporarily unavailable: {service}",
            code="SERVICE_UNAVAILABLE"
        )


class SecurityViolationException(ChatbotException):
    """Raised when security violation is detected"""
    def __init__(self, reason: str):
        super().__init__(
            message=f"Security violation: {reason}",
            code="SECURITY_VIOLATION"
        )
