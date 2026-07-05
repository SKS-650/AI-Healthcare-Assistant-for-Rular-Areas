# Dependencies Overview

This document provides an overview of all project dependencies and how to install them.

---

## 📦 Requirements Files

The project has multiple requirements files for different purposes:

### 1. **Root Level** (Unified)

**File**: `requirements.txt`  
**Purpose**: Complete installation of all project dependencies  
**Includes**: Backend + AI Models + Testing

```powershell
pip install -r requirements.txt
```

### 2. **Backend Only**

**File**: `backend/requirements.txt`  
**Purpose**: FastAPI backend dependencies only  
**Includes**: FastAPI, SQLAlchemy, PostgreSQL, Redis

```powershell
pip install -r backend/requirements.txt
```

### 3. **AI Models Only**

**File**: `ai_models/requirements.txt`  
**Purpose**: Machine learning dependencies  
**Includes**: NumPy, Pandas, scikit-learn, Jupyter

```powershell
pip install -r ai_models/requirements.txt
```

### 4. **Symptom Checker (Specific)**

**File**: `ai_models/symptom_checker/requirements.txt`  
**Purpose**: Symptom checker model dependencies  
**Includes**: Detailed ML libraries with versions

```powershell
pip install -r ai_models/symptom_checker/requirements.txt
```

---

## 🚀 Quick Installation

### Method 1: Automated Installation (Recommended)

```powershell
cd d:\MinorProject\ai_healthcare_assistant
.\install.ps1
```

**Options**:
- `.\install.ps1` - Install everything (default)
- `.\install.ps1 -BackendOnly` - Install backend only
- `.\install.ps1 -AIOnly` - Install AI models only
- `.\install.ps1 -SkipVerify` - Skip verification tests

### Method 2: Manual Installation

```powershell
# 1. Activate virtual environment
.\activate_venv.ps1

# 2. Upgrade pip
python -m pip install --upgrade pip

# 3. Install dependencies
pip install -r requirements.txt
```

---

## 📋 Core Dependencies

### Backend (FastAPI)

| Package | Version | Purpose |
|---------|---------|---------|
| fastapi | 0.111.0 | Modern web framework |
| uvicorn | 0.30.1 | ASGI server |
| sqlalchemy | 2.0.30 | Database ORM |
| asyncpg | 0.29.0 | PostgreSQL async driver |
| pydantic | 2.7.1 | Data validation |
| redis | 5.0.4 | Caching |
| alembic | 1.13.1 | Database migrations |
| python-multipart | 0.0.9 | File uploads |
| python-dotenv | 1.0.1 | Environment variables |

### AI Models (Machine Learning)

| Package | Version | Purpose |
|---------|---------|---------|
| numpy | ≥1.21.0 | Numerical computing |
| pandas | ≥1.3.0 | Data manipulation |
| scikit-learn | ≥1.0.0 | ML algorithms |
| joblib | ≥1.1.0 | Model serialization |
| scipy | ≥1.7.0 | Scientific computing |
| pyyaml | ≥6.0 | Configuration files |
| jupyter | ≥1.0.0 | Data exploration |

### Testing

| Package | Version | Purpose |
|---------|---------|---------|
| pytest | 8.2.0 | Testing framework |
| pytest-asyncio | 0.23.6 | Async tests |
| pytest-cov | 5.0.0 | Coverage reports |
| httpx | 0.27.0 | HTTP testing |

---

## 🔧 Optional Dependencies

### Security (Production)

```powershell
pip install passlib[bcrypt]
pip install python-jose[cryptography]
pip install cryptography
```

### Advanced ML

```powershell
pip install xgboost lightgbm shap
```

### Deep Learning

```powershell
# TensorFlow
pip install tensorflow>=2.13.0

# PyTorch
pip install torch>=2.0.0

# Transformers (NLP)
pip install transformers>=4.30.0
```

### Email Support

```powershell
pip install aiosmtplib email-validator
```

### Monitoring

```powershell
pip install sentry-sdk prometheus-client python-json-logger
```

---

