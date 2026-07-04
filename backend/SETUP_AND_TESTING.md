# Backend Setup & Testing Guide
## Module 1 (Authentication) + Module 2 (User Management)

---

## Prerequisites

| Tool | Version | Check |
|---|---|---|
| Python | ≥ 3.11 | `python --version` |
| PostgreSQL | ≥ 14 | `psql --version` |
| Redis | ≥ 6 | `redis-cli ping` |
| pip | latest | `pip --version` |

---

## Step 1 — Create the PostgreSQL Database

```bash
# Open psql as superuser
psql -U postgres

# Inside psql:
CREATE DATABASE healthcare_db;
\q
```

---

## Step 2 — Configure Environment

```bash
# From the project root
cd backend
copy .env.example .env    # Windows
# cp .env.example .env    # Mac/Linux
```

Open `backend/.env` and set at minimum:

```env
DATABASE_URL=postgresql+asyncpg://postgres:YOUR_PASSWORD@localhost:5432/healthcare_db
JWT_SECRET_KEY=your-strong-random-secret-here
```

Generate a strong JWT secret:
```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

---

## Step 3 — Install Dependencies

```bash
# From backend/ directory
pip install -r requirements.txt
```

---

## Step 4 — Run Database Migrations

```bash
# From backend/ directory

# Generate the initial migration from your ORM models
alembic revision --autogenerate -m "init_auth_and_users"

# Apply the migration to the database
alembic upgrade head
```

You should see output like:
```
INFO  [alembic.runtime.migration] Running upgrade  -> abc123, init_auth_and_users
```

Verify tables were created:
```bash
psql -U postgres -d healthcare_db -c "\dt"
```

Expected tables:
```
 users
 roles
 permissions
 role_permissions
 refresh_tokens
 otp_codes
 email_verification
 phone_verification
 password_reset
 user_sessions
 user_profiles
 user_addresses
 emergency_contacts
 medical_information
```

---

## Step 5 — Start the Server

```bash
# From backend/ directory
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
```

Expected output:
```
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Running startup tasks...
INFO:     Database tables created (init_db).
INFO:     Startup complete.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

## Step 6 — Verify Server is Running

Open your browser or run:
```bash
curl http://localhost:8000/health
```

Expected:
```json
{"status": "ok", "version": "1.0.0"}
```

Open the interactive API docs:
- Swagger UI → http://localhost:8000/docs
- ReDoc      → http://localhost:8000/redoc

---

## Step 7 — Manual API Testing (Swagger UI)

Open **http://localhost:8000/docs**

### 7.1 — Register a Patient

Click `POST /api/v1/auth/register` → Try it out → paste:

```json
{
  "full_name": "Ramesh Sharma",
  "email": "ramesh@example.com",
  "phone": "+919876543210",
  "password": "SecurePass@123",
  "confirm_password": "SecurePass@123",
  "role": "patient",
  "language": "en"
}
```

Expected response `201`:
```json
{
  "user_id": "...",
  "email": "ramesh@example.com",
  "message": "Registration successful. Please verify your email."
}
```

> **Note:** Email/SMS in development uses a mock (logs to console). No real email is sent.

### 7.2 — Manually Verify Email (Development Shortcut)

Since SMTP is mocked, manually mark the email as verified:

```bash
psql -U postgres -d healthcare_db -c \
  "UPDATE users SET email_verified = true WHERE email = 'ramesh@example.com';"
```

### 7.3 — Login

Click `POST /api/v1/auth/login` → Try it out:

```json
{
  "email": "ramesh@example.com",
  "password": "SecurePass@123"
}
```

Expected response `200`:
```json
{
  "user_id": "...",
  "email": "ramesh@example.com",
  "role": "patient",
  "tokens": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "token_type": "bearer",
    "expires_in": 900
  }
}
```

**Copy the `access_token`.**

### 7.4 — Authorize in Swagger

