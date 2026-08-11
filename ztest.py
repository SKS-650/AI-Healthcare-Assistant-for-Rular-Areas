# cd d:\MinorProject\ai_healthcare_assistant.\.venv\Scripts\activate

# cd backend
# python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
# uvicorn app.main:app --reload


# mobile_app\build\app\outputs\flutter-apk\app-debug.apk




# You need to change IP address in 3 files:
# Main File (Mobile App):

# 1)            api_config.dart
# d:\MinorProject\ai_healthcare_assistant\mobile_app\lib\config\api_config.dart
#  - Line 19
# Change: 'http://192.168.254.11:8000'
# Other Locations:

# 2)             .env
# d:\MinorProject\ai_healthcare_assistant\backend\.env
#  - Line 5 & 6

# APP_BASE_URL
# CORS_ORIGINS (add your new IP here too)

# 3)               server_status_banner.dart
# d:\MinorProject\ai_healthcare_assistant\mobile_app\lib\core\widgets\server_status_banner.dart
#  - Line 294

# Change: 'http://192.168.18.26:8000'
# Optional (Admin Dashboard):

# 4)                 constants.dart
#  - Line 9
# If you use admin dashboard on device
# Priority order:

# Must change: #1 (api_config.dart)
# Should change: #2 (backend/.env for CORS)
# Can change: #3 and #4 (for consistency)















#  Exact IP Configuration Locations
# With the new centralized setup, you need to update ONLY 2 FILES:

# ✅ Files to Update When Switching WiFi
# 1. Mobile App Configuration

# d:\MinorProject\ai_healthcare_assistant\mobile_app\.env
# Line to change:

# env

# BACKEND_URL=http://192.168.137.1:8000
#               ^^^^^^^^^^^^^^^^
#               Replace this IP only
# 2. Admin Dashboard Configuration

# d:\MinorProject\ai_healthcare_assistant\admin_dashboard\.env
# Line to change:

# env

# BACKEND_URL=http://192.168.137.1:8000
#               ^^^^^^^^^^^^^^^^
#               Replace this IP only

# 📝 Quick Change Checklist
# When you switch WiFi networks:

# ✅ Find your new IP: ipconfig → Look for "IPv4 Address"
# ✅ Edit File 1: 
# .env
#  → Line 16 → Update IP
# ✅ Edit File 2: 
# .env
#  → Line 16 → Update IP
# ✅ Restart apps: flutter run
# Total files to edit: 2 Total lines to change: 2 (one per file) Time required: ~10 second0s







#  Exact Answer: 2 Files Only
# When you switch WiFi networks, you need to change the IP address in ONLY 2 files:

# ✅ Files to Update
# 1️⃣ Mobile App

# d:\MinorProject\ai_healthcare_assistant\mobile_app\.env
# Line 17 - Change this:

# env

# BACKEND_URL=http://192.168.18.26:8000
#               ^^^^^^^^^^^^^^^^
#               Your new IP here
# 2️⃣ Admin Dashboard (if you use it)

# d:\MinorProject\ai_healthcare_assistant\admin_dashboard\.env
# Line 17 - Change this:

# env

# BACKEND_URL=http://192.168.18.26:8000
#               ^^^^^^^^^^^^^^^^
#               Your new IP here



# If you switch WiFi later:

# cd backend
# python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000



# 1.   Update network.env
# 2.   Run 
# sync_ip.ps1
# 3.   Rebuild the APK → reinstall on phones
#   cd mobile_app
#   flutter build apk --debug

# 4.    share : 
# mobile_app\build\app\outputs\flutter-apk\app-debug.apk



