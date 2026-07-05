# Quick Start Guide - Backend Server

## ✅ Issue Fixed

**The `ModuleNotFoundError: No module named 'backend'` error has been fixed!**

All imports in the `app/` directory have been corrected from:
- ❌ `from backend.app.auth import controller`
- ✅ `from app.auth import controller`

---

## Start the Server (3 Simple Steps)

### Step 1: Open Terminal in Backend Directory

```powershell
cd d:\MinorProject\ai_healthcare_assistant\backend
```

### Step 2: Activate Virtual Environment

```powershell
.\venv\Scripts\activate
```

You should see `(venv)` in your prompt.

### Step 3: Start the Server

```powershell
python -m uvicorn app.main:app --reload
```

**Expected Output:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [XXXXX] using WatchFiles
INFO:     Started server process [XXXXX]
INFO:     Application startup complete.
```

✅ **Success!** Your server is now running.

---

## Test the Server

### Option 1: Run Quick Test Script (Recommended)

Open a **new terminal** and run:

```powershell
cd d:\MinorProject\ai_healthcare_assistant\backend
.\quick_test.ps1
```

This will automatically test:
- ✓ Health check
- ✓ User registration
- ✓ Login
- ✓ Get profile (protected route)
- ✓ Create user profile

### Option 2: Open Swagger UI

1. Open your browser
2. Go to: **http://127.0.0.1:8000/docs**
3. You'll see interactive API documentation
4. Click on any endpoint to test it

### Option 3: Manual Test

In a **new PowerShell terminal**:

```powershell
# Health check
Invoke-RestMethod http://localhost:8000/health
```

Expected response:
```json
{
  "status": "ok",
  "version": "1.0.0"
}
```

---

## Common Issues

### Issue 1: Virtual Environment Not Activated

**Symptom**: Command not found or wrong Python version

**Solution**:
```powershell
.\venv\Scripts\activate
```

### Issue 2: Dependencies Not Installed

**Symptom**: `ModuleNotFoundError` for packages like `fastapi`, `uvicorn`, etc.

**Solution**:
```powershell
pip install -r requirements.txt
```

### Issue 3: Database Connection Error

**Symptom**: `OperationalError: could not connect to server`

**Solution**:
1. Check PostgreSQL is running:
   ```powershell
   Get-Service postgresql*
   ```

2. Verify `.env` has correct credentials:
   ```env
   DATABASE_URL=postgresql+asyncpg://postgres:YOUR_PASSWORD@localhost:5432/healthcare_db
   ```

3. Create database if needed:
   ```powershell
   psql -U postgres -c "CREATE DATABASE healthcare_db;"
   ```

### Issue 4: Port 8000 Already in Use

**Symptom**: `[Errno 10048] error while attempting to bind`

**Solution**: Use a different port:
```powershell
python -m uvicorn app.main:app --reload --port 8001
```

---

## What's Next?

1. ✅ Server is running without errors
2. ⬜ Test all endpoints in Swagger UI: http://127.0.0.1:8000/docs
3. ⬜ Run automated tests: `pytest`
4. ⬜ Test with mobile app
5. ⬜ Review complete testing guide: `COMPLETE_TESTING_GUIDE.md`

---

## Useful Links

- **Swagger UI**: http://127.0.0.1:8000/docs
- **ReDoc**: http://127.0.0.1:8000/redoc
- **Health Check**: http://127.0.0.1:8000/health

---

## Need More Help?

See the complete testing guide:
```powershell
code COMPLETE_TESTING_GUIDE.md
```

Or the original testing guide:
```powershell
code TESTING_GUIDE.md
```

---

**🎉 Your backend is ready to use!**
