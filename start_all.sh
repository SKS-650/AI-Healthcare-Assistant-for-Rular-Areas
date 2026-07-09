#!/bin/bash

# =============================================================================
# AI Healthcare Assistant - Complete Startup Script
# This script starts both backend and provides instructions for mobile app
# =============================================================================

set -e  # Exit on error

echo ""
echo "========================================================================="
echo "            AI HEALTHCARE ASSISTANT - COMPLETE STARTUP"
echo "========================================================================="
echo ""

# Change to project root
cd "$(dirname "$0")"

# ─── Check Prerequisites ─────────────────────────────────────────────────

echo "[1/5] Checking prerequisites..."
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python is not installed or not in PATH"
    echo "Please install Python 3.11+ from https://www.python.org/downloads/"
    exit 1
fi
echo "[OK] Python found: $(python3 --version)"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "[WARNING] Flutter is not installed or not in PATH"
    echo "You'll need Flutter to run the mobile app"
    echo "Download from: https://flutter.dev/docs/get-started/install"
    echo ""
    echo "You can still start the backend server..."
    sleep 3
else
    echo "[OK] Flutter found: $(flutter --version | head -n 1)"
fi

echo ""

# ─── Setup Virtual Environment ──────────────────────────────────────────

echo "[2/5] Setting up virtual environment..."
echo ""

if [ ! -d ".venv" ]; then
    echo "Creating new virtual environment..."
    python3 -m venv .venv
    echo "[OK] Virtual environment created"
else
    echo "[OK] Virtual environment already exists"
fi

echo ""

# ─── Activate Virtual Environment ───────────────────────────────────────

echo "[3/5] Activating virtual environment..."
echo ""

source .venv/bin/activate
echo "[OK] Virtual environment activated"

echo ""

# ─── Install Dependencies ───────────────────────────────────────────────

echo "[4/5] Checking Python dependencies..."
echo ""

if ! python -c "import fastapi" &> /dev/null; then
    echo "Installing Python dependencies (this may take a few minutes)..."
    pip install -r requirements.txt
    echo "[OK] Dependencies installed"
else
    echo "[OK] Dependencies already installed"
fi

echo ""

# ─── Check Environment Configuration ────────────────────────────────────

echo "[5/5] Checking configuration..."
echo ""

if [ ! -f "backend/.env" ]; then
    echo "[WARNING] backend/.env file not found"
    echo "Creating from template..."
    if [ -f "backend/.env.example" ]; then
        cp backend/.env.example backend/.env
        echo "[OK] Created backend/.env from template"
        echo "[ACTION REQUIRED] Please edit backend/.env and add your API keys:"
        echo "- JWT_SECRET_KEY"
        echo "- CHATBOT_LLM_API_KEY"
        echo ""
        sleep 5
    else
        echo "[ERROR] backend/.env.example not found"
        exit 1
    fi
else
    echo "[OK] Configuration file found"
fi

echo ""

# ─── Get Local IP Address ───────────────────────────────────────────────

echo "Detecting your local IP address..."

# Try different methods to get IP
if command -v ip &> /dev/null; then
    LOCAL_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
elif command -v ifconfig &> /dev/null; then
    LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
else
    echo "[WARNING] Could not detect IP address automatically"
fi

if [ ! -z "$LOCAL_IP" ]; then
    echo "[INFO] Your local IP address: $LOCAL_IP"
    echo ""
    echo "To run on a physical device, update mobile_app/lib/config/api_config.dart:"
    echo "  static const _devLanIp = '$LOCAL_IP';"
    echo "  static const _useEmulator = false;"
else
    echo "[WARNING] Could not detect IP address"
fi

echo ""
echo ""

# ─── Start Backend Server ───────────────────────────────────────────────

echo "========================================================================="
echo "                         STARTING BACKEND SERVER"
echo "========================================================================="
echo ""
echo "Backend will start on: http://0.0.0.0:8000"
echo "API Documentation: http://localhost:8000/docs"
echo "Health Check: http://localhost:8000/health"
echo ""
echo "[INFO] Backend logs will appear below..."
echo "[INFO] Press CTRL+C to stop the server"
echo ""
echo "-------------------------------------------------------------------------"
echo ""

cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# If we reach here, server was stopped
echo ""
echo ""
echo "========================================================================="
echo "Backend server stopped"
echo "========================================================================="
