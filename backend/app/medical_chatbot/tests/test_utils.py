"""
Tests for Medical Chatbot Utilities
"""
import pytest
from datetime import datetime, timedelta

from ..utils.helpers import (
    validate_message,
    detect_emergency_keywords,
    sanitize_html,
    truncate_text,
    generate_conversation_title,
    calculate_confidence,
    is_session_expired,
    hash_content,
    extract_keywords
)
from ..utils.exceptions import (
    EmptyMessageException,
    MessageTooLongException,
    SuspiciousContentException
)


class TestHelpers:
    """Test cases for helper functions"""
    
    def test_validate_message_success(self):
        """Test successful message validation"""
        message = "What are the symptoms of diabetes?"
        result = validate_message(message)
        assert result == message
    
    def test_validate_message_empty(self):
        """Test empty message validation"""
        with pytest.raises(EmptyMessageException):
            validate_message("")
        
        with pytest.raises(EmptyMessageException):
            validate_message("   ")
    
    def test_validate_message_too_long(self):
        """Test message too long"""
        message = "a" * 3000  # Exceeds MAX_MESSAGE_LENGTH
        with pytest.raises(MessageTooLongException):
            validate_message(message)
    
    def test_validate_message_suspicious_content(self):
        """Test suspicious content detection"""
        messages = [
            "DROP TABLE users",
            "DELETE FROM database",
            "<script>alert('xss')</script>",
            "javascript:void(0)"
        ]
        
        for msg in messages:
            with pytest.raises(SuspiciousContentException):
                validate_message(msg)
    
    def test_detect_emergency_keywords_found(self):
        """Test emergency keyword detection - positive"""
        messages = [
            "I'm having chest pain",
            "Can't breathe properly",
            "Severe bleeding from wound",
            "Someone is unconscious"
        ]
        
        for msg in messages:
            is_emergency, keyword = detect_emergency_keywords(msg)
            assert is_emergency is True
            assert keyword is not None
    
    def test_detect_emergency_keywords_not_found(self):
        """Test emergency keyword detection - negative"""
        messages = [
            "What is diabetes?",
            "Tell me about healthy diet",
            "How to prevent flu?"
        ]
        
        for msg in messages:
            is_emergency, keyword = detect_emergency_keywords(msg)
            assert is_emergency is False
            assert keyword is None
    
    def test_sanitize_html(self):
        """Test HTML sanitization"""
        html = "<p>Hello <b>world</b></p>"
        result = sanitize_html(html)
        assert result == "Hello world"
        assert "<" not in result
        assert ">" not in result
    
    def test_truncate_text(self):
        """Test text truncation"""
        text = "This is a very long text that needs to be truncated"
        result = truncate_text(text, max_length=20)
        assert len(result) <= 20
        assert result.endswith("...")
    
    def test_truncate_text_no_truncation(self):
        """Test text truncation when not needed"""
        text = "Short text"
        result = truncate_text(text, max_length=20)
        assert result == text
    
    def test_generate_conversation_title(self):
        """Test conversation title generation"""
        message = "What are the symptoms of diabetes?"
        title = generate_conversation_title(message, max_length=30)
        assert len(title) <= 30
        assert title != ""
    
    def test_generate_conversation_title_long_message(self):
        """Test title generation from long message"""
        message = "This is a very long message that should be truncated when creating the title"
        title = generate_conversation_title(message, max_length=30)
        assert len(title) <= 30
    
    def test_calculate_confidence(self):
        """Test confidence calculation"""
        factors = {
            'llm_confidence': 0.9,
            'retrieval_score': 0.8,
            'validation_score': 0.85,
            'context_relevance': 0.75
        }
        
        confidence = calculate_confidence(factors)
        assert 0.0 <= confidence <= 1.0
    
    def test_calculate_confidence_empty(self):
        """Test confidence calculation with no factors"""
        confidence = calculate_confidence({})
        assert confidence == 0.5  # Default value
    
    def test_is_session_expired_true(self):
        """Test expired session detection"""
        last_activity = datetime.utcnow() - timedelta(hours=25)
        assert is_session_expired(last_activity, expiry_hours=24) is True
    
    def test_is_session_expired_false(self):
        """Test active session detection"""
        last_activity = datetime.utcnow() - timedelta(hours=1)
        assert is_session_expired(last_activity, expiry_hours=24) is False
    
    def test_hash_content(self):
        """Test content hashing"""
        content = "test content"
        hash1 = hash_content(content)
        hash2 = hash_content(content)
        
        assert hash1 == hash2  # Same content, same hash
        assert len(hash1) == 64  # SHA256 hex digest length
    
    def test_hash_content_different(self):
        """Test different content produces different hashes"""
        hash1 = hash_content("content1")
        hash2 = hash_content("content2")
        
        assert hash1 != hash2
    
    def test_extract_keywords(self):
        """Test keyword extraction"""
        text = "What are the symptoms of diabetes and how to prevent it?"
        keywords = extract_keywords(text, max_keywords=5)
        
        assert len(keywords) <= 5
        assert "symptoms" in keywords
        assert "diabetes" in keywords
        assert "prevent" in keywords
    
    def test_extract_keywords_filters_stopwords(self):
        """Test keyword extraction filters stop words"""
        text = "The patient is experiencing severe pain in the chest"
        keywords = extract_keywords(text)
        
        # Stop words should be filtered out
        stop_words = ["the", "is", "in"]
        for word in stop_words:
            assert word not in keywords
