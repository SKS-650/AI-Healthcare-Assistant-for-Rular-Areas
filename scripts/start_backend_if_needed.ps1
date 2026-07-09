param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [int]$Port = 8000,
    [int]$TimeoutSeconds = 60
)

$ErrorActionPreference = "Stop"

$backendDir = Join-Path $ProjectRoot "backend"
$healthUrl = "http://127.0.0.1:$Port/health"

function Test-BackendReady {
    try {
        $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 2
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

if (Test-BackendReady) {
    Write-Host "Backend already running on $healthUrl"
    exit 0
}

$pythonCmd = "python"
$venvPython = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
$legacyVenvPython = Join-Path $ProjectRoot "venv\Scripts\python.exe"

if (Test-Path $venvPython) {
    $pythonCmd = $venvPython
} elseif (Test-Path $legacyVenvPython) {
    $pythonCmd = $legacyVenvPython
}

Write-Host "Starting backend server on http://127.0.0.1:$Port..."
$backendCommand = "cd /d `"$backendDir`" && `"$pythonCmd`" -m uvicorn app.main:app --reload --host 0.0.0.0 --port $Port"
Start-Process -FilePath "cmd.exe" -ArgumentList "/k", $backendCommand -WindowStyle Minimized -WorkingDirectory $backendDir

Write-Host "Waiting for backend to become ready..."
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
while ((Get-Date) -lt $deadline) {
    if (Test-BackendReady) {
        Write-Host "Backend is ready."
        exit 0
    }
    Start-Sleep -Seconds 1
}

Write-Error "Backend did not become ready. Check the 'AI Healthcare Backend' command window for errors."
exit 1
