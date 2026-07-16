# System Architecture Diagram — AI Healthcare Assistant

This file contains a system architecture diagram showing the main components, data flow, and integrations across the mobile app, admin dashboard, backend, AI models, and external services.

```mermaid
flowchart TD
  Frontend["Frontend Layer\nMobile App (Flutter)\nAdmin Dashboard (Flutter Web)"]
  Backend["Backend API Layer\nFastAPI + SQLAlchemy\nAuth, Symptom Checker, Chatbot, Emergency, Offline Sync, PHR"]
  Database["Database Layer\nPostgreSQL / SQLite\nSQLAlchemy ORM"]
  AI["AI / ML Module\nEmbeddings + Vector Store\nRAG Retriever + LLM\nSymptom & Emergency Models"]
  External["External Services\nNotifications / SMS / Email\nSTT / TTS / Voice\nModel Artifact Storage"]

  Frontend -->|HTTPS REST| Backend
  Backend -->|CRUD / query| Database
  Backend -->|retrieve / infer| AI
  Backend -->|notify / escalate| External
  AI -->|model artifacts| External
  Backend -->|voice APIs| External
  Frontend -->|admin analytics| Backend
  Backend -->|store model files| External
```

Notes:

- This is a top-level system architecture diagram.
- Use a Mermaid-compatible renderer in VS Code or GitHub.
- It emphasizes the major components and how they connect.
