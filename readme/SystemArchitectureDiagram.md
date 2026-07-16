# System Architecture Diagram — AI Healthcare Assistant

This file contains a system architecture diagram showing the main components, data flow, and integrations across the mobile app, admin dashboard, backend, AI models, and external services.

```mermaid
flowchart LR
  MobileApp[Mobile App]
  AdminDashboard[Admin Dashboard]
  BackendAPI[FastAPI Backend]
  AuthService[Auth Service]
  SymptomChecker[Symptom Checker]
  ChatbotService[Chatbot Service]
  EmergencyService[Emergency Service]
  SyncService[Offline Sync]
  HealthRecords[PHR Service]
  AnalyticsService[Analytics / Admin APIs]
  Database[Database]
  EmbeddingsService[Embeddings & Vector Store]
  RetrieverService[Retrieval Service]
  LLMProvider[LLM Provider]
  SymptomModel[Symptom ML Model]
  EmergencyModel[Emergency Risk Model]
  NotificationService[Notification / SMS / Email]
  VoiceService[STT / TTS]
  StorageService[Model Artifact Storage]

  MobileApp -->|REST| BackendAPI
  AdminDashboard -->|REST| BackendAPI
  BackendAPI --> AuthService
  BackendAPI --> SymptomChecker
  BackendAPI --> ChatbotService
  BackendAPI --> EmergencyService
  BackendAPI --> SyncService
  BackendAPI --> HealthRecords
  BackendAPI --> AnalyticsService
  BackendAPI --> Database
  SymptomChecker --> SymptomModel
  ChatbotService --> RetrieverService
  RetrieverService --> EmbeddingsService
  RetrieverService --> LLMProvider
  EmergencyService --> EmergencyModel
  SyncService --> Database
  HealthRecords --> Database
  AnalyticsService --> Database
  EmergencyService --> NotificationService
  BackendAPI --> VoiceService
  BackendAPI --> StorageService
  SymptomModel --> StorageService
  EmergencyModel --> StorageService
  EmbeddingsService --> StorageService
  AdminDashboard --> AnalyticsService
  AdminDashboard -->|trigger retrain| StorageService
```

Notes:

- This is a top-level system architecture diagram.
- Use a Mermaid-compatible renderer in VS Code or GitHub.
- It emphasizes the major components and how they connect.
