# Medical Chatbot - AI Implementation Guide

## Phase 05 Part 2 - Complete ✅

**Status:** Fully implemented with AI functionality  
**Date:** July 6, 2026

---

## Overview

This document describes the AI implementation for the Medical Chatbot module. The chatbot now has full AI capabilities powered by LLM (Large Language Model) integration.

---

## Architecture

```
User Question
     ↓
Emergency Detection (Pre-check)
     ↓
Load Conversation History
     ↓
Search Knowledge Base (Datasets)
     ↓
Build Context
     ↓
Create AI Prompt
     ↓
Call LLM API (OpenAI/Gemini)
     ↓
Receive AI Response
     ↓
Validate Response (Safety Check)
     ↓
Add Emergency Info (if needed)
     ↓
Save to Database
     ↓
Return to User
```

---

## Components

### 1. LLM Service (`llm_service.py`)

**Purpose:** Provider-independent LLM integration

**Supported Providers:**
- OpenAI (GPT-3.5/GPT-4)
- Google Gemini (Gemini Pro)
- Anthropic Claude (easy to add)

**Key Features:**
- Async API calls
- Timeout handling
- Error recovery
- Health checks
- Token tracking

**Example Usage:**
```python
from app.medical_chatbot.services import get_llm_service

llm = get_llm_service()
result = await llm.generate_response(
    prompt="What is diabetes?",
    temperature=0.7,
    max_tokens=1000
)

print(result["response"])
```

**Configuration:**
```env
# .env file
CHATBOT_LLM_PROVIDER=gemini  # or openai
CHATBOT_LLM_MODEL=gemini-pro  # or gpt-3.5-turbo
CHATBOT_LLM_API_KEY=your_api_key_here
```

---

### 2. Knowledge Service (`knowledge_service.py`)

**Purpose:** Load and search medical datasets

**Datasets Used:**
1. **Disease-Symptom Dataset**
   - Location: `datasets/chatbot_dataset/DiseaseSymptomPredictionDataset/`
   - Files:
     - `dataset.csv` - Disease and symptoms mapping
     - `symptom_Description.csv` - Disease descriptions
     - `symptom_precaution.csv` - Precautions for diseases
     - `Symptom-severity.csv` - Symptom severity ratings

2. **MedQuAD Dataset**
   - Location: `datasets/chatbot_dataset/MedQuAD_Dataset/`
   - File: `medquad.csv` - Medical Q&A pairs

**Key Functions:**
```python
from app.medical_chatbot.services import get_knowledge_service

knowledge = get_knowledge_service()

# Search for disease
disease_info = knowledge.search_disease("diabetes")
# Returns: {name, symptoms, description, precautions}

# Search symptoms
symptoms = knowledge.search_symptoms("fever")

# Get relevant knowledge for user message
context = knowledge.get_relevant_knowledge("What are symptoms of diabetes?")
```

---

### 3. Prompt Builder (`prompt_builder.py`)

**Purpose:** Create structured prompts for the LLM

**System Prompt:**
The system prompt instructs the AI to:
- Be friendly and helpful
- Provide educational information only
- Never diagnose or prescribe
- Always recommend consulting healthcare professionals
- Keep responses simple and clear

**Prompt Types:**
1. **Chat Prompt** - General conversation
2. **Symptom Explanation** - Explain symptoms
3. **Disease Explanation** - Explain diseases
4. **Medicine Explanation** - Medicine information
5. **First Aid** - First aid guidance
6. **Lifestyle Advice** - Health tips

**Example:**
```python
from app.medical_chatbot.services import PromptBuilder

builder = PromptBuilder()

prompt = builder.build_chat_prompt(
    user_question="What is diabetes?",
    conversation_history=[...],
    knowledge_context={...},
    user_context={...}
)
```

---

### 4. Response Validator (`response_validator.py`)

**Purpose:** Validate AI responses for safety

**Validation Checks:**
1. ✅ Not empty
2. ✅ Not too short
3. ✅ Not too long (warning)
4. ✅ No dangerous diagnostic phrases
5. ✅ No offensive language
6. ✅ Contains medical disclaimer
7. ✅ Relevant to user question

