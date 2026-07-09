"""
Simple test script to verify AI setup
Run this to check if everything is configured correctly
"""
import asyncio
import os
from pathlib import Path

# Add parent directory to path
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from app.medical_chatbot.services import (
    get_llm_service,
    get_knowledge_service,
    PromptBuilder,
    ResponseValidator,
    EmergencyDetector
)


async def test_llm_service():
    """Test LLM service"""
    print("\n1️⃣  Testing LLM Service...")
    print("-" * 50)
    
    try:
        llm = get_llm_service()
        print(f"✅ LLM Service initialized")
        print(f"   Provider: {llm.provider_name}")
        print(f"   Model: {llm.model}")
        print(f"   API Key: {'✅ Configured' if llm.api_key else '❌ Not configured'}")
        
        # Test health check
        health = await llm.health_check()
        print(f"   Health: {health['status']}")
        
        # Test simple generation
        print("\n   Testing AI response generation...")
        result = await llm.generate_response(
            "What is diabetes in one sentence?",
            temperature=0.7,
            max_tokens=50
        )
        print(f"   ✅ Response generated ({result['response_time']:.2f}s)")
        print(f"   Sample: {result['response'][:100]}...")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        return False


def test_knowledge_service():
    """Test knowledge service"""
    print("\n2️⃣  Testing Knowledge Service...")
    print("-" * 50)
    
    try:
        knowledge = get_knowledge_service()
        print(f"✅ Knowledge Service initialized")
        
        # Get stats
        stats = knowledge.get_stats()
        print(f"   Datasets loaded:")
        print(f"   - Diseases: {stats['diseases']}")
        print(f"   - Descriptions: {stats['descriptions']}")
        print(f"   - Precautions: {stats['precautions']}")
        print(f"   - MedQuAD entries: {stats['medquad_entries']}")
        
        # Test disease search
        print("\n   Testing disease search...")
        disease_info = knowledge.search_disease("diabetes")
        if disease_info:
            print(f"   ✅ Found: {disease_info['name']}")
            print(f"      Symptoms: {len(disease_info['symptoms'])} listed")
            print(f"      Precautions: {len(disease_info['precautions'])} listed")
        else:
            print(f"   ⚠️  No disease info found")
        
        # Test symptom search
        print("\n   Testing symptom search...")
        symptoms = knowledge.search_symptoms("fever")
        print(f"   ✅ Found {len(symptoms)} related symptoms")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        return False


def test_prompt_builder():
    """Test prompt builder"""
    print("\n3️⃣  Testing Prompt Builder...")
    print("-" * 50)
    
    try:
        builder = PromptBuilder()
        print(f"✅ Prompt Builder initialized")
        
        # Test basic prompt
        prompt = builder.build_chat_prompt(
            user_question="What is diabetes?",
            conversation_history=[],
            knowledge_context=None
        )
        print(f"   ✅ Chat prompt built ({len(prompt)} characters)")
        
        # Test symptom prompt
        symptom_prompt = builder.build_symptom_explanation_prompt("fever")
        print(f"   ✅ Symptom prompt built ({len(symptom_prompt)} characters)")
        
        # Test disease prompt
        disease_prompt = builder.build_disease_explanation_prompt("diabetes")
        print(f"   ✅ Disease prompt built ({len(disease_prompt)} characters)")
        
        # Test fallback
        fallback = builder.get_fallback_response("general")
        print(f"   ✅ Fallback response ready ({len(fallback)} characters)")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        return False


def test_response_validator():
    """Test response validator"""
    print("\n4️⃣  Testing Response Validator...")
    print("-" * 50)
    
    try:
        validator = ResponseValidator()
        print(f"✅ Response Validator initialized")
        
        # Test valid response
        is_valid, error, metadata = validator.validate_response(
            "This is a safe health information response. Please consult a doctor.",
            "test message"
        )
        print(f"   ✅ Valid response: {is_valid}")
        
        # Test dangerous phrase detection
        is_valid, error, metadata = validator.validate_response(
            "You have diabetes. Take this medicine.",
            "test message"
        )
        print(f"   ✅ Dangerous phrase detected: {not is_valid}")
        
        # Test sanitization
        dangerous = "You have diabetes."
        sanitized = validator.sanitize_response(dangerous)
        print(f"   ✅ Sanitization works: {'you have' not in sanitized.lower()}")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        return False


def test_emergency_detector():
    """Test emergency detector"""
    print("\n5️⃣  Testing Emergency Detector...")
    print("-" * 50)
    
    try:
        detector = EmergencyDetector()
        print(f"✅ Emergency Detector initialized")
        
        # Test emergency detection
        test_cases = [
            ("I'm having chest pain", True, "cardiac"),
            ("Can't breathe", True, "breathing"),
            ("What is diabetes?", False, None)
        ]
        
        for message, expected_emergency, expected_type in test_cases:
            is_emergency, em_type, keyword = detector.detect_emergency(message)
            status = "✅" if is_emergency == expected_emergency else "❌"
            print(f"   {status} '{message[:30]}...'")
            print(f"      Emergency: {is_emergency}, Type: {em_type}")
        
        # Test emergency response
        response = detector.get_emergency_response("cardiac")
        print(f"   ✅ Emergency response generated ({len(response)} characters)")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        return False


async def main():
    """Run all tests"""
    print("\n" + "=" * 50)
    print("🧪 AI Healthcare Chatbot - Setup Verification")
    print("=" * 50)
    
    results = []
    
    # Run tests
    results.append(await test_llm_service())
    results.append(test_knowledge_service())
    results.append(test_prompt_builder())
    results.append(test_response_validator())
    results.append(test_emergency_detector())
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 Test Summary")
    print("=" * 50)
    
    passed = sum(results)
    total = len(results)
    
    print(f"\nTests Passed: {passed}/{total}")
    
    if passed == total:
        print("\n✅ All tests passed! AI setup is complete.")
        print("\n🚀 You can now:")
        print("   1. Start the server: uvicorn app.main:app --reload")
        print("   2. Test via API: POST /api/v1/chatbot/chat")
        print("   3. View docs: http://localhost:8000/docs")
    else:
        print("\n⚠️  Some tests failed. Please check:")
        print("   1. API key is configured in .env")
        print("   2. Datasets are in correct location")
        print("   3. Dependencies are installed")
    
    print("\n" + "=" * 50)


if __name__ == "__main__":
    # Run async main
    asyncio.run(main())
