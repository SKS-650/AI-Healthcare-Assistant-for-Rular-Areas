"""Risk assessment engine for disease predictions.

Clinical weighting of every input parameter:
  ─ severity (1-4)        → up to 0.30 of total score
  ─ age                   → up to 0.18 (very young / elderly)
  ─ BMI (weight+height)   → up to 0.12 (obesity / underweight)
  ─ duration              → up to 0.15 (chronic > acute)
  ─ existing_diseases     → up to 0.15 (comorbidity burden)
  ─ medications           → up to 0.08 (polypharmacy risk)
  ─ emergency symptoms    → up to 0.50 (overrides everything)
  ─ symptom combinations  → up to 0.30
  ─ confidence base       → up to 0.40

Each factor is documented with its clinical rationale.
"""

from typing import List, Dict, Optional, Tuple
import numpy as np

from ..config.config import config
from ..config.constants import CRITICAL_SYMPTOMS, HIGH_RISK_COMBINATIONS


# ─── High-risk comorbidities ──────────────────────────────────────────────────
# These conditions significantly raise individual risk for most presentations.
HIGH_RISK_CONDITIONS = {
    # Cardiovascular / metabolic
    "diabetes":          0.08,
    "heart disease":     0.12,
    "hypertension":      0.07,
    "coronary artery":   0.12,
    "heart failure":     0.12,
    "atrial fibrillation": 0.10,
    # Respiratory
    "copd":              0.10,
    "asthma":            0.06,
    "emphysema":         0.09,
    # Oncological
    "cancer":            0.12,
    "tumor":             0.10,
    "leukemia":          0.12,
    "lymphoma":          0.11,
    # Immune / systemic
    "hiv":               0.10,
    "aids":              0.12,
    "lupus":             0.08,
    "autoimmune":        0.07,
    "immunodeficiency":  0.09,
    # Neurological
    "stroke":            0.09,
    "epilepsy":          0.07,
    "parkinson":         0.08,
    "dementia":          0.09,
    # Renal / hepatic
    "kidney disease":    0.09,
    "renal failure":     0.12,
    "liver disease":     0.08,
    "cirrhosis":         0.10,
    # Endocrine
    "thyroid":           0.05,
    "hypothyroid":       0.05,
    "hyperthyroid":      0.06,
    # Mental health
    "depression":        0.04,
    "anxiety":           0.03,
    # Musculoskeletal
    "arthritis":         0.04,
    "osteoporosis":      0.05,
}

# Medications that raise the clinical risk flag (many = polypharmacy)
HIGH_RISK_MEDICATIONS = {
    "warfarin", "heparin", "clopidogrel", "aspirin",       # anticoagulants
    "methotrexate", "azathioprine", "tacrolimus",           # immunosuppressants
    "prednisone", "dexamethasone", "cortisone",             # steroids
    "insulin", "glipizide", "glibenclamide",                # antidiabetics
    "lithium", "clozapine", "olanzapine",                   # psychotropics
    "digoxin", "amiodarone",                                # cardiac
    "chemotherapy",                                         # oncology
}


