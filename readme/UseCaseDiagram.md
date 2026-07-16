# Use Case Diagram — AI Healthcare Assistant

This document contains a high-level use-case diagram for the project and brief descriptions of each actor and use-case.

```mermaid
%%{init: {"themeVariables": {"actorBorder": "#2b6cb0"}}}%%
usecaseDiagram
  actor User as U
  actor Admin as A
  actor HealthcareProvider as HP
  actor System as S
  actor ExternalLLM as LLM
  actor EmergencyService as ES

  U --> (Authenticate)
  U --> (Use Symptom Checker)
  U --> (Chat with Medical Chatbot)
  U --> (View Health Records)
  U --> (Receive Notifications)
  U --> (Sync Offline Data)

  (Use Symptom Checker) ..> (Chat with Medical Chatbot) : "optionally calls"
  (Chat with Medical Chatbot) --> LLM : "calls for generation"
  (Chat with Medical Chatbot) --> (Retrieve Knowledge)
  (Retrieve Knowledge) --> S

  A --> (Authenticate as Admin)
  A --> (Manage Users)
  A --> (Review Flagged Conversations)
  A --> (Trigger Model Retrain)
  A --> (View Analytics)

  HP --> (Access Patient Data)
  HP --> (Review Symptom Reports)

  (Use Symptom Checker) --> S : "POST /symptom-checker/predict"
  (Chat with Medical Chatbot) --> S : "POST /chatbot/message"
  (Sync Offline Data) --> S : "POST /sync"

  S --> ES : "Escalate emergency when detected"

  note left of U: Mobile App (Flutter)
  note right of A: Admin Dashboard (Web)
  note right of S: Backend (FastAPI) & DB
  note right of LLM: External LLM Provider

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
