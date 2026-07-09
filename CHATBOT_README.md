# AI Healthcare Assistant - Medical Chatbot Module

**Complete Production-Ready Medical Chatbot with AI Integration**

A comprehensive medical chatbot module for rural healthcare assistance, providing AI-powered health information, emergency detection, and conversational support in multiple languages.

---

## 🎯 Project Overview

This is a **college minor project** implementing a full-stack medical chatbot system that:

- Provides general health information and guidance
- Detects emergency situations and provides immediate assistance
- Supports multiple languages (English, Nepali, Hindi)
- Uses AI (Google Gemini/OpenAI) for intelligent responses
- Integrates with medical knowledge databases
- Maintains conversation history
- Includes safety guardrails and medical disclaimers
- Follows clean architecture principles

**⚠️ Important Medical Disclaimer:**
This chatbot provides general health information only. It cannot diagnose conditions or prescribe medications. Always consult qualified healthcare professionals for medical advice.

---

## 📋 Table of Contents

1. [Features](#features)
2. [Technology Stack](#technology-stack)
3. [Architecture](#architecture)
4. [Project Structure](#project-structure)
5. [Installation](#installation)
6. [Configuration](#configuration)
7. [Usage](#usage)
8. [API Documentation](#api-documentation)
9. [AI Integration](#ai-integration)
10. [Testing](#testing)
11. [Deployment](#deployment)
12. [Contributing](#contributing)

---

## ✨ Features

### Core Features

- **AI-Powered Responses**: Uses Google Gemini or OpenAI for intelligent medical conversations
- **Emergency Detection**: Automatically detects 7 types of medical emergencies
- **Knowledge Base Integration**: Includes disease-symptom database and medical Q&A dataset
- **Multi-Language Support**: English, Nepali, and Hindi
- **Conversation Management**: Create, continue, retrieve, and delete conversations
- **User Authentication**: JWT-based secure authentication
- **Feedback System**: Users can rate and provide feedback on responses
- **Safety Validation**: Medical guardrails prevent harmful advice
- **Context-Aware**: Maintains conversation history for better responses
- **Health Recommendations**: Provides actionable health tips
- **Follow-up Questions**: Suggests relevant follow-up questions

### Emergency Detection

Detects and responds to:
1. Cardiac emergencies (chest pain, heart attack symptoms)
2. Breathing difficulties (asthma, choking, severe respiratory distress)
3. Severe bleeding/trauma
4. Stroke symptoms
5. Severe allergic reactions
6. Poisoning
7. Severe pain (abdominal, head)

### Technical Features

- **Clean Architecture**: Separation of concerns with repositories, services, and controllers
- **Async Operations**: Fully asynchronous for high performance
- **Database**: PostgreSQL with Alembic migrations
- **Caching**: Optional Redis integration for performance
- **Logging**: Comprehensive structured logging
- **Error Handling**: Graceful error handling with meaningful messages
- **Rate Limiting**: Protection against abuse
- **API Documentation**: Auto-generated OpenAPI/Swagger docs
- **Docker Support**: Containerized deployment ready
- **Testing**: 100+ unit and integration tests

---

## 🛠 Technology Stack

### Backend
- **Framework**: FastAPI 0.109+
- **Language**: Python 3.11+
- **Database**: PostgreSQL 15+ (SQLite for development)
- **Cache**: Redis 7+ (optional)
- **ORM**: SQLAlchemy 2.0+ (async)
- **Migrations**: Alembic
- **Validation**: Pydantic v2

### AI/ML
- **LLM Providers**: 
  - Google Gemini (recommended - free tier)
  - OpenAI (GPT-3.5/GPT-4)
  - Anthropic Claude (future support)
- **NLP**: Basic text processing for emergency detection
- **Knowledge Base**: CSV-based medical datasets

### DevOps
- **Containerization**: Docker & Docker Compose
- **Web Server**: Uvicorn
- **Reverse Proxy**: Nginx (production)
- **CI/CD**: GitHub Actions (optional)

### Testing
- **Framework**: Pytest
- **Coverage**: pytest-cov
- **Mocking**: pytest-mock
- **Async Testing**: pytest-asyncio

---

## 🏗 Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         API Layer (FastAPI)             │
│  - Routes, Controllers, Dependencies    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│        Service Layer                    │
│  - Business Logic                       │
│  - AI Integration (LLM, Knowledge)      │
│  - Validation, Safety Checks            │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       Repository Layer                  │
│  - Database Operations                  │
│  - Data Access Logic                    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       Database Layer                    │
│  - PostgreSQL / SQLite                  │
│  - Models, Migrations                   │
└─────────────────────────────────────────┘
```

### AI Workflow

```
User Message
    │
    ▼
┌─────────────────────┐
│ Authentication      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Security Validation │
│ - Prompt Injection  │
│ - Input Sanitization│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Emergency Detection │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Knowledge Retrieval │
│ - Disease Info      │
│ - Symptom Data      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Prompt Building     │
│ - System Prompt     │
│ - Context           │
│ - History           │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ LLM Generation      │
│ - Gemini / OpenAI   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Response Validation │
│ - Safety Check      │
│ - Medical Guardrails│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Save to Database    │
└──────────┬──────────┘
           │
           ▼
      AI Response
```

---

## 📁 Project Structure

```
backend/app/medical_chatbot/
├── api/                          # API Layer
│   ├── routes.py                 # API endpoints
│   ├── controller.py             # Request/response handling
│   └── dependencies.py           # Dependency injection
│
├── services/                     # Business Logic Layer
│   ├── chatbot_service.py        # Main chatbot service
│   ├── llm_service.py            # LLM integration (Gemini/OpenAI)
│   ├── knowledge_service.py      # Dataset integration
│   ├── prompt_builder.py         # AI prompt construction
│   └── response_validator.py     # Safety validation
│
├── repositories/                 # Data Access Layer
│   ├── conversation_repository.py
│   └── feedback_repository.py
│
├── database/                     # Database Layer
│   ├── models.py                 # SQLAlchemy models
│   └── migrations/               # Alembic migrations
│
├── schemas/                      # Pydantic Schemas
│   ├── request.py                # Request models
│   └── response.py               # Response models
│
├── utils/                        # Utilities
│   ├── exceptions.py             # Custom exceptions
│   ├── logger.py                 # Logging utilities
│   ├── helpers.py                # Helper functions
│   ├── constants.py              # Constants
│   ├── security.py               # Security utilities
│   └── performance.py            # Performance optimization
│
├── knowledge_base/               # Medical Datasets
│   ├── diseases/
│   ├── symptoms/
│   ├── medicines/
│   └── first_aid/
│
├── prompts/                      # AI Prompts
│   └── system_prompt.md          # System prompt template
│
├── safety/                       # Safety Features
│   └── medical_guardrails.py     # Medical safety rules
│
├── tests/                        # Tests
│   ├── test_services.py          # Service tests
│   ├── test_routes.py            # API tests
│   ├── test_llm_service.py       # LLM tests
│   ├── test_integration.py       # Integration tests
│   └── conftest.py               # Test configuration
│
├── config/                       # Configuration
│   └── settings.py               # App settings
│
└── README.md                     # Module documentation
```

---

## 🚀 Installation

### Prerequisites

- Python 3.11+
- PostgreSQL 15+ (or SQLite for development)
- Git
- Virtual environment tool

### Step 1: Clone Repository

```bash
git clone https://github.com/your-org/ai_healthcare_assistant.git
cd ai_healthcare_assistant
```

### Step 2: Create Virtual Environment

```bash
# Windows
python -m venv .venv
.venv\Scripts\activate

# Linux/Mac
python3 -m venv .venv
source .venv/bin/activate
```

### Step 3: Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### Step 4: Configure Environment

```bash
# Copy environment template
copy .env.example .env  # Windows
cp .env.example .env    # Linux/Mac

# Edit configuration
notepad .env  # Windows
nano .env     # Linux/Mac
```

### Step 5: Setup Database

```bash
# Run migrations
alembic upgrade head
```

### Step 6: Run Application

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Step 7: Verify Installation

- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/api/v1/chatbot/health

---

## ⚙️ Configuration

### Minimum Configuration

Required environment variables:

```env
# Database
DATABASE_URL=sqlite+aiosqlite:///./healthcare.db

# JWT
JWT_SECRET_KEY=your-secret-key-here

# AI Provider
CHATBOT_LLM_PROVIDER=gemini
CHATBOT_LLM_API_KEY=your-gemini-api-key
CHATBOT_LLM_MODEL=gemini-pro
```

### Full Configuration

See `.env.example` for all available options.

### Getting AI API Keys

**Google Gemini (Free)**:
1. Go to https://makersuite.google.com/app/apikey
2. Create API key
3. Add to `CHATBOT_LLM_API_KEY`

**OpenAI (Paid)**:
1. Go to https://platform.openai.com/api-keys
2. Create API key
3. Set `CHATBOT_LLM_PROVIDER=openai`
4. Add to `CHATBOT_LLM_API_KEY`

---

## 💬 Usage

### Example 1: Start Conversation

```bash
POST /api/v1/chatbot/chat
Content-Type: application/json
Authorization: Bearer <your_jwt_token>

{
  "message": "I have a fever and headache. What should I do?",
  "language": "en"
}
```

**Response:**

```json
{
  "assistant_message": "I understand you're experiencing fever and headache...",
  "conversation_id": "uuid-here",
  "message_id": 123,
  "timestamp": "2024-01-15T10:30:00",
  "confidence": 0.85,
  "emergency_detected": false,
  "recommendations": [
    "Monitor your temperature regularly",
    "Stay hydrated",
    "Consult a healthcare professional if symptoms persist"
  ],
  "follow_up_questions": [
    "How high is your fever?",
    "Do you have any other symptoms?",
    "How long have you had these symptoms?"
  ]
}
```

### Example 2: Continue Conversation

```bash
POST /api/v1/chatbot/chat

{
  "conversation_id": "uuid-from-previous-response",
  "message": "The fever is around 101°F",
  "language": "en"
}
```

### Example 3: Emergency Detection

```bash
POST /api/v1/chatbot/chat

{
  "message": "I'm having severe chest pain and difficulty breathing",
  "language": "en"
}
```

**Response includes:**

```json
{
  "emergency_detected": true,
  "assistant_message": "🚨 EMERGENCY: Call 108 immediately...",
  "recommendations": [
    "Call emergency services immediately (108 in India)",
    "Do not wait - seek immediate medical attention"
  ]
}
```

### Example 4: Get Conversations

```bash
GET /api/v1/chatbot/conversations?page=1&page_size=20
Authorization: Bearer <your_jwt_token>
```

### Example 5: Submit Feedback

```bash
POST /api/v1/chatbot/feedback

{
  "conversation_id": "uuid-here",
  "rating": 5,
  "feedback_text": "Very helpful information!",
  "feedback_type": "positive"
}
```

---

## 📚 API Documentation

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/chatbot/chat` | Send message to chatbot |
| GET | `/api/v1/chatbot/conversations` | List user's conversations |
| GET | `/api/v1/chatbot/conversations/{id}` | Get specific conversation |
| DELETE | `/api/v1/chatbot/conversations/{id}` | Delete conversation |
| POST | `/api/v1/chatbot/feedback` | Submit feedback |
| GET | `/api/v1/chatbot/health` | Health check |

### Interactive Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 🤖 AI Integration

### Supported Providers

1. **Google Gemini** (Recommended)
   - Free tier available
   - Model: `gemini-pro`
   - Best for college projects

2. **OpenAI**
   - Paid service
   - Models: `gpt-3.5-turbo`, `gpt-4`
   - Higher quality responses

3. **Anthropic Claude** (Future)
   - Coming soon

### AI Features

- Context-aware responses using conversation history
- Medical knowledge integration from datasets
- Emergency detection preprocessing
- Safety validation post-processing
- Confidence scoring
- Token usage tracking

### Prompt Engineering

The system uses carefully crafted prompts with:
- Medical safety guidelines
- Emergency handling instructions
- Knowledge base context
- Conversation history
- User context (location, language)

See `backend/app/medical_chatbot/prompts/system_prompt.md` for details.

---

## 🧪 Testing

### Run All Tests

```bash
cd backend
pytest
```

### Run Specific Tests

```bash
# Unit tests only
pytest app/medical_chatbot/tests/test_services.py

# Integration tests only
pytest app/medical_chatbot/tests/test_integration.py

# With coverage
pytest --cov=app/medical_chatbot --cov-report=html
```

### Test Coverage

Current coverage: **90%+**

Coverage includes:
- Service layer logic
- API endpoints
- Repository operations
- AI integration
- Emergency detection
- Validation and safety checks

---

## 🐳 Deployment

### Docker Deployment

```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop
docker-compose down
```

### Production Deployment

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed instructions on:
- Cloud platform deployment (Heroku, Railway, Render)
- VPS deployment (DigitalOcean, AWS, Azure)
- Nginx configuration
- SSL setup
- Database backup
- Monitoring

---

## 🔒 Security

### Implemented Security Measures

1. **Authentication**: JWT-based with token expiration
2. **Input Validation**: Sanitization of user messages
3. **Prompt Injection Detection**: Basic keyword filtering
4. **Rate Limiting**: Per-user request limits
5. **SQL Injection Protection**: ORM with parameterized queries
6. **CORS Configuration**: Whitelist trusted origins
7. **Conversation Ownership**: Users can only access their own data
8. **Sensitive Data Masking**: Logs don't contain secrets

### Medical Safety

1. **No Diagnosis**: Chatbot never claims to diagnose
2. **No Prescriptions**: Chatbot never prescribes medications
3. **Emergency Detection**: Immediate alert for emergencies
4. **Disclaimers**: Every response includes appropriate warnings
5. **Professional Referral**: Always recommends consulting doctors

---

## 📊 Performance

### Optimization Techniques

1. **Async Operations**: All I/O operations are asynchronous
2. **Connection Pooling**: Database connection reuse
3. **Dataset Caching**: In-memory caching of medical datasets
4. **Response Caching**: Cache common responses (optional)
5. **Conversation History Limiting**: Only recent messages sent to LLM
6. **Token Management**: Optimize token usage

### Expected Performance

- **Response Time**: 1-3 seconds (depends on LLM)
- **Concurrent Users**: 100+ (with proper scaling)
- **Database**: Handles 10,000+ conversations efficiently

---

## 🤝 Contributing

### Development Setup

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Make changes and test: `pytest`
4. Commit: `git commit -m "Add new feature"`
5. Push: `git push origin feature/new-feature`
6. Create Pull Request

### Code Standards

- Follow PEP 8 style guide
- Add type hints to all functions
- Write docstrings for all classes and methods
- Maintain test coverage above 80%
- Update documentation for new features

---

## 📝 License

This project is developed as a college minor project.

---

## 👥 Team

**College Minor Project Team**
- Project Guide: [Name]
- Team Members: [Names]

---

## 🙏 Acknowledgments

- Google Gemini AI for free API tier
- FastAPI for excellent web framework
- PostgreSQL for robust database
- All open-source contributors

---

## 📞 Support

- **Documentation**: Check `/backend/app/medical_chatbot/README.md`
- **Deployment**: See `DEPLOYMENT_GUIDE.md`
- **Issues**: Open GitHub issue
- **Email**: [your-email@example.com]

---

## 🗺 Roadmap

### Phase 1: Core Features ✅
- [x] Basic chatbot functionality
- [x] AI integration (Gemini/OpenAI)
- [x] Emergency detection
- [x] Conversation management
- [x] User authentication

### Phase 2: Enhancements ✅
- [x] Multi-language support
- [x] Knowledge base integration
- [x] Safety validation
- [x] Feedback system
- [x] Docker support

### Phase 3: Advanced Features (Future)
- [ ] Voice chat support
- [ ] Image-based questions (OCR)
- [ ] Nepali/Hindi language UI
- [ ] Local LLM support (offline mode)
- [ ] Doctor chat integration
- [ ] Medical report analysis

---

**Version**: 1.0.0 (Phase 05 Complete)  
**Last Updated**: January 2024  
**Status**: Production Ready ✅

---

**⚠️ Medical Disclaimer**: This application provides general health information only and is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition. In case of emergency, call 108 (India) or your local emergency number immediately.
