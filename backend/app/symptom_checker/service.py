"""Service layer for symptom checker."""

from typing import List, Dict, Optional
import sys
from pathlib import Path

from .schemas import SymptomCheckRequest, SymptomCheckResponse


class SymptomCheckerService:
    """Service for symptom checking operations."""
    
    def __init__(self):
        """Initialize the service with predictor."""
        self.predictor = None
        self._model_loaded = False
        self._load_model()
    
    def _load_model(self):
        """Load the trained model lazily and safely."""
        try:
            # Insert ai_models path here (inside the method) so it only runs
            # when the model is actually being loaded, not at module-import time.
            # This prevents import-order issues and skips the insertion when the
            # directory does not exist.
            ai_models_path = Path(__file__).parent.parent.parent.parent / "ai_models"
            if ai_models_path.exists() and str(ai_models_path) not in sys.path:
                sys.path.insert(0, str(ai_models_path))

            from symptom_checker.inference.predictor import SymptomCheckerPredictor
            from symptom_checker.config.paths import Paths

            print("Loading symptom checker model...")
            self.predictor = SymptomCheckerPredictor()
            
            # Prefer the large-dataset model (trained on 96K samples / 230 features)
            model_path = Paths.get_model_path("random_forest_symptom_checker")
            if not model_path.exists():
                # Fallback: look for any .pkl in the models directory
                model_dir = Paths.MODELS
                candidates = list(model_dir.glob("*.pkl")) if model_dir.exists() else []
                if candidates:
                    model_path = candidates[0]
                    print(f"Using fallback model: {model_path}")

            if model_path.exists():
                self.predictor.load_model(str(model_path))
                self._model_loaded = True
                print(f"Symptom checker model loaded successfully ({model_path.name})")
                print(f"  Features: {len(self.predictor.feature_names)}")
            else:
                print(f"Model not found at {model_path}")
                self._model_loaded = False
        except Exception as e:
            print(f"Error loading symptom checker model: {e}")
            import traceback
            traceback.print_exc()
            self._model_loaded = False
            self.predictor = None
    
    def is_model_loaded(self) -> bool:
        """Check if model is loaded."""
        return self._model_loaded and self.predictor is not None
    
    def check_symptoms(self, request: SymptomCheckRequest) -> Dict:
        """
        Perform symptom checking.
        
        Args:
            request: SymptomCheckRequest with patient data
        
        Returns:
            Prediction result dictionary
        """
        if not self.is_model_loaded():
            return {
                "status": "error",
                "message": "Model not loaded. Please train the model first.",
                "prediction": None,
                "risk_assessment": None,
                "recommendations": None
            }
        
        try:
            # Make prediction
            result = self.predictor.predict(
                symptoms=request.symptoms,
                age=request.age,
                gender=request.gender,
                weight=request.weight,
                height=request.height,
                duration=request.duration,
                severity=request.severity,
                existing_diseases=request.existing_diseases,
                medications=request.medications,
                allergies=request.allergies,
                pregnancy_status=request.pregnancy_status
            )
            
            return result
            
        except Exception as e:
            print(f"Error during prediction: {e}")
            return {
                "status": "error",
                "message": f"Prediction failed: {str(e)}",
                "prediction": None,
                "risk_assessment": None,
                "recommendations": None
            }
    
    def get_available_symptoms(self) -> List[str]:
        """Get list of available symptoms."""
        if not self.is_model_loaded():
            return []
        
        try:
            return self.predictor.symptom_vocabulary
        except:
            return []
    
    def _get_classes(self) -> list:
        """Safely retrieve disease class labels from the loaded predictor.

        The sklearn estimator lives at ``predictor.model.model`` (the wrapper
        holds a ``RandomForestSymptomChecker`` whose inner sklearn object is
        ``model.model``).  We probe both levels so the code works regardless
        of whether the wrapper is used or the estimator is stored directly.
        """
        predictor = self.predictor
        # Level 1 – predictor has classes_ directly (rare but possible)
        if hasattr(predictor, "classes_"):
            return list(predictor.classes_)
        # Level 2 – predictor.model is the sklearn-compatible wrapper
        wrapper = getattr(predictor, "model", None)
        if wrapper is None:
            return []
        if hasattr(wrapper, "classes_"):
            return list(wrapper.classes_)
        # Level 3 – wrapper.model is the raw sklearn estimator
        inner = getattr(wrapper, "model", None)
        if inner is not None and hasattr(inner, "classes_"):
            return list(inner.classes_)
        return []

    def get_available_diseases(self) -> List[str]:
        """Get list of diseases the model can predict."""
        if not self.is_model_loaded():
            return []
        try:
            return self._get_classes()
        except Exception:
            return []

    def get_model_info(self) -> Dict:
        """Get information about loaded model."""
        if not self.is_model_loaded():
            return {
                "loaded": False,
                "message": "Model not loaded"
            }

        try:
            from symptom_checker.config.config import config

            classes = self._get_classes()
            return {
                "loaded": True,
                "model_name": config.MODEL_NAME,
                "model_version": config.MODEL_VERSION,
                "n_symptoms": len(self.predictor.symptom_vocabulary),
                "n_diseases": len(classes),
                "n_features": len(self.predictor.feature_names),
            }
        except Exception:
            return {
                "loaded": False,
                "message": "Model metadata unavailable"
            }

    def reload_model(self) -> Dict:
        """Force-reload the model from disk (useful after retraining)."""
        self._model_loaded = False
        self.predictor = None
        self._load_model()
        return self.get_model_info()

    def validate(self) -> None:
        """Raise if the loaded model has wrong feature count (defensive check)."""
        if not self.is_model_loaded():
            raise RuntimeError("Symptom checker model is not loaded.")
        n = len(self.predictor.feature_names)
        if n != 230:
            raise RuntimeError(
                f"Loaded model has {n} features but 230 are required. "
                "Re-run train_large_dataset.py and restart the server."
            )


# Global service instance — loaded once at server startup
symptom_checker_service = SymptomCheckerService()
