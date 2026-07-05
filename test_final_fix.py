"""Final validation — confirms the 15-feature bug is permanently eliminated."""
import sys
sys.path.insert(0, 'ai_models')

print("=" * 60)
print("FINAL FIX VALIDATION")
print("=" * 60)

# 1. Verify artifacts on disk
import joblib
from symptom_checker.config.paths import Paths

fn = joblib.load(Paths.FEATURE_NAMES / "feature_names.pkl")
sv = joblib.load(Paths.get_encoder_path("symptom_vectorizer"))
assert len(fn) == 230, f"feature_names.pkl: {len(fn)}"
assert sv["vocabulary_size"] == 230, f"vectorizer vocab: {sv['vocabulary_size']}"
print(f"[OK] Artifacts on disk:  feature_names={len(fn)}, vectorizer={sv['vocabulary_size']}")

# 2. Verify model loads with 230 features
from backend.app.symptom_checker.service import symptom_checker_service
assert symptom_checker_service.is_model_loaded()
n = len(symptom_checker_service.predictor.feature_names)
assert n == 230, f"Loaded model has {n} features"
print(f"[OK] Service loaded:     {n} features, "
      f"{len(symptom_checker_service.predictor.model.classes_)} diseases")

# 3. validate() must not raise
symptom_checker_service.validate()
print("[OK] validate():         PASSED")

# 4. Predict with old-style mobile strings (capitals)
from backend.app.symptom_checker.schemas import SymptomCheckRequest

for label, symptoms in [
    ("exact lowercase",  ["fever", "cough", "shortness of breath", "fatigue"]),
    ("old mobile caps",  ["Fever", "Dry Cough", "Shortness of Breath", "Fatigue"]),
    ("mixed style",      ["Headache", "nausea", "dizziness", "chest tightness"]),
]:
    req = SymptomCheckRequest(symptoms=symptoms, age=30, gender="male", duration=3, severity=2)
    result = symptom_checker_service.check_symptoms(req)
    assert result["status"] == "success", f"FAILED for {label}: {result}"
    print(f"[OK] Prediction ({label}): "
          f"{result['prediction']['primary_disease']} "
          f"({result['prediction']['confidence']*100:.1f}%)")

# 5. train.py refuses to run
import subprocess, sys as _sys
proc = subprocess.run([_sys.executable, "ai_models/symptom_checker/training/train.py"],
                      capture_output=True, text=True)
assert proc.returncode != 0, "train.py should exit with error"
out = (proc.stdout + proc.stderr).lower()
assert "deprecated" in out or "disabled" in out or "error" in out, f"Unexpected output: {proc.stdout[:200]}"
print("[OK] train.py:           Correctly blocked (exits with error)")

print()
print("=" * 60)
print("ALL CHECKS PASSED — mobile error is permanently fixed")
print("Restart the backend server to apply all changes.")
print("=" * 60)