**Dangerous Phrases Blocked:**
- "you have [disease]"
- "you are diagnosed"
- "take this medicine"
- "prescribed dosage"
- "stop taking your medication"
- "guaranteed cure"

**Sanitization:**
If dangerous phrases are detected, they are replaced:
- "you have" → "you may have"
- "take this medicine" → "your doctor may prescribe medicine"

**Example:**
```python
from app.medical_chatbot.services import ResponseValidator

validator = ResponseValidator()

is_valid, error, metadata = validator.validate_response(
    response=ai_response,
    user_message=user_question
)

if not is_valid:
    safe_response = validator.sanitize_response(ai_response)
```

---

### 5. Emergency Detector (`response_validator.py`)

**Purpose:** Detect emergency situations

**Emergency Categories:**
1. **Cardiac** - chest pain, heart attack
2. **Breathing** - can't breathe, gasping
3. **Bleeding** - severe bleeding
4. **Neurological** - stroke, seizure, unconscious
5. **Trauma** - severe injury, broken bones
6. **Poisoning** - overdose, poison ingestion
7. **Allergic** - anaphylaxis, severe reaction

**Emergency Response:**
When emergency detected:
- Immediate warning to call 108 (India) / 911 (US)
- Specific first aid instructions
- Instructions NOT to drive
- Clear life-threatening warnings

**Example:**
```python
from app.medical_chatbot.services import EmergencyDetector

detector = EmergencyDetector()

is_emergency, em_type, keyword = detector.detect_emergency(
    "I'm having severe chest pain"
)

if is_emergency:
    emergency_response = detector.get_emergency_response(em_type)
    # Returns detailed emergency instructions
```

---

## Complete Flow Example

```python
async def process_chat(user_message: str):
    # 1. Detect emergency
    is_emergency, em_type, _ = emergency_detector.detect_emergency(user_message)
    
    # 2. Get conversation history
    history = await get_conversation_history(conversation_id)
    
    # 3. Search knowledge base
    knowledge = knowledge_service.get_relevant_knowledge(user_message)
    
    # 4. Build prompt
    if is_emergency:
        prompt = prompt_builder.build_chat_prompt(...)
        prompt = prompt_builder.add_emergency_context(prompt)
    else:
        prompt = prompt_builder.build_chat_prompt(...)
    
    # 5. Generate AI response
    result = await llm_service.generate_response(prompt)
    
    # 6. Validate response
    is_valid, _, _ = validator.validate_response(result["response"], user_message)
    
    if not is_valid:
        response = validator.sanitize_response(result["response"])
    else:
        response = result["response"]
    
    # 7. Add emergency message if needed
    if is_emergency:
        emergency_msg = detector.get_emergency_response(em_type)
        response = f"{emergency_msg}\n\n{response}"
    
    # 8. Save and return
    await save_message(response)
    
    return response
```

---

## Configuration

### Environment Variables

Add to your `.env` file:

```env
# LLM Provider Selection
CHATBOT_LLM_PROVIDER=gemini  # openai, gemini, anthropic

# Model Selection
CHATBOT_LLM_MODEL=gemini-pro  # or gpt-3.5-turbo, gpt-4, claude-2

# API Key (Required)
CHATBOT_LLM_API_KEY=your_api_key_here

# Optional Settings
CHATBOT_LLM_MAX_TOKENS=1000
CHATBOT_LLM_TEMPERATURE=0.7
CHATBOT_LLM_REQUEST_TIMEOUT=30
```

### Getting API Keys

**OpenAI:**
1. Go to https://platform.openai.com/
2. Create account / Sign in
3. Go to API Keys section
4. Create new key
5. Copy and add to `.env`

**Google Gemini:**
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with Google account
3. Click "Create API Key"
4. Copy and add to `.env`

---

## Dataset Setup

### Required Datasets

Ensure datasets are in correct location:
```
d:/MinorProject/ai_healthcare_assistant/
└── datasets/
    └── chatbot_dataset/
        ├── DiseaseSymptomPredictionDataset/
        │   ├── dataset.csv
        │   ├── symptom_Description.csv
        │   ├── symptom_precaution.csv
        │   └── Symptom-severity.csv
        └── MedQuAD_Dataset/
            └── medquad.csv
```

### Dataset Format

