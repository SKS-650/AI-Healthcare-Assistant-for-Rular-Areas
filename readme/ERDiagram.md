# ER Diagram — AI Healthcare Assistant

This file contains a high-level entity-relationship diagram for the main data entities in the project, written in a table-style layout.

```mermaid
erDiagram
    USERS {
        UUID user_id PK
        string full_name
        string email
        string hashed_password
        string role
        datetime created_at
    }

    SESSIONS {
        UUID session_id PK
        UUID user_id FK
        string access_token
        datetime expires_at
        bool is_active
    }

    SYMPTOM_REQUESTS {
        UUID request_id PK
        UUID user_id FK
        json symptoms
        string prediction
        float risk_score
        datetime created_at
    }

    CONVERSATIONS {
        UUID conversation_id PK
        UUID user_id FK
        datetime started_at
        datetime ended_at
    }

    MESSAGES {
        UUID message_id PK
        UUID conversation_id FK
        UUID user_id FK
        string role
        string content
        datetime created_at
    }

    OFFLINE_PAYLOADS {
        UUID payload_id PK
        UUID user_id FK
        string payload_type
        json payload_data
        string status
        datetime queued_at
    }

    EMERGENCY_EVENTS {
        UUID event_id PK
        UUID user_id FK
        string reason
        float severity_score
        bool escalated
        datetime detected_at
    }

    ADMIN_ACTIONS {
        UUID action_id PK
        UUID admin_id FK
        string action_type
        string details
        datetime created_at
    }

    MODEL_ARTIFACTS {
        string artifact_name PK
        string version
        datetime created_at
        string storage_path
    }

    USERS ||--o{ SESSIONS : "has"
    USERS ||--o{ SYMPTOM_REQUESTS : "submits"
    USERS ||--o{ CONVERSATIONS : "owns"
    CONVERSATIONS ||--o{ MESSAGES : "contains"
    USERS ||--o{ MESSAGES : "writes"
    USERS ||--o{ OFFLINE_PAYLOADS : "queues"
    USERS ||--o{ EMERGENCY_EVENTS : "triggers"
    USERS ||--o{ ADMIN_ACTIONS : "performs"
    ADMIN_ACTIONS }|..|{ USERS : "targets"
    MODEL_ARTIFACTS ||--|| ADMIN_ACTIONS : "updates"
```

Notes:

- This is a conceptual ER diagram; actual table and field names may differ in implementation.
- Render it with a Mermaid-compatible viewer.
