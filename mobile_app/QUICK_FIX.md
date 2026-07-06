# 🚨 Mobile App Not Connecting? Quick Fix!

## The 3-Minute Fix

### Step 1: Check Your Network (30 seconds)
```powershell
.\check_network.ps1
```

### Step 2: Start Backend Correctly (30 seconds)
```powershell
cd ..\backend
.\start_for_mobile.ps1
```

⚠️ **CRITICAL:** Backend MUST run with `--host 0.0.0.0` (not localhost!)

### Step 3: Update IP if Needed (1 minute)
1. Find your computer's WiFi IP:
   ```powershell
   ipconfig
   ```
   Look for "IPv4 Address" under WiFi adapter

2. Edit `lib/config/api_config.dart`:
   ```dart
   static const _devLanIp = '192.168.X.X';  // ← Your IP here
   ```

3. Rebuild app:
   ```powershell
   flutter clean
   flutter run
   ```

### Step 4: Test in Browser (30 seconds)
On your mobile device, open browser and go to:
```
http://YOUR_COMPUTER_IP:8000/docs
```

✅ **If you see API docs** → Network is working, run the app!  
❌ **If it doesn't load** → See checklist below

---

## Common Issues Checklist

| Issue | Fix |
|-------|-----|
| ❌ Mobile on different network | Connect to **same WiFi** as computer |
| ❌ Mobile using mobile data | Turn off mobile data, use WiFi only |
| ❌ Backend not running | Run `.\start_for_mobile.ps1` |
| ❌ Backend using localhost | MUST use `--host 0.0.0.0` |
| ❌ Wrong IP address | Update `_devLanIp` in config |
| ❌ Firewall blocking | See firewall fix below |
| ❌ App not rebuilt | Run `flutter clean && flutter run` |

---

## Firewall Quick Fix (Windows)

**Option 1: Temporarily disable** (for testing):
```powershell
# Run as Administrator
netsh advfirewall set allprofiles state off
```

**Option 2: Add rule** (recommended):
```powershell
# Run as Administrator
netsh advfirewall firewall add rule name="FastAPI Dev" dir=in action=allow protocol=TCP localport=8000
```

---

## Still Not Working?

### Try ngrok (Public URL - bypasses all network issues):
```powershell
# Install ngrok, then:
ngrok http 8000

# Copy the https URL, then:
cd mobile_app
flutter run --dart-define=BACKEND_URL=https://abc123.ngrok.io
```

### Or see full guide:
📖 **Detailed help:** `MOBILE_TROUBLESHOOTING.md`

---

## Working? Great! 

Remember for next time:
1. ✅ Backend with `--host 0.0.0.0`
2. ✅ Mobile on same WiFi
3. ✅ Correct IP in config
4. ✅ Firewall allows port 8000

Happy coding! 🎉
