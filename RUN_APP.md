# 🎯 How to Run the App - Simple Guide

## ⚡ Quick Start (3 Steps)

### Step 1: Start the Backend Server
```bash
# Double-click or run:
start_all.bat       # On Windows
# OR
./start_all.sh      # On macOS/Linux
```

Wait until you see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Step 2: Configure Mobile App (One-time)
1. Open `mobile_app/lib/config/api_config.dart`
2. Update your IP address:
   ```dart
   static const _devLanIp = 'YOUR_IP_HERE';  // e.g., '192.168.1.100'
   ```
3. Set emulator mode:
   ```dart
   static const _useEmulator = false;  // true for emulator, false for physical device
   ```

**How to find your IP:**
- Windows: Run `ipconfig` in Command Prompt
- macOS/Linux: Run `ifconfig` or `ip addr`
- Look for "IPv4 Address" on your WiFi adapter

### Step 3: Run the Mobile App
```bash
cd mobile_app
flutter run
```

## 📱 Device-Specific Instructions

### Android Emulator
```dart
// In api_config.dart:
static const _useEmulator = true;
```
Then run: `flutter run`

### Physical Android/iOS Device
1. Connect device via USB
2. Enable USB Debugging (Android) or Trust Certificate (iOS)
3. Make sure device and computer are on **same WiFi network**
4. Update IP in `api_config.dart`:
   ```dart
   static const _devLanIp = 'YOUR_COMPUTER_IP';
   static const _useEmulator = false;
   ```
5. Run: `flutter run`

## ✅ Verify It's Working

### Backend is Running:
- Visit http://localhost:8000/health
- You should see: `{"status":"ok","version":"1.0.0"}`

### Mobile App Connected:
- Open the app
- Try to register a new account
- If you can register → Everything is working! ✅
- If you get connection error → Check IP address and WiFi

## 🔧 Common Issues & Fixes

### Backend won't start
**Solution:** Make sure Python virtual environment is activated
```bash
.venv\Scripts\activate  # Windows
source .venv/bin/activate  # macOS/Linux
```

### Mobile app can't connect
**Solution 1:** Check if backend is actually running
- Visit http://localhost:8000/health
- If it doesn't load → restart backend

**Solution 2:** Check IP address
- Make sure `_devLanIp` matches your actual IP
- Both devices must be on same WiFi

**Solution 3:** Check Windows Firewall
- Temporarily disable firewall
- Or add exception for port 8000

### "Module not found" error
**Solution:** Install dependencies
```bash
pip install -r requirements.txt
```

### Flutter command not found
**Solution:** Install Flutter SDK
- Download from: https://flutter.dev/docs/get-started/install
- Add to PATH

## 📝 First Time Setup Checklist

- [ ] Python 3.11+ installed
- [ ] Flutter SDK installed
- [ ] Virtual environment created (`.venv` folder exists)
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] `.env` file exists in `backend/` folder
- [ ] API keys added to `.env` file
- [ ] Local IP address configured in `api_config.dart`
- [ ] Device and computer on same WiFi (for physical device)

## 🎉 You're All Set!

Once everything is running:
- ✅ Backend API: http://localhost:8000
- ✅ API Docs: http://localhost:8000/docs
- ✅ Mobile App: Running on your device
- ✅ All features: Working perfectly

## 🆘 Still Having Issues?

1. Check `QUICK_START_GUIDE.md` for detailed troubleshooting
2. Make sure you followed all steps in order
3. Restart both backend and mobile app
4. Try on emulator first, then move to physical device

---

**Need help?** Check the detailed guides:
- `QUICK_START_GUIDE.md` - Complete setup guide
- `backend/README.md` - Backend documentation
- `mobile_app/README.md` - Mobile app documentation
