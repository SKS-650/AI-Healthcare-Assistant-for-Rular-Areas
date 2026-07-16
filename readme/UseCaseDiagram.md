# Use Case Diagram — AI Healthcare Assistant

This document contains a high-level use-case diagram for the project and brief descriptions of each actor and use-case.

```mermaid
%% Fallback diagram: flowchart representation of use-cases and actors (widely supported)
flowchart LR
  subgraph Actors
    U[User\n(Mobile App)]
    A[Admin\n(Admin Dashboard)]
    HP[Healthcare\nProvider]
    LLM[External\nLLM Provider]
    ES[Emergency\nService]
  end

  subgraph System[Backend System]
    S[Backend\n(FastAPI + DB)]
    SK[Symptom\nChecker]
    CB[Medical\nChatbot]
    Sync[Offline\nSync]
    Retrieve[Retrieve\nKnowledge]
  end

  U -->|Authenticate| S
  U -->|Use Symptom Checker| SK
  U -->|Chat with Chatbot| CB
  U -->|View Health Records| S
  U -->|Receive Notifications| S
  U -->|Sync Offline Data| Sync

  CB -->|Call Retrieval| Retrieve
  Retrieve -->|Fetch docs| S
  CB -->|Call LLM Provider| LLM
  SK -->|POST /symptom-checker/predict| S
  CB -->|POST /chatbot/message| S
  Sync -->|POST /sync| S

  A -->|Authenticate as Admin| S
  A -->|Manage Users / Metrics / Retrain| S
  A -->|Review Flagged Conversations| S

  HP -->|Access Patient Data| S
  HP -->|Review Symptom Reports| S

  S -->|Escalate emergency| ES

  click S "./readme/Backend.md" "Backend details"
  click SK "./readme/SympCheck.md" "Symptom Checker details"
  click CB "./readme/Chatbot.md" "Chatbot details"
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
