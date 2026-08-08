# WiFi Change Checklist

## 1. Get new IP
```powershell
ipconfig
# Note IPv4 Address under "Wireless LAN adapter Wi-Fi"
```

## 2. `backend/.env`
```
APP_BASE_URL=http://NEW_IP:8000
CORS_ORIGINS=...existing...,http://NEW_IP:8000
```

## 3. `mobile_app/lib/config/api_config.dart` — line 19
```dart
static const String _wifiBackendUrl = 'http://NEW_IP:8000';
```

## 4. Restart backend & rebuild app
```powershell
# restart backend (run start_all.bat or manually)
# then in mobile_app:
flutter run
```

> Admin dashboard uses `localhost` — no change needed.
