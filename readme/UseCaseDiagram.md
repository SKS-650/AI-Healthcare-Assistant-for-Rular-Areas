# Use Case Diagram — AI Healthcare Assistant

This document contains a high-level use-case diagram for the project and brief descriptions of each actor and use case.

```mermaid
flowchart LR
  %% Actors outside the system boundary with use cases inside
  User((User))
  Admin((Admin))
  Provider((Healthcare Provider))

  subgraph SystemBoundary["AI Healthcare Assistant System"]
    direction TB
    Login((Login / Authenticate))
    Symptom((Use Symptom Checker))
    Chat((Chat with Medical Assistant))
    Records((View Health Records))
    Offline((Sync Offline Data))
    Flags((Review Flagged Content))
    Users((Manage Users & Roles))
    Retrain((Trigger Model Retraining))
    Analytics((View Analytics & Reports))
    Emergency((Escalate Emergency))
    Knowledge((Retrieve Knowledge))
  end

  User --> Login
  User --> Symptom
  User --> Chat
  User --> Records
  User --> Offline

  Admin --> Login
  Admin --> Flags
  Admin --> Users
  Admin --> Retrain
  Admin --> Analytics

  Provider --> Records
  Provider --> Flags

  Chat -.->|<<include>>| Knowledge
  Symptom -.->|<<extend>>| Emergency
  Chat -->|uses| Knowledge
  Symptom -->|may trigger| Emergency
```
## Actors

- **User**: the end-user (patient) interacting through the mobile app. Performs symptom input, chatting, and viewing results.
- **Admin**: operator using the Admin Dashboard to manage users, review flagged items, and trigger model operations.
- **HealthcareProvider**: clinician role that can access patient data and review symptom reports.
- **System**: the backend services that orchestrate APIs, model inference, persistence, and integrations.
- **ExternalLLM**: third-party large language model providers used by the chatbot.
- **EmergencyService**: external emergency escalation pathway (calls, SMS, or operator alerts).

## Primary Use Cases (brief)

- **Authenticate / Authenticate as Admin**: login flow returning tokens used for subsequent calls.
- **Use Symptom Checker**: submit structured symptom data and receive ranked conditions and triage guidance.
- **Chat with Medical Chatbot**: conversational interface that may call retrieval and LLM generation.
- **Retrieve Knowledge**: backend retrieval from vector store and documents used to ground chatbot replies.
- **Sync Offline Data**: client-side queued actions sent to the server when connectivity returns.
- **Manage Users**: admin operations for roles, suspensions, and user metadata.
- **Review Flagged Conversations**: admin workflow to inspect and act on content flagged by safety modules.
- **Trigger Model Retrain**: admin-triggered (or automated) retraining pipeline for models in `ai_models`.
- **View Analytics**: dashboards showing system metrics, emergency counts, and model performance.
- **Escalate to EmergencyService**: backend triggers if Emergency Detection reports high risk.

## How to use this file

- Render the Mermaid diagram in any viewer that supports Mermaid (VS Code, GitHub, Mermaid live editor).
- Use this diagram as the starting point for more detailed UML or sequence diagrams per module.
