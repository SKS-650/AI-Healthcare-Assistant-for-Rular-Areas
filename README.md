# AI Healthcare Assistant

A full-stack AI-powered healthcare platform built with FastAPI (Python) on the backend, Flutter for both the mobile app and admin web dashboard, and a dedicated AI models layer for machine learning, NLP, and voice capabilities.

---

## Current Project Status (July 2026)

The project has reached a comprehensive MVP/alpha stage. The core platform, AI modules, mobile experience, admin dashboard, and supporting infrastructure have all been implemented and documented.

### What has been completed so far

- Full-stack architecture for a healthcare assistant with backend APIs, mobile app, admin dashboard, and AI services
- FastAPI backend with authentication, user management, JWT sessions, role-based access, and modular feature routers
- Medical chatbot with conversation history, multi-language handling, emergency detection, response validation, and fallback to offline knowledge search
- Symptom checker with a trained machine learning model, risk scoring, recommendations, and prediction history support
- Emergency assessment workflow with risk evaluation, first-aid guidance, SOS contact handling, and emergency history tracking
- Personal health records (PHR) support for medical profile, history, prescriptions, images, and timeline management
- Health education module with categorized articles, bookmarks, reading progress, and personalized recommendations
- Voice assistant pipeline for speech-to-text, text-to-speech, language detection, and full voice-based chatbot interaction
- Offline sync and offline-capable features using local caching and FAISS-backed knowledge search
- Flutter mobile app with authentication, onboarding, chatbot, symptom checker, emergency, records, education, profile, and settings screens
- Flutter admin dashboard with 11 management modules, analytics, reports, logs, and settings
- AI model layer with training scripts, inference modules, dataset integration, and saved model artifacts
- Setup and deployment utilities including virtual environment scripts, startup scripts, Docker configuration, and detailed documentation

### Current implementation status

- Backend: implemented and organized into feature-based modules
- Mobile app: implemented with major user-facing features and offline support
- Admin dashboard: implemented with core administration workflows and analytics
- AI models: trained and integrated for symptom prediction and chatbot knowledge retrieval
- Documentation: setup guides, architecture docs, testing guides, quick-start references, and project reports are included

### Notes for production use

