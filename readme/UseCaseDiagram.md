# Use Case Diagram — AI Healthcare Assistant

This document contains a high-level use-case diagram for the project and brief descriptions of each actor and use case.

```mermaid
flowchart TD
  %% Actors on left and right, use cases in the middle
  actorUser([<b>User</b>])
  actorAdmin([<b>Admin</b>])
  actorProvider([<b>Healthcare Provider</b>])

  subgraph SystemBoundary["AI Healthcare Assistant System"]
    direction TB
    UC01((Register / Login))
    UC02((Use Symptom Checker))
    UC03((Chat with Medical Assistant))
    UC04((View Health Records))
    UC05((Sync Offline Data))
    UC06((Review Flagged Content))
    UC07((Manage Users & Roles))
    UC08((Trigger Model Retraining))
    UC09((View Analytics & Reports))
    UC10((Escalate Emergency))
    UC11((Retrieve Knowledge))
  end

  actorUser --> UC01
  actorUser --> UC02
  actorUser --> UC03
  actorUser --> UC04
  actorUser --> UC05

  actorAdmin --> UC01
  actorAdmin --> UC06
  actorAdmin --> UC07
  actorAdmin --> UC08
  actorAdmin --> UC09

  actorProvider --> UC04
  actorProvider --> UC06

  UC03 -.-> UC11
  UC02 -.-> UC10
  UC11 -.->|"uses external LLM / retrieval"| UC03
  UC10 -.->|"emergency workflow"| UC02
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
