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
    
    # Emergency keywords by category — comprehensive spec-compliant list
    CARDIAC_EMERGENCY = [
        "chest pain", "heart attack", "heart attack", "crushing chest",
        "pressure in chest", "pain radiating", "heart racing", "palpitations",
        "cardiac arrest", "my heart", "दिल में दर्द", "सीने में दर्द",
    ]
    
    BREATHING_EMERGENCY = [
        "can't breathe", "cannot breathe", "difficulty breathing",
        "shortness of breath", "gasping", "choking", "not breathing",
        "stopped breathing", "सांस नहीं", "saans nahi",
    ]
    
    BLEEDING_EMERGENCY = [
        "severe bleeding", "heavy bleeding", "bleeding won't stop",
        "blood gushing", "arterial bleeding", "hemorrhage",
        "खून बह रहा", "रक्तस्राव",
    ]
    
    NEUROLOGICAL_EMERGENCY = [
        "stroke", "sudden numbness", "slurred speech", "face drooping",
        "severe headache", "loss of consciousness", "unconscious",
        "unconsciousness", "seizure", "convulsion", "fit",
        "fainted", "not responding", "paralysis", "brain stroke",
        "बेहोश", "दौरा",
    ]
    
    TRAUMA_EMERGENCY = [
        "severe injury", "broken bone", "compound fracture",
        "head injury", "fell from height", "car accident",
        "road accident", "electric shock", "electrocution",
        "burned badly", "severe burn", "burns all over",
        "बिजली का झटका", "जल गया",
    ]
    
    POISONING_EMERGENCY = [
        "poisoning", "overdose", "swallowed poison",
        "chemical burn", "toxic", "poison", "rat poison",
        "pesticide", "snake bite", "snakebite", "dog bite", "animal bite",
        "insect sting", "scorpion sting", "साँप ने काटा", "सर्पदंश",
    ]
    
    ALLERGIC_EMERGENCY = [
        "allergic reaction", "anaphylaxis", "swelling throat",
        "severe swelling", "hives all over", "throat closing",
        "severe allergic", "can't swallow", "face swelling",
        "एलर्जी", "गला बंद",
    ]
    
    MENTAL_HEALTH_EMERGENCY = [
        "suicide", "kill myself", "want to die", "end my life",
        "self harm", "self-harm", "cutting myself", "hurting myself",
        "jump off", "hang myself", "खुदकुशी", "आत्महत्या",
    ]
    
    INFANT_EMERGENCY = [
        "high fever infant", "baby not breathing", "newborn fever",
        "infant convulsion", "baby seizure", "baby unconscious",
        "baby choking", "infant emergency", "बच्चे को तेज बुखार",
        "शिशु को बुखार", "baby high fever", "very high fever baby",
        "104 fever child", "105 fever child",
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
            self.ALLERGIC_EMERGENCY +
            self.MENTAL_HEALTH_EMERGENCY +
            self.INFANT_EMERGENCY
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
        
        # Check mental health / suicide emergencies FIRST (highest priority)
        for keyword in self.MENTAL_HEALTH_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Mental health emergency detected: {keyword}")
                return True, "mental_health", keyword
        
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
        
        # Check trauma emergencies (includes electric shock, burns)
        for keyword in self.TRAUMA_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Trauma emergency detected: {keyword}")
                return True, "trauma", keyword
        
        # Check poisoning/snake bite emergencies
        for keyword in self.POISONING_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Poisoning/snake bite emergency detected: {keyword}")
                return True, "poisoning", keyword
        
        # Check allergic emergencies
        for keyword in self.ALLERGIC_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Allergic emergency detected: {keyword}")
                return True, "allergic", keyword
        
        # Check infant/child emergencies
        for keyword in self.INFANT_EMERGENCY:
            if keyword in message_lower:
                logger.warning(f"Infant emergency detected: {keyword}")
                return True, "infant", keyword
        
        return False, None, None
    
    def get_emergency_response(self, emergency_type: str) -> str:
        """Get appropriate emergency response"""
        responses = {
            "cardiac": (
                "🚨 **CARDIAC EMERGENCY DETECTED**\n\n"
                "**CALL EMERGENCY SERVICES NOW:**\n"
                "🚑 **108** (India) | **102** (Nepal) | **112** (Global)\n\n"
                "**While waiting for help:**\n"
                "1. Sit down and stay as calm as possible\n"
                "2. Loosen tight clothing (belt, collar, tie)\n"
                "3. If not allergic to aspirin and it's available, chew 1 tablet\n"
                "4. Do NOT drive yourself — wait for emergency services\n"
                "5. Unlock your front door so paramedics can enter\n\n"
                "⚠️ **This could be life-threatening. Get medical help immediately!**"
            ),
            "breathing": (
                "🚨 **BREATHING EMERGENCY DETECTED**\n\n"
                "**CALL EMERGENCY SERVICES NOW:**\n"
                "🚑 **108** (India) | **102** (Nepal) | **112** (Global)\n\n"
                "**While waiting for help:**\n"
                "1. Sit upright — do NOT lie flat\n"
                "2. Loosen any tight clothing around neck and chest\n"
                "3. Try to breathe slowly and calmly\n"
                "4. Use your inhaler if you have one\n"
                "5. Open a window for fresh air\n\n"
                "⚠️ **Breathing difficulty is life-threatening. Get help NOW!**"
            ),
            "bleeding": (
                "🚨 **SEVERE BLEEDING EMERGENCY**\n\n"
                "**CALL EMERGENCY SERVICES NOW:**\n"
                "🚑 **108** (India) | **102** (Nepal) | **112** (Global)\n\n"
                "**While waiting for help:**\n"
                "1. Apply FIRM, constant pressure directly on the wound\n"
                "2. Use a clean cloth — do NOT remove it even if soaked; add more on top\n"
                "3. Elevate the bleeding part above heart level if possible\n"
                "4. Do NOT remove any embedded objects\n"
                "5. Keep the person lying down and warm\n\n"
                "⚠️ **Severe bleeding requires immediate medical attention!**"
            ),
            "neurological": (
                "🚨 **NEUROLOGICAL EMERGENCY DETECTED**\n\n"
                "**CALL EMERGENCY SERVICES NOW:**\n"
                "🚑 **108** (India) | **102** (Nepal) | **112** (Global)\n\n"
                "**While waiting for help:**\n"
                "1. Note the exact time symptoms started — tell the doctors\n"
                "2. Lay the person down safely; support their head\n"
                "3. Do NOT give food, water, or medication by mouth\n"
                "4. Turn their head to the side if vomiting occurs\n"
                "5. Do NOT restrain them during a seizure — move objects away\n\n"
                "⚠️ **Stroke/seizure is time-critical — every minute matters!**"
            ),
            "trauma": (
                "🚨 **TRAUMA / BURN / ELECTRIC SHOCK EMERGENCY**\n\n"
                "**CALL EMERGENCY SERVICES NOW:**\n"
                "🚑 **108** (India) | **102** (Nepal) | **112** (Global)\n\n"
                "**While waiting for help:**\n"
                "1. Do NOT move the person unless they are in immediate danger\n"
                "2. For burns: cool with running water for 10–20 minutes; do NOT use ice\n"
                "3. For electric shock: do NOT touch the person until power is OFF\n"
                "4. Keep them warm and still\n"
                "5. Control any visible bleeding with gentle pressure\n\n"
                "⚠️ **Serious trauma requires professional emergency care immediately!**"
            ),
            "poisoning": (
                "🚨 **POISONING / SNAKE BITE EMERGENCY**\n\n"
                "**CALL EMERGENCY SERVICES NOW:**\n"
                "🚑 **108** (India) | **102** (Nepal) | **112** (Global)\n\n"
                "**While waiting for help:**\n"
                "1. Do NOT induce vomiting unless emergency services instruct you\n"
                "2. For snake bite: keep the limb still and below heart level\n"
                "3. Remove watches, rings, or tight items near the bite\n"
                "4. Keep container/substance info ready for doctors\n"
                "5. Note the time of exposure/bite for medical staff\n\n"
                "⚠️ **Poisoning/snake bite requires immediate professional treatment!**"
            ),
            "allergic": (
                "🚨 **SEVERE ALLERGIC REACTION (ANAPHYLAXIS)**\n\n"
                "**CALL EMERGENCY SERVICES NOW:**\n"
                "🚑 **108** (India) | **102** (Nepal) | **112** (Global)\n\n"
                "**While waiting for help:**\n"
                "1. Use EpiPen / adrenaline injector immediately if available\n"
                "2. Lay the person flat with legs elevated (unless breathing is difficult)\n"
                "3. If unconscious and not breathing, start CPR\n"
                "4. Remove the allergen source if safely possible\n"
                "5. Do NOT give antihistamines alone — this is not enough for anaphylaxis\n\n"
                "⚠️ **Anaphylaxis can be fatal within minutes. Get emergency help NOW!**"
            ),
            "mental_health": (
                "🚨 **MENTAL HEALTH CRISIS DETECTED — YOU ARE NOT ALONE**\n\n"
                "**Please reach out right now:**\n"
                "📞 **iCall (India):** 9152987821\n"
                "📞 **Vandrevala Foundation:** 1860-2662-345 (24/7)\n"
                "📞 **Emergency:** 108 (India) | 112 (Global)\n\n"
                "**Please know:**\n"
                "1. You matter and your life has value 💙\n"
                "2. This feeling will pass — please reach out to someone you trust\n"
                "3. Call a crisis helpline — trained counsellors are available 24/7\n"
                "4. Go to the nearest hospital emergency room if you feel unsafe\n"
                "5. Tell someone near you how you are feeling right now\n\n"
                "⚠️ **Please seek help immediately. You do not have to face this alone.**"
            ),
            "infant": (
                "🚨 **INFANT / CHILD EMERGENCY DETECTED**\n\n"
                "**CALL EMERGENCY SERVICES NOW:**\n"
                "🚑 **108** (India) | **102** (Nepal) | **112** (Global)\n\n"
                "**While waiting for help:**\n"
                "1. For high fever (above 38.5°C/101.3°F): remove extra clothing, apply cool (not cold) damp cloth on forehead\n"
                "2. Do NOT give aspirin to children — only paracetamol as directed by a doctor\n"
                "3. Keep the baby/child lying on their side if vomiting\n"
                "4. Keep them calm and do not leave them alone\n"
                "5. Note the temperature reading to tell the doctor\n\n"
                "⚠️ **Infant emergencies can escalate rapidly. Seek medical care immediately!**"
            ),
        }
        return responses.get(emergency_type, responses["cardiac"])


# Example usage:
# validator = ResponseValidator()
# is_valid, error, metadata = validator.validate_response(ai_response, user_message)
#
# detector = EmergencyDetector()
# is_emergency, em_type, keyword = detector.detect_emergency(user_message)
