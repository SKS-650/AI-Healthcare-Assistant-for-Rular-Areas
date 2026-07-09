"""
Tests for Prompt Builder
"""
import pytest

from ..services.prompt_builder import PromptBuilder


class TestPromptBuilder:
    """Test cases for Prompt Builder"""
    
    @pytest.fixture
    def prompt_builder(self):
        """Create prompt builder instance"""
        return PromptBuilder()
    
    def test_build_chat_prompt_basic(self, prompt_builder):
        """Test basic chat prompt building"""
        prompt = prompt_builder.build_chat_prompt(
            user_question="What is diabetes?"
        )
        
        assert "What is diabetes?" in prompt
        assert "medical information assistant" in prompt.lower()
        assert "diagnose" in prompt.lower()  # Should mention not diagnosing
    
    def test_build_chat_prompt_with_history(self, prompt_builder):
        """Test prompt with conversation history"""
        history = [
            {"sender": "user", "message": "Hello"},
            {"sender": "assistant", "message": "Hello! How can I help?"}
        ]
        
        prompt = prompt_builder.build_chat_prompt(
            user_question="What is diabetes?",
            conversation_history=history
        )
        
        assert "Recent Conversation" in prompt
        assert "Hello" in prompt
    
    def test_build_chat_prompt_with_knowledge(self, prompt_builder):
        """Test prompt with knowledge context"""
        knowledge = {
            "disease_info": {
                "name": "Diabetes",
                "description": "High blood sugar condition",
                "symptoms": ["Increased thirst", "Frequent urination"],
                "precautions": ["Regular exercise", "Healthy diet"]
            }
        }
        
        prompt = prompt_builder.build_chat_prompt(
            user_question="Tell me about diabetes",
            knowledge_context=knowledge
        )
        
        assert "Diabetes" in prompt
        assert "Increased thirst" in prompt
        assert "Medical Knowledge Base" in prompt
    
    def test_build_chat_prompt_with_user_context(self, prompt_builder):
        """Test prompt with user context"""
        user_context = {
            "symptom_check_result": {
                "predicted_disease": "Type 2 Diabetes",
                "confidence": 0.85,
                "symptoms": ["Thirst", "Fatigue"]
            }
        }
        
        prompt = prompt_builder.build_chat_prompt(
            user_question="What should I do?",
            user_context=user_context
        )
        
        assert "User Context" in prompt
        assert "Type 2 Diabetes" in prompt
        assert "85%" in prompt
    
    def test_build_symptom_explanation_prompt(self, prompt_builder):
        """Test symptom explanation prompt"""
        prompt = prompt_builder.build_symptom_explanation_prompt("fever")
        
        assert "fever" in prompt.lower()
        assert "explain" in prompt.lower()
        assert "symptom" in prompt.lower()
    
    def test_build_disease_explanation_prompt(self, prompt_builder):
        """Test disease explanation prompt"""
        disease_info = {
            "description": "Test description",
            "symptoms": ["symptom1", "symptom2"],
            "precautions": ["precaution1", "precaution2"]
        }
        
        prompt = prompt_builder.build_disease_explanation_prompt(
            "diabetes",
            info=disease_info
        )
        
        assert "diabetes" in prompt.lower()
        assert "Test description" in prompt
        assert "symptom1" in prompt
    
    def test_build_medicine_explanation_prompt(self, prompt_builder):
        """Test medicine explanation prompt"""
        prompt = prompt_builder.build_medicine_explanation_prompt("aspirin")
        
        assert "aspirin" in prompt.lower()
        assert "NOT prescribe" in prompt
        assert "doctor" in prompt.lower()
    
    def test_build_first_aid_prompt(self, prompt_builder):
        """Test first aid prompt"""
        prompt = prompt_builder.build_first_aid_prompt("burns")
        
        assert "burns" in prompt.lower()
        assert "first aid" in prompt.lower()
        assert "emergency" in prompt.lower()
    
    def test_build_lifestyle_advice_prompt(self, prompt_builder):
        """Test lifestyle advice prompt"""
        prompt = prompt_builder.build_lifestyle_advice_prompt("exercise")
        
        assert "exercise" in prompt.lower()
        assert "lifestyle" in prompt.lower()
        assert "healthy" in prompt.lower()
    
    def test_add_emergency_context(self, prompt_builder):
        """Test adding emergency context"""
        base_prompt = "Basic prompt"
        emergency_prompt = prompt_builder.add_emergency_context(base_prompt)
        
        assert "EMERGENCY" in emergency_prompt
        assert "108" in emergency_prompt
        assert base_prompt in emergency_prompt
    
    def test_get_fallback_response_general(self, prompt_builder):
        """Test general fallback response"""
        response = prompt_builder.get_fallback_response("general")
        
        assert "apologize" in response.lower()
        assert "healthcare professional" in response.lower()
    
    def test_get_fallback_response_technical(self, prompt_builder):
        """Test technical fallback response"""
        response = prompt_builder.get_fallback_response("technical")
        
        assert "technical" in response.lower()
        assert "healthcare professional" in response.lower()
    
    def test_get_fallback_response_out_of_scope(self, prompt_builder):
        """Test out of scope fallback response"""
        response = prompt_builder.get_fallback_response("out_of_scope")
        
        assert "not able to provide" in response.lower()
        assert "healthcare professional" in response.lower()
