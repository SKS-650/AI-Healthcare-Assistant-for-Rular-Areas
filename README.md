# AI Healthcare Assistant

Project workspace for the AI Healthcare Assistant.

## Quick Start for Mobile Development

### Backend Setup
```powershell
# Start backend for mobile access (Windows)
cd backend
.\start_for_mobile.ps1
```

Or manually:
```powershell
cd backend
.venv\Scripts\Activate.ps1
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

⚠️ **Important:** Use `--host 0.0.0.0` not `localhost` for mobile access!

### Mobile App Setup

1. **Check your network configuration:**
   ```powershell
   cd mobile_app
   .\check_network.ps1
   ```

2. **Update IP address in `mobile_app/lib/config/api_config.dart`:**
   ```dart
   static const _devLanIp = 'YOUR_WIFI_IP';  // e.g., '192.168.18.26'
   ```

3. **Run the app:**
   ```powershell
   cd mobile_app
   flutter run
   ```

### Mobile Connection Issues?

If you see connection timeout errors on mobile:
- See detailed troubleshooting guide: [`mobile_app/MOBILE_TROUBLESHOOTING.md`](mobile_app/MOBILE_TROUBLESHOOTING.md)
- Run network diagnostic: `.\check_network.ps1`
- Ensure mobile device is on **same WiFi** as your computer
- Check firewall settings

## Project Structure

- `backend/` - FastAPI backend server
- `mobile_app/` - Flutter mobile application  
- `admin_dashboard/` - Flutter web admin dashboard
- `ai_models/` - AI/ML models and training scripts
