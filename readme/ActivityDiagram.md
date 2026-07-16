# Activity Diagram — AI Healthcare Assistant

This document contains an activity-style flowchart that shows the primary runtime flow for user interactions, symptom checking, chatbot retrieval, emergency escalation, and persistence.

```mermaid
flowchart TD
  %% Activity-style flowchart compatible with GitHub/VS Code Mermaid
  Start([Start])
  InputSymptoms[/User enters symptoms/]
  Validate{Valid input?}
  Preprocess[Preprocess & feature extraction]
  SymptomCheck[/Call Symptom Checker API\nPOST /api/v1/symptom-checker/predict/]
  AssessRisk{Emergency risk?}
  EmergencyFlow[/Invoke Emergency Detection\nEscalate if threshold reached/]
  ChatbotOption{User requests chatbot?}
  Retrieve[/Retrieve knowledge (vector search)/]
  Generate[/Call LLM provider to generate reply/]
  SaveRecord[/Persist session, results, audit logs/]
  Notify[/Send notifications to user/admins/]
  Sync[/Queue offline sync payloads/]
  End([End])

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
