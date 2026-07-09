@echo off
REM Batch file to start the backend server on Windows

echo ========================================
echo Starting AI Healthcare Backend Server
echo ========================================

REM Change to backend directory
cd /d "%~dp0"

REM Activate virtual environment
if exist "..\\.venv\\Scripts\\activate.bat" (
    echo Activating virtual environment...
    call "..\\.venv\\Scripts\\activate.bat"
) else (
    echo ERROR: Virtual environment not found!
    echo Please run: python -m venv .venv
    pause
    exit /b 1
)

REM Start the server
echo.
echo Starting FastAPI server...
echo.
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

pause
