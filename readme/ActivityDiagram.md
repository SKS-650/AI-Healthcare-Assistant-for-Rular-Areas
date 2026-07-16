# Activity Diagram — AI Healthcare Assistant

This document contains an activity-style flowchart that shows the primary runtime flow for the whole project in a vertical activity layout.

```mermaid
flowchart TD
  Start([Start])
  LaunchApp["Launch mobile app or admin dashboard"]
  Authenticate["Authenticate user or admin"]
  MainMenu["Choose flow:\nSymptom Checker, Chatbot, Health Records, Offline Sync, Admin"]

  SymptomFlow["Symptom Checker flow"]
  InputSymptoms["Enter symptoms / health data"]
  Predict["Run symptom prediction"]
  RiskCheck{"High emergency risk?"}
  EmergencyAction["Escalate emergency and alert user"]
  Triage["Show triage guidance"]

  ChatFlow["Medical Chatbot flow"]
  UserMessage["Send chat message"]
  Retrieve["Retrieve knowledge context"]
  Generate["Generate response from LLM"]
  ChatReply["Show chatbot reply"]

  RecordsFlow["View health records"]
  OfflineFlow["Offline queue and sync"]
  Sync["Sync queued actions when online"]

  AdminFlow["Admin review and retraining"]
  Retrain["Trigger model retraining"]

  End([End])

  Start --> LaunchApp --> Authenticate --> MainMenu
  MainMenu --> SymptomFlow
  SymptomFlow --> InputSymptoms --> Predict --> RiskCheck
  RiskCheck -->|yes| EmergencyAction --> Triage --> End
  RiskCheck -->|no| Triage --> End

  MainMenu --> ChatFlow
  ChatFlow --> UserMessage --> Retrieve --> Generate --> ChatReply --> End

  MainMenu --> RecordsFlow --> End
  MainMenu --> OfflineFlow --> Sync --> End
  MainMenu --> AdminFlow --> Retrain --> End
```

Actors and mapping to components:

- User: mobile app — initiates symptom input and chat (see [readme/SympCheck.md](readme/SympCheck.md)).
- Backend: FastAPI — orchestrates inference, persistence, and escalation (see [readme/Backend.md](readme/Backend.md)).
- Chatbot & Retrieval: RAG pipeline (see [readme/Chatbot.md](readme/Chatbot.md)).
- Emergency Service: external escalation endpoint/phone/SMS.

How to use:

- Render this file in any Mermaid-capable viewer (VS Code, GitHub, Mermaid Live Editor).
- If you need a higher-fidelity UML activity diagram (e.g., for documentation PDFs), I can export a PNG/SVG and add it to the `readme/` folder.
