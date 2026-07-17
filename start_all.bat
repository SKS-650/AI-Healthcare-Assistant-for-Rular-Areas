@echo off
SETLOCAL EnableDelayedExpansion

REM ============================================================================
REM  AI Medical Voice Assistant — Full Startup Script
REM  Starts the FastAPI backend with all AI services (voice, FAISS, LLM)
REM ============================================================================

echo.
echo  ==========================================================================
echo      AI MEDICAL VOICE ASSISTANT  ^|  Production Startup
echo  ==========================================================================
echo.

cd /d "%~dp0"

REM ── 1. Prerequisites ────────────────────────────────────────────────────────

echo  [1/6] Checking prerequisites...
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] Python not found. Install Python 3.11+ from https://python.org
    pause & exit /b 1
)
for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo  [OK] %%v

flutter --version >nul 2>&1
if errorlevel 1 (
    echo  [WARN]  Flutter not found — mobile app cannot be run from here.
) else (
    for /f "tokens=1,2" %%a in ('flutter --version 2^>^&1 ^| findstr "Flutter"') do echo  [OK] Flutter %%b
)
echo.

REM ── 2. Virtual environment ──────────────────────────────────────────────────

echo  [2/6] Setting up virtual environment...
echo.

if not exist ".venv" (
    echo  Creating virtual environment...
    python -m venv .venv
    if errorlevel 1 ( echo  [ERROR] venv failed & pause & exit /b 1 )
)
call .venv\Scripts\activate.bat
if errorlevel 1 ( echo  [ERROR] Cannot activate venv & pause & exit /b 1 )
echo  [OK] Virtual environment active
echo.

REM ── 3. Install / verify dependencies ─────────────────────────────────────

echo  [3/6] Checking Python dependencies...
echo.

pip show fastapi >nul 2>&1
if errorlevel 1 (
    echo  Installing core dependencies (this may take a few minutes)...
    pip install -r requirements.txt --quiet
    if errorlevel 1 ( echo  [ERROR] pip install failed & pause & exit /b 1 )
    echo  [OK] Core dependencies installed
) else (
    echo  [OK] Core dependencies already present
)

REM Check key AI packages individually so we can give targeted warnings
for %%p in (sentence_transformers faiss langdetect deep_translator edge_tts gtts openai whisper) do (
    pip show %%p >nul 2>&1
    if errorlevel 1 (
        echo  [WARN]  %%p not installed — some AI features may be limited
    )
)
echo.

REM ── 4. Environment file ─────────────────────────────────────────────────────

echo  [4/6] Checking environment configuration...
echo.

if not exist "backend\.env" (
    echo  backend\.env not found — creating from template...
    if exist ".env.example" (
        copy .env.example backend\.env >nul
        echo  [OK] backend\.env created from .env.example
        echo  [ACTION REQUIRED] Open backend\.env and set:
        echo     CHATBOT_LLM_API_KEY  = your Gemini / OpenAI API key
        echo     JWT_SECRET_KEY       = a long random secret string
        echo.
        timeout /t 6 /nobreak >nul
    ) else (
        echo  [ERROR] .env.example not found.
        pause & exit /b 1
    )
) else (
    echo  [OK] backend\.env found
)
echo.

REM ── 5. Build FAISS index (if not already built) ──────────────────────────────

echo  [5/6] Checking FAISS knowledge index...
echo.

if not exist "ai_models\saved_models\faiss_index\index.faiss" (
    echo  FAISS index not found.
    echo  Building semantic search index from medical datasets...
    echo  (This runs once and takes 5–20 minutes depending on your hardware)
    echo.
    python ai_models\scripts\build_faiss_index.py
    if errorlevel 1 (
        echo  [WARN]  FAISS index build failed — offline mode will use keyword search only
    ) else (
        echo  [OK] FAISS index built successfully
    )
) else (
    echo  [OK] FAISS index already exists — skipping build
)
echo.

REM ── 6. Start backend ────────────────────────────────────────────────────────

REM Detect local IP for mobile app connection info
for /f "tokens=2 delims=:" %%a in ('ipconfig 2^>nul ^| findstr /c:"IPv4 Address"') do (
    set "LOCAL_IP=%%a"
    set "LOCAL_IP=!LOCAL_IP:~1!"
    goto :got_ip
)
:got_ip

echo  [6/6] Starting backend server...
echo.
echo  ==========================================================================
echo   Backend URL   :  http://0.0.0.0:8000
echo   Swagger UI    :  http://localhost:8000/docs
echo   Health check  :  http://localhost:8000/health
echo   Voice API     :  http://localhost:8000/api/v1/voice/health
echo   Chatbot API   :  http://localhost:8000/api/v1/chatbot/health
if defined LOCAL_IP (
echo.
echo   ── WiFi Mobile Access ────────────────────────────────────────────────
echo   LAN address   :  http://!LOCAL_IP!:8000
echo   Swagger (LAN) :  http://!LOCAL_IP!:8000/docs
echo   Health (LAN)  :  http://!LOCAL_IP!:8000/health
echo.
echo   ► Open http://!LOCAL_IP!:8000/docs on your PHONE browser to verify.
echo.
echo   Mobile app WiFi config:
echo     File : mobile_app\lib\config\api_config.dart
echo     Set  _devLanIp = '!LOCAL_IP!'  (currently set to 192.168.254.5)
echo     If the IPs differ, update _devLanIp and re-run: flutter build apk
echo.
echo   ► Both the laptop and phone MUST be on the SAME WiFi network.
echo   ► No USB cable required after the APK is installed.
)
echo  ==========================================================================
echo.
echo  Press CTRL+C to stop.
echo.

cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

echo.
echo  Server stopped.
pause
