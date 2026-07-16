# System Architecture Diagram — AI Healthcare Assistant

This file contains a system architecture diagram showing the main components, data flow, and integrations across the mobile app, admin dashboard, backend, AI models, and external services.

```mermaid
flowchart LR
  subgraph Client[Clients]
    Mobile[Mobile App\nFlutter]
    Admin[Admin Dashboard\nFlutter Web]
  end

  subgraph Backend[Backend / API Layer]
    API[FastAPI API]
    Auth[Authentication & Authorization]
    Symptom[Symptom Checker Service]
    Chatbot[Medical Chatbot Service]
    Emergency[Emergency Detection Service]
    Sync[Offline Sync Service]
    HealthRecords[PHR Service]
    Analytics[Analytics + Admin APIs]
    DB[SQLAlchemy / Database]
  end

  subgraph AI[AI / ML Layer]
    Embeddings[Embeddings + Vector Store]
    Retriever[Retrieval Service]
    LLM[LLM Provider]
    SymptomModel[Symptom ML Models]
    EmergencyModel[Emergency Risk Model]
  end

  subgraph External[External Services]
    Notification[Notification / SMS / Email]
    Voice[STT / TTS]
    Storage[File Storage / Model Artifacts]
  end

  Mobile -->|REST API| API
  Admin -->|REST API| API
  API --> Auth
  API --> Symptom
  API --> Chatbot
  API --> Emergency
  API --> Sync
  API --> HealthRecords
  API --> Analytics
  Symptom --> SymptomModel
  Chatbot --> Retriever
  Retriever --> Embeddings
  Retriever --> LLM
  Emergency --> EmergencyModel
  API --> DB
  Analytics --> DB
  Sync --> DB
  HealthRecords --> DB
  Notification <-- Emergency
  API --> Voice
  API --> Storage
  Storage <-- SymptomModel
  Storage <-- EmergencyModel
  Storage <-- Embeddings
  Admin --> Analytics
  Admin -->|trigger retrain| Storage
```

Notes:

- This is a top-level system architecture diagram.
- Use a Mermaid-compatible renderer in VS Code or GitHub.
- It emphasizes the major components and how they connect.
