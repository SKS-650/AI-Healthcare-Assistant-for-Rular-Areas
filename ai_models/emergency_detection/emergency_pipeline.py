"""
Emergency Detection Pipeline — the single entry point for all emergency assessment.

Usage
-----
from ai_models.emergency_detection.emergency_pipeline import (
    EmergencyPipelineInput,
    run_emergency_pipeline,
)

result = run_emergency_pipeline(EmergencyPipelineInput(
    description="I have severe chest pain and difficulty breathing",
    age=55,
    has_cardiac_history=True,
    symptom_count=3,
    severity_level=4,
    duration_hours=1.0,
))

print(result.risk_level)        # CRITICAL
print(result.risk_score)        # 88
print(result.first_aid.steps)   # [...first aid instructions...]
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field
from typing import List, Optional

from ai_models.emergency_detection.emergency_classifier import (
    EmergencyClassification,
    EmergencyClassifier,
)
from ai_models.emergency_detection.emergency_rules import (
    EmergencyCategory,
    RiskLevel,
)
from ai_models.emergency_detection.first_aid_engine import FirstAidGuide, get_first_aid
from ai_models.emergency_detection.severity_estimator import (
    SeverityInput,
    SeverityResult,
    estimate_severity,
)

logger = logging.getLogger(__name__)

# Module-level singleton to avoid re-instantiation on every request
_classifier: Optional[EmergencyClassifier] = None


def _get_classifier() -> EmergencyClassifier:
    global _classifier
    if _classifier is None:
        _classifier = EmergencyClassifier()
    return _classifier


# ─── Pipeline I/O dataclasses ─────────────────────────────────────────────────

@dataclass
class EmergencyPipelineInput:
    """Full assessment input from the API / Flutter app."""

    # Free-text description
    description: str = ""

    # Demographics
    age:    Optional[int]   = None
    gender: Optional[str]   = None    # "male" / "female" / "other"
    weight: Optional[float] = None    # kg

    # Symptom data
    symptoms:       List[str] = field(default_factory=list)
    symptom_count:  int       = 0     # overrides len(symptoms) if provided
    severity_level: int       = 1     # 1-5
    duration_hours: float     = 0.0

    # Medical history
    has_cardiac_history:     bool = False
    has_diabetes:            bool = False
    has_hypertension:        bool = False
    has_respiratory_disease: bool = False
    is_immunocompromised:    bool = False
    is_pregnant:             bool = False

    # Context flags
    recent_accident:     bool = False
    recent_surgery:      bool = False
    recent_travel:       bool = False
    snake_bite:          bool = False
    exposure_to_poison:  bool = False

    # Language for response localisation
    language: str = "en"


@dataclass
class EmergencyPipelineResult:
    """Full assessment result returned to the API."""

    is_emergency:         bool
    risk_score:           int                           # 0-100
    risk_level:           RiskLevel
    emergency_type:       Optional[str]                 # human-readable category name
    emergency_category:   Optional[EmergencyCategory]
    possible_emergency:   str                           # display label
    recommended_dept:     str
    first_aid:            Optional[FirstAidGuide]
    sos_required:         bool
    warning_message:      str
    matched_keywords:     List[str]   = field(default_factory=list)
    severity_breakdown:   dict        = field(default_factory=dict)
    ml_confidence:        float       = 0.0
    rule_triggered:       bool        = False


# ─── Warning message bank ─────────────────────────────────────────────────────

_WARNINGS = {
    EmergencyCategory.CARDIAC: (
        "🚨 HEART EMERGENCY! Call 102 immediately. Do NOT drive yourself. "
        "Chew aspirin if not allergic. Lie down and stay calm."
    ),
    EmergencyCategory.STROKE: (
        "🚨 POSSIBLE STROKE! Act FAST — Call 102 NOW. "
        "Note the time symptoms started. Do NOT give food or water."
    ),
    EmergencyCategory.RESPIRATORY: (
        "🚨 BREATHING EMERGENCY! Call 102 immediately. "
        "If unconscious and not breathing, begin CPR."
    ),
    EmergencyCategory.SNAKEBITE: (
        "🚨 SNAKEBITE! Keep still — do NOT suck venom or cut the wound. "
        "Call 102 or go to hospital immediately."
    ),
    EmergencyCategory.UNCONSCIOUS: (
        "🚨 UNCONSCIOUS PERSON! Call 102 immediately. "
        "Check breathing — begin CPR if not breathing."
    ),
    EmergencyCategory.SEVERE_BLEEDING: (
        "🚨 SEVERE BLEEDING! Apply firm direct pressure. "
        "Elevate the limb. Call 102 immediately."
    ),
    EmergencyCategory.POISONING: (
        "🚨 POISONING SUSPECTED! Call 102 and Poison Control. "
        "Do NOT induce vomiting. Bring the poison container."
    ),
    EmergencyCategory.OVERDOSE: (
        "🚨 OVERDOSE! Call 102 immediately. "
        "Tell them what was taken. Place in recovery position if drowsy."
    ),
    EmergencyCategory.SEVERE_ALLERGY: (
        "🚨 ANAPHYLAXIS! Use epinephrine (EpiPen) if available. "
        "Call 102 immediately."
    ),
    EmergencyCategory.CHOKING: (
        "🚨 CHOKING! Give 5 back blows then 5 abdominal thrusts. "
        "Call 102 if obstruction not cleared."
    ),
    EmergencyCategory.TRAUMA: (
        "🚨 SERIOUS INJURY! Do NOT move the person. "
        "Control bleeding. Call 102 immediately."
    ),
    EmergencyCategory.HIGH_FEVER: (
        "⚠️ HIGH FEVER! Go to hospital immediately if fever > 40°C "
        "or if there are seizures, confusion, or stiff neck."
    ),
    EmergencyCategory.PREGNANCY: (
        "🚨 PREGNANCY EMERGENCY! Call 102 immediately. "
        "Lay on left side. Do NOT delay."
    ),
}

_DEFAULT_WARNING = (
    "🚨 MEDICAL EMERGENCY DETECTED!\n\n"
    "Your symptoms may be life-threatening.\n"
    "• Call 102 (Ambulance) or 112 immediately\n"
    "• Go to the nearest hospital now\n"
    "• Do NOT wait — every second counts\n\n"
    "⚠️ This AI cannot replace emergency care."
)


# ─── Pipeline ─────────────────────────────────────────────────────────────────

def run_emergency_pipeline(inp: EmergencyPipelineInput) -> EmergencyPipelineResult:
    """
    Run the full emergency assessment pipeline.

    Steps:
      1. Combine description + symptom list into a single text corpus
      2. Classify (rule engine + ML)
      3. Estimate severity score
      4. Fetch first aid guide
      5. Build response
    """

    # 1. Prepare text corpus
    symptom_text = " ".join(inp.symptoms) if inp.symptoms else ""
    full_text = f"{inp.description} {symptom_text}".strip()

    # 2. Classify
    clf = _get_classifier()
    classification: EmergencyClassification = clf.classify(full_text)

    # 3. Estimate severity
    eff_symptom_count = inp.symptom_count if inp.symptom_count > 0 else len(inp.symptoms)

    severity_inp = SeverityInput(
        matched_category=classification.category,
        rule_score_weight=classification.rule_weight,
        symptom_count=eff_symptom_count,
        severity_level=inp.severity_level,
        duration_hours=inp.duration_hours,
        has_cardiac_history=inp.has_cardiac_history,
        has_diabetes=inp.has_diabetes,
        has_hypertension=inp.has_hypertension,
        has_respiratory_disease=inp.has_respiratory_disease,
        is_immunocompromised=inp.is_immunocompromised,
        is_pregnant=inp.is_pregnant,
        age=inp.age,
        weight=inp.weight,
        recent_accident=inp.recent_accident,
        recent_surgery=inp.recent_surgery,
        recent_travel=inp.recent_travel,
        snake_bite=inp.snake_bite,
        exposure_to_poison=inp.exposure_to_poison,
        combo_triggered=classification.combo_triggered,
    )
    severity: SeverityResult = estimate_severity(severity_inp)

    # 4. Merge — rule engine can only elevate, never lower the risk
    if classification.rule_triggered:
        # Rule engine result always wins for CRITICAL — ML can only agree or be ignored
        final_risk = classification.risk_level
        final_score = max(severity.score, 76 if final_risk == RiskLevel.CRITICAL else severity.score)
    else:
        final_risk = severity.risk_level
        final_score = severity.score

    # 5. First aid + metadata
    guide = get_first_aid(classification.category)
    category = classification.category

    warning = _WARNINGS.get(category, _DEFAULT_WARNING) if classification.is_emergency else ""

    possible_emergency = (
        guide.title if classification.is_emergency
        else "No immediate emergency detected"
    )

    recommended_dept = guide.recommended_dept if classification.is_emergency else "General Practitioner"

    sos_required = final_risk == RiskLevel.CRITICAL

    return EmergencyPipelineResult(
        is_emergency=classification.is_emergency,
        risk_score=final_score,
        risk_level=final_risk,
        emergency_type=category.value if category else None,
        emergency_category=category,
        possible_emergency=possible_emergency,
        recommended_dept=recommended_dept,
        first_aid=guide if classification.is_emergency else None,
        sos_required=sos_required,
        warning_message=warning,
        matched_keywords=classification.matched_keywords,
        severity_breakdown=severity.breakdown,
        ml_confidence=classification.ml_confidence,
        rule_triggered=classification.rule_triggered,
    )


# ─── Backward compat shim ─────────────────────────────────────────────────────

def run_emergency_pipeline_simple(
    text: str,
    symptom_count: int = 0,
) -> dict[str, object]:
    """Legacy interface — kept for old callers."""
    from ai_models.emergency_detection.emergency_classifier import is_emergency
    from ai_models.emergency_detection.severity_estimator import quick_severity

    emergency = is_emergency(text)
    return {
        "is_emergency": emergency,
        "severity": quick_severity(symptom_count, emergency),
    }
