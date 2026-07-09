"""
Automatic Backend Startup Script
This script automatically starts the FastAPI backend server.
"""
import os
import sys
import subprocess
import time
from pathlib import Path

def check_virtual_env():
    """Check if we're in a virtual environment"""
    return hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix)

def activate_venv():
    """Activate virtual environment"""
    project_root = Path(__file__).parent.parent
    venv_path = project_root / ".venv"
    
    if not venv_path.exists():
        print("❌ Virtual environment not found. Please run: python -m venv .venv")
        sys.exit(1)
    
    # Add venv to path
    if sys.platform == "win32":
        scripts_dir = venv_path / "Scripts"
    else:
        scripts_dir = venv_path / "bin"
    
    os.environ["PATH"] = f"{scripts_dir}{os.pathsep}{os.environ['PATH']}"
    os.environ["VIRTUAL_ENV"] = str(venv_path)
    
    # Remove the default prefix from PATH
    if "PYTHONHOME" in os.environ:
        del os.environ["PYTHONHOME"]
    
    return scripts_dir

def check_dependencies():
    """Check if required packages are installed"""
    try:
        import fastapi
        import uvicorn
        import sqlalchemy
        print("✅ All required packages are installed")
        return True
    except ImportError as e:
        print(f"❌ Missing required package: {e.name}")
        print("Installing dependencies...")
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", "../requirements.txt"], check=True)
        return True

def start_server():
    """Start the FastAPI server"""
    print("\n" + "="*60)
    print("🚀 Starting AI Healthcare Assistant Backend Server")
    print("="*60)
    
    # Change to backend directory
    backend_dir = Path(__file__).parent
    os.chdir(backend_dir)
    
    # Start uvicorn
    try:
        print("\n📡 Server starting on http://0.0.0.0:8000")
        print("📚 API Documentation: http://localhost:8000/docs")
        print("📊 Health Check: http://localhost:8000/health")
        print("\n⚠️  Press CTRL+C to stop the server\n")
        
        subprocess.run([
            sys.executable, "-m", "uvicorn",
            "app.main:app",
            "--reload",
            "--host", "0.0.0.0",
            "--port", "8000",
            "--log-level", "info"
        ], check=True)
    except KeyboardInterrupt:
        print("\n\n👋 Server stopped by user")
    except Exception as e:
        print(f"\n❌ Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    print("🔧 Checking environment...")
    
    # Check and activate venv if needed
    if not check_virtual_env():
        print("⚠️  Not in virtual environment, activating...")
        activate_venv()
    
    # Check dependencies
    check_dependencies()
    
    # Start server
    start_server()
