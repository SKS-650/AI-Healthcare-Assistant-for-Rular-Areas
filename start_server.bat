@echo off
SETLOCAL EnableDelayedExpansion

REM ============================================================================
REM  AI Healthcare Assistant — Quick Backend Startup Script
REM  ─────────────────────────────────────────────────────
REM  Usage  : Double-click this file OR run from terminal
REM  Requires: Python venv already set up (run start_all.bat once first)
REM
REM  After the server starts:
REM    1. Note the LAN address printed below
REM    2. Connect your phone to the SAME WiFi as this laptop
REM    3. Launch the mobile app — no USB cable needed!
REM ============================================================================

cd /d "%~dp0"

echo.
echo  ================================================================
echo      AI HEALTHCARE ASSISTANT  ^|  Backend Server
echo  ================================================================
echo.

REM ── Activate virtual environment ─────────────────────────────────────────────
if not exist ".venv\Scripts\activate.bat" (
    echo  [ERROR] Virtual environment not found.
    echo          Run start_all.bat first to set everything up.
    pause
    exit /b 1
)

call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo  [ERROR] Cannot activate virtual environment.
    pause
    exit /b 1
)

REM ── Check backend/.env ───────────────────────────────────────────────────────
if not exist "backend\.env" (
    echo  [WARN]  backend\.env not found — using defaults.
    echo          Copy .env.development to backend\.env and set your API keys.
    echo.
)

REM ── Detect local WiFi IP ─────────────────────────────────────────────────────
set "LOCAL_IP=unknown"
for /f "tokens=2 delims=:" %%a in ('ipconfig 2^>nul ^| findstr /c:"IPv4 Address"') do (
    set "LOCAL_IP=%%a"
    set "LOCAL_IP=!LOCAL_IP:~1!"
    REM Use first match (usually the active WiFi adapter)
    goto :ip_found
)
:ip_found

echo  ================================================================
echo.
echo   Server IP (WiFi)  :  http://!LOCAL_IP!:8000
echo   Swagger docs      :  http://!LOCAL_IP!:8000/docs
echo   Health check      :  http://!LOCAL_IP!:8000/health
echo   API base          :  http://!LOCAL_IP!:8000/api/v1
echo.
echo   ► Mobile app config file:
echo     mobile_app\lib\config\api_config.dart
echo     Set  _devLanIp = '!LOCAL_IP!'  if different from 192.168.18.26
echo.
echo   ► Make sure your phone and this laptop are on the SAME WiFi!
echo.
echo  ================================================================
echo.
echo  Starting FastAPI server on 0.0.0.0:8000 ...
echo  Press CTRL+C to stop.
echo.

cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

echo.
echo  Server stopped.
pause
