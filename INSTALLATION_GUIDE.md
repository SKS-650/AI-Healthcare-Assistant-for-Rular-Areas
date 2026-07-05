# Installation Guide - AI Healthcare Assistant

Complete guide for setting up the development environment.

---

## Quick Start (3 Steps)

### Step 1: Activate Virtual Environment

```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\activate_venv.ps1
```

### Step 2: Install All Dependencies

```powershell
pip install -r requirements.txt
```

### Step 3: Verify Installation

```powershell
python -c "import fastapi, pandas, sklearn; print('✓ All core packages installed!')"
```

---

## Detailed Installation

### Prerequisites

Before you begin, ensure you have:

- ✓ Python 3.11+ installed
- ✓ PostgreSQL 12+ installed and running
- ✓ Git installed
- ✓ 2GB+ free disk space

**Check Prerequisites:**
```powershell
python --version          # Should show Python 3.11.x
psql --version            # Should show PostgreSQL
git --version             # Should show Git version
```

---

## Installation Options

### Option 1: Install Everything (Recommended)

This installs all dependencies for backend + AI models:

```powershell
# 1. Navigate to project root
cd d:\MinorProject\ai_healthcare_assistant

# 2. Activate virtual environment
.\activate_venv.ps1

# 3. Upgrade pip
python -m pip install --upgrade pip

# 4. Install all dependencies
pip install -r requirements.txt
```

**Installation time**: ~5-10 minutes (depending on internet speed)

---

### Option 2: Install Backend Only

If you only need the FastAPI backend:

```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\activate_venv.ps1
pip install -r backend/requirements.txt
```

---

### Option 3: Install AI Models Only

If you only need the ML components:

```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\activate_venv.ps1
pip install -r ai_models/requirements.txt
```

---

## Optional Dependencies

### Security & Authentication (Production)

For production-grade security:

```powershell
pip install passlib[bcrypt]==1.7.4
pip install python-jose[cryptography]==3.3.0
pip install cryptography>=41.0.0
```

### Advanced ML Features

For advanced machine learning:

```powershell
# Gradient Boosting
pip install xgboost>=1.5.0
pip install lightgbm>=3.3.0

# Model Explainability
pip install shap>=0.40.0

# Deep Learning (choose one or both)
pip install tensorflow>=2.13.0
pip install torch>=2.0.0
pip install transformers>=4.30.0
```

### Email Support

For sending emails:

```powershell
pip install aiosmtplib>=3.0.0
pip install email-validator>=2.0.0
```

### Monitoring & Logging

For production monitoring:

```powershell
pip install sentry-sdk==2.0.0
pip install prometheus-client==0.17.0
pip install python-json-logger==2.0.7
```

---

## Verify Installation

### Check Installed Packages

```powershell
pip list
```

### Test Core Imports

**Backend:**
```powershell
python -c "import fastapi, uvicorn, sqlalchemy, pydantic; print('✓ Backend packages OK')"
```

**AI Models:**
```powershell
python -c "import numpy, pandas, sklearn, joblib; print('✓ AI packages OK')"
```

**Testing:**
```powershell
python -c "import pytest, httpx; print('✓ Testing packages OK')"
```

### Run All Verification Tests

```powershell
python -c "
import sys
packages = {
    'fastapi': 'FastAPI',
    'uvicorn': 'Uvicorn',
    'sqlalchemy': 'SQLAlchemy',
    'pydantic': 'Pydantic',
    'numpy': 'NumPy',
    'pandas': 'Pandas',
    'sklearn': 'scikit-learn',
    'pytest': 'pytest',
    'httpx': 'httpx',
    'redis': 'Redis',
}

failed = []
for module, name in packages.items():
    try:
        __import__(module)
        print(f'✓ {name}')
    except ImportError:
        print(f'✗ {name}')
        failed.append(name)

if failed:
    print(f'\n❌ Failed to import: {', '.join(failed)}')
    sys.exit(1)
else:
    print('\n✅ All core packages installed successfully!')
"
```

---

## Common Installation Issues

### Issue 1: pip is outdated

**Error**: `WARNING: You are using pip version X.X.X; however, version Y.Y.Y is available.`

**Solution**:
```powershell
python -m pip install --upgrade pip
```

---

### Issue 2: C++ Build Tools Required

**Error**: `error: Microsoft Visual C++ 14.0 or greater is required`

