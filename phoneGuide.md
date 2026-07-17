# Phone Guide — AI Healthcare Assistant

Everything you need to run the app on your phone over WiFi.

---

## Your Setup

| Item | Value |
|---|---|
| Laptop WiFi IP | `192.168.18.26` |
| Backend Port | `8000` |
| Backend URL | `http://192.168.18.26:8000` |
| APK location | `mobile_app\build\app\outputs\flutter-apk\app-debug.apk` |

---

## First Time Setup (Do Once)

### Step 1 — Install the APK on your phone

**Option A — WhatsApp/Telegram (easiest)**
1. Open WhatsApp or Telegram on your laptop
2. Send this file to yourself:
   ```
   d:\MinorProject\ai_healthcare_assistant\mobile_app\build\app\outputs\flutter-apk\app-debug.apk
   ```
3. Open it on your phone → tap Download → tap Install

**Option B — Google Drive**
1. Upload the APK to Google Drive
2. Open the link on your phone → Download → Install

**Option C — WiFi file share (no internet needed)**
1. Open terminal on laptop and run:
   ```
   cd d:\MinorProject\ai_healthcare_assistant\mobile_app\build\app\outputs\flutter-apk
   python -m http.server 9000
   ```
2. On phone browser go to:
   ```
   http://192.168.18.26:9000
   ```
3. Tap `app-debug.apk` → Download → Install

### Step 2 — Allow installing unknown apps on phone

Go to:
```
Settings → Apps → Special app access → Install unknown apps
→ Allow your browser or file manager
```

---

## Every Time You Want to Use the App

### On Laptop — do this FIRST

Double-click:
```
start_server.bat
```

Located at:
```
d:\MinorProject\ai_healthcare_assistant\start_server.bat
```

A terminal window opens and shows:
```
Starting FastAPI server on 0.0.0.0:8000 ...
```

Keep this window open the whole time.

### On Phone

1. Connect phone to the **same WiFi** as your laptop
2. Open the AI Healthcare Assistant app
3. Sign in

That's it. No cable needed.

---

## Verify Server is Running (Optional)

Open your phone browser and go to:
```
http://192.168.18.26:8000/health
```

You should see:
```json
{"status": "healthy", "server": "running"}
```

If you see that — everything is working.

---

## Demo Login Credentials

```
Email:    demo@health.ai
Password: Password@1
```

Admin login:
```
Email:    admin@healthcare.ai
Password: Admin@123456
```

---

## The Server Serves All Platforms

One `start_server.bat` handles everything at the same time:

```
start_server.bat  (run once)
        |
        ▼
  FastAPI on port 8000
        |
   _____|______________________
  |           |                |
Phone      Chrome           Flutter
(WiFi)   (Admin Dashboard)  (Dev)
```

---

## If Something Goes Wrong

| Problem | Fix |
|---|---|
| App says "Cannot connect to server" | Make sure `start_server.bat` is running |
| Phone can't reach server | Check both are on same WiFi |
| `http://192.168.18.26:8000/health` not loading | Laptop IP may have changed — see below |
| Login fails with wrong credentials | Use demo credentials above |

### If your laptop IP changes

Your laptop IP changes when you connect to a different WiFi network.

**Check current IP:**
Open terminal on laptop and run:
```
ipconfig
```
Look for `IPv4 Address` under the WiFi adapter.

**If IP is different from `192.168.18.26`:**
1. Open this file:
   ```
   mobile_app\lib\config\api_config.dart
   ```
2. Find this line:
   ```dart
   static const String _wifiBackendUrl = 'http://192.168.18.26:8000';
   ```
3. Replace `192.168.18.26` with your new IP
4. Rebuild APK:
   ```
   cd mobile_app
   flutter build apk --debug
   ```
5. Reinstall APK on phone

---

## Rebuilding the APK (When You Make Code Changes)

```
cd d:\MinorProject\ai_healthcare_assistant\mobile_app
flutter build apk --debug
```

APK will be at:
```
mobile_app\build\app\outputs\flutter-apk\app-debug.apk
```

Reinstall on phone using any method from the First Time Setup section.

---

## Stop the Server

Just close the `start_server.bat` terminal window.
