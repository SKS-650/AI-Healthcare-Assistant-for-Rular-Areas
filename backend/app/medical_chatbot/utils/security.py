"""
Security Validation Utilities
Basic security measures for college project
"""
import re
from typing import Optional, List, Tuple
from .exceptions import InvalidMessageException, SecurityViolationException
from .logger import logger


class MessageValidator:
    """Validate and sanitize user messages"""
    
    # Dangerous patterns that might indicate injection attempts
    DANGEROUS_PATTERNS = [
        # SQL injection patterns
        r"('|\")\s*(OR|AND)\s*\d+\s*=\s*\d+",
        r"(DROP|DELETE|TRUNCATE|ALTER)\s+(TABLE|DATABASE)",
        r"UNION\s+SELECT",
        
        # Script injection patterns
        r"<script[^>]*>.*?</script>",
        r"javascript:",
        r"onerror\s*=",
        r"onclick\s*=",
        
        # Command injection
        r";\s*(rm|del|format|shutdown)",
        r"\$\(.*\)",
        r"`.*`",
    ]
    
    # Excessive special characters that might indicate abuse
    EXCESSIVE_SPECIAL_CHARS = r"[^\w\s,.!?'-]"
    
    @staticmethod
    def validate_message(message: str) -> Tuple[bool, Optional[str]]:
        """
        Validate user message for security issues
        
        Args:
            message: User message to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        # Check length
        if not message or len(message.strip()) == 0:
            return False, "Message cannot be empty"
        
        if len(message) > 5000:
            return False, "Message too long (max 5000 characters)"
        
        # Check for dangerous patterns
        for pattern in MessageValidator.DANGEROUS_PATTERNS:
            if re.search(pattern, message, re.IGNORECASE):
                logger.warning(f"Dangerous pattern detected in message: {pattern}")
                return False, "Message contains potentially harmful content"
        
        # Check for excessive special characters (> 30% of message)
        special_chars = re.findall(MessageValidator.EXCESSIVE_SPECIAL_CHARS, message)
        if len(special_chars) > len(message) * 0.3:
            return False, "Message contains too many special characters"
        
        # Check for repeated characters (spam detection)
        if re.search(r"(.)\1{10,}", message):
            return False, "Message contains excessive repeated characters"
        
        return True, None
    
    @staticmethod
    def sanitize_message(message: str) -> str:
        """
        Sanitize user message
        
        Args:
            message: Raw message
            
        Returns:
            Sanitized message
        """
        # Remove HTML tags
        message = re.sub(r"<[^>]+>", "", message)
        
        # Remove null bytes
        message = message.replace("\x00", "")
        
        # Normalize whitespace
        message = " ".join(message.split())
        
        # Trim to max length
        if len(message) > 5000:
            message = message[:5000]
        
        return message.strip()


class PromptInjectionDetector:
    """
    Detect basic prompt injection attempts
    
    Prompt injection is when users try to manipulate the AI by adding
    instructions in their message.
    """
    
    INJECTION_KEYWORDS = [
        "ignore previous instructions",
        "ignore above",
        "disregard",
        "forget everything",
        "new instructions",
        "system prompt",
        "you are now",
        "act as if",
        "pretend you are",
        "roleplay as",
        "your new role is",
    ]
    
    @staticmethod
    def detect_injection(message: str) -> Tuple[bool, Optional[str]]:
        """
        Detect potential prompt injection
        
        Args:
            message: User message
            
        Returns:
            Tuple of (is_injection, matched_pattern)
        """
        message_lower = message.lower()
        
        for keyword in PromptInjectionDetector.INJECTION_KEYWORDS:
            if keyword in message_lower:
                logger.warning(f"Prompt injection attempt detected: {keyword}")
                return True, keyword
        
        return False, None


class ConversationOwnershipValidator:
    """Validate conversation ownership"""
    
    @staticmethod
    def validate_ownership(
        conversation_user_id: int,
        requesting_user_id: int,
        is_admin: bool = False
    ) -> bool:
        """
        Validate that user has access to conversation
        
        Args:
            conversation_user_id: User ID that owns the conversation
            requesting_user_id: User ID making the request
            is_admin: Whether requesting user is admin
            
        Returns:
            True if access allowed, False otherwise
        """
        # Admin can access any conversation
        if is_admin:
            return True
        
        # User can only access their own conversations
        return conversation_user_id == requesting_user_id


class RateLimitTracker:
    """
    Simple in-memory rate limiting
    
    Note: For production with multiple servers, use Redis
    """
    
    def __init__(self):
        self._requests: dict = {}  # user_id -> list of timestamps
    
    def check_rate_limit(
        self,
        user_id: int,
        max_requests: int,
        time_window: int
    ) -> Tuple[bool, int]:
        """
        Check if user has exceeded rate limit
        
        Args:
            user_id: User ID
            max_requests: Maximum allowed requests
            time_window: Time window in seconds
            
        Returns:
            Tuple of (is_allowed, remaining_requests)
        """
        import time
        
        now = time.time()
        
        # Initialize user's request list
        if user_id not in self._requests:
            self._requests[user_id] = []
        
        # Remove old requests outside time window
        self._requests[user_id] = [
            req_time for req_time in self._requests[user_id]
            if now - req_time < time_window
        ]
        
        # Check if under limit
        current_requests = len(self._requests[user_id])
        
        if current_requests >= max_requests:
            return False, 0
        
        # Record this request
        self._requests[user_id].append(now)
        
        remaining = max_requests - current_requests - 1
        return True, remaining
    
    def reset_user(self, user_id: int):
        """Reset rate limit for user"""
        if user_id in self._requests:
            del self._requests[user_id]


# Global rate limiter instance
rate_limiter = RateLimitTracker()


class InputSanitizer:
    """Sanitize various input types"""
    
    @staticmethod
    def sanitize_conversation_id(conversation_id: str) -> str:
        """Sanitize conversation UUID"""
        # UUIDs should only contain hex digits and hyphens
        if not re.match(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", conversation_id, re.IGNORECASE):
            raise InvalidMessageException("Invalid conversation ID format")
        return conversation_id
    
    @staticmethod
    def sanitize_language(language: str) -> str:
        """Sanitize language code"""
        # Language codes should be 2-3 letters
        if not re.match(r"^[a-z]{2,3}$", language, re.IGNORECASE):
            raise InvalidMessageException("Invalid language code")
        return language.lower()
    
    @staticmethod
    def sanitize_rating(rating: int) -> int:
        """Sanitize rating value"""
        if not isinstance(rating, int) or rating < 1 or rating > 5:
            raise InvalidMessageException("Rating must be between 1 and 5")
        return rating
    
    @staticmethod
    def sanitize_page_number(page: int) -> int:
        """Sanitize page number"""
        if not isinstance(page, int) or page < 1:
            raise InvalidMessageException("Page number must be positive")
        return page
    
    @staticmethod
    def sanitize_page_size(page_size: int, max_size: int = 100) -> int:
        """Sanitize page size"""
        if not isinstance(page_size, int) or page_size < 1:
            raise InvalidMessageException("Page size must be positive")
        
        if page_size > max_size:
            raise InvalidMessageException(f"Page size cannot exceed {max_size}")
        
        return page_size


class SecurityMiddleware:
    """
    Security middleware for API requests
    Performs validation before processing
    """
    
    @staticmethod
    def validate_chat_request(message: str, conversation_id: Optional[str] = None) -> str:
        """
        Validate chat request
        
        Args:
            message: User message
            conversation_id: Optional conversation ID
            
        Returns:
            Sanitized message
            
        Raises:
            InvalidMessageException: If validation fails
            SecurityViolationException: If security issue detected
        """
        # Validate message
        is_valid, error = MessageValidator.validate_message(message)
        if not is_valid:
            raise InvalidMessageException(error)
        
        # Detect prompt injection
        is_injection, keyword = PromptInjectionDetector.detect_injection(message)
        if is_injection:
            logger.warning(f"Prompt injection detected: {keyword}")
            # Don't block, just log and sanitize
            # raise SecurityViolationException(f"Potential prompt injection detected")
        
        # Sanitize message
        sanitized = MessageValidator.sanitize_message(message)
        
        # Validate conversation ID if provided
        if conversation_id:
            InputSanitizer.sanitize_conversation_id(conversation_id)
        
        return sanitized
    
    @staticmethod
    def check_rate_limit(user_id: int, max_requests: int = 60, time_window: int = 60) -> bool:
        """
        Check rate limit for user
        
        Args:
            user_id: User ID
            max_requests: Maximum requests allowed (default: 60)
            time_window: Time window in seconds (default: 60)
            
        Returns:
            True if allowed, False if rate limit exceeded
        """
        is_allowed, remaining = rate_limiter.check_rate_limit(
            user_id,
            max_requests,
            time_window
        )
        
        if not is_allowed:
            logger.log_rate_limit_exceeded(user_id, "api_request")
            return False
        
        return True


def validate_jwt_token(token: str) -> bool:
    """
    Basic JWT token validation
    
    Args:
        token: JWT token string
        
    Returns:
        True if valid format, False otherwise
    """
    # JWT has 3 parts separated by dots
    parts = token.split(".")
    
    if len(parts) != 3:
        return False
    
    # Each part should be base64url encoded
    for part in parts:
        if not re.match(r"^[A-Za-z0-9_-]+$", part):
            return False
    
    return True


def mask_sensitive_data(data: str, mask_char: str = "*") -> str:
    """
    Mask sensitive data for logging
    
    Args:
        data: Sensitive data to mask
        mask_char: Character to use for masking
        
    Returns:
        Masked data
    """
    if not data or len(data) < 4:
        return mask_char * 8
    
    # Show first and last 2 characters
    return f"{data[:2]}{mask_char * (len(data) - 4)}{data[-2:]}"


def sanitize_log_message(message: str) -> str:
    """
    Sanitize message before logging
    Remove potential sensitive information
    
    Args:
        message: Log message
        
    Returns:
        Sanitized log message
    """
    # Mask email addresses
    message = re.sub(
        r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
        "[EMAIL]",
        message
    )
    
    # Mask phone numbers
    message = re.sub(
        r"\b\d{10,15}\b",
        "[PHONE]",
        message
    )
    
    # Mask credit card numbers
    message = re.sub(
        r"\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b",
        "[CARD]",
        message
    )
    
    # Mask tokens (Bearer tokens)
    message = re.sub(
        r"Bearer\s+[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+",
        "Bearer [TOKEN]",
        message
    )
    
    return message
