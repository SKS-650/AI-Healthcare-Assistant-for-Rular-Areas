"""
Response Validator - Validates AI responses for safety and quality
"""
from typing import Tuple, Optional, Dict, Any
import re

from ..utils.logger import logger
from ..utils.constants import EMERGENCY_KEYWORDS, MEDICAL_DISCLAIMER


class ResponseValidator:
    """Validates AI responses before sending to users"""
    
    # Dangerous phrases that should never appear
    DANGEROUS_PHRASES = [
        "you have",
        "you are diagnosed",
        "you definitely have",
        "you are suffering from",
        "take this medicine",
        "take this drug",
        "here is your prescription",
        "prescribed dosage",
        "you should take",
        "stop taking your",
        "discontinue your medication",
        "don't see a doctor",
        "you don't need a doctor",
        "skip your medication",
        "guaranteed cure",
        "definitely cured",
        "100% effective"
    ]
    
    # Offensive/inappropriate words
    OFFENSIVE_WORDS = [
        "stupid", "idiot", "fool", "dumb", "moron",
        "useless", "worthless"
    ]
    
    def __init__(self):
        """Initialize validator"""
        pass
    
    def validate_response(
        self,
        response: str,
        user_message: str
    ) -> Tuple[bool, Optional[str], Optional[Dict[str, Any]]]:
        """
        Validate AI response
        
        Args:
            response: AI generated response
            user_message: Original user message
            
        Returns:
            Tuple of (is_valid, error_reason, metadata)
        """
        metadata = {
            "length": len(response),
            "warnings": []
        }
        
        # 1. Check if response is empty
        if not response or not response.strip():
            return False, "Empty response", metadata
        
        # 2. Check if response is too short
        if len(response.strip()) < 20:
            return False, "Response too short", metadata
        
        # 3. Check if response is too long
        if len(response) > 2000:
            metadata["warnings"].append("Response very long")
            logger.warning("Response exceeds recommended length")
        
        # 4. Check for dangerous diagnostic phrases
        response_lower = response.lower()
        for phrase in self.DANGEROUS_PHRASES:
            if phrase in response_lower:
                logger.warning(f"Dangerous phrase detected: {phrase}")
                return False, f"Dangerous phrase: {phrase}", metadata
        
        # 5. Check for offensive language
        for word in self.OFFENSIVE_WORDS:
            if word in response_lower:
                logger.warning(f"Offensive word detected: {word}")
                return False, f"Offensive language: {word}", metadata
        
        # 6. Check for medical disclaimer
        if not self._has_disclaimer(response):
            metadata["warnings"].append("Missing disclaimer")
            # Add disclaimer automatically
            response_with_disclaimer = f"{response}\n\n{MEDICAL_DISCLAIMER}"
            logger.info("Added medical disclaimer to response")
        
        # 7. Check if response is relevant
        if not self._is_relevant(response, user_message):
            metadata["warnings"].append("Possibly irrelevant response")
        
        logger.info(f"Response validation passed with {len(metadata['warnings'])} warnings")
        return True, None, metadata
    
    def _has_disclaimer(self, response: str) -> bool:
        """Check if response contains medical disclaimer"""
        disclaimer_keywords = [
            "consult", "doctor", "healthcare professional",
            "medical advice", "physician"
        ]
        
        response_lower = response.lower()
        return any(keyword in response_lower for keyword in disclaimer_keywords)
    
    def _is_relevant(self, response: str, user_message: str) -> bool:
        """
        Check if response is relevant to user message
        Simple heuristic: check for keyword overlap
        """
        # Extract key words from user message (simple approach)
        user_words = set(re.findall(r'\b\w+\b', user_message.lower()))
        response_words = set(re.findall(r'\b\w+\b', response.lower()))
        
        # Remove common stop words
        stop_words = {
            'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at',
            'to', 'for', 'of', 'is', 'are', 'was', 'were', 'what',
            'how', 'why', 'when', 'where', 'can', 'could', 'will'
        }
        
        user_words -= stop_words
        response_words -= stop_words
        
        # Check overlap
        if not user_words:
            return True  # Can't determine, assume relevant
        
        overlap = user_words & response_words
        overlap_ratio = len(overlap) / len(user_words)
        
        # At least 20% keyword overlap
        return overlap_ratio >= 0.2
    
    def sanitize_response(self, response: str) -> str:
        """
        Sanitize response by removing/replacing unsafe content
        
        Args:
            response: Original response
            
        Returns:
            Sanitized response
        """
        sanitized = response
        
        # Replace dangerous diagnostic phrases
        replacements = {
            "you have": "you may have",
            "you are diagnosed": "this could be",
            "you definitely have": "this might be",
            "you are suffering from": "you may be experiencing",
            "take this medicine": "your doctor may prescribe medicine",
            "here is your prescription": "please consult a doctor for prescription"
        }
        
        for dangerous, safe in replacements.items():
            sanitized = re.sub(
                re.escape(dangerous),
                safe,
                sanitized,
                flags=re.IGNORECASE
            )
        
        # Ensure disclaimer is present
        if not self._has_disclaimer(sanitized):
            sanitized += f"\n\n{MEDICAL_DISCLAIMER}"
        
        return sanitized
    
    def get_fallback_response(self, reason: str = "validation_failed") -> str:
        """Get safe fallback response when validation fails"""
        fallbacks = {
            "validation_failed": (
                "I apologize, but I'm having trouble providing a safe and accurate response. "
                "For your health concerns, please consult a qualified healthcare professional. "
                f"\n\n{MEDICAL_DISCLAIMER}"
            ),
            "empty_response": (
                "I wasn't able to generate a response to your question. "
                "For medical advice, please consult a healthcare professional."
            ),
            "dangerous_content": (
                "I apologize, but I cannot provide that information safely. "
                "Please consult a qualified healthcare professional for medical advice. "
                f"\n\n{MEDICAL_DISCLAIMER}"
            ),
            "too_complex": (
                "Your question involves complex medical topics that require professional expertise. "
                "I recommend consulting a qualified healthcare professional for accurate information. "
                f"\n\n{MEDICAL_DISCLAIMER}"
            )
        }
        
        return fallbacks.get(reason, fallbacks["validation_failed"])


