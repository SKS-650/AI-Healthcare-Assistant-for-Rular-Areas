"""Personalised recommendation engine.

Every patient parameter influences the output:

  age         → paediatric / elderly-specific advice, age-appropriate urgency
  gender      → pregnancy warnings, female/male-specific screening reminders
  BMI         → weight management advice, bariatric referral flags
  duration    → acute self-care vs. chronic specialist referral timelines
  severity    → triage urgency level and specific action list
  existing_diseases → disease-specific follow-up, contraindication warnings
  medications → drug-interaction reminders, allergy cross-checks
  allergies   → explicit contraindication warnings in care advice
"""

from typing import List, Dict, Optional
from ..config.constants import RECOMMENDATIONS
from ..config.config import config


def _bmi(weight: Optional[float], height: Optional[float]) -> Optional[float]:
    if weight and height and height > 0:
        h = height / 100.0
        return weight / (h * h)
    return None


def _bmi_label(bmi: float) -> str:
    if bmi < 16.0:  return "severely underweight"
    if bmi < 18.5:  return "underweight"
    if bmi < 25.0:  return "normal weight"
    if bmi < 30.0:  return "overweight"
    if bmi < 35.0:  return "obese (Class I)"
    if bmi < 40.0:  return "obese (Class II)"
    return "morbidly obese"


