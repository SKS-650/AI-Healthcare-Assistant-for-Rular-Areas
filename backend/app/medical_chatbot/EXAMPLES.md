# Medical Chatbot - Usage Examples

## Complete Working Examples

### Example 1: Simple Health Question

**User:** "What is diabetes?"

**AI Response:**
```
Diabetes is a condition where your body has trouble managing blood sugar (glucose) levels. 

There are mainly two types:
- Type 1: Your body doesn't produce insulin
- Type 2: Your body doesn't use insulin effectively

Common symptoms include increased thirst, frequent urination, and fatigue.

⚠️ Important: This is general information. If you're concerned about diabetes, please consult a qualified healthcare professional for proper testing and diagnosis.
```

**API Call:**
```bash
curl -X POST http://localhost:8000/api/v1/chatbot/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What is diabetes?",
    "language": "en"
  }'
```

**Response:**
```json
{
  "assistant_message": "Diabetes is a condition where your body...",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "message_id": 1,
  "timestamp": "2026-07-06T12:00:00Z",
  "confidence": 0.87,
  "emergency_detected": false,
  "recommendations": [
    "Consult a healthcare provider for proper evaluation",
    "Regular exercise",
    "Healthy diet",
    "Monitor blood sugar"
  ],
  "follow_up_questions": [
    "Would you like to know more about diabetes?",
    "What are the risk factors for diabetes?",
    "How can this condition be prevented?"
  ],
  "response_time": 2.3,
  "tokens_used": 425
}
```

---

### Example 2: Symptom Question

**User:** "I have a fever and headache. What should I do?"

**AI Response:**
```
Fever and headache together could be caused by several things, including:
- Common viral infections (like flu or cold)
- Bacterial infections
- Dehydration
- Stress or fatigue

General self-care tips:
- Rest and stay hydrated
- Take fever-reducing medication if needed (consult pharmacist)
- Monitor your temperature
- Get plenty of sleep

When to see a doctor:
- Fever above 103°F (39.4°C)
- Symptoms lasting more than 3 days
- Severe headache or stiff neck
- Difficulty breathing
- Confusion or drowsiness

⚠️ This is general guidance only. Please consult a healthcare professional for proper evaluation and treatment.
```

---

### Example 3: Emergency Situation

**User:** "I'm having severe chest pain"

**AI Response:**
```
🚨 **CARDIAC EMERGENCY DETECTED**

**IMMEDIATE ACTION REQUIRED:**
1. Call emergency services NOW (108 in India, 911 in US)
2. If someone is with you, ask them to call while you rest
3. Sit down and try to stay calm
4. If you have aspirin and are not allergic, chew one tablet
5. Do NOT drive yourself to the hospital

⚠️ This could be life-threatening. Get medical help immediately!

---

Chest pain can be a sign of a heart attack or other serious conditions. 
While waiting for emergency services:
- Stay as calm as possible
- Loosen any tight clothing
- If you lose consciousness, someone should perform CPR if trained
```

**Response:**
```json
{
  "assistant_message": "🚨 **CARDIAC EMERGENCY DETECTED**...",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "message_id": 5,
  "timestamp": "2026-07-06T12:05:00Z",
  "confidence": 1.0,
  "emergency_detected": true,
  "recommendations": [
    "Call emergency services immediately (108 in India)",
    "Do not wait - seek immediate medical attention"
  ],
  "follow_up_questions": [],
  "response_time": 1.8,
  "tokens_used": 380
}
```

---

### Example 4: Medicine Information

**User:** "Tell me about aspirin"

**AI Response:**
```
Aspirin is a common pain reliever and fever reducer. Here's general information:

**What it's used for:**
- Relieving mild to moderate pain
- Reducing fever
- Sometimes used for heart protection (under doctor's guidance)

**General precautions:**
- Should be taken with food or after meals
- Not suitable for children under 16 (risk of Reye's syndrome)
- Can cause stomach irritation
- May increase bleeding risk

**Important:**
⚠️ This medicine should only be taken as recommended by a healthcare professional. 
- Dosage must be determined by a doctor or pharmacist
- Do not self-medicate for extended periods
- Inform your doctor about all medications you're taking
- Some people may be allergic or have conditions where aspirin is not safe

Please consult a pharmacist or doctor for specific advice about taking aspirin.
```

---

### Example 5: First Aid Question

**User:** "How do I treat a minor burn?"

**AI Response:**
```
For minor burns (first-degree burns with redness but no blistering):

**Immediate steps:**
1. **Cool the burn** - Hold under cool (not cold) running water for 10-20 minutes
2. **Remove items** - Take off jewelry, watches, or tight clothing near the burn
3. **Don't pop blisters** - If blisters form, leave them intact
4. **Cover** - Use a sterile, non-stick bandage or clean cloth
5. **Pain relief** - Over-the-counter pain relievers may help (consult pharmacist)

**What NOT to do:**
- Don't use ice (can cause more damage)
- Don't apply butter, oil, or toothpaste
- Don't break blisters
- Don't use fluffy cotton (fibers can stick)

**See a doctor if:**
- Burn is larger than 3 inches
- On face, hands, feet, genitals, or joints
- Blisters are large or numerous
- Shows signs of infection (increased pain, swelling, pus)
- Caused by chemicals or electricity

⚠️ This is basic first aid guidance. For serious burns, seek immediate medical attention.
```

