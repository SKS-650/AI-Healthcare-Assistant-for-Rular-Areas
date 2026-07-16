@echo off
setlocal enabledelayedexpansion
title AI Healthcare Assistant — Admin Dashboard Launcher

echo.
echo  =========================================================
echo   AI Healthcare Assistant — Admin Dashboard
echo  =========================================================
echo.

:: ── 1. Activate virtual environment ──────────────────────────────────────────
if not exist ".venv\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found. Run: python -m venv .venv
    pause
    exit /b 1
)
echo [1/4] Activating virtual environment...
call .venv\Scripts\activate.bat

:: ── 2. Install / verify Python dependencies ───────────────────────────────────
echo [2/4] Checking Python dependencies...
pip install -r requirements.txt -q

:: ── 3. Seed the admin user and default settings (idempotent) ─────────────────
echo [3/4] Seeding admin user and system settings...
cd backend
python -m app.admin.seed
if errorlevel 1 (
    echo [WARN] Seed step returned a non-zero exit code — this is safe to ignore
    echo        if the admin user already exists.
)
cd ..

:: ── 4. Start FastAPI backend in a new window ──────────────────────────────────
echo [4/4] Starting FastAPI backend on http://localhost:8000 ...
start "Healthcare Backend" cmd /k "call .venv\Scripts\activate.bat && cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"

:: Brief pause so the backend can start before the browser opens
timeout /t 3 /nobreak >nul

:: ── 5. Start Flutter Web dashboard ───────────────────────────────────────────
echo.
echo  Starting Flutter Web dashboard on http://localhost:5000
echo  (This may take a minute on first run while dependencies compile)
echo.
cd admin_dashboard
start "Healthcare Admin UI" cmd /k "flutter run -d chrome --web-port 5000"
cd ..

echo.
echo  =========================================================
echo   Services launching in separate windows.
echo.
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/docs
echo   Dashboard: http://localhost:5000
echo.
echo   Default credentials:
echo     Email:    admin@healthcare.ai
echo     Password: Admin@123456
echo  =========================================================
echo.
pause