- Some advanced features work best when real API credentials are configured for LLM providers, email/SMS services, and cloud storage
- The symptom checker model and FAISS index are included as part of the project artifacts and are ready for use once the environment is configured
- The platform is suitable for further development, demo deployment, and refinement into a production-ready healthcare application

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Repository Structure](#2-repository-structure)
3. [Tech Stack](#3-tech-stack)
4. [Backend — FastAPI](#4-backend--fastapi)
   - [Architecture](#41-architecture)
   - [Authentication & Authorization](#42-authentication--authorization)
   - [Medical Chatbot](#43-medical-chatbot)
   - [Symptom Checker](#44-symptom-checker)
   - [Emergency Module](#45-emergency-module)
   - [Health Records (PHR)](#46-health-records-phr)
   - [Health Education](#47-health-education)
   - [Voice Assistant](#48-voice-assistant)
   - [Offline Sync](#49-offline-sync)
   - [Database](#410-database)
5. [Mobile App — Flutter](#5-mobile-app--flutter)
   - [Architecture & State Management](#51-architecture--state-management)
   - [Features & Screens](#52-features--screens)
   - [Offline Mode](#53-offline-mode)
   - [Key Packages](#54-key-packages)
6. [Admin Dashboard — Flutter Web](#6-admin-dashboard--flutter-web)
7. [AI Models Layer](#7-ai-models-layer)
8. [Environment Configuration](#8-environment-configuration)
9. [Getting Started](#9-getting-started)
10. [API Reference](#10-api-reference)
11. [Bug Fixes & Known Issues Resolved](#11-bug-fixes--known-issues-resolved)

---

## 1. Project Overview

The AI Healthcare Assistant is designed to make basic healthcare guidance accessible from a smartphone. It combines several AI capabilities into one unified app:

- An AI-powered medical chatbot that answers health questions in multiple languages
- A symptom checker that uses a trained ML model to suggest possible conditions
- An emergency assessment tool with AI risk scoring, first-aid guides, and SOS alerts
- A personal health records vault (PHR) for storing prescriptions, medical history, and images
- A health education library with personalized article recommendations
- A voice interface supporting Speech-to-Text and Text-to-Speech in English, Hindi, Nepali, and other Indian languages
- Full offline support using a local FAISS vector database and Hive on-device storage
- An admin web dashboard for platform management

The system is intended primarily for users in South Asia (India, Nepal) and includes language support for Hindi, Nepali, Bhojpuri, Bengali, Tamil, Telugu, Marathi, and Gujarati.

---

## 2. Repository Structure

```
ai_healthcare_assistant/
├── backend/                    # FastAPI Python backend
│   ├── app/
│   │   ├── auth/               # Authentication, JWT, OTP, sessions, RBAC
│   │   ├── users/              # User profile management
│   │   ├── medical_chatbot/    # LLM-powered medical chatbot
│   │   ├── symptom_checker/    # ML-based symptom → disease prediction
│   │   ├── emergency/          # Emergency assessment, contacts, SOS
│   │   ├── health_records/     # Personal health records (PHR)
│   │   ├── health_education/   # Articles, bookmarks, recommendations
│   │   ├── voice/              # STT, TTS, full voice-chat pipeline
│   │   ├── offline_sync/       # Bidirectional offline data sync
│   │   ├── config/             # Settings loaded from environment
│   │   ├── core/               # Startup, shutdown lifecycle hooks
│   │   └── database/           # Async SQLAlchemy engine and session
│   ├── TESTING_GUIDE.md
│   └── .env
├── mobile_app/                 # Flutter mobile app (Android / iOS)
│   ├── lib/
│   │   ├── core/               # API client, local DB, routing, shared widgets
│   │   ├── features/           # One folder per feature (auth, chatbot, etc.)
│   │   └── routing/            # Named routes and navigation config
│   └── pubspec.yaml
├── admin_dashboard/            # Flutter web admin dashboard
│   ├── lib/
│   │   ├── core/               # API client, router, theme
│   │   └── features/           # analytics, users, doctors, reports, etc.
│   └── pubspec.yaml
├── ai_models/                  # Python ML/AI scripts and saved models
│   ├── chatbot/                # Chatbot engine, conversation manager, prompts
│   ├── configs/                # Model and inference YAML configs
│   ├── datasets/               # Training and evaluation data
│   ├── scripts/                # FAISS index builder and training utilities
│   ├── saved_models/           # Trained model files (joblib, FAISS index)
│   └── tests/                  # AI model unit tests
├── requirements.txt            # Unified Python dependencies
├── .env.example                # All environment variables documented
├── start_all.bat               # One-click Windows startup script
└── README.md
```

---

## 3. Tech Stack

### Backend
| Layer | Technology |
|---|---|
| Web framework | FastAPI 0.111 + Uvicorn |
| ORM | SQLAlchemy 2.0 (async) |
| Database (dev) | SQLite via aiosqlite |
| Database (prod) | PostgreSQL via asyncpg |
| Cache | Redis |
| Migrations | Alembic |
| LLM providers | OpenAI GPT-4, Google Gemini, Anthropic Claude |
| Embeddings | sentence-transformers (all-MiniLM-L6-v2) |
| Vector search | FAISS (offline knowledge base) |
| ML / prediction | scikit-learn, NumPy, pandas, SciPy |
| Speech-to-Text | OpenAI Whisper (local), Google STT (fallback), Vosk (fully offline) |
| Text-to-Speech | Microsoft Edge TTS (neural), gTTS (fallback), pyttsx3 (offline) |
| Translation | deep-translator (Google Translate wrapper) |
| Language detection | langdetect |
| Auth | JWT (HS256), bcrypt password hashing, OTP via email/SMS |
| HTTP client | httpx, aiohttp |

### Mobile App
| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State management | Riverpod 2.x |
| Local storage | Hive + hive_flutter |
| Secure token storage | flutter_secure_storage |
| Voice (STT) | speech_to_text 7.x |
| Voice (TTS) | flutter_tts 4.x |
| Audio recording | record 7.x |
| Audio playback | audioplayers 6.x |
| Networking | http 1.x, connectivity_plus, internet_connection_checker_plus |
| UI | flutter_animate, shimmer, lottie, flutter_markdown, cached_network_image |
| Preferences | shared_preferences |

### Admin Dashboard
| Layer | Technology |
|---|---|
| Framework | Flutter Web (Dart) |
| Routing | go_router |
| Charts / Analytics | fl_chart or similar |

---

## 4. Backend — FastAPI

The backend is a single FastAPI application that serves all features through a versioned REST API at `/api/v1/`. It uses SQLAlchemy's async engine throughout, so all database operations are non-blocking. In development it runs against SQLite (zero config), and in production it connects to PostgreSQL.

### 4.1 Architecture

The app is created in `backend/app/main.py` using a factory pattern (`create_app()`). Each feature is a self-contained Python package with its own `routes.py`, `services.py`, `schemas.py`, and `models.py`. All routers are registered in the factory with the shared `/api/v1` prefix.

Startup and shutdown lifecycle hooks in `backend/app/core/startup.py` handle:
- Loading environment variables from `.env`
- Running `Base.metadata.create_all()` to auto-create all tables in development
- Initializing the FAISS vector index and loading the ML symptom-checker model
- Graceful shutdown of async resources

CORS is configured to allow all origins in development and is restricted to `CORS_ORIGINS` in production. Static file uploads (profile images, prescription PDFs, medical images) are served from `/uploads`.

### 4.2 Authentication & Authorization

Module path: `backend/app/auth/`

A complete authentication system with the following endpoints:

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/register` | Create a new user account |
| POST | `/auth/verify-email` | Verify email using token |
| POST | `/auth/resend-email-verification` | Resend verification email |
| POST | `/auth/send-phone-otp` | Send SMS OTP to registered phone |
| POST | `/auth/verify-phone` | Verify phone with OTP |
| POST | `/auth/login` | Login, returns access + refresh tokens |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Revoke current session |
| POST | `/auth/logout-all` | Revoke all sessions (all devices) |
| POST | `/auth/forgot-password` | Request password reset via email link |
| POST | `/auth/forgot-password-otp` | Request password reset via 6-digit OTP (mobile-friendly) |
| POST | `/auth/verify-reset-otp` | Verify OTP and receive a reset token |
| POST | `/auth/reset-password` | Set new password using reset token |
| GET | `/auth/me` | Get current user profile |
| GET | `/auth/sessions` | List active sessions |
| POST | `/auth/sessions/revoke` | Revoke a specific session |
| POST | `/auth/change-role` | Change user role (admin only) |

**Key design decisions:**
- Access tokens expire in 15 minutes; refresh tokens last 30 days
- Tokens are stored in the database with hashes — individual sessions can be revoked
- User IDs are UUID strings (not integers), which is enforced throughout the system
- Roles: `patient`, `doctor`, `admin` — enforced via FastAPI dependency injection
- Email and phone verification are tracked separately on the user record
- All OTP codes are stored as hashed values and single-use
- SMTP email and Twilio SMS are configurable; a mock provider is used in development

**Database models:** `users`, `roles`, `permissions`, `role_permissions`, `refresh_tokens`, `otp_codes`, `email_verification`, `phone_verification`, `password_reset`, `user_sessions`

---

### 4.3 Medical Chatbot

Module path: `backend/app/medical_chatbot/`

An LLM-powered medical assistant that maintains full conversation history.

| Method | Endpoint | Description |
|---|---|---|
| POST | `/chatbot/chat` | Send a message and receive AI response |
| GET | `/chatbot/conversations` | List user's conversations (paginated, filterable) |
| GET | `/chatbot/conversations/{id}` | Get full conversation with all messages |
| DELETE | `/chatbot/conversations/{id}` | Delete a conversation |
| POST | `/chatbot/feedback` | Rate a conversation (1–5 stars + text) |
| GET | `/chatbot/health` | Service health check |

**How it works:**
- The chatbot service tries an online LLM first (Gemini, OpenAI, or Claude based on configuration)
- If the LLM is unavailable or the API key is invalid, it falls back to a FAISS-powered offline semantic search against a pre-built medical knowledge base
- Responses include emergency detection — if the user describes a potential emergency, the chatbot flags it and suggests calling emergency services
- Follow-up question suggestions are returned alongside every response
- Language auto-detection allows the user to write in Hindi, Nepali, or English and receive a response in the same language
- Conversations and messages are persisted in the database (`conversations`, `messages`, `chatbot_feedback`, `chatbot_sessions` tables)

---

### 4.4 Symptom Checker

Module path: `backend/app/symptom_checker/`

An ML-based disease prediction engine trained on a 230-symptom dataset.

| Method | Endpoint | Description |
|---|---|---|
| POST | `/symptom-checker/predict` | Predict diseases from symptom list |
| GET | `/symptom-checker/symptoms` | List all 230 recognizable symptoms |
| GET | `/symptom-checker/symptoms/categorized` | Symptoms organized by body system |
| GET | `/symptom-checker/diseases` | List all known diseases |
| POST | `/symptom-checker/batch-predict` | Batch predictions |
| GET | `/symptom-checker/model-info` | Model metadata and accuracy metrics |
| POST | `/symptom-checker/reload` | Hot-reload the model (admin) |

**Prediction input includes:**
- List of symptom names (from the 230-symptom vocabulary)
- Age, gender, weight, height
- Symptom duration and severity (1–4)
- Existing conditions, current medications, allergies
- Pregnancy status

**Prediction output includes:**
- Top 5 diseases with confidence scores
- Risk assessment: `low`, `medium`, `high`, or `critical`
- Medical recommendations
- Emergency alert flag if symptoms indicate urgent care is needed

**Symptoms are organized into body-system categories:** General, Respiratory, Cardiovascular, Neurological, Digestive, Musculoskeletal, ENT, Dermatological, Urological, Ophthalmological, Psychological, Endocrine, and others.

---

### 4.5 Emergency Module

Module path: `backend/app/emergency/`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/emergency/assessment` | Run AI emergency assessment (auth optional) |
| GET | `/emergency/history` | Past assessments for authenticated user |
| GET | `/emergency/assessment/{id}` | Get a specific assessment |
| GET | `/emergency/contacts` | List emergency contacts |
| POST | `/emergency/contacts` | Add emergency contact |
| PUT | `/emergency/contacts/{id}` | Update emergency contact |
| DELETE | `/emergency/contacts/{id}` | Delete emergency contact |
| POST | `/emergency/sos` | Trigger SOS alert to all contacts |
| GET | `/emergency/first-aid` | All first-aid guides (offline-safe) |

**Assessment pipeline:**
- Takes symptoms, patient data, and location
- Returns a numerical risk score, risk level (`low` / `moderate` / `high` / `critical`), and step-by-step first-aid guidance
- Lists recommended nearby hospital types based on the situation
- Anonymous assessments are supported (no login required) — these are stored without a user link

**SOS feature:**
- Sends alerts to all stored emergency contacts via SMS/email
- Rate-limited to prevent accidental repeated triggers

**First-aid guides** cover common emergencies (heart attack, stroke, choking, burns, fractures, allergic reactions, etc.) and are fully embedded in the API response so they work offline.

---

### 4.6 Health Records (PHR)

Module path: `backend/app/health_records/`

A personal health record vault where users can store and manage all their medical data.

| Method | Endpoint | Description |
|---|---|---|
| GET | `/health-records/summary` | Dashboard summary (counts, last activity) |
| GET | `/health-records/profile` | Get medical profile |
| PUT | `/health-records/profile` | Create or update medical profile |
| GET | `/health-records/history` | List medical history entries (filterable) |
| POST | `/health-records/history` | Add a history entry |
| PUT | `/health-records/history/{id}` | Update history entry |
| DELETE | `/health-records/history/{id}` | Delete history entry |
| GET | `/health-records/prescriptions` | List prescriptions |
| POST | `/health-records/prescriptions` | Upload prescription (with optional file) |
| DELETE | `/health-records/prescriptions/{id}` | Delete prescription |
| GET | `/health-records/images` | List medical images |
| POST | `/health-records/images` | Upload medical image (X-ray, MRI, CT, etc.) |
| DELETE | `/health-records/images/{id}` | Delete image |
| GET | `/health-records/timeline` | Unified chronological medical timeline |
| POST | `/health-records/timeline/external` | Push event from another module |

The medical profile stores blood group, allergies, chronic conditions, current medications, and baseline health metrics. Files (prescription PDFs and medical images) are stored on disk under `/uploads` and served as static files.

---

### 4.7 Health Education

Module path: `backend/app/health_education/`

A content management system for health education articles with personalization.

| Method | Endpoint | Description |
|---|---|---|
| GET | `/education/dashboard` | Full dashboard (featured, categories, recommendations, bookmarks) |
| GET | `/education/categories` | All health categories |
| GET | `/education/articles` | Paginated article list (filterable by category, language) |
| GET | `/education/articles/{id}` | Article detail + increments view count |
| GET | `/education/featured` | Featured articles |
| GET | `/education/search` | Full-text search |
| GET | `/education/recommendations` | Personalized recommendations based on reading history |
| GET | `/education/bookmarks` | User's saved articles |
| POST | `/education/bookmarks` | Save article to bookmarks |
| DELETE | `/education/bookmarks/{id}` | Remove bookmark |
| POST | `/education/reading-progress/{id}` | Track reading progress |

The module auto-seeds initial articles on first request using `SeedService`. Content supports multiple languages: English (`en`), Hindi (`hi`), Nepali (`ne`), and Bhojpuri (`bh`). Reading history drives the recommendation engine.

---

### 4.8 Voice Assistant

Module path: `backend/app/voice/`

A three-tier voice processing pipeline: Speech-to-Text → AI → Text-to-Speech.

| Method | Endpoint | Description |
|---|---|---|
| POST | `/voice/stt` | Upload audio file → get transcript |
| POST | `/voice/tts` | Text → base64 MP3 audio |
| POST | `/voice/chat` | Full pipeline: audio → STT → AI → TTS → audio response |
| GET | `/voice/languages` | Supported languages list |
| GET | `/voice/health` | Engine availability check |

**STT stack (priority order):**
1. OpenAI Whisper (local model, best accuracy, works offline)
2. Google Speech Recognition (free, requires internet)
3. Vosk (fully offline, lower accuracy)

**TTS stack (priority order):**
1. Microsoft Edge TTS neural voices (free, best quality) — supports `en-IN`, `hi-IN`, `ne-NP`
2. Google TTS (gTTS)
3. pyttsx3 system voice (fully offline)

**Supported languages for voice:** English, Hindi, Nepali, Bhojpuri, Bengali, Tamil, Telugu, Marathi. Language auto-detection is available.

**Voice chat pipeline** (`/voice/chat`):
- Accepts an audio file and optional conversation ID
- Runs STT to get transcript
- Detects language and intent
- Calls the chatbot AI (online or offline FAISS)
- Detects emergency keywords
- Synthesizes the response as audio
- Returns both text and base64-encoded audio in one response

---

### 4.9 Offline Sync

Module path: `backend/app/offline_sync/`

Enables bidirectional synchronization between the server and the mobile app's local Hive database.

| Method | Endpoint | Description |
|---|---|---|
| POST | `/offline/upload/` | Upload pending queue items from device to server |
| GET | `/offline/download/` | Download latest data to cache on device |
| POST | `/offline/sync/` | Full bidirectional sync in one round-trip |
| GET | `/offline/history/` | Sync history for the user |
| GET | `/offline/settings/` | Get offline settings |
| PUT | `/offline/settings/` | Update offline settings |

The sync system allows users to use the app without an internet connection and push/pull changes when connectivity is restored.

---

### 4.10 Database

**Development:** SQLite (`app.db` file in the backend directory) — no setup required.

**Production:** PostgreSQL — configure `DATABASE_URL` in `.env`.

The app uses SQLAlchemy's async engine throughout. In development, all tables are auto-created on startup via `Base.metadata.create_all()`. For production, Alembic handles migrations.

Redis is used for caching and rate limiting (configurable via `REDIS_URL`).

---

## 5. Mobile App — Flutter

Directory: `mobile_app/`

A Flutter mobile application for Android and iOS that connects to the FastAPI backend.

### 5.1 Architecture & State Management

The app follows a layered feature-first architecture:

```
lib/
├── core/
│   ├── api/            # HTTP client, interceptors, error handling
│   ├── local_db/       # Hive-based local database service
│   ├── network/        # NetworkConfig — persisted backend URL
│   └── routing/        # Named route constants and go_router config
└── features/
    └── <feature>/
        ├── data/
        │   ├── datasources/   # Remote (API) and local (Hive) data sources
        │   └── repositories/  # Repository implementations
        ├── domain/
        │   ├── entities/      # Pure data models
        │   └── repositories/  # Repository interfaces
        └── presentation/
            ├── controllers/   # Riverpod providers / state notifiers
            ├── pages/         # Screen widgets
            └── widgets/       # Reusable UI components
```

State is managed with **Riverpod 2.x**. Every feature has its own set of providers, keeping state isolated and preventing cross-feature side effects.

### 5.2 Features & Screens

**Authentication flow:**
- Splash screen with auto-login check
- Onboarding / welcome screens for new users
- Registration with email + phone
- Email and phone OTP verification
- Login with email + password
- Forgot password via OTP (mobile-optimized flow)
- OTP entry and reset password screens
- Profile completion (name, age, gender, language preference)
- Guest mode (limited access without an account)
- Backend URL setup page (shown on first launch on a new network)

**Home Dashboard** (`/home`):
- Overview cards linking to all major features
- Quick-access buttons for emergency and chatbot
- Health summary from the PHR module
- Connectivity status indicator

**Medical Chatbot** (`/chatbot`):
- Chatbot home screen listing all past conversations
- Chat screen with real-time message bubbles
- Supports text and voice input
- Markdown rendering for formatted responses
- Loading/typing indicator
- Offline mode automatically falls back to FAISS responses

**Symptom Checker** (`/symptom-checker`):
- Multi-select symptom input (categorized by body system)
- Patient info form (age, gender, duration, severity)
- Results screen with disease predictions, confidence scores, and recommendations

**Emergency** (`/emergency`):
- Emergency home with quick-access guides and SOS button
- Emergency assessment form (symptoms + patient info)
- Assessment result screen with risk level, first-aid steps, and hospital recommendations
- Emergency contacts management

**Health Records** (`/records`):
- Dashboard summary screen
- Medical profile editor (blood group, allergies, chronic conditions)
- Medical history list and create/edit forms
- Prescriptions list with file upload support
- Medical images gallery with upload
- Unified medical timeline

**Health Education** (`/health-education`):
- Article list with category filtering and search
- Article detail with markdown rendering and reading-progress tracking
- Bookmarks screen

**Offline Module** (`/offline`):
- Offline dashboard showing cached data status
- Offline symptom checker (uses local model)
- Offline chatbot (uses FAISS knowledge base)
- Sync center showing history and manual sync trigger

**Other screens:**
- Nearby healthcare facilities (`/nearby-healthcare`)
- Disease prediction history (`/history`)
- User profile (`/profile`)
- App settings (`/settings`)

### 5.3 Offline Mode

Offline support uses a two-layer approach:

1. **Hive on-device storage** — all chatbot conversations, symptom check history, health records, and education articles are cached locally using Hive (a fast key-value NoSQL database for Flutter).
2. **FAISS knowledge base** — a pre-built vector index of medical knowledge is bundled in `assets/offline/` and used by the chatbot when there is no internet connection.
3. **Sync center** — when connectivity is restored, the app syncs pending local changes to the server using the `/offline/sync/` endpoint.
4. **Connectivity detection** — `connectivity_plus` and `internet_connection_checker_plus` are used to detect network state changes in real time and switch between online and offline modes seamlessly.

### 5.4 Key Packages

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `hive` + `hive_flutter` | Local database (offline cache) |
| `speech_to_text` | On-device speech recognition |
| `flutter_tts` | Text-to-speech playback |
| `record` | Audio recording for voice messages |
| `audioplayers` | Audio playback for TTS responses |
| `connectivity_plus` | Network state detection |
| `internet_connection_checker_plus` | Actual internet reachability check |
| `shared_preferences` | Persistent non-sensitive settings (backend URL, etc.) |
| `flutter_secure_storage` | Encrypted token storage (keychain/keystore) |
| `flutter_animate` | UI animations |
| `flutter_markdown` | Render chatbot markdown responses |
| `lottie` | JSON-based loading and animation assets |
| `shimmer` | Loading skeleton placeholders |
| `cached_network_image` | Cached profile and article images |
| `file_picker` | Pick prescription/image files for upload |
| `permission_handler` | Microphone and storage permissions |
| `intl` | Date/time formatting and internationalization |
| `uuid` | Client-side UUID generation for offline records |

---

## 6. Admin Dashboard — Flutter Web

Directory: `admin_dashboard/`

A Flutter Web application for platform administrators and healthcare managers.

**All 11 phases complete:**

| Module | Route | Purpose |
|---|---|---|
| `authentication` | `/login` | Admin login with JWT, session restore, auto-redirect |
| `dashboard` | `/dashboard` | Platform overview: 8 KPI cards, 4 trend charts, recent activity |
| `users` | `/users` | User list, search, activate/deactivate, role change, delete |
| `emergency` | `/emergency` | Emergency assessment monitoring, risk cards, SOS tracking |
| `chatbot` | `/chatbot` | Conversation monitoring, language distribution, emergency flags |
| `education` | `/education` | Health article CRUD, publish/draft toggle, category filters |
| `analytics` | `/analytics` | Symptom analytics: frequency charts, risk/age/gender distribution |
| `datasets` | `/datasets` | AI dataset version management, activate/deactivate |
| `reports` | `/reports` | Period-selectable charts: registrations, risk, chatbot, emergency |
| `logs` | `/logs` | Admin action audit trail with module/severity filters |
| `settings` | `/settings` | System settings editor (grouped), danger zone |

**Shared infrastructure:**
- Collapsible sidebar with 11 nav items
- Top bar with notifications bell (badge + dropdown panel), dark mode toggle, user chip
- Shimmer loading states, fade page transitions, responsive grid layouts
- 51 unit tests across 5 test files (all passing)

The dashboard communicates with the same FastAPI backend using admin-scoped JWT tokens. Routing is handled by `go_router` and the theme is in `lib/core/theme.dart`.

---

## 7. AI Models Layer

Directory: `ai_models/`

Standalone Python code for training, evaluating, and serving the ML and AI components.

### Chatbot Engine (`ai_models/chatbot/`)
- `chatbot_engine.py` — Core engine orchestrating online (LLM) and offline (FAISS) modes
- `conversation_manager.py` — Tracks conversation context, turn history, and language state
- `prompt_templates.py` — System prompts and instruction templates for different LLM providers
- `response_generator.py` — Post-processes raw LLM output into structured chat responses

### Model Configuration (`ai_models/configs/`)
- `model_config.yaml` — Model IDs, token limits, temperature settings, fallback order
- `inference_config.yaml` — Inference parameters, batch sizes, caching settings

### Saved Models (`ai_models/saved_models/`)
- `symptom_checker/` — Trained scikit-learn classification model (joblib format) with the 230-feature symptom vocabulary
- `faiss_index/` — Pre-built FAISS vector index (`index.faiss` + metadata) for semantic search on the medical knowledge base

### Scripts (`ai_models/scripts/`)
- `build_faiss_index.py` — Reads medical datasets, generates embeddings using `sentence-transformers/all-MiniLM-L6-v2`, and builds the FAISS index. Runs once; takes 5–20 minutes depending on hardware.

### Datasets (`ai_models/datasets/`)
Medical Q&A datasets and symptom-disease training data used for model training and index building.

---

## 8. Environment Configuration

Copy `.env.example` to `backend/.env` and fill in the required values.

```env
# App
APP_NAME=AI Healthcare Assistant API
ENVIRONMENT=development        # development | production
DEBUG=true
API_PREFIX=/api/v1
APP_BASE_URL=http://localhost:8000

# Database (leave blank in dev to use SQLite automatically)
DATABASE_URL=postgresql+asyncpg://postgres:YOUR_PASSWORD@localhost:5432/healthcare_db
MONGODB_URL=mongodb://localhost:27017
REDIS_URL=redis://localhost:6379/0

# JWT
JWT_SECRET_KEY=your-long-random-secret-key
JWT_ALGORITHM=HS256

# LLM (set at least one)
CHATBOT_LLM_PROVIDER=gemini             # gemini | openai | anthropic
CHATBOT_LLM_API_KEY=your-api-key
OPENAI_API_KEY=your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key

# Voice
WHISPER_MODEL_SIZE=base                 # tiny | base | small | medium
VOICE_STT_ENGINE=google                 # whisper | google | vosk
VOICE_TTS_ENGINE=edge                   # edge | gtts | pyttsx3

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=noreply@healthcareai.com

# SMS (Twilio)
SMS_PROVIDER=mock                       # mock | twilio
TWILIO_ACCOUNT_SID=your-sid
TWILIO_AUTH_TOKEN=your-token
TWILIO_FROM_NUMBER=+1234567890

# Firebase (optional)
FIREBASE_PROJECT_ID=your-project-id

# CORS
CORS_ORIGINS=*                          # comma-separated URLs in production
```

In **development**, `DATABASE_URL` can be left blank — the app will automatically use `sqlite+aiosqlite:///./app.db`. In development mode CORS also allows any `localhost` or `127.0.0.1` origin on any port, which is required for Flutter Web and the admin dashboard.

---

## 9. Getting Started

### Prerequisites

| Tool | Version | Check |
|---|---|---|
| Python | 3.11+ | `python --version` |
| Flutter SDK | 3.x | `flutter --version` |
| PostgreSQL | 14+ (optional in dev) | `psql --version` |
| FFmpeg | any | `ffmpeg -version` (needed for audio conversion) |

### Option A — One-click startup (Windows)

```batch
start_all.bat
```

This script will:
1. Check Python and Flutter installations
2. Create and activate a virtual environment (`.venv`)
3. Install all Python dependencies from `requirements.txt`
4. Create `backend/.env` from `.env.example` if it doesn't exist
5. Build the FAISS knowledge index (first run only — takes 5–20 min)
6. Start the FastAPI server at `http://0.0.0.0:8000`

### Option B — Manual setup

**Backend:**
```powershell
# From project root
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Create and configure backend/.env
copy .env.example backend\.env
# Edit backend\.env — set JWT_SECRET_KEY and CHATBOT_LLM_API_KEY at minimum

# Build FAISS index (first time only)
python ai_models\scripts\build_faiss_index.py

# Start the server
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Use `--host 0.0.0.0` (not `localhost`) so physical Android/iOS devices on the same WiFi can reach the server.

**Mobile app:**
```powershell
cd mobile_app
flutter pub get
flutter run
```

On first launch on a new device/network, the app displays a setup screen where you enter the backend URL (e.g., `http://192.168.x.x:8000`). This URL is saved with `shared_preferences` so you only need to enter it once.

**Admin dashboard:**
```powershell
cd admin_dashboard
flutter pub get
flutter run -d chrome
```

### Verify the backend is running

```
GET http://localhost:8000/health
→ { "status": "ok", "version": "1.0.0" }
```

Swagger UI: `http://localhost:8000/docs`

ReDoc: `http://localhost:8000/redoc`

---

## 10. API Reference

All API endpoints are under `/api/v1/`. Interactive documentation is auto-generated by FastAPI.

| Module | Base path | Endpoints |
|---|---|---|
| Auth | `/api/v1/auth` | 17 endpoints |
| Users | `/api/v1/users` | Profile management |
| Medical Chatbot | `/api/v1/chatbot` | 6 endpoints |
| Symptom Checker | `/api/v1/symptom-checker` | 7 endpoints |
| Emergency | `/api/v1/emergency` | 9 endpoints |
| Health Records | `/api/v1/health-records` | 15 endpoints |
| Health Education | `/api/v1/education` | 11 endpoints |
| Voice Assistant | `/api/v1/voice` | 5 endpoints |
| Offline Sync | `/api/v1/offline` | 7 endpoints |
| Notifications | `/api/v1/notifications` | 7 endpoints |
| Admin Dashboard | `/api/v1/admin` | 36 endpoints |

All authenticated endpoints require a `Bearer` token in the `Authorization` header:

```
Authorization: Bearer <access_token>
```

Access tokens are obtained from `POST /api/v1/auth/login` and expire after 15 minutes. Use `POST /api/v1/auth/refresh` with a refresh token to get a new access token.

---

## 11. Bug Fixes & Known Issues Resolved

Ten bugs were identified and fixed across the backend and mobile app. These are documented in `.kiro/specs/ai-healthcare-full-fix/design.md`.

| # | Area | Bug | Fix |
|---|---|---|---|
| C1 | Backend | UUID user IDs were force-cast to `int` in the chatbot dependency, causing `ValueError` on every request | Removed the `int()` cast — IDs are now passed as strings throughout |
| C2 | Backend | Chatbot DB models were never imported at startup, so their tables were never created | Added chatbot model imports to the startup table-creation hook |
| C3 | Mobile | Backend IP was hardcoded (`192.168.18.26`), making the app unusable on any other network | Added `NetworkConfig` service + `BackendSetupPage` to configure and persist the URL at runtime |
| C4 | Mobile | Auth tokens were kept only in memory; users were logged out every app restart | Migrated token storage to `flutter_secure_storage` (device keychain/keystore) |
| C5 | Mobile | `completeProfile` silently swallowed 422 validation errors and retried with PUT | Error handling was added to surface 422 responses correctly |
| C6 | Backend | Symptom checker inserted its `sys.path` entry at module import time, before the path was validated | Moved the path insertion inside the `_load_model` method |
| C7 | Mobile | Symptom checker page had no 401 handler; expired tokens caused a silent blank screen | Added a 401 handler that redirects to the login screen |
| C8 | Backend | LLM service had no fallback when the API key was invalid or the service was unreachable | Added try/except around all LLM calls with automatic fallback to FAISS offline mode |
| C9 | Backend | Chatbot router was registered without the shared `/api/v1` prefix | Fixed the router registration to use `settings.api_prefix` like all other routers |
| C10 | Mobile | Six packages required by existing code were missing from `pubspec.yaml` | Added all missing packages: `flutter_secure_storage`, `flutter_markdown`, `lottie`, `shimmer`, `internet_connection_checker_plus`, `record` |

---

## Notes

- The symptom checker model file must be present in `ai_models/saved_models/symptom_checker/` before starting the backend. If it is not found, the `/symptom-checker/predict` endpoint returns HTTP 503.
- The FAISS index must be built before the offline chatbot and voice chat features work. Run `python ai_models/scripts/build_faiss_index.py` once before first use.
- In production, set `ENVIRONMENT=production` in `.env`. This disables debug mode, switches the CORS policy to use the explicit `CORS_ORIGINS` list, and expects PostgreSQL instead of SQLite.
- Firebase Cloud Messaging is configured via `FIREBASE_PROJECT_ID` but is optional. If not set, push notifications are skipped.
