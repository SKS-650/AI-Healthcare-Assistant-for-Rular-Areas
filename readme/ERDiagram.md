# ER Diagram — AI Healthcare Assistant

This file contains a high-level entity-relationship diagram for the main data entities in the project, including users, sessions, symptom requests, conversations, messages, offline sync payloads, emergency events, and admin actions.

```mermaid
erDiagram
    USER {
        UUID id PK
        string name
        string email
        string hashed_password
        string roles
        datetime created_at
        datetime updated_at
    }

    SESSION {
        UUID id PK
        UUID user_id FK
        string access_token
        datetime expires_at
        bool is_active
    }

    SYMPTOM_REQUEST {
        UUID id PK
        UUID user_id FK
        json symptoms
        string prediction
        float risk_score
        datetime created_at
    }

    CONVERSATION {
        UUID id PK
        UUID user_id FK
        datetime started_at
        datetime ended_at
    }

    MESSAGE {
        UUID id PK
        UUID conversation_id FK
        UUID user_id FK
        string role
        string content
        datetime created_at
    }

    OFFLINE_PAYLOAD {
        UUID id PK
        UUID user_id FK
        string payload_type
        json payload_data
        string status
        datetime queued_at
    }

    MODEL_ARTIFACT {
        string model_name PK
        string version
        datetime created_at
        string storage_path
    }

    ADMIN_ACTION {
        UUID id PK
        UUID admin_id FK
        string action_type
        string details
        datetime created_at
    }

    EMERGENCY_EVENT {
        UUID id PK
        UUID user_id FK
        string reason
        float severity_score
        bool escalated
        datetime detected_at
    }

    USER ||--o{ SESSION : "has"
    USER ||--o{ SYMPTOM_REQUEST : "submits"
    USER ||--o{ CONVERSATION : "owns"
    CONVERSATION ||--o{ MESSAGE : "contains"
    USER ||--o{ MESSAGE : "writes"
    USER ||--o{ OFFLINE_PAYLOAD : "queues"
    USER ||--o{ EMERGENCY_EVENT : "may trigger"
    USER ||--o{ ADMIN_ACTION : "performs"
    ADMIN_ACTION }|..|{ USER : "targets"
    MODEL_ARTIFACT ||--|| ADMIN_ACTION : "updates"
```

Notes:

- This is a conceptual ER diagram; actual table and field names may vary in the implementation.
- Use a Mermaid-compatible viewer to render this diagram.
