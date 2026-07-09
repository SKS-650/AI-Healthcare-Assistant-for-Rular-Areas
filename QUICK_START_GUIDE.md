# 🚀 Quick Start Guide - AI Healthcare Assistant

This guide will help you run the complete AI Healthcare Assistant application with just a few commands.

## 📋 Prerequisites

### Required Software
- **Python 3.11+** - [Download](https://www.python.org/downloads/)
- **Flutter SDK 3.12+** - [Download](https://flutter.dev/docs/get-started/install)
- **Git** - [Download](https://git-scm.com/downloads)

### Optional (for full features)
- **PostgreSQL** (optional - SQLite is used by default)
- **Redis** (optional - for caching)

## 🎯 One-Time Setup

### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd ai_healthcare_assistant
```

### Step 2: Setup Python Virtual Environment
```bash
# Create virtual environment
python -m venv .venv

# Activate it
# On Windows:
.venv\Scripts\activate
# On macOS/Linux:
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Configure Environment
```bash
# Copy example environment file
cp backend/.env.example backend/.env

# Edit backend/.env and add your configuration
# Minimum required: JWT_SECRET_KEY and CHATBOT_LLM_API_KEY
```

### Step 4: Initialize Database
```bash
cd backend
# Run database migrations
alembic upgrade head
cd ..
```

## 🏃 Running the Application

### Method 1: Automatic Startup (Recommended)

#### On Windows:
```cmd
REM Start backend server
cd backend
start_backend.bat

REM In a new terminal, start mobile app
cd mobile_app
flutter run
```

#### On macOS/Linux:
```bash
# Start backend server
cd backend
chmod +x start_backend.sh
./start_backend.sh &

# Start mobile app
cd mobile_app
flutter run
```

### Method 2: Manual Startup

#### Terminal 1 - Backend Server:
```bash
cd backend
..\\.venv\\Scripts\\activate  # Windows
# source ../.venv/bin/activate  # macOS/Linux
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Terminal 2 - Mobile App:
```bash
cd mobile_app
flutter run
```

## 📱 Device Configuration

### For Android Emulator
1. Start Android emulator from Android Studio
2. In `mobile_app/lib/config/api_config.dart`, set:
   ```dart
   static const _useEmulator = true;
   ```
3. Run `flutter run`

### For Physical Android Device
1. Enable Developer Options and USB Debugging on your device
2. Connect device via USB
3. Find your computer's local IP address:
   - Windows: Run `ipconfig` and look for IPv4 Address
   - macOS/Linux: Run `ifconfig` or `ip addr`
4. In `mobile_app/lib/config/api_config.dart`, set:
   ```dart
   static const _devLanIp = 'YOUR_IP_ADDRESS';  // e.g., '192.168.1.100'
   static const _useEmulator = false;
   ```
5. Make sure your device and computer are on the same WiFi network
6. Run `flutter run`

### For iOS Simulator
1. Start iOS Simulator from Xcode
2. In `mobile_app/lib/config/api_config.dart`, set:
   ```dart
   static const _useEmulator = true;
   ```
3. Run `flutter run`

### For Physical iOS Device
1. Connect device via USB
2. Trust the developer certificate on your device
3. Find your computer's local IP (same as Android above)
4. In `mobile_app/lib/config/api_config.dart`, set:
   ```dart
   static const _devLanIp = 'YOUR_IP_ADDRESS';
   static const _useEmulator = false;
   ```
5. Run `flutter run`

## 🧪 Verify Installation

### 1. Check Backend Health
Open browser and visit:
- http://localhost:8000/health - Should return `{"status": "ok"}`
- http://localhost:8000/docs - Interactive API documentation

### 2. Test API Endpoints
```bash
# Test authentication
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!","full_name":"Test User"}'

# Test symptom checker
curl http://localhost:8000/api/v1/symptom-checker/symptoms

# Test chatbot health
curl http://localhost:8000/api/v1/chatbot/health
```

### 3. Test Mobile App
1. Launch the app on your device/emulator
2. You should see the splash screen followed by onboarding/login
3. Try registering a new account
4. Test symptom checker and chatbot features

## 🔧 Troubleshooting

### Backend won't start
**Error:** `ImportError: cannot import name 'get_session'`
- ✅ **Fixed!** This has been resolved in the latest version

**Error:** `Module not found`
- Run: `pip install -r requirements.txt`

**Error:** `Database connection failed`
- Check if `.env` file exists in `backend/` directory
- Verify DATABASE_URL (or leave commented for SQLite)

### Mobile app can't connect to backend
**Error:** `Connection refused` or timeout
- ✅ Verify backend is running (check http://localhost:8000/health)
- ✅ Check `_devLanIp` in `api_config.dart` matches your machine's IP
- ✅ Ensure device and computer are on same WiFi network
- ✅ Check if firewall is blocking port 8000
- ✅ Try restarting both backend and mobile app

**Error:** `Connection timeout on physical device`
- Disable Windows Firewall temporarily or add exception for port 8000
- Verify your phone can ping your computer
- Make sure you're using your computer's WiFi IP, not ethernet IP

### Flutter issues
**Error:** `Flutter SDK not found`
- Install Flutter: https://flutter.dev/docs/get-started/install
- Add Flutter to PATH

**Error:** `No devices found`
- For Android: Enable USB debugging
- For iOS: Trust developer certificate
- Check: `flutter devices`

## 📖 API Documentation

Once backend is running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🎨 Features Available

### ✅ Authentication
- User Registration
- Email/Password Login
- Email Verification
- Password Reset
- JWT Token Management

### ✅ User Management
- Profile Management
- Address Management
- Emergency Contacts
- Medical Information

### ✅ Symptom Checker
- 230+ Symptoms Recognition
- 100+ Disease Predictions
- Risk Assessment
- Medical Recommendations

### ✅ Medical Chatbot
- AI-Powered Medical Queries
- Multi-language Support (English, Nepali, Hindi, Bhojpuri)
- Context-Aware Conversations
- Emergency Detection
- Medical Knowledge Base Integration

## 🔐 Security Notes

### Development Mode
- Default database: SQLite (no setup needed)
- CORS: Allow all origins (development only)
- Debug mode: Enabled

### Production Recommendations
- Use PostgreSQL instead of SQLite
- Configure proper CORS origins in `.env`
- Set strong `JWT_SECRET_KEY`
- Enable HTTPS
- Set `DEBUG=false`
- Use proper secret management

## 📚 Additional Resources

- [Backend API Documentation](./backend/README.md)
- [Mobile App Documentation](./mobile_app/README.md)
- [Symptom Checker Guide](./SYMPTOM_CHECKER_COMPLETE.md)
- [Chatbot Setup Guide](./CHATBOT_SETUP_GUIDE.md)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)

## 💡 Tips for Best Experience

1. **First Time Users**
   - Start with emulator for easier testing
   - Move to physical device once comfortable

2. **Development**
   - Use `--hot-reload` with Flutter for faster development
   - Check backend logs for API errors
   - Use Swagger UI for API testing

3. **Physical Devices**
   - Always use same WiFi network
   - Note your IP can change (restart backend if needed)
   - Disable VPN for better connectivity

4. **Performance**
   - Backend typically uses 200-500MB RAM
   - First API calls might be slower (model loading)
   - Symptom checker loads ~230 features

## 🆘 Getting Help

If you encounter issues:

1. Check this guide's troubleshooting section
2. Review error messages carefully
3. Check backend logs in terminal
4. Verify network connectivity
5. Try restarting both backend and app

## 🎉 Success!

Once everything is running:
- ✅ Backend API at http://localhost:8000
- ✅ Mobile app on your device
- ✅ All features working
- ✅ Database initialized
- ✅ AI models loaded

You're ready to develop and test the AI Healthcare Assistant! 🚀

---

**Last Updated:** January 2025
**Version:** 1.0.0
