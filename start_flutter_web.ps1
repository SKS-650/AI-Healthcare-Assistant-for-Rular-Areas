# start_flutter_web.ps1 — runs the Flutter app as a web app on port 3000
# Usage: .\start_flutter_web.ps1

$root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$appDir  = Join-Path $root "mobile_app"

Write-Host ""
Write-Host "=== AI Healthcare Assistant — Flutter Web ===" -ForegroundColor Cyan
Write-Host ""

Set-Location $appDir

Write-Host "Getting packages..." -ForegroundColor Green
flutter pub get

Write-Host ""
Write-Host "Starting Flutter web on http://localhost:3000" -ForegroundColor Green
Write-Host "Make sure the backend is running on port 8000 first!" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop." -ForegroundColor Yellow
Write-Host ""

flutter run -d chrome --web-port 3000
