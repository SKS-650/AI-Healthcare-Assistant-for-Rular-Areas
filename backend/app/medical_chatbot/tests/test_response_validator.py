"""
Tests for Response Validator and Emergency Detector
"""
import pytest

from ..services.response_validator import ResponseValidator, EmergencyDetector


class TestResponseValidator:
    """Test cases for Response Validator"""
    
    @pytest.fixture
    def validator(self):
        """Create validator instance"""
        return ResponseValidator()
    
    def test_validate_response_success(self, validator):
        """Test successful response validation"""
        response = "This is a good response that provides health information. Please consult a doctor."
        user_message = "What is diabetes?"
        
        is_valid, error, metadata = validator.validate_response(response, user_message)
        
        assert is_valid is True
        assert error is None
        assert metadata["length"] > 0
    
    def test_validate_response_empty(self, validator):
        """Test empty response validation"""
        is_valid, error, metadata = validator.validate_response("", "test")
        
        assert is_valid is False
        assert "empty" in error.lower()
    
    def test_validate_response_too_short(self, validator):
        """Test too short response"""
        is_valid, error, metadata = validator.validate_response("OK", "test")
        
        assert is_valid is False
        assert "short" in error.lower()
    
    def test_validate_response_dangerous_phrase(self, validator):
        """Test dangerous phrase detection"""
        dangerous_responses = [
            "You have diabetes based on your symptoms.",
            "You are diagnosed with hypertension.",
            "Take this medicine for your condition."
        ]
        
        for response in dangerous_responses:
            is_valid, error, metadata = validator.validate_response(response, "test")
            assert is_valid is False
            assert "dangerous" in error.lower()
    
    def test_validate_response_offensive_language(self, validator):
        """Test offensive language detection"""
        response = "That's a stupid question about health."
        
        is_valid, error, metadata = validator.validate_response(response, "test")
        
        assert is_valid is False
        assert "offensive" in error.lower()
    
    def test_validate_response_missing_disclaimer(self, validator):
        """Test missing disclaimer warning"""
        response = "Here is some health information without any disclaimer or doctor recommendation."
        
        is_valid, error, metadata = validator.validate_response(response, "test")
        
        # Should still be valid but with warning
        assert "disclaimer" in str(metadata.get("warnings", []))
    
    def test_sanitize_response(self, validator):
        """Test response sanitization"""
        dangerous = "You have diabetes. Take this medicine."
        sanitized = validator.sanitize_response(dangerous)
        
        assert "you have" not in sanitized.lower()
        assert "may have" in sanitized.lower() or "could be" in sanitized.lower()
    
    def test_get_fallback_response(self, validator):
        """Test fallback responses"""
        fallbacks = [
            "validation_failed",
            "empty_response",
            "dangerous_content",
            "too_complex"
        ]
        
        for reason in fallbacks:
            response = validator.get_fallback_response(reason)
            assert len(response) > 0
            assert "healthcare professional" in response.lower()


class TestEmergencyDetector:
    """Test cases for Emergency Detector"""
    
    @pytest.fixture
    def detector(self):
        """Create detector instance"""
        return EmergencyDetector()
    
    def test_detect_cardiac_emergency(self, detector):
        """Test cardiac emergency detection"""
        messages = [
            "I'm having chest pain",
            "Severe chest pain radiating to arm",
            "Heart attack symptoms"
        ]
        
        for message in messages:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            assert is_emergency is True
            assert em_type == "cardiac"
            assert keyword is not None
    
    def test_detect_breathing_emergency(self, detector):
        """Test breathing emergency detection"""
        messages = [
            "I can't breathe",
            "Difficulty breathing",
            "Gasping for air"
        ]
        
        for message in messages:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            assert is_emergency is True
            assert em_type == "breathing"
    
    def test_detect_bleeding_emergency(self, detector):
        """Test bleeding emergency detection"""
        messages = [
            "Severe bleeding won't stop",
            "Heavy bleeding from wound",
            "Blood gushing out"
        ]
        
        for message in messages:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            assert is_emergency is True
            assert em_type == "bleeding"
    
    def test_detect_neurological_emergency(self, detector):
        """Test neurological emergency detection"""
        messages = [
            "I think I'm having a stroke",
            "Sudden numbness on one side",
            "Severe seizure",
            "Loss of consciousness"
        ]
        
        for message in messages:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            assert is_emergency is True
            assert em_type == "neurological"
    
    def test_detect_trauma_emergency(self, detector):
        """Test trauma emergency detection"""
        messages = [
            "Severe injury from accident",
            "Broken bone sticking out",
            "Head injury from fall"
        ]
        
        for message in messages:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            assert is_emergency is True
            assert em_type == "trauma"
    
    def test_detect_poisoning_emergency(self, detector):
        """Test poisoning emergency detection"""
        messages = [
            "Swallowed poison by accident",
            "Drug overdose",
            "Chemical burn"
        ]
        
        for message in messages:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            assert is_emergency is True
            assert em_type == "poisoning"
    
    def test_detect_allergic_emergency(self, detector):
        """Test allergic emergency detection"""
        messages = [
            "Severe allergic reaction",
            "Throat swelling from allergy",
            "Anaphylaxis symptoms"
        ]
        
        for message in messages:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            assert is_emergency is True
            assert em_type == "allergic"
    
    def test_no_emergency(self, detector):
        """Test non-emergency messages"""
        messages = [
            "What is diabetes?",
            "How to stay healthy?",
            "Tell me about nutrition"
        ]
        
        for message in messages:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            assert is_emergency is False
            assert em_type is None
            assert keyword is None
    
    def test_get_emergency_response_cardiac(self, detector):
        """Test cardiac emergency response"""
        response = detector.get_emergency_response("cardiac")
        
        assert "108" in response
        assert "emergency" in response.lower()
        assert "hospital" in response.lower()
    
    def test_get_emergency_response_breathing(self, detector):
        """Test breathing emergency response"""
        response = detector.get_emergency_response("breathing")
        
        assert "108" in response
        assert "breathe" in response.lower()
        assert "sit upright" in response.lower()
    
    def test_get_emergency_response_all_types(self, detector):
        """Test all emergency response types"""
        emergency_types = [
            "cardiac", "breathing", "bleeding", "neurological",
            "trauma", "poisoning", "allergic"
        ]
        
        for em_type in emergency_types:
            response = detector.get_emergency_response(em_type)
            assert len(response) > 0
            assert "108" in response
            assert "emergency" in response.lower()
