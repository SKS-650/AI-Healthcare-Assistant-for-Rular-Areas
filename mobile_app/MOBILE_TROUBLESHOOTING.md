# Mobile Connection Troubleshooting Guide

## Common Error: Connection Timeout on Mobile

If you see this error on mobile:
```
Error: Exception: Network error: ClientException with SocketException: 
Connection timed out (OS Error: Connection timed out, errno = 110), 
address = 192.168.18.26, port = 38724, uri=http://192.168.18.26:8000/api/v1/symptom-checker/predict
```

### Root Causes & Solutions

#### 1. **Device Not on Same WiFi Network** ✅ MOST COMMON
**Problem:** Your mobile device is using mobile data or connected to a different WiFi network than your computer.

**Solution:**
- Ensure your mobile device is connected to the **SAME WiFi network** as your computer
- Turn off mobile data to force WiFi usage
- Check WiFi settings on both devices

---

#### 2. **Wrong IP Address** 
**Problem:** The configured IP address doesn't match your computer's current IP.

**Solution:**
1. Find your computer's IP address:
   - **Windows:** Open Command Prompt and run:
     ```bash
     ipconfig
     ```
     Look for "IPv4 Address" under your WiFi adapter (e.g., `192.168.18.26`)

   - **Mac/Linux:**
     ```bash
     ifconfig
     ```
     Or use: `ip addr show`

2. Update the IP in `mobile_app/lib/config/api_config.dart`:
   ```dart
   static const _devLanIp = '192.168.18.26';  // ← Update this
   ```

3. Rebuild the app:
   ```bash
   cd mobile_app
   flutter clean
   flutter run
   ```

---

#### 3. **Firewall Blocking Connections**
**Problem:** Windows Firewall or antivirus is blocking incoming connections on port 8000.

**Solution:**

**Windows:**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Add Python or your backend executable
4. Enable both Private and Public networks

**Or temporarily disable firewall to test:**
```powershell
# Run as Administrator
netsh advfirewall set allprofiles state off
# Remember to turn it back on!
netsh advfirewall set allprofiles state on
```

**Alternative - Add firewall rule:**
```powershell
# Run as Administrator
netsh advfirewall firewall add rule name="FastAPI Dev" dir=in action=allow protocol=TCP localport=8000
```

---

#### 4. **Backend Not Running or Not Accessible**
**Problem:** Backend server isn't running or only listening on localhost.

**Solution:**

1. Ensure backend is running with the correct host:
   ```bash
   cd backend
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
   
   **Important:** Use `0.0.0.0` not `127.0.0.1` or `localhost`

2. Verify backend is accessible from mobile device:
   - Open browser on your mobile
   - Navigate to: `http://192.168.18.26:8000/docs`
   - You should see the API documentation

---

#### 5. **Using Android Emulator Instead of Physical Device**
**Problem:** Configuration assumes physical device but you're using emulator.

**Solution:**

In `mobile_app/lib/config/api_config.dart`, change:
```dart
static const _useEmulator = true;  // Change to true for emulator
```

For emulator, use:
- **Android Emulator:** `http://10.0.2.2:8000`
- **iOS Simulator:** `http://localhost:8000`

---

## Quick Diagnostic Checklist

Run through this checklist:

- [ ] Mobile device connected to same WiFi as computer
- [ ] Mobile data turned OFF
- [ ] Computer's IP address is correct in `api_config.dart`
- [ ] Backend is running with `--host 0.0.0.0`
- [ ] Can access `http://YOUR_IP:8000/docs` from mobile browser
- [ ] Firewall allows connections on port 8000
- [ ] App was rebuilt after changing config (`flutter run`)

---

## Testing the Connection

### Step 1: Test Backend from Computer
```bash
curl http://localhost:8000/api/v1/health
```

### Step 2: Test Backend from Same Network
From another computer or mobile browser:
```
http://192.168.18.26:8000/docs
```

### Step 3: Test from Mobile App
The app will show a clear error message if:
- Connection times out (30 seconds)
- Server not reachable
- Wrong network

---

## Configuration Options

### Option 1: Use LAN IP (Default for Physical Devices)
```dart
// In api_config.dart
static const _devLanIp = '192.168.18.26';
static const _useEmulator = false;
```

### Option 2: Use Custom URL at Runtime
```bash
flutter run --dart-define=BACKEND_URL=http://192.168.18.26:8000
```

### Option 3: Test with ngrok (Public URL)
If local network continues to have issues:
```bash
# Install ngrok
ngrok http 8000

# Copy the https URL (e.g., https://abc123.ngrok.io)
# Use in app:
flutter run --dart-define=BACKEND_URL=https://abc123.ngrok.io
```

---

## Error Messages Explained

### "Connection timed out"
- Device can't reach the server within 30 seconds
- Usually means wrong network or firewall blocking

### "Connection refused"
- Device can reach the IP but nothing is listening on port 8000
- Backend is not running or using wrong port

### "Network unreachable"
- Device is on different network or no network
- Check WiFi connection

---

## Still Not Working?

1. **Restart everything:**
   - Backend server
   - Mobile app
   - Computer's WiFi
   - Mobile device's WiFi

2. **Check router settings:**
   - Some routers have "AP Isolation" enabled
   - This prevents devices from communicating
   - Check router admin panel

3. **Try USB debugging with port forwarding:**
   ```bash
   # Android only
   adb reverse tcp:8000 tcp:8000
   # Then use http://localhost:8000 in the app
   ```

4. **Use ngrok as mentioned above** - bypasses all network issues

---

## Best Practices for Development

1. **Keep IP updated:** Use a static IP or update config when it changes
2. **Use ngrok for demos:** More reliable than LAN
3. **Test both networks:** WiFi and mobile data (with ngrok)
4. **Monitor backend logs:** Watch for incoming requests
5. **Use Flutter DevTools:** Check network requests

---

## Contact Support

If you've tried everything above and still have issues:
1. Check backend logs for error messages
2. Use `flutter doctor -v` to check Flutter setup
3. Try running on emulator to isolate network issues
4. Check if other devices can connect to the backend
