@echo off
REM ============================================================================
REM  Run Flutter Mobile App
REM  Make sure a device/emulator is connected first.
REM ============================================================================
cd /d "%~dp0"

flutter --version >nul 2>&1
if errorlevel 1 (
    echo Flutter not found. Install from https://flutter.dev/docs/get-started/install
    pause & exit /b 1
)

cd mobile_app
echo.
echo Getting Flutter packages...
flutter pub get
echo.
echo Available devices:
flutter devices
echo.
echo Starting mobile app...
echo (You can also open mobile_app/ in Android Studio or VS Code)
echo.
REM Use the app launcher so a physical Android phone receives an ADB reverse
REM tunnel to the local FastAPI server before Flutter starts.
call flutter.bat run
pause
