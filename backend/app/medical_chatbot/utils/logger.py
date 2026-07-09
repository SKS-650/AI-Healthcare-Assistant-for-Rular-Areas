"""
Logging utilities for Medical Chatbot Module
"""
import logging
import sys
from typing import Any, Dict, Optional
from datetime import datetime
import json

from .constants import LOG_SENSITIVE_FIELDS


class ChatbotLogger:
    """Custom logger for chatbot module with structured logging"""
    
    def __init__(self, name: str = "medical_chatbot"):
        self.logger = logging.getLogger(name)
        self._setup_logger()
    
    def _setup_logger(self):
        """Setup logger with formatter and handler"""
        if not self.logger.handlers:
            handler = logging.StreamHandler(sys.stdout)
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                datefmt='%Y-%m-%d %H:%M:%S'
            )
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
            self.logger.setLevel(logging.INFO)
    
    def _sanitize_data(self, data: Any) -> Any:
        """Remove sensitive information from logs"""
        if isinstance(data, dict):
            return {
                k: '***REDACTED***' if any(sensitive in k.lower() for sensitive in LOG_SENSITIVE_FIELDS) else self._sanitize_data(v)
                for k, v in data.items()
            }
        elif isinstance(data, list):
            return [self._sanitize_data(item) for item in data]
        return data
    
    def _format_extra(self, extra: Optional[Dict[str, Any]]) -> str:
        """Format extra data for logging"""
        if not extra:
            return ""
        
        sanitized = self._sanitize_data(extra)
        try:
            return f" | {json.dumps(sanitized, default=str)}"
        except Exception:
            return f" | {str(sanitized)}"
    
    def info(self, message: str, extra: Optional[Dict[str, Any]] = None):
        """Log info message"""
        self.logger.info(f"{message}{self._format_extra(extra)}")
    
    def error(self, message: str, extra: Optional[Dict[str, Any]] = None, exc_info: bool = False):
        """Log error message"""
        self.logger.error(f"{message}{self._format_extra(extra)}", exc_info=exc_info)
    
    def warning(self, message: str, extra: Optional[Dict[str, Any]] = None):
        """Log warning message"""
        self.logger.warning(f"{message}{self._format_extra(extra)}")
    
    def debug(self, message: str, extra: Optional[Dict[str, Any]] = None):
        """Log debug message"""
        self.logger.debug(f"{message}{self._format_extra(extra)}")
    
    def log_conversation_started(
        self,
        conversation_id: str,
        user_id: int,
        language: str
    ):
        """Log conversation start"""
        self.info("Conversation started", extra={
            "event": "conversation_started",
            "conversation_id": conversation_id,
            "user_id": user_id,
            "language": language,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_message_received(
        self,
        conversation_id: str,
        user_id: int,
        message_length: int
    ):
        """Log message received"""
        self.info("Message received", extra={
            "event": "message_received",
            "conversation_id": conversation_id,
            "user_id": user_id,
            "message_length": message_length,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_llm_request(
        self,
        conversation_id: str,
        tokens: Optional[int] = None,
        model: Optional[str] = None
    ):
        """Log LLM request"""
        self.info("LLM request sent", extra={
            "event": "llm_request",
            "conversation_id": conversation_id,
            "tokens": tokens,
            "model": model,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_llm_response(
        self,
        conversation_id: str,
        response_time: float,
        tokens_used: Optional[int] = None,
        confidence: Optional[float] = None
    ):
        """Log LLM response"""
        self.info("LLM response received", extra={
            "event": "llm_response",
            "conversation_id": conversation_id,
            "response_time": response_time,
            "tokens_used": tokens_used,
            "confidence": confidence,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_emergency_detected(
        self,
        conversation_id: str,
        user_id: int,
        emergency_type: str,
        confidence: float
    ):
        """Log emergency detection"""
        self.warning("Emergency detected", extra={
            "event": "emergency_detected",
            "conversation_id": conversation_id,
            "user_id": user_id,
            "emergency_type": emergency_type,
            "confidence": confidence,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_feedback_submitted(
        self,
        conversation_id: str,
        user_id: int,
        rating: int,
        feedback_type: Optional[str] = None
    ):
        """Log feedback submission"""
        self.info("Feedback submitted", extra={
            "event": "feedback_submitted",
            "conversation_id": conversation_id,
            "user_id": user_id,
            "rating": rating,
            "feedback_type": feedback_type,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_rate_limit_exceeded(
        self,
        user_id: int,
        limit_type: str
    ):
        """Log rate limit exceeded"""
        self.warning("Rate limit exceeded", extra={
            "event": "rate_limit_exceeded",
            "user_id": user_id,
            "limit_type": limit_type,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_validation_error(
        self,
        user_id: int,
        error_type: str,
        details: Optional[Dict[str, Any]] = None
    ):
        """Log validation error"""
        self.warning("Validation error", extra={
            "event": "validation_error",
            "user_id": user_id,
            "error_type": error_type,
            "details": details,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_safety_filter_triggered(
        self,
        conversation_id: str,
        user_id: int,
        reason: str
    ):
        """Log safety filter trigger"""
        self.warning("Safety filter triggered", extra={
            "event": "safety_filter_triggered",
            "conversation_id": conversation_id,
            "user_id": user_id,
            "reason": reason,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_database_error(
        self,
        operation: str,
        error: str,
        details: Optional[Dict[str, Any]] = None
    ):
        """Log database error"""
        self.error("Database error", extra={
            "event": "database_error",
            "operation": operation,
            "error": error,
            "details": details,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    def log_cache_operation(
        self,
        operation: str,
        key: str,
        success: bool
    ):
        """Log cache operation"""
        self.debug("Cache operation", extra={
            "event": "cache_operation",
            "operation": operation,
            "key": key,
            "success": success,
            "timestamp": datetime.utcnow().isoformat()
        })


# Global logger instance
logger = ChatbotLogger()
