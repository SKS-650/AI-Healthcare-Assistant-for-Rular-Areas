# Mobile App Deployment Checklist

## Pre-Testing Checklist

Use this checklist before testing the mobile app to avoid connection issues.

### ✅ Backend Configuration

- [ ] Backend server is running
- [ ] Backend started with `--host 0.0.0.0` (not localhost)
- [ ] Port 8000 is used
- [ ] Can access `http://localhost:8000/docs` from computer
- [ ] Can access `http://YOUR_IP:8000/docs` from computer

**Command to start backend:**
```powershell
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

### ✅ Network Configuration

- [ ] Computer connected to WiFi (not ethernet)
- [ ] Know your computer's WiFi IP address
- [ ] Firewall allows connections on port 8000
- [ ] No VPN running (may interfere)

**Find your IP:**
```powershell
ipconfig | findstr "IPv4"
```

**Add firewall rule (if needed):**
```powershell
# Run as Administrator
netsh advfirewall firewall add rule name="FastAPI Dev" dir=in action=allow protocol=TCP localport=8000
```

---

### ✅ Mobile Device Configuration

- [ ] Mobile device connected to SAME WiFi network as computer
- [ ] Mobile data turned OFF (to force WiFi usage)
- [ ] Can open web browser on mobile
- [ ] Can access `http://YOUR_COMPUTER_IP:8000/docs` from mobile browser

---

### ✅ Mobile App Configuration

- [ ] IP address updated in `lib/config/api_config.dart`
- [ ] `_devLanIp` matches your computer's WiFi IP
- [ ] `_useEmulator` is set correctly (false for physical device)
- [ ] App rebuilt after config changes (`flutter clean && flutter run`)

**Config file location:**
```
mobile_app/lib/config/api_config.dart
```

**Expected values:**
```dart
static const _devLanIp = '192.168.18.26';  // Your actual IP
static const _useEmulator = false;         // true only for emulator
static const connectionTimeout = 30;       // Seconds
```

---

## Testing Checklist

### Level 1: Backend Health Check

- [ ] Test from computer browser: `http://localhost:8000/docs`
- [ ] Test from computer browser: `http://YOUR_IP:8000/docs`
- [ ] Test from computer terminal:
  ```powershell
  curl http://localhost:8000/api/v1/health
  ```

**Expected result:** Should see FastAPI Swagger documentation or health status

---

### Level 2: Network Accessibility

- [ ] Test from mobile browser: `http://YOUR_COMPUTER_IP:8000/docs`
- [ ] Can see API documentation on mobile
- [ ] Try a simple API endpoint from mobile browser

**If this fails:** Network or firewall issue, not app issue

---

### Level 3: Mobile App Connection

- [ ] Run the mobile app
- [ ] App shows loading screen
- [ ] App successfully loads data
- [ ] Login works
- [ ] Symptom checker loads

**If this fails but Level 2 passed:** App configuration issue

---

## Common Issues & Quick Fixes

### Issue: "Connection timed out"

**Diagnosis:**
- Backend can't be reached from mobile device

**Quick Fix:**
1. Check mobile is on WiFi (not mobile data)
2. Verify IP address in config is correct
3. Test with mobile browser first
4. Check firewall

---

### Issue: "Connection refused"

**Diagnosis:**
- Backend not running or using wrong port

**Quick Fix:**
1. Restart backend with correct command
2. Verify port 8000 is used
3. Check no other app is using port 8000

---

### Issue: "Network unreachable"

**Diagnosis:**
- Mobile not on network or wrong network

**Quick Fix:**
1. Verify WiFi connection on mobile
2. Reconnect to WiFi
3. Turn off mobile data
4. Restart mobile WiFi

---

### Issue: Works on laptop but not mobile

**Diagnosis:**
- Backend listening only on localhost

**Quick Fix:**
Backend MUST use `--host 0.0.0.0`:
```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## Automated Diagnostics

### Run network diagnostic script:
```powershell
cd mobile_app
.\check_network.ps1
```

**What it checks:**
- ✅ Backend running status
- ✅ Your computer's IP addresses
- ✅ Mobile app configuration
- ✅ Firewall rules
- ✅ Network accessibility

---

## Daily Development Workflow

### 1. Morning Setup (First time each day)

```powershell
# 1. Start backend
cd backend
.\start_for_mobile.ps1

# 2. Check network (if IP changed)
cd ..\mobile_app
.\check_network.ps1

# 3. Update IP if needed (in api_config.dart)

# 4. Run app
flutter run
```

### 2. During Development

- Backend stays running with hot reload
- Mobile app hot reloads automatically
- Only rebuild if config changes

### 3. If Issues Occur

```powershell
# Quick diagnostic
.\check_network.ps1

# Restart backend
cd ..\backend
.\start_for_mobile.ps1

# Rebuild app
cd ..\mobile_app
flutter clean
flutter run
```

---

## Alternative: Use ngrok (Recommended for Demos)

If you're doing a demo or presentation, use ngrok to avoid network issues:

```powershell
# 1. Install ngrok (one time)
# Download from https://ngrok.com

# 2. Start backend normally
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 3. Start ngrok (in another terminal)
ngrok http 8000

# 4. Copy the HTTPS URL (e.g., https://abc123.ngrok.io)

# 5. Run app with custom URL
cd mobile_app
flutter run --dart-define=BACKEND_URL=https://abc123.ngrok.io
```

**Benefits:**
- ✅ Works on any network (WiFi, mobile data, different networks)
- ✅ No firewall issues
- ✅ Can share with others
- ✅ HTTPS included

---

## Pre-Demo Checklist

Before showing the app to others:

- [ ] Backend running and accessible
- [ ] Test login flow
- [ ] Test symptom checker
- [ ] Test on actual mobile device
- [ ] Have fallback (ngrok URL ready)
- [ ] Know your IP address in case someone asks
- [ ] Have demo credentials ready

---

## Deployment Environments

### Development (Current)
- ✅ Local WiFi network
- ✅ `--host 0.0.0.0`
- ✅ No HTTPS required
- ✅ Hot reload enabled

### Staging (Future)
- ✅ Cloud deployment (AWS/Azure/etc.)
- ✅ HTTPS required
- ✅ Environment-based config
- ✅ Separate database

### Production (Future)
- ✅ Production server
- ✅ HTTPS enforced
- ✅ Authentication required
- ✅ Rate limiting enabled
- ✅ Monitoring & logging

---

## Quick Reference URLs

| Environment | Backend URL | Mobile Config |
|-------------|-------------|---------------|
| Local Dev | `http://192.168.X.X:8000` | Update in `api_config.dart` |
| ngrok | `https://xxx.ngrok.io` | Pass via `--dart-define` |
| Staging | `https://staging.example.com` | Environment variable |
| Production | `https://api.example.com` | Environment variable |

---

## Support Resources

- 📖 **Full troubleshooting:** `MOBILE_TROUBLESHOOTING.md`
- 🚀 **Quick fix guide:** `QUICK_FIX.md`
- 🌐 **Network setup:** `NETWORK_SETUP.md`
- 🔧 **Diagnostic tool:** `check_network.ps1`
- 🚀 **Backend starter:** `../backend/start_for_mobile.ps1`

---

## Need Help?

1. **Run diagnostic first:** `.\check_network.ps1`
2. **Check troubleshooting guide:** `MOBILE_TROUBLESHOOTING.md`
3. **Verify network setup:** `NETWORK_SETUP.md`
4. **Try quick fixes:** `QUICK_FIX.md`
5. **Still stuck?** Check backend logs and mobile app console

---

**Last Updated:** 2026-07-06
**Version:** 1.0
