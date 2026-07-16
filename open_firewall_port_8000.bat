@echo off
REM ============================================================================
REM  Run this ONCE as Administrator to allow your phone to connect to the
REM  backend over WiFi.
REM
REM  Right-click this file → "Run as administrator"
REM ============================================================================

echo Adding Windows Firewall rule to allow inbound connections on port 8000...
echo.

netsh advfirewall firewall delete rule name="FastAPI Backend 8000" >nul 2>nul

netsh advfirewall firewall add rule ^
  name="FastAPI Backend 8000" ^
  dir=in ^
  action=allow ^
  protocol=TCP ^
  localport=8000 ^
  profile=private,domain ^
  description="AI Healthcare Assistant — FastAPI backend for LAN access"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to add rule. Make sure you are running as Administrator.
    pause
    exit /b 1
)

echo.
echo [OK] Port 8000 is now open on private/domain networks.
echo      Your phone (on the same WiFi) can reach the backend at:
echo.

for /f "tokens=2 delims=:" %%a in ('ipconfig 2^>nul ^| findstr /c:"IPv4 Address"') do (
    set "IP=%%a"
    set "IP=!IP:~1!"
    echo      http://!IP!:8000
    goto :done
)
:done

echo.
pause