## ✅ Verify Installation

### Quick Check

```powershell
python -c "import fastapi, pandas, sklearn; print('✓ All packages installed!')"
```

### Detailed Check

```powershell
python -c "
packages = ['fastapi', 'uvicorn', 'sqlalchemy', 'pydantic', 
            'numpy', 'pandas', 'sklearn', 'pytest', 'httpx', 'redis']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✓ {pkg}')
    except ImportError:
        print(f'✗ {pkg} - NOT INSTALLED')
"
```

### List All Installed

```powershell
pip list
```

### Check Specific Package

```powershell
pip show package-name
```

---

## 🔄 Update Dependencies

### Update All

```powershell
pip install --upgrade -r requirements.txt
```

### Update Specific Package

```powershell
pip install --upgrade package-name
```

### Check Outdated

```powershell
pip list --outdated
```

---

## 📊 Dependency Tree

```
AI Healthcare Assistant
│
├── Backend (FastAPI)
│   ├── fastapi==0.111.0
│   ├── uvicorn==0.30.1
│   ├── sqlalchemy==2.0.30
│   ├── asyncpg==0.29.0
│   ├── pydantic==2.7.1
│   ├── redis==5.0.4
│   ├── alembic==1.13.1
│   ├── python-multipart==0.0.9
│   └── python-dotenv==1.0.1
│
├── AI Models (Machine Learning)
│   ├── numpy>=1.21.0
│   ├── pandas>=1.3.0
│   ├── scikit-learn>=1.0.0
│   ├── joblib>=1.1.0
│   ├── scipy>=1.7.0
│   ├── pyyaml>=6.0
│   ├── python-dateutil>=2.8.2
│   └── jupyter>=1.0.0
│
└── Testing
    ├── pytest==8.2.0
    ├── pytest-asyncio==0.23.6
    ├── pytest-cov==5.0.0
    └── httpx==0.27.0
```

---

## 💾 Disk Space Requirements

| Component | Size |
|-----------|------|
| Virtual Environment | ~500 MB |
| Core Dependencies | ~1 GB |
| Optional ML Packages | ~2-4 GB |
| **Total Recommended** | **2-6 GB** |

---

## 🐛 Common Installation Issues

### Issue 1: pip is outdated

```powershell
python -m pip install --upgrade pip
```

### Issue 2: C++ Build Tools Required

Download and install: https://visualstudio.microsoft.com/visual-cpp-build-tools/

### Issue 3: Package Conflicts

```powershell
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt --no-cache-dir
```

### Issue 4: Slow Installation

Use a faster mirror:
```powershell
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

---

## 📚 Related Documentation

- **Installation Guide**: `INSTALLATION_GUIDE.md` - Complete setup instructions
- **Virtual Environment**: `VIRTUAL_ENV_GUIDE.md` - venv management
- **Backend Testing**: `backend/COMPLETE_TESTING_GUIDE.md` - Testing guide
- **Quick Start**: `backend/QUICK_START.md` - Get started quickly

---

## 🔗 Useful Commands

```powershell
# Install all dependencies
pip install -r requirements.txt

# Install backend only
pip install -r backend/requirements.txt

# Install AI models only
pip install -r ai_models/requirements.txt

# Verify installation
python -c "import fastapi, pandas, sklearn; print('OK')"

# List installed packages
pip list

# Check specific package
pip show fastapi

# Update all packages
pip install --upgrade -r requirements.txt

# Create lock file with exact versions
pip freeze > requirements.lock

# Install from lock file
pip install -r requirements.lock

# Uninstall all packages
pip freeze > temp.txt && pip uninstall -r temp.txt -y && rm temp.txt
```

---

## 📞 Need Help?

1. Check the **INSTALLATION_GUIDE.md** for detailed instructions
2. See **Common Issues** section above
3. Run the automated installer: `.\install.ps1`
4. Check individual requirements files for specific components

---

**Last Updated**: 2026-07-05  
**Python Version**: 3.11+  
**Total Packages**: ~15 core + ~80-100 with dependencies
