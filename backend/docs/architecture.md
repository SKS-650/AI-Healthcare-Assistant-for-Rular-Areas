# Backend Architecture

The backend follows a modular FastAPI structure:

- `api/` contains route modules.
- `services/` contains business logic.
- `models/` contains domain models.
- `schemas/` contains request and response shapes.
- `database/` contains external data connectors.
- `middleware/`, `security/`, `cache/`, and `background_jobs/` contain infrastructure concerns.
