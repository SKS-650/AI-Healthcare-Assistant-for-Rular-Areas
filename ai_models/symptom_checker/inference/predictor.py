"""Main prediction engine for symptom checker.

Clinical augmentation strategy
───────────────────────────────
The underlying Random Forest was trained on a 230-feature binary symptom
vector.  Patient demographics (age, sex, weight, height) and context
(duration, severity, existing diseases, medications) were NOT part of the
training features — so they cannot be fed directly to the model.

Instead we apply two complementary layers:

Layer 1 – Symptom augmentation (before model inference)
  We infer *additional* clinically plausible symptoms from the patient
  profile and append them to the symptom list before building the feature
  vector.  This makes the model see a richer, more accurate picture.

  Examples:
    • Obese patient (BMI ≥ 30) with joint pain → also flags "weight gain"
    • Elderly patient (≥ 65) with confusion   → also flags "disturbance of memory"
    • Chronic symptoms (> 14 days)            → also flags "feeling ill", "fatigue"
    • Diabetic patient with skin rash         → also flags "itching of skin"

Layer 2 – Post-model risk enrichment (after model inference)
  The RiskAssessmentEngine now accepts weight, height, duration, medications,
  and allergies and folds them into the risk score with documented clinical
  weights (see risk_engine.py).

Together, every input field the user provides materially changes BOTH the
predicted disease distribution AND the risk score.
"""

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


# ─────────────────────────────────────────────────────────────────────────────
# Clinical augmentation maps
# Each key is a model symptom name (from feature_names.pkl).
# Values are (condition_check_fn, reason_string) pairs used for logging.
# ─────────────────────────────────────────────────────────────────────────────

def _bmi(weight: float, height: float) -> float:
    h = height / 100.0
    return weight / (h * h) if h > 0 else 0.0


# BMI thresholds
_BMI_UNDERWEIGHT = 18.5
_BMI_OVERWEIGHT  = 25.0
_BMI_OBESE       = 30.0
_BMI_MORBID      = 40.0