class RiskAssessmentEngine:
    """Assess risk level based on ALL clinical parameters."""

    def __init__(self):
        self.risk_levels = config.RISK_LEVELS
        self.critical_symptoms = [s.lower() for s in CRITICAL_SYMPTOMS]
        self.high_risk_combinations = [
            [s.lower() for s in combo] for combo in HIGH_RISK_COMBINATIONS
        ]

    # ─────────────────────────────────────────────────────────────────────────
    # Public API
    # ─────────────────────────────────────────────────────────────────────────

    def assess_risk(
        self,
        symptoms: List[str],
        confidence_score: float,
        severity: int = 1,
        age: Optional[int] = None,
        existing_diseases: Optional[List[str]] = None,
        weight: Optional[float] = None,
        height: Optional[float] = None,
        duration: Optional[int] = None,
        medications: Optional[List[str]] = None,
        allergies: Optional[List[str]] = None,
    ) -> Tuple[str, float, Dict]:
        """
        Compute a clinically-weighted risk score.

        Returns
        -------
        (risk_level, risk_score 0-1, details_dict)
        """
        risk_score = 0.0
        risk_factors: List[str] = []
        breakdown: Dict[str, float] = {}

        # 1. Base confidence contribution (max 0.40)
        base = confidence_score * 0.40
        risk_score += base
        breakdown["base_confidence"] = round(base, 4)

        # 2. Emergency / critical symptoms (max 0.50 — overriding)
        emerg_score, emerg_factors = self._check_emergency_symptoms(symptoms)
        risk_score += emerg_score
        risk_factors.extend(emerg_factors)
        breakdown["emergency_symptoms"] = round(emerg_score, 4)

        # 3. High-risk symptom combinations (max 0.30)
        combo_score, combo_factors = self._check_symptom_combinations(symptoms)
        risk_score += combo_score
        risk_factors.extend(combo_factors)
        breakdown["symptom_combinations"] = round(combo_score, 4)

        # 4. Severity — clinical weight 0.075 per level above 1 (max 0.30)
        #    Mild=1 adds nothing; Moderate=2 adds 0.075; Severe=3 adds 0.15;
        #    Critical=4 adds 0.225 — matching clinical triage escalation.
        sev_score = max(0.0, (severity - 1) * 0.075)
        risk_score += sev_score
        breakdown["severity"] = round(sev_score, 4)
        if severity == 2:
            risk_factors.append("Moderate symptom severity")
        elif severity == 3:
            risk_factors.append("Severe symptom severity — medical review recommended")
        elif severity == 4:
            risk_factors.append("Critical symptom severity — seek urgent care")

        # 5. Age risk (max 0.18)
        if age is not None:
            age_score, age_factors = self._assess_age_risk(age)
            risk_score += age_score
            risk_factors.extend(age_factors)
            breakdown["age"] = round(age_score, 4)

        # 6. BMI risk from weight + height (max 0.12)
        if weight is not None and height is not None and height > 0:
            bmi_score, bmi_factors = self._assess_bmi_risk(weight, height)
            risk_score += bmi_score
            risk_factors.extend(bmi_factors)
            breakdown["bmi"] = round(bmi_score, 4)

        # 7. Duration risk (max 0.15) — chronic symptoms imply untreated disease
        if duration is not None:
            dur_score, dur_factors = self._assess_duration_risk(duration, severity)
            risk_score += dur_score
            risk_factors.extend(dur_factors)
            breakdown["duration"] = round(dur_score, 4)

        # 8. Comorbidity burden (max 0.15)
        if existing_diseases and len(existing_diseases) > 0:
            cond_score, cond_factors = self._assess_conditions_risk(existing_diseases)
            risk_score += cond_score
            risk_factors.extend(cond_factors)
            breakdown["existing_conditions"] = round(cond_score, 4)

        # 9. Medication / polypharmacy risk (max 0.08)
        if medications and len(medications) > 0:
            med_score, med_factors = self._assess_medication_risk(medications)
            risk_score += med_score
            risk_factors.extend(med_factors)
            breakdown["medications"] = round(med_score, 4)

        # Cap at 1.0
        risk_score = min(round(risk_score, 4), 1.0)
        risk_level = self._get_risk_level(risk_score)

        return risk_level, risk_score, {
            "factors": risk_factors,
            "breakdown": breakdown,
        }

    # ─────────────────────────────────────────────────────────────────────────
    # Private helpers
    # ─────────────────────────────────────────────────────────────────────────

    def _check_emergency_symptoms(
        self, symptoms: List[str]
    ) -> Tuple[float, List[str]]:
        symptoms_lower = [s.lower() for s in symptoms]
        found = [
            s for s in symptoms_lower
            if any(c in s for c in self.critical_symptoms)
        ]
        if found:
            return 0.50, [f"Critical symptom detected: {s}" for s in found]
        return 0.0, []

    def _check_symptom_combinations(
        self, symptoms: List[str]
    ) -> Tuple[float, List[str]]:
        symptoms_lower = [s.lower() for s in symptoms]
        found = []
        for combo in self.high_risk_combinations:
            if all(any(c in s for s in symptoms_lower) for c in combo):
                found.append(" + ".join(combo))
        if found:
            score = min(len(found) * 0.20, 0.30)
            return score, [f"High-risk symptom combination: {c}" for c in found]
        return 0.0, []

    def _assess_age_risk(self, age: int) -> Tuple[float, List[str]]:
        """
        Clinical age-risk bands:
          0–4   → 0.15  (immature immune system, rapid deterioration)
          5–11  → 0.08  (paediatric risk)
          12–17 → 0.04  (adolescent — mild elevation)
          18–64 → 0.00  (reference adult group)
          65–74 → 0.08  (early elderly — comorbidity common)
          75–84 → 0.13  (moderate elderly — multiple organ vulnerability)
          85+   → 0.18  (advanced age — highest vulnerability)
        """
        if age < 0:
            return 0.0, []
        if age <= 4:
            return 0.15, ["Very young age (< 5 yrs) — higher vulnerability"]
        if age <= 11:
            return 0.08, ["Paediatric age (5–11 yrs) — elevated risk"]
        if age <= 17:
            return 0.04, ["Adolescent age (12–17 yrs)"]
        if age <= 64:
            return 0.00, []
        if age <= 74:
            return 0.08, ["Elderly age (65–74 yrs) — higher comorbidity risk"]
        if age <= 84:
            return 0.13, ["Advanced age (75–84 yrs) — multiple organ vulnerability"]
        return 0.18, ["Very advanced age (≥ 85 yrs) — highest age-related risk"]

    def _assess_bmi_risk(
        self, weight: float, height: float
    ) -> Tuple[float, List[str]]:
        """
        BMI clinical risk:
          < 16    → 0.12  (severe underweight — malnutrition / eating disorder)
          16–18.4 → 0.07  (underweight)
          18.5–24.9 → 0.00 (normal — no extra risk)
          25–29.9 → 0.04  (overweight — mild cardiometabolic risk)
          30–34.9 → 0.07  (obese class I)
          35–39.9 → 0.10  (obese class II — significant comorbidity risk)
          ≥ 40    → 0.12  (obese class III / morbid obesity)
        """
        height_m = height / 100.0
        bmi = weight / (height_m ** 2)

        if bmi < 16.0:
            return 0.12, [f"Severe underweight (BMI {bmi:.1f}) — malnutrition risk"]
        if bmi < 18.5:
            return 0.07, [f"Underweight (BMI {bmi:.1f}) — nutritional vulnerability"]
        if bmi < 25.0:
            return 0.00, []
        if bmi < 30.0:
            return 0.04, [f"Overweight (BMI {bmi:.1f}) — mild cardiometabolic risk"]
        if bmi < 35.0:
            return 0.07, [f"Obese class I (BMI {bmi:.1f}) — elevated risk"]
        if bmi < 40.0:
            return 0.10, [f"Obese class II (BMI {bmi:.1f}) — significant risk"]
        return 0.12, [f"Morbid obesity (BMI {bmi:.1f}) — high comorbidity risk"]

    def _assess_duration_risk(
        self, duration: int, severity: int
    ) -> Tuple[float, List[str]]:
        """
        Duration interacts with severity:
          ≤ 3 days (acute)      → 0.03  (could be self-limiting)
          4–7 days              → 0.06  (sub-acute — monitoring needed)
          8–14 days (2 weeks)   → 0.09  (persisting — warrants investigation)
          15–30 days (1 month)  → 0.12  (chronic onset — diagnosis required)
          > 30 days (chronic)   → 0.15  (chronic — active management needed)

        Severe/critical severity with long duration → extra +0.03 flag.
        """
        factors = []
        if duration <= 3:
            score = 0.03
            factors.append(f"Acute onset ({duration} day{'s' if duration != 1 else ''})")
        elif duration <= 7:
            score = 0.06
            factors.append(f"Sub-acute duration ({duration} days) — monitoring advised")
        elif duration <= 14:
            score = 0.09
            factors.append(f"Symptoms persisting {duration} days — medical review recommended")
        elif duration <= 30:
            score = 0.12
            factors.append(f"Prolonged symptoms ({duration} days) — diagnosis investigation warranted")
        else:
            score = 0.15
            factors.append(f"Chronic symptoms ({duration} days) — ongoing management needed")
            if severity >= 3:
                score = min(score + 0.03, 0.15)
                factors.append("Chronic + high severity combination — urgent review")
        return score, factors

    def _assess_conditions_risk(
        self, existing_diseases: List[str]
    ) -> Tuple[float, List[str]]:
        """
        Each known condition contributes its individual clinical weight.
        Total is capped at 0.15 to prevent single-factor domination.
        """
        factors = []
        score = 0.0
        matched_conditions = []

        for disease in existing_diseases:
            d_lower = disease.lower().strip()
            for keyword, weight in HIGH_RISK_CONDITIONS.items():
                if keyword in d_lower:
                    score += weight
                    matched_conditions.append(disease)
                    break
            else:
                # Unknown condition still adds a small base risk
                score += 0.03

        score = min(score, 0.15)

        if len(existing_diseases) == 1:
            factors.append(f"Existing condition: {existing_diseases[0]}")
        elif len(existing_diseases) == 2:
            factors.append(f"2 existing conditions: {', '.join(existing_diseases)}")
        else:
            factors.append(
                f"{len(existing_diseases)} comorbidities "
                f"(e.g. {', '.join(existing_diseases[:2])}…)"
            )
        if matched_conditions:
            factors.append(
                f"High-risk condition(s): {', '.join(set(matched_conditions))}"
            )

        return score, factors

    def _assess_medication_risk(
        self, medications: List[str]
    ) -> Tuple[float, List[str]]:
        """
        Polypharmacy risk:
          1–2 meds         → 0.02
          3–4 meds         → 0.04
          5+  meds         → 0.06  (polypharmacy threshold)
        High-risk med present → +0.02 (capped at 0.08 total).
        """
        factors = []
        count = len(medications)

        if count <= 0:
            return 0.0, []
        if count <= 2:
            base = 0.02
        elif count <= 4:
            base = 0.04
        else:
            base = 0.06
            factors.append(f"Polypharmacy ({count} medications) — drug-interaction risk")

        # Check for high-risk medications
        risky = [
            m for m in medications
            if any(hr in m.lower() for hr in HIGH_RISK_MEDICATIONS)
        ]
        extra = min(len(risky) * 0.02, 0.02)
        total = min(base + extra, 0.08)

        if risky:
            factors.append(
                f"High-risk medication(s): {', '.join(risky[:3])}"
            )
        elif count > 0:
            factors.append(f"{count} current medication(s)")

        return total, factors

    def _get_risk_level(self, risk_score: float) -> str:
        for level, bounds in self.risk_levels.items():
            if bounds["min"] <= risk_score < bounds["max"]:
                return level
        # Edge case: score == 1.0
        return "critical"

    def get_risk_color(self, risk_level: str) -> str:
        return self.risk_levels.get(risk_level, {}).get("color", "gray")

    def is_emergency(self, risk_level: str) -> bool:
        return risk_level == "critical"

    def requires_immediate_attention(self, risk_level: str) -> bool:
        return risk_level in ["high", "critical"]


