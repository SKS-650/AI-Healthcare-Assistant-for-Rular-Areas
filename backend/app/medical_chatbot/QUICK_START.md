# Medical Chatbot - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites

- Python 3.11+
- PostgreSQL 14+
- Existing AI Healthcare Assistant backend setup

---

## Step 1: Database Migration

Run the migration to create chatbot tables:

```bash
cd backend
alembic upgrade head
```

This creates:
- `conversations` table
- `messages` table
- `chatbot_feedback` table
- `chatbot_sessions` table

---

## Step 2: Start the Server

```bash
# Development mode
uvicorn app.main:app --reload

# Production mode
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

---

## Step 3: Test the API

### Health Check

```bash
curl http://localhost:8000/api/v1/chatbot/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "medical_chatbot",
  "timestamp": "2026-07-06T12:00:00Z",
  "version": "1.0.0",
  "components": {
    "database": "healthy",
    "llm_service": "not_implemented",
    "cache": "not_implemented"
  }
}
```

### Send a Chat Message

**Note:** You need a valid JWT token. Use the auth endpoints to login first.

```bash
# Login first (if not already logged in)
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your@email.com",
    "password": "yourpassword"
  }'

# Copy the access_token from response, then:

curl -X POST http://localhost:8000/api/v1/chatbot/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "message": "What are the symptoms of diabetes?",
    "language": "en"
  }'
```

Expected response:
```json
{
  "assistant_message": "Thank you for your message...",
  "conversation_id": "uuid-here",
  "message_id": 1,
  "timestamp": "2026-07-06T12:00:00Z",
  "confidence": 0.85,
  "emergency_detected": false,
  "recommendations": [...],
  "follow_up_questions": [...],
  "response_time": 1.25,
  "tokens_used": null
}
```

---

## Step 4: Explore the API

### Interactive Documentation

Open your browser:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

### Available Endpoints

1. **Chat**
   - `POST /api/v1/chatbot/chat`

2. **Conversations**
   - `GET /api/v1/chatbot/conversations`
   - `GET /api/v1/chatbot/conversations/{id}`
   - `DELETE /api/v1/chatbot/conversations/{id}`

3. **Feedback**
   - `POST /api/v1/chatbot/feedback`

4. **Health**
   - `GET /api/v1/chatbot/health`

---

## Step 5: Run Tests

```bash
# All tests
pytest backend/app/medical_chatbot/tests/ -v

# Specific test file
pytest backend/app/medical_chatbot/tests/test_routes.py -v

# With coverage
pytest backend/app/medical_chatbot/tests/ --cov=app.medical_chatbot --cov-report=html

# View coverage report
open htmlcov/index.html
```

---

## Common Use Cases

### 1. Start a New Conversation

```python
import requests

url = "http://localhost:8000/api/v1/chatbot/chat"
headers = {"Authorization": "Bearer YOUR_TOKEN"}
data = {
    "message": "What is diabetes?",
    "language": "en"
}

response = requests.post(url, json=data, headers=headers)
print(response.json())
```

### 2. Continue a Conversation

```python
data = {
    "message": "What are the risk factors?",
    "conversation_id": "uuid-from-previous-response",
    "language": "en"
}

response = requests.post(url, json=data, headers=headers)
print(response.json())
```

### 3. List Your Conversations

```python
url = "http://localhost:8000/api/v1/chatbot/conversations"
params = {"page": 1, "page_size": 20}

response = requests.get(url, params=params, headers=headers)
print(response.json())
```

### 4. Get Conversation Details

```python
conversation_id = "your-conversation-uuid"
url = f"http://localhost:8000/api/v1/chatbot/conversations/{conversation_id}"

response = requests.get(url, headers=headers)
print(response.json())
```

### 5. Submit Feedback

```python
url = "http://localhost:8000/api/v1/chatbot/feedback"
data = {
    "conversation_id": "conversation-uuid",
    "rating": 5,
    "feedback_text": "Very helpful!",
    "feedback_type": "helpful"
}

response = requests.post(url, json=data, headers=headers)
print(response.json())
```

---

## Emergency Detection Test

The system detects emergency keywords:

```python
data = {
    "message": "I'm having severe chest pain",
    "language": "en"
}

response = requests.post(url, json=data, headers=headers)
result = response.json()

print(f"Emergency detected: {result['emergency_detected']}")
# Output: Emergency detected: True
```

---

## Configuration

### Environment Variables

Create a `.env` file:

```env
# Database
DATABASE_URL=postgresql://user:password@localhost/dbname

# JWT
JWT_SECRET_KEY=your-secret-key-here
JWT_ALGORITHM=HS256

# Chatbot
CHATBOT_DEBUG=false
CHATBOT_RATE_LIMIT_MESSAGES_PER_MINUTE=10
CHATBOT_MAX_CONVERSATION_MESSAGES=100

# LLM (Phase 2)
CHATBOT_LLM_PROVIDER=openai
CHATBOT_LLM_API_KEY=your-api-key
CHATBOT_LLM_MODEL=gpt-4

# Redis (Phase 2)
REDIS_URL=redis://localhost:6379
```

---

## Troubleshooting

### Issue: Migration fails

**Solution:** Ensure PostgreSQL is running and DATABASE_URL is correct.

```bash
# Check PostgreSQL status
pg_isready

# Test connection
psql -h localhost -U your_user -d your_database
```

### Issue: 401 Unauthorized

**Solution:** You need a valid JWT token. Login first:

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your@email.com",
    "password": "yourpassword"
  }'
```

### Issue: 422 Validation Error

**Solution:** Check your request payload matches the schema:

```python
# Correct format
{
    "message": "Your message here",  # Required, 1-2000 chars
    "language": "en",                # Optional, default "en"
    "conversation_id": "uuid"        # Optional, for continuing
}
```

### Issue: Placeholder responses

**Expected:** This is Phase 05 Part 1. Real AI responses will be implemented in Phase 05 Part 2.

The current implementation returns informative placeholder responses to test the infrastructure.

---

## What's Working Now

✅ Full REST API  
✅ Database operations  
✅ Authentication & authorization  
✅ Input validation  
✅ Error handling  
✅ Logging  
✅ Emergency detection  
✅ Conversation management  
✅ Feedback system  
✅ Health checks  

## What's Coming in Phase 05 Part 2

🚧 Real AI/LLM responses  
🚧 Medical knowledge base  
🚧 RAG pipeline  
🚧 Vector search  
🚧 Response validation  
🚧 Safety filters  
🚧 Multi-language support  
🚧 Redis caching  

---

## Next Steps

1. **Test all endpoints** using Swagger UI
2. **Run the test suite** to verify everything works
3. **Review the code** to understand the architecture
4. **Read the README** for detailed documentation
5. **Prepare for Phase 05 Part 2** - LLM integration

---

## Support

- 📖 **Full Documentation:** See `README.md`
- 📋 **Implementation Details:** See `IMPLEMENTATION_SUMMARY.md`
- 🧪 **Tests:** See `tests/` directory
- 🔧 **Configuration:** See `config/settings.py`

---

## Success! 🎉

Your medical chatbot infrastructure is now running and ready for LLM integration in Phase 05 Part 2.

Happy coding! 💻
