# Database helpers

This folder contains lazy, cached client helpers for:
- Firebase (firebase-admin / Firestore)
- MongoDB (Motor)
- Redis (redis-py asyncio)

All clients are created lazily on first use.

## Environment variables

### Firebase
- `GOOGLE_APPLICATION_CREDENTIALS` (optional)
- `FIREBASE_PROJECT_ID` (optional)

### MongoDB
- `MONGODB_URI` (optional; default `mongodb://localhost:27017`)
- `MONGODB_DB` (optional; default `ai_healthcare`)

### Redis
- `REDIS_URL` (optional; default `redis://localhost:6379/0`)