class EmergencyDetector:
    """Detects emergency situations in user messages"""
    
    # Emergency keywords by category
    CARDIAC_EMERGENCY = [
        "chest pain", "heart attack", "heart racing", "crushing chest",
        "pressure in chest", "pain radiating"
    ]
    
    BREATHING_EMERGENCY = [
        "can't breathe", "cannot breathe", "difficulty breathing",
        "shortness of breath", "gasping", "choking"
    ]
    
    BLEEDING_EMERGENCY = [
        "severe bleeding", "heavy bleeding", "bleeding won't stop",
        "blood gushing", "arterial bleeding"
    ]
    
    NEUROLOGICAL_EMERGENCY = [
        "stroke", "sudden numbness", "slurred speech", "face drooping",
        "severe headache", "loss of consciousness", "unconscious",
        "seizure", "convulsion", "fit"
    ]
    
    TRAUMA_EMERGENCY = [
        "severe injury", "broken bone", "compound fracture",
        "head injury", "fell from height", "car accident"
    ]
    
    POISONING_EMERGENCY = [
        "poisoning", "overdose", "swallowed poison",
        "chemical burn", "toxic"
    ]
    
    ALLERGIC_EMERGENCY = [
        "allergic reaction", "anaphylaxis", "swelling throat",
        "severe swelling", "hives all over"
    ]
    
    def __init__(self):
        """Initialize emergency detector"""
        # Combine all emergency keywords
        self.all_emergency_keywords = (
            self.CARDIAC_EMERGENCY +
            self.BREATHING_EMERGENCY +
            self.BLEEDING_EMERGENCY +
            self.NEUROLOGICAL_EMERGENCY +
            self.TRAUMA_EMERGENCY +
            self.POISONING_EMERGENCY +
            self.ALLERGIC_EMERGENCY
        )
    
    def detect_emergency(self, message: str) -> Tuple[bool, Optional[str], Optional[str]]:
        """
        Detect if message contains emergency keywords
        
        Args:
            message: User message
            
        Returns:
            Tuple of (is_emergency, emergency_type, matched_keyword)
        """
        message_lower = message.lower()
        
        # Check cardiac emergencies
        for keyword in self.CARDIAC_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Cardiac emergency detected: {keyword}")
                return True, "cardiac", keyword
        
        # Check breathing emergencies
        for keyword in self.BREATHING_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Breathing emergency detected: {keyword}")
                return True, "breathing", keyword
        
        # Check bleeding emergencies
        for keyword in self.BLEEDING_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Bleeding emergency detected: {keyword}")
                return True, "bleeding", keyword
        
        # Check neurological emergencies
        for keyword in self.NEUROLOGICAL_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Neurological emergency detected: {keyword}")
                return True, "neurological", keyword
        
        # Check trauma emergencies
        for keyword in self.TRAUMA_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Trauma emergency detected: {keyword}")
                return True, "trauma", keyword
        
        # Check poisoning emergencies
        for keyword in self.POISONING_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Poisoning emergency detected: {keyword}")
                return True, "poisoning", keyword
        
        # Check allergic emergencies
        for keyword in self.ALLERGIC_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Allergic emergency detected: {keyword}")
                return True, "allergic", keyword
        
        return False, None, None
    
    def get_emergency_response(self, emergency_type: str) -> str:
        """Get appropriate emergency response"""
        responses = {
            "cardiac": (
                "🚨 **CARDIAC EMERGENCY DETECTED**\n\n"
                "**IMMEDIATE ACTION REQUIRED:**\n"
                "1. Call emergency services NOW (108 in India, 911 in US)\n"
                "2. If someone is with you, ask them to call while you rest\n"
                "3. Sit down and try to stay calm\n"
                "4. If you have aspirin and are not allergic, chew one tablet\n"
                "5. Do NOT drive yourself to the hospital\n\n"
                "⚠️ This could be life-threatening. Get medical help immediately!"
            ),
            "breathing": (
                "🚨 **BREATHING EMERGENCY DETECTED**\n\n"
                "**IMMEDIATE ACTION REQUIRED:**\n"
                "1. Call emergency services NOW (108 in India, 911 in US)\n"
                "2. Sit upright, do not lie down\n"
                "3. Loosen tight clothing\n"
                "4. Try to stay calm and breathe slowly\n"
                "5. If you have an inhaler, use it\n\n"
                "⚠️ Breathing difficulties can be life-threatening. Get help NOW!"
            ),
            "bleeding": (
                "🚨 **SEVERE BLEEDING EMERGENCY**\n\n"
                "**IMMEDIATE ACTION REQUIRED:**\n"
                "1. Call emergency services NOW (108 in India, 911 in US)\n"
                "2. Apply firm pressure directly on the wound\n"
                "3. Keep pressure constant - do not remove cloth even if soaked\n"
                "4. Lie down if possible, elevate the bleeding part if safe\n"
                "5. Do not remove any embedded objects\n\n"
                "⚠️ Severe bleeding requires immediate medical attention!"
            ),
            "neurological": (
                "🚨 **NEUROLOGICAL EMERGENCY DETECTED**\n\n"
                "**IMMEDIATE ACTION REQUIRED:**\n"
                "1. Call emergency services NOW (108 in India, 911 in US)\n"
                "2. Note the time symptoms started\n"
                "3. Lie down safely or help the person lie down\n"
                "4. Do NOT give anything to eat or drink\n"
                "5. Turn head to side if vomiting\n\n"
                "⚠️ Stroke and neurological emergencies are time-critical. Every minute counts!"
            ),
            "trauma": (
                "🚨 **TRAUMA EMERGENCY DETECTED**\n\n"
                "**IMMEDIATE ACTION REQUIRED:**\n"
                "1. Call emergency services NOW (108 in India, 911 in US)\n"
                "2. Do NOT move unless absolutely necessary\n"
                "3. Keep still, especially the neck and back\n"
                "4. Control any bleeding with direct pressure\n"
                "5. Keep warm with blankets\n\n"
                "⚠️ Serious injuries require professional emergency care!"
            ),
            "poisoning": (
                "🚨 **POISONING EMERGENCY DETECTED**\n\n"
                "**IMMEDIATE ACTION REQUIRED:**\n"
                "1. Call emergency services NOW (108 in India, 911 in US)\n"
                "2. Call Poison Control if available\n"
                "3. Do NOT induce vomiting unless instructed\n"
                "4. If substance known, have container ready for emergency responders\n"
                "5. Stay calm and follow emergency dispatcher's instructions\n\n"
                "⚠️ Poisoning requires immediate professional treatment!"
            ),
            "allergic": (
                "🚨 **SEVERE ALLERGIC REACTION DETECTED**\n\n"
                "**IMMEDIATE ACTION REQUIRED:**\n"
                "1. Call emergency services NOW (108 in India, 911 in US)\n"
                "2. If you have an EpiPen, use it immediately\n"
                "3. Lie down with legs elevated\n"
                "4. Do not stand up suddenly\n"
                "5. Remove any allergen source if possible\n\n"
                "⚠️ Anaphylaxis can be life-threatening. Get emergency help NOW!"
            )
        }
        
        return responses.get(emergency_type, responses["cardiac"])


# Example usage:
# validator = ResponseValidator()
# is_valid, error, metadata = validator.validate_response(ai_response, user_message)
#
# detector = EmergencyDetector()
# is_emergency, em_type, keyword = detector.detect_emergency(user_message)
