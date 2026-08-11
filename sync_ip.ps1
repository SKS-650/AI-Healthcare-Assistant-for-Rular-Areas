# ═══════════════════════════════════════════════════════════════════════════
# sync_ip.ps1 — Sync IP address from network.env to all project .env files
# ═══════════════════════════════════════════════════════════════════════════
# Usage: .\sync_ip.ps1
# ═══════════════════════════════════════════════════════════════════════════

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

# ── 1. Read network.env ───────────────────────────────────────────────────────
$networkEnvPath = Join-Path $root "network.env"
if (-not (Test-Path $networkEnvPath)) {
    Write-Error "network.env not found at $networkEnvPath"
    exit 1
}

$config = @{}
Get-Content $networkEnvPath | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $config[$Matches[1].Trim()] = $Matches[2].Trim()
    }
}

$ip   = $config["HOST_IP"]
$port = $config["BACKEND_PORT"]

if (-not $ip) {
    Write-Error "HOST_IP is not set in network.env"
    exit 1
}

$backendUrl = "http://${ip}:${port}"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  IP Sync — AI Healthcare Assistant" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Host IP    : $ip" -ForegroundColor Yellow
Write-Host "  Backend URL: $backendUrl" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# ── Helper: update or add a key=value line in a file ─────────────────────────
function Set-EnvValue {
    param(
        [string]$FilePath,
        [string]$Key,
        [string]$Value
    )
    $content = Get-Content $FilePath -Raw
    $pattern = "(?m)^($Key\s*=).*$"
    if ($content -match $pattern) {
        $content = $content -replace $pattern, "`${1}$Value"
    } else {
        # Key not found — append it
        $content = $content.TrimEnd() + "`n$Key=$Value`n"
    }
    Set-Content $FilePath $content -NoNewline
}

# ── 2. Update mobile_app/.env ─────────────────────────────────────────────────
$mobileEnv = Join-Path $root "mobile_app\.env"
if (Test-Path $mobileEnv) {
    Set-EnvValue -FilePath $mobileEnv -Key "BACKEND_URL" -Value $backendUrl
    Set-EnvValue -FilePath $mobileEnv -Key "BACKEND_PORT" -Value $port
    Write-Host "  [OK] mobile_app/.env" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] mobile_app/.env not found" -ForegroundColor DarkYellow
}

# ── 3. Update admin_dashboard/.env ───────────────────────────────────────────
$adminEnv = Join-Path $root "admin_dashboard\.env"
if (Test-Path $adminEnv) {
    Set-EnvValue -FilePath $adminEnv -Key "BACKEND_URL" -Value $backendUrl
    Set-EnvValue -FilePath $adminEnv -Key "BACKEND_PORT" -Value $port
    Write-Host "  [OK] admin_dashboard/.env" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] admin_dashboard/.env not found" -ForegroundColor DarkYellow
}

# ── 4. Update backend/.env ───────────────────────────────────────────────────
$backendEnv = Join-Path $root "backend\.env"
if (Test-Path $backendEnv) {
    Set-EnvValue -FilePath $backendEnv -Key "APP_BASE_URL" -Value $backendUrl

    # Rebuild CORS_ORIGINS — keep static origins, replace the dynamic IP entry
    $content = Get-Content $backendEnv -Raw
    $corsPattern = "(?m)^(CORS_ORIGINS\s*=).*$"
    if ($content -match $corsPattern) {
        # Extract existing CORS line
        $existingCors = ($content | Select-String -Pattern "(?m)^CORS_ORIGINS\s*=(.*)$").Matches[0].Groups[1].Value.Trim()
        
        # Split into individual origins and remove any previous dynamic IP entries (http://192.x.x.x or http://10.x.x.x that aren't standard)
        $staticOrigins = $existingCors -split ',' | Where-Object {
            $o = $_.Trim()
            # Keep localhost, 127.x, 10.0.2.2 (emulator) — remove other 192.x / 10.x dynamic IPs
            $o -match '^http://(localhost|127\.|10\.0\.2\.2)' 
        }
        
        # Add new dynamic IP
        $allOrigins = ($staticOrigins + $backendUrl) -join ','
        $content = $content -replace $corsPattern, "`${1}$allOrigins"
        Set-Content $backendEnv $content -NoNewline
    }

    Write-Host "  [OK] backend/.env" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] backend/.env not found" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "  Done! Hot restart your Flutter apps to apply changes." -ForegroundColor Cyan
Write-Host ""