---

### Example 6: Lifestyle Advice

**User:** "How can I stay healthy?"

**AI Response:**
```
Great question! Here are key tips for staying healthy:

**Nutrition:**
- Eat a balanced diet with fruits, vegetables, whole grains
- Limit processed foods and added sugars
- Stay hydrated (6-8 glasses of water daily)
- Include protein sources and healthy fats

**Exercise:**
- Aim for 30 minutes of moderate activity most days
- Include both cardio and strength training
- Even simple activities like walking help
- Start small and build gradually

**Sleep:**
- Get 7-9 hours of quality sleep
- Maintain consistent sleep schedule
- Create a relaxing bedtime routine

**Preventive Care:**
- Regular health checkups
- Keep vaccinations up to date
- Practice good hygiene
- Manage stress through relaxation techniques

**Mental Wellness:**
- Stay socially connected
- Practice mindfulness or meditation
- Seek help if feeling overwhelmed

Remember: Small, consistent changes lead to big improvements over time!
```

---

### Example 7: Continuing Conversation

**First Message:**
```json
{
  "message": "What is diabetes?",
  "language": "en"
}
```

**Response includes conversation_id:** `550e8400-e29b-41d4-a716-446655440000`

**Second Message (Continuing):**
```json
{
  "message": "What are the symptoms?",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "language": "en"
}
```

**AI Response:**
```
Based on our previous discussion about diabetes, here are the common symptoms:

**Early symptoms:**
- Increased thirst and frequent urination
- Extreme hunger
- Unexplained weight loss
- Fatigue and weakness
- Blurred vision

**Additional signs:**
- Slow-healing sores or frequent infections
- Tingling or numbness in hands/feet
- Dry skin and itching
- Fruity-smelling breath (in Type 1)

**Important notes:**
- Type 1 symptoms often develop quickly
- Type 2 symptoms may develop gradually over years
- Some people with Type 2 have no symptoms initially

If you're experiencing several of these symptoms, please consult a healthcare provider for proper testing and evaluation. Early detection and management are important.
```

---

### Example 8: With Symptom Checker Context

**Request with Context:**
```json
{
  "message": "What should I know about this condition?",
  "context": {
    "symptom_check_result": {
      "predicted_disease": "Type 2 Diabetes",
      "confidence": 0.85,
      "symptoms": ["Increased thirst", "Frequent urination", "Fatigue"]
    }
  },
  "language": "en"
}
```

**AI Response:**
```
I see from your recent symptom check that you may be experiencing symptoms related to Type 2 Diabetes with 85% confidence. Let me provide you with important information:

**About Type 2 Diabetes:**
Type 2 diabetes is a condition where your body doesn't use insulin effectively. It's the most common form of diabetes.

**Your Reported Symptoms:**
The symptoms you mentioned (increased thirst, frequent urination, fatigue) are indeed common indicators of diabetes. This happens because:
- High blood sugar draws water from tissues, causing thirst
- Excess sugar in blood leads to more urination
- Cells aren't getting enough glucose for energy, causing fatigue

**What You Should Do:**
1. **See a healthcare provider soon** - They can do proper blood tests
2. **Don't panic** - Symptom checkers are helpful but not diagnostic
3. **Monitor symptoms** - Keep track of any changes
4. **Lifestyle** - Maintain healthy diet and exercise while waiting for appointment

**Tests your doctor may order:**
- Fasting blood sugar test
- HbA1c test
- Oral glucose tolerance test

⚠️ Important: This information is educational. Only a healthcare professional can diagnose diabetes through proper testing. Please schedule an appointment with your doctor for evaluation.
```

---

### Example 9: Python SDK Usage

```python
import requests
from typing import Dict, Any

class MedicalChatbot:
    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        self.conversation_id = None
    
    def chat(self, message: str, **kwargs) -> Dict[str, Any]:
        """Send a message to the chatbot"""
        payload = {
            "message": message,
            "language": kwargs.get("language", "en")
        }
        
        # Continue conversation if exists
        if self.conversation_id:
            payload["conversation_id"] = self.conversation_id
        
        # Add context if provided
        if "context" in kwargs:
            payload["context"] = kwargs["context"]
        
        response = requests.post(
            f"{self.base_url}/api/v1/chatbot/chat",
            headers=self.headers,
            json=payload
        )
        
        result = response.json()
        
        # Save conversation ID for next message
        if not self.conversation_id:
            self.conversation_id = result["conversation_id"]
        
        return result
    
    def get_conversations(self, page: int = 1, page_size: int = 20):
        """Get list of conversations"""
        response = requests.get(
            f"{self.base_url}/api/v1/chatbot/conversations",
            headers=self.headers,
            params={"page": page, "page_size": page_size}
        )
        return response.json()
    
    def submit_feedback(self, rating: int, feedback_text: str = None):
        """Submit feedback for current conversation"""
        if not self.conversation_id:
            raise ValueError("No active conversation")
        
        payload = {
            "conversation_id": self.conversation_id,
            "rating": rating,
            "feedback_text": feedback_text
        }
        
        response = requests.post(
            f"{self.base_url}/api/v1/chatbot/feedback",
            headers=self.headers,
            json=payload
        )
        return response.json()


# Usage Example
chatbot = MedicalChatbot(
    base_url="http://localhost:8000",
    api_key="your_jwt_token_here"
)

# Start conversation
result1 = chatbot.chat("What is diabetes?")
print(f"AI: {result1['assistant_message']}")

# Continue conversation
result2 = chatbot.chat("What are the symptoms?")
print(f"AI: {result2['assistant_message']}")

# Submit feedback
feedback = chatbot.submit_feedback(rating=5, feedback_text="Very helpful!")
print(f"Feedback submitted: {feedback['message']}")

# Get all conversations
conversations = chatbot.get_conversations()
print(f"Total conversations: {conversations['total']}")
```

