# Sequence Diagram — AI Healthcare Assistant

This document contains a project-wide sequence diagram for the main user flows: authentication, symptom checking, medical chatbot, emergency escalation, offline sync, admin reporting, and model retraining.

```mermaid
sequenceDiagram
    participant U as User
    participant M as Mobile App
    participant B as Backend
    participant S as Symptom Checker
    participant R as Retriever
    participant L as LLM Provider
    participant D as Database
    participant A as Admin Dashboard
    participant E as Emergency Service

    U->>M: Open app
    M->>B: POST /api/v1/auth/login
    B-->>M: auth token
    M->>B: POST /api/v1/symptom-checker/predict
    B->>S: preprocess input & run inference
    S-->>B: symptom predictions
    B->>D: save symptom request
    B-->>M: return symptom results

    alt emergency detected
        B->>E: escalate emergency
        E-->>B: acknowledge
        B-->>M: show emergency alert
    else normal triage
        B-->>M: show triage advice
    end

    M->>B: POST /api/v1/chatbot/message
    B->>R: retrieve knowledge documents
    R-->>B: retrieved context
    B->>L: send prompt + context
    L-->>B: generated chat reply
    B->>D: save conversation / audit log
    B-->>M: deliver chatbot response

    alt offline mode
        M->>M: queue actions locally
        M->>B: POST /api/v1/sync when online
        B->>D: apply queued changes
        B-->>M: sync acknowledgment
    end

    A->>B: GET /api/v1/admin/analytics
    B->>D: fetch metrics and user/session data
    B-->>A: analytics dashboard data

    A->>B: POST /api/v1/admin/retrain
    B->>B: trigger model retrain pipeline
    B-->>A: retrain started
```

Notes:

- Use a Mermaid-compatible viewer like GitHub or VS Code to render this diagram.
- If this still fails, I can export a static PNG/SVG image instead of Mermaid text.
