"""
Helper utilities for Medical Chatbot Module
"""
from typing import Optional, Any, Dict, List
import re
from datetime import datetime, timedelta
import hashlib
import uuid

from .constants import (
    SUSPICIOUS_PATTERNS,
    EMERGENCY_KEYWORDS,
    MAX_MESSAGE_LENGTH,
    MIN_MESSAGE_LENGTH
)
from .exceptions import (
    InvalidMessageException,
    EmptyMessageException,
    MessageTooLongException,
    SuspiciousContentException
)


def validate_message(message: str) -> str:
    """
    Validate and sanitize user message
    
    Args:
        message: User input message
        
    Returns:
        Sanitized message
        
    Raises:
        EmptyMessageException: If message is empty
        MessageTooLongException: If message exceeds max length
        SuspiciousContentException: If message contains suspicious patterns
    """
    if not message or not message.strip():
        raise EmptyMessageException()
    
    # Remove excessive whitespace
    message = ' '.join(message.split())
    
    # Check length
    if len(message) < MIN_MESSAGE_LENGTH:
        raise EmptyMessageException()
    
    if len(message) > MAX_MESSAGE_LENGTH:
        raise MessageTooLongException(MAX_MESSAGE_LENGTH)
    
    # Check for suspicious patterns
    message_upper = message.upper()
    for pattern in SUSPICIOUS_PATTERNS:
        if pattern in message_upper:
            raise SuspiciousContentException(pattern)
    
    return message.strip()


def detect_emergency_keywords(message: str) -> tuple[bool, Optional[str]]:
    """
    Detect emergency keywords in message
    
    Args:
        message: User message
        
    Returns:
        Tuple of (is_emergency, matched_keyword)
    """
    message_lower = message.lower()
    
    for keyword in EMERGENCY_KEYWORDS:
        if keyword in message_lower:
            return True, keyword
    
    return False, None


def sanitize_html(text: str) -> str:
    """
    Remove HTML tags from text
    
    Args:
        text: Input text
        
    Returns:
        Text without HTML tags
    """
    clean = re.compile('<.*?>')
    return re.sub(clean, '', text)


def truncate_text(text: str, max_length: int = 100, suffix: str = "...") -> str:
    """
    Truncate text to maximum length
    
    Args:
        text: Input text
        max_length: Maximum length
        suffix: Suffix to add if truncated
        
    Returns:
        Truncated text
    """
    if len(text) <= max_length:
        return text
    
    return text[:max_length - len(suffix)] + suffix


def generate_conversation_title(message: str, max_length: int = 50) -> str:
    """
    Generate conversation title from first message
    
    Args:
        message: First user message
        max_length: Maximum title length
        
    Returns:
        Generated title
    """
    # Remove special characters and excessive whitespace
    title = re.sub(r'[^\w\s]', '', message)
    title = ' '.join(title.split())
    
    # Truncate if needed
    if len(title) > max_length:
        title = title[:max_length - 3] + "..."
    
    return title or "New Conversation"


def calculate_confidence(factors: Dict[str, float]) -> float:
    """
    Calculate confidence score from multiple factors
    
    Args:
        factors: Dictionary of factor names and their scores (0-1)
        
    Returns:
        Overall confidence score (0-1)
    """
    if not factors:
        return 0.5
    
    # Weighted average
    weights = {
        'llm_confidence': 0.4,
        'retrieval_score': 0.3,
        'validation_score': 0.2,
        'context_relevance': 0.1
    }
    
    total_weight = 0.0
    weighted_sum = 0.0
    
    for factor, score in factors.items():
        weight = weights.get(factor, 0.1)
        weighted_sum += score * weight
        total_weight += weight
    
    if total_weight == 0:
        return sum(factors.values()) / len(factors)
    
    return min(max(weighted_sum / total_weight, 0.0), 1.0)


def format_timestamp(dt: datetime, format: str = "%Y-%m-%d %H:%M:%S") -> str:
    """
    Format datetime to string
    
    Args:
        dt: Datetime object
        format: Format string
        
    Returns:
        Formatted timestamp
    """
    return dt.strftime(format)


def parse_timestamp(timestamp: str, format: str = "%Y-%m-%d %H:%M:%S") -> datetime:
    """
    Parse timestamp string to datetime
    
    Args:
        timestamp: Timestamp string
        format: Format string
        
    Returns:
        Datetime object
    """
    return datetime.strptime(timestamp, format)


