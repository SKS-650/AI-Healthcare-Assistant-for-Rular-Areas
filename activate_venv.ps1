# Virtual Environment Activation Script
# Run this script to activate the virtual environment

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "AI Healthcare Assistant - Virtual Env" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

$venvPath = Join-Path $PSScriptRoot "venv"

if (Test-Path $venvPath) {
    Write-Host "✓ Virtual environment found" -ForegroundColor Green
    Write-Host ""
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    
    & "$venvPath\Scripts\Activate.ps1"
    
    Write-Host ""
    Write-Host "✓ Virtual environment activated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Python location:" -ForegroundColor Yellow
    Write-Host "  $(Get-Command python | Select-Object -ExpandProperty Source)" -ForegroundColor White
    Write-Host ""
    Write-Host "Python version:" -ForegroundColor Yellow
    python --version
    Write-Host ""
    Write-Host "You can now:" -ForegroundColor Yellow
    Write-Host "  - Install packages: pip install -r backend/requirements.txt" -ForegroundColor White
    Write-Host "  - Run backend: cd backend && python -m uvicorn app.main:app --reload" -ForegroundColor White
    Write-Host "  - Run AI models: cd ai_models && python script.py" -ForegroundColor White
    Write-Host ""
    Write-Host "To deactivate: type 'deactivate'" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "✗ Virtual environment not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    Write-Host "✓ Virtual environment created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Please run this script again to activate it." -ForegroundColor Yellow
}
