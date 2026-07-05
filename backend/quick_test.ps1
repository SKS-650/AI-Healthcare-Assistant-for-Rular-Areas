# Quick Test Script for Backend API
# This script tests the basic functionality of the backend

$BASE = "http://localhost:8000"
$ErrorActionPreference = "Stop"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "AI Healthcare Backend - Quick Test" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "[1/5] Testing Health Check..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod "$BASE/health"
    if ($health.status -eq "ok") {
        Write-Host "✓ Health Check PASSED - Status: $($health.status)" -ForegroundColor Green
    } else {
        Write-Host "✗ Health Check FAILED" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Health Check FAILED - Server may not be running" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start the server first:" -ForegroundColor Yellow
    Write-Host "  cd d:\MinorProject\ai_healthcare_assistant\backend" -ForegroundColor White
    Write-Host "  python -m uvicorn app.main:app --reload" -ForegroundColor White
    exit 1
}

# Test 2: Registration
Write-Host ""
Write-Host "[2/5] Testing User Registration..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testEmail = "test$timestamp@example.com"
$testPassword = "SecurePass@123"

try {
    $regBody = @{
        full_name = "Test User $timestamp"
        email = $testEmail
        password = $testPassword
        confirm_password = $testPassword
        role = "patient"
        language = "en"
    } | ConvertTo-Json

    $reg = Invoke-RestMethod -Method POST "$BASE/api/v1/auth/register" `
        -ContentType "application/json" `
        -Body $regBody

    Write-Host "✓ Registration PASSED - User ID: $($reg.user_id)" -ForegroundColor Green
    $userId = $reg.user_id
} catch {
    Write-Host "✗ Registration FAILED" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Login
Write-Host ""
Write-Host "[3/5] Testing Login..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    $login = Invoke-RestMethod -Method POST "$BASE/api/v1/auth/login" `
        -ContentType "application/json" `
        -Body $loginBody

    $TOKEN = $login.tokens.access_token
    $HEADERS = @{ Authorization = "Bearer $TOKEN" }
    
    Write-Host "✓ Login PASSED - Access Token: $($TOKEN.Substring(0,20))..." -ForegroundColor Green
} catch {
    Write-Host "✗ Login FAILED" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 4: Get User Profile
Write-Host ""
Write-Host "[4/5] Testing Get Profile (Protected Route)..." -ForegroundColor Yellow
try {
    $profile = Invoke-RestMethod "$BASE/api/v1/auth/me" -Headers $HEADERS
    
    if ($profile.email -eq $testEmail) {
        Write-Host "✓ Get Profile PASSED" -ForegroundColor Green
        Write-Host "  - Name: $($profile.full_name)" -ForegroundColor Gray
        Write-Host "  - Email: $($profile.email)" -ForegroundColor Gray
        Write-Host "  - Role: $($profile.role)" -ForegroundColor Gray
    } else {
        Write-Host "✗ Get Profile FAILED - Email mismatch" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Get Profile FAILED" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 5: Create User Profile
Write-Host ""
Write-Host "[5/5] Testing Create User Profile..." -ForegroundColor Yellow
try {
    $profileBody = @{
        date_of_birth = "2000-06-15"
        gender = "male"
        blood_group = "B+"
        height_cm = 170
        weight_kg = 65
        occupation = "Student"
        marital_status = "single"
    } | ConvertTo-Json

    $profileCreate = Invoke-RestMethod -Method POST "$BASE/api/v1/users/profile" `
        -Headers $HEADERS `
        -ContentType "application/json" `
        -Body $profileBody

    Write-Host "✓ Create Profile PASSED" -ForegroundColor Green
    Write-Host "  - Blood Group: $($profileCreate.blood_group)" -ForegroundColor Gray
    Write-Host "  - Gender: $($profileCreate.gender)" -ForegroundColor Gray
} catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "✓ Profile already exists (expected for reruns)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Create Profile FAILED" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Summary
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "✓ ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your backend is working correctly!" -ForegroundColor Green
Write-Host ""
Write-Host "Test User Created:" -ForegroundColor Yellow
Write-Host "  Email: $testEmail" -ForegroundColor White
Write-Host "  Password: $testPassword" -ForegroundColor White
Write-Host "  User ID: $userId" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Open Swagger UI: http://localhost:8000/docs" -ForegroundColor White
Write-Host "  2. Test with mobile app" -ForegroundColor White
Write-Host "  3. Run automated tests: pytest" -ForegroundColor White
Write-Host ""