def is_session_expired(last_activity: datetime, expiry_hours: int = 24) -> bool:
    """
    Check if session has expired
    
    Args:
        last_activity: Last activity timestamp
        expiry_hours: Session expiry in hours
        
    Returns:
        True if expired, False otherwise
    """
    expiry_time = last_activity + timedelta(hours=expiry_hours)
    return datetime.utcnow() > expiry_time


def hash_content(content: str) -> str:
    """
    Generate SHA256 hash of content
    
    Args:
        content: Content to hash
        
    Returns:
        Hex digest of hash
    """
    return hashlib.sha256(content.encode()).hexdigest()


def generate_session_id() -> str:
    """
    Generate unique session ID
    
    Returns:
        UUID string
    """
    return str(uuid.uuid4())


def extract_keywords(text: str, max_keywords: int = 10) -> List[str]:
    """
    Extract keywords from text (simple implementation)
    
    Args:
        text: Input text
        max_keywords: Maximum number of keywords
        
    Returns:
        List of keywords
    """
    # Remove special characters and convert to lowercase
    clean_text = re.sub(r'[^\w\s]', '', text.lower())
    
    # Split into words
    words = clean_text.split()
    
    # Remove common stop words (simple list)
    stop_words = {
        'the', 'a', 'an', 'and', 'or', 'but', 'is', 'are', 'was', 'were',
        'to', 'of', 'in', 'on', 'at', 'by', 'for', 'with', 'about', 'as',
        'i', 'you', 'he', 'she', 'it', 'we', 'they', 'what', 'which', 'who',
        'when', 'where', 'why', 'how', 'this', 'that', 'these', 'those'
    }
    
    # Filter stop words and get unique words
    keywords = [word for word in words if word not in stop_words and len(word) > 2]
    
    # Get most common words (simplified - just take unique words)
    unique_keywords = list(dict.fromkeys(keywords))
    
    return unique_keywords[:max_keywords]


def format_citations(citations: List[Dict[str, Any]]) -> str:
    """
    Format citations for display
    
    Args:
        citations: List of citation dictionaries
        
    Returns:
        Formatted citation string
    """
    if not citations:
        return ""
    
    formatted = "\n\n**Sources:**\n"
    for i, citation in enumerate(citations, 1):
        source = citation.get('source', 'Unknown')
        url = citation.get('url', '')
        if url:
            formatted += f"{i}. [{source}]({url})\n"
        else:
            formatted += f"{i}. {source}\n"
    
    return formatted


def chunk_text(text: str, chunk_size: int = 1000, overlap: int = 100) -> List[str]:
    """
    Split text into overlapping chunks
    
    Args:
        text: Input text
        chunk_size: Size of each chunk
        overlap: Overlap between chunks
        
    Returns:
        List of text chunks
    """
    if len(text) <= chunk_size:
        return [text]
    
    chunks = []
    start = 0
    
    while start < len(text):
        end = start + chunk_size
        
        # Try to break at sentence boundary
        if end < len(text):
            # Look for sentence ending
            sentence_end = text.rfind('.', start, end)
            if sentence_end > start:
                end = sentence_end + 1
        
        chunks.append(text[start:end])
        start = end - overlap
    
    return chunks


def format_error_message(error: Exception, user_friendly: bool = True) -> str:
    """
    Format error message for display
    
    Args:
        error: Exception object
        user_friendly: Whether to return user-friendly message
        
    Returns:
        Formatted error message
    """
    if user_friendly:
        # Return generic user-friendly message
        return "I apologize, but I encountered an error processing your request. Please try again."
    
    return str(error)


def calculate_reading_time(text: str, words_per_minute: int = 200) -> int:
    """
    Calculate estimated reading time in seconds
    
    Args:
        text: Input text
        words_per_minute: Average reading speed
        
    Returns:
        Reading time in seconds
    """
    word_count = len(text.split())
    minutes = word_count / words_per_minute
    return int(minutes * 60)


def mask_sensitive_data(data: Dict[str, Any], sensitive_keys: List[str]) -> Dict[str, Any]:
    """
    Mask sensitive data in dictionary
    
    Args:
        data: Input dictionary
        sensitive_keys: List of keys to mask
        
    Returns:
        Dictionary with masked values
    """
    masked = data.copy()
    
    for key in sensitive_keys:
        if key in masked:
            masked[key] = "***MASKED***"
    
    return masked
