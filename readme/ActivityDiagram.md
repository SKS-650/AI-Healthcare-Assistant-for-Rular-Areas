# Activity Diagram — AI Healthcare Assistant

This document contains an activity-style flowchart that shows the primary runtime flow for user interactions, symptom checking, chatbot retrieval, emergency escalation, and persistence.

```mermaid
flowchart TD
  %% Activity-style flowchart compatible with GitHub/VS Code Mermaid
  Start([Start])
  User(User)
  Auth["Authenticate (POST /api/v1/auth/login)"]
  Token["Issue token / session"]

  Choose{Choose action}
  Symptom["Symptom Checker\nPOST /api/v1/symptom-checker/predict"]
  Chat["Medical Chatbot\nPOST /api/v1/chatbot/message"]
  ViewRecords["View Health Records"]
  Offline["Offline Sync / Queue"]
  AdminPanel["Admin Dashboard"]

  Preprocess["Preprocess & feature extraction"]
  SymptomModel["Symptom Model\nInference"]
  SymptomResults["Symptom Results / Triage"]
  RiskCheck{High emergency risk?}
  Emergency["Emergency Detection / Escalate"]

  Retrieve["Retrieve knowledge (vector search)"]
  LLM["External LLM Provider"]
  Generate["Generate reply / RAG pipeline"]
  Persist["Persist session, messages, audit logs (DB)"]
  Notify["Notify user / admins / external services"]

  SyncEndpoint["Sync endpoint\nPOST /api/v1/sync"]
  ApplySync["Apply queued changes on server"]

  Retrain["Trigger retrain / CI pipeline"]
  ModelStore["Model artifacts updated"]

  Analytics["Collect metrics / analytics"]
  End([End])

  %% Primary flow
  Start --> User --> Auth --> Token --> Choose

  %% Symptom flow
  Choose -->|symptom check| Symptom --> Preprocess --> SymptomModel --> SymptomResults --> RiskCheck
  RiskCheck -->|yes| Emergency --> Persist --> Notify --> Analytics --> End
  RiskCheck -->|no| Persist --> Notify

  %% Chatbot flow
  Choose -->|chat| Chat --> Retrieve --> Generate --> Persist --> Notify --> Analytics

  %% View records flow
  Choose -->|view records| ViewRecords --> Persist

  %% Offline sync flow
  Choose -->|sync| Offline --> SyncEndpoint --> ApplySync --> Persist --> Notify

  %% Admin and retrain
  User -->|admin login| AdminPanel -->|trigger retrain| Retrain --> ModelStore --> Notify

  %% Analytics sink
  Persist --> Analytics --> End

  %% Healthcare provider path
  HP[Healthcare Provider] -->|access patient data| ViewRecords

  %% External escalation
  Emergency -->|call/emails| Notify

  %% Keep labels simple and quoted to maximize compatibility

  Start --> InputSymptoms --> Validate
  Validate -->|yes| Preprocess --> SymptomCheck --> AssessRisk
  AssessRisk -->|high| EmergencyFlow --> SaveRecord
  AssessRisk -->|low| ChatbotOption
  ChatbotOption -->|yes| Retrieve --> Generate --> SaveRecord
  ChatbotOption -->|no| SaveRecord
  SaveRecord --> Notify --> Sync --> End
  Validate -->|no| InputSymptoms

  %% Optional branches (admin operations, retraining)
  AdminStart([Admin action]) -->|trigger retrain| SaveRecord

  %% Notes
  %% Keep this simple to maximize rendering compatibility across viewers
```

Actors and mapping to components:

- User: mobile app — initiates symptom input and chat (see [readme/SympCheck.md](readme/SympCheck.md)).
- Backend: FastAPI — orchestrates inference, persistence, and escalation (see [readme/Backend.md](readme/Backend.md)).
- Chatbot & Retrieval: RAG pipeline (see [readme/Chatbot.md](readme/Chatbot.md)).
- Emergency Service: external escalation endpoint/phone/SMS.

How to use:

- Render this file in any Mermaid-capable viewer (VS Code, GitHub, Mermaid Live Editor).
- If you need a higher-fidelity UML activity diagram (e.g., for documentation PDFs), I can export a PNG/SVG and add it to the `readme/` folder.
