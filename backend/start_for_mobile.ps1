# Start Backend Server for Mobile Development
# This script starts the backend with the correct configuration for mobile access

Write-Host "=== Starting Backend for Mobile Development ===" -ForegroundColor Cyan
Write-Host ""

# Get WiFi IP
$wifiIp = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { 
        ($_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Wireless*") -and 
        $_.IPAddress -notlike "169.254.*" 
    } | 
    Select-Object -First 1 -ExpandProperty IPAddress

if ($wifiIp) {
    Write-Host "Your WiFi IP address: $wifiIp" -ForegroundColor Green
    Write-Host "Mobile devices can connect to: http://$($wifiIp):8000" -ForegroundColor Cyan
} else {
    Write-Host "Warning: Could not detect WiFi IP address" -ForegroundColor Yellow
    Write-Host "Finding all available IPs..." -ForegroundColor Yellow
    $allIps = Get-NetIPAddress -AddressFamily IPv4 | 
        Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" }
    foreach ($ip in $allIps) {
        Write-Host "  $($ip.IPAddress) - $($ip.InterfaceAlias)" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "Important: " -ForegroundColor Yellow -NoNewline
Write-Host "Make sure your mobile device is on the SAME WiFi network!" -ForegroundColor White
Write-Host ""
Write-Host "Starting FastAPI server..." -ForegroundColor Green
Write-Host "Server will be accessible on all network interfaces (0.0.0.0)" -ForegroundColor Gray
Write-Host ""

# Check if virtual environment exists
if (Test-Path ".venv\Scripts\Activate.ps1") {
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    & .venv\Scripts\Activate.ps1
} elseif (Test-Path "..\.venv\Scripts\Activate.ps1") {
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    & ..\.venv\Scripts\Activate.ps1
} else {
    Write-Host "Warning: Virtual environment not found" -ForegroundColor Yellow
}

# Start the server
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Start with hot reload enabled
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