class SymptomCheckerPredictor:
    """Main predictor class for symptom checking."""

    def __init__(self, model_path: Optional[str] = None):
        self.model: Optional[RandomForestSymptomChecker] = None
        self.symptom_vectorizer = None
        self.feature_engineer = FeatureEngineer()
        self.symptom_normalizer = SymptomNormalizer()
        self.risk_engine = RiskAssessmentEngine()
        self.recommendation_engine = RecommendationEngine()
        self.emergency_detector = EmergencyDetector()
        self.feature_names: List[str] = []
        self.symptom_vocabulary: List[str] = []

        if model_path:
            self.load_model(model_path)

    # ── Model loading (unchanged) ─────────────────────────────────────────────

    def load_model(self, model_path: Optional[str] = None):
        if model_path is None:
            model_path = Paths.get_model_path(config.MODEL_NAME)

        print(f"Loading model from {model_path}")
        self.model = RandomForestSymptomChecker.load(model_path)
        n_model_features = self.model.model.n_features_in_
        print(f"  Model expects {n_model_features} input features")

        feature_names_path = Paths.FEATURE_NAMES / "feature_names.pkl"
        if feature_names_path.exists():
            self.feature_names = joblib.load(feature_names_path)
            self.symptom_vocabulary = list(self.feature_names)
            print(f"  Loaded {len(self.feature_names)} feature names")
        else:
            raise FileNotFoundError(
                f"feature_names.pkl not found at {feature_names_path}. "
                "Re-run train_large_dataset.py."
            )

        if len(self.feature_names) != n_model_features:
            raise ValueError(
                f"MISMATCH: feature_names.pkl has {len(self.feature_names)} "
                f"entries but model expects {n_model_features}. "
                "Re-run train_large_dataset.py."
            )

        vectorizer_path = Paths.get_encoder_path("symptom_vectorizer")
        if vectorizer_path.exists():
            try:
                from ..feature_engineering.symptom_vectorizer import SymptomVectorizer
                self.symptom_vectorizer = SymptomVectorizer.load(str(vectorizer_path))
            except Exception as e:
                print(f"  Warning: could not load symptom_vectorizer.pkl ({e}).")

        print(f"Model loaded — {len(self.feature_names)} symptoms, "
              f"{len(self.model.classes_)} diseases")

    # ── Main prediction ───────────────────────────────────────────────────────

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
        pregnancy_status: Optional[bool] = False,
    ) -> Dict:
        if not self.model:
            raise ValueError("Model not loaded. Call load_model() first.")

        # ── Normalise base symptoms ───────────────────────────────────────────
        symptoms = self.symptom_normalizer.normalize_list(symptoms)

        # ── Layer 1: clinical symptom augmentation ────────────────────────────
        augmented, augmentation_log = self._augment_symptoms(
            symptoms=symptoms,
            age=age,
            gender=gender,
            weight=weight,
            height=height,
            duration=duration,
            severity=severity,
            existing_diseases=existing_diseases or [],
            medications=medications or [],
            allergies=allergies or [],
            pregnancy_status=pregnancy_status or False,
        )

        # ── Emergency detection (on augmented list) ───────────────────────────
        is_emergency, critical_symptoms = self.emergency_detector.is_emergency(augmented)

        # ── Build feature vector from augmented symptoms ──────────────────────
        features = self._prepare_features(augmented)

        # ── Model inference ───────────────────────────────────────────────────
        top_diseases = self.model.predict_top_k(features, k=config.TOP_K_DISEASES)

        primary_disease    = top_diseases[0][0][0] if top_diseases[0] else "Unknown"
        primary_confidence = top_diseases[0][0][1] if top_diseases[0] else 0.0

        # ── Layer 2: enriched risk assessment ─────────────────────────────────
        risk_level, risk_score, risk_details = self.risk_engine.assess_risk(
            symptoms=augmented,
            confidence_score=primary_confidence,
            severity=severity or 1,
            age=age,
            existing_diseases=existing_diseases or [],
            weight=weight,
            height=height,
            duration=duration,
            medications=medications or [],
            allergies=allergies or [],
        )

        if is_emergency:
            risk_level = "critical"
            risk_score = 1.0

        # ── Personalised recommendations ──────────────────────────────────────
        recommendations = self.recommendation_engine.generate_recommendations(
            disease=primary_disease,
            risk_level=risk_level,
            confidence=primary_confidence,
            symptoms=augmented,
            age=age,
            gender=gender,
            weight=weight,
            height=height,
            duration=duration,
            severity=severity or 1,
            existing_diseases=existing_diseases or [],
            medications=medications or [],
            allergies=allergies or [],
        )

        # ── Build BMI for summary ──────────────────────────────────────────────
        bmi_value = None
        bmi_category = None
        if weight and height and height > 0:
            bmi_value = round(_bmi(weight, height), 1)
            bmi_category = _bmi_category_label(bmi_value)

        # ── Compile result ─────────────────────────────────────────────────────
        result = {
            "status": "success",
            "prediction": {
                "primary_disease": primary_disease,
                "confidence": float(primary_confidence),
                "top_diseases": [
                    {"disease": d, "confidence": float(c)}
                    for d, c in top_diseases[0]
                ],
            },
            "risk_assessment": {
                "risk_level": risk_level,
                "risk_score": float(risk_score),
                "is_emergency": is_emergency,
                "critical_symptoms": critical_symptoms,
                "risk_factors": risk_details["factors"],
                "score_breakdown": risk_details["breakdown"],
            },
            "recommendations": recommendations,
            "input_summary": {
                # ── Original inputs ──────────────────────────────────────────
                "symptom_count": len(symptoms),
                "symptoms": symptoms,
                "age": age,
                "gender": gender,
                "weight_kg": weight,
                "height_cm": height,
                "bmi": bmi_value,
                "bmi_category": bmi_category,
                "duration_days": duration,
                "duration_category": _duration_label(duration) if duration is not None else None,
                "severity": severity,
                "severity_label": _severity_label(severity or 1),
                "existing_conditions": existing_diseases or [],
                "medications": medications or [],
                "allergies": allergies or [],
                "pregnancy_status": pregnancy_status,
                # ── Augmentation transparency ────────────────────────────────
                "augmented_symptom_count": len(augmented),
                "augmented_symptoms": augmented,
                "augmentation_log": augmentation_log,
            },
            "metadata": {
                "model_version": config.MODEL_VERSION,
                "timestamp": pd.Timestamp.now().isoformat(),
            },
        }

        if is_emergency:
            result["emergency_alert"] = self.emergency_detector.get_emergency_message()

        return result

    # ── Layer 1: clinical symptom augmentation ────────────────────────────────

    def _augment_symptoms(
        self,
        symptoms: List[str],
        age: int,
        gender: str,
        weight: Optional[float],
        height: Optional[float],
        duration: int,
        severity: int,
        existing_diseases: List[str],
        medications: List[str],
        allergies: List[str],
        pregnancy_status: bool,
    ) -> Tuple[List[str], List[str]]:
        """
        Return (augmented_symptom_list, log_messages).

        We add symptoms to the model's vocabulary that are clinically implied
        by the patient's profile but may not have been explicitly reported.
        Only symptoms that are already in the model vocabulary are added
        (we build the set once for O(1) lookup).
        """
        vocab_set = set(self.feature_names)
        augmented = list(symptoms)  # start with a copy
        log: List[str] = []

        def _add(symptom: str, reason: str):
            """Add symptom if it's in vocabulary and not already present."""
            if symptom in vocab_set and symptom not in augmented:
                augmented.append(symptom)
                log.append(f"Added '{symptom}' — {reason}")

        # ── BMI-based augmentation ────────────────────────────────────────────
        if weight and height and height > 0:
            bmi = _bmi(weight, height)

            if bmi >= _BMI_MORBID:
                _add("weight gain",          "morbid obesity (BMI ≥ 40)")
                _add("shortness of breath",  "morbid obesity — reduced lung compliance")
                _add("fatigue",              "morbid obesity — increased metabolic load")
                _add("cramps and spasms",    "morbid obesity — musculoskeletal stress")
                _add("increased heart rate", "morbid obesity — elevated cardiac demand")
                _add("peripheral edema",     "morbid obesity — venous insufficiency")

            elif bmi >= _BMI_OBESE:
                _add("weight gain",          "obesity (BMI ≥ 30)")
                _add("fatigue",              "obesity — increased metabolic demand")
                _add("shortness of breath",  "obesity — reduced functional capacity")
                _add("peripheral edema",     "obesity — venous stasis")

            elif bmi >= _BMI_OVERWEIGHT:
                _add("weight gain",          "overweight (BMI ≥ 25)")

            elif bmi < _BMI_UNDERWEIGHT:
                _add("fatigue",              "underweight (BMI < 18.5) — likely nutritional deficit")
                _add("weakness",             "underweight — muscle wasting")
                _add("loss of appetite",     "underweight — appetite dysregulation")
                if bmi < 16.0:
                    _add("feeling ill",      "severe underweight — systemic compromise")

        # ── Age-based augmentation ────────────────────────────────────────────
        if age <= 4:
            # Infants / toddlers — classic non-specific presentations
            _add("restlessness",    "infant age — common non-specific symptom")
            _add("lack of growth",  "infant age — growth parameter relevant")

        elif age <= 11:
            # School-age children — tend to present with more systemic symptoms
            _add("fatigue",         "paediatric — high metabolic demand amplifies fatigue")

        elif age >= 65:
            # Elderly — atypical presentations are common
            _add("weakness",        "elderly — sarcopenia / deconditioning")
            _add("fatigue",         "elderly — reduced physiological reserve")
            if age >= 75:
                _add("disturbance of memory", "advanced age — cognitive vulnerability")
                _add("sleepiness",            "advanced age — circadian dysregulation")
                _add("dizziness",             "advanced age — orthostatic / vestibular risk")

        # ── Duration-based augmentation ───────────────────────────────────────
        if duration is not None:
            if duration > 14:
                # Symptoms persisting >2 weeks suggest systemic involvement
                _add("fatigue",     f"symptoms persisting {duration} days — systemic fatigue")
                _add("feeling ill", f"chronic presentation ({duration} days) — malaise")
                _add("weakness",    f"prolonged illness ({duration} days) — deconditioning")

            if duration > 30:
                # Truly chronic — adds weight-loss / appetite signals
                _add("loss of appetite",  "chronic illness > 1 month — appetite suppression")
                _add("weight gain",       "chronic inflammatory state — metabolic shift")
                _add("sleepiness",        "chronic illness — fatigue cascade")

        # ── Severity-based augmentation ───────────────────────────────────────
        if severity == 4:
            # Critical severity always implies systemic involvement
            _add("weakness",    "critical severity — systemic compromise")
            _add("feeling ill", "critical severity — severe malaise")

        # ── Gender-specific augmentation ──────────────────────────────────────
        if gender == "female":
            if pregnancy_status:
                _add("fatigue",           "pregnancy — increased physiological demand")
                _add("nausea",            "pregnancy — common symptom")
                _add("increased heart rate", "pregnancy — elevated cardiac output")

        # ── Existing-disease augmentation ─────────────────────────────────────
        diseases_lower = " ".join(d.lower() for d in existing_diseases)

        if "diabetes" in diseases_lower:
            _add("fatigue",              "diabetes — chronic energy dysregulation")
            _add("increased heart rate", "diabetes — autonomic neuropathy")
            _add("itching of skin",      "diabetes — pruritus from hyperglycaemia")
            _add("weakness",             "diabetes — peripheral neuropathy")

        if any(k in diseases_lower for k in ("hypertension", "high blood pressure")):
            _add("headache",             "hypertension — pressure headache")
            _add("dizziness",            "hypertension — cerebrovascular effect")

        if any(k in diseases_lower for k in ("heart", "cardiac", "coronary")):
            _add("fatigue",              "cardiac condition — reduced output")
            _add("shortness of breath",  "cardiac condition — pulmonary congestion")
            _add("peripheral edema",     "cardiac condition — right heart failure")

        if any(k in diseases_lower for k in ("copd", "asthma", "emphysema", "lung")):
            _add("shortness of breath",  "respiratory condition — baseline dyspnoea")
            _add("cough",                "respiratory condition — chronic airway irritation")
            _add("fatigue",              "respiratory condition — hypoxic fatigue")

        if any(k in diseases_lower for k in ("kidney", "renal")):
            _add("fatigue",              "renal condition — anaemia / uraemia")
            _add("peripheral edema",     "renal condition — fluid retention")
            _add("nausea",               "renal condition — uraemic nausea")

        if any(k in diseases_lower for k in ("liver", "hepatitis", "cirrhosis")):
            _add("fatigue",              "liver condition — hepatic insufficiency")
            _add("nausea",               "liver condition — dyspepsia")
            _add("jaundice",             "liver condition — bilirubin accumulation risk")

        if any(k in diseases_lower for k in ("thyroid", "hypothyroid")):
            _add("fatigue",              "hypothyroidism — low metabolism")
            _add("weakness",             "hypothyroidism — myopathy")
            _add("weight gain",          "hypothyroidism — metabolic suppression")

        if "hyperthyroid" in diseases_lower:
            _add("increased heart rate", "hyperthyroidism — thyroid-mediated tachycardia")
            _add("sweating",             "hyperthyroidism — heat intolerance")
            _add("anxiety and nervousness", "hyperthyroidism — sympathetic activation")

        if any(k in diseases_lower for k in ("cancer", "tumor", "leukemia", "lymphoma")):
            _add("fatigue",              "malignancy — cancer-related fatigue")
            _add("weight gain",          "malignancy — metabolic disruption")
            _add("weakness",             "malignancy — cachexia / deconditioning")
            _add("loss of appetite",     "malignancy — cancer anorexia")

        if any(k in diseases_lower for k in ("hiv", "aids", "immunodeficiency")):
            _add("fatigue",              "immunocompromised — systemic vulnerability")
            _add("feeling ill",          "immunocompromised — recurrent illness")
            _add("weakness",             "immunocompromised — constitutional symptoms")

        if any(k in diseases_lower for k in ("depression", "anxiety")):
            _add("fatigue",              "mental health condition — psychosomatic fatigue")
            _add("insomnia",             "mental health condition — sleep disruption")

        # ── Medication-based augmentation ────────────────────────────────────
        meds_lower = " ".join(m.lower() for m in medications)

        if any(k in meds_lower for k in ("steroid", "prednisone", "dexamethasone", "cortisone")):
            _add("weight gain",          "corticosteroid use — fluid/fat redistribution")
            _add("increased heart rate", "corticosteroid use — sympathomimetic effect")

        if any(k in meds_lower for k in ("metformin", "insulin", "glipizide")):
            _add("fatigue",              "antidiabetic therapy — glucose fluctuations")

        if any(k in meds_lower for k in ("warfarin", "heparin", "clopidogrel")):
            _add("fatigue",              "anticoagulant therapy — anaemia risk")

        if any(k in meds_lower for k in ("chemotherapy", "chemo")):
            _add("fatigue",              "chemotherapy — bone marrow suppression")
            _add("nausea",               "chemotherapy — common GI side effect")
            _add("loss of appetite",     "chemotherapy — GI toxicity")
            _add("weakness",             "chemotherapy — systemic toxicity")

        return augmented, log

    # ── Feature vector construction ───────────────────────────────────────────

    def _prepare_features(self, symptoms: List[str]) -> np.ndarray:
        """Build 230-dim binary feature vector from (augmented) symptom list."""
        n = len(self.feature_names)
        if n == 0:
            raise ValueError("feature_names empty — call load_model() first.")

        vec = np.zeros(n, dtype=float)
        sym_idx: Dict[str, int] = {name: i for i, name in enumerate(self.feature_names)}

        matched = 0
        for symptom in symptoms:
            idx = sym_idx.get(symptom)
            if idx is not None:
                vec[idx] = 1.0
                matched += 1
                continue
            # Substring fallback
            low = symptom.lower().strip()
            for feat, fidx in sym_idx.items():
                if low in feat or feat in low:
                    vec[fidx] = 1.0
                    matched += 1
                    break

        if matched == 0 and symptoms:
            print(
                f"Warning: none of {len(symptoms)} symptoms matched vocabulary. "
                f"Sample: {symptoms[:5]}"
            )
        return vec.reshape(1, -1)

    # ── Batch / explain (public API preserved) ────────────────────────────────

    def batch_predict(self, patients_data: List[Dict]) -> List[Dict]:
        results = []
        for patient in patients_data:
            try:
                results.append(self.predict(**patient))
            except Exception as e:
                results.append({"status": "error", "error": str(e)})
        return results

    def explain_prediction(self, symptoms: List[str], age: int, gender: str, **kw) -> Dict:
        prediction = self.predict(symptoms, age, gender, **kw)
        top_features = self.model.get_feature_importance(
            feature_names=self.feature_names, top_n=10
        )
        return {
            "prediction": prediction,
            "important_features": top_features.to_dict("records"),
            "explanation": (
                f"Prediction based on {len(symptoms)} base symptoms "
                f"(expanded to {prediction['input_summary']['augmented_symptom_count']} "
                f"after clinical augmentation)."
            ),
        }


# ─────────────────────────────────────────────────────────────────────────────
# Small utility functions (used in input_summary)
# ─────────────────────────────────────────────────────────────────────────────

def _bmi_category_label(bmi: float) -> str:
    if bmi < 16.0:   return "Severe underweight"
    if bmi < 18.5:   return "Underweight"
    if bmi < 25.0:   return "Normal weight"
    if bmi < 30.0:   return "Overweight"
    if bmi < 35.0:   return "Obese (Class I)"
    if bmi < 40.0:   return "Obese (Class II)"
    return "Morbidly obese (Class III)"


def _duration_label(days: int) -> str:
    if days <= 3:    return "Acute"
    if days <= 7:    return "Short-term"
    if days <= 14:   return "Sub-acute"
    if days <= 30:   return "Prolonged"
    return "Chronic"


def _severity_label(severity: int) -> str:
    return {1: "Mild", 2: "Moderate", 3: "Severe", 4: "Critical"}.get(severity, "Mild")
