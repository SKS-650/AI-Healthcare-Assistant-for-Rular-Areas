@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "APP_DIR=%SCRIPT_DIR%mobile_app"
set "BACKEND_DIR=%SCRIPT_DIR%backend"
set "ROOT_WRAPPER=%SCRIPT_DIR%flutter.bat"
set "APP_WRAPPER=%APP_DIR%\flutter.bat"

set "PYTHON_CMD=python"
if exist "%SCRIPT_DIR%venv\Scripts\python.exe" (
    set "PYTHON_CMD=%SCRIPT_DIR%venv\Scripts\python.exe"
) else if exist "%SCRIPT_DIR%.venv\Scripts\python.exe" (
    set "PYTHON_CMD=%SCRIPT_DIR%.venv\Scripts\python.exe"
)

if /I "%~1"=="run" (
    call :ensure_backend
    if errorlevel 1 exit /b 1
    call :configure_android_backend
    echo [2/2] Launching Flutter app...
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

:ensure_backend
echo [1/2] Checking backend server...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8000/health' -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if not errorlevel 1 (
    echo Backend already running on http://127.0.0.1:8000
    exit /b 0
)

echo Starting backend server on http://127.0.0.1:8000...
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

:configure_android_backend
set "FLUTTER_BACKEND_DEFINE="
set "ADB_CMD="
where.exe adb >nul 2>nul && set "ADB_CMD=adb"
if not defined ADB_CMD (
    for /f "tokens=1,* delims==" %%A in ('findstr /b /c:"sdk.dir=" "%APP_DIR%\android\local.properties" 2^>nul') do set "ANDROID_SDK_DIR=%%B"
    if defined ANDROID_SDK_DIR if exist "%ANDROID_SDK_DIR%\platform-tools\adb.exe" set "ADB_CMD=%ANDROID_SDK_DIR%\platform-tools\adb.exe"
)
if not defined ADB_CMD exit /b 0

set "ANDROID_DEVICE_FOUND="
for /f "skip=1 tokens=1,2" %%A in ('"%ADB_CMD%" devices') do (
    if "%%B"=="device" (
        "%ADB_CMD%" -s %%A reverse tcp:8000 tcp:8000 >nul 2>nul
        if not errorlevel 1 set "ANDROID_DEVICE_FOUND=1"
    )
)

if defined ANDROID_DEVICE_FOUND (
    set "FLUTTER_BACKEND_DEFINE=--dart-define=BACKEND_URL=http://127.0.0.1:8000"
    echo Android USB backend forwarding is ready.
)
exit /b 0