# ─────────────────────────────────────────────────────────────────────────────
# SeverityAnalyzer (unchanged public API, improved internals)
# ─────────────────────────────────────────────────────────────────────────────

class SeverityAnalyzer:
    """Analyze symptom severity."""

    @staticmethod
    def calculate_severity_score(
        symptom_count: int,
        severity_level: int,
        duration_days: int,
    ) -> float:
        count_score = min(symptom_count / 10, 0.40)
        level_score = max(0.0, (severity_level - 1) / 3) * 0.40
        if duration_days > 30:
            dur_score = 0.20
        elif duration_days > 14:
            dur_score = 0.15
        elif duration_days > 7:
            dur_score = 0.10
        else:
            dur_score = 0.05
        return min(count_score + level_score + dur_score, 1.0)


# ─────────────────────────────────────────────────────────────────────────────
# EmergencyDetector (unchanged)
# ─────────────────────────────────────────────────────────────────────────────

class EmergencyDetector:
    """Detect emergency conditions."""

    def __init__(self):
        self.critical_symptoms = [s.lower() for s in CRITICAL_SYMPTOMS]

    def is_emergency(self, symptoms: List[str]) -> Tuple[bool, List[str]]:
        symptoms_lower = [s.lower() for s in symptoms]
        critical_found = [
            s for s in symptoms_lower
            if any(c in s for c in self.critical_symptoms)
        ]
        return len(critical_found) > 0, critical_found

    def get_emergency_message(self) -> str:
        return (
            "⚠️ EMERGENCY: Your symptoms may indicate a serious medical condition. "
            "Please seek immediate medical attention or call emergency services."
        )
