# AI Healthcare Assistant - Quick Installation Script
# This script automates the installation process

param(
    [switch]$FullInstall = $false,
    [switch]$BackendOnly = $false,
    [switch]$AIOnly = $false,
    [switch]$SkipVerify = $false
)

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "AI Healthcare Assistant - Installation" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if command exists
function Test-Command {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "[1/6] Checking Prerequisites..." -ForegroundColor Yellow

if (-not (Test-Command python)) {
    Write-Host "✗ Python not found!" -ForegroundColor Red
    Write-Host "  Please install Python 3.11+ from https://www.python.org/" -ForegroundColor Yellow
    exit 1
}

$pythonVersion = python --version 2>&1
Write-Host "✓ Python installed: $pythonVersion" -ForegroundColor Green

if (-not (Test-Command git)) {
    Write-Host "⚠ Git not found (optional)" -ForegroundColor Yellow
} else {
    Write-Host "✓ Git installed: $(git --version)" -ForegroundColor Green
}

# Check virtual environment
Write-Host ""
Write-Host "[2/6] Checking Virtual Environment..." -ForegroundColor Yellow

if (-not (Test-Path "venv")) {
    Write-Host "  Creating virtual environment..." -ForegroundColor Gray
    python -m venv venv
    Write-Host "✓ Virtual environment created" -ForegroundColor Green
} else {
    Write-Host "✓ Virtual environment exists" -ForegroundColor Green
}

# Activate virtual environment
Write-Host ""
Write-Host "[3/6] Activating Virtual Environment..." -ForegroundColor Yellow

try {
    & ".\venv\Scripts\Activate.ps1"
    Write-Host "✓ Virtual environment activated" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to activate virtual environment" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Upgrade pip
Write-Host ""
Write-Host "[4/6] Upgrading pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
Write-Host "✓ pip upgraded" -ForegroundColor Green

# Determine what to install
Write-Host ""
Write-Host "[5/6] Installing Dependencies..." -ForegroundColor Yellow

if ($BackendOnly) {
    Write-Host "  Installing backend dependencies only..." -ForegroundColor Gray
    pip install -r backend/requirements.txt
    Write-Host "✓ Backend dependencies installed" -ForegroundColor Green
}
elseif ($AIOnly) {
    Write-Host "  Installing AI model dependencies only..." -ForegroundColor Gray
    pip install -r ai_models/requirements.txt
    Write-Host "✓ AI model dependencies installed" -ForegroundColor Green
}
else {
    Write-Host "  Installing all dependencies..." -ForegroundColor Gray
    pip install -r requirements.txt
    Write-Host "✓ All dependencies installed" -ForegroundColor Green
}

# Verify installation
if (-not $SkipVerify) {
    Write-Host ""
    Write-Host "[6/6] Verifying Installation..." -ForegroundColor Yellow

    $packages = @(
        @{Name="fastapi"; Display="FastAPI"},
        @{Name="uvicorn"; Display="Uvicorn"},
        @{Name="sqlalchemy"; Display="SQLAlchemy"},
        @{Name="pydantic"; Display="Pydantic"},
        @{Name="numpy"; Display="NumPy"},
        @{Name="pandas"; Display="Pandas"},
        @{Name="sklearn"; Display="scikit-learn"},
        @{Name="pytest"; Display="pytest"}
    )

    $failed = @()
    foreach ($pkg in $packages) {
        try {
            python -c "import $($pkg.Name)" 2>$null
            Write-Host "  ✓ $($pkg.Display)" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ $($pkg.Display)" -ForegroundColor Red
            $failed += $pkg.Display
        }
    }

    if ($failed.Count -gt 0) {
        Write-Host ""
        Write-Host "⚠ Some packages failed to import: $($failed -join ', ')" -ForegroundColor Yellow
        Write-Host "  Try reinstalling: pip install -r requirements.txt" -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "✅ All packages verified!" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "[6/6] Skipping Verification (--SkipVerify flag)" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ Installation Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Configure backend:" -ForegroundColor White
Write-Host "     cd backend" -ForegroundColor Gray
Write-Host "     Copy-Item .env.example .env" -ForegroundColor Gray
Write-Host "     # Edit .env with your settings" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Setup database:" -ForegroundColor White
Write-Host "     psql -U postgres -c `"CREATE DATABASE healthcare_db;`"" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Start backend server:" -ForegroundColor White
Write-Host "     cd backend" -ForegroundColor Gray
Write-Host "     python -m uvicorn app.main:app --reload" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Open API docs:" -ForegroundColor White
Write-Host "     http://127.0.0.1:8000/docs" -ForegroundColor Gray
Write-Host ""

Write-Host "For help, see:" -ForegroundColor Yellow
Write-Host "  - INSTALLATION_GUIDE.md" -ForegroundColor White
Write-Host "  - backend/QUICK_START.md" -ForegroundColor White
Write-Host ""

# Check if PostgreSQL is running
if (Test-Command psql) {
    try {
        $pgStatus = Get-Service postgresql* -ErrorAction SilentlyContinue
        if ($pgStatus.Status -eq "Running") {
            Write-Host "✓ PostgreSQL is running" -ForegroundColor Green
        } else {
            Write-Host "⚠ PostgreSQL is not running" -ForegroundColor Yellow
            Write-Host "  Start it with: Start-Service postgresql-x64-15" -ForegroundColor Gray
        }
    } catch {
        Write-Host "⚠ Could not check PostgreSQL status" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎉 Happy Coding!" -ForegroundColor Cyan
Write-Host ""
