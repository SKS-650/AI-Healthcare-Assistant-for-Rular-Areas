"""
Constants for Medical Chatbot Module
"""
from enum import Enum


# Message Constants
MAX_MESSAGE_LENGTH = 2000
MIN_MESSAGE_LENGTH = 1
MAX_CONVERSATION_MESSAGES = 100
MAX_TOKENS_PER_REQUEST = 4000

# Rate Limiting
RATE_LIMIT_MESSAGES_PER_MINUTE = 10
RATE_LIMIT_REQUESTS_PER_HOUR = 100
RATE_LIMIT_CONVERSATIONS_PER_DAY = 20

# Timeouts
LLM_REQUEST_TIMEOUT = 30  # seconds
DATABASE_QUERY_TIMEOUT = 10  # seconds
CACHE_OPERATION_TIMEOUT = 5  # seconds

# Session
SESSION_EXPIRY_HOURS = 24
CONVERSATION_IDLE_TIMEOUT_HOURS = 2

# Pagination
DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE = 100

# Confidence Thresholds
EMERGENCY_CONFIDENCE_THRESHOLD = 0.7
LOW_CONFIDENCE_THRESHOLD = 0.5
HIGH_CONFIDENCE_THRESHOLD = 0.8

# Language Codes
SUPPORTED_LANGUAGES = [
    'en',  # English
    'hi',  # Hindi
    'bn',  # Bengali
    'te',  # Telugu
    'ta',  # Tamil
    'mr',  # Marathi
    'gu',  # Gujarati
    'kn',  # Kannada
    'ml',  # Malayalam
    'pa',  # Punjabi
]


class MessageSender(str, Enum):
    """Message sender types"""
    USER = "user"
    ASSISTANT = "assistant"


class FeedbackType(str, Enum):
    """Feedback types"""
    HELPFUL = "helpful"
    INACCURATE = "inaccurate"
    INAPPROPRIATE = "inappropriate"
    INCOMPLETE = "incomplete"
    OTHER = "other"


class ConversationTopic(str, Enum):
    """Conversation topic categories"""
    GENERAL = "general"
    DISEASE = "disease"
    SYMPTOM = "symptom"
    MEDICINE = "medicine"
    FIRST_AID = "first_aid"
    NUTRITION = "nutrition"
    EXERCISE = "exercise"
    MENTAL_HEALTH = "mental_health"
    PREVENTIVE_CARE = "preventive_care"
    EMERGENCY = "emergency"


class EmergencyType(str, Enum):
    """Emergency types"""
    CARDIAC = "cardiac"
    STROKE = "stroke"
    SEVERE_BLEEDING = "severe_bleeding"
    BREATHING_DIFFICULTY = "breathing_difficulty"
    SEVERE_ALLERGIC_REACTION = "severe_allergic_reaction"
    POISONING = "poisoning"
    SEVERE_INJURY = "severe_injury"
    UNCONSCIOUSNESS = "unconsciousness"
    SEIZURE = "seizure"
    SEVERE_PAIN = "severe_pain"


class SafetyFilterReason(str, Enum):
    """Safety filter blocking reasons"""
    MEDICAL_DIAGNOSIS = "medical_diagnosis"
    PRESCRIPTION_REQUEST = "prescription_request"
    HARMFUL_ADVICE = "harmful_advice"
    INAPPROPRIATE_CONTENT = "inappropriate_content"
    SELF_HARM = "self_harm"
    DANGEROUS_SUGGESTION = "dangerous_suggestion"


# Suspicious Patterns for Input Validation
SUSPICIOUS_PATTERNS = [
    'DROP TABLE',
    'DELETE FROM',
    'INSERT INTO',
    'UPDATE SET',
    '<script>',
    '</script>',
    'javascript:',
    'eval(',
    'exec(',
    'onclick=',
    'onerror=',
    '../',
    '../../',
]

# Emergency Keywords
EMERGENCY_KEYWORDS = [
    'chest pain',
    'heart attack',
    'stroke',
    'can\'t breathe',
    'cannot breathe',
    'difficulty breathing',
    'severe bleeding',
    'heavy bleeding',
    'unconscious',
    'not breathing',
    'seizure',
    'convulsion',
    'overdose',
    'poisoning',
    'severe injury',
    'severe accident',
    'severe pain',
    'suicide',
    'kill myself',
]

# Medical Disclaimer
MEDICAL_DISCLAIMER = (
    "⚠️ Important: I'm an AI assistant providing general health information only. "
    "I cannot diagnose conditions or prescribe treatments. "
    "Always consult qualified healthcare professionals for medical advice."
)

# Emergency Disclaimer
EMERGENCY_DISCLAIMER = (
    "🚨 EMERGENCY DETECTED: If this is a medical emergency, please call emergency services "
    "immediately (108 in India, 911 in US) or go to the nearest hospital. "
    "Do not rely solely on this chatbot in emergency situations."
)

# Recommended Follow-up Actions
RECOMMEND_DOCTOR_VISIT = "I recommend consulting a healthcare provider for proper evaluation."
RECOMMEND_EMERGENCY_SERVICES = "Please call emergency services or visit the nearest hospital immediately."
RECOMMEND_SYMPTOM_CHECKER = "You may want to use our symptom checker for a more detailed assessment."
RECOMMEND_FIRST_AID = "Here's some basic first aid guidance, but seek medical attention if symptoms worsen."

# Logging
LOG_SENSITIVE_FIELDS = [
    'password',
    'token',
    'api_key',
    'secret',
    'auth',
]

# Cache Keys
CACHE_KEY_CONVERSATION = "chatbot:conversation:{conversation_id}"
CACHE_KEY_USER_RATE_LIMIT = "chatbot:rate_limit:{user_id}"
CACHE_KEY_USER_MESSAGES = "chatbot:messages:{user_id}"
CACHE_KEY_SESSION = "chatbot:session:{session_id}"

# Cache TTL (Time To Live)
CACHE_TTL_CONVERSATION = 3600  # 1 hour
CACHE_TTL_RATE_LIMIT = 60  # 1 minute
CACHE_TTL_SESSION = 86400  # 24 hours