Click the **Authorize 🔒** button (top right of Swagger UI).
Enter: `Bearer YOUR_ACCESS_TOKEN`
Click Authorize → Close.

All subsequent requests will include this token automatically.

### 7.5 — Get My Profile

Click `GET /api/v1/auth/me` → Try it out → Execute.

Expected `200`:
```json
{
  "user_id": "...",
  "full_name": "Ramesh Sharma",
  "email": "ramesh@example.com",
  "role": "patient",
  ...
}
```

### 7.6 — Create User Profile

Click `POST /api/v1/users/profile` → Try it out:

```json
{
  "date_of_birth": "2000-01-15",
  "gender": "male",
  "blood_group": "B+",
  "height_cm": 172,
  "weight_kg": 68,
  "occupation": "Student",
  "marital_status": "single"
}
```

Expected `201` with profile data.

### 7.7 — Add Address

Click `POST /api/v1/users/address`:

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

### 7.8 — Add Emergency Contact

Click `POST /api/v1/users/emergency-contact`:

```json
{
  "contact_name": "Ram Sharma",
  "relationship": "father",
  "phone": "+919876540000",
  "email": "ram@example.com",
  "priority": 1
}
```

### 7.9 — Add Medical Information

Click `POST /api/v1/users/medical-info`:

```json
{
  "blood_group": "B+",
  "allergies": ["Penicillin"],
  "chronic_diseases": ["None"],
  "disabilities": [],
  "current_medications": ["Vitamin D"],
  "smoking_status": false,
  "alcohol_consumption": false
}
```

### 7.10 — Get Full User Detail

Click `GET /api/v1/users/{user_id}` → enter your `user_id`.

Returns everything: account + profile + addresses + contacts + medical info.

### 7.11 — Refresh Token

Click `POST /api/v1/auth/refresh`:

```json
{
  "refresh_token": "YOUR_REFRESH_TOKEN"
}
```

### 7.12 — Logout

Click `POST /api/v1/auth/logout`:

```json
{
  "refresh_token": "YOUR_REFRESH_TOKEN"
}
```

### 7.13 — Password Reset Flow

```bash
# Step 1: Request reset
POST /api/v1/auth/forgot-password
{"email": "ramesh@example.com"}

# Step 2: Get token from DB (dev shortcut)
psql -U postgres -d healthcare_db \
  -c "SELECT pr.id, pr.token_hash FROM password_reset pr JOIN users u ON pr.user_id=u.id WHERE u.email='ramesh@example.com' AND pr.is_used=false;"

# In production the raw token is in the email link.
# For dev, regenerate a token directly (see below).
```

---

## Step 8 — Run Automated Tests

### Install dev dependencies

```bash
pip install -r requirements-dev.txt
```

### Run all tests

```bash
# From backend/ directory
pytest tests/ -v
```

### Run only auth tests

```bash
pytest tests/api/test_auth.py -v
```

### Run only user management tests

```bash
pytest tests/api/test_users.py -v
```

### Expected output

```
tests/api/test_auth.py::test_register_success PASSED
tests/api/test_auth.py::test_register_duplicate_email PASSED
tests/api/test_auth.py::test_register_password_mismatch PASSED
tests/api/test_auth.py::test_register_weak_password PASSED
tests/api/test_auth.py::test_login_before_email_verify PASSED
tests/api/test_auth.py::test_login_success PASSED
tests/api/test_auth.py::test_login_wrong_password PASSED
tests/api/test_auth.py::test_refresh_token PASSED
tests/api/test_auth.py::test_logout PASSED
tests/api/test_auth.py::test_list_sessions PASSED
...
tests/api/test_users.py::test_get_me PASSED
tests/api/test_users.py::test_create_profile PASSED
tests/api/test_users.py::test_add_address PASSED
tests/api/test_users.py::test_add_emergency_contact PASSED
tests/api/test_users.py::test_create_medical_info PASSED
tests/api/test_users.py::test_cannot_view_other_users_detail PASSED
...
===================== 30 passed in X.XXs =====================
```

