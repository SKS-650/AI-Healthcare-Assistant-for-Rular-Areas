# Sequence Diagram — AI Healthcare Assistant

This document shows a project-wide sequence diagram in lifeline style, modeled after the requested layout.

```mermaid
sequenceDiagram
    participant User
    participant MobileApp as Mobile App
    participant AuthService as Auth Service
    participant Backend as Backend API
    participant SymptomService as Symptom Checker
    participant Retriever as Retriever
    participant LLM as LLM Provider
    participant Database as Database
    participant EmergencyService as Emergency Service
    participant AdminDashboard as Admin Dashboard

    User->>MobileApp: open app
    MobileApp->>AuthService: POST /api/v1/auth/login
    AuthService-->>MobileApp: return token
    MobileApp-->>Backend: GET /api/v1/user/profile
    Backend-->>Database: query user profile
    Database-->>Backend: user data
    Backend-->>MobileApp: profile data

    User->>MobileApp: submit symptoms
    MobileApp->>Backend: POST /api/v1/symptom-checker/predict
    Backend->>SymptomService: preprocess + infer
    SymptomService-->>Backend: predictions
    Backend->>Database: save symptom request
    Database-->>Backend: saved
    Backend-->>MobileApp: symptom results

    alt emergency detected
        Backend->>EmergencyService: escalate emergency
        EmergencyService-->>Backend: escalation acknowledge
        Backend-->>MobileApp: emergency alert
    else normal result
        Backend-->>MobileApp: triage advice
    end

    User->>MobileApp: send chat message
    MobileApp->>Backend: POST /api/v1/chatbot/message
    Backend->>Retriever: retrieve context
    Retriever->>Database: fetch indexed docs
    Database-->>Retriever: context
    Retriever->>LLM: call LLM
    LLM-->>Retriever: generated reply
    Retriever-->>Backend: response context
    Backend->>Database: save conversation
    Database-->>Backend: saved
    Backend-->>MobileApp: chat reply

    User->>MobileApp: go offline
    MobileApp->>MobileApp: queue offline actions
    MobileApp->>Backend: POST /api/v1/sync
    Backend->>Database: apply queued updates
    Database-->>Backend: synced
    Backend-->>MobileApp: sync result

    AdminDashboard->>Backend: GET /api/v1/admin/analytics
    Backend->>Database: query analytics data
    Database-->>Backend: metrics
    Backend-->>AdminDashboard: dashboard data

    AdminDashboard->>Backend: POST /api/v1/admin/retrain
    Backend->>Backend: trigger retrain workflow
    Backend-->>AdminDashboard: retrain started
```

Notes:

- Render this file in a Mermaid-capable viewer such as VS Code or GitHub.
- If the diagram still does not render, I can generate a fixed PNG/SVG version.
