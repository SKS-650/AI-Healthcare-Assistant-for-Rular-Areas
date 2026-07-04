# Testing Guide — Module 1 (Auth) + Module 2 (User Management)

Everything here works against the real FastAPI backend called from the Flutter mobile app.

---

## Prerequisites

| Requirement | Check |
|---|---|
| Python 3.11+ | `python --version` |
| PostgreSQL running | `Get-Service postgresql*` (Windows) |
| pip packages installed | `pip install -r backend/requirements.txt` |
| Flutter SDK | `flutter --version` |
| Physical device / emulator connected | `flutter devices` |

---

## STEP 1 — Configure the LAN IP

Open `mobile_app/lib/config/api_config.dart` and make sure `_devLanIp` matches your machine's IP:

```dart
static const _devLanIp = '192.168.18.26';   // ← your machine's LAN IP
```

Find your IP:
```powershell
ipconfig | Select-String "IPv4"
```

The device and your PC must be on the **same Wi-Fi network**.

---

## STEP 2 — Configure the Backend .env

File: `backend/.env`

```env
ENVIRONMENT=development
DEBUG=true
DATABASE_URL=postgresql+asyncpg://postgres:YOUR_PASSWORD@localhost:5432/healthcare_db
JWT_SECRET_KEY=5d878d3ac108534013cc5cc52b51d60a1919f57ec130f39150c9701ad684ca7c
```

- Replace `YOUR_PASSWORD` with your PostgreSQL password.
- Make sure `healthcare_db` database exists:

```powershell
psql -U postgres -c "CREATE DATABASE healthcare_db;"
```

---

## STEP 3 — Start the Backend Server

Run from the **project root** (`ai_healthcare_assistant/`):

```powershell
python -m uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
```

Expected output:
```
INFO: Database connection verified.
INFO: Database tables created/verified (dev auto-create).
INFO: Startup complete.
INFO: Uvicorn running on http://0.0.0.0:8000
```

> Tables are created automatically in development mode — no need to run alembic migrations manually.

Verify the server is up:
```powershell
Invoke-RestMethod http://localhost:8000/health
```
Expected: `{ status: ok, version: 1.0.0 }`

---

## STEP 4 — Run the Flutter App

```powershell
flutter run
```

Run from `mobile_app/` folder, or specify the device:

```powershell
flutter run -d <device-id>
```

To pass a custom backend URL (optional):
```powershell
flutter run --dart-define=BACKEND_URL=http://192.168.18.26:8000
```

---

## MODULE 1: AUTHENTICATION

---

### Test 1.1 — Register

On the app: tap **Sign Up**, fill:
- Full Name: `Shyam Kishor`
- Email: `shyam@example.com`
- Password: `SecurePass@123`  ← must have uppercase + lowercase + digit + special char
- Confirm Password: `SecurePass@123`
- Check terms checkbox
- Tap **Create Account**

**Expected:** Navigates to Profile Completion screen.

**Password rules (backend enforces):**
- Min 8 chars
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character: `!@#$%^&*(),.?":{}|<>_-`

> Example passwords that work: `SecurePass@123`, `Hello@World1`, `Test#Pass9`
>
> Example that fails: `shyam123` (no uppercase, no special char)

---

### Test 1.2 — Login

On the app: tap **Sign In**, fill:
- Email: `shyam@example.com`
- Password: `SecurePass@123`
- Tap **Sign In**

**Expected:** Navigates to Home Dashboard (if profile complete) or Profile Completion.

> Since `EMAIL_VERIFICATION_REQUIRED=false` in development (the default), you can log in immediately after registering without verifying your email.

**If login fails with "Email not verified"**, manually verify via SQL:

```powershell
python -c "
import asyncio, sys
sys.path.insert(0, '.')
from dotenv import load_dotenv
load_dotenv('backend/.env', override=True)
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from backend.app.config.settings import Settings
s = Settings()
async def go():
    engine = create_async_engine(s.database_url)
    async with engine.connect() as conn:
        await conn.execute(text('UPDATE users SET email_verified=true WHERE email=:e'), {'e': 'shyam@example.com'})
        await conn.commit()
        print('Email verified OK')
    await engine.dispose()
asyncio.run(go())
"
```

---

### Test 1.3 — Forgot Password (OTP flow)