> Tests use an **in-memory SQLite** database — no PostgreSQL needed for the test suite.

---

## Step 9 — Test with cURL (Terminal)

```bash
# Register
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"full_name":"Test","email":"t@t.com","phone":"+919876543210","password":"SecurePass@123","confirm_password":"SecurePass@123","role":"patient","language":"en"}'

# Manually verify email in DB
psql -U postgres -d healthcare_db -c "UPDATE users SET email_verified=true WHERE email='t@t.com';"

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"t@t.com","password":"SecurePass@123"}'

# Use token (replace TOKEN below)
curl http://localhost:8000/api/v1/auth/me \
  -H "Authorization: Bearer TOKEN"
```

---

## Common Errors & Fixes

| Error | Cause | Fix |
|---|---|---|
| `could not connect to server` | PostgreSQL not running | `pg_ctl start` or start from Services |
| `FATAL: database "healthcare_db" does not exist` | DB not created | Run Step 1 |
| `RuntimeError: JWT_SECRET_KEY is not configured` | .env not loaded or key is `change-me` | Set a real value in `.env` |
| `ModuleNotFoundError: No module named 'asyncpg'` | Dependencies not installed | `pip install -r requirements.txt` |
| `alembic.util.exc.CommandError: Can't locate revision` | Stale migrations | `alembic downgrade base` then `alembic upgrade head` |
| `403 Email not verified` | Email not verified | Run the SQL UPDATE in Step 7.2 |
| `409 Email already registered` | Duplicate registration | Use a different email |
| `422 Unprocessable Entity` | Validation failed | Check the response body `detail` field |

---

## API Reference Summary

### Authentication — `/api/v1/auth`

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/register` | No | Register new user |
| POST | `/verify-email` | No | Verify email via token |
| POST | `/resend-email-verification` | No | Resend verification email |
| POST | `/send-phone-otp` | No | Send phone OTP |
| POST | `/verify-phone` | No | Verify phone OTP |
| POST | `/login` | No | Login → tokens |
| POST | `/refresh` | No | Refresh access token |
| POST | `/logout` | Yes | Logout current device |
| POST | `/logout-all` | Yes | Logout all devices |
| GET | `/me` | Yes | Get current user |
| GET | `/sessions` | Yes | List active sessions |
| POST | `/sessions/revoke` | Yes | Revoke a session |
| POST | `/forgot-password` | No | Request password reset |
| POST | `/reset-password` | No | Reset password |
| POST | `/admin/change-role` | Admin | Change user role |

### User Management — `/api/v1/users`

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/me` | Yes | Get my account |
| PUT | `/me` | Yes | Update my account |
| POST | `/me/profile-image` | Yes | Upload profile image |
| GET | `/{user_id}` | Yes | Full user detail |
| GET | `/` | Admin | List all users |
| PATCH | `/{user_id}/status` | Admin | Activate/deactivate |
| POST | `/profile` | Yes | Create profile |
| GET | `/profile` | Yes | Get my profile |
| GET | `/{user_id}/profile` | Admin/Doctor | Get user profile |
| PUT | `/profile` | Yes | Update profile |
| POST | `/address` | Yes | Add address |
| GET | `/address` | Yes | Get my addresses |
| PUT | `/address/{id}` | Yes | Update address |
| DELETE | `/address/{id}` | Yes | Delete address |
| POST | `/emergency-contact` | Yes | Add emergency contact |
| GET | `/emergency-contact` | Yes | Get contacts |
| PUT | `/emergency-contact/{id}` | Yes | Update contact |
| DELETE | `/emergency-contact/{id}` | Yes | Delete contact |
| POST | `/medical-info` | Yes | Create medical info |
| GET | `/medical-info` | Yes | Get medical info |
| PUT | `/medical-info` | Yes | Update medical info |
