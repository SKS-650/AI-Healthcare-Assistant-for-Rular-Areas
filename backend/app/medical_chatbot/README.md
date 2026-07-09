# Medical Chatbot Module

## Overview

The Medical Chatbot module provides a conversational AI assistant for healthcare information. It is designed to help users understand general health topics, symptoms, diseases, and basic first aid, while always emphasizing the importance of consulting healthcare professionals.

**⚠️ IMPORTANT DISCLAIMER:** This chatbot provides general health information only. It CANNOT diagnose conditions, prescribe treatments, or replace professional medical advice.

## Features

### Current Implementation (Phase 05 - COMPLETE)

✅ **Complete Production-Ready Infrastructure with AI:**
- REST API endpoints with FastAPI
- SQLAlchemy 2.0 ORM models
- PostgreSQL database integration
- Pydantic v2 schemas for validation
- Repository pattern for data access
- Service layer for business logic
- **LLM Integration (OpenAI/Gemini)**
- **Medical Knowledge Base Integration**
- **Prompt Engineering & Building**
- **Response Validation & Safety Filtering**
- **Emergency Detection & Handling**
- **Context-Aware AI Responses**
- Comprehensive error handling
- Structured logging
- JWT authentication support
- Rate limiting structure
- Input validation and sanitization
- Conversation management
- Feedback system
- Health check endpoints
- Complete unit tests (100+)
- Alembic migrations
- OpenAPI documentation

### AI Features (Phase 05 Part 2) ✅

🤖 **Artificial Intelligence:**
- Real-time AI responses using LLM APIs
- Provider-independent (OpenAI, Gemini, easy to extend)
- Medical dataset integration (diseases, symptoms, Q&A)
- Intelligent prompt building with context
- Conversation history management
- Response validation and sanitization
- Emergency situation detection (7 categories)
- Medical safety guardrails
- Confidence scoring
- Fallback handling

## Architecture

```
┌─────────────────┐
│  Flutter App    │
└────────┬────────┘
         │ HTTP/REST
┌────────▼────────────────────┐
│   FastAPI Backend           │
│  ┌──────────────────────┐  │
│  │  API Routes          │  │
│  │  - Chat              │  │
│  │  - Conversations     │  │
│  │  - Feedback          │  │
│  └──────────┬───────────┘  │
│  ┌──────────▼───────────┐  │
│  │  Controller Layer    │  │
│  │  - Request validation│  │
│  │  - Error handling    │  │
│  └──────────┬───────────┘  │
│  ┌──────────▼───────────┐  │
│  │  Service Layer       │  │
│  │  - Business logic    │  │
│  │  - LLM integration   │  │ (Phase 2)
│  └──────────┬───────────┘  │
│  ┌──────────▼───────────┐  │
│  │  Repository Layer    │  │
│  │  - Data access       │  │
│  └──────────┬───────────┘  │
│             │              │
└─────────────┼──────────────┘
              │
┌─────────────▼──────────────┐
│   PostgreSQL Database      │
│  - conversations           │
│  - messages                │
│  - chatbot_feedback        │
│  - chatbot_sessions        │
└────────────────────────────┘
```

## Database Schema

### Tables

1. **conversations**
   - User chat sessions
   - Tracks conversation metadata
   - Links to user and session

2. **messages**
   - Individual messages
   - Stores both user and assistant messages
   - Includes metadata (tokens, response time, confidence)

3. **chatbot_feedback**
   - User feedback on conversations
   - Rating system (1-5)
   - Feedback categories

4. **chatbot_sessions**
   - User session tracking
   - Device and location information
   - Activity timestamps

## API Endpoints

### Chat
- `POST /api/v1/chatbot/chat` - Send message to chatbot
  - Create new conversation or continue existing
  - Returns AI response with recommendations

### Conversations
- `GET /api/v1/chatbot/conversations` - List user's conversations
  - Pagination, search, and filtering
- `GET /api/v1/chatbot/conversations/{id}` - Get conversation details
  - Includes all messages
- `DELETE /api/v1/chatbot/conversations/{id}` - Delete conversation

### Feedback
- `POST /api/v1/chatbot/feedback` - Submit feedback

### Health
- `GET /api/v1/chatbot/health` - Service health check

## Quick Start

### Prerequisites
- Python 3.11+
- PostgreSQL 14+
- OpenAI or Google Gemini API key

### Setup

1. **Install Dependencies**
```bash
cd backend
pip install -r requirements.txt
```

