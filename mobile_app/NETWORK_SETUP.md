# Mobile App Network Setup Guide

## How It Works

```
┌─────────────────────────────────────────────────────┐
│             Your WiFi Network (Router)              │
│                  192.168.18.x                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────┐      ┌──────────────────┐   │
│  │   Your Computer   │      │  Mobile Device   │   │
│  │                   │      │                   │   │
│  │ IP: 192.168.18.26│◄────►│ IP: 192.168.18.xx│   │
│  │                   │      │                   │   │
│  │ Backend Server:   │      │ Flutter App:     │   │
│  │ Port 8000        │      │ Connects to:     │   │
│  │ Host: 0.0.0.0    │      │ 192.168.18.26    │   │
│  └──────────────────┘      └──────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## ✅ Correct Setup

### Computer (Backend):
```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

- ✅ `--host 0.0.0.0` - Listens on ALL network interfaces
- ✅ Accepts connections from mobile device
- ✅ Can access from: `http://192.168.18.26:8000`

### Mobile App Config:
```dart
static const _devLanIp = '192.168.18.26';  // Your computer's IP
static const _useEmulator = false;         // Physical device
```

- ✅ Points to computer's LAN IP
- ✅ Mobile device can reach this IP
- ✅ Same network = Low latency

---

## ❌ Common Mistakes

### Mistake 1: Backend on Localhost Only

```powershell
# ❌ WRONG - Only accessible from computer itself
uvicorn app.main:app --reload
# or
uvicorn app.main:app --host 127.0.0.1 --port 8000
```

**Problem:** Mobile can't connect because localhost (127.0.0.1) is computer-only

**Fix:** Use `--host 0.0.0.0`

---

### Mistake 2: Wrong Network

```
┌─────────────────┐       ┌─────────────────┐
│   WiFi Network  │       │  Mobile Data    │
│  192.168.18.x   │       │  (Internet)     │
├─────────────────┤       ├─────────────────┤
│                 │       │                 │
│  Your Computer  │       │  Mobile Device  │
│  192.168.18.26 │  ✗   │  4G/5G         │
│                 │       │                 │
└─────────────────┘       └─────────────────┘
    Different Networks - Can't Connect!
```

**Fix:** Connect mobile to same WiFi network

---

### Mistake 3: Firewall Blocking

```
┌──────────────────┐      ┌──────────────────┐
│  Your Computer   │      │  Mobile Device   │
│                  │      │                  │
│  ┌────────────┐  │      │  Request to:     │
│  │  Firewall  │  │      │  192.168.18.26   │
│  │    🚫      │◄─┼──────┤  port 8000       │
│  │  Block!    │  │      │                  │
│  └────────────┘  │      │                  │
│                  │      │                  │
│  Backend:8000   │      │  ❌ Timeout      │
└──────────────────┘      └──────────────────┘
```

**Fix:** Allow port 8000 through Windows Firewall

---

## Network Configurations

### Configuration 1: Local WiFi (Development) - Recommended

**Pros:**
- ✅ Fast and low latency
- ✅ No internet required
- ✅ Free
- ✅ Privacy (local only)

**Cons:**
- ❌ Requires same network
- ❌ IP may change
- ❌ Firewall issues possible

**Setup:**
1. Connect both devices to same WiFi
2. Start backend with `--host 0.0.0.0`
3. Configure IP in app
4. Allow through firewall

---

### Configuration 2: ngrok (Public Tunnel) - Easiest

**Pros:**
- ✅ Works on any network
- ✅ Bypasses firewall
- ✅ Easy to share
- ✅ HTTPS included

**Cons:**
- ❌ Requires internet
- ❌ Slower (tunneled)
- ❌ Free tier has limits

**Setup:**
```powershell
# Install ngrok
ngrok http 8000

# Copy URL like: https://abc123.ngrok.io
# Run app with:
flutter run --dart-define=BACKEND_URL=https://abc123.ngrok.io
```

---

### Configuration 3: Android Emulator

```
┌─────────────────────────────────────┐
│        Your Computer                │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   Android Emulator            │ │
│  │                               │ │
│  │   Special IP: 10.0.2.2       │ │
│  │   Maps to host's localhost   │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│  Backend: localhost:8000           │
│                                     │
└─────────────────────────────────────┘
```

**Config:**
```dart
static const _useEmulator = true;
// Uses: http://10.0.2.2:8000
```

**Backend:**
```powershell
uvicorn app.main:app --reload
# localhost is fine for emulator
```

---

## Testing Connectivity

### Test 1: From Computer
```powershell
curl http://localhost:8000/api/v1/health
# Should work regardless of configuration
```

### Test 2: From LAN IP
```powershell
curl http://192.168.18.26:8000/api/v1/health
# Should work if backend uses 0.0.0.0
```

### Test 3: From Mobile Browser
```
Open: http://192.168.18.26:8000/docs
# Should see Swagger UI
# If this works, the app will work!
```

### Test 4: From Mobile App
```dart
// The app will show detailed error messages:
// ✅ Connected successfully
// ❌ Connection timeout → Check network/firewall
// ❌ Connection refused → Backend not running
// ❌ Network unreachable → Wrong network
```

---

## Port Reference

| Port | Service | Access |
|------|---------|--------|
| 8000 | FastAPI Backend | HTTP API |
| 5432 | PostgreSQL | Database (local only) |
| 6379 | Redis | Cache (local only) |

Mobile app only needs access to port 8000.

---

## Security Notes

### Development (Current Setup)
- ✅ Backend open on LAN (0.0.0.0:8000)
- ⚠️ No authentication required for some endpoints
- ⚠️ Open to anyone on your WiFi
- ✅ Safe for development

### Production (Future)
- ✅ Deploy behind HTTPS
- ✅ Enable authentication on all endpoints
- ✅ Use environment variables for URLs
- ✅ Implement rate limiting

**For now:** Only use on trusted networks!

---

## Troubleshooting Commands

### Check your IP:
```powershell
ipconfig | findstr IPv4
```

### Check backend is running:
```powershell
curl http://localhost:8000/api/v1/health
```

### Check backend from LAN:
```powershell
curl http://YOUR_IP:8000/api/v1/health
```

### Check firewall:
```powershell
Get-NetFirewallRule | Where-Object { $_.LocalPort -eq 8000 }
```

### Test from mobile (browser):
```
http://YOUR_COMPUTER_IP:8000/docs
```

---

## Quick Reference

| Scenario | Backend Host | Mobile Config |
|----------|--------------|---------------|
| Physical device (WiFi) | `0.0.0.0` | `192.168.X.X` (computer's IP) |
| Android emulator | `127.0.0.1` | `10.0.2.2` |
| iOS simulator | `127.0.0.1` | `localhost` |
| ngrok tunnel | `0.0.0.0` | `https://xxx.ngrok.io` |

---

## Need Help?

- 📖 Full troubleshooting: `MOBILE_TROUBLESHOOTING.md`
- 🚀 Quick fix: `QUICK_FIX.md`
- 🔧 Run diagnostic: `.\check_network.ps1`