---

### Example 10: Error Handling

**Request with Invalid Message:**
```json
{
  "message": "",
  "language": "en"
}
```

**Error Response:**
```json
{
  "error": "Invalid request",
  "detail": "Message cannot be empty",
  "code": "INVALID_MESSAGE",
  "timestamp": "2026-07-06T12:00:00Z"
}
```

**LLM Service Timeout:**
```json
{
  "assistant_message": "I apologize, but I'm having trouble providing a response right now. For your health concerns, please consult a qualified healthcare professional...",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "confidence": 0.5,
  "emergency_detected": false,
  "response_time": 30.0
}
```

---

## Testing Examples

### Unit Test Example

```python
import pytest
from app.medical_chatbot.services import EmergencyDetector

def test_emergency_detection():
    detector = EmergencyDetector()
    
    # Test cardiac emergency
    is_emergency, em_type, keyword = detector.detect_emergency(
        "I'm having severe chest pain"
    )
    
    assert is_emergency is True
    assert em_type == "cardiac"
    assert keyword == "chest pain"
    
    # Test non-emergency
    is_emergency, em_type, keyword = detector.detect_emergency(
        "What is diabetes?"
    )
    
    assert is_emergency is False
    assert em_type is None
```

### Integration Test Example

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def auth_headers():
    # Get JWT token
    return {"Authorization": "Bearer test_token"}

def test_chat_endpoint(client, auth_headers):
    response = client.post(
        "/api/v1/chatbot/chat",
        json={
            "message": "What is diabetes?",
            "language": "en"
        },
        headers=auth_headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "assistant_message" in data
    assert "conversation_id" in data
    assert data["emergency_detected"] is False
```

---

## Common Use Cases

### Use Case 1: Health Information Lookup
User wants to understand a medical condition
- Quick, educational response
- Links to precautions
- Recommendation to see doctor

### Use Case 2: Symptom Guidance
User reports symptoms
- Explain possible causes (non-diagnostic)
- Suggest when to see doctor
- Provide self-care tips

### Use Case 3: Emergency Response
User describes emergency symptoms
- Immediate emergency instructions
- Call emergency services
- Basic first aid steps

### Use Case 4: Medication Information
User asks about medicine
- General information only
- Safety precautions
- Strong emphasis on consulting healthcare provider

### Use Case 5: Lifestyle Advice
User wants health tips
- Practical, actionable advice
- Evidence-based recommendations
- Encouragement and motivation

---

## Best Practices

### For Users
1. **Be specific** in your questions
2. **Provide context** when helpful
3. **Follow up** with clarifying questions
4. **Always consult** healthcare professionals for serious concerns
5. **Call emergency** services for emergencies

### For Developers
1. **Always validate** user input
2. **Handle errors** gracefully
3. **Log appropriately** (not sensitive data)
4. **Test emergency** detection thoroughly
5. **Monitor API** usage and costs
6. **Cache common** responses when possible
7. **Update datasets** regularly

---

## Troubleshooting Examples

### Issue: "LLM API key not configured"
```python
# Solution: Add to .env file
CHATBOT_LLM_API_KEY=your_actual_api_key_here
```

### Issue: "Response validation failed"
```python
# The system automatically sanitizes unsafe responses
# Check logs for what was detected:
logger.warning(f"Dangerous phrase detected: {phrase}")
# Sanitized response is returned automatically
```

### Issue: "Knowledge base not loaded"
```python
# Check dataset location
from app.medical_chatbot.services import get_knowledge_service
knowledge = get_knowledge_service()
print(knowledge.is_loaded())  # Should be True
print(knowledge.get_stats())   # Shows dataset counts
```

---

## Summary

These examples demonstrate:
- ✅ Simple health questions
- ✅ Symptom queries
- ✅ Emergency detection
- ✅ Medicine information
- ✅ First aid guidance
- ✅ Lifestyle advice
- ✅ Conversation continuation
- ✅ Context integration
- ✅ Error handling
- ✅ Python SDK usage

All responses include:
- Educational information
- Medical disclaimers
- Professional consultation recommendations
- Safety guardrails
- Emergency escalation when needed

**The chatbot provides information, NOT medical advice!** ⚠️