class RecommendationEngine:
    """Generate fully personalised medical recommendations."""

    def __init__(self):
        self.recommendations = RECOMMENDATIONS
        self.departments = config.DEPARTMENTS

        self.disease_department_map = {
            "heart attack": "emergency",    "angina": "cardiology",
            "hypertension": "cardiology",   "arrhythmia": "cardiology",
            "heart failure": "cardiology",
            "pneumonia": "respiratory",     "asthma": "respiratory",
            "bronchitis": "respiratory",    "copd": "respiratory",
            "stroke": "emergency",          "migraine": "neurology",
            "epilepsy": "neurology",        "meningitis": "emergency",
            "appendicitis": "emergency",    "gastritis": "gastroenterology",
            "ulcer": "gastroenterology",    "hepatitis": "gastroenterology",
            "diabetes": "endocrinology",    "thyroid": "endocrinology",
            "hyperthyroidism": "endocrinology",
            "eczema": "dermatology",        "psoriasis": "dermatology",
            "fracture": "emergency",        "arthritis": "orthopedics",
            "osteoporosis": "orthopedics",  "sinusitis": "ent",
            "tonsillitis": "ent",           "otitis": "ent",
            "glaucoma": "ophthalmology",    "conjunctivitis": "ophthalmology",
            "covid": "general",             "influenza": "general",
            "malaria": "general",           "dengue": "general",
            "anemia": "general",            "obesity": "endocrinology",
        }

    # ── Public entry point ────────────────────────────────────────────────────

    def generate_recommendations(
        self,
        disease: str,
        risk_level: str,
        confidence: float,
        symptoms: Optional[List[str]] = None,
        # ── Patient profile (all optional for backward-compat) ──────────────
        age: Optional[int] = None,
        gender: Optional[str] = None,
        weight: Optional[float] = None,
        height: Optional[float] = None,
        duration: Optional[int] = None,
        severity: int = 1,
        existing_diseases: Optional[List[str]] = None,
        medications: Optional[List[str]] = None,
        allergies: Optional[List[str]] = None,
    ) -> Dict:

        symptoms        = symptoms        or []
        existing_diseases = existing_diseases or []
        medications     = medications     or []
        allergies       = allergies       or []

        bmi_val   = _bmi(weight, height)
        dept      = self._get_department(disease)
        base_rec  = self.recommendations.get(risk_level, self.recommendations["medium"])

        actions     = self._build_actions(
            risk_level, disease, age, gender, bmi_val,
            duration, severity, existing_diseases, medications, allergies)

        care_advice = self._build_care_advice(
            disease, risk_level, symptoms, age, gender, bmi_val,
            duration, existing_diseases, medications, allergies)

        follow_up   = self._build_follow_up(
            risk_level, confidence, age, duration, existing_diseases)

        return {
            "risk_level":       risk_level,
            "primary_action":   base_rec["action"],
            "department":       self.departments.get(dept, "General Medicine"),
            "department_code":  dept,
            "actions":          actions,
            "care_advice":      care_advice,
            "follow_up":        follow_up,
            "urgency":          self._urgency(risk_level, age, existing_diseases),
            "emergency_contact": risk_level == "critical",
        }

    # ── Actions ───────────────────────────────────────────────────────────────

    def _build_actions(
        self,
        risk_level: str,
        disease: str,
        age: Optional[int],
        gender: Optional[str],
        bmi: Optional[float],
        duration: Optional[int],
        severity: int,
        conditions: List[str],
        medications: List[str],
        allergies: List[str],
    ) -> List[str]:
        actions: List[str] = []

        # ── Base triage action ────────────────────────────────────────────────
        if risk_level == "critical":
            actions += [
                "🚨 Call emergency services (911 / 108) immediately",
                "Do not drive — ask someone to accompany you",
                "Go to the nearest Emergency Department now",
                "Alert a family member or neighbour",
            ]
        elif risk_level == "high":
            actions += [
                "Visit a hospital Emergency or Urgent Care unit today",
                "Do not postpone — same-day evaluation is essential",
                "Bring a complete list of your medications and allergies",
            ]
        elif risk_level == "medium":
            timeline = "within 24–48 hours" if severity >= 3 else "within 2–3 days"
            actions += [
                f"Schedule a doctor's appointment {timeline}",
                "Keep a symptom diary noting time, triggers, and changes",
                "Prepare your full medication list for the consultation",
            ]
        else:  # low
            watch = "5 days" if (duration or 0) > 7 else "7 days"
            actions += [
                f"Monitor symptoms for the next {watch}",
                "Rest adequately and maintain hydration",
                "Seek medical advice if symptoms worsen or new ones appear",
            ]

        # ── Age-specific actions ──────────────────────────────────────────────
        if age is not None:
            if age < 5:
                actions.append(
                    "⚠️ Child under 5 — paediatric assessment is strongly advised "
                    "even for mild symptoms"
                )
            elif age < 12:
                actions.append(
                    "Consult a paediatrician; children may deteriorate faster than adults"
                )
            elif age >= 75:
                actions.append(
                    "Advanced age — arrange transport and take a carer/family member "
                    "to the appointment"
                )
            elif age >= 65:
                actions.append(
                    "Elderly patient — consider same-day review even for moderate risk"
                )

        # ── BMI-specific actions ──────────────────────────────────────────────
        if bmi is not None:
            if bmi >= 40:
                actions.append(
                    f"BMI {bmi:.1f} (morbidly obese) — discuss weight-management "
                    "referral with your doctor"
                )
            elif bmi >= 30:
                actions.append(
                    f"BMI {bmi:.1f} (obese) — obesity increases risk for this condition; "
                    "mention it at consultation"
                )
            elif bmi < 16:
                actions.append(
                    f"BMI {bmi:.1f} (severely underweight) — nutritional assessment "
                    "recommended alongside treatment"
                )
            elif bmi < 18.5:
                actions.append(
                    f"BMI {bmi:.1f} (underweight) — inform your doctor; "
                    "nutritional support may be needed"
                )

        # ── Duration-specific actions ─────────────────────────────────────────
        if duration is not None:
            if duration > 30:
                actions.append(
                    f"Symptoms lasting {duration} days — chronic presentation; "
                    "ask for specialist referral if not already investigated"
                )
            elif duration > 14:
                actions.append(
                    f"Symptoms lasting {duration} days — investigations "
                    "(blood tests, imaging) may be required"
                )

        # ── Allergy warnings ──────────────────────────────────────────────────
        if allergies:
            actions.append(
                f"⚠️ Known allergies ({', '.join(allergies[:3])}) — "
                "always inform medical staff before any treatment"
            )

        # ── Gender-specific actions ───────────────────────────────────────────
        if gender == "female" and age and 15 <= age <= 50:
            actions.append(
                "Inform your doctor if there is any possibility of pregnancy "
                "before imaging or certain medications"
            )

        # ── High-risk condition actions ───────────────────────────────────────
        cond_lower = " ".join(c.lower() for c in conditions)
        if "diabetes" in cond_lower:
            actions.append(
                "Diabetic patient — check blood glucose before and after any "
                "new medication is started"
            )
        if any(k in cond_lower for k in ("heart", "cardiac", "coronary", "arrhythmia")):
            actions.append(
                "Cardiac history — bring your ECG reports and cardiology letters "
                "to the appointment"
            )
        if any(k in cond_lower for k in ("kidney", "renal")):
            actions.append(
                "Renal condition — remind the treating doctor; dose adjustments "
                "are often needed"
            )
        if any(k in cond_lower for k in ("cancer", "tumor", "leukemia", "lymphoma")):
            actions.append(
                "Oncology history — contact your oncologist for guidance before "
                "starting any new medication"
            )

        # ── Polypharmacy reminder ─────────────────────────────────────────────
        if len(medications) >= 5:
            actions.append(
                f"Polypharmacy ({len(medications)} medications) — request a "
                "medication-review from your pharmacist or GP"
            )

        return actions

    # ── Care advice ───────────────────────────────────────────────────────────

    def _build_care_advice(
        self,
        disease: str,
        risk_level: str,
        symptoms: List[str],
        age: Optional[int],
        gender: Optional[str],
        bmi: Optional[float],
        duration: Optional[int],
        conditions: List[str],
        medications: List[str],
        allergies: List[str],
    ) -> List[str]:

        if risk_level == "critical":
            return [
                "Do not attempt home treatment for a critical condition",
                "Keep the patient calm and still",
                "Loosen tight clothing and ensure fresh air",
                "Stay on the line with emergency services until help arrives",
            ]

        advice: List[str] = []

        # ── General fundamentals ──────────────────────────────────────────────
        advice += [
            "Rest adequately — allow your body to recover",
            "Stay well hydrated (2–3 litres of water per day unless restricted)",
        ]

        # ── Disease-specific ─────────────────────────────────────────────────
        d = disease.lower()
        if any(k in d for k in ("fever", "flu", "influenza", "viral")):
            advice += [
                "Take paracetamol for fever (follow package dose instructions)",
                "Apply cool damp cloth to forehead for high fever",
                "Avoid contact with vulnerable people while feverish",
            ]
        if any(k in d for k in ("cough", "respiratory", "bronch", "asthm", "copd")):
            advice += [
                "Use steam inhalation to loosen airways",
                "Keep the head elevated during sleep",
                "Avoid cold air, smoke, and strong odours",
            ]
        if any(k in d for k in ("gastrit", "ulcer", "acid", "reflux", "indigestion")):
            advice += [
                "Eat small, frequent, bland meals",
                "Avoid spicy food, alcohol, and NSAIDs (ibuprofen, aspirin)",
                "Do not lie down immediately after eating",
            ]
        if any(k in d for k in ("migraine", "headache")):
            advice += [
                "Rest in a quiet, darkened room",
                "Apply a cold pack to the forehead or neck",
                "Avoid screens and bright lights during an attack",
            ]
        if any(k in d for k in ("diabet", "glucose", "insulin")):
            advice += [
                "Monitor blood glucose levels regularly",
                "Maintain consistent meal timing",
                "Carry fast-acting glucose in case of hypoglycaemia",
            ]
        if any(k in d for k in ("arthrit", "joint", "ortho", "bone")):
            advice += [
                "Apply heat or cold packs to affected joints as needed",
                "Gentle range-of-motion exercises can relieve stiffness",
                "Avoid overloading affected joints",
            ]

        # ── BMI-specific care ─────────────────────────────────────────────────
        if bmi is not None:
            if bmi >= 30:
                advice.append(
                    f"Your BMI ({bmi:.1f} — {_bmi_label(bmi)}) increases risk; "
                    "a modest weight reduction of 5–10 % significantly reduces "
                    "cardiovascular and metabolic risk"
                )
            elif bmi < 18.5:
                advice.append(
                    f"Your BMI ({bmi:.1f} — {_bmi_label(bmi)}) suggests nutritional "
                    "deficiency; ensure adequate protein and micronutrient intake"
                )

        # ── Duration-specific care ────────────────────────────────────────────
        if duration is not None:
            if duration > 14:
                advice.append(
                    f"With symptoms lasting {duration} days, self-care alone is "
                    "unlikely to be sufficient — professional assessment is advised"
                )
            elif duration <= 3:
                advice.append(
                    "Symptoms are recent — initial self-care and monitoring are "
                    "appropriate if risk is low"
                )

        # ── Age-specific care ─────────────────────────────────────────────────
        if age is not None:
            if age < 5:
                advice.append(
                    "For children under 5, use only age-appropriate dosing; "
                    "never give aspirin to children"
                )
            elif age >= 65:
                advice.append(
                    "Elderly patients are more sensitive to medication side effects — "
                    "start at lowest effective dose"
                )

        # ── Allergy contraindications ─────────────────────────────────────────
        if allergies:
            allergy_str = ", ".join(allergies[:5])
            advice.append(
                f"⚠️ Allergy alert — do NOT take {allergy_str} or related compounds; "
                "always disclose this list to any treating clinician or pharmacist"
            )

        # ── Medication-specific care ──────────────────────────────────────────
        med_lower = " ".join(m.lower() for m in medications)
        if any(k in med_lower for k in ("warfarin", "heparin", "clopidogrel")):
            advice.append(
                "⚠️ On anticoagulant therapy — avoid NSAIDs and aspirin; "
                "report any unusual bruising or bleeding to your doctor"
            )
        if any(k in med_lower for k in ("steroid", "prednisone", "dexamethasone")):
            advice.append(
                "On corticosteroid therapy — do not stop abruptly; "
                "monitor blood pressure and blood glucose"
            )
        if any(k in med_lower for k in ("insulin", "metformin", "glipizide")):
            advice.append(
                "Antidiabetic medication on board — monitor glucose closely "
                "during any illness; illness can destabilise glucose control"
            )

        # ── Chronic condition care ────────────────────────────────────────────
        cond_lower = " ".join(c.lower() for c in conditions)
        if "hypertension" in cond_lower or "high blood pressure" in cond_lower:
            advice.append(
                "Monitor your blood pressure daily during this illness; "
                "stress and illness commonly raise BP"
            )
        if "asthma" in cond_lower or "copd" in cond_lower:
            advice.append(
                "Keep your rescue inhaler accessible at all times; "
                "viral illness often triggers exacerbations"
            )

        return advice

    # ── Follow-up ─────────────────────────────────────────────────────────────

    def _build_follow_up(
        self,
        risk_level: str,
        confidence: float,
        age: Optional[int],
        duration: Optional[int],
        conditions: List[str],
    ) -> Dict:
        # Base timelines
        base = {
            "critical": ("Immediate",    "Emergency evaluation required"),
            "high":     ("Within 24 h",  "Urgent medical evaluation"),
            "medium":   ("Within 2–3 days", "Schedule GP / specialist appointment"),
            "low":      ("7 days if no improvement", "Monitor; consult if symptoms persist"),
        }
        when, action = base.get(risk_level, ("Within 2–3 days", "See a doctor"))

        # Shorten follow-up for high-risk profiles
        notes = []
        if age is not None and (age < 5 or age >= 75):
            notes.append("Earlier review recommended due to age")
        if (duration or 0) > 14:
            notes.append(f"Symptoms already lasting {duration} days — expedite review")
        if len(conditions) >= 3:
            notes.append("Multiple comorbidities — proactive monitoring advised")
        if confidence < 0.15:
            notes.append(
                "Low model confidence — differential diagnosis is broad; "
                "thorough clinical evaluation is particularly important"
            )

        monitoring = (
            "Continuous medical supervision" if risk_level == "critical"
            else "Check for new symptoms, worsening intensity, or spread daily"
        )

        result = {
            "when":       when,
            "action":     action,
            "monitoring": monitoring,
        }
        if notes:
            result["notes"] = notes
        return result

    # ── Urgency ───────────────────────────────────────────────────────────────

    def _urgency(
        self,
        risk_level: str,
        age: Optional[int],
        conditions: List[str],
    ) -> str:
        base_map = {
            "critical": "IMMEDIATE — Emergency",
            "high":     "URGENT — Same day",
            "medium":   "Moderate — Within 2–3 days",
            "low":      "Routine — Monitor and consult if needed",
        }
        urgency = base_map.get(risk_level, "Moderate — Within 2–3 days")

        # Escalate for vulnerable groups
        if risk_level in ("low", "medium"):
            if age is not None and (age < 5 or age >= 75):
                urgency = urgency.replace("Routine", "Elevated-routine").replace(
                    "Moderate", "Moderate-elevated"
                )
            if any(
                k in " ".join(c.lower() for c in conditions)
                for k in ("cancer", "hiv", "aids", "renal failure", "heart failure")
            ):
                urgency += " (escalated — high-risk comorbidity)"

        return urgency

    # ── Department lookup ─────────────────────────────────────────────────────

    def _get_department(self, disease: str) -> str:
        d = disease.lower()
        for key, dept in self.disease_department_map.items():
            if key in d:
                return dept
        return "general"
