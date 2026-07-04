# Backend

FastAPI backend for the AI Healthcare Assistant for Rural Areas project.

## Structure

- `app/api/` contains versioned API modules.
- `app/services/` contains business logic.
- `app/models/` and `app/schemas/` contain domain and transport objects.
- `app/database/` contains Firebase, MongoDB, Redis, and connection helpers.
- `tests/` contains unit, integration, API, and performance tests.

## Run

```bash
uvicorn main:app --reload
```
