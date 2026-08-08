# Cloud Deployment Guide (Render)

Everything in this repo is already prepared. Follow the steps below to go live.

---

## What's already done
- `render.yaml` created at project root with correct build/start commands
- `mobile_app/lib/config/api_config.dart` updated with Render URL placeholder
- All changes committed to git

---

## Steps you need to do

### 1. Push to GitHub
```powershell
git push
```

---

### 2. Create a free Render account
Go to https://render.com and sign up with GitHub.

---

### 3. Create a new Web Service on Render
1. Dashboard → **New** → **Web Service**
2. Connect your GitHub repo
3. Render auto-detects `render.yaml` — confirm it shows:
   - Root Dir: `backend`
   - Build: `pip install -r ../requirements.txt`
   - Start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

---

### 4. Set environment variables in Render dashboard
Go to your service → **Environment** tab → add these:

| Key | Value |
|-----|-------|
| `JWT_SECRET_KEY` | (copy from `backend/.env`) |
| `CHATBOT_LLM_API_KEY` | (your Gemini/OpenAI key) |
| `CORS_ORIGINS` | `*` |
| `ENVIRONMENT` | `production` |
| `APP_BASE_URL` | (set after deploy — paste your Render URL) |

---

### 5. Deploy
Click **Deploy** and wait ~3–5 minutes.

You'll get a permanent URL like:
```
https://ai-healthcare-backend.onrender.com
```

Test it: open `https://your-url.onrender.com/health` in a browser — should return `{"status":"healthy"}`

---

### 6. Update mobile app with your real Render URL
Open `mobile_app/lib/config/api_config.dart` and replace the placeholder:
```dart
static const String _wifiBackendUrl = 'https://YOUR-REAL-URL.onrender.com';
```

---

### 7. Rebuild APK
```powershell
cd mobile_app
flutter build apk --debug
```

Install `build\app\outputs\flutter-apk\app-debug.apk` on your phone.

---

## Done! The app now works on any network, anywhere.

> **Free tier note:** Render sleeps after 15 min of inactivity.
> First request after sleep takes ~30s to wake up.
> To avoid this, use **Railway** (https://railway.app) — same steps, no sleep.
