"""Main prediction engine for symptom checker."""

import numpy as np
import pandas as pd
from typing import List, Dict, Optional, Tuple
from pathlib import Path
import joblib

from ..models.random_forest import RandomForestSymptomChecker
from ..risk_assessment.risk_engine import RiskAssessmentEngine, EmergencyDetector
from ..recommendation.recommendation_engine import RecommendationEngine
from ..preprocessing.symptom_normalization import SymptomNormalizer
from ..feature_engineering.feature_creation import FeatureEngineer, calculate_bmi
from ..config.config import config
from ..config.paths import Paths


class SymptomCheckerPredictor:
    """Main predictor class for symptom checking."""
    
    def __init__(self, model_path: Optional[str] = None):
        """Initialize predictor with model and dependencies."""
        self.model: Optional[RandomForestSymptomChecker] = None
        self.symptom_vectorizer = None
        self.feature_engineer = FeatureEngineer()
        self.symptom_normalizer = SymptomNormalizer()
        self.risk_engine = RiskAssessmentEngine()
        self.recommendation_engine = RecommendationEngine()
        self.emergency_detector = EmergencyDetector()
        self.feature_names = []
        self.symptom_vocabulary = []
        
        # Load model if path provided
        if model_path:
            self.load_model(model_path)
    
    def load_model(self, model_path: Optional[str] = None):
        """Load trained model and artifacts."""
        if model_path is None:
            model_path = Paths.get_model_path(config.MODEL_NAME)

        print(f"Loading model from {model_path}")

        # Load main model
        self.model = RandomForestSymptomChecker.load(model_path)
        n_model_features = self.model.model.n_features_in_
        print(f"  Model expects {n_model_features} input features")

        # ── Always use feature_names.pkl as the canonical source ──────────
        # This must match the columns used during train_large_dataset.py.
        feature_names_path = Paths.FEATURE_NAMES / "feature_names.pkl"
        if feature_names_path.exists():
            self.feature_names = joblib.load(feature_names_path)
            self.symptom_vocabulary = list(self.feature_names)
            print(f"  Loaded {len(self.feature_names)} feature names from feature_names.pkl")
        else:
            raise FileNotFoundError(
                f"feature_names.pkl not found at {feature_names_path}. "
                "Re-run train_large_dataset.py to regenerate artifacts."
            )

        # ── Safety assertion: feature count must match the saved model ────
        if len(self.feature_names) != n_model_features:
            raise ValueError(
                f"CRITICAL MISMATCH: feature_names.pkl has {len(self.feature_names)} "
                f"entries but the loaded model expects {n_model_features} features. "
                "Re-run train_large_dataset.py to regenerate consistent artifacts."
            )

        # Load vectorizer only for metadata / compatibility – never used for
        # feature construction (we build the vector directly from feature_names).
        vectorizer_path = Paths.get_encoder_path("symptom_vectorizer")
        if vectorizer_path.exists():
            try:
                from ..feature_engineering.symptom_vectorizer import SymptomVectorizer
                self.symptom_vectorizer = SymptomVectorizer.load(str(vectorizer_path))
                # Do NOT override feature_names / symptom_vocabulary from the
                # vectorizer – feature_names.pkl is authoritative.
            except Exception as e:
                print(f"  Warning: could not load symptom_vectorizer.pkl ({e}). "
                      "Proceeding with feature_names.pkl only.")

        print(f"Model loaded successfully — {len(self.feature_names)} symptoms, "
              f"{len(self.model.classes_)} diseases")
    
    def predict(
        self,
        symptoms: List[str],
        age: int,
        gender: str,
        weight: Optional[float] = None,
        height: Optional[float] = None,
        duration: Optional[int] = None,
        severity: Optional[int] = 1,
        existing_diseases: Optional[List[str]] = None,
        medications: Optional[List[str]] = None,
        allergies: Optional[List[str]] = None,
        pregnancy_status: Optional[bool] = False
    ) -> Dict:
        """
        Make a disease prediction based on symptoms and patient data.
        
        Args:
            symptoms: List of symptom names
            age: Patient age in years
            gender: Patient gender ('male', 'female', 'other')
            weight: Weight in kg (optional)
            height: Height in cm (optional)
            duration: Symptom duration in days (optional)
            severity: Severity level 1-4 (optional)
            existing_diseases: List of existing conditions (optional)
            medications: List of current medications (optional)
            allergies: List of allergies (optional)
            pregnancy_status: Whether patient is pregnant (optional)
        
        Returns:
            Comprehensive prediction result dictionary
        """
        if not self.model:
            raise ValueError("Model not loaded. Call load_model() first.")
        
        # Normalize symptoms
        symptoms = self.symptom_normalizer.normalize_list(symptoms)
        
        # Check for emergency
        is_emergency, critical_symptoms = self.emergency_detector.is_emergency(symptoms)
        
        # Prepare features
        features = self._prepare_features(
            symptoms=symptoms,
            age=age,
            gender=gender,
            weight=weight,
            height=height,
            duration=duration,
            severity=severity,
            existing_diseases=existing_diseases,
            medications=medications,
            allergies=allergies
        )
        
        # Make prediction
        top_diseases = self.model.predict_top_k(features, k=config.TOP_K_DISEASES)
        
        # Get primary prediction
        primary_disease = top_diseases[0][0][0] if top_diseases[0] else "Unknown"
        primary_confidence = top_diseases[0][0][1] if top_diseases[0] else 0.0
        
        # Assess risk
        risk_level, risk_score, risk_details = self.risk_engine.assess_risk(
            symptoms=symptoms,
            confidence_score=primary_confidence,
            severity=severity,
            age=age,
            existing_diseases=existing_diseases or []
        )
        
        # Override risk if emergency detected
        if is_emergency:
            risk_level = "critical"
            risk_score = 1.0
        
        # Generate recommendations
        recommendations = self.recommendation_engine.generate_recommendations(
            disease=primary_disease,
            risk_level=risk_level,
            confidence=primary_confidence,
            symptoms=symptoms
        )
        
        # Compile result
        result = {
            'status': 'success',
            'prediction': {
                'primary_disease': primary_disease,
                'confidence': float(primary_confidence),
                'top_diseases': [
                    {'disease': disease, 'confidence': float(conf)}
                    for disease, conf in top_diseases[0]
                ]
            },
            'risk_assessment': {
                'risk_level': risk_level,
                'risk_score': float(risk_score),
                'is_emergency': is_emergency,
                'critical_symptoms': critical_symptoms,
                'risk_factors': risk_details['factors']
            },
            'recommendations': recommendations,
            'input_summary': {
                'symptom_count': len(symptoms),
                'symptoms': symptoms,
                'age': age,
                'severity': severity,
                'duration_days': duration
            },
            'metadata': {
                'model_version': config.MODEL_VERSION,
                'timestamp': pd.Timestamp.now().isoformat()
            }
        }
        
        # Add emergency alert if needed
        if is_emergency:
            result['emergency_alert'] = self.emergency_detector.get_emergency_message()
        
        return result
    
    def _prepare_features(
        self,
        symptoms: List[str],
        age: int,
        gender: str,
        weight: Optional[float],
        height: Optional[float],
        duration: Optional[int],
        severity: Optional[int],
        existing_diseases: Optional[List[str]],
        medications: Optional[List[str]],
        allergies: Optional[List[str]]
    ) -> np.ndarray:
        """Prepare 230-dim binary feature vector for model input.

        Each position corresponds to one symptom in feature_names.
        The vector is 1 where the patient has that symptom, 0 otherwise.
        """
        n_features = len(self.feature_names)

        if n_features == 0:
            raise ValueError(
                "feature_names list is empty — model artifacts may not be loaded. "
                "Call load_model() before predict()."
            )

        feature_vector = np.zeros(n_features, dtype=float)

        # Build O(1) lookup: symptom name → column index
        symptom_to_idx: Dict[str, int] = {
            name: i for i, name in enumerate(self.feature_names)
        }

        matched = 0
        for symptom in symptoms:
            # 1. Direct exact match (already normalized by SymptomNormalizer)
            idx = symptom_to_idx.get(symptom)
            if idx is not None:
                feature_vector[idx] = 1.0
                matched += 1
                continue

            # 2. Partial / substring fallback for robustness:
            #    if the symptom string is contained in a feature name or vice-versa
            #    (e.g. "dry cough" → "cough", "Shortness Of Breath" → "shortness of breath")
            lowered = symptom.lower().strip()
            for feat_name, feat_idx in symptom_to_idx.items():
                if lowered in feat_name or feat_name in lowered:
                    feature_vector[feat_idx] = 1.0
                    matched += 1
                    break

        if matched == 0 and symptoms:
            print(
                f"Warning: none of the {len(symptoms)} provided symptoms "
                f"matched the model vocabulary. Check normalizer. "
                f"Sample: {symptoms[:5]}"
            )

        return feature_vector.reshape(1, -1)
    
    def batch_predict(
        self,
        patients_data: List[Dict]
    ) -> List[Dict]:
        """
        Make predictions for multiple patients.
        
        Args:
            patients_data: List of patient data dictionaries
        
        Returns:
            List of prediction results
        """
        results = []
        
        for patient in patients_data:
            try:
                result = self.predict(**patient)
                results.append(result)
            except Exception as e:
                results.append({
                    'status': 'error',
                    'error': str(e),
                    'patient_data': patient
                })
        
        return results
    
    def explain_prediction(
        self,
        symptoms: List[str],
        age: int,
        gender: str,
        **kwargs
    ) -> Dict:
        """
        Explain why a particular prediction was made.
        
        Returns:
            Dictionary with feature importance and explanation
        """
        # Get prediction
        prediction = self.predict(symptoms, age, gender, **kwargs)
        
        # Get feature importance for top symptoms
        top_features = self.model.get_feature_importance(
            feature_names=self.feature_names,
            top_n=10
        )
        
        return {
            'prediction': prediction,
            'important_features': top_features.to_dict('records'),
            'explanation': f"The prediction is based on {len(symptoms)} symptoms, "
                          f"with the most influential factors being the top features shown."
        }