**Solution**: Install Microsoft C++ Build Tools
1. Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Install "Desktop development with C++"
3. Restart terminal and retry

**Alternative**: Use pre-built wheels:
```powershell
pip install --only-binary :all: package-name
```

---

### Issue 3: Package Conflict

**Error**: `ERROR: Cannot install X because Y requires Z`

**Solution**: Install in order:
```powershell
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt --no-cache-dir
```

---

### Issue 4: Permission Denied

**Error**: `PermissionError: [Errno 13] Permission denied`

**Solution**: Close all Python processes and retry, or use:
```powershell
pip install -r requirements.txt --user
```

---

### Issue 5: Slow Download

**Solution**: Use a faster mirror:
```powershell
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

---

### Issue 6: SSL Certificate Error

**Error**: `SSLError: [SSL: CERTIFICATE_VERIFY_FAILED]`

**Solution**: Update certificates or temporarily bypass (not recommended for production):
```powershell
pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt
```

---

## Post-Installation Setup

### 1. Configure Environment Variables

```powershell
cd backend
Copy-Item .env.example .env
# Edit .env with your settings
```

### 2. Setup Database

```powershell
# Create database
psql -U postgres -c "CREATE DATABASE healthcare_db;"

# Run migrations (if using Alembic)
cd backend
alembic upgrade head
```

### 3. Test Backend Server

```powershell
cd backend
python -m uvicorn app.main:app --reload
```

Open: http://127.0.0.1:8000/docs

### 4. Test AI Models

```powershell
cd ai_models
python -c "from symptom_checker.config.config import config; print('✓ AI models configured')"
```

---

## Update Dependencies

### Update All Packages

```powershell
pip install --upgrade -r requirements.txt
```

### Update Specific Package

```powershell
pip install --upgrade package-name
```

### Check Outdated Packages

```powershell
pip list --outdated
```

---

## Create Requirements Lock File

For production deployment with exact versions:

```powershell
pip freeze > requirements.lock
```

Install from lock file:
```powershell
pip install -r requirements.lock
```

---

## Uninstall All Packages

If you need to start fresh:

```powershell
pip freeze > packages.txt
pip uninstall -r packages.txt -y
rm packages.txt
```

---

## Package Information

### Core Packages

| Package | Version | Purpose |
|---------|---------|---------|
| fastapi | 0.111.0 | Web framework |
| uvicorn | 0.30.1 | ASGI server |
| sqlalchemy | 2.0.30 | Database ORM |
| pydantic | 2.7.1 | Data validation |
| numpy | ≥1.21.0 | Numerical computing |
| pandas | ≥1.3.0 | Data analysis |
| scikit-learn | ≥1.0.0 | Machine learning |
| pytest | 8.2.0 | Testing |

### Total Package Count

After full installation:
- **Core packages**: ~15
- **With dependencies**: ~80-100

---

## Disk Space Requirements

- **Virtual Environment**: ~500 MB
- **Core Dependencies**: ~1 GB
- **With Optional ML**: ~3-5 GB
- **Total Recommended**: 2-6 GB free space

---

## Installation Checklist

- [ ] Python 3.11+ installed
- [ ] Virtual environment created (`venv`)
- [ ] Virtual environment activated
- [ ] pip upgraded to latest version
- [ ] Core dependencies installed (`requirements.txt`)
- [ ] All imports verified (no errors)
- [ ] PostgreSQL installed and running
- [ ] Backend `.env` configured
- [ ] Database created
- [ ] Backend server starts successfully
- [ ] API docs accessible (http://localhost:8000/docs)

---

## Need Help?

### Check Installed Versions
```powershell
pip show package-name
```

### Check Package Dependencies
```powershell
pip show -v package-name
```

### Get Package Info
```powershell
pip search package-name  # (deprecated, use PyPI website)
```

### Official Documentation

- **FastAPI**: https://fastapi.tiangolo.com/
- **scikit-learn**: https://scikit-learn.org/
- **Pandas**: https://pandas.pydata.org/
- **SQLAlchemy**: https://www.sqlalchemy.org/

---

## Next Steps

After successful installation:

1. ✅ All dependencies installed
2. ⏭️ Configure backend environment (`.env`)
3. ⏭️ Setup database
4. ⏭️ Start backend server
5. ⏭️ Run tests: `cd backend && pytest`
6. ⏭️ Start development

---

**🎉 Installation Complete!**

You're ready to start developing the AI Healthcare Assistant.