1. On Login page, tap **Forgot password?**
2. Enter email: `shyam@example.com`
3. Tap **Send OTP**

**Expected:** Navigates to OTP verification screen.

**Get the OTP from backend logs:**
```
INFO  ...  DEV MODE — Password reset OTP for shyam@example.com: 847291 (expires in 10 min)
```

4. Enter the 6-digit OTP shown in the server log
5. Tap **Verify OTP**

**Expected:** Navigates to Reset Password screen.

6. Enter new password + confirm
7. Tap **Reset Password**

**Expected:** Success message, navigates back to Login.

---

### Test 1.4 — Verify via Swagger (optional deep test)

Open **http://localhost:8000/docs** in a browser.

1. `POST /api/v1/auth/register` — register a user
2. `POST /api/v1/auth/login` — copy `access_token` from response
3. Click **Authorize 🔒** (top right) → enter `Bearer <access_token>` → Authorize
4. `GET /api/v1/auth/me` — confirms token works

---

## MODULE 2: USER MANAGEMENT

These are tested after you are logged in via the app or Swagger.

### Via Swagger (recommended for deep testing)

1. Log in via `POST /api/v1/auth/login`, copy `access_token`
2. Authorize in Swagger with the token
3. Run all the tests below

---

### Test 2.1 — Get My Account

```
GET /api/v1/users/me
```
Expected `200`:
```json
{
  "user_id": "...",
  "full_name": "Shyam Kishor",
  "email": "shyam@example.com",
  "role": "patient",
  "preferred_language": "en",
  ...
}
```

---

### Test 2.2 — Update My Account

```
PUT /api/v1/users/me
```
Body:
```json
{
  "full_name": "Shyam Kishor Sah",
  "preferred_language": "hi"
}
```
Expected `200` — updated fields.

---

### Test 2.3 — Create Profile

```
POST /api/v1/users/profile
```
Body:
```json
{
  "date_of_birth": "2000-06-15",
  "gender": "male",
  "blood_group": "B+",
  "height_cm": 170,
  "weight_kg": 65,
  "occupation": "Student",
  "marital_status": "single"
}
```
Expected `201`.

Calling again → `409 Profile already exists. Use PUT to update.`

---

### Test 2.4 — Get My Profile

```
GET /api/v1/users/profile
```
Expected `200`.

---

### Test 2.5 — Update Profile

```
PUT /api/v1/users/profile
```
Body:
```json
{
  "weight_kg": 68,
  "bio": "Healthcare app tester"
}
```
Expected `200`.

---

### Test 2.6 — Add Address

```
POST /api/v1/users/address
```
Body:
```json
{
  "address_type": "home",
  "country": "Nepal",
  "state": "Bagmati",
  "district": "Kathmandu",
  "municipality": "KMC",
  "ward_number": "10",
  "street": "Thamel Marg",
  "postal_code": "44600",
  "is_primary": true
}
```
Expected `201`. Copy the `address_id`.

---

### Test 2.7 — Get Addresses

```
GET /api/v1/users/address
```
Expected `200 { "addresses": [...], "total": 1 }`

---

### Test 2.8 — Update Address

```
PUT /api/v1/users/address/{address_id}
```
Body:
```json
{
  "address_type": "home",
  "district": "Lalitpur",
  "street": "Patan Dhoka"
}
```
Expected `200`.

---

### Test 2.9 — Delete Address

```
DELETE /api/v1/users/address/{address_id}
```
Expected `200 { "message": "Address deleted." }`

---

### Test 2.10 — Add Emergency Contact

```
POST /api/v1/users/emergency-contact
```
Body:
```json
{
  "contact_name": "Ram Sah",
  "relationship": "father",
  "phone": "+919000000001",
  "priority": 1
}
```
Expected `201`. Copy the `contact_id`.

---

### Test 2.11 — Get Emergency Contacts

```
GET /api/v1/users/emergency-contact
```
Expected `200 { "contacts": [...], "total": 1 }`

---

### Test 2.12 — Create Medical Information

```
POST /api/v1/users/medical-info
```
Body:
```json
{
  "blood_group": "B+",
  "allergies": ["Penicillin", "Dust"],
  "chronic_diseases": ["Diabetes Type 2"],
  "disabilities": [],
  "current_medications": ["Metformin 500mg"],
  "smoking_status": false,
  "alcohol_consumption": false,
  "notes": "Test notes"
}
```
Expected `201`.

