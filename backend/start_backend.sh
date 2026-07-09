#!/bin/bash
# Shell script to start the backend server on Linux/Mac

echo "========================================"
echo "Starting AI Healthcare Backend Server"
echo "========================================"

# Change to backend directory
cd "$(dirname "$0")"

# Activate virtual environment
if [ -f "../.venv/bin/activate" ]; then
    echo "Activating virtual environment..."
    source ../.venv/bin/activate
else
    echo "ERROR: Virtual environment not found!"
    echo "Please run: python -m venv .venv"
    exit 1
fi

# Start the server
echo ""
echo "Starting FastAPI server..."
echo ""
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
