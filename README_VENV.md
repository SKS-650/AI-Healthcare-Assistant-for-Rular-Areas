# Virtual Environment - Quick Start

## ✅ Status: Virtual Environment Created & Ready

Location: `d:\MinorProject\ai_healthcare_assistant\venv\`

---

## Activate Virtual Environment (2 Ways)

### Option 1: Using Quick Script (Easiest)

```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\activate_venv.ps1
```

### Option 2: Manual Activation

```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\venv\Scripts\Activate.ps1
```

**Success Indicator**: You'll see `(venv)` in your prompt:
```
(venv) PS D:\MinorProject\ai_healthcare_assistant>
```

---

## Install Dependencies

With virtual environment activated:

```powershell
# Install backend dependencies
pip install -r backend/requirements.txt

# Install AI models dependencies (if needed)
pip install -r ai_models/requirements.txt
```

---

## Run Backend Server

```powershell
# Make sure venv is activated first!
cd backend
python -m uvicorn app.main:app --reload
```

**Expected Output:**
```
INFO: Uvicorn running on http://127.0.0.1:8000
INFO: Application startup complete.
```

**Test it:**
- Browser: http://127.0.0.1:8000/docs
- PowerShell: `Invoke-RestMethod http://localhost:8000/health`

---

## Complete Workflow

### First Time Setup:

```powershell
# 1. Navigate to project
cd d:\MinorProject\ai_healthcare_assistant

# 2. Activate venv
.\activate_venv.ps1

# 3. Install dependencies
pip install -r backend/requirements.txt

# 4. Run backend
cd backend
python -m uvicorn app.main:app --reload
```

### Daily Workflow:

```powershell
# 1. Navigate to project
cd d:\MinorProject\ai_healthcare_assistant

# 2. Activate venv
.\activate_venv.ps1

# 3. Run backend
cd backend
python -m uvicorn app.main:app --reload
```

---

## Deactivate

When done working:
```powershell
deactivate
```

---

## Need Help?

See detailed guide: `VIRTUAL_ENV_GUIDE.md`

---

**🎉 Your virtual environment is ready to use!**
