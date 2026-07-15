@echo off
REM ============================================================================
REM  Build FAISS Semantic Search Index
REM  Run this once after cloning, or after updating medical datasets.
REM  Output: ai_models/saved_models/faiss_index/
REM ============================================================================
cd /d "%~dp0"

if not exist ".venv\Scripts\activate.bat" (
    echo Virtual environment not found. Run start_all.bat first.
    pause & exit /b 1
)
call .venv\Scripts\activate.bat

echo.
echo Building FAISS index from medical datasets...
echo (Takes 5-20 minutes on first run)
echo.
python ai_models\scripts\build_faiss_index.py %*
if errorlevel 1 (
    echo.
    echo [ERROR] Index build failed. Check the output above.
) else (
    echo.
    echo [OK] Index built successfully.
    echo Output: ai_models\saved_models\faiss_index\
)
echo.
pause
