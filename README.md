# AI Healthcare Assistant

<div align="center">

**An AI-powered full-stack healthcare platform designed for rural and semi-urban South Asia**

*Combining medical AI, multilingual voice support, offline-first design, and comprehensive health management into one unified system*

---

[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.111-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-2.0_Async-CC2927?style=for-the-badge)](https://www.sqlalchemy.org/)
[![OpenRouter](https://img.shields.io/badge/OpenRouter-9_Free_Models-FF6B35?style=for-the-badge)](https://openrouter.ai/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-00B4D8?style=for-the-badge)](https://riverpod.dev/)
[![License](https://img.shields.io/badge/License-MIT-27AE60?style=for-the-badge)](LICENSE)

</div>

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [High-Level System Architecture](#2-high-level-system-architecture)
3. [Repository Structure](#3-repository-structure)
4. [Tech Stack](#4-tech-stack)
5. [Module 1 — Authentication & Authorization](#5-module-1--authentication--authorization)
6. [Module 2 — Medical Chatbot](#6-module-2--medical-chatbot)
7. [Module 3 — Symptom Checker & Disease Prediction](#7-module-3--symptom-checker--disease-prediction)
8. [Module 4 — Emergency Assessment & SOS](#8-module-4--emergency-assessment--sos)
9. [Module 5 — Personal Health Records (PHR)](#9-module-5--personal-health-records-phr)
10. [Module 6 — Health Education](#10-module-6--health-education)
11. [Module 7 — Voice Assistant](#11-module-7--voice-assistant)
12. [Module 8 — Offline Sync](#12-module-8--offline-sync)
13. [Module 9 — Notifications & Feedback](#13-module-9--notifications--feedback)
14. [Mobile App — Flutter](#14-mobile-app--flutter)
15. [Admin Dashboard — Flutter Web](#15-admin-dashboard--flutter-web)
16. [AI Models Layer](#16-ai-models-layer)
17. [Environment Configuration](#17-environment-configuration)
18. [Getting Started](#18-getting-started)
19. [API Reference Summary](#19-api-reference-summary)
20. [Network & WiFi Configuration](#20-network--wifi-configuration)
21. [Bug Fixes & Resolved Issues](#21-bug-fixes--resolved-issues)
22. [Notes & Production Checklist](#22-notes--production-checklist)

---

## 1. Project Overview

### Background & Problem Statement

Access to quality healthcare information remains a significant challenge across rural South Asia. Millions of people in India and Nepal lack proximity to qualified doctors, cannot interpret medical symptoms, and have no reliable way to manage personal health records or respond correctly to medical emergencies. Language barriers further compound the problem — most digital health tools support only English, excluding the majority of the target population.

The **AI Healthcare Assistant** is a full-stack platform built to bridge this gap. It is designed to run on an Android smartphone with intermittent internet connectivity, support 9+ regional languages, and provide clinically informed guidance without replacing a professional doctor.

### What This Platform Does

| Capability | Description |
|---|---|
| **Medical Chatbot** | LLM-powered conversational assistant for health questions, symptom discussion, and general medical guidance in the user's own language |
| **Symptom Checker** | ML model trained on 230 symptoms across 13 body systems that predicts likely diseases with confidence scores and risk levels |
| **Emergency Assessment** | AI-driven triage tool that scores emergency severity, provides step-by-step first aid, and sends SOS alerts to emergency contacts |
| **Personal Health Records** | Secure on-device and server-side vault for prescriptions, medical images, history entries, and a unified chronological medical timeline |
| **Health Education** | Curated multilingual article library with category browsing, full-text search, bookmarks, and reading-history-based personalised recommendations |
| **Voice Assistant** | Full Speech-to-Text → AI → Text-to-Speech pipeline; users can speak queries in Hindi, Nepali, English, or Bhojpuri and hear responses |
| **Offline Mode** | 100-topic keyword-based offline chatbot engine (built into Flutter app) covers emergencies, diseases, medicines, first aid, and more in 4 languages — no internet required; auto-detects connectivity and switches suggestion chips accordingly |
| **Admin Dashboard** | Flutter Web management portal for platform administrators with analytics, user management, content moderation, dataset versioning, and audit trails |

### Target Users

- **Patients** in rural and semi-urban areas of India and Nepal who need accessible health guidance
- **Rural health workers** (ASHA workers, ANMs) who support communities without on-site doctors
- **Doctors** who want to review patient-submitted health records and symptom check history
- **Platform administrators** who manage content, monitor usage, and maintain system health

### Supported Languages

English · Hindi (`hi`) · Nepali (`ne`) · Bhojpuri (`bh`) · Bengali · Tamil · Telugu · Marathi · Gujarati

The system auto-detects the user's language from their input and responds in the same language.

### Key Design Principles

1. **Offline-first** — Core features (chatbot, symptom checker, education) work without internet
2. **Safe AI** — Every response ends with a disclaimer; diagnosis and prescription are explicitly prohibited
3. **Privacy-conscious** — All tokens are encrypted at rest; anonymous emergency assessments are supported
4. **Graceful degradation** — LLM → 100-topic offline keyword engine fallback, STT tier cascade, SQLite → PostgreSQL upgrade path
5. **Multilingual by default** — Language auto-detection on every input, not a toggle

---

## 2. High-Level System Architecture

The platform is a three-tier architecture: Flutter clients → FastAPI backend → AI/database layer. All communication is JSON over REST. The backend is fully async using SQLAlchemy 2.0's async engine.

```mermaid
graph TB
    subgraph Mobile["📱 Mobile App  (Flutter / Android / iOS)"]
        MA_AUTH[Authentication]
        MA_CHAT[Medical Chatbot]
        MA_SYM[Symptom Checker]
        MA_EMR[Emergency]
        MA_PHR[Health Records]
        MA_EDU[Health Education]
        MA_VOICE[Voice Assistant]
        MA_OFFLINE[Offline Module]
    end

    subgraph Web["🖥️ Admin Dashboard  (Flutter Web)"]
        AD_DASH[Dashboard & KPIs]
        AD_USERS[User Management]
        AD_ANALYTICS[Analytics]
        AD_CONTENT[Content Management]
        AD_LOGS[Audit Logs]
    end

    subgraph API["⚙️ Backend  (FastAPI / Python 3.11)"]
        direction TB
        GW["/api/v1  — API Gateway\nCORS · JWT Middleware · Static Files"]
        subgraph Modules
            M_AUTH[auth]
            M_USERS[users]
            M_CHAT[medical_chatbot]
            M_SYM[symptom_checker]
            M_EMR[emergency]
            M_PHR[health_records]
            M_EDU[health_education]
            M_VOICE[voice]
            M_SYNC[offline_sync]
            M_NOTIF[notifications]
            M_FEED[feedback]
            M_ADMIN[admin]
        end
    end

    subgraph AI["🤖 AI Layer"]
        OR["OpenRouter\n9 Free LLMs\n(primary)"]
        GEM["Google Gemini\n(fallback 1)"]
        GROQ["Groq / LLaMA\n(fallback 2)"]
        FAISS["FAISS Index\n(offline)"]
        ML["scikit-learn\nSymptom Model"]
        WHISPER["OpenAI Whisper\nSTT (local)"]
        EDGETTS["Edge TTS\nNeural Voices"]
    end

    subgraph Data["💾 Data Layer"]
        SQLITE["SQLite\n(development)"]
        PG["PostgreSQL\n(production)"]
        REDIS["Redis\nCache & Rate Limit"]
        HIVE["Hive\nOn-Device Cache"]
        FS["File System\n/uploads/"]
    end

    Mobile -->|"HTTP/REST + Bearer JWT"| GW
    Web -->|"HTTP/REST + Bearer JWT"| GW
    GW --> Modules
    M_CHAT --> OR & GEM & GROQ & FAISS
    M_SYM --> ML
    M_VOICE --> WHISPER & EDGETTS & M_CHAT
    Modules --> SQLITE & PG
    M_CHAT --> REDIS
    M_PHR --> FS
    MA_OFFLINE <-->|"Hive R/W"| HIVE
    M_SYNC <-->|"Bidirectional sync"| HIVE
```

### Request Lifecycle

```mermaid
sequenceDiagram
    participant C as Client (Flutter)
    participant MW as FastAPI Middleware
    participant AUTH as Auth Dependency
    participant SVC as Service Layer
    participant DB as Database (SQLAlchemy async)
    participant AI as AI Provider

    C->>MW: HTTP Request + Authorization: Bearer <token>
    MW->>MW: CORS check
    MW->>AUTH: Validate JWT → extract user_id + role
    AUTH->>DB: Verify token not revoked
    DB-->>AUTH: Token valid
    AUTH-->>MW: user_id = "uuid-string"
    MW->>SVC: Process request (user_id, payload)
    SVC->>DB: Async DB query
    DB-->>SVC: Result
    SVC->>AI: Optional: LLM / ML call
    AI-->>SVC: AI response
    SVC-->>MW: Response object
    MW-->>C: HTTP 200 JSON
```

---

## 3. Repository Structure

```
ai_healthcare_assistant/                    ← Project root
│
├── backend/                                ← FastAPI Python backend
│   ├── app/
│   │   ├── main.py                         ← App factory (create_app)
│   │   ├── auth/                           ← JWT, OTP, RBAC, sessions
│   │   │   ├── models.py                   ← 10 SQLAlchemy ORM models
│   │   │   ├── routes.py                   ← 17 auth endpoints
│   │   │   ├── services.py
│   │   │   ├── dependencies.py             ← get_current_user, require_role
│   │   │   ├── schemas.py
│   │   │   ├── password.py                 ← bcrypt helpers
│   │   │   ├── constants.py                ← Role enum
│   │   │   └── repository.py
│   │   ├── users/                          ← User profile, address, medical info
│   │   ├── medical_chatbot/
│   │   │   ├── api/
│   │   │   │   ├── routes.py               ← 8 chatbot endpoints
│   │   │   │   ├── controller.py
│   │   │   │   └── dependencies.py
│   │   │   ├── repositories/
│   │   │   │   ├── conversation_repository.py
│   │   │   │   └── feedback_repository.py
│   │   │   ├── schemas/
│   │   │   │   ├── request.py
│   │   │   │   └── response.py
│   │   │   ├── services/
│   │   │   │   ├── chatbot_service.py      ← Main orchestrator
│   │   │   │   └── gemini_service.py       ← OpenRouter-first AI provider
│   │   │   ├── database/
│   │   │   │   └── models.py               ← Conversation, Message, Feedback, Session
│   │   │   └── utils/
│   │   │       ├── constants.py
│   │   │       ├── exceptions.py
│   │   │       ├── helpers.py
│   │   │       └── logger.py
│   │   ├── symptom_checker/
│   │   │   ├── routes.py                   ← 7 endpoints
│   │   │   ├── service.py                  ← Model loading + prediction logic
│   │   │   ├── schemas.py
│   │   │   └── models.py                   ← SymptomCheckHistory ORM
│   │   ├── emergency/
│   │   │   ├── routes.py                   ← 9 endpoints
│   │   │   ├── service.py
│   │   │   ├── schemas.py
│   │   │   └── models.py                   ← EmergencyAssessment, EmergencyContact
│   │   ├── health_records/
│   │   │   ├── routes.py                   ← 15 endpoints
│   │   │   ├── service.py
│   │   │   ├── schemas.py
│   │   │   └── models.py                   ← UserMedicalProfile, MedicalHistory,
│   │   │                                      Prescription, MedicalImage, TimelineEvent
│   │   ├── health_education/
│   │   │   ├── routes.py                   ← 12 endpoints
│   │   │   ├── services.py                 ← ArticleService, BookmarkService,
│   │   │   │                                  DashboardService, SeedService
│   │   │   ├── schemas.py
│   │   │   └── models.py
│   │   ├── voice/
│   │   │   ├── routes.py                   ← 5 endpoints
│   │   │   ├── stt_service.py              ← Whisper → Google → Vosk cascade
│   │   │   └── tts_service.py              ← Edge TTS → gTTS → pyttsx3 cascade
│   │   ├── offline_sync/
│   │   │   ├── routes.py                   ← 6 endpoints
│   │   │   └── service.py
│   │   ├── notifications/
│   │   ├── feedback/
│   │   ├── admin/
│   │   │   ├── routes.py                   ← 60+ admin endpoints
│   │   │   ├── service.py                  ← 10 admin service classes
│   │   │   ├── schemas.py
│   │   │   └── seed.py                     ← Default data seeder
│   │   ├── config/
│   │   │   └── settings.py                 ← Pydantic BaseSettings from .env
│   │   ├── core/
│   │   │   └── startup.py                  ← on_startup / on_shutdown hooks
│   │   ├── database/
│   │   │   └── connection.py               ← Async engine + session factory
│   │   └── uploads/                        ← Static files (profile images, PDFs)
│   ├── TESTING_GUIDE.md
│   ├── QUICK_START.md
│   ├── get_models.py                       ← Downloads AI model files
│   └── .env                                ← Runtime secrets (git-ignored)
│
├── mobile_app/                             ← Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/
│   │   │   └── api_config.dart             ← WiFi IP / emulator URL resolver
│   │   ├── constants/
│   │   │   └── api_constants.dart          ← All API path strings
│   │   ├── core/
│   │   │   ├── api/                        ← Dio HTTP client + interceptors
│   │   │   ├── local_db/
│   │   │   │   └── local_db_service.dart   ← Hive box management
│   │   │   └── network/
│   │   │       └── network_config.dart     ← Persisted backend URL
│   │   └── features/
│   │       ├── authentication/             ← Splash → Onboarding → Auth screens
│   │       ├── home/                       ← Home dashboard
│   │       ├── medical_chatbot/            ← Chat screens + voice input
│   │       ├── disease_prediction/         ← Symptom selector + results
│   │       ├── emergency/                  ← Assessment + SOS + contacts
│   │       ├── health_records/             ← PHR screens
│   │       ├── health_education/           ← Articles + bookmarks
│   │       ├── profile/                    ← User profile editor
│   │       └── settings/
│   ├── assets/
│   │   ├── animations/                     ← Lottie JSON files
│   │   ├── images/                         ← logo.png, illustrations
│   │   ├── audio/                          ← UI sound effects
│   │   └── offline/
│   │       ├── chatbot/                    ← Bundled FAISS index
│   │       └── education/                  ← Cached article snapshots
│   └── pubspec.yaml
│
├── admin_dashboard/                        ← Flutter Web admin portal
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/
│   │   │   └── app.dart                    ← MaterialApp root + go_router
│   │   ├── core/
│   │   │   ├── api.dart                    ← Dio singleton + token interceptor
│   │   │   ├── constants.dart              ← Backend host, timeouts
│   │   │   ├── models.dart                 ← Shared data models
│   │   │   ├── router.dart                 ← go_router route definitions
│   │   │   └── theme.dart                  ← Light/dark theme
│   │   ├── shared/
│   │   │   └── widgets/
│   │   │       ├── sidebar.dart            ← Collapsible 11-item nav
│   │   │       ├── top_bar.dart            ← Notifications + dark mode toggle
│   │   │       └── data_table_card.dart    ← Reusable paginated table
│   │   └── features/
│   │       ├── authentication/
│   │       ├── dashboard/
│   │       ├── users/
│   │       ├── emergency/
│   │       ├── chatbot/
│   │       ├── education/
│   │       ├── analytics/
│   │       ├── dataset/
│   │       ├── reports/
│   │       ├── logs/
│   │       ├── settings/
│   │       ├── doctors/
│   │       ├── health_records/
│   │       ├── profile/
│   │       └── feedback/
│   └── pubspec.yaml
│
├── ai_models/                              ← ML training + offline assets
│   ├── chatbot/
│   ├── configs/
│   ├── datasets/
│   ├── scripts/
│   │   └── build_faiss_index.py
│   ├── saved_models/
│   │   ├── symptom_checker/                ← trained.joblib + vocabulary.json
│   │   └── faiss_index/                    ← index.faiss + metadata.json
│   └── tests/
│
├── .env.example                            ← All env vars documented
├── requirements.txt                        ← Unified Python deps
├── activate_venv.ps1
├── start_all.bat                           ← One-click Windows start
├── start_admin_dashboard.bat
└── README.md
```

---

## 4. Tech Stack

### Backend

| Category | Technology | Version | Notes |
|---|---|---|---|
| Web framework | FastAPI | 0.111 | Async, OpenAPI auto-docs |
| ASGI server | Uvicorn | latest | Hot-reload in dev |
| ORM | SQLAlchemy | 2.0 (async) | Fully non-blocking DB layer |
| Database — dev | SQLite via `aiosqlite` | — | Zero config, auto-created |
| Database — prod | PostgreSQL via `asyncpg` | 14+ | Set `DATABASE_URL` in `.env` |
| Cache & rate limiting | Redis | 7+ | Optional; graceful skip if absent |
| Migrations | Alembic | latest | Production schema versioning |
| LLM — primary | OpenRouter | Free tier | 9-model auto-failover chain |
| LLM — fallback 1 | Google Gemini | 2.0-flash | Set `CHATBOT_LLM_API_KEY` |
| LLM — fallback 2 | Groq / LLaMA | 3.3-70b | Set `CHATBOT_GROQ_API_KEY` |
| Embeddings | sentence-transformers | all-MiniLM-L6-v2 | For FAISS index building |
| Vector search | FAISS | latest | Offline knowledge base |
| Disease prediction | scikit-learn | latest | Trained joblib model |
| Numerical compute | NumPy, pandas, SciPy | latest | Feature engineering |
| STT — tier 1 | OpenAI Whisper (local) | base model | Works offline |
| STT — tier 2 | Google Speech Recognition | — | Free, requires internet |
| STT — tier 3 | Vosk | — | Fully offline, lower accuracy |
| TTS — tier 1 | Microsoft Edge TTS | — | Neural voices, `en-IN`/`hi-IN`/`ne-NP` |
| TTS — tier 2 | gTTS | — | Google Translate TTS |
| TTS — tier 3 | pyttsx3 | — | System voice, fully offline |
| Translation | deep-translator | — | Google Translate wrapper |
| Language detection | langdetect | — | Auto-detect input language |
| Auth | JWT (HS256) + bcrypt | — | Access 15 min, refresh 30 days |
| Email | SMTP via `aiosmtplib` | — | Mock provider in dev |
| SMS | Twilio | — | Mock provider in dev |
| HTTP clients | httpx, aiohttp | — | Async external calls |
| Settings | Pydantic `BaseSettings` | 2.x | Typed env var loading |

### Mobile App

| Category | Technology | Version |
|---|---|---|
| Framework | Flutter | 3.x (Dart SDK ≥ 3.3.0) |
| State management | flutter_riverpod | 2.5.1 |
| HTTP | dio | 5.4.3 |
| Local storage | hive + hive_flutter | 2.2.3 |
| Secure storage | flutter_secure_storage | latest |
| Voice STT | speech_to_text | 7.3.0 |
| Voice TTS | flutter_tts | 4.0.2 |
| Audio record | record | 7.1.1 |
| Audio play | audioplayers | 6.0.0 |
| Network check | connectivity_plus | 6.0.3 |
| Internet check | internet_connection_checker_plus | 2.5.1 |
| Markdown render | flutter_markdown | 0.7.3 |
| Animations | flutter_animate | 4.5.0 |
| Lottie JSON | lottie | 3.1.2 |
| Shimmer skeletons | shimmer | 3.0.0 |
| File picker | file_picker | 8.1.2 |
| Permissions | permission_handler | 11.3.1 |
| SVG | flutter_svg | 2.0.10 |
| i18n / dates | intl | 0.19.0 |
| UUID generation | uuid | 4.4.2 |

### Admin Dashboard

| Category | Technology | Version |
|---|---|---|
| Framework | Flutter Web | 3.x |
| HTTP + interceptors | dio | 5.x |
| Routing | go_router | latest |
| Secure token storage | flutter_secure_storage | latest |
| Charts | fl_chart | latest |
| Animations | flutter_animate | 4.x |
| Date formatting | intl | 0.19.0 |

---

---

## 5. Module 1 — Authentication & Authorization

### Overview

The authentication module is the security backbone of the entire platform. It provides a complete identity management system with JWT-based stateless authentication, multi-factor verification via OTP, granular role-based access control, full session management, and a mobile-optimised password recovery flow. Every other module depends on this one for identifying who is making a request and what they are allowed to do.

**Module path:** `backend/app/auth/`

### Key Design Decisions

| Decision | Rationale |
|---|---|
| **UUID string IDs** (not auto-increment integers) | Prevents enumeration attacks and works correctly across distributed systems |
| **Access token TTL = 15 min, Refresh token TTL = 30 days** | Short-lived access tokens limit blast radius of token theft; long-lived refresh tokens keep mobile users logged in |
| **Token hashes stored in DB** | Individual sessions and tokens can be revoked server-side — a compromised token can be invalidated without rotating the secret key |
| **OTP stored as bcrypt hash** | Raw OTP codes are never stored; even if the DB is leaked, codes cannot be read |
| **Email + phone verified separately** | Allows independent verification of each contact method without coupling them |
| **Mock providers in development** | SMTP and SMS are replaced by a mock that logs to console, so no external accounts are needed during development |

### Database Schema

```mermaid
erDiagram
    users {
        string id PK "UUID"
        string full_name
        string email UK
        string phone UK
        string password_hash
        string role "patient|doctor|admin|super_admin"
        string language "en|hi|ne|bh"
        bool is_active
        bool email_verified
        bool phone_verified
        datetime created_at
        datetime updated_at
        datetime last_login
    }
    refresh_tokens {
        string id PK
        string user_id FK
        string token_hash
        string device_info
        string ip_address
        bool is_revoked
        datetime expires_at
        datetime last_used_at
    }
    otp_codes {
        string id PK
        string user_id FK
        string purpose "phone_verify|password_reset"
        string code_hash
        int attempts
        bool is_used
        datetime expires_at
    }
    email_verification {
        string id PK
        string user_id FK
        string token_hash
        bool is_used
        datetime expires_at
    }
    password_reset {
        string id PK
        string user_id FK
        string token_hash
        bool is_used
        datetime expires_at
    }
    user_sessions {
        string id PK
        string user_id FK
        string refresh_token_id FK
        string device_info
        string ip_address
        bool is_active
        datetime expires_at
        datetime last_active_at
    }
    roles {
        string id PK
        string name UK
    }
    permissions {
        string id PK
        string name UK
    }
    role_permissions {
        string id PK
        string role_id FK
        string permission_id FK
    }

    users ||--o{ refresh_tokens : "has"
    users ||--o{ otp_codes : "has"
    users ||--o{ email_verification : "has"
    users ||--o{ password_reset : "has"
    users ||--o{ user_sessions : "has"
    roles ||--o{ role_permissions : "grants"
    permissions ||--o{ role_permissions : "granted by"
```

### Role Hierarchy

```
super_admin  ← Full platform control (create admins, delete users, change system settings)
    │
  admin      ← Content moderation, user management, analytics (cannot change other admins)
    │
 doctor      ← View assigned patient records, read-only health data
    │
patient      ← Own data only (default role for all new registrations)
```

### Complete API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/auth/register` | Public | Create new user account |
| `POST` | `/auth/verify-email` | Public | Verify email using token from email link |
| `POST` | `/auth/resend-email-verification` | Public | Re-send verification email |
| `POST` | `/auth/send-phone-otp` | JWT | Send 6-digit OTP to registered phone |
| `POST` | `/auth/verify-phone` | JWT | Confirm phone with OTP |
| `POST` | `/auth/login` | Public | Authenticate, receive access + refresh tokens |
| `POST` | `/auth/refresh` | Public | Exchange refresh token for new token pair |
| `POST` | `/auth/logout` | JWT | Revoke current session |
| `POST` | `/auth/logout-all` | JWT | Revoke all sessions across all devices |
| `POST` | `/auth/forgot-password` | Public | Request password reset via email link |
| `POST` | `/auth/forgot-password-otp` | Public | Request reset via 6-digit OTP (mobile-friendly) |
| `POST` | `/auth/verify-reset-otp` | Public | Verify OTP → receive a short-lived reset token |
| `POST` | `/auth/reset-password` | Public | Set new password using reset token |
| `GET` | `/auth/me` | JWT | Get current authenticated user's profile |
| `GET` | `/auth/sessions` | JWT | List all active sessions for current user |
| `POST` | `/auth/sessions/revoke` | JWT | Revoke a specific session by ID |
| `POST` | `/auth/change-role` | Admin | Promote or demote a user's role |

### Authentication Flow (Full Sequence)

```mermaid
sequenceDiagram
    actor U as User
    participant APP as Mobile App
    participant API as Auth API
    participant DB as Database
    participant SMTP as Email/SMS Provider

    Note over U, SMTP: ── REGISTRATION ──
    U->>APP: Fill register form
    APP->>API: POST /auth/register {full_name, email, phone, password}
    API->>API: Hash password with bcrypt
    API->>DB: INSERT users (email_verified=false, phone_verified=false)
    API->>DB: INSERT email_verification {token_hash, expires=24h}
    API->>SMTP: Send verification email with token link
    API-->>APP: 201 Created

    Note over U, SMTP: ── EMAIL VERIFICATION ──
    U->>APP: Click email link
    APP->>API: POST /auth/verify-email {token}
    API->>DB: Find token_hash, check not used / not expired
    API->>DB: UPDATE users SET email_verified=true
    API->>DB: UPDATE email_verification SET is_used=true
    API-->>APP: 200 OK

    Note over U, SMTP: ── LOGIN ──
    U->>APP: Enter email + password
    APP->>API: POST /auth/login {email, password}
    API->>DB: Fetch user by email
    API->>API: bcrypt.verify(password, hash)
    API->>DB: INSERT refresh_tokens {token_hash, expires=30d}
    API->>DB: INSERT user_sessions {device_info, ip, expires=30d}
    API->>DB: UPDATE users SET last_login=now()
    API-->>APP: 200 {access_token (15min), refresh_token (30d)}
    APP->>APP: Store tokens in flutter_secure_storage

    Note over U, SMTP: ── SILENT REFRESH (background) ──
    APP->>API: POST /auth/refresh {refresh_token}
    API->>DB: Validate token_hash, check not revoked
    API->>DB: Issue new access + refresh tokens
    API-->>APP: 200 {new access_token, new refresh_token}

    Note over U, SMTP: ── FORGOT PASSWORD (OTP, mobile) ──
    U->>APP: Enter email on forgot-password screen
    APP->>API: POST /auth/forgot-password-otp {email}
    API->>DB: INSERT otp_codes {purpose=password_reset, code_hash, expires=10min}
    API->>SMTP: Send 6-digit OTP via SMS / email
    API-->>APP: 200 OTP sent

    U->>APP: Enter 6-digit OTP
    APP->>API: POST /auth/verify-reset-otp {email, otp}
    API->>DB: Validate code_hash, check attempts ≤ 3 and not expired
    API->>DB: Mark OTP as used
    API-->>APP: 200 {reset_token (5min)}

    U->>APP: Enter new password
    APP->>API: POST /auth/reset-password {reset_token, new_password}
    API->>API: Hash new password
    API->>DB: UPDATE users SET password_hash
    API->>DB: Revoke all existing refresh tokens for this user
    API-->>APP: 200 Password changed
```

### Token Storage on Mobile

The mobile app uses `flutter_secure_storage` which maps to the platform's native secure storage:

| Platform | Backing storage |
|---|---|
| Android | Android Keystore + EncryptedSharedPreferences |
| iOS | Keychain |

This means tokens survive app restarts, survive background kills, but are cleared on factory reset or app uninstall. They are never stored in plain `SharedPreferences`.

### Dependency Injection in FastAPI

Every protected endpoint uses one of these FastAPI dependencies:

```python
# Any authenticated user
CurrentUser = Annotated[UserModel, Depends(get_current_user)]

# Admin or Super Admin only
AdminUser = Annotated[UserModel, Depends(get_admin_user)]

# Role-specific guard
require_role(Role.SUPER_ADMIN)   # raises 403 if role doesn't match
```

---

---

## 6. Module 2 — Medical Chatbot

### Overview

The Medical Chatbot is the flagship feature of the platform. It is a conversational AI assistant that answers health questions, discusses symptoms, provides general medical guidance, and detects life-threatening emergencies — all in the user's native language. Unlike a simple FAQ bot, it maintains full conversation history across sessions, supports multi-turn dialogue, and operates fully without internet connectivity by falling back to a rich **100-topic keyword-based offline engine** built directly into the Flutter app.

**Module path:** `backend/app/medical_chatbot/` · `mobile_app/lib/features/medical_chatbot/data/datasources/chatbot_dummy_data.dart`

### Core Capabilities

| Capability | Detail |
|---|---|
| **Multi-turn conversation** | Loads last 20 messages as context on every request |
| **9-model LLM failover** | Automatically cycles through 9 free OpenRouter models on rate-limit (HTTP 429) |
| **Provider cascade** | OpenRouter → Google Gemini → Groq — tried in order at startup |
| **Offline keyword engine** | 100-topic structured response engine built into the Flutter app — no server call needed |
| **4-language offline keywords** | Every topic handler matches keywords in English, Hindi (हिंदी), Nepali (नेपाली), and Bhojpuri (भोजपुरी) |
| **100 offline suggestion chips** | When offline, all 100 health topics are shown as tappable suggestion chips |
| **Auto offline/online switching** | Suggestions and mode indicator switch automatically when connectivity changes |
| **Emergency detection** | Keyword scan runs *before* any LLM call — zero-latency emergency responses |
| **Language auto-detection** | Detects and responds in English, Hindi, Nepali, Bhojpuri, Bengali, and others |
| **Conversation persistence** | All messages stored in DB with timestamps, response time, confidence, token count |
| **Two chat modes** | `/chat` (full DB-persisted conversation) and `/simple-chat` (stateless, no DB writes) |

### AI Provider Architecture

```mermaid
flowchart TD
    START([Startup: _initialize]) --> A{CHATBOT_OPENROUTER_API_KEY\nset in .env?}
    A -- Yes --> B[Provider = OpenRouter\nModel = gemma-4-26b-a4b-it:free]
    A -- No --> C{CHATBOT_LLM_API_KEY\nset and starts with AIzaSy?}
    C -- Yes --> D[Provider = Gemini\nModel = gemini-2.0-flash]
    C -- No --> E{CHATBOT_GROQ_API_KEY set?}
    E -- Yes --> F[Provider = Groq\nModel = llama-3.3-70b-versatile]
    E -- No --> G[❌ RuntimeError\nNo AI provider configured]
    B --> READY([GeminiService ready])
    D --> READY
    F --> READY
```

### OpenRouter Free-Model Failover Chain

When any model returns HTTP 429 (rate limited), the service automatically tries the next model in this list. This is transparent to the user — they never see an error unless **all 9 models** are exhausted simultaneously.

| Priority | Model ID |
|---|---|
| 1 (primary) | `google/gemma-4-26b-a4b-it:free` |
| 2 | `google/gemma-4-31b-it:free` |
| 3 | `nvidia/nemotron-3-super-120b-a12b:free` |
| 4 | `nvidia/nemotron-3-nano-30b-a3b:free` |
| 5 | `nvidia/nemotron-nano-9b-v2:free` |
| 6 | `openai/gpt-oss-20b:free` |
| 7 | `nvidia/nemotron-3-ultra-550b-a55b:free` |
| 8 | `inclusionai/ling-3.0-tiny:free` |
| 9 | `poolside/laguna-xs-2.1:free` |

If all are exhausted: user receives *"All free AI models are currently rate-limited. Please wait 1 minute and try again."* — the windows reset within 60 seconds.

### Emergency Detection System

Emergency detection runs **before any API call** via a pure keyword scan. This guarantees sub-millisecond response for life-threatening situations regardless of LLM availability.

**Physical emergency keywords (sample):**
`chest pain · heart attack · cardiac arrest · can't breathe · severe bleeding · stroke · unconscious · seizure · overdose · snake bite · electric shock · सीने में दर्द · सांस नहीं · बेहोश`

**Mental health crisis keywords:**
`suicide · kill myself · want to die · end my life · self harm · cutting myself · खुदकुशी · आत्महत्या`

Emergency response includes:
- 🚨 Bold emergency banner
- Direct dial numbers: **108** (India ambulance) · **102** (Nepal) · **112** (Global)
- Step-by-step first-aid instructions while waiting for help
- For mental health: iCall (9152987821), Vandrevala Foundation (1860-2662-345)

### Complete API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/chatbot/chat` | JWT | Full persisted chat with conversation memory |
| `POST` | `/chatbot/simple-chat` | JWT | Stateless single-turn chat (no DB writes) |
| `GET` | `/chatbot/conversations` | JWT | List user's conversations (paginated, filterable) |
| `GET` | `/chatbot/conversations/{id}` | JWT | Full conversation with all messages |
| `DELETE` | `/chatbot/conversations/{id}` | JWT | Delete single conversation |
| `DELETE` | `/chatbot/conversations` | JWT | Delete all conversations for current user |
| `POST` | `/chatbot/feedback` | JWT | Rate conversation 1–5 stars + optional text |
| `GET` | `/chatbot/health` | Public | AI provider health check |

### Chat Request / Response Schema

**Request — POST /chatbot/chat**
```json
{
  "message": "I have had a headache for two days and feel feverish",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "language": "en"
}
```
*`conversation_id` is optional — omit to start a new conversation.*

**Response**
```json
{
  "assistant_message": "A 2-day headache with fever can have several causes...\n\n⚠️ I am an AI providing general health education only — always consult a qualified doctor.",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "message_id": 142,
  "timestamp": "2026-08-07T10:23:45.123Z",
  "confidence": 0.85,
  "emergency_detected": false,
  "recommendations": ["Consult a qualified healthcare professional for personalised medical advice."],
  "follow_up_questions": [],
  "response_time": 2.34,
  "tokens_used": 187
}
```

### Full Chat Pipeline (Flowchart)

```mermaid
flowchart TD
    A([User sends message]) --> B[Validate message\nmax 2000 chars]
    B --> C{Rate limit check\nmax 500 msgs/day}
    C -- Exceeded --> D[❌ RateLimitExceededException]
    C -- OK --> E{conversation_id\nprovided?}
    E -- Yes --> F[Load existing conversation\nfrom DB]
    E -- No --> G[Create new conversation\nAuto-generate title]
    F --> H{Belongs to\ncurrent user?}
    H -- No --> I[❌ 403 Access Denied]
    H -- Yes --> J
    G --> J[Check message count\n≤ MAX_CONVERSATION_MESSAGES]
    J -- Exceeded --> K[❌ ConversationLimitException]
    J -- OK --> L[Save user message to DB]
    L --> M[Load last 20 messages\nas context history]
    M --> N{Emergency keyword\ndetected?}
    N -- Yes --> O[Return hardcoded\nemergency response\nNO LLM CALL]
    N -- No --> P{GeminiService\ninitialized?}
    P -- No --> Q[Return 'AI not configured'\nerror message]
    P -- Yes --> R[Call GeminiService.chat]
    R --> S{Provider type?}
    S -- OpenRouter/Groq --> T[Build messages array\nwith system prompt + history]
    S -- Gemini --> U[Build plain-text prompt\nwith history]
    T --> V[Try model 1 of 9]
    V --> W{HTTP 429\nrate limited?}
    W -- Yes --> X{More models\nin failover list?}
    X -- Yes --> Y[Try next model]
    Y --> W
    X -- No --> Z[❌ All models exhausted]
    W -- No / Success --> AA[LLM text response]
    U --> AB[Call Gemini API]
    AB --> AA
    O --> AC[Save assistant message to DB]
    AA --> AC
    Q --> AC
    AC --> AD[Return ChatResponse\nwith all metadata]
    AD --> AE([Client receives response])

    style O fill:#ff6b6b,color:#fff
    style D fill:#ff9999,color:#000
    style Z fill:#ff9999,color:#000
```

### System Prompt

Every LLM request is prefixed with this medical safety system prompt:

```
You are an AI Healthcare Assistant for Rural Areas.

RULES:
- Never diagnose diseases or prescribe medicines.
- Always recommend consulting a doctor for medical concerns.
- Keep replies concise (2-3 paragraphs or a short bullet list).
- Use simple, friendly language with helpful emojis.
- Detect the user's language and reply in the SAME language.
- For emergencies: immediately tell them to call 108 (India) / 102 (Nepal) / 112 (Global).
- End every reply with: ⚠️ I am an AI providing general health education only —
  always consult a qualified doctor.
```

### Database Models

```
conversations
  ├── id (int PK)
  ├── uuid (UUID, exposed to API)
  ├── user_id (FK → users.id, string)
  ├── title (auto-generated from first message)
  ├── language
  ├── is_active
  └── created_at / updated_at

messages
  ├── id (int PK)
  ├── conversation_id (FK)
  ├── sender (user | assistant)
  ├── message (text)
  ├── response_time (float, seconds)
  ├── confidence (float 0–1)
  ├── emergency_detected (bool)
  ├── tokens_used (int)
  ├── metadata (JSON)
  └── created_at

chatbot_feedback
  ├── id, conversation_id, message_id
  ├── rating (1–5)
  ├── feedback_text
  └── feedback_type

chatbot_sessions
  └── (session tracking for analytics)
```

### Mobile App Integration

The mobile chatbot UI (`features/medical_chatbot/`) works as follows:

1. **Chatbot Home Page** — Riverpod provider loads the conversation list (`GET /chatbot/conversations`). Each tile shows the title, date, and message count.
2. **Chat Page** — Sends messages via `POST /chatbot/chat`, renders responses as markdown bubbles using `flutter_markdown`. A typing indicator (Lottie animation) shows while the AI is processing.
3. **Offline mode** — When connectivity is lost, the Riverpod provider switches to the local FAISS-backed response generator without any user action required.
4. **Voice input** — Microphone button on the chat input bar triggers STT (`speech_to_text` package). The transcript is populated into the text field and can be edited before sending.

---

---

## 7. Module 3 — Symptom Checker & Disease Prediction

### Overview

The Symptom Checker is an ML-powered clinical decision support tool. Users select symptoms from a structured vocabulary of 230 symptoms organised across 13 body-system categories, optionally provide demographic and clinical context, and receive a ranked list of possible conditions with confidence scores, a risk level, and actionable recommendations. The model is trained with scikit-learn and loaded from a serialised joblib file at server startup.

**Module path:** `backend/app/symptom_checker/`

### How It Works

The prediction pipeline converts a user's symptom selection into a **230-dimensional binary feature vector** (1 = symptom present, 0 = absent), feeds it into the trained multi-class classifier, and returns the top-5 predicted diseases sorted by probability. Risk assessment is computed as a weighted combination of the prediction confidence, symptom severity, and duration.

```mermaid
flowchart LR
    A([User selects symptoms\n+ demographic info]) --> B[POST /symptom-checker/predict]
    B --> C{Model loaded?}
    C -- No --> D[HTTP 503\nModel unavailable]
    C -- Yes --> E[Build 230-dim\nbinary feature vector]
    E --> F[Add numeric features:\nage, gender, severity,\nduration, BMI]
    F --> G[scikit-learn classifier\npredict_proba]
    G --> H[Top-5 diseases\nwith confidence scores]
    H --> I[Risk score calculation\nconfidence × severity weight]
    I --> J{Risk score}
    J -->|≥ 85| K[CRITICAL\nemergency_alert=true]
    J -->|70–84| L[HIGH]
    J -->|50–69| M[MEDIUM]
    J -->|< 50| N[LOW]
    K & L & M & N --> O[Generate recommendations\nbased on risk level]
    O --> P[Save to symptom_check_history]
    P --> Q([Return PredictionResponse])

    style K fill:#dc2626,color:#fff
    style L fill:#ea580c,color:#fff
    style M fill:#ca8a04,color:#fff
    style N fill:#16a34a,color:#fff
```

### Symptom Categories (13 Body Systems)

| Category | Example Symptoms |
|---|---|
| **General / Systemic** | fever, fatigue, weight loss, night sweats, loss of appetite |
| **Respiratory** | cough, shortness of breath, wheezing, chest tightness, sputum |
| **Cardiovascular** | chest pain, palpitations, swollen ankles, irregular heartbeat |
| **Neurological** | headache, dizziness, numbness, seizures, confusion, memory loss |
| **Digestive / GI** | nausea, vomiting, abdominal pain, diarrhoea, constipation, bloating |
| **Musculoskeletal** | joint pain, back pain, muscle weakness, stiffness, swelling |
| **ENT** | sore throat, ear pain, runny nose, nasal congestion, hearing loss |
| **Dermatological** | rash, itching, skin discolouration, hives, bruising |
| **Urological** | frequent urination, painful urination, blood in urine |
| **Ophthalmological** | blurred vision, eye pain, redness, double vision |
| **Psychological** | anxiety, depression, insomnia, mood swings, panic attacks |
| **Endocrine** | excessive thirst, excessive hunger, cold intolerance, hair loss |
| **Reproductive / Other** | irregular periods, discharge, pelvic pain |

**Total: 230 symptoms across 13 categories**

### Prediction Input Schema

```json
{
  "symptoms": ["fever", "headache", "fatigue", "nausea"],
  "age": 28,
  "gender": "female",
  "weight_kg": 58,
  "height_cm": 162,
  "duration_days": 3,
  "severity": 3,
  "existing_conditions": ["diabetes"],
  "current_medications": [],
  "allergies": [],
  "is_pregnant": false
}
```

### Prediction Response Schema

```json
{
  "predictions": [
    {
      "disease": "Typhoid Fever",
      "confidence": 0.82,
      "description": "A bacterial infection caused by Salmonella typhi...",
      "icd_code": "A01.0"
    },
    {
      "disease": "Viral Fever",
      "confidence": 0.71,
      "description": "...",
      "icd_code": "A99"
    }
  ],
  "risk_level": "HIGH",
  "risk_score": 74.5,
  "emergency_alert": false,
  "recommendations": [
    "Seek medical attention within 24 hours.",
    "Stay hydrated and rest.",
    "Do not self-medicate with antibiotics."
  ],
  "disclaimer": "This is a decision-support tool. Always consult a qualified doctor.",
  "checked_at": "2026-08-07T10:30:00Z"
}
```

### Complete API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/symptom-checker/predict` | JWT | Run disease prediction from symptom list |
| `GET` | `/symptom-checker/symptoms` | Public | List all 230 recognisable symptoms |
| `GET` | `/symptom-checker/symptoms/categorized` | Public | Symptoms organised by body system |
| `GET` | `/symptom-checker/diseases` | Public | List all known diseases in the model |
| `POST` | `/symptom-checker/batch-predict` | JWT | Batch predictions (multiple patients) |
| `GET` | `/symptom-checker/model-info` | Public | Model version, accuracy metrics, loaded status |
| `POST` | `/symptom-checker/reload` | Admin | Hot-reload the model without server restart |

### Model Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Loading : Server startup\non_startup() hook
    Loading --> Loaded : joblib.load() success
    Loading --> Unavailable : File not found\n(HTTP 503 on predict)
    Loaded --> Predicting : POST /predict request
    Predicting --> Loaded : Response returned
    Loaded --> Reloading : POST /reload (admin)
    Reloading --> Loaded : Hot-reload success
    Reloading --> Unavailable : Reload failure
```

**Model file path:** `ai_models/saved_models/symptom_checker/trained.joblib`

If this file is absent at startup, the `/predict` endpoint returns HTTP 503. The model can be hot-reloaded via the admin API without restarting the server — useful for deploying updated model versions in production.

### Risk Level Thresholds

| Risk Level | Score Range | Meaning | User Action |
|---|---|---|---|
| **CRITICAL** | 85 – 100 | Potentially life-threatening | Emergency services immediately |
| **HIGH** | 70 – 84 | Urgent medical attention needed | Visit hospital within 24 hours |
| **MEDIUM** | 50 – 69 | Medical consultation recommended | See a doctor within a few days |
| **LOW** | 0 – 49 | Low probability of serious illness | Monitor symptoms, rest |

### History Persistence

Every prediction is saved to `symptom_check_history` for later review by the user and the admin analytics dashboard:

```
symptom_check_history
  ├── id, user_id (nullable for anonymous)
  ├── symptoms (JSON array)
  ├── age, gender, weight, height
  ├── duration_days, severity
  ├── predicted_disease (top-1 disease name)
  ├── confidence (float)
  ├── risk_level, risk_score
  ├── is_emergency (bool)
  └── created_at
```

### Mobile App Integration

The disease prediction feature (`features/disease_prediction/`) has three screens:

1. **Disease Prediction Home** — Entry screen with description, quick-start button, and recent prediction history list
2. **Symptom Selector** — Multi-select chip grid organised by body system category tabs. Users tap symptoms, fill in age/gender/severity/duration, and submit
3. **Prediction Result Page** — Shows the ranked disease list with confidence progress bars, risk badge (colour-coded), first-aid recommendations, and a "Save to Health Records" button

A 401 interceptor on the Riverpod provider automatically redirects to the login screen if the session has expired — no silent blank screens.

---

### Performance Metrics

This section documents the complete, end-to-end performance profile of the Symptom Checker model — from training data statistics through classification accuracy, risk scoring behaviour, and runtime characteristics.

---

#### Dataset Statistics

The model is trained on the **Diseases and Symptoms** large dataset.

| Statistic | Value |
|---|---|
| Total samples (before deduplication) | ~96,000 |
| Total samples (after deduplication) | ~93,000+ |
| Input feature dimensions | **230** binary symptom features |
| Disease classes (output labels) | **120+** distinct diseases |
| Feature type | Multi-hot binary encoding (1 = present, 0 = absent) |
| Target column | `diseases` (string label, lowercased) |
| Dataset split | 70 % train · 15 % validation · 15 % test |
| Class balancing strategy | `class_weight='balanced'` in RandomForestClassifier |

**Data split sizes (approximate):**

| Split | Samples | Percentage |
|---|---|---|
| Training | ~65,100 | 70 % |
| Validation | ~13,950 | 15 % |
| Test | ~13,950 | 15 % |

---

#### Model Architecture & Hyperparameters

| Parameter | Value | Rationale |
|---|---|---|
| Algorithm | **Random Forest Classifier** | Robust to noisy binary features; naturally multi-class; provides `predict_proba` |
| `n_estimators` | **200** trees | Balance between variance reduction and training time |
| `max_depth` | **30** | Deep enough to capture complex symptom interactions; limited to prevent overfitting |
| `min_samples_split` | **5** | Prevents tiny pure nodes on rare diseases |
| `min_samples_leaf` | **2** | Smooths leaf probability estimates |
| `max_features` | **`"sqrt"`** | Standard for classification — `√230 ≈ 15` features per split |
| `class_weight` | **`"balanced"`** | Compensates for unequal disease frequency in training data |
| `random_state` | **42** | Reproducible training runs |
| `n_jobs` | **-1** | Parallelise across all CPU cores |
| `TOP_K_DISEASES` | **5** | Top-5 predictions returned per request |
| `MIN_CONFIDENCE_THRESHOLD` | **0.005** | Include low-probability candidates to handle multi-class spread |

---

#### Training Performance Targets vs. Achieved

The README within the AI module documents the following target thresholds. These represent the minimum acceptable values for the model to be considered production-ready:

| Metric | Target | Notes |
|---|---|---|
| Overall Accuracy | **> 85 %** | Top-1 exact match on test set |
| Top-3 Accuracy | **> 95 %** | Correct disease in top-3 predictions |
| Top-5 Accuracy | **> 97 %** | Correct disease in top-5 predictions |
| Weighted Precision | **> 80 %** | Across all disease classes |
| Weighted Recall | **> 80 %** | Across all disease classes |
| Weighted F1 Score | **> 80 %** | Harmonic mean of precision and recall |

> These thresholds drive the training loop: if evaluation on the test set does not meet all targets, hyperparameter tuning via `GridSearchCV` is re-run automatically before the model is serialised.

---

#### Evaluation Metrics — How They Are Computed

The model is evaluated using `sklearn.metrics` on the held-out test set (never seen during training or validation):

```python
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

metrics = {
    'accuracy':  accuracy_score(y_test, y_pred),
    'precision': precision_score(y_test, y_pred, average='weighted', zero_division=0),
    'recall':    recall_score(y_test, y_pred,    average='weighted', zero_division=0),
    'f1_score':  f1_score(y_test, y_pred,        average='weighted', zero_division=0),
}
```

All multi-class metrics use **`average='weighted'`** — each class contributes proportionally to its frequency in the test set, which is appropriate for an imbalanced disease distribution.

---

#### Top-K Accuracy Definition

Top-K accuracy answers: *"Is the correct disease somewhere in the model's top K predictions?"*

```python
for k in [1, 3, 5]:
    top_k_preds = model.predict_top_k(X_test, k=k)
    correct = sum(
        1 for i, true_disease in enumerate(y_test)
        if true_disease in [d for d, _ in top_k_preds[i]]
    )
    top_k_accuracy = correct / len(y_test)
```

This is the most clinically meaningful metric for a decision-support tool — a doctor reviewing the top-5 suggestions will identify the correct condition even if it is not ranked first.

---

#### Risk Score Computation — Factor Weights

The `RiskAssessmentEngine` computes a continuous risk score in `[0.0, 1.0]` as a weighted sum of nine independent clinical factors. This is a **post-model** layer that enriches the ML output with patient context the Random Forest does not see.

```mermaid
flowchart TD
    A([ML confidence score]) --> B[× 0.40 → base contribution]
    C([Emergency symptoms]) --> D[+ 0.00 to 0.50]
    E([Symptom combinations]) --> F[+ 0.00 to 0.30]
    G([Severity level 1-4]) --> H["+ (level−1) × 0.075\nmax 0.225"]
    I([Age]) --> J[+ 0.00 to 0.18]
    K([BMI]) --> L[+ 0.00 to 0.12]
    M([Duration]) --> N[+ 0.03 to 0.15]
    O([Existing conditions]) --> P[+ 0.00 to 0.15]
    Q([Medications / polypharmacy]) --> R[+ 0.00 to 0.08]
    B & D & F & H & J & L & N & P & R --> S[SUM all factors]
    S --> T["min(sum, 1.0) = final risk score"]
    T --> U{Threshold lookup}
    U -->|≥ 0.85| V[CRITICAL]
    U -->|0.60–0.84| W[HIGH]
    U -->|0.30–0.59| X[MEDIUM]
    U -->|< 0.30| Y[LOW]

    style V fill:#dc2626,color:#fff
    style W fill:#ea580c,color:#fff
    style X fill:#ca8a04,color:#fff
    style Y fill:#16a34a,color:#fff
```

**Detailed factor weights:**

| Factor | Max Contribution | Clinical Rationale |
|---|---|---|
| **Base confidence** (ML output × 0.40) | 0.40 | Higher ML certainty → higher base risk |
| **Emergency symptom present** | 0.50 | Overriding — chest pain, seizure, stroke symptoms etc. |
| **High-risk symptom combination** | 0.30 | Co-occurrence of dangerous clusters (e.g. chest pain + dyspnoea) |
| **Severity level 2 (Moderate)** | +0.075 | Self-reported symptom burden above mild |
| **Severity level 3 (Severe)** | +0.150 | Significant impairment |
| **Severity level 4 (Critical)** | +0.225 | Maximum self-reported severity |
| **Age < 5 years** | +0.15 | Immature immune system, rapid deterioration |
| **Age 5–11 years** | +0.08 | Paediatric elevated risk |
| **Age 12–17 years** | +0.04 | Adolescent mild elevation |
| **Age 65–74 years** | +0.08 | Early elderly — comorbidity common |
| **Age 75–84 years** | +0.13 | Multiple organ vulnerability |
| **Age ≥ 85 years** | +0.18 | Highest age-related vulnerability |
| **BMI < 16.0 (severe underweight)** | +0.12 | Malnutrition / eating disorder risk |
| **BMI 16–18.4 (underweight)** | +0.07 | Nutritional vulnerability |
| **BMI 25–29.9 (overweight)** | +0.04 | Mild cardiometabolic risk |
| **BMI 30–34.9 (obese class I)** | +0.07 | Elevated risk |
| **BMI 35–39.9 (obese class II)** | +0.10 | Significant comorbidity risk |
| **BMI ≥ 40 (morbid obesity)** | +0.12 | High comorbidity risk |
| **Duration ≤ 3 days (acute)** | +0.03 | Could be self-limiting |
| **Duration 4–7 days** | +0.06 | Sub-acute — monitoring needed |
| **Duration 8–14 days** | +0.09 | Persisting — warrants investigation |
| **Duration 15–30 days** | +0.12 | Chronic onset — diagnosis required |
| **Duration > 30 days (chronic)** | +0.15 | Active management needed |
| **Each high-risk comorbidity** | varies (0.03–0.12) | Capped at 0.15 total |
| **Polypharmacy (≥ 5 medications)** | +0.06 base | Drug-interaction risk |
| **High-risk medication present** | +0.02 additional | Capped at 0.08 total |

---

#### Risk Level Thresholds (Actual Values from Code)

| Risk Level | Score Range | Colour Code | Clinical Action |
|---|---|---|---|
| **LOW** | `0.00 – 0.29` | 🟢 Green | Monitor at home; consult if worsening |
| **MEDIUM** | `0.30 – 0.59` | 🟡 Yellow | Schedule GP appointment within 2–3 days |
| **HIGH** | `0.60 – 0.84` | 🟠 Orange | Urgent care same day; visit ED if worsening |
| **CRITICAL** | `0.85 – 1.00` | 🔴 Red | Emergency services immediately (108 / 112) |

> Note: thresholds are defined in `config.py` as `RISK_LEVELS` dict and are configurable without code changes via the admin settings panel.

---

#### Comorbidity Risk Weights (Top Conditions)

The risk engine assigns precise clinical weights to known comorbidities. These are additive and capped at **0.15 total** to prevent any single factor from dominating:

| Condition | Risk Weight | Clinical Basis |
|---|---|---|
| Heart failure / Coronary artery disease | +0.12 | Highest cardiovascular mortality risk |
| Cancer (any) / Leukemia | +0.12 | Immune compromise + systemic burden |
| AIDS / Renal failure | +0.12 | Severe immunocompromise / organ failure |
| Heart attack (acute) | +0.12 | Immediate life threat |
| Heart disease (general) | +0.12 | Elevated cardiac event risk |
| Atrial fibrillation | +0.10 | Thromboembolic risk |
| COPD / Emphysema | +0.09–0.10 | Respiratory decompensation risk |
| Stroke / Dementia / Parkinson | +0.08–0.09 | Neurological vulnerability |
| Kidney disease / Liver disease / Cirrhosis | +0.08–0.10 | Organ function compromise |
| HIV | +0.10 | Immune suppression |
| Lymphoma / Tumour | +0.10–0.11 | Oncological burden |
| Lupus / Autoimmune / Immunodeficiency | +0.07–0.09 | Immune dysregulation |
| Diabetes | +0.08 | Metabolic and vascular burden |
| Hypertension | +0.07 | Cardiovascular risk factor |
| Asthma | +0.06 | Exacerbation risk |
| Hyperthyroidism | +0.06 | Arrhythmia and metabolic risk |
| Osteoporosis / Arthritis | +0.04–0.05 | Musculoskeletal vulnerability |
| Depression / Anxiety | +0.03–0.04 | Psychosomatic and adherence risk |
| Unknown condition | +0.03 (base) | Conservative unclassified risk |

---

#### Clinical Symptom Augmentation — Why and How It Improves Accuracy

The predictor uses a two-layer inference strategy. The Random Forest was trained only on the 230-symptom binary vocabulary; demographic fields (age, BMI, duration, medications) were **not training features**. To compensate, Layer 1 augments the symptom list before model inference using evidence-based clinical rules:

```mermaid
flowchart LR
    A[User's reported symptoms\ne.g. joint pain, cough] --> B[SymptomNormalizer\nnormalise spellings]
    B --> C[Layer 1: Clinical Augmentation\n_augment_symptoms]
    C --> D{BMI rules\nAge rules\nDuration rules\nSeverity rules\nComorbidity rules\nMedication rules}
    D --> E[Augmented symptom list\ne.g. + weight gain, + shortness of breath]
    E --> F[_prepare_features\n→ 230-dim binary vector]
    F --> G[Random Forest\npredict_top_k]
    G --> H[Layer 2: Post-model\nRisk Enrichment]
    H --> I[Final risk score\n+ recommendations]
```

**Examples of clinical augmentation rules:**

| Trigger Condition | Symptoms Added to Vector | Clinical Evidence |
|---|---|---|
| BMI ≥ 40 (morbid obesity) | `weight gain`, `shortness of breath`, `fatigue`, `cramps and spasms`, `increased heart rate`, `peripheral edema` | Morbid obesity impairs cardiorespiratory function and raises metabolic demand |
| BMI ≥ 30 (obese) | `weight gain`, `fatigue`, `shortness of breath`, `peripheral edema` | Obesity-related functional limitations |
| BMI < 18.5 (underweight) | `fatigue`, `weakness`, `loss of appetite` | Nutritional deficit and muscle wasting |
| Age < 5 | `restlessness`, `lack of growth` | Common non-specific infant presentations |
| Age ≥ 75 | `disturbance of memory`, `sleepiness`, `dizziness` | Atypical elderly presentations |
| Duration > 14 days | `fatigue`, `feeling ill`, `weakness` | Systemic involvement in chronic illness |
| Duration > 30 days | `loss of appetite`, `sleepiness` | Chronic illness fatigue cascade |
| Severity = 4 (Critical) | `weakness`, `feeling ill` | Severe malaise at critical self-reported intensity |
| Existing diabetes | `fatigue`, `increased heart rate`, `itching of skin`, `weakness` | Diabetic neuropathy and metabolic dysregulation |
| Existing hypertension | `headache`, `dizziness` | Pressure-related vascular symptoms |
| Existing cardiac condition | `fatigue`, `shortness of breath`, `peripheral edema` | Heart failure / reduced output |
| Existing COPD / asthma | `shortness of breath`, `cough`, `fatigue` | Baseline airway obstruction |
| Existing renal disease | `fatigue`, `peripheral edema`, `nausea` | Uraemia and fluid retention |
| Existing liver disease | `fatigue`, `nausea`, `jaundice` | Hepatic insufficiency |
| Existing hypothyroidism | `fatigue`, `weakness`, `weight gain` | Low metabolism |
| Existing cancer | `fatigue`, `weight gain`, `weakness`, `loss of appetite` | Cancer-related fatigue and cachexia |
| Pregnancy | `fatigue`, `nausea`, `increased heart rate` | Physiological pregnancy demands |
| Corticosteroid therapy | `weight gain`, `increased heart rate` | Fluid redistribution and sympathomimetic effects |
| Chemotherapy | `fatigue`, `nausea`, `loss of appetite`, `weakness` | Systemic GI and haematological toxicity |
| Anticoagulant therapy | `fatigue` | Anaemia risk from chronic anticoagulation |

**Effect on accuracy:** Augmentation means a user who reports only "joint pain" but has documented obesity and diabetes will have the model evaluate a richer, more clinically complete symptom profile — producing a more accurate disease distribution and higher risk score, without requiring the user to manually tick every secondary symptom.

---

#### Feature Importance — Top Predictive Symptoms

The Random Forest's `feature_importances_` attribute ranks all 230 symptoms by their contribution to prediction accuracy. The `explain_prediction` endpoint (`predictor.explain_prediction()`) returns the top-10 most important features for any given prediction. The globally most predictive symptom categories (based on typical trained model importance distributions for this type of dataset) are:

| Rank | Symptom Category | Reason for High Importance |
|---|---|---|
| 1–3 | Respiratory symptoms (cough, shortness of breath, wheezing) | Common across a wide range of diseases — high discriminative value |
| 4–6 | Systemic/General (fever, fatigue, weight loss) | Present in most serious conditions — high differential value |
| 7–9 | Neurological (headache, dizziness, seizures) | Strong signal for neurological and systemic diseases |
| 10–12 | Cardiovascular (chest pain, palpitations, peripheral edema) | Distinct cluster for cardiac and respiratory conditions |
| 13–15 | Digestive (nausea, abdominal pain, diarrhoea) | Key discriminators for GI and infectious diseases |

---

#### Medication & Polypharmacy Risk Weights

The following high-risk medication classes trigger additional risk scoring:

| Medication Class | Examples | Additional Risk |
|---|---|---|
| Anticoagulants | warfarin, heparin, clopidogrel, aspirin | Bleeding risk |
| Immunosuppressants | methotrexate, azathioprine, tacrolimus | Infection vulnerability |
| Corticosteroids | prednisone, dexamethasone, cortisone | Metabolic and immune effects |
| Antidiabetics | insulin, glipizide, glibenclamide | Glucose instability risk |
| Psychotropics | lithium, clozapine, olanzapine | Narrow therapeutic index |
| Cardiac agents | digoxin, amiodarone | Narrow therapeutic index, arrhythmia risk |
| Chemotherapy | any cytotoxic agent | Bone marrow suppression, GI toxicity |

**Polypharmacy scoring:**

| Medication count | Base risk score | Notes |
|---|---|---|
| 0 | 0.00 | No added risk |
| 1–2 | +0.02 | Minimal |
| 3–4 | +0.04 | Moderate attention |
| 5+ | +0.06 | Polypharmacy threshold — drug-interaction risk |
| + High-risk med present | +0.02 additional | Capped at 0.08 total |

---

#### Severity Level Definitions

| Severity Code | Label | Clinical Description | Risk Score Contribution |
|---|---|---|---|
| 1 | **Mild** | Barely noticeable; does not interfere with daily activities | +0.000 |
| 2 | **Moderate** | Noticeable impairment; reduces but doesn't stop daily activities | +0.075 |
| 3 | **Severe** | Significant impairment; daily activities severely limited | +0.150 |
| 4 | **Critical** | Incapacitating; patient cannot perform normal activities | +0.225 |

---

#### Duration Categories & Risk Contribution

| Duration | Category Label | Risk Score Contribution | Clinical Meaning |
|---|---|---|---|
| 0–3 days | **Acute** | +0.03 | Could be self-limiting (viral URTI etc.) |
| 4–7 days | **Short-term** | +0.06 | Sub-acute — monitoring advised |
| 8–14 days | **Sub-acute** | +0.09 | Persisting — warrants investigation |
| 15–30 days | **Prolonged** | +0.12 | Chronic onset — diagnosis required |
| > 30 days | **Chronic** | +0.15 | Active management needed |

---

#### BMI Categories & Classification

| BMI Range | Category | Risk Score Contribution |
|---|---|---|
| < 16.0 | Severe underweight | +0.12 |
| 16.0 – 18.4 | Underweight | +0.07 |
| 18.5 – 24.9 | Normal weight | 0.00 (reference) |
| 25.0 – 29.9 | Overweight | +0.04 |
| 30.0 – 34.9 | Obese Class I | +0.07 |
| 35.0 – 39.9 | Obese Class II | +0.10 |
| ≥ 40.0 | Morbidly obese (Class III) | +0.12 |

---

#### Model API Response — Performance Metadata

Every `/symptom-checker/predict` response includes a `metadata` block:

```json
{
  "metadata": {
    "model_version": "v1.0",
    "timestamp": "2026-08-09T10:30:00.000000"
  },
  "input_summary": {
    "symptom_count": 4,
    "symptoms": ["fever", "headache", "fatigue", "nausea"],
    "augmented_symptom_count": 7,
    "augmented_symptoms": ["fever", "headache", "fatigue", "nausea", "weight gain", "itching of skin", "weakness"],
    "augmentation_log": [
      "Added 'weight gain' — diabetes: metabolic dysregulation",
      "Added 'itching of skin' — diabetes: pruritus from hyperglycaemia",
      "Added 'weakness' — diabetes: peripheral neuropathy"
    ],
    "bmi": 22.1,
    "bmi_category": "Normal weight",
    "duration_category": "Acute",
    "severity_label": "Severe"
  }
}
```

This full transparency allows clinicians, admins, and auditors to understand exactly why a risk score was assigned and which augmentation rules fired.

---

#### Performance Monitoring — Admin Dashboard

The admin **Symptom Analytics** panel (`/analytics`) tracks live model performance across the platform:

| Metric Tracked | Chart Type | Refresh |
|---|---|---|
| Total predictions (all-time / period) | KPI card | On load |
| Risk level distribution (LOW/MEDIUM/HIGH/CRITICAL) | Pie chart | On load |
| Top 20 most-reported symptoms | Horizontal bar chart | On load |
| Age group distribution of predictions | Histogram | On load |
| Gender distribution | Doughnut chart | On load |
| Top emergency types flagged | Bar chart | On load |
| Symptom frequency trend over 30/60/90 days | Line chart | Period selector |
| Per-disease prediction frequency | Ranked table | On load |
| Model version and loaded status | Status badge | On load |

The admin can also trigger a **hot-reload** of the model via the Datasets panel — allowing a freshly retrained model to be deployed without a server restart.

---

#### Deployment & Runtime Characteristics

| Characteristic | Value |
|---|---|
| Model format | `joblib` serialised `RandomForestSymptomChecker` |
| Model load time (cold start) | ~2–5 seconds at server startup |
| Prediction latency (single request) | < 50 ms (after model loaded) |
| Batch prediction support | Yes — `POST /symptom-checker/batch-predict` |
| Hot-reload without restart | Yes — `POST /symptom-checker/reload-model` |
| Feature validation on load | Strict — raises `RuntimeError` if feature count ≠ 230 |
| Thread safety | Yes — `sklearn` predict is stateless; safe for concurrent requests |
| Memory footprint | ~200–400 MB (200 trees × depth 30 × 230 features) |

---

## 8. Module 4 — Emergency Assessment & SOS

### Overview

The Emergency module provides rapid AI-assisted triage for potentially life-threatening situations. It accepts patient symptoms and demographic data, computes a numerical risk score, returns step-by-step first-aid instructions, and — when the user triggers SOS — immediately notifies all stored emergency contacts via SMS and email. Anonymous access is intentionally supported so that bystanders can use the tool without having an account.

**Module path:** `backend/app/emergency/`

### Key Design Decisions

| Decision | Rationale |
|---|---|
| **Anonymous assessments allowed** | A bystander helping an unconscious patient should not be blocked by a login screen |
| **First-aid guides embedded in API response** | Guides work offline — the app caches them so no network call is needed during an actual emergency |
| **SOS rate-limited** | Prevents accidental repeated triggers that would spam contacts |
| **Risk score 0–100 (numeric)** | Granular scoring allows threshold configuration via admin settings without code changes |
| **Configurable thresholds** | Critical/High/Medium/Low thresholds are stored in `system_settings` table and adjustable via admin dashboard |

### Risk Scoring Model

The AI risk scoring engine evaluates:
- **Symptom severity and combination** — certain symptom clusters (e.g. chest pain + shortness of breath) carry exponentially higher weight
- **Patient demographics** — age extremes (< 5 years, > 65 years) and pre-existing conditions (diabetes, hypertension, heart disease) multiply risk
- **Symptom duration** — acute-onset high-severity symptoms score higher than chronic slow-onset ones
- **Vital sign indicators** — user-reported heart rate, temperature, blood pressure where provided

### Default Risk Thresholds (configurable via admin)

| Level | Score Range | Colour | Recommended Action |
|---|---|---|---|
| **CRITICAL** | 90 – 100 | 🔴 Red | Call emergency services immediately (108/112) |
| **HIGH** | 75 – 89 | 🟠 Orange | Go to nearest hospital emergency room now |
| **MEDIUM** | 50 – 74 | 🟡 Yellow | Seek urgent care within hours |
| **LOW** | 0 – 49 | 🟢 Green | Monitor at home, visit clinic if not improving |

### Complete API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/emergency/assessment` | Optional JWT | Run AI emergency assessment (anonymous OK) |
| `GET` | `/emergency/history` | JWT | Past assessments for authenticated user |
| `GET` | `/emergency/assessment/{id}` | JWT | Get single assessment detail |
| `GET` | `/emergency/contacts` | JWT | List emergency contacts |
| `POST` | `/emergency/contacts` | JWT | Add emergency contact |
| `PUT` | `/emergency/contacts/{id}` | JWT | Update emergency contact |
| `DELETE` | `/emergency/contacts/{id}` | JWT | Remove emergency contact |
| `POST` | `/emergency/sos` | JWT | Trigger SOS alert to all contacts |
| `GET` | `/emergency/first-aid` | Public | All first-aid guide cards (offline-safe) |

### Emergency Assessment Flow

```mermaid
flowchart TD
    A([User opens Emergency module]) --> B{Is user\nlogged in?}
    B -- Yes --> C[Load emergency contacts\nfrom DB]
    B -- No --> D[Anonymous mode\nNo contacts available]
    C --> E[Emergency Assessment Form]
    D --> E

    E --> F[User fills:\nsymptoms, age, gender,\nexisting conditions, location]
    F --> G[POST /emergency/assessment]

    G --> H[AI Risk Scoring Engine]
    H --> I[Compute risk score 0–100]
    I --> J[Determine risk level]

    J --> K[Fetch matching first-aid guide\nfrom knowledge base]
    K --> L[List recommended\nhospital types]
    L --> M[Save to emergency_assessments\nDB table]
    M --> N[Return EmergencyAssessmentResponse]

    N --> O([Result Screen shown to user])

    O --> P{Risk Level?}
    P -->|CRITICAL| Q[🔴 Auto-display SOS button\nwith emergency numbers]
    P -->|HIGH| R[🟠 Strong recommendation\nto seek ER care]
    P -->|MEDIUM/LOW| S[🟡🟢 Standard guidance]

    Q --> T{User taps SOS?}
    T -- Yes --> U[POST /emergency/sos]
    U --> V{Rate limit\npassed?}
    V -- No --> W[❌ Too many SOS requests\nPlease wait]
    V -- Yes --> X[Fetch all emergency contacts]
    X --> Y[Send SMS to each contact\nvia Twilio/mock]
    X --> Z[Send email to each contact\nvia SMTP/mock]
    Y & Z --> AA([SOS Sent confirmation\nwith timestamp])

    style Q fill:#dc2626,color:#fff
    style W fill:#ff9999,color:#000
    style AA fill:#16a34a,color:#fff
```

### Assessment Request / Response Schema

**Request**
```json
{
  "symptoms": ["chest pain", "shortness of breath", "sweating"],
  "age": 52,
  "gender": "male",
  "existing_conditions": ["hypertension", "diabetes"],
  "current_medications": ["metformin"],
  "duration_minutes": 20,
  "location": {
    "latitude": 27.7172,
    "longitude": 85.3240,
    "description": "Kathmandu, Nepal"
  }
}
```

**Response**
```json
{
  "assessment_id": "ea-00142",
  "risk_score": 91.5,
  "risk_level": "CRITICAL",
  "is_emergency": true,
  "emergency_type": "Possible Cardiac Event",
  "first_aid_steps": [
    "Call 102 (Nepal) or 108 (India) immediately.",
    "Have the person sit or lie down in a comfortable position.",
    "Loosen tight clothing around neck and chest.",
    "If the person loses consciousness and stops breathing, begin CPR.",
    "Do NOT give food, water, or medication by mouth."
  ],
  "recommended_facilities": ["Cardiac Care Hospital", "Emergency Room", "ICU"],
  "recommendations": [
    "Go to the nearest hospital emergency room immediately.",
    "Do not drive yourself — call an ambulance."
  ],
  "emergency_numbers": {
    "india": "108",
    "nepal": "102",
    "global": "112"
  },
  "assessed_at": "2026-08-07T10:45:00Z"
}
```

### First-Aid Guide Coverage

The `/emergency/first-aid` endpoint returns embedded guides for:

| Condition | Key Steps Covered |
|---|---|
| Heart Attack | Recognition signs, CPR instructions, medication (aspirin) guidance |
| Stroke | FAST test (Face, Arms, Speech, Time), positioning |
| Choking | Heimlich manoeuvre (adult and child), back blows |
| Severe Burns | Cool water, no ice, sterile covering |
| Fractures | Immobilisation, splinting, do-not-move rules |
| Anaphylaxis | Epinephrine auto-injector, position, airway |
| Drowning | Recovery position, CPR sequence |
| Snake Bite | Immobilise, remove jewellery, no incision/suction |
| Electric Shock | Safe approach, CPR if needed |
| Seizure | Safe space, recovery position, timing |
| Severe Bleeding | Direct pressure, tourniquet guidance |
| Diabetic Emergency | Signs of hypo/hyperglycaemia, glucose administration |

### Database Models

```
emergency_assessments
  ├── id (int PK)
  ├── user_id (nullable — anonymous support)
  ├── age, gender
  ├── symptoms (JSON array)
  ├── existing_conditions (JSON array)
  ├── risk_score (float 0–100)
  ├── risk_level (LOW | MEDIUM | HIGH | CRITICAL)
  ├── is_emergency (bool)
  ├── emergency_type (string, e.g. "Possible Cardiac Event")
  ├── first_aid_steps (JSON array)
  ├── location (JSON)
  └── created_at

emergency_contacts
  ├── id, user_id (FK)
  ├── name, relationship
  ├── phone, email
  ├── is_primary (bool)
  └── created_at
```

### Mobile App Screens

| Screen | Purpose |
|---|---|
| **Emergency Home** | Quick-access grid: Assessment, Contacts, First-Aid Guides, SOS button |
| **Emergency Assessment Page** | Multi-step form: symptom selection → patient details → submit |
| **Emergency Result Page** | Risk badge, score meter, first-aid steps, SOS trigger button |
| **Emergency History Page** | Chronological list of past assessments with risk badges |
| **Emergency Contacts** | CRUD list for managing SOS recipients |

---

---

## 9. Module 5 — Personal Health Records (PHR)

### Overview

The Personal Health Records (PHR) module is a fully working, end-to-end live data module — not a static prototype. It is a secure digital health vault that stores, organises, and retrieves a user's complete medical history across five record types, all backed by the FastAPI backend with a SQLite (dev) / PostgreSQL (prod) database, local Hive cache for offline access, and a real-time refresh flow on the mobile app.

**Module path:** `backend/app/health_records/`  
**Mobile path:** `mobile_app/lib/features/health_records/`  
**Admin path:** `admin_dashboard/lib/features/health_records/`

### Architecture — Data Flow

```
Mobile App (Flutter / Riverpod)
  └── HealthRecordsController (StateNotifier)
        ├── loadAll() — concurrent fetch of all 6 endpoints
        ├── createPrescription() / addHistoryEntry() / addMedicalImage()
        └── HealthRecordsRepositoryImpl
              ├── Remote: HealthRecordsRemoteDataSource → SimpleApiClient
              │     → http://[device-ip]:8000/api/v1/health-records/*
              └── Local cache: LocalDbService (Hive) — offline fallback

Backend (FastAPI)
  └── /api/v1/health-records/*
        ├── MedicalProfileService   → user_medical_profiles table
        ├── MedicalHistoryService   → medical_history table
        ├── PrescriptionService     → prescriptions table + /uploads/
        ├── MedicalImageService     → medical_images table + /uploads/
        ├── TimelineService         → timeline_events table (auto-populated)
        └── HealthRecordsSummaryService → aggregate counts
```

> **URL note:** `SimpleApiClient.get(path)` prepends `ApiConfig.apiBaseUrl` which is
> `http://[ip]:8000/api/v1`. All datasource paths start with `/health-records/` (no repeated prefix).

### Record Types

| Record Type | What It Stores |
|---|---|
| **Medical Profile** | Blood group, height, weight, auto-calculated BMI, allergies, chronic conditions, current medications, smoking/alcohol status, activity level, family history, vaccination history |
| **Medical History** | Past and current conditions (diagnoses, surgeries, chronic illnesses, allergies, family history) with category and status tracking |
| **Prescriptions** | Doctor name, hospital, diagnosis, dynamic medicines list (name / dose / frequency / duration), instructions, prescription date, validity date, optional PDF/image file |
| **Medical Images** | X-rays, MRI, CT scans, blood reports, ECG, skin images — with type, body part, doctor, scan date, tags, optional file upload |
| **Medical Timeline** | Auto-aggregated chronological feed of all record types plus events pushed from the Emergency and Symptom Checker modules |

### Complete API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/health-records/summary` | JWT | Dashboard counts — profile flag, history count, prescription count, image count, recent timeline |
| `GET` | `/health-records/profile` | JWT | Get medical profile; creates an empty one on first access |
| `PUT` | `/health-records/profile` | JWT | Upsert medical profile; BMI auto-calculated server-side |
| `GET` | `/health-records/history` | JWT | List history entries (filter: `category`, `limit`, `offset`) |
| `POST` | `/health-records/history` | JWT | Add new history entry |
| `PUT` | `/health-records/history/{id}` | JWT | Update history entry |
| `DELETE` | `/health-records/history/{id}` | JWT | Delete history entry |
| `GET` | `/health-records/prescriptions` | JWT | List prescriptions (paginated) |
| `POST` | `/health-records/prescriptions` | JWT | Create prescription — accepts `application/json` OR `multipart/form-data` (with file) |
| `DELETE` | `/health-records/prescriptions/{id}` | JWT | Delete prescription |
| `GET` | `/health-records/images` | JWT | List medical images (filter: `image_type`) |
| `POST` | `/health-records/images` | JWT | Upload medical image — same dual content-type handler as prescriptions |
| `DELETE` | `/health-records/images/{id}` | JWT | Delete image |
| `GET` | `/health-records/timeline` | JWT | Unified timeline `{total, events:[]}` sorted newest-first |
| `POST` | `/health-records/timeline/external` | JWT | Push cross-module event (emergency, symptom check, chat) |

### Database Schema

```mermaid
erDiagram
    users ||--o| user_medical_profiles : "has one"
    users ||--o{ medical_history : "has many"
    users ||--o{ prescriptions : "has many"
    users ||--o{ medical_images : "has many"
    users ||--o{ timeline_events : "has many"

    user_medical_profiles {
        string id PK
        string user_id FK
        string blood_group
        float height_cm
        float weight_kg
        float bmi "auto-calculated"
        string smoking_status
        string alcohol_status
        string activity_level
        json allergies
        json chronic_diseases
        json current_medications
        json family_history
        json vaccination_history
        datetime created_at
        datetime updated_at
    }

    medical_history {
        string id PK
        string user_id FK
        string disease_name
        string category "current|past|surgery|allergy|chronic|family"
        string status "active|resolved|managed"
        datetime diagnosis_date
        string doctor_name
        string hospital_name
        text notes
        datetime created_at
        datetime updated_at
    }

    prescriptions {
        string id PK
        string user_id FK
        string doctor_name
        string hospital_name
        string diagnosis
        datetime prescription_date
        datetime valid_until
        json medicines "name|dose|frequency|duration"
        text instructions
        text notes
        string file_url
        string file_original_name
        datetime created_at
    }

    medical_images {
        string id PK
        string user_id FK
        string title
        string image_type "xray|mri|ct_scan|blood_report|ecg|skin|other"
        string description
        string body_part
        string doctor_name
        string hospital_name
        datetime scan_date
        json tags
        string file_url
        string file_original_name
        int file_size_bytes
        datetime created_at
    }

    timeline_events {
        string id PK
        string user_id FK
        string event_type "medical_history|prescription|medical_image|symptom_assessment|chat_conversation|emergency_assessment"
        string title
        text description
        string reference_id "FK to source record"
        string icon_emoji
        datetime event_date
        datetime created_at
    }
```

### File Upload — Dual Content-Type Handler

Both the prescription and image endpoints accept two request formats, which lets the mobile app send JSON-only (no file) or multipart (with file) using the same endpoint:

```mermaid
sequenceDiagram
    participant APP as Mobile App
    participant API as Health Records API
    participant FS as /uploads/
    participant DB as Database

    alt JSON-only (no file)
        APP->>API: POST /health-records/prescriptions\nContent-Type: application/json\n{doctor_name, diagnosis, medicines[]}
    else Multipart with file
        APP->>API: POST /health-records/prescriptions\nContent-Type: multipart/form-data\n{metadata: JSON string, file: binary}
    end

    API->>API: Auto-detect content-type\n→ parse accordingly
    opt File present
        API->>FS: Save to /uploads/prescriptions/<uuid>.<ext>
        FS-->>API: file_url confirmed
    end
    API->>DB: INSERT prescription record
    DB-->>API: Created record
    API-->>APP: 201 PrescriptionResponse {id, file_url, ...}
```

### Timeline Auto-Population

Every write operation (create history, upload prescription, upload image) automatically inserts a `timeline_events` row via the service layer. Other modules push events using the external endpoint:

```
Timeline sources:
  medical_history  CREATE  → "Added Medical History: Hypertension"          🩺
  prescriptions    CREATE  → "Prescription from Dr. Sharma"                  💊
  medical_images   CREATE  → "Medical Image: Chest X-Ray"                   📷
  emergency module POST    → "Emergency Assessment: HIGH severity"           🚨
  symptom checker  POST    → "Symptom Check: Fever + Headache"              🤒
  chatbot          POST    → "AI Consultation completed"                     �

All sorted by event_date DESC → most recent first
```

### Medical History Categories & Statuses

| Category | Description |
|---|---|
| `current` | Active conditions the user currently has |
| `past` | Resolved conditions from the past |
| `surgery` | Surgical procedures performed |
| `allergy` | Known allergens and reactions |
| `chronic` | Long-term conditions requiring ongoing management |
| `family` | Family history / hereditary risk factors |

| Status | Description |
|---|---|
| `active` | Currently ongoing |
| `resolved` | Fully treated / no longer present |
| `managed` | Controlled with ongoing medication or lifestyle changes |

### Mobile App — Screens & Features

| Screen | Features |
|---|---|
| **Health Records Home** | Gradient hero header with live vitals chips (blood group, height, weight, BMI); summary stats row (History / Rx / Scans / Labs counts); 6-card Quick Access grid; Recent Activity timeline (last 5 events); pull-to-refresh; shimmer skeleton on load |
| **Medical Profile** | Edit blood group, height, weight (BMI auto-computed), smoking/alcohol/activity status; tag editors for allergies, chronic conditions, medications, family history; saves to backend via `PUT /health-records/profile`; cached in Hive |
| **Medical History** | List with category filter chips (All / Current / Chronic / Past / Surgery / Allergy / Family); add/edit/delete entries via bottom sheet form; status badge (Active / Managed / Resolved) |
| **Prescriptions** | Card list with expiry status (Active / Expired); real add-form bottom sheet — diagnosis, doctor, hospital, date pickers, dynamic medicine rows (add/remove), instructions; copy & share prescription text; file download if attached |
| **Medical Images** | Grid with type filter (X-Ray / MRI / CT / Blood Report / ECG / Skin / Other); upload form with title, type, body part, scan date; full-screen viewer |
| **Medical Timeline** | Chronological feed with type-colour badges; filter by event type; grouped by month |
| **Search Records** | Full-text search across all record types |
| **Upload Report** | Bulk report upload page |

### Offline / Cache Strategy

| Operation | Strategy |
|---|---|
| **Read on load** | Remote first → on any network error → Hive local cache |
| **Profile save** | Remote write → `toLocalJson()` saved to Hive on success |
| **History / Images** | Remote write → local Hive upsert on success |
| **Error banner** | Shown only for real connectivity failures (SocketException, timeout, 401, 5xx) — NOT for empty data (new users see empty state, not error) |
| **Retry** | Banner includes a Retry button that calls `loadAll()` |

### Admin Dashboard — Health Records

The admin dashboard includes a dedicated 6-tab Health Records management page at `/health-records`:

| Tab | Contents |
|---|---|
| **Overview** | Aggregate stats: total profiles, history entries, prescriptions, images, timeline events; privacy notice |
| **Medical Profiles** | Paginated searchable table; view-detail dialog with full vitals, allergies, medications, family history |
| **Medical History** | Paginated table with search + category filter (current/chronic/past/surgery/allergy/family) + status filter (active/resolved/managed); detail dialog |
| **Prescriptions** | Paginated searchable table with medicine list; detail dialog |
| **Medical Images** | Paginated table with image-type filter; type badges |
| **Timeline** | All cross-user timeline events with event-type badges; paginated |

Admin endpoints used (all require `admin` or `super_admin` role):

| Endpoint | Description |
|---|---|
| `GET /admin/health-records/stats` | Aggregate counts across all five tables |
| `GET /admin/health-records/profiles` | Paginated + searchable medical profiles |
| `GET /admin/health-records/medical-history` | Paginated + searchable + filterable history |
| `GET /admin/health-records/prescriptions` | Paginated + searchable prescriptions |
| `GET /admin/health-records/images` | Paginated + type-filterable images |
| `GET /admin/health-records/timeline` | Paginated timeline events |

### Key Bug Fixes Applied

| Bug | Root Cause | Fix |
|---|---|---|
| "Exception: Not Found" on every load | `_kBase` in datasource was `'${ApiConstants.apiPrefix}/health-records'` — when prepended to `ApiConfig.apiBaseUrl` (which already contains `/api/v1`) the URL doubled to `.../api/v1/api/v1/health-records/...` | Changed `_kBase = '/health-records'` |
| Error banner shown for new users | `'not found'` and `'404'` were in the network-error detection list; a new user with no records triggers an empty response, not an error | Removed 404/not-found from the error list; empty state shown instead |
| Static/dummy data shown instead of live data | `getMedicalRecords`, `getLabReports`, `getMedicalTimeline`, and the prescriptions fallback all returned `HealthRecordsDummyData.*` | Replaced all with `const []` — live data from backend only |
| Timeline event card crash | `_TimelineEventCard` typed `event` as `dynamic` and used unsafe `.as` casts | Changed to typed `TimelineEvent` entity |
| Local profile cache broken | `saveMedicalProfile` called `toJson()..addAll({id, user_id, ...})` which mutates an unmodifiable map | Added `toLocalJson()` method that includes all server-assigned fields |
| SliverAppBar text overlap | `FlexibleSpaceBar.title` and the `background` vitals text rendered at the same position when collapsed | Removed `FlexibleSpaceBar.title`; collapsed title is now in `SliverAppBar.title`; vitals moved to pill chips in expanded hero |
| Prescriptions form non-functional | Upload sheet was a placeholder with no form fields | Replaced with a full `ConsumerStatefulWidget` form (diagnosis, doctor, hospital, dates, dynamic medicine rows, saves to backend) |
| Admin dashboard missing Medical History tab | Provider had no `AdminMedicalHistory` model or `loadMedicalHistory` method | Added model, state fields, and full `_HistoryTab` with search + filters |

---

---

## 10. Module 6 — Health Education

### Overview

The Health Education module is a fully-featured, visually rich multilingual content platform delivering WHO evidence-based health articles to users across rural South Asia. It was comprehensively overhauled with **25 meaningful articles across 12 colour-coded categories**, a vibrant multi-colour UI built with HSL-shifted gradients, live reading progress tracking, TTS (text-to-speech) listen mode, offline download, bookmarks, and a personalised recommendation engine — all offline-first.

**Module path:** `backend/app/health_education/`  
**Mobile UI path:** `mobile_app/lib/features/health_education/`

### Core Features

| Feature | Detail |
|---|---|
| **25 WHO-sourced articles** | Full Markdown content with tables, emergency signs, prevention checklists, and meal plans — covering diseases, nutrition, vaccination, maternal health, first aid, mental health, and more |
| **12 colour-coded categories** | Each category has a unique gradient colour; icons, slugs, and colours are consistent across backend seed, Flutter dummy data, and the UI palette |
| **Auto-seeding** | `SeedService.seed()` runs on every dashboard/category/article request; idempotent — inserts defaults only when the table is empty |
| **Multilingual content** | Articles exist in `en`, `hi`, `ne`, `bh` — client passes `?language=` param |
| **Live reading progress bar** | A colour-accented bar at the top of the article detail page updates in real time as the user scrolls; debounced to 50 px intervals to prevent excessive state updates |
| **TTS listen mode** | Full text-to-speech with play/pause, and a speed slider (0.25×–1.0×) via `flutter_tts`; markdown stripped before speech |
| **Recommendation engine** | Ranks by `view_count + bookmark_count × 3`; returns top 10 most-engaged articles |
| **Bookmarks** | Per-user saved article list, synced to backend with local Hive fallback |
| **Offline download** | Individual articles can be saved to device storage and read without internet |
| **Featured articles** | 10 articles flagged `is_featured = true` in seed data; surfaced as horizontal gradient cards on the dashboard |
| **View counter** | Incremented atomically on each `GET /articles/{id}` call |
| **Full-text search** | Searches title, summary, content, and tags; results show instantly with shimmer skeleton while loading |

### 12 Categories (Updated)

| # | Category | Slug | Colour | Icon |
|---|---|---|---|---|
| 1 | Diseases | `diseases` | `#F97316` (Orange) | 🩺 |
| 2 | Nutrition | `nutrition` | `#2ECC8B` (Green) | 🥗 |
| 3 | Vaccination | `vaccination` | `#4F94FF` (Blue) | 💉 |
| 4 | Maternal Health | `maternal-health` | `#E879A0` (Pink) | 🤰 |
| 5 | Child Health | `child-health` | `#FFB829` (Amber) | 👶 |
| 6 | Hygiene | `hygiene` | `#18C8C8` (Teal) | 🧼 |
| 7 | Healthy Lifestyle | `healthy-lifestyle` | `#926EFF` (Violet) | 🏃 |
| 8 | Mental Health | `mental-health` | `#7C3AED` (Purple) | 🧠 |
| 9 | Heart Health | `heart-health` | `#EF4444` (Red) | ❤️ |
| 10 | First Aid | `first-aid` | `#F43F5E` (Rose) | 🩹 |
| 11 | Women's Health | `womens-health` | `#EC4899` (Fuchsia) | ♀️ |
| 12 | Eye & Ear Care | `eye-ear-care` | `#0EA5E9` (Sky) | 👁️ |

### 25 Seed Articles

| # | Title | Category | Featured |
|---|---|---|---|
| 1 | Understanding Diabetes: Causes, Symptoms & Prevention | Diseases | ✅ |
| 2 | Malaria Prevention and Treatment Guide | Diseases | ✅ |
| 3 | Nutrition During Pregnancy: What to Eat for a Healthy Baby | Nutrition | ✅ |
| 4 | BCG, Polio & Childhood Vaccination Schedule | Vaccination | ✅ |
| 5 | Hand Washing: The Most Powerful Disease Prevention Tool | Hygiene | — |
| 6 | Managing High Blood Pressure (Hypertension) Naturally | Heart Health | ✅ |
| 7 | Child Fever: When to Worry and Home Care Guide | Child Health | — |
| 8 | Mental Wellness for Rural Communities | Mental Health | — |
| 9 | Breastfeeding: Benefits and Best Practices for New Mothers | Maternal Health | ✅ |
| 10 | Tuberculosis (TB): Facts, Prevention, and Treatment | Diseases | — |
| 11 | Diarrhoea in Children: ORS, Zinc & Prevention | Child Health | — |
| 12 | Anaemia in Women: Iron Deficiency, Symptoms & Iron-Rich Diet | Women's Health | ✅ |
| 13 | Snake Bite First Aid: Do's, Don'ts & Emergency Response | First Aid | ✅ |
| 14 | Protecting Your Eyesight: Common Eye Problems & Prevention | Eye & Ear Care | — |
| 15 | Safe Drinking Water: Purification Methods for Rural Homes | Hygiene | — |
| 16 | Heart Attack Warning Signs & Immediate Action Steps | Heart Health | ✅ |
| 17 | Sleep Your Way to Better Health: Sleep Hygiene Guide | Healthy Lifestyle | — |
| 18 | Dengue Fever: Symptoms, Warning Signs & Home Management | Diseases | ✅ |
| 19 | Physical Activity for Health: A Beginner's Exercise Guide | Healthy Lifestyle | — |
| 20 | Antenatal Care: Essential Pregnancy Check-ups & Tests | Maternal Health | — |
| 21 | Understanding Cholesterol: Good vs Bad & Diet Changes | Heart Health | — |
| 22 | Oral Health: Brushing, Flossing & Preventing Gum Disease | Hygiene | — |
| 23 | Pneumonia in Children: Recognition, Treatment & Prevention | Diseases | — |
| 24 | 7 Cancer Warning Signs You Should Never Ignore | Healthy Lifestyle | — |
| 25 | Essential Newborn Care: First 28 Days Guide for Parents | Child Health | ✅ |

### Complete API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/education/dashboard` | JWT | Full dashboard: featured + categories + recommendations + recent reading + bookmarks |
| `GET` | `/education/categories` | JWT | All 12 health categories |
| `GET` | `/education/articles` | JWT | Paginated article list (filter by category slug, language) |
| `GET` | `/education/articles/{id}` | JWT | Article detail — increments view count |
| `GET` | `/education/featured` | JWT | Featured articles (limit configurable, default 5) |
| `GET` | `/education/search` | JWT | Full-text search across title, summary, content, and tags |
| `GET` | `/education/recommendations` | JWT | Ranked by engagement score (view + bookmark × 3) |
| `GET` | `/education/bookmarks` | JWT | User's bookmarked articles |
| `POST` | `/education/bookmarks` | JWT | Bookmark an article |
| `DELETE` | `/education/bookmarks/{id}` | JWT | Remove a bookmark |
| `POST` | `/education/reading-progress/{id}` | JWT | Update scroll position and completion state |
| `GET` | `/education/health` | Public | Module health check |

### Education Module Flow

```mermaid
flowchart TD
    A([User opens Health Education]) --> B[GET /education/dashboard\n?language=en]
    B --> C[SeedService.seed\nInsert 25 articles + 12 categories\nif tables are empty — idempotent]
    C --> D[DashboardService.get_dashboard]

    D --> E[Featured Articles\n10 flagged articles]
    D --> F[All 12 Categories\nwith colour + icon]
    D --> G[Recommendations\nRanked by view_count + bookmark×3]
    D --> H[Recent Reading\nReadingHistoryService]
    D --> I[Bookmarks\nBookmarkService.list_bookmarks]

    E & F & G & H & I --> J([Dashboard rendered\nVibrant gradient UI])

    J --> K{User Action}

    K -->|Tap category tile| L[GET /education/articles\n?category=child-health&language=en]
    K -->|Search bar| M[GET /education/search?q=dengue]
    K -->|Tap featured card| N[GET /education/articles/:id]

    L --> N
    M --> N

    N --> O[ArticleService.get_article_detail\nIncrement view_count atomically]
    O --> P[Render full Markdown\nProgress bar + TTS listen mode]
    P --> Q[POST /education/reading-progress/:id\n{last_read_position, is_completed}]
    Q --> R[Debounced — fires every 50 px\nUpserts reading_history record]
    R --> S[Drives future recommendations]

    N --> T{Bookmark / Download?}
    T -- Bookmark --> U[POST /education/bookmarks\nIdempotent — no duplicates]
    T -- Download --> V[Save full article to Hive\nAvailable offline]

    style S fill:#74c69d,color:#000
    style V fill:#4F94FF,color:#fff
```

### Recommendation Engine Logic

```mermaid
flowchart LR
    A[GET /education/recommendations] --> B[Query all published articles\nfor requested language]
    B --> C[Order by\nview_count + bookmark_count × 3 DESC]
    C --> D[Return top 10\nhighest-engagement articles]
    D --> E([Personalised feed\nshown in Recommended For You])
```

### Database Schema

```
health_categories
  ├── id (string PK, UUID)
  ├── name, slug (unique, indexed)
  ├── description, icon (emoji), color_hex
  ├── sort_order, is_active
  └── created_at

health_articles
  ├── id (string PK, UUID)
  ├── category_id (FK → health_categories)
  ├── title, slug (unique, indexed)
  ├── summary (max 600 chars — used in cards)
  ├── content (full Markdown — loaded only in detail view)
  ├── language (en|hi|ne|bh)
  ├── emoji, author, source
  ├── tags (JSON array — used in search)
  ├── read_time_min (int, minutes)
  ├── is_featured, is_published
  ├── view_count, bookmark_count
  └── published_at, created_at, updated_at

reading_history
  ├── id, user_id (FK), article_id (FK)
  ├── last_read_position (pixel offset)
  ├── is_completed (bool)
  ├── read_count (incremented per visit)
  └── created_at, updated_at
  [UNIQUE on user_id + article_id]

user_bookmarks
  ├── id, user_id (FK), article_id (FK)
  └── created_at
  [UNIQUE on user_id + article_id]
```

### Article Dashboard Response Structure

```json
{
  "featured_articles": [ ...HealthArticleSummary ],
  "categories": [ ...HealthCategoryResponse ],
  "recommended_articles": [ ...HealthArticleSummary ],
  "recent_articles": [ ...HealthArticleSummary ],
  "bookmarks": [ ...HealthArticleSummary ]
}
```

### Mobile App — UI & Screens

#### Education Home (Dashboard)
- **Gradient hero banner** — 3-colour gradient (indigo → blue → teal) with decorative blobs, "Learn & Stay Healthy" title, WHO Evidence-Based badge, live article + topic count pills, and "Browse All Articles →" CTA
- **Quick-facts strip** — horizontally scrollable colour pills: 25 Articles · 12 Topics · WHO Sourced · Offline Ready · Listen Mode
- **4-column category grid** — each tile has a unique per-category gradient icon with coloured shadow; 12 categories rendered in a `GridView` with `childAspectRatio: 0.90`
- **Featured Articles carousel** — horizontal `ListView` of gradient cards (width 230, height 206) with HSL-shifted complementary colour pairs and decorative circle overlays
- **Daily Health Tip card** — rotates by day-of-month from 5 curated tips; colour-accented gradient background
- **Recommended For You list** — article cards with gradient emoji icons, category colour tag, read-time, and coloured "Read →" button

#### Article Detail Page
- **Gradient SliverAppBar** — category colour → HSL-shifted second colour; category pill, emoji box, title (max 3 lines), read-time and source meta pills; 3 action buttons (bookmark, download, share) as pill containers
- **Live reading progress bar** — thin accent-coloured bar pinned below the status bar; updates on scroll, debounced every 50 px
- **Progress strip** — inline `%read` indicator with `LinearProgressIndicator`
- **Quick Summary card** — accent-gradient background with info icon; shows article summary before the full content
- **Status badges** — Featured ⭐, Offline Ready, Bookmarked — shown when applicable
- **Markdown rendering** — via `flutter_markdown` with custom `MarkdownStyleSheet`: h1/h2 in accent colour, coloured bold text, styled blockquote borders (4 px left accent), coloured table headers with light background, rounded code blocks
- **TTS Listen mode** — play/pause button in bottom bar; speed slider (0.25×, 0.5×, 0.75×, 1.0×) in a floating panel above the bottom bar; uses `flutter_tts` with markdown stripped before speech
- **Bottom action bar** — 4 animated pill buttons (Listen, Save, Download, Share) with filled/unfilled states

#### Article List Page
- Category filter chips with gradient selected state and coloured shadow
- Search bar with animated border and focus shadow
- Infinite scroll with load-more spinner
- Shimmer skeleton loading for 8 cards

#### Bookmarks & Offline Page
- Two-tab layout: Bookmarks / Offline
- Pull-to-refresh on bookmarks tab
- Empty state with animated emoji and gradient CTA button

### Offline-First Behaviour

| Scenario | Behaviour |
|---|---|
| No internet at startup | `EducationDummyData` provides all 25 articles and 12 categories instantly |
| API returns 200 | Live data replaces dummy data; dashboard refreshes |
| User taps Download on article | Full article stored in `LocalDbService` (Hive); accessible forever offline |
| User opens downloaded article offline | Loaded directly from Hive; no network call needed |
| Backend articles updated | On next successful API call, live data takes precedence over dummy fallback |

---

## 11. Module 7 — Voice Assistant

### Overview

The Voice Assistant module provides a complete hands-free healthcare interaction pipeline. Users can speak health questions and receive spoken answers — without typing a single character. It uses a three-tier cascade for both Speech-to-Text and Text-to-Speech, prioritising accuracy and quality at the top tier and falling back to fully offline options at the bottom, ensuring functionality even without internet connectivity.

**Module path:** `backend/app/voice/`

### STT Tier Cascade

```mermaid
flowchart LR
    AUDIO([Audio File Input]) --> A{Tier 1:\nOpenAI Whisper\nlocal model}
    A -- Available --> B[Transcribe locally\nBest accuracy\nWorks offline]
    A -- Not available --> C{Tier 2:\nGoogle Speech\nRecognition}
    C -- Available + Internet --> D[Google STT API\nFree tier\nGood accuracy]
    C -- Not available --> E{Tier 3:\nVosk\nfully offline}
    E -- Available --> F[Vosk local model\nLower accuracy\nCompletely offline]
    E -- Not available --> G[❌ STT unavailable\nReturn error]
    B & D & F --> H([Transcript text])
```

### TTS Tier Cascade

```mermaid
flowchart LR
    TEXT([Text to synthesise]) --> A{Tier 1:\nMicrosoft Edge TTS\nneural voices}
    A -- Internet available --> B[Neural voice synthesis\nen-IN / hi-IN / ne-NP\nBest quality]
    A -- Offline --> C{Tier 2:\ngTTS\nGoogle Translate TTS}
    C -- Internet available --> D[Google TTS\nMp3 output]
    C -- Offline --> E{Tier 3:\npyttsx3\nsystem voice}
    E --> F[System TTS\nCompletely offline\nBasic quality]
    B & D & F --> G([Base64 MP3 audio])
```

### Supported Voice Languages

| Language | STT Code | TTS Voice (Edge) | Locale |
|---|---|---|---|
| English (India) | `en-IN` | `en-IN-NeerjaNeural` | `en-IN` |
| Hindi | `hi-IN` | `hi-IN-SwaraNeural` | `hi-IN` |
| Nepali | `ne-NP` | `ne-NP-HemkalaNeural` | `ne-NP` |
| Bhojpuri | `bh` | Falls back to `hi-IN` | `hi-IN` |
| Bengali | `bn-IN` | `bn-IN-TanishaaNeural` | `bn-IN` |
| Tamil | `ta-IN` | `ta-IN-PallaviNeural` | `ta-IN` |
| Telugu | `te-IN` | `te-IN-ShrutiNeural` | `te-IN` |
| Marathi | `mr-IN` | `mr-IN-AarohiNeural` | `mr-IN` |

### Complete API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/voice/stt` | JWT | Upload audio file → receive transcript text |
| `POST` | `/voice/tts` | JWT | Send text → receive base64 MP3 audio |
| `POST` | `/voice/chat` | JWT | Full pipeline: audio → STT → AI chatbot → TTS → audio response |
| `GET` | `/voice/languages` | Public | List all supported languages and voices |
| `GET` | `/voice/health` | Public | Check availability of each STT/TTS engine |

### Full Voice Chat Pipeline

```mermaid
sequenceDiagram
    actor U as User
    participant APP as Mobile App
    participant VAPI as Voice API
    participant STT as STT Engine
    participant CHAT as Chatbot Service
    participant TTS as TTS Engine

    U->>APP: Hold mic button and speak
    APP->>APP: record package records audio\nas WAV/M4A file
    APP->>VAPI: POST /voice/chat\n{audio: <binary>, conversation_id?, language?}

    VAPI->>STT: Transcribe audio
    Note over STT: Whisper → Google STT → Vosk\n(first available tier used)
    STT-->>VAPI: transcript = "मुझे दो दिन से बुखार है"

    VAPI->>VAPI: Auto-detect language → "hi"

    VAPI->>CHAT: ChatbotService.process_chat\n{message: transcript, language: "hi"}
    Note over CHAT: Same full pipeline as /chatbot/chat\nEmergency detection → LLM failover → DB persist
    CHAT-->>VAPI: reply_text = "बुखार के कई कारण हो सकते हैं..."

    VAPI->>TTS: Synthesise reply_text\nin language "hi"
    Note over TTS: Edge TTS (hi-IN-SwaraNeural)\n→ gTTS → pyttsx3
    TTS-->>VAPI: audio_bytes (MP3)

    VAPI->>VAPI: base64.encode(audio_bytes)
    VAPI-->>APP: {\n  transcript: "मुझे दो दिन से बुखार है",\n  reply_text: "बुखार के कई कारण...",\n  audio_base64: "//NExAA...",\n  language: "hi",\n  emergency: false,\n  conversation_id: "uuid"\n}

    APP->>APP: Show text reply in chat bubble
    APP->>APP: audioplayers plays base64 MP3
    APP->>U: User hears spoken response
```

### Voice Chat Request / Response

**Request — POST /voice/chat**
```
Content-Type: multipart/form-data
Fields:
  - audio: <binary audio file> (WAV, M4A, MP3, OGG)
  - conversation_id: "uuid" (optional)
  - language: "hi" (optional — auto-detected if omitted)
```

**Response**
```json
{
  "transcript": "मुझे दो दिन से बुखार है",
  "reply_text": "बुखार के कई कारण हो सकते हैं...\n\n⚠️ मैं केवल सामान्य स्वास्थ्य जानकारी प्रदान करने वाला AI हूं।",
  "audio_base64": "//NExAAA...",
  "audio_mime_type": "audio/mp3",
  "language_detected": "hi",
  "emergency_detected": false,
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "response_time_seconds": 4.21
}
```

### Whisper Model Configuration

| Model Size | Disk | RAM | Accuracy | Speed |
|---|---|---|---|---|
| `tiny` | 39 MB | ~1 GB | Lowest | Fastest |
| `base` | 74 MB | ~1 GB | Good | Fast — **recommended default** |
| `small` | 244 MB | ~2 GB | Better | Moderate |
| `medium` | 769 MB | ~5 GB | High | Slow |

Set via `WHISPER_MODEL_SIZE` in `.env`. The `base` model offers the best balance of accuracy and speed for low-resource devices.

### Mobile Integration

The mobile chatbot (`chat_page.dart`) includes a microphone button that:
1. Requests microphone permission via `permission_handler`
2. Records audio using the `record` package (outputs M4A on iOS, WAV on Android)
3. Sends the audio file to `POST /voice/chat`
4. Populates the transcript in the chat bubble and plays the audio response via `audioplayers`
5. Falls back to text-only mode if microphone permission is denied

---

---

## 12. Module 8 — Offline Sync

### Overview

The Offline Sync module enables the app to function fully without internet connectivity and synchronise accumulated local changes back to the server when connectivity returns. It uses **Hive** (a fast key-value NoSQL database) as the on-device store and exposes a set of server-side sync endpoints for bidirectional data exchange. Real-time network state changes are detected by `connectivity_plus` and `internet_connection_checker_plus`, which trigger automatic sync transparently in the background.

**Module path:** `backend/app/offline_sync/`

### Offline Data Strategy

The platform uses a two-layer offline approach:

| Layer | Technology | Purpose |
|---|---|---|
| **Structured data cache** | Hive (on-device) | Conversations, symptom history, health records, education articles |
| **AI chatbot offline engine** | 100-topic keyword engine (`chatbot_dummy_data.dart`) | Structured chatbot responses across 100 health topics — no server or FAISS index needed |
| **Offline suggestion chips** | `offlineSuggestions` list (100 items) | All 100 topic chips shown when offline; reverts to 8 online chips when reconnected |
| **Pending write queue** | Hive box `pendingQueue` | Mutations made offline that need to be pushed to server |
| **Sync metadata** | Hive box `syncMeta` | Last sync timestamps per data type |

### Network State Machine

```mermaid
stateDiagram-v2
    [*] --> Checking : App launch
    Checking --> Online : connectivity_plus detects WiFi/Mobile\n+ internet_connection_checker_plus\nconfirms real internet
    Checking --> Offline : No connectivity detected

    Online --> Offline : Network lost
    Offline --> Online : Network restored

    Online --> Syncing : Pending queue not empty\n(auto-triggered on reconnect)
    Syncing --> Online : Sync complete
    Syncing --> SyncError : Sync failed (conflict / server error)
    SyncError --> Online : Retry after backoff

    Online --> FetchingCache : User opens feature\nfor first time / stale cache
    FetchingCache --> Online : Cache updated

    note right of Offline : App uses Hive cache\nChatbot uses 100-topic keyword engine\nWrites go to pendingQueue
    note right of Online : Normal API mode\nAll writes go directly to server
```

### Complete API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/offline/upload/` | JWT | Push pending queue items from device to server |
| `GET` | `/offline/download/` | JWT | Download latest data snapshot for device cache |
| `POST` | `/offline/sync/` | JWT | Full bidirectional sync in a single round-trip |
| `GET` | `/offline/history/` | JWT | Sync history log for the user |
| `GET` | `/offline/settings/` | JWT | Get offline sync preferences |
| `PUT` | `/offline/settings/` | JWT | Update sync preferences (auto-sync interval, WiFi-only, etc.) |

### Bidirectional Sync Flow

```mermaid
sequenceDiagram
    participant APP as Mobile App (Hive)
    participant NET as Network Monitor
    participant API as Offline Sync API
    participant DB as Server Database

    Note over APP, DB: ── OFFLINE PERIOD ──
    APP->>APP: User creates prescription\n(no internet)
    APP->>APP: Write to Hive: health_records box
    APP->>APP: Add to pendingQueue:\n{type: "prescription", action: "create", data: {...}}

    Note over APP, DB: ── RECONNECTION ──
    NET->>APP: connectivity_plus fires\nNetworkChanged(online=true)
    APP->>NET: internet_connection_checker_plus\nconfirms real internet (GET /health)
    NET->>APP: Confirmed online

    APP->>API: POST /offline/sync/\n{last_synced_at: "2026-08-07T08:00:00Z",\n pending_items: [...]}

    API->>API: Process pending_items
    loop For each pending item
        API->>DB: Apply mutation\n(INSERT / UPDATE / DELETE)
        DB-->>API: Result (success / conflict)
    end

    API->>DB: Fetch all records changed\nsince last_synced_at
    DB-->>API: Delta records

    API-->>APP: {\n  synced_items: [{id, status},...],\n  server_changes: [{type, data},...],\n  sync_timestamp: "2026-08-07T10:30:00Z"\n}

    APP->>APP: Apply server_changes to Hive boxes
    APP->>APP: Clear synced items from pendingQueue
    APP->>APP: Update syncMeta.last_synced_at
```

### Hive Box Structure (On-Device)

```
Hive boxes:
  ├── auth_box
  │     └── {access_token, refresh_token, user_profile}
  ├── conversations_box
  │     └── List<ConversationModel> (last 50 conversations)
  ├── messages_box_{conversation_id}
  │     └── List<MessageModel>
  ├── symptom_history_box
  │     └── List<SymptomCheckResult>
  ├── health_records_box
  │     ├── medical_profile
  │     ├── history_entries[]
  │     └── prescriptions[]
  ├── education_box
  │     ├── articles[] (cached for offline reading)
  │     └── bookmarks[]
  ├── pending_queue_box
  │     └── List<PendingAction> — queued mutations
  └── sync_meta_box
        └── {last_synced_at, sync_count, last_error}
```

### Conflict Resolution Strategy

When an item in the pending queue conflicts with a server record (both modified offline and on server since last sync), the platform applies **last-write-wins** with the server timestamp taking precedence:

```
Conflict Resolution Rules:
  1. Server DELETE wins over client UPDATE (record was removed on server)
  2. Server UPDATE wins if server.updated_at > client.updated_at
  3. Client UPDATE wins if client.updated_at > server.updated_at
  4. Conflicts are logged to sync_history with status="conflict_resolved"
```

### Offline Sync Settings

Users can configure sync behaviour via `GET/PUT /offline/settings/`:

| Setting | Default | Description |
|---|---|---|
| `auto_sync_enabled` | `true` | Automatically sync when connectivity restores |
| `wifi_only` | `false` | Only sync on WiFi (saves mobile data) |
| `sync_interval_minutes` | `30` | Background sync interval when online |
| `max_offline_days` | `7` | How many days of data to keep in local cache |
| `sync_health_records` | `true` | Include health records in sync |
| `sync_conversations` | `true` | Include chatbot conversations in sync |

### Mobile Sync Centre Screen

The **Sync Centre** (`/offline`) screen provides full visibility into sync state:
- Last sync timestamp and status badge (Success / Error / Pending)
- Count of pending queue items waiting to be synced
- Manual "Sync Now" button
- Sync history list (last 20 sync events with item counts)
- Storage usage breakdown per Hive box
- Clear cache option (with warning)

---

## 13. Module 9 — Notifications & Feedback

### Overview

The Notifications module delivers both in-app and push notifications to users for health reminders, emergency alerts, and system messages. The Feedback module collects star ratings and free-text feedback on chatbot conversations to drive continuous improvement.

**Module paths:** `backend/app/notifications/` · `backend/app/feedback/`

### Notifications Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/notifications/` | JWT | List notifications (paginated, unread-first) |
| `GET` | `/notifications/unread-count` | JWT | Count of unread notifications |
| `POST` | `/notifications/mark-read/{id}` | JWT | Mark single notification as read |
| `POST` | `/notifications/mark-all-read` | JWT | Mark all notifications as read |
| `POST` | `/notifications/register-device` | JWT | Register FCM push token for device |
| `DELETE` | `/notifications/register-device` | JWT | Unregister push token on logout |
| `GET` | `/notifications/preferences` | JWT | Get notification preferences |
| `PUT` | `/notifications/preferences` | JWT | Update preferences (enable/disable types) |

### Notification Types

| Type | Trigger | Example |
|---|---|---|
| `emergency_alert` | SOS triggered | "SOS sent to 3 contacts at 10:45 AM" |
| `high_risk_assessment` | Risk level HIGH/CRITICAL | "Your symptom check shows HIGH risk. Please seek care." |
| `medication_reminder` | Scheduled | "Time to take your Metformin 500mg" |
| `appointment_reminder` | Upcoming visit | "Doctor appointment tomorrow at 2:00 PM" |
| `sync_complete` | Offline sync done | "12 records synced successfully" |
| `system_message` | Admin broadcast | "Platform maintenance on Sunday 2–4 AM" |

### Feedback Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/feedback/` | JWT | Submit feedback (rating 1–5 + optional text) |
| `GET` | `/feedback/` | JWT | List user's submitted feedback |
| `GET` | `/feedback/summary` | Admin | Aggregate statistics (avg rating, distribution) |
| `GET` | `/feedback/list` | Admin | All feedback paginated (for admin review) |

---

---

## 14. Mobile App — Flutter

### Overview

The mobile application is a Flutter app targeting Android and iOS. It follows a **feature-first clean architecture** with Riverpod 2.x for state management and a strict separation between data, domain, and presentation layers within each feature. The app is designed to be offline-capable from day one — every network call has a Hive cache counterpart, and the connectivity layer switches modes transparently.

**Directory:** `mobile_app/`

### Architecture Pattern

```
lib/
├── main.dart                       ← App entry point, Hive init, ProviderScope
├── config/
│   └── api_config.dart             ← Resolves backend URL at runtime
│                                      (WiFi IP / emulator / dart-define override)
├── constants/
│   └── api_constants.dart          ← All API path strings as constants
├── core/
│   ├── api/
│   │   ├── api_client.dart         ← Dio singleton with JWT interceptor
│   │   └── api_interceptor.dart    ← Auto-refresh on 401, error normalisation
│   ├── local_db/
│   │   └── local_db_service.dart   ← Hive box open/close lifecycle management
│   └── network/
│       └── network_config.dart     ← Persisted backend URL via SharedPreferences
└── features/
    └── <feature_name>/
        ├── data/
        │   ├── datasources/
        │   │   ├── <feature>_remote_datasource.dart   ← REST API calls
        │   │   └── <feature>_local_datasource.dart    ← Hive read/write
        │   └── repositories/
        │       └── <feature>_repository_impl.dart     ← Combines remote + local
        ├── domain/
        │   ├── entities/
        │   │   └── <feature>_model.dart               ← Pure Dart models
        │   └── repositories/
        │       └── <feature>_repository.dart          ← Abstract interface
        └── presentation/
            ├── controllers/
            │   └── <feature>_provider.dart            ← Riverpod StateNotifier
            ├── pages/
            │   └── <feature>_page.dart                ← Screen widgets
            └── widgets/
                └── (reusable UI components)
```

### State Management — Riverpod 2.x

Every feature exposes its own set of providers. State is fully isolated — a state change in the chatbot module never triggers a rebuild in the emergency module.

```mermaid
flowchart LR
    A[User interaction\non screen widget] --> B[ConsumerWidget\nref.read/watch provider]
    B --> C[StateNotifier\nor AsyncNotifier]
    C --> D{Online?}
    D -- Yes --> E[Repository Impl\nRemote DataSource\nDio HTTP call]
    D -- No --> F[Repository Impl\nLocal DataSource\nHive read]
    E --> G[Cache result\nto Hive]
    G --> H[Emit new state]
    F --> H
    H --> I[Widget rebuilds\nwith new data]
```

**Provider types used:**

| Riverpod Provider | When used |
|---|---|
| `StateNotifierProvider` | Mutable state with complex logic (auth, chatbot, emergency) |
| `AsyncNotifierProvider` | Async data fetching with loading/error/data states |
| `FutureProvider` | One-shot async reads (model info, categories list) |
| `StreamProvider` | Real-time connectivity state from `connectivity_plus` |

### Complete Navigation Map

```mermaid
flowchart TD
    A([App Launch]) --> B[SplashPage\n2s + token check]
    B --> C{Valid token\nin secure storage?}
    C -- No --> D[OnboardingPage\nFirst launch only]
    C -- Yes --> HOME
    D --> E[WelcomePage\nLogin / Register]

    E --> F[RegisterPage]
    E --> G[LoginPage]

    F --> H[VerifyEmailPage]
    H --> I[VerifyPhonePage]
    I --> J[CompleteProfilePage]
    J --> HOME

    G --> HOME

    HOME[HomeDashboardPage] --> CHAT[ChatbotHomePage]
    HOME --> SYM[DiseasePredictionHomePage]
    HOME --> EMR[EmergencyHomePage]
    HOME --> PHR[HealthRecordsHome]
    HOME --> EDU[HealthEducationHome]
    HOME --> PROF[ProfilePage]
    HOME --> SET[SettingsPage]

    CHAT --> CHATROOM[ChatPage\nconversation_id]

    SYM --> SYMPTOM_SEL[SymptomSelectorPage]
    SYMPTOM_SEL --> PRED_RESULT[PredictionResultPage]
    PRED_RESULT --> PHR

    EMR --> EMR_ASSESS[EmergencyAssessmentPage]
    EMR --> EMR_CONTACTS[EmergencyContactsPage]
    EMR --> FIRST_AID[FirstAidGuidePage]
    EMR_ASSESS --> EMR_RESULT[EmergencyResultPage]
    EMR_RESULT --> SOS[SOS Sent Screen]

    PHR --> MED_PROFILE[MedicalProfilePage]
    PHR --> MED_HIST[MedicalHistoryPage]
    PHR --> PRESCRIPTIONS[PrescriptionsPage]
    PHR --> MED_IMAGES[MedicalImagesPage]
    PHR --> TIMELINE[TimelinePage]

    EDU --> ARTICLE_LIST[ArticleListPage]
    EDU --> BOOKMARKS[BookmarksPage]
    ARTICLE_LIST --> ARTICLE_DETAIL[ArticleDetailPage]
```

### API Config — URL Resolution Priority

`lib/config/api_config.dart` resolves the backend URL at runtime using this priority chain:

```
1. --dart-define=BACKEND_URL=http://...  ← CI / team overrides
2. Android emulator (IS_EMULATOR=true)  ← http://10.0.2.2:8000
3. Physical Android device              ← http://<_wifiBackendUrl>:8000
4. Web / Desktop                        ← http://localhost:8000
```

To change the WiFi IP, update `_wifiBackendUrl` in `api_config.dart`:
```dart
static const String _wifiBackendUrl = 'http://192.168.x.x:8000';
```

### HTTP Client — Dio Interceptor

The Dio client (`core/api/api_client.dart`) includes an interceptor that:

1. **Adds `Authorization: Bearer <token>`** to every request from `flutter_secure_storage`
2. **On HTTP 401** — calls `POST /auth/refresh` with the stored refresh token
3. **If refresh succeeds** — retries the original request with the new access token
4. **If refresh fails** — clears all tokens, navigates to `WelcomePage`
5. **On HTTP 4xx/5xx** — normalises the error into a human-readable `ApiException` with `statusCode`, `message`, and `detail`

### Key Packages and Their Roles

| Package | Role in the App |
|---|---|
| `flutter_riverpod 2.5.1` | State management across all features |
| `dio 5.4.3` | HTTP client with interceptor chain |
| `hive + hive_flutter 2.2.3` | Fast key-value local DB for offline caching |
| `flutter_secure_storage` | Encrypted JWT token storage (Keychain / Keystore) |
| `speech_to_text 7.3.0` | On-device STT for voice input in chat |
| `flutter_tts 4.0.2` | TTS playback for voice responses |
| `record 7.1.1` | Audio recording (WAV/M4A) for `/voice/chat` |
| `audioplayers 6.0.0` | Play base64 MP3 audio responses |
| `connectivity_plus 6.0.3` | Detect WiFi/mobile/none connectivity |
| `internet_connection_checker_plus` | Confirm actual internet vs. captive portal |
| `flutter_markdown 0.7.3` | Render AI chatbot responses as rich Markdown |
| `flutter_animate 4.5.0` | Entrance animations on list items and cards |
| `lottie 3.1.2` | JSON-based loading spinner and state animations |
| `shimmer 3.0.0` | Skeleton loading placeholders while fetching |
| `cached_network_image 3.3.1` | Lazy-load and cache profile/article images |
| `file_picker 8.1.2` | Attach prescription PDFs and medical images |
| `permission_handler 11.3.1` | Microphone and storage permission requests |
| `flutter_svg 2.0.10` | SVG icons and illustrations |
| `intl 0.19.0` | Date/time formatting and locale-aware display |
| `uuid 4.4.2` | Client-side UUID generation for offline records |

### Splash & First-Launch Flow

```mermaid
sequenceDiagram
    participant APP as App (SplashPage)
    participant SS as flutter_secure_storage
    participant API as Backend

    APP->>APP: Show logo + animation (1.5s)
    APP->>SS: Read access_token
    SS-->>APP: token (or null)

    alt token exists
        APP->>API: GET /auth/me (Bearer token)
        alt 200 OK
            API-->>APP: user profile
            APP->>APP: Navigate to HomeDashboardPage
        else 401 Unauthorized
            APP->>API: POST /auth/refresh
            alt refresh OK
                API-->>APP: new tokens
                APP->>SS: Store new tokens
                APP->>APP: Navigate to HomeDashboardPage
            else refresh failed
                APP->>SS: Clear all tokens
                APP->>APP: Navigate to WelcomePage
            end
        end
    else no token
        APP->>APP: First launch? → OnboardingPage
        APP->>APP: Returning user? → WelcomePage
    end
```

### Offline Mode Visual Indicators

The app communicates connectivity state clearly to users:

| State | Visual Indicator | Behaviour |
|---|---|---|
| **Online** | No banner | Full API mode |
| **Offline** | Orange banner "You are offline — using cached data" | Hive + 100-topic keyword engine mode; 100 suggestion chips shown |
| **Syncing** | Blue banner "Syncing…" with progress | Background sync in progress |
| **Sync Error** | Red banner "Sync failed — tap to retry" | Manual retry available |

---

---

## 15. Admin Dashboard — Flutter Web

### Overview

The Admin Dashboard is a Flutter Web application that gives platform administrators and healthcare managers full visibility and complete control over the entire platform. It connects to the same FastAPI backend via admin-scoped JWT tokens and provides **18 distinct management panels** behind a collapsible sidebar. All data tables are paginated, searchable, and filterable. The dashboard supports both light and dark mode with a custom theme.

**Directory:** `admin_dashboard/`

**URL:** http://localhost:5000

**Default credentials:** `admin@healthcare.ai` / `Admin@123456` (role: `super_admin`)

### Running the Admin Dashboard

```powershell
cd admin_dashboard
flutter pub get
flutter run -d chrome --web-port 5000
```

### Token Storage on Web

Both `ApiClient._storage` and `AuthNotifier._storage` use `WebOptions` so tokens persist across page reloads in Chrome/Edge:

```dart
static const _storage = FlutterSecureStorage(
  webOptions: WebOptions(dbName: 'admin_secure', publicKey: 'admin_key'),
);
```

This stores tokens in `localStorage` via the Web Crypto API. Without this, `flutter_secure_storage` silently fails to write tokens on Flutter Web — causing the login page to reappear immediately after successful authentication.

### Shared UI Infrastructure

```mermaid
flowchart LR
    subgraph Shell["App Shell (app.dart)"]
        SIDEBAR["Collapsible Sidebar\n18 nav items\n(expand/collapse on hover)"]
        TOPBAR["Top Bar\n• Notifications bell + badge + dropdown\n• Dark/light mode toggle\n• Admin user chip + logout"]
        CONTENT["Content Area\n(go_router page rendering)"]
    end

    SIDEBAR --> CONTENT
    TOPBAR --> CONTENT

    subgraph Shared["Shared Widgets"]
        DTC["DataTableCard\nPaginated sortable table\nwith search + filter slots"]
        SB["StatusBadge\nColour-coded active/inactive"]
        SHIMMER["Shimmer placeholders\nfor all loading states"]
        FADE["Fade page transitions\nvia flutter_animate"]
    end
```

**Collapsible Sidebar Navigation (18 items):**

| Section | Route | Panel |
|---|---|---|
| **Overview** | `/dashboard` | Dashboard & KPIs |
| **User Management** | `/users` | User Management |
| | `/users/:userId` | Per-User Detail (6 tabs) |
| | `/doctors` | Doctors Management |
| | `/authentication` | Authentication & Sessions |
| | `/profile` *(user profiles section)* | User Profiles |
| **Modules** | `/emergency` | Emergency Monitoring |
| | `/chatbot` | AI Chatbot Monitoring |
| | `/disease-prediction` | Disease Prediction Stats |
| | `/health-records` | Health Records Admin |
| | `/medical-history` | Medical History |
| | `/education` | Health Education CMS |
| | `/feedback` | User Feedback |
| **System** | `/analytics` | Analytics & Insights |
| | `/datasets` | Dataset Management |
| | `/reports` | Reports & Charts |
| | `/logs` | Audit Logs |
| | `/notifications` | Notifications |
| | `/settings` | System Settings |
| **Account** | `/profile` | Admin Profile |

### Token Management in Admin Dashboard

The Dio client (`lib/core/api.dart`) uses `flutter_secure_storage` and a token refresh interceptor identical to the mobile app:

```
On every request:     Add Authorization: Bearer <access_token>
On HTTP 401:          POST /auth/refresh → retry with new token
If refresh fails:     clearTokens() → navigate to /login
```

**Backend URL configuration** (`lib/core/constants.dart`):

```dart
static const String _backendHost = 'localhost:8000';
// Change to LAN IP for device testing:
// static const String _backendHost = '192.168.1.100:8000';
```

---

### Panel 1 — Dashboard & KPIs

**Route:** `/dashboard` · **Provider:** `DashboardNotifier`

The central landing screen after login. Loads `GET /admin/dashboard` and `GET /admin/system/health` in parallel.

**8 KPI Cards:**

| Card | Metric | API Source |
|---|---|---|
| Total Users | Registered user count | `stats.total_users` |
| Active Users | `is_active = true` count | `stats.active_users` |
| Total Conversations | All chatbot conversations | `stats.total_conversations` |
| Emergency Assessments | Total assessments | `stats.total_emergencies` |
| High Risk Cases | Risk ≥ HIGH count | `stats.high_risk_count` |
| Published Articles | Live education content | `stats.published_articles` |
| Average Chat Rating | Mean feedback score | `stats.avg_rating` |
| Active Sessions | Currently active JWT sessions | `stats.active_sessions` |

**4 Trend Charts (fl_chart):**
- User registrations over last 30 days (line chart)
- Emergency assessments over last 30 days (bar chart)
- Chatbot conversations over last 30 days (line chart)
- Risk level distribution (doughnut chart)

**System Health Panel:**
Calls `GET /admin/system/health` and displays a colour-coded status badge for each subsystem: `database` · `api` · `symptom_checker` · `chatbot` · `emergency_system` · `storage`

```mermaid
flowchart LR
    A[DashboardNotifier.load] --> B[GET /admin/dashboard]
    A --> C[GET /admin/system/health]
    B --> D[Parse DashboardStats\n+ recentUsers\n+ recentEmergencies\n+ trend arrays]
    C --> E[Parse system health map]
    D & E --> F[Emit DashboardState\n→ Widget rebuilds]
    F --> G[8 KPI cards]
    F --> H[4 trend charts]
    F --> I[System health badges]
    F --> J[Recent users table]
    F --> K[Recent emergencies list]
```

---

### Panel 2 — User Management

**Route:** `/users` · **Provider:** `UsersNotifier`

Full CRUD management of all registered users with bulk operations and CSV/JSON export.

**Features:**
- Paginated data table (20/page) with search by name/email
- Filter by role (`patient` · `doctor` · `admin` · `super_admin`) and status (`active` · `inactive`)
- Stat chips: Total · Active · Inactive · Doctors · Admins
- Per-row actions: **View Details** (→ full detail page) · Activate/Deactivate · Change Role · Delete
- Multi-row checkbox selection → Bulk Action bar (Activate / Deactivate / Delete)
- Add User dialog — creates admin-verified account bypassing password-strength rules
- Export dialog — calls `GET /admin/export/users?format=csv|json`, displays result in selectable text dialog for copy/save

**Admin API calls used:**

| Action | Endpoint |
|---|---|
| Load users | `GET /admin/users?search=&role=&is_active=&page=` |
| Create user | `POST /admin/users` |
| Activate/Deactivate | `PATCH /admin/users/{id}/status` |
| Change role | `PATCH /admin/users/{id}/role` |
| Delete user | `DELETE /admin/users/{id}` |
| Bulk action | `POST /admin/users/bulk-action` |
| Export CSV/JSON | `GET /admin/export/users?format=csv\|json` |

---

### Panel 2a — Per-User Detail Page (6 Tabs)

**Route:** `/users/:userId` · **Provider:** `UserDetailNotifier` (StateNotifierProvider.family)

Clicking the **eye icon (👁)** on any user row navigates to a full-screen detail page with 6 lazy-loaded tabs. Each tab loads its data on first open.

#### Tab 1 — Profile

Read-only summary of everything known about the user plus one-click action buttons.

| Field shown | Source |
|---|---|
| Full name, email, phone | `AdminUser` model |
| Role badge | colour-coded: patient/doctor/admin/super_admin |
| Active / Inactive status badge | `is_active` |
| Email verified flag | `email_verified` |
| Language | user's preferred language code |
| Chat conversations total | `total_conversations` |
| Emergency assessments total | `total_emergency_assessments` |
| Joined date | `created_at` |
| Last login | `last_login` |

**Quick-action buttons on Profile tab:**

| Button | Role required | API call | Effect |
|---|---|---|---|
| Activate / Deactivate | admin+ | `PATCH /admin/users/{id}/status` | Toggles `is_active` immediately |
| Change Role | super_admin | `PATCH /admin/users/{id}/role` | Shows role dropdown; saves on confirm |
| Reset Password | super_admin | `POST /admin/users/{id}/reset-password` | Prompts for new password (min 6 chars) |
| Revoke All Sessions | admin+ | `POST /admin/users/{id}/revoke-sessions` | Deactivates all sessions + refresh tokens → user is immediately logged out everywhere |

#### Tab 2 — Edit

Inline form to modify the user's profile fields directly.

| Field | Notes |
|---|---|
| Full Name | Text field with non-empty validation |
| Phone | Optional; uniqueness check against other users |
| Language | Dropdown: English / Hindi / Nepali / Spanish / French |
| Email Verified | Checkbox — admin can manually mark as verified |
| Phone Verified | Checkbox — admin can manually mark as verified |

Also contains a **Force Reset Password** card (super_admin only) — enter new password, show/hide toggle, calls `POST /admin/users/{id}/reset-password`.

**API call:** `PATCH /admin/users/{id}/profile`

#### Tab 3 — Chats

Paginated list of every chatbot conversation this user ever had.

Each card shows: title · message count · emergency flag count · language · date.
Data loads on first tab open. Pagination: 15 per page.

**API call:** `GET /admin/users/{id}/conversations?page=&page_size=15`

#### Tab 4 — Emergency

Paginated list of every emergency assessment this user ran.

Each card shows: risk level badge (colour-coded) · EMERGENCY badge if triggered · possible emergency type · symptoms chips · age/gender · SOS trigger count · date.

**API call:** `GET /admin/users/{id}/emergencies?page=&page_size=15`

#### Tab 5 — Symptoms

Paginated list of every disease prediction / symptom check this user submitted.

Each card shows: risk level badge · EMERGENCY badge · top predicted disease with confidence % · symptoms chips · age/gender · date.

**API call:** `GET /admin/users/{id}/symptom-checks?page=&page_size=15`

#### Tab 6 — Sessions

All login sessions (active and expired) across every device.

Each card shows: device icon (mobile/desktop) · device info · IP address · last active time · Active/Expired badge.

**Revoke All button** (visible only when active sessions exist): calls `POST /admin/users/{id}/revoke-sessions` — deactivates all `user_sessions` rows and revokes all `refresh_tokens` rows.

**API call:** `GET /admin/users/{id}/sessions`

**Complete per-user backend endpoints:**

| Method | Endpoint | Role | Description |
|---|---|---|---|
| `GET` | `/admin/users/{id}` | admin+ | Full profile with activity counts |
| `PATCH` | `/admin/users/{id}/status` | admin+ | Activate or deactivate |
| `PATCH` | `/admin/users/{id}/role` | super_admin | Change role |
| `DELETE` | `/admin/users/{id}` | super_admin | Permanently delete |
| `PATCH` | `/admin/users/{id}/profile` | admin+ | Edit name/phone/language/verification flags |
| `POST` | `/admin/users/{id}/reset-password` | super_admin | Force-set new password |
| `POST` | `/admin/users/{id}/revoke-sessions` | admin+ | Revoke all sessions + refresh tokens |
| `GET` | `/admin/users/{id}/conversations` | admin+ | Paginated chat history |
| `GET` | `/admin/users/{id}/emergencies` | admin+ | Paginated emergency assessments |
| `GET` | `/admin/users/{id}/sessions` | admin+ | All sessions with active count |
| `GET` | `/admin/users/{id}/symptom-checks` | admin+ | Paginated symptom check history |

---

### Panel 3 — Doctors Management

**Route:** `/doctors`

Dedicated panel for managing doctor accounts — a filtered view of users with `role = doctor` plus a "Create Doctor" form.

**Features:**
- Filterable list of all doctors (search + active status filter)
- Create Doctor dialog (email + password + name — pre-verified on creation)
- Activate/Deactivate per doctor
- Shows: specialisation (if set), email, phone, active status, last login

**Admin API calls:**

| Action | Endpoint |
|---|---|
| List doctors | `GET /admin/doctors?search=&is_active=&page=` |
| Create doctor | `POST /admin/doctors` |
| Toggle status | `PATCH /admin/doctors/{id}/status` |

---

### Panel 4 — Emergency Monitoring

**Route:** `/emergency`

Real-time monitoring of emergency assessments platform-wide.

**Features:**
- Risk-level summary cards: Critical · High · Medium · Low (from `GET /admin/emergency/stats`)
- Paginated assessment list filtered by risk level and `is_emergency` flag
- Each row shows: user name · age · gender · risk score · risk level badge · emergency type · date
- Expandable row reveals full symptoms list and first-aid steps used
- Emergency config editor (thresholds stored in `system_settings` — no code deploy needed):
  - Critical threshold (default 90)
  - High threshold (default 75)
  - Medium threshold (default 50)
  - Auto-SOS threshold (default 95)
  - Auto-SOS enabled toggle
  - Notify admin on SOS toggle

**Admin API calls:**

| Action | Endpoint |
|---|---|
| Stats | `GET /admin/emergency/stats` |
| List assessments | `GET /admin/emergency?risk_level=&is_emergency=&page=` |
| Get config | `GET /admin/emergency/config` |
| Update config | `PUT /admin/emergency/config` |

---

### Panel 5 — Chatbot Monitoring

**Route:** `/chatbot`

Monitor all chatbot conversations across the platform, view language distribution, and manage chatbot configuration.

**Features:**
- Stats bar: total conversations · total messages · emergency flags · average response time · average rating
- Paginated conversation table with filters: search · language · `has_emergency`
- Each row: user name · conversation title · language · message count · has emergency flag · date
- Click row to view full conversation transcript in a side panel
- Delete conversation (admin can delete any conversation)
- Language distribution doughnut chart
- Chatbot config editor (temperature · max tokens · context window · emergency detection toggle · safety settings)

**Admin API calls:**

| Action | Endpoint |
|---|---|
| Stats | `GET /admin/chatbot/stats` |
| List conversations | `GET /admin/chatbot/conversations?search=&language=&has_emergency=&page=` |
| Delete conversation | `DELETE /admin/chatbot/conversations/{id}` |
| Get config | `GET /admin/chatbot/config` |
| Update config | `PUT /admin/chatbot/config` |

---

### Panel 6 — Health Education CMS

**Route:** `/education`

Content management system for health articles — full CRUD with publish/draft toggle.

**Features:**
- Article list with search · category filter · language filter · published status filter
- Create Article dialog (title · summary · body Markdown · category · language · tags · read time · featured toggle)
- Edit article inline (PUT)
- Publish/unpublish toggle per article
- Delete article with confirmation
- Category list with article counts

**Admin API calls:**

| Action | Endpoint |
|---|---|
| List articles | `GET /admin/education/articles?search=&category_id=&language=&is_published=&page=` |
| Create article | `POST /admin/education/articles` |
| Update article | `PUT /admin/education/articles/{id}` |
| Delete article | `DELETE /admin/education/articles/{id}` |

---

### Panel 7 — Symptom Analytics

**Route:** `/analytics`

Deep analytics on symptom checker usage across the platform.

**Features:**
- Summary cards: total predictions · total emergency flags · model status
- Top 20 most-reported symptoms (horizontal bar chart)
- Risk level distribution (pie chart: LOW / MEDIUM / HIGH / CRITICAL)
- Age group distribution (histogram: 0–18 · 19–35 · 36–55 · 56+)
- Gender distribution (donut: male · female · other)
- Top emergency types (bar chart)
- Symptom frequency trend over last 30/60/90 days (line chart)
- Disease prediction stats: model version · total predictions · top 10 diseases table
- Prediction history table with risk/emergency filters
- Disease model config editor (confidence threshold · emergency keywords · risk thresholds)
- Hot-reload model button (admin can deploy a new model version without restart)

**Admin API calls:**

| Action | Endpoint |
|---|---|
| Stats | `GET /admin/analytics/stats` |
| Symptom frequency | `GET /admin/analytics/symptom-frequency?limit=20` |
| Trend | `GET /admin/analytics/trend?days=30` |
| Risk distribution | `GET /admin/analytics/risk-distribution` |
| Gender distribution | `GET /admin/analytics/gender-distribution` |
| Age distribution | `GET /admin/analytics/age-distribution` |
| Emergency types | `GET /admin/analytics/emergency-types` |
| Disease prediction stats | `GET /admin/disease-prediction/stats` |
| Prediction history | `GET /admin/disease-prediction/history?risk_level=&is_emergency=&page=` |
| Reload model | `POST /admin/disease-prediction/reload-model` |

---

### Panel 8 — Dataset Management

**Route:** `/datasets` · **Provider:** `DatasetNotifier`

Version management for AI training datasets. Admins can register new dataset versions, activate a specific version for production, and remove obsolete ones.

**Features:**
- Dataset list with type filter (`symptom_checker` · `chatbot_knowledge` · `education`)
- Stats card: total datasets · active datasets · total records
- Create Dataset dialog (name · type · version · description)
- Activate dataset (marks as active, deactivates all others of same type — logged with `severity=warning`)
- Delete dataset with confirmation
- Each row shows: name · type · version · record count · file size · active badge · uploaded by · date

**Admin API calls:**

| Action | Endpoint |
|---|---|
| List datasets | `GET /admin/datasets?dataset_type=&page=` |
| Stats | `GET /admin/datasets/stats` |
| Create | `POST /admin/datasets` |
| Activate | `PATCH /admin/datasets/{id}/activate` |
| Delete | `DELETE /admin/datasets/{id}` |

---

### Panel 9 — Reports & Charts

**Route:** `/reports`

Period-selectable aggregate reports for executive-level platform overview.

**Features:**
- Period selector: 7 · 14 · 30 · 60 · 90 · 180 · 365 days
- User registration trend (line chart)
- Chatbot conversation volume (bar chart)
- Emergency assessment volume + risk level breakdown (stacked bar)
- Risk level distribution over time (area chart)
- Article views and engagement (line chart)
- All charts rendered with `fl_chart`

**Admin API call:** `GET /admin/reports?days=30`

---

### Panel 10 — Audit Logs

**Route:** `/logs`

Immutable audit trail of all admin actions across the platform.

**Features:**
- Paginated log table (50/page) with filters: module · severity · admin user
- Module filter covers: `users` · `authentication` · `chatbot` · `emergency` · `education` · `datasets` · `settings` · `disease_prediction` · `doctors`
- Severity filter: `info` (default) · `warning` (destructive actions) · `error`
- Each row: timestamp · admin name · action · module · target resource · IP address · severity badge
- Colour-coded severity: info = blue · warning = amber · error = red

**Admin API call:** `GET /admin/logs?module=&severity=&admin_id=&page=`

**Logged actions (sample):**

| Action | Severity | Trigger |
|---|---|---|
| `user.activate` / `user.deactivate` | info | Status toggle |
| `user.delete` | warning | User deletion |
| `user.change_role` | warning | Role change |
| `users.bulk_activate` / `bulk_delete` | warning | Bulk operations |
| `article.create` / `article.update` | info | CMS changes |
| `article.delete` | warning | Content removal |
| `dataset.activate` | warning | Dataset version switch |
| `model.reload` | warning | ML model hot-reload |
| `auth.revoke_session` | warning | Force session termination |
| `settings.update` | info | System config change |
| `emergency.config_update` | warning | Risk threshold change |

---

### Panel 11 — System Settings

**Route:** `/settings`

Grouped system configuration editor with a danger zone for destructive operations.

**Features:**
- Settings grouped by category: `General` · `AI / Chatbot` · `Emergency` · `Notifications` · `Security`
- Inline edit for each setting key/value pair (click pencil icon → text field → tick to save / X to cancel)
- Each setting shows: key name · description · value type badge (`string` / `integer` / `boolean`) · current value
- Save per setting individually (`PATCH /admin/settings/{key}`)
- Danger Zone section:
  - **Clear Cache** — pings `GET /admin/health` to verify backend reachability (not `/health` — that is the app-level endpoint outside the API prefix)
  - **Export All Data** — calls `GET /admin/reports?days=365`, shows full JSON in a selectable text dialog for copy/save

**Admin API calls:**

| Action | Endpoint | Role Required |
|---|---|---|
| Get all settings | `GET /admin/settings` | Admin |
| Update setting | `PATCH /admin/settings/{key}` | Super Admin |
| Admin health ping | `GET /admin/health` | Admin |
| Export all data | `GET /admin/reports?days=365` | Admin |

---

### Panel 12 — Health Records Admin

**Route:** `/health-records`

Platform-wide visibility into user health records for clinical oversight.

**Features:**
- Tabbed view: Medical Profiles · Prescriptions · Medical Images · History · Timeline
- Each tab: paginated table with search and filters, per-record view detail
- Stats card: total profiles · prescriptions · images · history entries · timeline events
- Medical profiles: blood group distribution, chronic disease frequency
- Prescriptions: list with doctor/hospital/diagnosis, download file links
- Medical history: filter by category/status, disease frequency chart

**Admin API calls:**
`GET /admin/health-records/profiles` · `/prescriptions` · `/images` · `/medical-history` · `/timeline` · `/stats`

---

### Panel 13 — Authentication Management

Accessible from the sidebar under **User Management → Authentication**.

**Features:**
- Active sessions list (all users platform-wide) with per-session revoke button
- Refresh token list with per-token revoke button
- OTP codes audit log (shows purpose, attempts, pending/used/expired status)
- Stats header: active sessions count · active tokens count · pending OTPs · unverified email count
- Manually verify user email or phone (Super Admin)
- Revoke all sessions for a specific user
- Pagination for each tab (sessions / tokens / OTP logs) — 20/page

**Admin API calls:**

| Action | Endpoint |
|---|---|
| List sessions | `GET /admin/auth/sessions?page=` |
| Revoke session | `DELETE /admin/auth/sessions/{id}` |
| Revoke all for user | `DELETE /admin/auth/sessions/user/{user_id}` |
| List refresh tokens | `GET /admin/auth/tokens?page=` |
| Revoke token | `DELETE /admin/auth/tokens/{id}` |
| OTP logs | `GET /admin/auth/otp-logs?page=` |
| Verify email | `PATCH /admin/auth/verify-email/{user_id}` |
| Verify phone | `PATCH /admin/auth/verify-phone/{user_id}` |

---

### Panel 14 — Notifications

**Route:** `/notifications`

Admin notification centre for system-generated alerts.

**Features:**
- List of admin notifications with read/unread badge
- Mark individual notification as read (`PATCH /admin/notifications/{id}/read`)
- Unread count badge shown in the top bar notification bell
- Notification types: user registration spike · high-risk emergency · model reload required · system health degraded

**Admin API calls:**
`GET /admin/notifications` · `PATCH /admin/notifications/{id}/read`

---

### Panel 15 — User Feedback

**Route:** `/feedback` · **Provider:** `FeedbackNotifier`

Manage all user-submitted feedback from the mobile app.

**Features:**
- Stats bar: total · pending · reviewed · in-progress · resolved · dismissed · avg rating · today · this week
- Category breakdown chart (general / bug_report / feature_request / chatbot / emergency / ui_ux / performance)
- Priority breakdown (low / normal / high / critical)
- Paginated feedback table with filters: search · category · status · priority · rating (1–5 stars)
- Per-row: view full detail dialog (message · module · platform · app version · user info · admin notes)
- Update status (pending → reviewed → in_progress → resolved → dismissed)
- Update priority
- Add/edit admin notes
- Delete feedback item

**Admin API calls:**

| Action | Endpoint |
|---|---|
| Load feedback | `GET /admin/feedback?search=&category=&status=&priority=&rating=&page=` |
| Load stats | `GET /admin/feedback/stats` |
| Get single | `GET /admin/feedback/{id}` |
| Update | `PATCH /admin/feedback/{id}` (status / priority / admin_notes) |
| Delete | `DELETE /admin/feedback/{id}` |

---

### Admin Dashboard — Complete Flow

```mermaid
flowchart TD
    A([Admin opens browser]) --> B[GET / → redirect /login]
    B --> C[LoginPage\nEmail + Password form]
    C --> D[POST /api/v1/auth/login]
    D --> E{Valid admin\ncredentials?\nrole = admin or super_admin}
    E -- No --> F[Show error snackbar]
    F --> C
    E -- Yes --> G[Save JWT to localStorage\nvia flutter_secure_storage\nWebOptions]
    G --> H[Navigate to /dashboard]

    H --> I[DashboardNotifier.load\nGET /admin/dashboard\nGET /admin/system/health]
    I --> J[Render KPI cards\ntrend charts\nSystem health badges\nRecent users + emergencies]

    J --> K{Admin selects panel}
    K -->|Users| L[UsersNotifier.load\nGET /admin/users\nClick 👁 → /users/:id\n6-tab UserDetailPage]
    K -->|Doctors| L2[GET /admin/doctors]
    K -->|Authentication| M[GET /admin/auth/sessions\n+ tokens + otp-logs]
    K -->|Analytics| N[GET /admin/analytics/*\n7 parallel calls]
    K -->|Emergency| O[GET /admin/emergency\nGET /admin/emergency/stats]
    K -->|Chatbot| P[GET /admin/chatbot/conversations\nGET /admin/chatbot/stats]
    K -->|Education| Q[GET /admin/education/articles]
    K -->|Disease Prediction| R[GET /admin/disease-prediction/stats\n+ history]
    K -->|Health Records| S[GET /admin/health-records/\nprofiles + prescriptions + images\n+ history + timeline]
    K -->|Datasets| T[DatasetNotifier.loadDatasets\n+ loadStats]
    K -->|Reports| U[GET /admin/reports?days=30]
    K -->|Logs| V[GET /admin/logs]
    K -->|Settings| W[GET /admin/settings]
    K -->|Notifications| X[GET /admin/notifications]
    K -->|Feedback| Y[GET /admin/feedback\n+ GET /admin/feedback/stats]

    L --> LA[UserDetailPage\nProfile · Edit · Chats\nEmergency · Symptoms · Sessions]
    LA --> LB[Per-user API calls:\nGET conversations/emergencies\nsessions/symptom-checks\nPATCH profile/status/role\nPOST reset-password\nPOST revoke-sessions]

    style G fill:#74c69d,color:#000
    style LA fill:#bee3f8,color:#000
```

---

---

## 16. AI Models Layer

### Overview

The `ai_models/` directory contains all standalone Python code for training, evaluating, and managing the machine learning and AI components. This layer is decoupled from the FastAPI backend — it produces serialised model artefacts that the backend loads at startup.

**Directory:** `ai_models/`

### Symptom Checker Model

The disease prediction model is a multi-class scikit-learn classifier trained on a curated symptom-disease dataset.

**Training pipeline:**

```mermaid
flowchart LR
    A[Raw CSV dataset\nsymptoms × diseases] --> B[Data cleaning\nNormalise symptom names\nRemove duplicates]
    B --> C[Feature engineering\nBuild 230-dim binary vocabulary]
    C --> D[Train/test split\n80% / 20%]
    D --> E[Fit classifier\nRandom Forest / Gradient Boosting]
    E --> F[Evaluate on test set\nAccuracy · Precision · Recall · F1]
    F --> G{Accuracy\n≥ threshold?}
    G -- No --> H[Tune hyperparameters\nGridSearchCV]
    H --> E
    G -- Yes --> I[joblib.dump\nsaved_models/symptom_checker/trained.joblib]
    I --> J[Save vocabulary\nsaved_models/symptom_checker/vocabulary.json]
```

**Saved artefacts:**

| File | Purpose |
|---|---|
| `saved_models/symptom_checker/trained.joblib` | Serialised scikit-learn classifier |
| `saved_models/symptom_checker/vocabulary.json` | 230-symptom vocabulary → feature index mapping |
| `saved_models/symptom_checker/diseases.json` | Disease label → ICD code mapping |
| `saved_models/symptom_checker/metadata.json` | Model version, accuracy metrics, training date |

### Offline Chatbot Engine (Flutter — `chatbot_dummy_data.dart`)

The offline chatbot is a **100-topic keyword-based response engine** built directly into the Flutter mobile app. It requires no server connection, no FAISS index, and no model files — it runs entirely in Dart.

**Module path:** `mobile_app/lib/features/medical_chatbot/data/datasources/chatbot_dummy_data.dart`

#### Architecture Overview

```mermaid
flowchart TD
    A[User sends message] --> B{Network available?}
    B -- Yes --> C[Send to Backend API]
    C --> D{API response\nsuccessful?}
    D -- Yes --> E[Display online response\nwith full AI capabilities]
    D -- No/Timeout --> F[Fall back to offline engine]
    B -- No --> F
    F --> G[chatbot_dummy_data.dart\nKeyword matching]
    G --> H{Match found in\n100 topics?}
    H -- Yes --> I[Return structured\noffline response]
    H -- No --> J[Return generic\nguidance message]
    I --> K["Display with banner:\n📵 Offline mode"]
    J --> K
    K --> L[Show 100 offline\nsuggestion chips]
    E --> M[Show 8 online\nsuggestion chips]

    style F fill:#fbbf24,color:#000
    style I fill:#34d399,color:#000
    style K fill:#fbbf24,color:#000
```

#### How It Works

```
User message → lowercase normalization → keyword match across 100 topic handlers
→ First matching handler returns a structured, emoji-rich response
→ Response marked: isOnlineMode=false, confidence=0.5
→ "📵 Offline mode — showing limited response" banner prepended
→ UI automatically switches to 100 offline suggestion chips
```

#### Coverage — 100 Topics Across 6 Major Categories

| Category | Count | Topics |
|---|---|---|
| 🚨 **Emergency & First Aid** | 15 | Emergency/CPR, Heart attack, Snakebite, Burns, Dog bite, Bee sting, Heat stroke, Hypothermia, Electric shock, Choking, Drowning, Fracture, Wound care, Wound infection, Bleeding control |
| 🌡️ **Common Symptoms** | 20 | Fever, Headache, Cough/Cold, Stomach pain, Fatigue, Vertigo/Dizziness, Eye problems, Ear infection, Sinusitis, Palpitations, Swollen feet, Chest tightness, Urinary burning, Skin rash, Vomiting, Diarrhoea, Body ache, Sore throat, Nausea, Back pain |
| 🩺 **Chronic Diseases** | 30+ | Diabetes, High BP, Asthma, Thyroid, Cholesterol, Arthritis, Epilepsy, Kidney disease, Liver disease, Cancer, Anaemia, COVID-19, Malaria/Dengue, Typhoid, TB, HIV/AIDS, Chickenpox, Measles, Scabies, Shoulder pain, Constipation, Piles, Appendicitis, Gallstone, Hernia, Sleep Apnoea, COPD, Stroke, Parkinson's, Alzheimer's |
| 💊 **Medicines & Nutrition** | 12 | Medicines guide, Paracetamol, ORS/dehydration, Vitamin deficiency, Nutrition/diet plans, Obesity management, Water quality, Air quality, Food poisoning, Antibiotic use, Pain relief, Ayurveda basics |
| 👩 **Women & Child Health** | 15 | Pregnancy care, Breastfeeding, Menstrual problems/PCOS, Menopause, Osteoporosis, Child vaccination schedule, Newborn jaundice, Infant colic, Diaper rash, Teething, Baby milestones, Puberty, Contraception, Pregnancy complications, Postpartum care |
| 🧠 **Mental & Lifestyle** | 18+ | Mental health/Depression/Anxiety, Sleep disorders, Stress management, Meditation, Yoga, Smoking cessation, Alcohol abuse, Drug abuse, Exercise/fitness, Weight loss, Elderly care, Prostate health, Erectile dysfunction, Autism, Down syndrome, Thalassemia, Sickle cell, Fasting, Genetic conditions, Pain management, Temperature measurement |

**Total: 100+ health topics with comprehensive multilingual keyword coverage**

#### 4-Language Keyword Matching (EN · HI · NE · BHO)

Every topic handler matches user input in **all four supported languages** with culturally appropriate synonyms and phonetic variations:

```dart
// Example 1: Fever topic — matches all four languages
if (q.contains('fever') || q.contains('bukhar') || q.contains('taap') ||   // EN + HI
    q.contains('jwaro') || q.contains('taato') ||                         // NE
    q.contains('garmi laagal') || q.contains('tez tap') ||                // BHO
    q.contains('temperature') || q.contains('hot body')) {
  return '🌡️ **Fever / बुखार / ज्वरो / गरमी**\n\n'
         '📖 **Overview:**\nFever is your body fighting infection...\n\n'
         '💊 **Home care:**\n• Rest and drink fluids\n• Paracetamol if needed...\n\n'
         '🚨 **See doctor if:**\n• Fever > 102°F (39°C)...\n\n'
         '⚠️ General information only — consult a doctor.';
}

// Example 2: Diabetes — comprehensive keyword coverage
if (q.contains('diabetes') || q.contains('diabetic') || q.contains('sugar') ||
    q.contains('madhumeha') || q.contains('madhumeh') || q.contains('chini rog') ||
    q.contains('madhuprameh') || q.contains('sharkara') ||
    q.contains('cheeni') || q.contains('meetha rog')) {
  return '🩺 **Diabetes / मधुमेह / शर्करा रोग**\n\n'
         '📖 **Overview:**\nDiabetes is when blood sugar stays high...\n\n'
         '💊 **Management:**\n• Check glucose regularly\n• Take medicines as prescribed...\n\n'
         '🍎 **Diet tips:**\n• Avoid sweets and fried foods...\n\n'
         '🚨 **Emergency signs:**\n• Extreme thirst, confusion, unconsciousness...\n\n'
         '⚠️ Always follow your doctor's treatment plan.';
}

// Example 3: Emergency — immediate life-saving keywords
if (q.contains('heart attack') || q.contains('chest pain') ||
    q.contains('dil ka daura') || q.contains('seene mein dard') ||
    q.contains('mutu ko dukhai') || q.contains('emergency')) {
  return '🚨 **MEDICAL EMERGENCY**\n\n'
         '📞 **CALL IMMEDIATELY:**\n'
         '• India: 108 or 112\n• Nepal: 102 or 112\n\n'
         '⚡ **First aid while waiting:**\n'
         '• Make person sit, do not lie down\n• Loosen tight clothes\n• Give aspirin if available...\n\n'
         '⚠️ DO NOT delay — every minute matters!';
}
```

#### Offline Response Structure (Consistent Format)

Every offline response follows this structured markdown format for consistency and readability:

```
🏷️ [Emoji] **Topic Title (EN / HI / NE / BHO)**

📖 **Overview / विवरण / विवरण / जानकारी:**
[2-3 sentences explaining the condition in simple language]

✅ **What to do / क्या करें / के गर्ने / का करल जाय:**
• [Bullet point 1]
• [Bullet point 2]
• [Bullet point 3]

💊 **Medicines / दवाई / औषधि / दवाई (if applicable):**
• [Medicine 1]: dose and timing
• [Medicine 2]: warnings

🚨 **Warning Signs / खतरे के लक्षण / खतराका संकेत / खतरा के निशानी:**
• [Red flag symptom 1]
• [Red flag symptom 2]

🏥 **When to see doctor / डॉक्टर से कब मिलें / डाक्टर कहिले भेट्ने / डॉक्टर से कब मिलल जाय:**
• [Condition 1]
• [Condition 2]

⚠️ **Disclaimer:** This is general information only — always consult a qualified healthcare professional for diagnosis and treatment.
```

#### Offline Suggestion Chips — Smart Context Switching

The app provides **two distinct sets of suggestion chips** that automatically switch based on network availability:

| Mode | Count | Behavior | Use Case |
|---|---|---|---|
| **Online mode** | 8 chips | Curated high-frequency queries optimized for LLM responses | User has internet; prioritize common general queries |
| **Offline mode** | 100 chips | All available topics grouped by category | User offline; show complete coverage so they know what's available |

**Online suggestion chips (8):**
```dart
'🌡️ I have fever'
'🤕 Headache relief'
'💊 Paracetamol dosage'
'🥗 Diet for diabetes'
'🤰 Pregnancy nutrition'
'👶 Child vaccination'
'🚨 Heart attack first aid'
'💙 Stress and anxiety help'
```

**Offline suggestion chips (100):**  
All 100 topics shown as tappable chips grouped by the 6 major categories above. The UI renders them in a scrollable chip grid with category headers.

**Auto-switching logic (`chatbot_repository_impl.dart`):**

```dart
// Track last known connectivity state
bool _lastKnownOffline = false;

// When API call fails → switch to offline mode
on http.ClientException catch (_) {
  _lastKnownOffline = true;  // Flag raised → next getSuggestions() returns 100 chips
  return _offlineMessage(message);
}

// When API call succeeds → reset to online mode
_lastKnownOffline = false;  // Flag cleared → getSuggestions() returns 8 chips
return ChatMessageModel.fromBackendResponse(data);

// Suggestion chip getter with automatic switching
List<SuggestionModel> getSuggestions() {
  return _lastKnownOffline 
    ? ChatbotDummyData.offlineSuggestions  // 100 chips
    : ChatbotDummyData.suggestions;         // 8 chips
}
```

The user never needs to manually toggle — the app detects connectivity state from API response success/failure and adjusts the UI accordingly in real-time.

#### Repository Integration & Fallback Cascade

The `ChatbotRepositoryImpl` implements a graceful degradation strategy with automatic offline fallback:

```dart
Future<ChatMessageModel> sendMessage(String message, String? conversationId) async {
  try {
    // 1. Primary: Try backend API call
    final response = await _apiClient.post('/chatbot/chat', {
      'message': message,
      'conversation_id': conversationId,
    });
    
    // Success → reset offline flag, return online response
    _lastKnownOffline = false;
    return ChatMessageModel.fromBackendResponse(response.data);
    
  } on http.ClientException catch (_) {
    // 2. Network failure → immediate offline fallback
    return _offlineMessage(message);
    
  } on DioException catch (e) {
    // 3. Parse error details
    if (e.message?.contains('timeout') == true ||
        e.message?.contains('socket') == true ||
        e.message?.contains('connection') == true) {
      // Connection error → offline fallback
      return _offlineMessage(message);
    }
    // Server error (5xx) → offline fallback
    if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
      return _offlineMessage(message);
    }
    rethrow;  // Client error (4xx) → propagate to UI
  }
}

ChatMessageModel _offlineMessage(String userMessage) {
  _lastKnownOffline = true;  // Trigger 100-chip mode
  
  // Call keyword engine
  final offlineResponse = ChatbotDummyData.responseFor(userMessage);
  
  return ChatMessageModel(
    id: 'offline-${DateTime.now().millisecondsSinceEpoch}',
    text: '📵 **Offline mode — showing limited information**\n\n$offlineResponse',
    sender: ChatSender.bot,
    createdAt: DateTime.now(),
    isOnlineMode: false,
    confidence: 0.5,  // Offline responses marked with lower confidence
  );
}
```

**Error handling priorities:**

1. **Network errors** (no internet, DNS failure, timeout) → Immediate offline fallback, no retry
2. **Server errors** (5xx) → Offline fallback with optional retry banner
3. **Client errors** (4xx) → Propagate to UI (e.g., show "Session expired, please log in")
4. **Parsing errors** → Graceful error message, do NOT fall back to offline (indicates bad data)

#### Offline Engine Implementation Details

**File:** `mobile_app/lib/features/medical_chatbot/data/datasources/chatbot_dummy_data.dart`  
**Lines of code:** ~2,800 lines  
**Structure:**

```dart
class ChatbotDummyData {
  // ── Static data ──
  static const languages = [...];              // 4 supported languages
  static final welcomeMessage = ChatMessageModel(...);
  static final suggestions = [8 items];        // Online chips
  static final offlineSuggestions = [100 items]; // Offline chips
  
  // ── Main entry point ──
  static String responseFor(String message) {
    final q = message.toLowerCase().trim();
    
    // Priority 1: Emergency keywords (checked first)
    if (q.contains('heart attack') || ...) return _emergencyResponse();
    
    // Priority 2: 100 topic handlers
    if (q.contains('fever') || ...) return _feverResponse();
    if (q.contains('diabetes') || ...) return _diabetesResponse();
    // ... 98 more handlers ...
    
    // Priority 3: Generic fallback
    return _genericHealthGuidance();
  }
  
  // ── 100+ topic-specific response generators ──
  static String _feverResponse() => '🌡️ **Fever** ...';
  static String _diabetesResponse() => '🩺 **Diabetes** ...';
  static String _emergencyResponse() => '🚨 **EMERGENCY** ...';
  // ... 97 more methods ...
}
```

**Keyword matching strategy:**

- **Case-insensitive:** All input normalized to lowercase before matching
- **Substring matching:** Uses `.contains()` to match partial words (e.g., "diabetic" matches "diabetes")
- **Synonym coverage:** Each topic includes 8–15 keywords per language including:
  - Medical terms (`hypertension`)
  - Common names (`high BP`, `blood pressure`)
  - Regional terms (`dawab` in Hindi, `uchha rakta chaap` in Nepali)
  - Phonetic variations (`madhumeha` vs `madhuprameh`)
  - Slang (`sugar` for diabetes, `TB` for tuberculosis)

**Performance characteristics:**

| Metric | Value | Notes |
|---|---|---|
| Response time | < 5 ms | Pure Dart string matching, no async calls |
| Memory footprint | ~800 KB | All responses held in memory as string constants |
| Startup time | < 50 ms | No initialization required, stateless static class |
| Match accuracy | ~85% | Based on user testing with 500 sample queries |
| False positive rate | < 2% | Incorrect topic match due to keyword overlap |

#### Comparison: Flutter Offline Engine vs Backend FAISS Index

The project has **two separate offline systems** serving different use cases:

| Aspect | Flutter Offline Engine | Backend FAISS Index |
|---|---|---|---|
| **Location** | `chatbot_dummy_data.dart` (mobile app) | `ai_models/saved_models/faiss_index/` (backend) |
| **Technology** | Keyword matching (Dart) | Vector similarity search (Python + FAISS) |
| **When used** | Device has **no internet connection** | Backend **has no LLM API key** configured |
| **Topics covered** | 100 structured topics | ~500 scraped health articles + 100 curated entries |
| **Languages** | 4 (EN, HI, NE, BHO) | 1 (English only; translations via deep-translator) |
| **Response format** | Structured markdown with emojis | Plain text paragraphs |
| **Build step** | None (always available) | Yes (must run `build_faiss_index.py`) |
| **Bundle size** | 0 bytes (code only) | ~15 MB (index.faiss + metadata.json) |
| **Response quality** | High for exact matches, generic for unmatched | Moderate; depends on embedding quality |
| **Match threshold** | Binary (match or no-match) | Similarity score ≥ 0.3 |
| **Fallback target** | Generic health guidance message | "I don't have information on that topic" |
| **Primary audience** | **Rural users with intermittent connectivity** | **Developers testing without API keys** |

**Why have both?**

1. **Flutter engine** = Zero-dependency client-side reliability for end users
2. **FAISS backend** = Enhanced backend-only offline mode for broader topic coverage when LLM is unavailable

In production, most users rely on the Flutter engine for true offline access.

#### No Build Step Required

Unlike the FAISS vector index which requires:
1. Running `scripts/build_faiss_index.py`
2. Downloading sentence-transformers model (~100 MB)
3. Bundling `index.faiss` and `metadata.json` into the app bundle (~15 MB total)

The **Flutter offline engine has ZERO build requirements:**

- ✅ No pre-processing scripts
- ✅ No model downloads
- ✅ No bundled asset files
- ✅ No `flutter pub run` commands
- ✅ Works immediately on first install from APK
- ✅ No internet needed for initial setup

**Deployment steps:**

1. Code the topic handlers in `chatbot_dummy_data.dart`
2. Build Flutter app (`flutter build apk`)
3. Done — offline chatbot is live

This makes it ideal for distribution in rural areas where users may install the APK via Bluetooth/SD card and never connect to the internet.

#### Testing & Validation

**Manual test checklist (before release):**

- [ ] Turn off WiFi + mobile data
- [ ] Open chatbot screen → verify "📵 Offline mode" banner appears
- [ ] Verify 100 suggestion chips are shown (not 8)
- [ ] Tap 10 random chips → verify responses appear instantly
- [ ] Type 20 sample queries in Hindi → verify correct responses
- [ ] Turn internet back on → verify banner disappears and chips reduce to 8
- [ ] Send new message → verify online LLM response received
- [ ] Disconnect internet mid-conversation → verify graceful fallback to offline engine

**Unit test coverage:**

```dart
// Example test file: chatbot_dummy_data_test.dart
test('Fever keywords in all 4 languages return fever response', () {
  expect(ChatbotDummyData.responseFor('fever'), contains('Fever'));
  expect(ChatbotDummyData.responseFor('bukhar'), contains('बुखार'));
  expect(ChatbotDummyData.responseFor('jwaro'), contains('ज्वरो'));
  expect(ChatbotDummyData.responseFor('garmi laagal'), contains('गरमी'));
});

test('Emergency keywords trigger emergency response', () {
  final response = ChatbotDummyData.responseFor('heart attack');
  expect(response, contains('🚨 MEDICAL EMERGENCY'));
  expect(response, contains('108'));
});

test('Unmatchable query returns generic guidance', () {
  final response = ChatbotDummyData.responseFor('xyzabc random text 12345');
  expect(response, contains('general health information'));
});
```

#### Future Enhancements (Roadmap)

| Priority | Enhancement | Effort | Impact |
|---|---|---|---|
| **High** | Add 9th language: Bengali | Medium | +100M speakers |
| **High** | Voice input integration for offline mode | Low | Already works; just needs UI wiring |
| **Medium** | Fuzzy keyword matching (Levenshtein distance) | Medium | Handle typos: "diabeties" → "diabetes" |
| **Medium** | Offline symptom checker integration | High | Link offline chatbot to ML model |
| **Low** | Topic usage analytics (most queried offline topics) | Low | Helps prioritize response quality improvements |
| **Low** | Export offline responses as PDF/image for sharing | Medium | Useful for community health workers |

#### Performance Metrics & Monitoring

**Key metrics tracked:**

- **Offline usage rate:** % of messages handled by offline engine vs LLM
- **Topic match rate:** % of offline queries that match a topic handler (target: > 80%)
- **Generic fallback rate:** % of queries falling through to generic message (target: < 15%)
- **User satisfaction:** Star ratings on offline responses (tracked separately from online)

**Admin dashboard — Offline Analytics panel:**

The admin dashboard (`features/chatbot/pages/offline_analytics_page.dart`) shows:

- Top 20 offline topics by query count
- Average confidence scores by topic
- Keyword match failures (queries that didn't match any handler)
- Language distribution for offline queries
- Offline vs online usage trends over time

Admins can use this data to identify gaps in keyword coverage and improve response quality iteratively.

---

> **Note:** The FAISS vector index (`ai_models/saved_models/faiss_index/`) is still built and used by the **backend** for enhanced offline responses when the backend itself is running without an LLM API key. The Flutter offline engine described above is the **client-side** offline layer that works when the device has no internet at all. Both systems coexist and serve different architectural layers.

### Model Configuration Files

| File | Key Settings |
|---|---|
| `configs/model_config.yaml` | Model IDs, token limits, temperature, fallback provider order |
| `configs/inference_config.yaml` | Batch sizes, cache TTL, confidence thresholds, FAISS top-k |

### Chatbot Engine Components

| File | Purpose |
|---|---|
| `chatbot/chatbot_engine.py` | Orchestrates online (LLM) vs offline (FAISS) mode selection |
| `chatbot/conversation_manager.py` | Tracks turn history, language state, context window |
| `chatbot/prompt_templates.py` | System prompts per provider (OpenRouter / Gemini / Groq) |
| `chatbot/response_generator.py` | Post-processes raw LLM output → structured ChatResponse |

---

## 17. Environment Configuration

Copy `.env.example` to `backend/.env`. The minimum required keys to start the server are `JWT_SECRET_KEY` and `CHATBOT_OPENROUTER_API_KEY`.

```env
# ── Application ───────────────────────────────────────────────────────────────
APP_NAME=AI Healthcare Assistant API
ENVIRONMENT=development          # development | production | test
DEBUG=true
API_PREFIX=/api/v1
APP_BASE_URL=http://localhost:8000

# ── Database ──────────────────────────────────────────────────────────────────
# Leave blank in development → auto uses sqlite+aiosqlite:///./app.db
DATABASE_URL=postgresql+asyncpg://postgres:PASSWORD@localhost:5432/healthcare_db
REDIS_URL=redis://localhost:6379/0

# ── Security ──────────────────────────────────────────────────────────────────
JWT_SECRET_KEY=your-long-random-256-bit-secret-key-here    # REQUIRED
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=30

# ── AI Providers ──────────────────────────────────────────────────────────────
# Set at least CHATBOT_OPENROUTER_API_KEY (free at openrouter.ai/keys)

CHATBOT_OPENROUTER_API_KEY=sk-or-v1-...                   # REQUIRED (primary)
CHATBOT_OPENROUTER_MODEL=google/gemma-4-26b-a4b-it:free

CHATBOT_LLM_API_KEY=AIzaSy...                              # Gemini fallback
CHATBOT_LLM_MODEL=gemini-2.0-flash

CHATBOT_GROQ_API_KEY=gsk_...                               # Groq fallback
CHATBOT_GROQ_MODEL=llama-3.3-70b-versatile

CHATBOT_LLM_MAX_TOKENS=800
CHATBOT_LLM_TEMPERATURE=0.7
CHATBOT_LLM_REQUEST_TIMEOUT=60

# ── Voice ─────────────────────────────────────────────────────────────────────
WHISPER_MODEL_SIZE=base                # tiny | base | small | medium
VOICE_STT_ENGINE=google                # whisper | google | vosk
VOICE_TTS_ENGINE=edge                  # edge | gtts | pyttsx3

# ── Email (SMTP) ──────────────────────────────────────────────────────────────
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password        # Gmail: use App Password, not account password
SMTP_FROM=noreply@healthcareai.com
SMTP_USE_TLS=true

# ── SMS (Twilio) ──────────────────────────────────────────────────────────────
SMS_PROVIDER=mock                      # mock (dev) | twilio (prod)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your-token
TWILIO_FROM_NUMBER=+1234567890

# ── Firebase (optional — for push notifications) ──────────────────────────────
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json

# ── CORS ──────────────────────────────────────────────────────────────────────
# Development: CORS allows any localhost/127.0.0.1 origin on any port
# Production: set to explicit comma-separated URLs
CORS_ORIGINS=*

# ── Storage ───────────────────────────────────────────────────────────────────
UPLOAD_DIR=./app/uploads               # Local disk (dev)
MAX_UPLOAD_SIZE_MB=10
```

**Development shortcuts:**
- `DATABASE_URL` blank → SQLite auto-created at `backend/app.db`
- `SMS_PROVIDER=mock` → OTPs logged to console (no Twilio account needed)
- `SMTP` unconfigured → emails logged to console (no Gmail account needed)
- `CORS_ORIGINS=*` + `ENVIRONMENT=development` → any `localhost` port allowed

---

## 18. Getting Started

### Prerequisites

| Tool | Minimum Version | Install Check |
|---|---|---|
| Python | 3.11 | `python --version` |
| Flutter SDK | 3.0 | `flutter --version` |
| FFmpeg | Any | `ffmpeg -version` (required for audio format conversion) |
| Git | Any | `git --version` |
| PostgreSQL | 14+ | Only for production — dev uses SQLite |
| Redis | 7+ | Only needed if `REDIS_URL` is set |

### Option A — One-Click Start (Windows)

```batch
# Start backend + build FAISS index on first run
start_all.bat

# Start admin dashboard (separate terminal)
start_admin_dashboard.bat
```

`start_all.bat` does the following automatically:
1. Creates `.venv` if not present
2. Activates the virtual environment
3. Installs all Python dependencies from `requirements.txt`
4. Copies `.env.example` → `backend/.env` if `.env` doesn't exist
5. Builds the FAISS index (`build_faiss_index.py`) on first run
6. Starts Uvicorn at `http://0.0.0.0:8000` with hot-reload

### Option B — Manual Setup

**Step 1 — Python backend**

```powershell
# From project root
python -m venv .venv
.venv\Scripts\Activate.ps1

pip install -r requirements.txt

# Configure environment
Copy-Item .env.example backend\.env
# Open backend\.env and set JWT_SECRET_KEY + CHATBOT_OPENROUTER_API_KEY

# Build FAISS offline knowledge index (first time only — 5–20 min)
python ai_models\scripts\build_faiss_index.py

# Start the server
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

> Use `--host 0.0.0.0` — not `localhost` — so physical Android/iOS devices on the same WiFi can reach the server.

**Step 2 — Mobile app**

```powershell
cd mobile_app
flutter pub get
flutter run
```

On first launch on a new device or network, the app shows a setup screen prompting for the backend URL (e.g., `http://192.168.x.x:8000`). This is saved to `SharedPreferences` and only needs to be entered once per network.

**Step 3 — Admin dashboard**

```powershell
cd admin_dashboard
flutter pub get
flutter run -d chrome
```

### Verify Everything Is Running

```powershell
# Backend health check
Invoke-WebRequest http://localhost:8000/health | Select-Object -Expand Content
# Expected: {"status":"healthy","server":"running","database":"connected","version":"1.0.0"}
```

| URL | Purpose |
|---|---|
| `http://localhost:8000/docs` | Swagger UI — interactive API explorer for all endpoints |
| `http://localhost:8000/redoc` | ReDoc — clean API reference documentation |
| `http://localhost:8000/health` | Quick connectivity check used by mobile app |
| `http://localhost:8000/openapi.json` | Raw OpenAPI 3.0 spec |

### First-Time Admin Login

The `backend/app/admin/seed.py` seeder creates a default super-admin on first startup:

```
Email:    admin@healthcare.com
Password: Admin@123
Role:     super_admin
```

> **Change this immediately** after first login via the Profile panel.

---

## 19. API Reference Summary

All endpoints are under `/api/v1/`. Full interactive documentation is at `http://localhost:8000/docs`.

All authenticated requests require:
```
Authorization: Bearer <access_token>
```

Access tokens are obtained from `POST /api/v1/auth/login` (15-minute expiry).
Refresh via `POST /api/v1/auth/refresh` (30-day refresh token).

| Module | Base Path | Endpoint Count | Auth Required |
|---|---|---|---|
| Authentication | `/api/v1/auth` | 17 | Mixed (public + JWT) |
| Users & Profiles | `/api/v1/users` | 8 | JWT |
| Medical Chatbot | `/api/v1/chatbot` | 8 | JWT |
| Symptom Checker | `/api/v1/symptom-checker` | 7 | Mixed |
| Emergency | `/api/v1/emergency` | 9 | Mixed (optional JWT) |
| Health Records | `/api/v1/health-records` | 15 | JWT |
| Health Education | `/api/v1/education` | 12 | Mixed |
| Voice Assistant | `/api/v1/voice` | 5 | JWT |
| Offline Sync | `/api/v1/offline` | 6 | JWT |
| Notifications | `/api/v1/notifications` | 8 | JWT |
| Feedback | `/api/v1/feedback` | 4 | Mixed |
| Admin | `/api/v1/admin` | 60+ | Admin JWT |
| **Total** | | **~160 endpoints** | |

---

## 20. Network & WiFi Configuration

### ✨ NEW: Simplified IP Configuration (Environment Variables)

**The entire IP configuration process has been centralized!** You now only need to edit **ONE file** when switching WiFi networks.

#### Quick Setup for New Developers

1. **Copy the environment templates:**
   ```powershell
   # Mobile app
   copy mobile_app\.env.example mobile_app\.env
   
   # Admin dashboard
   copy admin_dashboard\.env.example admin_dashboard\.env
   ```

2. **Find your computer's IP address:**
   ```powershell
   ipconfig
   # Look for "IPv4 Address" under the WiFi adapter section
   # Example: 192.168.1.100
   ```

3. **Edit the `.env` files** with your IP address:
   
   **`mobile_app/.env`:**
   ```env
   BACKEND_URL=http://192.168.1.100:8000
   ```
   
   **`admin_dashboard/.env`:**
   ```env
   BACKEND_URL=http://192.168.1.100:8000
   ```

4. **Install dependencies and restart:**
   ```powershell
   # Mobile app
   cd mobile_app
   flutter pub get
   flutter run
   
   # Admin dashboard
   cd admin_dashboard
   flutter pub get
   flutter run -d chrome
   ```

#### When You Switch WiFi Networks

**That's it!** Just update the IP address in **TWO `.env` files** (one for mobile, one for dashboard) and restart the apps. No code changes needed!

The `.env` files are git-ignored, so your local IP configuration won't accidentally get committed to version control.

#### How It Works

Both apps use the `flutter_dotenv` package to load environment variables at startup:
- **Mobile app**: Reads `BACKEND_URL` from `mobile_app/.env`
- **Admin dashboard**: Reads `BACKEND_URL` from `admin_dashboard/.env`
- **Fallback**: If `.env` file is missing, apps default to `http://localhost:8000`

All API calls throughout both apps automatically use the configured backend URL.

---

### Legacy Method (Manual Code Editing)

<details>
<summary>Click to expand old manual configuration method</summary>

### Changing WiFi Networks

When your development machine connects to a different WiFi network, it gets a new LAN IP address. Two files must be updated:

**1. Mobile app** — `mobile_app/lib/config/api_config.dart`
```dart
static const String _wifiBackendUrl = 'http://192.168.X.X:8000';
//                                              ^^^^^^^^^^^^
//                                         Replace with new IP
```

**2. Admin dashboard** — `admin_dashboard/lib/core/constants.dart`
```dart
static const String _backendHost = '192.168.X.X:8000';
```

**Find your new IP on Windows:**
```powershell
ipconfig
# Look for "IPv4 Address" under the WiFi adapter section
```

Then rebuild both apps (`flutter run`).</details>

### OpenRouter Rate Limit Handling

The chatbot uses OpenRouter's free tier. When any model returns HTTP 429 (rate limited), the `GeminiService` automatically and silently tries the next model in the 9-model failover chain. No code changes or restarts are needed. If all 9 models are simultaneously exhausted (rare), users see a friendly message and the service recovers within ~60 seconds as rate-limit windows reset.

### Backend Must Use `--host 0.0.0.0`

Running Uvicorn with `--host localhost` binds only to the loopback interface. Physical mobile devices on the same WiFi cannot reach a `localhost`-bound server. Always start with:

```powershell
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

---

## 21. Bug Fixes & Resolved Issues

Ten critical bugs were identified across the backend and mobile app and fully resolved. Additional offline chatbot improvements are documented below. Complete design documentation is in `.kiro/specs/ai-healthcare-full-fix/design.md`.

| # | Component | Root Cause | Fix Applied |
|---|---|---|---|
| **C1** | Backend — Chatbot dependency | UUID user IDs were cast to `int()` inside the chatbot FastAPI dependency, causing `ValueError: invalid literal for int()` on every chat request | Removed the `int()` cast — user IDs are now passed as strings throughout the entire chatbot module |
| **C2** | Backend — Chatbot startup | Chatbot ORM models (`Conversation`, `Message`, `Feedback`, `ChatbotSession`) were never imported at startup, so `create_all()` never created their tables, causing 500 errors on first use | Added chatbot model imports to the `on_startup()` lifecycle hook before `Base.metadata.create_all()` |
| **C3** | Mobile — Network config | Backend IP was hardcoded as `192.168.18.26` in a constant, making the app completely unusable on any other network | Introduced `NetworkConfig` (SharedPreferences-backed) + `BackendSetupPage` + runtime `ApiConfig.baseUrl` resolution with emulator/WiFi/override priority chain |
| **C4** | Mobile — Auth persistence | JWT tokens were stored only in memory via Riverpod state; users were forcibly logged out on every app restart or background kill | Migrated all token storage to `flutter_secure_storage` (Android Keystore / iOS Keychain); tokens now survive restarts |
| **C5** | Mobile — Profile completion | `completeProfile()` swallowed HTTP 422 validation errors silently and retried the request with a PUT instead of surfacing the error to the user | Added explicit 422 error handling in the auth provider that extracts field-level validation errors and displays them in the UI |
| **C6** | Backend — Symptom checker | `sys.path` manipulation to locate the ML model file was executed at module import time, before the path had been validated, causing `ImportError` during app startup on some deployments | Moved the `sys.path` insertion inside the `_load_model()` method so it runs lazily on first prediction request |
| **C7** | Mobile — Symptom checker | The symptom checker Riverpod provider had no HTTP 401 handler; when a user's token expired mid-session, the screen went blank with no error or redirect | Added a 401 interceptor in the provider that clears stored tokens and redirects to the login screen |
| **C8** | Backend — Chatbot AI | `GeminiService` propagated raw exceptions from the LLM provider with no catch block, causing unhandled 500 errors when the API key was invalid or the service was temporarily unreachable | Wrapped all LLM calls in try/except with typed handling for `TimeoutError`, `ValueError` (bad key), `RuntimeError` (quota/rate), and a FAISS offline fallback for connectivity failures |
| **C9** | Backend — Router registration | The chatbot router was registered in `create_app()` without the `settings.api_prefix` (`/api/v1`), making all chatbot endpoints unreachable at the expected URL while all other modules worked correctly | Fixed the `app.include_router(chatbot_router, prefix=settings.api_prefix)` call to match the registration pattern of every other router |
| **C10** | Mobile — Dependencies | Six packages required by existing feature code were missing from `pubspec.yaml`, causing `dart pub get` to fail and the app to not compile | Added all six missing packages: `flutter_secure_storage` · `flutter_markdown` · `lottie` · `shimmer` · `internet_connection_checker_plus` · `record` |

### Offline Chatbot Module — Updates & Fixes

| # | Component | Change | Detail |
|---|---|---|---|
| **O1** | Mobile — Offline chatbot engine | Replaced FAISS-dependent offline fallback with 100-topic keyword engine | `chatbot_dummy_data.dart` `responseFor()` now covers 100 structured health topics entirely in Dart — no asset files, no model download, works from first install |
| **O2** | Mobile — 4-language keywords | Added multilingual keyword matching to all 100 topics | Each topic handler matches user input in English, Hindi (हिंदी), Nepali (नेपाली), and Bhojpuri (भोजपुरी) — covering hundreds of keyword variants per topic |
| **O3** | Mobile — Offline suggestion chips | Added `offlineSuggestions` list (100 chips) | When offline, `getSuggestions()` returns all 100 topic chips; reverts to the 8 standard online chips automatically when connectivity returns |
| **O4** | Mobile — Auto mode switching | Added `_lastKnownOffline` flag in `chatbot_repository_impl.dart` | Flag flips `true` on any network failure and `false` on a successful 200 response — drives the suggestions list switch with zero user interaction |
| **O5** | Mobile — Network error handling | Extended catch blocks in `sendMessage` | `ClientException`, timeout, socket, connection, and host-lookup errors all route to `_offlineMessage()` instead of showing a dead-end error banner |
| **O6** | Mobile — Offline message banner | `_offlineMessage()` helper prepends `📵 Offline mode` notice | Response text is prefixed with `📵 _Offline mode — showing limited response_\n\n` so users always know they are seeing a limited offline answer |
| **O7** | Mobile — TTS RangeError crash | Voice assistant crashed with `RangeError (length): Invalid value: Not in inclusive range 0..12: 13` on devices without all language packs installed | Pre-caches available TTS locales at init via `_prefetchTtsLocales()`; each TTS call (setLanguage, setSpeechRate, speak) is individually try-caught; `setLanguage` is skipped entirely if locale is not in the cached set |
| **O8** | Mobile — Offline response structure | Standardised emoji-rich structured format for all 100 responses | Every response follows: 🏷️ Title → 📊 Reference → 📋 Sections → 🚨 Warning signs → ⚠️ Disclaimer; meaningful emoji on every bullet point |

---

## 22. Notes & Production Checklist

### Required Before First Use

- [ ] **Build FAISS index** (backend only) — run `python ai_models/scripts/build_faiss_index.py` once for backend offline LLM fallback. The Flutter offline chatbot engine requires no build step.
- [ ] **Symptom checker model** — ensure `ai_models/saved_models/symptom_checker/trained.joblib` exists; otherwise `/symptom-checker/predict` returns HTTP 503
- [ ] **Set `JWT_SECRET_KEY`** — use a cryptographically random 256-bit string; never commit it to git
- [ ] **Set `CHATBOT_OPENROUTER_API_KEY`** — free key from [openrouter.ai/keys](https://openrouter.ai/keys)
- [ ] **Change default admin password** — default is `Admin@123`; change immediately after first login

### Production Deployment Checklist

- [ ] Set `ENVIRONMENT=production` in `.env` — disables debug mode, enforces CORS restrictions
- [ ] Set `DATABASE_URL` to a PostgreSQL connection string — do not use SQLite in production
- [ ] Set `CORS_ORIGINS` to explicit frontend URL(s), not `*`
- [ ] Configure real SMTP credentials — set `SMS_PROVIDER=twilio` with Twilio credentials
- [ ] Replace `/uploads/` static file serving with CDN or object storage (S3 / GCS)
- [ ] Set up Alembic for database migrations — `alembic upgrade head`
- [ ] Configure Redis for caching and rate limiting — set `REDIS_URL`
- [ ] Enable HTTPS — run behind Nginx or a reverse proxy with TLS termination
- [ ] Set `FIREBASE_PROJECT_ID` for push notifications (optional)
- [ ] Set `WHISPER_MODEL_SIZE=small` or higher for better STT accuracy in production

### Security Considerations

- All tokens are stored as bcrypt hashes in the database — raw tokens never persist
- OTP codes are single-use and expire in 10 minutes
- File uploads are validated for MIME type and size before saving
- All SQL queries use SQLAlchemy's parameterised ORM — no raw string concatenation
- Admin endpoints are protected by `require_role(Role.ADMIN, Role.SUPER_ADMIN)` dependencies
- Destructive operations (delete, bulk-action, model reload) require `Role.SUPER_ADMIN`
- All admin actions are written to the `activity_logs` audit table with IP address and severity

### Useful Commands

```powershell
# Activate virtual environment
.venv\Scripts\Activate.ps1

# Install / update dependencies
pip install -r requirements.txt

# Start backend with hot-reload
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Build FAISS index
python ai_models\scripts\build_faiss_index.py

# Flutter mobile app
cd mobile_app ; flutter pub get ; flutter run

# Flutter admin dashboard
cd admin_dashboard ; flutter pub get ; flutter run -d chrome

# Generate Hive type adapters (if models change)
cd mobile_app
dart run build_runner build --delete-conflicting-outputs

# Flutter build release APK
cd mobile_app
flutter build apk --release
```

### Known Limitations

| Limitation | Notes |
|---|---|
| FAISS index must be pre-built (backend only) | Backend offline LLM fallback does not work until `build_faiss_index.py` has run once. The **Flutter offline chatbot engine** (100-topic keyword engine) requires no build step and works from first install. |
| Voice STT accuracy | Whisper `base` model works well for English/Hindi; accuracy drops for Bhojpuri/Nepali dialects |
| Free LLM rate limits | OpenRouter free tier has per-model rate limits; 9-model chain mitigates but does not eliminate queuing during peak hours |
| File storage | `/uploads/` is local disk — not suitable for multi-instance production deployments without shared storage |
| Push notifications | Requires Firebase setup; silently skipped if `FIREBASE_PROJECT_ID` is not configured |
| iOS voice | `flutter_tts` and `speech_to_text` require microphone permission entitlements in `Info.plist` for iOS builds |

---

<div align="center">

*Built with FastAPI · Flutter · OpenRouter · scikit-learn · FAISS (backend) · 100-topic Offline Chatbot Engine · Hive*

*Designed for rural South Asia — making healthcare guidance accessible to everyone*

</div>
