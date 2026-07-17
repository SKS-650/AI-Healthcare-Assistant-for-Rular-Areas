@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "APP_DIR=%SCRIPT_DIR%"
set "BACKEND_DIR=%SCRIPT_DIR%..\backend"
set "ROOT_WRAPPER=%SCRIPT_DIR%..\flutter.bat"
set "APP_WRAPPER=%SCRIPT_DIR%flutter.bat"

set "PYTHON_CMD=python"
if exist "%SCRIPT_DIR%..\venv\Scripts\python.exe" (
    set "PYTHON_CMD=%SCRIPT_DIR%..\venv\Scripts\python.exe"
) else if exist "%SCRIPT_DIR%..\.venv\Scripts\python.exe" (
    set "PYTHON_CMD=%SCRIPT_DIR%..\.venv\Scripts\python.exe"
)

if /I "%~1"=="run" (
    call :ensure_firewall
    call :ensure_backend
    if errorlevel 1 exit /b 1
    call :configure_android_backend
    echo [3/3] Launching Flutter app...
)

set "FLUTTER_CMD="
for /f "delims=" %%I in ('where.exe flutter.bat 2^>nul') do (
    if /I not "%%~fI"=="%ROOT_WRAPPER%" if /I not "%%~fI"=="%APP_WRAPPER%" if not defined FLUTTER_CMD set "FLUTTER_CMD=%%~fI"
)

if not defined FLUTTER_CMD (
    for /f "delims=" %%I in ('where.exe flutter.exe 2^>nul') do (
        if /I not "%%~fI"=="%~f0" if not defined FLUTTER_CMD set "FLUTTER_CMD=%%~fI"
    )
)

if not defined FLUTTER_CMD (
    echo Flutter SDK was not found on PATH.
    exit /b 1
)

cd /d "%APP_DIR%"
call "%FLUTTER_CMD%" %* %FLUTTER_BACKEND_DEFINE%
exit /b %ERRORLEVEL%

REM ─────────────────────────────────────────────────────────────────────────────
REM  ensure_firewall  — adds Windows Firewall inbound rule for port 8000 once
REM ─────────────────────────────────────────────────────────────────────────────
:ensure_firewall
netsh advfirewall firewall show rule name="FastAPI Backend 8000" >nul 2>nul
if not errorlevel 1 exit /b 0

echo [1/3] Adding Windows Firewall rule for port 8000 (requires admin)...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process netsh -ArgumentList 'advfirewall firewall add rule name=""FastAPI Backend 8000"" dir=in action=allow protocol=TCP localport=8000 profile=private,domain description=""AI Healthcare Assistant backend""' -Verb RunAs -Wait" >nul 2>nul
if errorlevel 1 (
    echo [WARN] Could not add firewall rule automatically.
    echo        Run this manually as Administrator:
    echo        netsh advfirewall firewall add rule name="FastAPI Backend 8000" dir=in action=allow protocol=TCP localport=8000
) else (
    echo [OK] Firewall rule added — port 8000 is now open on private networks.
)
exit /b 0

REM ─────────────────────────────────────────────────────────────────────────────
REM  ensure_backend  — starts the backend if not already running
REM ─────────────────────────────────────────────────────────────────────────────
:ensure_backend
echo [2/3] Checking backend server...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8000/health' -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if not errorlevel 1 (
    echo Backend already running on http://127.0.0.1:8000
    exit /b 0
)

echo Starting backend server on http://0.0.0.0:8000...
start "AI Healthcare Backend" /min cmd /k "cd /d ""%BACKEND_DIR%"" && ""%PYTHON_CMD%"" -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

echo Waiting for backend to become ready...
for /l %%A in (1,1,45) do (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8000/health' -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
    if not errorlevel 1 (
        echo Backend is ready.
        exit /b 0
    )
    timeout /t 1 /nobreak >nul
)

echo Backend did not become ready. Check the "AI Healthcare Backend" window for errors.
exit /b 1

REM ─────────────────────────────────────────────────────────────────────────────
REM  configure_android_backend  — sets FLUTTER_BACKEND_DEFINE
REM    USB device found + ADB tunnel  → BACKEND_URL=http://127.0.0.1:8000
REM    AVD emulator detected          → IS_EMULATOR=true  (app uses 10.0.2.2)
REM    WiFi physical device           → BACKEND_URL=http://<LAN IP>:8000
REM ─────────────────────────────────────────────────────────────────────────────
:configure_android_backend
set "FLUTTER_BACKEND_DEFINE="
set "ADB_CMD="

where.exe adb >nul 2>nul && set "ADB_CMD=adb"
if not defined ADB_CMD (
    for /f "tokens=1,* delims==" %%A in ('findstr /b /c:"sdk.dir=" "%APP_DIR%\android\local.properties" 2^>nul') do set "ANDROID_SDK_DIR=%%B"
    if defined ANDROID_SDK_DIR if exist "%ANDROID_SDK_DIR%\platform-tools\adb.exe" set "ADB_CMD=%ANDROID_SDK_DIR%\platform-tools\adb.exe"
)

if not defined ADB_CMD (
    echo [INFO] adb not found on PATH — skipping Android device detection.
    echo        Physical device will use hardcoded LAN IP from api_config.dart
    exit /b 0
)

REM ── Check for USB physical device (state = "device", not "emulator") ────────
set "ANDROID_USB_FOUND="
set "ANDROID_EMU_FOUND="

for /f "skip=1 tokens=1,2" %%A in ('"%ADB_CMD%" devices 2^>nul') do (
    if "%%B"=="device" (
        REM Check if this is an emulator (serial starts with "emulator-")
        echo %%A | findstr /i /b "emulator-" >nul 2>nul
        if not errorlevel 1 (
            set "ANDROID_EMU_FOUND=1"
        ) else (
            REM Physical USB device — set up reverse tunnel
            "%ADB_CMD%" -s %%A reverse tcp:8000 tcp:8000 >nul 2>nul
            if not errorlevel 1 set "ANDROID_USB_FOUND=1"
        )
    )
)

if defined ANDROID_USB_FOUND (
    REM ADB reverse tunnel active — 127.0.0.1 on device = host machine
    set "FLUTTER_BACKEND_DEFINE=--dart-define=BACKEND_URL=http://127.0.0.1:8000"
    echo Android USB device detected. ADB reverse tunnel active ^(127.0.0.1:8000^).
    exit /b 0
)

if defined ANDROID_EMU_FOUND (
    REM Android emulator — use IS_EMULATOR flag so app picks 10.0.2.2
    set "FLUTTER_BACKEND_DEFINE=--dart-define=IS_EMULATOR=true"
    echo Android emulator detected. App will use 10.0.2.2:8000.
    exit /b 0
)

REM ── No ADB device connected — detect LAN IP for WiFi physical device ─────────
REM
REM For WiFi physical devices we do NOT inject a BACKEND_URL dart-define.
REM The hardcoded _wifiBackendUrl in lib/config/api_config.dart
REM (currently http://192.168.254.5:8000) is used instead.
REM
REM This avoids unreliable ipconfig text-parsing producing malformed URLs
REM like "http://192.168.254.5.8000" (dot instead of colon).
REM
REM To use a DIFFERENT IP, either:
REM   a) Edit _wifiBackendUrl in lib/config/api_config.dart  (recommended)
REM   b) Run:  flutter run --dart-define=BACKEND_URL=http://YOUR_IP:8000

echo No USB/emulator device. Physical WiFi device will use the IP hardcoded
echo in lib/config/api_config.dart  ^(currently http://192.168.254.5:8000^).
exit /b 0
