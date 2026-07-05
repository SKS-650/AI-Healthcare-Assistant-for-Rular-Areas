# Complete Backend Testing Guide - AI Healthcare Assistant

This comprehensive guide provides step-by-step instructions for fixing, running, and testing the FastAPI backend application.

---

## ✅ ISSUE FIXED: ModuleNotFoundError

**Problem**: `ModuleNotFoundError: No module named 'backend'`

**Solution Applied**: All imports in the `app/` directory have been changed from:
```python
from backend.app.auth import controller  # ❌ Wrong
```
to:
```python
from app.auth import controller  # ✅ Correct
```

This fix has been applied to all Python files in the backend/app directory.

---

## Prerequisites Checklist

| Requirement | Check Command | Expected |
|-------------|---------------|----------|
| Python 3.11+ | `python --version` | Python 3.11.x |
| PostgreSQL | `Get-Service postgresql*` | Running |
| pip | `pip --version` | Latest version |
| Git | `git --version` | Any version |

---

## Step-by-Step Setup

### Step 1: Navigate to Backend Directory

```powershell
cd d:\MinorProject\ai_healthcare_assistant\backend
```

### Step 2: Create Virtual Environment (First Time Only)

```powershell
python -m venv venv
```

### Step 3: Activate Virtual Environment

```powershell
.\venv\Scripts\activate
```

You should see `(venv)` appear in your terminal prompt:
```
(venv) PS D:\MinorProject\ai_healthcare_assistant\backend>
```

### Step 4: Install Dependencies

```powershell
pip install -r requirements.txt
```

**Expected output**: All packages install successfully without errors.

### Step 5: Configure Environment Variables

1. **Check if `.env` exists**:
   ```powershell
   Test-Path .env
   ```

2. **If False, copy from example**:
   ```powershell
   Copy-Item .env.example .env
   ```

3. **Edit `.env` file** with your PostgreSQL credentials:
   ```env
   ENVIRONMENT=development
   DEBUG=true
   DATABASE_URL=postgresql+asyncpg://postgres:YOUR_PASSWORD@localhost:5432/healthcare_db
   JWT_SECRET_KEY=5d878d3ac108534013cc5cc52b51d60a1919f57ec130f39150c9701ad684ca7c
   EMAIL_VERIFICATION_REQUIRED=false
   ```

   Replace `YOUR_PASSWORD` with your actual PostgreSQL password.

### Step 6: Create Database

```powershell
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE healthcare_db;

# Exit
\q
```

**Alternative**: One-line command:
```powershell
psql -U postgres -c "CREATE DATABASE healthcare_db;"
```

### Step 7: Run Database Migrations (Optional)

If you have migrations:
```powershell
alembic upgrade head
```

**Note**: In development mode, tables are created automatically on first run, so this step may not be necessary.

### Step 8: Start the Backend Server

```powershell
python -m uvicorn app.main:app --reload
```

**Expected Output**:
```
INFO:     Will watch for changes in these directories: ['D:\\MinorProject\\ai_healthcare_assistant\\backend']
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [XXXXX] using WatchFiles
INFO:     Started server process [XXXXX]
INFO:     Waiting for application startup.
INFO:     Database connection verified.
INFO:     Database tables created/verified (dev auto-create).
INFO:     Application startup complete.
```

**✅ If you see this, your server is running successfully!**

---

## Testing Methods

### Method 1: Quick Health Check

Open a new PowerShell terminal and run:

```powershell
Invoke-RestMethod http://localhost:8000/health
```

**Expected Response**:
```json
{
  "status": "ok",
  "version": "1.0.0"
}
```

### Method 2: Swagger UI (Recommended for Beginners)

1. Open your web browser
2. Navigate to: **http://127.0.0.1:8000/docs**
3. You'll see an interactive API documentation page

**Testing Registration**:
1. Find `POST /api/v1/auth/register`
2. Click to expand
3. Click "Try it out"
4. Enter:
   ```json
   {
     "full_name": "Test User",
     "email": "test@example.com",
     "password": "SecurePass@123",
     "confirm_password": "SecurePass@123",
     "role": "patient",
     "language": "en"
   }
   ```
5. Click "Execute"
6. Check response - should be `201 Created`

**Testing Login**:
1. Find `POST /api/v1/auth/login`
2. Click "Try it out"
3. Enter:
   ```json
   {
     "email": "test@example.com",
     "password": "SecurePass@123"
   }
   ```
4. Click "Execute"
5. Copy the `access_token` from response

