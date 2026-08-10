# 🚀 IP Configuration Guide

## Quick Start (10 Seconds!)

When you switch WiFi networks, just update **ONE IP address** in **TWO simple files**:

### Step 1: Find Your IP Address

**Windows:**
```powershell
ipconfig
```
Look for **"IPv4 Address"** under your WiFi adapter (e.g., `192.168.1.100`)

**Mac/Linux:**
```bash
ifconfig  # or: hostname -I
```

### Step 2: Update .env Files

**File 1:** `mobile_app/.env`
```env
BACKEND_URL=http://YOUR_IP_HERE:8000
```

**File 2:** `admin_dashboard/.env`
```env
BACKEND_URL=http://YOUR_IP_HERE:8000
```

### Step 3: Restart Apps

```powershell
# Mobile app
cd mobile_app
flutter pub get
flutter run

# Admin dashboard (if using)
cd admin_dashboard
flutter pub get
flutter run -d chrome
```

**Done!** 🎉 Your apps now work on the new WiFi network.

---

## First-Time Setup

If `.env` files don't exist yet:

```powershell
# Copy templates
copy mobile_app\.env.example mobile_app\.env
copy admin_dashboard\.env.example admin_dashboard\.env

# Then edit with your IP as shown above
```

---

## Configuration Details

### What Changed?

**Before:** You had to manually edit hardcoded IP addresses in multiple `.dart` files across both apps.

**Now:** Just edit the `.env` files — all API calls automatically use the configured IP.

### File Locations

```
ai_healthcare_assistant/
├── mobile_app/
│   ├── .env                  ← Edit this (git-ignored)
│   └── .env.example          ← Template for new developers
│
└── admin_dashboard/
    ├── .env                  ← Edit this (git-ignored)
    └── .env.example          ← Template for new developers
```

### Environment Variables

Both `.env` files support:

| Variable | Description | Example |
|----------|-------------|---------|
| `BACKEND_URL` | Full backend URL with port | `http://192.168.1.100:8000` |
| `BACKEND_PORT` | Backend port (optional) | `8000` |
| `API_VERSION` | API version prefix (optional) | `v1` |

### Supported Network Scenarios

| Scenario | Configuration | Notes |
|----------|--------------|-------|
| **Physical Device + Same WiFi** | `http://192.168.x.x:8000` | Most common setup |
| **Android Emulator** | `http://10.0.2.2:8000` | Automatic fallback |
| **iOS Simulator** | `http://localhost:8000` | Automatic fallback |
| **Mobile Hotspot** | `http://192.168.137.1:8000` | Typical hotspot IP |
| **Web/Desktop Development** | `http://localhost:8000` | Default fallback |

### Troubleshooting

#### Apps Can't Connect to Backend

1. **Verify backend is running:**
   ```powershell
   cd backend
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```
   
   ⚠️ **Important:** Use `--host 0.0.0.0` (not `localhost`)!

2. **Verify IP address is correct:**
   - Run `ipconfig` again
   - Make sure you copied the **WiFi adapter's IPv4 address**
   - Check you updated **both** `.env` files

3. **Verify phone and computer are on the same WiFi network**

4. **Check Windows Firewall:**
   - Allow port 8000 for Python/Uvicorn

5. **Restart the app after changing `.env`:**
   ```powershell
   flutter pub get  # Reload environment variables
   flutter run
   ```

#### .env File Not Found

If you see warnings like `Could not load .env file`, create it:

```powershell
# Mobile app
copy mobile_app\.env.example mobile_app\.env

# Admin dashboard
copy admin_dashboard\.env.example admin_dashboard\.env
```

Then edit with your IP address.

---

## For Team Collaboration

### Sharing with Other Developers

1. **Never commit `.env` files** — they contain local IP addresses
2. **Do commit `.env.example` files** — they're templates
3. **Each developer creates their own `.env`:**
   ```powershell
   copy .env.example .env
   # Then edit with their local IP
   ```

### Version Control

The `.gitignore` is already configured:

```gitignore
# Flutter app environment files are ignored
mobile_app/.env
admin_dashboard/.env

# But templates are tracked
!mobile_app/.env.example
!admin_dashboard/.env.example
```

---

## Advanced: Override with Command Line

You can temporarily override the `.env` configuration:

```powershell
flutter run --dart-define=BACKEND_URL=http://192.168.5.100:8000
```

This is useful for CI/CD or testing different backends without editing files.

---

## Need Help?

- **Check README.md** → Section 20: Network & WiFi Configuration
- **Backend issues?** → Ensure `--host 0.0.0.0` is used
- **Still stuck?** → Check `mobile_app/lib/config/api_config.dart` logs in debug console

---

**Last Updated:** February 2025  
**Package Used:** `flutter_dotenv: ^5.1.0`
