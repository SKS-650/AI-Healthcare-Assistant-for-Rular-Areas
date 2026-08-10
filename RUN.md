# Run Guide

## Quick Start (All-in-one)

Double-click `start_all.bat` — starts backend + shows LAN IP for mobile.

Or for backend + admin dashboard together:

Double-click `start_admin_dashboard.bat`

---

## Manual Commands

### Backend
```powershell
# From project root
.venv\Scripts\activate
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```


- Swagger UI: http://localhost:8000/docs
- Health check: http://localhost:8000/health

### Admin Dashboard (Flutter Web)
```powershell
cd admin_dashboard
flutter run -d chrome --web-port 5000
```
- Opens at: http://localhost:5000
- Default login: `admin@healthcare.ai` / `Admin@123456`

### Mobile App
```powershell
cd mobile_app
flutter run
```
> Make sure `_wifiBackendUrl` in `lib/config/api_config.dart` matches your machine's IP. See `WIFI.md`.

---

## First-Time Setup

```powershell
# 1. Create virtual environment
python -m venv .venv
.venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Copy env file
copy .env.example backend\.env
# Edit backend\.env and set CHATBOT_LLM_API_KEY and JWT_SECRET_KEY

# 4. Seed admin user
cd backend
python -m app.admin.seed
cd ..

# 5. (Optional) Build FAISS index — takes 5–20 min, runs once
python ai_models\scripts\build_faiss_index.py
```

---

## Flutter Dependencies

```powershell
# Mobile app
cd mobile_app
flutter pub get

# Admin dashboard
cd admin_dashboard
flutter pub get
```

---

## Build APK (Android)

```powershell
cd mobile_app
flutter build apk --debug
# Output: build\app\outputs\flutter-apk\app-debug.apk
```

---

## URLs at a Glance

| Service        | URL                          |
|----------------|------------------------------|
| Backend API    | http://localhost:8000        |
| Swagger UI     | http://localhost:8000/docs   |
| Health Check   | http://localhost:8000/health |
| Admin Dashboard| http://localhost:5000        |
| Mobile (LAN)   | http://YOUR_IP:8000          |
