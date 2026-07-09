# AI Healthcare Assistant - Deployment Guide

Complete deployment guide for the Medical Chatbot module.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Docker Deployment](#docker-deployment)
4. [Production Deployment](#production-deployment)
5. [Environment Configuration](#environment-configuration)
6. [Database Setup](#database-setup)
7. [AI Configuration](#ai-configuration)
8. [Testing](#testing)
9. [Monitoring & Logging](#monitoring--logging)
10. [Troubleshooting](#troubleshooting)

---

## 1. Prerequisites

### System Requirements
- **OS**: Windows 10/11, Linux, or macOS
- **RAM**: Minimum 4GB (8GB recommended)
- **Storage**: 2GB free space
- **Internet**: Required for AI API calls

### Software Requirements
- **Python**: 3.11 or higher
- **PostgreSQL**: 15 or higher (or SQLite for development)
- **Redis**: 7 or higher (optional)
- **Docker**: 24.0 or higher (for containerized deployment)
- **Git**: For version control

---

## 2. Local Development Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/your-org/ai_healthcare_assistant.git
cd ai_healthcare_assistant
```

### Step 2: Create Virtual Environment

```bash
# Create virtual environment
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate

# Activate (Linux/Mac)
source .venv/bin/activate
```

### Step 3: Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### Step 4: Configure Environment

```bash
# Copy example environment file
copy .env.example .env  # Windows
# or
cp .env.example .env    # Linux/Mac

# Edit .env with your configuration
notepad .env  # Windows
# or
nano .env     # Linux/Mac
```

**Minimum required configuration:**

```env
# Database (SQLite for development)
DATABASE_URL=sqlite+aiosqlite:///./healthcare.db

# JWT Secret
JWT_SECRET_KEY=your-secret-key-change-in-production

# AI Provider (Gemini - free tier available)
CHATBOT_LLM_PROVIDER=gemini
CHATBOT_LLM_API_KEY=your-gemini-api-key
CHATBOT_LLM_MODEL=gemini-pro
```

### Step 5: Initialize Database

```bash
# Run database migrations
cd backend
alembic upgrade head
```

### Step 6: Load Dataset

```bash
# Datasets should be in: datasets/chatbot_dataset/
# Create directory if it doesn't exist
mkdir -p ../datasets/chatbot_dataset

# Copy your disease-symptom dataset files here
# Required files:
# - Disease-Symptom-Dataset.csv
# - MedQuAD-Dataset.csv (optional)
```

### Step 7: Run Backend Server

```bash
# From backend directory
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Step 8: Verify Setup

Open browser and go to:
- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/api/v1/chatbot/health

---

## 3. Docker Deployment

### Step 1: Install Docker

Download and install Docker Desktop from:
- **Windows/Mac**: https://www.docker.com/products/docker-desktop
- **Linux**: Follow official Docker installation guide

### Step 2: Configure Environment

```bash
# Create .env file in root directory
copy .env.example .env  # Windows
cp .env.example .env    # Linux/Mac

# Update with your configuration
```

**Required Docker environment variables:**

```env
# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=healthcare_db

# Application
JWT_SECRET_KEY=your_jwt_secret_key

# AI
CHATBOT_LLM_PROVIDER=gemini
CHATBOT_LLM_API_KEY=your_api_key
```

### Step 3: Build and Run

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down

# Stop and remove volumes (CAUTION: deletes data)
docker-compose down -v
```

### Step 4: Access Services

After starting Docker:

- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

### Step 5: Run Database Migrations

```bash
# Execute migrations inside Docker container
docker-compose exec backend alembic upgrade head
```

---

## 4. Production Deployment

### Option A: Cloud Platform (Heroku, Railway, Render)

#### 1. Heroku Deployment

```bash
# Install Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# Login
heroku login

# Create app
heroku create your-app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set JWT_SECRET_KEY=your_secret_key
heroku config:set CHATBOT_LLM_PROVIDER=gemini
heroku config:set CHATBOT_LLM_API_KEY=your_api_key

# Deploy
git push heroku main

# Run migrations
heroku run alembic upgrade head
```

#### 2. Railway Deployment

1. Go to https://railway.app
2. Connect GitHub repository
3. Add PostgreSQL database
4. Configure environment variables
5. Deploy automatically

### Option B: VPS (DigitalOcean, AWS, Azure)

#### 1. Setup Server

```bash
# SSH into your server
ssh user@your-server-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose -y
```

#### 2. Deploy Application

```bash
# Clone repository
git clone https://github.com/your-org/ai_healthcare_assistant.git
cd ai_healthcare_assistant

# Create and configure .env
nano .env

# Start services
docker-compose up -d

# Setup Nginx reverse proxy (optional)
sudo apt install nginx -y
sudo nano /etc/nginx/sites-available/healthcare
```

**Nginx configuration:**

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/healthcare /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Setup SSL with Let's Encrypt
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

---

## 5. Environment Configuration

### Core Configuration

```env
# Application
ENVIRONMENT=production
DEBUG=false
API_PREFIX=/api/v1
APP_BASE_URL=https://your-domain.com

# Database
DATABASE_URL=postgresql+asyncpg://user:password@host:5432/database

# JWT
JWT_SECRET_KEY=your-super-secret-jwt-key
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### AI Configuration

```env
# Provider Selection
CHATBOT_LLM_PROVIDER=gemini  # or openai, anthropic

# Gemini Configuration
CHATBOT_LLM_API_KEY=your-gemini-api-key
CHATBOT_LLM_MODEL=gemini-pro

# OpenAI Configuration (alternative)
# CHATBOT_LLM_PROVIDER=openai
# CHATBOT_LLM_API_KEY=your-openai-api-key
# CHATBOT_LLM_MODEL=gpt-3.5-turbo

# AI Settings
CHATBOT_LLM_MAX_TOKENS=1000
CHATBOT_LLM_TEMPERATURE=0.7
CHATBOT_LLM_REQUEST_TIMEOUT=30
```

### Security Configuration

```env
# CORS
CORS_ORIGINS=https://your-frontend.com,https://admin.your-domain.com

# Rate Limiting
CHATBOT_RATE_LIMIT_MESSAGES_PER_MINUTE=10
CHATBOT_RATE_LIMIT_REQUESTS_PER_HOUR=100

# Password Hashing
BCRYPT_ROUNDS=12
```

### Optional Services

```env
# Redis Cache
REDIS_URL=redis://localhost:6379/0

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Monitoring
SENTRY_DSN=your-sentry-dsn
ENABLE_METRICS=true
```

---

## 6. Database Setup

### PostgreSQL Setup

#### Local Installation

```bash
# Ubuntu/Debian
sudo apt install postgresql postgresql-contrib

# macOS (Homebrew)
brew install postgresql
brew services start postgresql

# Windows
# Download installer from: https://www.postgresql.org/download/windows/
```

#### Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE healthcare_db;

# Create user
CREATE USER healthcare_user WITH PASSWORD 'your_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE healthcare_db TO healthcare_user;

# Exit
\q
```

### SQLite Setup (Development Only)

```env
# Use SQLite for quick testing
DATABASE_URL=sqlite+aiosqlite:///./healthcare.db
```

### Run Migrations

```bash
# Install Alembic (if not already installed)
pip install alembic

# Initialize migrations (first time only)
cd backend
alembic init alembic

# Run migrations
alembic upgrade head

# Create new migration (after model changes)
alembic revision --autogenerate -m "Description of changes"
alembic upgrade head
```

---

## 7. AI Configuration

### Option 1: Google Gemini (Recommended for College Project)

**Pros:**
- Free tier available
- No credit card required
- Good performance
- Simple API

**Setup:**

1. Go to https://makersuite.google.com/app/apikey
2. Create API key
3. Add to `.env`:

```env
CHATBOT_LLM_PROVIDER=gemini
CHATBOT_LLM_API_KEY=your-gemini-api-key
CHATBOT_LLM_MODEL=gemini-pro
```

### Option 2: OpenAI

**Pros:**
- High quality responses
- Well-documented

**Cons:**
- Requires credit card
- Paid service

**Setup:**

1. Go to https://platform.openai.com/api-keys
2. Create API key
3. Add to `.env`:

```env
CHATBOT_LLM_PROVIDER=openai
CHATBOT_LLM_API_KEY=your-openai-api-key
CHATBOT_LLM_MODEL=gpt-3.5-turbo
```

### Testing AI Setup

```bash
cd backend/app/medical_chatbot
python test_ai_setup.py
```

---

## 8. Testing

### Run Unit Tests

```bash
cd backend

# Run all tests
pytest

# Run specific test file
pytest app/medical_chatbot/tests/test_services.py

# Run with coverage
pytest --cov=app/medical_chatbot --cov-report=html

# View coverage report
open htmlcov/index.html  # macOS
start htmlcov/index.html # Windows
```

### Run Integration Tests

```bash
# Run integration tests only
pytest app/medical_chatbot/tests/test_integration.py -v

# Run with real database
pytest --use-real-db
```

### Manual API Testing

Use the interactive API documentation:

1. Start server: `uvicorn app.main:app --reload`
2. Open browser: http://localhost:8000/docs
3. Test endpoints interactively

---

## 9. Monitoring & Logging

### Application Logs

```bash
# View logs (Docker)
docker-compose logs -f backend

# View logs (direct)
tail -f backend/logs/app.log

# Log levels
# DEBUG - Detailed information
# INFO - General information
# WARNING - Warning messages
# ERROR - Error messages
# CRITICAL - Critical issues
```

### Log Configuration

```env
# .env file
LOG_LEVEL=INFO  # Set to DEBUG for development
LOG_FORMAT=json # or 'text' for human-readable
```

### Health Monitoring

```bash
# Check health endpoint
curl http://localhost:8000/api/v1/chatbot/health

# Expected response:
{
  "status": "healthy",
  "service": "medical_chatbot",
  "timestamp": "2024-01-15T10:30:00",
  "version": "1.0.0",
  "components": {
    "database": "connected",
    "llm": "available (gemini)",
    "datasets": "loaded",
    "validator": "active",
    "emergency_detector": "active"
  }
}
```

### Optional: Sentry Integration

```env
# Add to .env
SENTRY_DSN=your-sentry-dsn
```

```python
# In app/main.py (already configured)
import sentry_sdk
sentry_sdk.init(dsn=os.getenv("SENTRY_DSN"))
```

---

## 10. Troubleshooting

### Common Issues

#### 1. Database Connection Failed

**Error**: `could not connect to server`

**Solution**:
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql  # Linux
brew services list                # macOS

# Check connection string
echo $DATABASE_URL

# Test connection
psql $DATABASE_URL
```

#### 2. LLM API Key Invalid

**Error**: `Authentication failed: Invalid API key`

**Solution**:
```bash
# Verify API key is set
echo $CHATBOT_LLM_API_KEY

# Test API key
python backend/app/medical_chatbot/test_ai_setup.py
```

#### 3. Port Already in Use

**Error**: `Address already in use`

**Solution**:
```bash
# Find process using port
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

#### 4. Import Errors

**Error**: `ModuleNotFoundError: No module named 'app'`

**Solution**:
```bash
# Ensure virtual environment is activated
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows

# Reinstall dependencies
pip install -r requirements.txt

# Add app to PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:$(pwd)"  # Linux/Mac
set PYTHONPATH=%PYTHONPATH%;%CD%          # Windows
```

#### 5. Docker Build Fails

**Error**: `failed to solve with frontend dockerfile.v0`

**Solution**:
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache

# Check Dockerfile syntax
docker-compose config
```

#### 6. Migrations Failed

**Error**: `Target database is not up to date`

**Solution**:
```bash
# Check current migration version
alembic current

# View migration history
alembic history

# Downgrade if needed
alembic downgrade -1

# Upgrade to latest
alembic upgrade head
```

### Getting Help

- **GitHub Issues**: https://github.com/your-org/ai_healthcare_assistant/issues
- **Documentation**: Check `backend/app/medical_chatbot/README.md`
- **Logs**: Always check application logs first

---

## Deployment Checklist

### Pre-Deployment

- [ ] All tests passing (`pytest`)
- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] Datasets loaded and accessible
- [ ] AI API key valid and tested
- [ ] Security settings reviewed
- [ ] CORS origins configured
- [ ] Rate limiting configured

### Post-Deployment

- [ ] Health check endpoint responding
- [ ] API documentation accessible
- [ ] Create test conversation
- [ ] Verify emergency detection
- [ ] Check logging output
- [ ] Monitor error rates
- [ ] Setup backups (database)
- [ ] Configure monitoring alerts

---

## Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use strong JWT secrets** (minimum 32 characters)
3. **Enable HTTPS** in production
4. **Regularly update dependencies**: `pip list --outdated`
5. **Monitor logs** for suspicious activity
6. **Backup database** regularly
7. **Rotate API keys** periodically
8. **Use rate limiting** to prevent abuse
9. **Enable CORS** only for trusted domains
10. **Keep PostgreSQL updated**

---

## Performance Optimization

1. **Use PostgreSQL** instead of SQLite in production
2. **Enable Redis** for caching
3. **Use connection pooling** for database
4. **Optimize database queries** (add indexes)
5. **Cache datasets** in memory
6. **Use async operations** where possible
7. **Monitor response times**
8. **Set appropriate timeouts**

---

## Backup & Recovery

### Database Backup

```bash
# Backup PostgreSQL
pg_dump -U postgres healthcare_db > backup.sql

# Restore
psql -U postgres healthcare_db < backup.sql

# Docker backup
docker-compose exec -T postgres pg_dump -U postgres healthcare_db > backup.sql
```

### Automated Backups

```bash
# Add to crontab (Linux)
0 2 * * * /path/to/backup_script.sh

# backup_script.sh
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -U postgres healthcare_db > backup_$DATE.sql
# Upload to cloud storage
```

---

## Support

For additional help:

1. Check the [README](backend/app/medical_chatbot/README.md)
2. Review [AI Implementation Guide](backend/app/medical_chatbot/AI_IMPLEMENTATION.md)
3. See [Examples](backend/app/medical_chatbot/EXAMPLES.md)
4. Open a GitHub issue

---

**Last Updated**: Phase 05 Part 3 Completion
**Version**: 1.0.0
