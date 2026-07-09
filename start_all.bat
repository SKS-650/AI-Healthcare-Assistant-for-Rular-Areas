@echo off
SETLOCAL EnableDelayedExpansion

REM ============================================================================
REM AI Healthcare Assistant - Complete Startup Script
REM This script starts both backend and provides instructions for mobile app
REM ============================================================================

echo.
echo =========================================================================
echo            AI HEALTHCARE ASSISTANT - COMPLETE STARTUP
echo =========================================================================
echo.

REM Change to project root
cd /d "%~dp0"

REM ─── Check Prerequisites ─────────────────────────────────────────────────

echo [1/5] Checking prerequisites...
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.11+ from https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [OK] Python found: 
python --version

REM Check Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Flutter is not installed or not in PATH
    echo You'll need Flutter to run the mobile app
    echo Download from: https://flutter.dev/docs/get-started/install
    echo.
    echo You can still start the backend server...
    timeout /t 3 >nul
) else (
    echo [OK] Flutter found:
    flutter --version | findstr "Flutter"
)

echo.

REM ─── Setup Virtual Environment ──────────────────────────────────────────

echo [2/5] Setting up virtual environment...
echo.

if not exist ".venv" (
    echo Creating new virtual environment...
    python -m venv .venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment
        pause
        exit /b 1
    )
    echo [OK] Virtual environment created
) else (
    echo [OK] Virtual environment already exists
)

echo.

REM ─── Activate Virtual Environment ───────────────────────────────────────

echo [3/5] Activating virtual environment...
echo.

call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment
    pause
    exit /b 1
)
echo [OK] Virtual environment activated

echo.

REM ─── Install Dependencies ───────────────────────────────────────────────

echo [4/5] Checking Python dependencies...
echo.

REM Check if packages are installed
pip show fastapi >nul 2>&1
if errorlevel 1 (
    echo Installing Python dependencies (this may take a few minutes)...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
    echo [OK] Dependencies installed
) else (
    echo [OK] Dependencies already installed
)

echo.

REM ─── Check Environment Configuration ────────────────────────────────────

echo [5/5] Checking configuration...
echo.

if not exist "backend\.env" (
    echo [WARNING] backend\.env file not found
    echo Creating from template...
    if exist "backend\.env.example" (
        copy backend\.env.example backend\.env >nul
        echo [OK] Created backend\.env from template
        echo [ACTION REQUIRED] Please edit backend\.env and add your API keys:
        echo - JWT_SECRET_KEY
        echo - CHATBOT_LLM_API_KEY
        echo.
        timeout /t 5
    ) else (
        echo [ERROR] backend\.env.example not found
        pause
        exit /b 1
    )
) else (
    echo [OK] Configuration file found
)

echo.

REM ─── Get Local IP Address ───────────────────────────────────────────────

echo Detecting your local IP address...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set "LOCAL_IP=%%a"
    set "LOCAL_IP=!LOCAL_IP:~1!"
    goto :ip_found
)
:ip_found

if defined LOCAL_IP (
    echo [INFO] Your local IP address: !LOCAL_IP!
    echo.
    echo To run on a physical device, update mobile_app/lib/config/api_config.dart:
    echo   static const _devLanIp = '!LOCAL_IP!';
    echo   static const _useEmulator = false;
) else (
    echo [WARNING] Could not detect IP address automatically
)

echo.
echo.

REM ─── Start Backend Server ───────────────────────────────────────────────

echo =========================================================================
echo                         STARTING BACKEND SERVER
echo =========================================================================
echo.
echo Backend will start on: http://0.0.0.0:8000
echo API Documentation: http://localhost:8000/docs
echo Health Check: http://localhost:8000/health
echo.
echo [INFO] Backend logs will appear below...
echo [INFO] Press CTRL+C to stop the server
echo.
echo -------------------------------------------------------------------------
echo.

cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

REM If we reach here, server was stopped
echo.
echo.
echo =========================================================================
echo Backend server stopped
echo =========================================================================
pause
