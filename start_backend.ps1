# start_backend.ps1 — starts the FastAPI backend from the project root
# Usage: .\start_backend.ps1

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backend = Join-Path $root "backend"
$venv    = Join-Path $root ".venv\Scripts\Activate.ps1"

Write-Host ""
Write-Host "=== AI Healthcare Assistant — Backend Startup ===" -ForegroundColor Cyan
Write-Host ""

# Activate venv if present
if (Test-Path $venv) {
    Write-Host "Activating virtual environment..." -ForegroundColor Green
    & $venv
} else {
    Write-Host "WARNING: .venv not found. Using system Python." -ForegroundColor Yellow
}

# Move into backend folder
Set-Location $backend

# Install / update dependencies
Write-Host "Checking dependencies..." -ForegroundColor Green
pip install -r requirements.txt -q

# Start server
Write-Host ""
Write-Host "Starting FastAPI on http://localhost:8000" -ForegroundColor Green
Write-Host "API docs: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop." -ForegroundColor Yellow
Write-Host ""

python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
