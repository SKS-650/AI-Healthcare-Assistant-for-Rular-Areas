# Mobile Network Configuration Check Script
# Run this script to verify your setup before running the mobile app

Write-Host "=== Mobile App Network Configuration Check ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check backend is running
Write-Host "1. Checking if backend is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/health" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✓ Backend is running on localhost:8000" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend is NOT running or not accessible" -ForegroundColor Red
    Write-Host "   → Start backend with: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload" -ForegroundColor Yellow
}
Write-Host ""

# 2. Get computer's IP address
Write-Host "2. Finding your computer's IP address..." -ForegroundColor Yellow
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" }

if ($ipAddresses) {
    Write-Host "   Available IP addresses:" -ForegroundColor Green
    foreach ($ip in $ipAddresses) {
        Write-Host "   - $($ip.IPAddress) (Interface: $($ip.InterfaceAlias))" -ForegroundColor Cyan
        
        # Highlight WiFi adapter
        if ($ip.InterfaceAlias -like "*Wi-Fi*" -or $ip.InterfaceAlias -like "*Wireless*") {
            Write-Host "     ^ This is likely your WiFi adapter" -ForegroundColor Green
            $wifiIp = $ip.IPAddress
        }
    }
} else {
    Write-Host "   ✗ No network interfaces found" -ForegroundColor Red
}
Write-Host ""

# 3. Check api_config.dart
Write-Host "3. Checking mobile app configuration..." -ForegroundColor Yellow
$configPath = "lib\config\api_config.dart"
if (Test-Path $configPath) {
    $configContent = Get-Content $configPath -Raw
    if ($configContent -match "static const _devLanIp = '([^']+)'") {
        $configuredIp = $matches[1]
        Write-Host "   Current configured IP: $configuredIp" -ForegroundColor Cyan
        
        if ($wifiIp -and $configuredIp -eq $wifiIp) {
            Write-Host "   ✓ IP matches your WiFi adapter" -ForegroundColor Green
        } elseif ($wifiIp) {
            Write-Host "   ✗ IP doesn't match. Should be: $wifiIp" -ForegroundColor Red
            Write-Host "   → Update _devLanIp in $configPath" -ForegroundColor Yellow
        }
    }
    
    # Check useEmulator setting
    if ($configContent -match "static const _useEmulator = (true|false)") {
        $useEmulator = $matches[1]
        Write-Host "   Emulator mode: $useEmulator" -ForegroundColor Cyan
        if ($useEmulator -eq "true") {
            Write-Host "   ℹ  Using emulator configuration (10.0.2.2)" -ForegroundColor Blue
        } else {
            Write-Host "   ℹ  Using physical device configuration" -ForegroundColor Blue
        }
    }
} else {
    Write-Host "   ✗ Config file not found at $configPath" -ForegroundColor Red
}
Write-Host ""

# 4. Check firewall
Write-Host "4. Checking Windows Firewall..." -ForegroundColor Yellow
$firewallRules = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*8000*" -or $_.DisplayName -like "*Python*" -or $_.DisplayName -like "*FastAPI*" }
if ($firewallRules) {
    Write-Host "   ✓ Found firewall rules for port 8000 or Python" -ForegroundColor Green
} else {
    Write-Host "   ⚠  No firewall rules found for port 8000" -ForegroundColor Yellow
    Write-Host "   → You may need to add a firewall rule or temporarily disable firewall" -ForegroundColor Yellow
    Write-Host "   → Run this as Admin to add rule:" -ForegroundColor Cyan
    Write-Host '     netsh advfirewall firewall add rule name="FastAPI Dev" dir=in action=allow protocol=TCP localport=8000' -ForegroundColor Gray
}
Write-Host ""

# 5. Test backend from LAN IP
if ($wifiIp) {
    Write-Host "5. Testing backend accessibility from LAN IP..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://$($wifiIp):8000/api/v1/health" -TimeoutSec 5 -UseBasicParsing
        Write-Host "   ✓ Backend is accessible at http://$($wifiIp):8000" -ForegroundColor Green
        Write-Host "   → Mobile devices can connect to this URL" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ Backend is NOT accessible from $wifiIp" -ForegroundColor Red
        Write-Host "   → Check if backend is running with --host 0.0.0.0" -ForegroundColor Yellow
        Write-Host "   → Check firewall settings" -ForegroundColor Yellow
    }
}
Write-Host ""

# Summary
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To test on your mobile device:" -ForegroundColor White
Write-Host "1. Connect your mobile to the SAME WiFi network" -ForegroundColor White
Write-Host "2. Open mobile browser and go to: http://$($wifiIp):8000/docs" -ForegroundColor Cyan
Write-Host "3. If you see the API docs, the network is working" -ForegroundColor White
Write-Host "4. Run the mobile app with: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "If still having issues, see: MOBILE_TROUBLESHOOTING.md" -ForegroundColor Yellow
Write-Host ""