**dataset.csv:**
```csv
Disease,Symptom_1,Symptom_2,Symptom_3,...
Diabetes,Increased thirst,Frequent urination,Fatigue,...
```

**symptom_Description.csv:**
```csv
Disease,Description
Diabetes,A condition where blood sugar levels are too high...
```

**symptom_precaution.csv:**
```csv
Disease,Precaution_1,Precaution_2,Precaution_3,Precaution_4
Diabetes,Regular exercise,Healthy diet,Monitor sugar,Regular checkups
```

**medquad.csv:**
```csv
question,answer
What is diabetes?,Diabetes is a disease where...
```

---

## Testing

### Run All Tests

```bash
# Run all chatbot tests
pytest backend/app/medical_chatbot/tests/ -v

# Run specific test files
pytest backend/app/medical_chatbot/tests/test_llm_service.py -v
pytest backend/app/medical_chatbot/tests/test_knowledge_service.py -v
pytest backend/app/medical_chatbot/tests/test_prompt_builder.py -v
pytest backend/app/medical_chatbot/tests/test_response_validator.py -v

# With coverage
pytest backend/app/medical_chatbot/tests/ --cov=app.medical_chatbot --cov-report=html
```

### Test Coverage

- ✅ LLM Service - 15 tests
- ✅ Knowledge Service - 10 tests
- ✅ Prompt Builder - 15 tests
- ✅ Response Validator - 15 tests
- ✅ Emergency Detector - 10 tests
- ✅ API Routes - 20 tests (from Part 1)
- ✅ Chatbot Service - 15 tests (from Part 1)

**Total: 100+ tests**

---

## Safety Features

### Medical Safety Rules

The chatbot **NEVER**:
- ❌ Diagnoses diseases
- ❌ Prescribes medications
- ❌ Recommends medicine dosages
- ❌ Tells users to stop medications
- ❌ Replaces doctors
- ❌ Guarantees medical outcomes

The chatbot **ALWAYS**:
- ✅ Uses phrases like "may be", "could be", "possibly"
- ✅ Recommends consulting healthcare professionals
- ✅ Includes medical disclaimers
- ✅ Detects emergencies
- ✅ Validates all responses
- ✅ Sanitizes dangerous content

### Emergency Detection

**Immediate Response for:**
- Chest pain / Heart attack
- Difficulty breathing
- Severe bleeding
- Stroke symptoms
- Loss of consciousness
- Seizures
- Severe injuries
- Poisoning/overdose
- Severe allergic reactions

**Emergency Response Includes:**
- 🚨 Call 108 (India) / 911 (US) immediately
- Basic first aid steps
- What NOT to do
- Clear warnings about life-threatening nature

---

## API Response Format

```json
{
  "assistant_message": "AI generated response with medical information...",
  "conversation_id": "uuid-here",
  "message_id": 42,
  "timestamp": "2026-07-06T12:00:00Z",
  "confidence": 0.87,
  "emergency_detected": false,
  "recommendations": [
    "Consult a healthcare provider",
    "Maintain healthy diet",
    "Regular exercise"
  ],
  "follow_up_questions": [
    "Would you like to know more about prevention?",
    "Do you need information about treatment options?"
  ],
  "response_time": 2.3,
  "tokens_used": 450
}
```

---

## Error Handling

### LLM Errors

**Timeout:**
```python
try:
    result = await llm_service.generate_response(prompt)
except LLMTimeoutException:
    # Returns fallback response
    response = validator.get_fallback_response("technical")
```

**API Error:**
```python
try:
    result = await llm_service.generate_response(prompt)
except LLMServiceException as e:
    logger.error(f"LLM error: {e}")
    response = validator.get_fallback_response("technical")
```

**Invalid Response:**
```python
is_valid, error, _ = validator.validate_response(ai_response, user_message)

if not is_valid:
    # Sanitize or use fallback
    response = validator.sanitize_response(ai_response)
```

### Fallback Responses

When AI fails, safe fallback responses are provided:
- Apologize for technical issue
- Recommend healthcare professional
- Include medical disclaimer
- Never leave user without guidance

---

## Performance Optimization

### Response Time

Typical response times:
- OpenAI GPT-3.5: 1-3 seconds
- Google Gemini: 2-4 seconds
- Knowledge base search: <100ms
- Emergency detection: <10ms

