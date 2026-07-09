"""Quick startup health-check — run from backend/ directory."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))

from app.core.startup import initialize_application
initialize_application()

print("=== Checking router imports ===")
from app.auth.routes import router as r1
print("  auth router OK,", len(r1.routes), "routes")

from app.users.routes import router as r2
print("  users router OK,", len(r2.routes), "routes")

from app.symptom_checker.routes import router as r3
print("  symptom_checker router OK,", len(r3.routes), "routes")

from app.medical_chatbot.api import router as r4
print("  chatbot router OK,", len(r4.routes), "routes")
for route in r4.routes:
    methods = getattr(route, 'methods', set())
    path    = getattr(route, 'path', '')
    print("   ", methods, path)

print("\n=== Checking DB connection string ===")
from app.config.settings import settings
print("  DB URL:", settings.database_url)
print("  ENV:", settings.environment)

print("\n=== All checks passed ===")