---

### Test 2.13 — Get Medical Info

```
GET /api/v1/users/medical-info
```
Expected `200`.

---

### Test 2.14 — Get Full User Detail

```
GET /api/v1/users/{user_id}
```
Use the `user_id` from login.

Expected `200`:
```json
{
  "account": { ... },
  "profile": { ... },
  "addresses": [ ... ],
  "emergency_contacts": [ ... ],
  "medical_info": { ... }
}
```

---

## Full End-to-End PowerShell Test (Backend Only)

Run from project root — this registers, logs in, creates all sub-records, and verifies the full detail:

```powershell
# 1. Register
$reg = Invoke-RestMethod -Method POST `
  -Uri "http://localhost:8000/api/v1/auth/register" `
  -Body '{"full_name":"Test User","email":"test@example.com","password":"TestPass@123","confirm_password":"TestPass@123","role":"patient","language":"en"}' `
  -ContentType "application/json"
Write-Host "Registered: $($reg.user_id)"

# 2. Login
$login = Invoke-RestMethod -Method POST `
  -Uri "http://localhost:8000/api/v1/auth/login" `
  -Body '{"email":"test@example.com","password":"TestPass@123"}' `
  -ContentType "application/json"
$TOKEN = $login.tokens.access_token
$UID   = $login.user_id
$H     = @{ Authorization = "Bearer $TOKEN" }
Write-Host "Logged in: $UID"

# 3. Create profile
Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/v1/users/profile" `
  -Body '{"gender":"male","blood_group":"O+","height_cm":170,"weight_kg":65}' `
  -ContentType "application/json" -Headers $H | Out-Null
Write-Host "Profile created"

# 4. Add address
Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/v1/users/address" `
  -Body '{"address_type":"home","country":"Nepal","district":"Kathmandu","is_primary":true}' `
  -ContentType "application/json" -Headers $H | Out-Null
Write-Host "Address added"

# 5. Add emergency contact
Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/v1/users/emergency-contact" `
  -Body '{"contact_name":"Parent","relationship":"father","phone":"+919000000002","priority":1}' `
  -ContentType "application/json" -Headers $H | Out-Null
Write-Host "Emergency contact added"

# 6. Add medical info
Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/v1/users/medical-info" `
  -Body '{"blood_group":"O+","allergies":["Dust"],"smoking_status":false,"alcohol_consumption":false}' `
  -ContentType "application/json" -Headers $H | Out-Null
Write-Host "Medical info added"

# 7. Full user detail
$detail = Invoke-RestMethod -Uri "http://localhost:8000/api/v1/users/$UID" -Headers $H
Write-Host "Full detail: profile=$($detail.profile -ne $null), addresses=$($detail.addresses.Count), contacts=$($detail.emergency_contacts.Count)"

# 8. Forgot password OTP
Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/v1/auth/forgot-password-otp" `
  -Body '{"email":"test@example.com"}' -ContentType "application/json" | Out-Null
Write-Host "OTP requested (check server logs)"

# 9. Logout
Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/v1/auth/logout" `
  -Body "{`"refresh_token`":`"$($login.tokens.refresh_token)`"}" `
  -ContentType "application/json" | Out-Null
Write-Host "Logged out"

Write-Host ""
Write-Host "ALL TESTS PASSED" -ForegroundColor Green
```

---

## Common Errors

| Error on App | Cause | Fix |
|---|---|---|
| `Registration failed. Please try again.` | Password too weak or email already exists | Use password with uppercase + lowercase + digit + special char |
| `Email already registered.` | Email already in DB | Use a different email |
| `Something went wrong. Please try again.` (login) | Wrong password or network unreachable | Check password and LAN IP in api_config.dart |
| `Failed to send OTP. Please try again.` | Network error or email not in DB | Make sure you registered first |
| App can't connect at all | Wrong LAN IP or backend not running | Run `ipconfig`, update `_devLanIp`, restart backend |
| `403 Email not verified` | `EMAIL_VERIFICATION_REQUIRED=true` | Add `EMAIL_VERIFICATION_REQUIRED=false` to backend/.env |
| `500` on any endpoint | Backend crashed | Check server logs in the terminal |