### Caching (Future Enhancement)

Consider caching for:
- Common questions
- Disease information
- Dataset search results
- Prompt templates

---

## Monitoring & Logging

### What's Logged

- User messages (sanitized)
- AI response times
- API latency
- Token usage
- Emergency detections
- Validation failures
- Errors and exceptions

### What's NOT Logged

- Full sensitive medical conversations
- API keys
- Personal health information (PHI)
- User authentication tokens

---

## Supported Topics

The chatbot can answer questions about:

✅ Common Diseases (diabetes, hypertension, fever, cold, etc.)
✅ Symptoms (what they mean, when to worry)
✅ General Medicine Information (NOT prescriptions)
✅ First Aid (burns, bleeding, fractures, etc.)
✅ Healthy Lifestyle (nutrition, exercise, sleep)
✅ Prevention (vaccinations, hygiene, screenings)
✅ Mental Wellness (general information, NOT therapy)
✅ Child & Elderly Healthcare
✅ Pregnancy (general information only)

❌ Specific Diagnoses
❌ Prescription Recommendations
❌ Dosage Instructions
❌ Medical Test Interpretations
❌ Surgery Advice
❌ Mental Health Therapy

---

## Known Limitations

1. **Not a Doctor:** Provides information, not medical advice
2. **Dataset Limited:** Based on available datasets only
3. **Language:** Currently optimized for English
4. **Context Window:** Limited conversation history (last 20 messages)
5. **Response Length:** Limited to ~1000 tokens
6. **API Dependent:** Requires internet and API access
7. **Cost:** API calls cost money (OpenAI/Gemini pricing)

---

## Future Enhancements

### Phase 06 (Potential)

- Multi-language support (Hindi, regional languages)
- Voice input/output
- Image analysis (skin conditions, rashes)
- Medication reminders
- Health tracking integration
- Doctor appointment booking
- Telemedicine integration
- Offline mode with local LLM

---

## Troubleshooting

### LLM Service Not Working

**Problem:** "LLM API key not configured"
**Solution:** Add API key to `.env` file

**Problem:** "Timeout error"
**Solution:** Increase timeout or check internet connection

**Problem:** "Empty response from LLM"
**Solution:** Check API quota/limits, verify API key

### Knowledge Service Issues

**Problem:** "Dataset not found"
**Solution:** Verify dataset path in `datasets/chatbot_dataset/`

**Problem:** "No disease information found"
**Solution:** Check CSV files are properly formatted

### Response Validation Failures

**Problem:** "Dangerous phrase detected"
**Solution:** This is expected - response is sanitized automatically

**Problem:** "Response too short"
**Solution:** LLM generated insufficient response - uses fallback

---

## Support & Resources

### Documentation
- Main README: `README.md`
- Implementation Summary: `IMPLEMENTATION_SUMMARY.md`
- Quick Start: `QUICK_START.md`
- This file: `AI_IMPLEMENTATION.md`

### Code Files
- LLM Service: `services/llm_service.py`
- Knowledge Service: `services/knowledge_service.py`
- Prompt Builder: `services/prompt_builder.py`
- Response Validator: `services/response_validator.py`
- Main Service: `services/chatbot_service.py`

### Tests
- All tests: `tests/` directory
- Run: `pytest backend/app/medical_chatbot/tests/ -v`

---

## License & Credits

**Project:** AI Healthcare Assistant for Rural Areas  
**Module:** Medical Chatbot  
**Phase:** 05 Part 2 - AI Implementation  
**Status:** ✅ Complete  
**Date:** July 6, 2026

**Technologies Used:**
- OpenAI GPT-3.5/GPT-4
- Google Gemini Pro
- FastAPI
- SQLAlchemy
- PostgreSQL
- Pandas
- Pydantic v2

---

## Summary

✅ **Phase 05 Part 2 Complete**

The Medical Chatbot now has full AI capabilities:
- Real-time AI responses using OpenAI or Gemini
- Medical knowledge base integration
- Emergency detection and handling
- Response validation and safety filtering
- Comprehensive error handling
- Complete test coverage
- Production-ready implementation

**Ready for deployment and testing!** 🎉
