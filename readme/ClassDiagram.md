# Class Diagram — AI Healthcare Assistant

This file contains a high-level class diagram for the main components and data structures in the project, including authentication, symptom checker, chatbot, offline sync, admin operations, and persistence.

```mermaid
classDiagram
    class User {
        +UUID id
        +String name
        +String email
        +String hashedPassword
        +List<String> roles
        +DateTime createdAt
        +DateTime updatedAt
    }

    class Session {
        +UUID id
        +UUID userId
        +String accessToken
        +DateTime expiresAt
        +Boolean isActive
    }

    class SymptomRequest {
        +UUID id
        +UUID userId
        +Map<String, Object> symptoms
        +String prediction
        +Float riskScore
        +DateTime createdAt
    }

    class Message {
        +UUID id
        +UUID userId
        +String role
        +String content
        +DateTime createdAt
    }

    class Conversation {
        +UUID id
        +UUID userId
        +List<Message> messages
        +DateTime startedAt
        +DateTime endedAt
    }

    class OfflinePayload {
        +UUID id
        +UUID userId
        +String payloadType
        +Map<String, Object> payloadData
        +String status
        +DateTime queuedAt
    }

    class ModelArtifact {
        +String modelName
        +String version
        +DateTime createdAt
        +String storagePath
    }

    class AdminAction {
        +UUID id
        +UUID adminId
        +String actionType
        +String details
        +DateTime createdAt
    }

    class EmergencyEvent {
        +UUID id
        +UUID userId
        +String reason
        +Float severityScore
        +Boolean escalated
        +DateTime detectedAt
    }

    class AuthService {
        +login(email, password)
        +refreshToken(refreshToken)
        +logout(sessionId)
        +validateToken(token)
    }

    class SymptomCheckerService {
        +predict(symptoms)
        +preprocess(input)
        +calculateRisk(scores)
    }

    class ChatbotService {
        +handleMessage(request)
        +retrieveContext(query)
        +generateReply(prompt)
    }

    class SyncService {
        +queuePayload(payload)
        +sync(payloads)
    }

    class AdminService {
        +reviewFlaggedContent()
        +triggerRetrain()
        +fetchAnalytics()
    }

    class EmergencyService {
        +assessRisk(data)
        +escalate(event)
    }

    User "1" --> "*" Session : has
    User "1" --> "*" SymptomRequest : submits
    User "1" --> "*" Conversation : owns
    Conversation "1" --> "*" Message : contains
    User "1" --> "*" OfflinePayload : queues
    User "1" --> "*" EmergencyEvent : may trigger
    AdminAction --> User : targets
    SymptomCheckerService --> SymptomRequest : creates
    ChatbotService --> Conversation : appends
    SyncService --> OfflinePayload : processes
    AdminService --> ModelArtifact : updates
    EmergencyService --> EmergencyEvent : creates
```

Notes:

- This is a conceptual class diagram; actual class names and field types may differ in implementation.
- Render in a Mermaid-capable viewer such as VS Code or GitHub.