**Testing Protected Endpoint**:
1. Click "Authorize" button (🔒 at top right)
2. Enter: `Bearer YOUR_ACCESS_TOKEN` (replace with actual token)
3. Click "Authorize"
4. Find `GET /api/v1/auth/me`
5. Click "Try it out" → "Execute"
6. Should return your user profile

### Method 3: PowerShell Script Testing

Save this as `test_api.ps1`:

```powershell
$BASE = "http://localhost:8000"

Write-Host "Testing Health Check..." -ForegroundColor Yellow
$health = Invoke-RestMethod "$BASE/health"
Write-Host "Status: $($health.status)" -ForegroundColor Green

Write-Host "`nRegistering User..." -ForegroundColor Yellow
try {
    $reg = Invoke-RestMethod -Method POST "$BASE/api/v1/auth/register" `
        -ContentType "application/json" `
        -Body '{"full_name":"Test User","email":"test@example.com","password":"SecurePass@123","confirm_password":"SecurePass@123","role":"patient","language":"en"}'
    Write-Host "User ID: $($reg.user_id)" -ForegroundColor Green
} catch {
    Write-Host "Registration Error (may already exist): $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`nLogging In..." -ForegroundColor Yellow
$login = Invoke-RestMethod -Method POST "$BASE/api/v1/auth/login" `
    -ContentType "application/json" `
    -Body '{"email":"test@example.com","password":"SecurePass@123"}'
$TOKEN = $login.tokens.access_token
Write-Host "Access Token: $($TOKEN.Substring(0,20))..." -ForegroundColor Green

Write-Host "`nGetting User Profile..." -ForegroundColor Yellow
$profile = Invoke-RestMethod "$BASE/api/v1/auth/me" `
    -Headers @{ Authorization = "Bearer $TOKEN" }
Write-Host "Full Name: $($profile.full_name)" -ForegroundColor Green
Write-Host "Email: $($profile.email)" -ForegroundColor Green

Write-Host "`nAll Tests Passed! ✓" -ForegroundColor Green
```

Run it:
```powershell
.\test_api.ps1
```

### Method 4: Using curl

**Register**:
```powershell
curl -X POST "http://localhost:8000/api/v1/auth/register" `
  -H "Content-Type: application/json" `
  -d '{\"full_name\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"SecurePass@123\",\"confirm_password\":\"SecurePass@123\",\"role\":\"patient\",\"language\":\"en\"}'
```

**Login**:
```powershell
curl -X POST "http://localhost:8000/api/v1/auth/login" `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\",\"password\":\"SecurePass@123\"}'
```

### Method 5: Python Requests Library

Create `test_backend.py`:

```python
import requests
import json

BASE_URL = "http://localhost:8000"

# Health check
print("Testing health check...")
r = requests.get(f"{BASE_URL}/health")
print(f"Status: {r.json()['status']}")

# Register
print("\nRegistering user...")
data = {
    "full_name": "Test User",
    "email": "test@example.com",
    "password": "SecurePass@123",
    "confirm_password": "SecurePass@123",
    "role": "patient",
    "language": "en"
}
try:
    r = requests.post(f"{BASE_URL}/api/v1/auth/register", json=data)
    print(f"User ID: {r.json()['user_id']}")
except:
    print("User may already exist")

# Login
print("\nLogging in...")
data = {
    "email": "test@example.com",
    "password": "SecurePass@123"
}
r = requests.post(f"{BASE_URL}/api/v1/auth/login", json=data)
token = r.json()["tokens"]["access_token"]
print(f"Token: {token[:20]}...")

# Get profile
print("\nGetting profile...")
headers = {"Authorization": f"Bearer {token}"}
r = requests.get(f"{BASE_URL}/api/v1/auth/me", headers=headers)
profile = r.json()
print(f"Name: {profile['full_name']}")
print(f"Email: {profile['email']}")

print("\n✓ All tests passed!")
```

Run it:
```powershell
python test_backend.py
```

---

## Running Automated Tests

### Basic Test Run

```powershell
pytest
```

### Run with Verbose Output

```powershell
pytest -v
```

### Run Specific Test File

```powershell
pytest tests/api/test_auth.py
```

### Run Specific Test

```powershell
pytest tests/api/test_auth.py::test_register_success -v
```

### Run with Coverage Report

```powershell
pytest --cov=app --cov-report=html
```

View the report:
```powershell
start htmlcov/index.html
```

---

## Complete Testing Workflow

### 1. Authentication Flow

**A. Register → Login → Get Profile**

```powershell
# Step 1: Register
$reg = Invoke-RestMethod -Method POST "http://localhost:8000/api/v1/auth/register" `
    -ContentType "application/json" `
    -Body '{"full_name":"John Doe","email":"john@example.com","password":"SecurePass@123","confirm_password":"SecurePass@123","role":"patient","language":"en"}'

# Step 2: Login
$login = Invoke-RestMethod -Method POST "http://localhost:8000/api/v1/auth/login" `
    -ContentType "application/json" `
    -Body '{"email":"john@example.com","password":"SecurePass@123"}'

$TOKEN = $login.tokens.access_token
$HEADERS = @{ Authorization = "Bearer $TOKEN" }

# Step 3: Get Profile
$profile = Invoke-RestMethod "http://localhost:8000/api/v1/auth/me" -Headers $HEADERS
Write-Host "Profile: $($profile | ConvertTo-Json)"
```

**B. Password Reset Flow**

```powershell
# Step 1: Request OTP
Invoke-RestMethod -Method POST "http://localhost:8000/api/v1/auth/forgot-password-otp" `
    -ContentType "application/json" `
    -Body '{"email":"john@example.com"}'

# Check server logs for OTP (look for: "Password reset OTP for john@example.com: 123456")

# Step 2: Verify OTP
$reset = Invoke-RestMethod -Method POST "http://localhost:8000/api/v1/auth/verify-reset-otp" `
    -ContentType "application/json" `
    -Body '{"email":"john@example.com","otp":"123456"}'

$RESET_TOKEN = $reset.reset_token

# Step 3: Reset Password
Invoke-RestMethod -Method POST "http://localhost:8000/api/v1/auth/reset-password" `
    -ContentType "application/json" `
    -Body "{`"reset_token`":`"$RESET_TOKEN`",`"new_password`":`"NewPass@456`",`"confirm_password`":`"NewPass@456`"}"
```

### 2. User Profile Management

```powershell
# Assume you have $TOKEN and $HEADERS from login

# Create Profile
Invoke-RestMethod -Method POST "http://localhost:8000/api/v1/users/profile" `
    -Headers $HEADERS `
    -ContentType "application/json" `
    -Body '{"date_of_birth":"2000-06-15","gender":"male","blood_group":"B+","height_cm":170,"weight_kg":65,"occupation":"Student","marital_status":"single"}'

# Get Profile
$profile = Invoke-RestMethod "http://localhost:8000/api/v1/users/profile" -Headers $HEADERS
Write-Host $($profile | ConvertTo-Json)

# Update Profile
Invoke-RestMethod -Method PUT "http://localhost:8000/api/v1/users/profile" `
    -Headers $HEADERS `
    -ContentType "application/json" `
    -Body '{"weight_kg":68,"bio":"Healthcare app tester"}'
```

### 3. Address Management

```powershell
# Add Address
$addr = Invoke-RestMethod -Method POST "http://localhost:8000/api/v1/users/address" `
    -Headers $HEADERS `
    -ContentType "application/json" `
    -Body '{"address_type":"home","country":"Nepal","state":"Bagmati","district":"Kathmandu","municipality":"KMC","ward_number":"10","street":"Thamel Marg","postal_code":"44600","is_primary":true}'

$ADDR_ID = $addr.address_id

# Get All Addresses
$addresses = Invoke-RestMethod "http://localhost:8000/api/v1/users/address" -Headers $HEADERS
Write-Host "Total Addresses: $($addresses.total)"

# Update Address
Invoke-RestMethod -Method PUT "http://localhost:8000/api/v1/users/address/$ADDR_ID" `
    -Headers $HEADERS `
    -ContentType "application/json" `
    -Body '{"street":"Updated Street Name"}'

# Delete Address
Invoke-RestMethod -Method DELETE "http://localhost:8000/api/v1/users/address/$ADDR_ID" -Headers $HEADERS
```

---

## Troubleshooting

### Issue 1: Server Won't Start - Import Errors

**Error**: `ModuleNotFoundError: No module named 'backend'`

**Solution**: ✅ Already fixed! But if you see it again:
```powershell
# Make sure you're in the backend directory
cd d:\MinorProject\ai_healthcare_assistant\backend

# Run from here
python -m uvicorn app.main:app --reload
```

### Issue 2: Database Connection Failed

**Error**: `sqlalchemy.exc.OperationalError: could not connect to server`

**Solutions**:
1. Check PostgreSQL is running:
   ```powershell
   Get-Service postgresql*
   ```
   
2. If not running, start it:
   ```powershell
   Start-Service postgresql-x64-15  # Adjust version number
   ```

3. Verify credentials in `.env`:
   ```powershell
   # Test connection
   psql -U postgres -d healthcare_db
   ```

### Issue 3: Port Already in Use

**Error**: `[Errno 10048] error while attempting to bind on address ('127.0.0.1', 8000)`

**Solution**: Use a different port:
```powershell
python -m uvicorn app.main:app --reload --port 8001
```

### Issue 4: Database Does Not Exist

**Error**: `database "healthcare_db" does not exist`

**Solution**: Create the database:
```powershell
psql -U postgres -c "CREATE DATABASE healthcare_db;"
```

### Issue 5: Permission Denied (PostgreSQL)

**Error**: `FATAL: password authentication failed for user "postgres"`

**Solutions**:
1. Reset PostgreSQL password
2. Update `.env` with correct password
3. Or use trust authentication temporarily (not recommended for production)

---

## API Endpoints Reference

### Authentication (`/api/v1/auth`)
- `POST /register` - Register new user
- `POST /login` - Login with credentials
- `POST /verify-email` - Verify email address
- `POST /refresh` - Refresh access token
- `GET /me` - Get current user profile
- `POST /logout` - Logout current session
- `POST /logout-all` - Logout all sessions
- `POST /forgot-password-otp` - Request password reset OTP
- `POST /verify-reset-otp` - Verify password reset OTP
- `POST /reset-password` - Reset password with token

### Users (`/api/v1/users`)
- `GET /me` - Get user account details
- `PUT /me` - Update user account
- `GET /profile` - Get user profile
- `POST /profile` - Create user profile
- `PUT /profile` - Update user profile
- `GET /address` - List addresses
- `POST /address` - Add address
- `PUT /address/{id}` - Update address
- `DELETE /address/{id}` - Delete address
- `GET /emergency-contact` - List emergency contacts
- `POST /emergency-contact` - Add emergency contact
- `PUT /emergency-contact/{id}` - Update emergency contact
- `DELETE /emergency-contact/{id}` - Delete emergency contact
- `GET /medical-info` - Get medical information
- `POST /medical-info` - Create medical information
- `PUT /medical-info` - Update medical information

### Health Check
- `GET /health` - Server health status

---

## Password Requirements

Passwords must contain:
- Minimum 8 characters
- At least one uppercase letter (A-Z)
- At least one lowercase letter (a-z)
- At least one digit (0-9)
- At least one special character: `!@#$%^&*(),.?":{}|<>_-`

**Valid Examples**:
- `SecurePass@123`
- `Hello@World1`
- `Test#Pass9`
- `MyP@ssw0rd`

**Invalid Examples**:
- `password` (no uppercase, no digit, no special char)
- `Password123` (no special char)
- `Pass@1` (too short)

---

## Next Steps After Testing

1. ✅ Backend server running successfully
2. ✅ Can register and login users
3. ✅ Can create and manage profiles
4. ⬜ Test with mobile app
5. ⬜ Test AI model integration
6. ⬜ Deploy to production

---

## Useful Commands Summary

```powershell
# Start server
python -m uvicorn app.main:app --reload

# Start server on all interfaces (for mobile testing)
python -m uvicorn app.main:app --reload --host 0.0.0.0

# Run tests
pytest

# Run tests with coverage
pytest --cov=app --cov-report=html

# Check database
psql -U postgres -d healthcare_db

# List tables
psql -U postgres -d healthcare_db -c "\dt"

# Create migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback migration
alembic downgrade -1

# Check Python version
python --version

# Check installed packages
pip list

# Update requirements
pip freeze > requirements.txt
```

---

## Support & Documentation

- **FastAPI Docs**: https://fastapi.tiangolo.com/
- **SQLAlchemy Docs**: https://docs.sqlalchemy.org/
- **Pydantic Docs**: https://docs.pydantic.dev/
- **Alembic Docs**: https://alembic.sqlalchemy.org/

---

## Success Checklist

- [x] Import errors fixed (`from backend.app` → `from app`)
- [ ] Virtual environment activated
- [ ] Dependencies installed
- [ ] `.env` configured
- [ ] Database created
- [ ] Server starts without errors
- [ ] Can access http://127.0.0.1:8000/docs
- [ ] Can register a user
- [ ] Can login successfully
- [ ] Can access protected endpoints
- [ ] Tests pass

---

**🎉 Your backend is now ready for testing and development!**
