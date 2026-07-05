# Virtual Environment Guide

## ✅ Virtual Environment Created

A Python virtual environment named `venv` has been created in the root directory:
```
d:\MinorProject\ai_healthcare_assistant\venv\
```

---

## How to Activate

### Method 1: Using the Activation Script (Recommended)

```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\activate_venv.ps1
```

This script will:
- ✓ Check if venv exists
- ✓ Activate the virtual environment
- ✓ Show Python version and location
- ✓ Display helpful commands

### Method 2: Manual Activation

```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\venv\Scripts\Activate.ps1
```

### Verify Activation

When activated, you should see `(venv)` in your terminal prompt:
```
(venv) PS D:\MinorProject\ai_healthcare_assistant>
```

Check Python location:
```powershell
Get-Command python | Select-Object -ExpandProperty Source
```

Expected output:
```
D:\MinorProject\ai_healthcare_assistant\venv\Scripts\python.exe
```

---

## Install Dependencies

Once the virtual environment is activated:

### For Backend

```powershell
cd backend
pip install -r requirements.txt
```

### For AI Models

```powershell
cd ai_models
pip install -r requirements.txt
```

### For All Components

From the root directory with venv activated:
```powershell
# Install backend dependencies
pip install -r backend/requirements.txt

# Install AI models dependencies
pip install -r ai_models/requirements.txt
```

---

## Usage

### Running Backend Server

```powershell
cd backend
python -m uvicorn app.main:app --reload
```

### Running AI Models

```powershell
cd ai_models
python symptom_checker/training/train.py
```

### Running Python Scripts

```powershell
python script.py
```

---

## Deactivate Virtual Environment

When you're done working:
```powershell
deactivate
```

The `(venv)` prefix will disappear from your prompt.

---

## Benefits of Using Virtual Environment

✓ **Isolated Dependencies** - Packages installed won't affect system Python  
✓ **Project-Specific** - Each project can have different package versions  
✓ **Clean System** - Keep your system Python clean  
✓ **Reproducible** - Easy to recreate environment with requirements.txt  
✓ **No Conflicts** - Avoid version conflicts between projects  

---

## Common Commands

### Check Installed Packages
```powershell
pip list
```

### Install a Package
```powershell
pip install package-name
```

### Install Specific Version
```powershell
pip install package-name==1.2.3
```

### Uninstall a Package
```powershell
pip uninstall package-name
```

### Update a Package
```powershell
pip install --upgrade package-name
```

### Freeze Dependencies
```powershell
pip freeze > requirements.txt
```

### Check Python Version
```powershell
python --version
```

### Check pip Version
```powershell
pip --version
```

---

## Troubleshooting

### Issue 1: "Activate.ps1 cannot be loaded"

**Error**: `Activate.ps1 cannot be loaded because running scripts is disabled on this system`

**Solution**: Enable script execution (run as Administrator):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue 2: Virtual Environment Not Activating

**Solution**: Try using the activation script:
```powershell
.\activate_venv.ps1
```

Or activate manually with full path:
```powershell
& "d:\MinorProject\ai_healthcare_assistant\venv\Scripts\Activate.ps1"
```

### Issue 3: Wrong Python Version

**Check Python version**:
```powershell
python --version
```

If wrong version is shown after activation, recreate venv:
```powershell
Remove-Item -Recurse -Force venv
python -m venv venv
.\venv\Scripts\Activate.ps1
```

### Issue 4: Package Installation Fails

**Solution**: Upgrade pip first:
```powershell
python -m pip install --upgrade pip
```

Then retry package installation.

---

## Project Structure

```
ai_healthcare_assistant/
├── venv/                    # ← Virtual environment (created)
│   ├── Scripts/
│   │   ├── activate.ps1     # Activation script
│   │   ├── python.exe       # Python executable
│   │   └── pip.exe          # Package installer
│   ├── Lib/
│   └── ...
├── backend/
│   ├── app/
│   ├── requirements.txt     # Backend dependencies
│   └── ...
├── ai_models/
│   ├── requirements.txt     # AI models dependencies
│   └── ...
├── mobile_app/              # Flutter app
├── activate_venv.ps1        # Quick activation script
└── VIRTUAL_ENV_GUIDE.md     # This guide
```

---

## Quick Reference Card

| Action | Command |
|--------|---------|
| Activate venv | `.\activate_venv.ps1` |
| Activate manually | `.\venv\Scripts\Activate.ps1` |
| Deactivate | `deactivate` |
| Install backend deps | `pip install -r backend/requirements.txt` |
| Install AI deps | `pip install -r ai_models/requirements.txt` |
| Run backend | `cd backend && python -m uvicorn app.main:app --reload` |
| Check packages | `pip list` |
| Check Python | `python --version` |
| Check location | `Get-Command python` |

---

## Next Steps

1. ✅ Virtual environment created
2. ✅ Virtual environment activated
3. ⬜ Install backend dependencies: `pip install -r backend/requirements.txt`
4. ⬜ Install AI model dependencies: `pip install -r ai_models/requirements.txt`
5. ⬜ Run backend server: `cd backend && python -m uvicorn app.main:app --reload`
6. ⬜ Test backend: Open http://localhost:8000/docs

---

**💡 Tip**: Always activate the virtual environment before working on the project!

You can add the activation to your workflow:
```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\activate_venv.ps1
cd backend
python -m uvicorn app.main:app --reload
```