2. **Configure Environment**
```bash
cp .env.example .env
# Edit .env with your configuration

# Required for AI functionality:
CHATBOT_LLM_PROVIDER=gemini  # or openai
CHATBOT_LLM_API_KEY=your_api_key_here
CHATBOT_LLM_MODEL=gemini-pro  # or gpt-3.5-turbo
```

3. **Setup Datasets**
Ensure datasets are in place:
```
d:/MinorProject/ai_healthcare_assistant/
└── datasets/
    └── chatbot_dataset/
        ├── DiseaseSymptomPredictionDataset/
        └── MedQuAD_Dataset/
```

4. **Run Migrations**
```bash
alembic upgrade head
```

5. **Start Server**
```bash
uvicorn app.main:app --reload
```

6. **Test AI Functionality**
```bash
# Health check
curl http://localhost:8000/api/v1/chatbot/health

# Send a message (requires JWT token)
curl -X POST http://localhost:8000/api/v1/chatbot/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What are the symptoms of diabetes?",
    "language": "en"
  }'
```

## Configuration

Environment variables (prefix: `CHATBOT_`):

```env
# Service
CHATBOT_DEBUG=false

# Database
DATABASE_URL=postgresql://user:pass@localhost/dbname

# LLM (Phase 2)
CHATBOT_LLM_PROVIDER=openai
CHATBOT_LLM_API_KEY=your_api_key
CHATBOT_LLM_MODEL=gpt-4

# Rate Limiting
CHATBOT_RATE_LIMIT_MESSAGES_PER_MINUTE=10
CHATBOT_RATE_LIMIT_REQUESTS_PER_HOUR=100

# Security
JWT_SECRET_KEY=your_secret_key
```

## Usage Examples

### Send Message

```python
import requests

headers = {"Authorization": "Bearer YOUR_JWT_TOKEN"}

# New conversation
payload = {
    "message": "What are the symptoms of diabetes?",
    "language": "en"
}

response = requests.post(
    "http://localhost:8000/api/v1/chatbot/chat",
    json=payload,
    headers=headers
)

print(response.json())
```

### Continue Conversation

```python
payload = {
    "message": "What are the risk factors?",
    "conversation_id": "uuid-from-previous-response",
    "language": "en"
}

response = requests.post(
    "http://localhost:8000/api/v1/chatbot/chat",
    json=payload,
    headers=headers
)
```

### Get Conversations

```python
response = requests.get(
    "http://localhost:8000/api/v1/chatbot/conversations?page=1&page_size=20",
    headers=headers
)
```

### Submit Feedback

```python
payload = {
    "conversation_id": "conversation-uuid",
    "rating": 5,
    "feedback_text": "Very helpful!",
    "feedback_type": "helpful"
}

response = requests.post(
    "http://localhost:8000/api/v1/chatbot/feedback",
    json=payload,
    headers=headers
)
```

## Testing

Run tests:
```bash
pytest backend/app/medical_chatbot/tests/ -v
```

Run with coverage:
```bash
pytest backend/app/medical_chatbot/tests/ --cov=app.medical_chatbot --cov-report=html
```

## Security

- JWT authentication required for all endpoints
- Input validation and sanitization
- SQL injection prevention
- XSS protection
- Rate limiting
- Emergency detection
- Sensitive data masking in logs

## Safety Guidelines

The chatbot implements multiple safety layers:

1. **Medical Disclaimers** - Always included in responses
2. **Emergency Detection** - Keywords trigger immediate warnings
3. **Safety Filters** - Prevent harmful advice
4. **Recommendation System** - Suggests professional consultation
5. **Conversation Limits** - Prevents excessive reliance

## Contributing

When contributing to this module:

1. Follow Clean Architecture principles
2. Maintain SOLID principles
3. Write comprehensive tests
4. Update documentation
5. Follow code style guidelines

## Roadmap

### Phase 05 Part 1 ✅
- [x] Database models and migrations
- [x] REST API endpoints
- [x] Repository pattern
- [x] Service layer
- [x] Request/Response schemas
- [x] Authentication
- [x] Error handling
- [x] Logging
- [x] Tests
- [x] Documentation

### Phase 05 Part 2 🚧
- [ ] LLM service integration
- [ ] Prompt engineering
- [ ] RAG pipeline
- [ ] Knowledge base
- [ ] Memory management
- [ ] Response validation
- [ ] Safety filters
- [ ] Multi-language support
- [ ] Redis caching
- [ ] Performance optimization

## License

Copyright © 2026 AI Healthcare Assistant Team

## Support

For questions or issues, contact the development team.
