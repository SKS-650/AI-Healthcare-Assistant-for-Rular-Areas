"""
Severity Estimator — calculates a 0-100 risk score from structured input.

Scoring factors:
  - matched emergency rule weight      (up to 40 pts)
  - symptom count                      (up to 20 pts)
  - symptom severity level             (up to 15 pts)
  - duration of symptoms               (up to 10 pts)
  - existing diseases / comorbidities  (up to 10 pts)
  - age risk factor                    (up to 5 pts)

Total ceiling: 100.  Score is then mapped to a RiskLevel.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import List, Optional

from ai_models.emergency_detection.emergency_rules import (
    EmergencyCategory,
    RiskLevel,
    score_to_risk_level,
)


# ─── Input dataclass ─────────────────────────────────────────────────────────

@dataclass
class SeverityInput:
    """All patient and symptom data fed into the severity estimator."""

    # Rule result
    matched_category:   Optional[EmergencyCategory] = None
    rule_score_weight:  int                          = 0     # 0-100 from rule

    # Symptoms
    symptom_count:      int                          = 0
    severity_level:     int                          = 1     # 1 (mild) – 5 (extreme)

    # Duration in hours
    duration_hours:     float                        = 0.0

    # Medical history flags
    has_cardiac_history:    bool = False
    has_diabetes:           bool = False
    has_hypertension:       bool = False
    has_respiratory_disease:bool = False
    is_immunocompromised:   bool = False
    is_pregnant:            bool = False

    # Demographics
    age:    Optional[int] = None
    weight: Optional[float] = None   # kg (used for pediatric assessment)

    # Context flags
    recent_accident:  bool = False
    recent_surgery:   bool = False
    recent_travel:    bool = False
    snake_bite:       bool = False
    exposure_to_poison: bool = False

    # Override — set by rule engine for combo triggers
    combo_triggered:  bool = False


@dataclass
class SeverityResult:
    score:       int
    risk_level:  RiskLevel
    breakdown:   dict = field(default_factory=dict)


# ─── Scorer ──────────────────────────────────────────────────────────────────

def estimate_severity(inp: SeverityInput) -> SeverityResult:
    """
    Compute a 0-100 risk score and map it to a RiskLevel.

    All contributions are additive and capped at their individual ceiling.
    """
    breakdown: dict[str, int] = {}

    # 1. Rule match contribution (0-40 pts)
    if inp.rule_score_weight > 0:
        rule_pts = int(inp.rule_score_weight * 0.40)
    elif inp.matched_category is not None:
        rule_pts = 30  # fallback for unscored rule hits
    else:
        rule_pts = 0
    rule_pts = min(rule_pts, 40)
    breakdown["rule_match"] = rule_pts

    # 2. Symptom count contribution (0-20 pts)
    # 1 symptom = 5, 2 = 9, 3 = 13, 4 = 16, 5+ = 20
    symptom_pts = min(20, max(0, int(inp.symptom_count * 4.5) - 0))
    breakdown["symptom_count"] = symptom_pts

    # 3. Severity level contribution (0-15 pts)
    # severity 1 → 3 pts, severity 5 → 15 pts
    severity_pts = max(0, min(15, (inp.severity_level - 1) * 3 + 3))
    breakdown["symptom_severity"] = severity_pts

    # 4. Duration contribution (0-10 pts)
    # >24 h = 10, 12-24 h = 7, 6-12 h = 5, 2-6 h = 3, < 2 h = 1
    if inp.duration_hours >= 24:
        duration_pts = 10
    elif inp.duration_hours >= 12:
        duration_pts = 7
    elif inp.duration_hours >= 6:
        duration_pts = 5
    elif inp.duration_hours >= 2:
        duration_pts = 3
    else:
        duration_pts = 1
    breakdown["duration"] = duration_pts

    # 5. Comorbidity contribution (0-10 pts)
    comorbidity_pts = 0
    if inp.has_cardiac_history:     comorbidity_pts += 3
    if inp.has_diabetes:            comorbidity_pts += 2
    if inp.has_hypertension:        comorbidity_pts += 2
    if inp.has_respiratory_disease: comorbidity_pts += 2
    if inp.is_immunocompromised:    comorbidity_pts += 2
    if inp.is_pregnant:             comorbidity_pts += 1
    comorbidity_pts = min(comorbidity_pts, 10)
    breakdown["comorbidities"] = comorbidity_pts

    # 6. Age contribution (0-5 pts)
    age_pts = 0
    if inp.age is not None:
        if inp.age < 2 or inp.age > 80:
            age_pts = 5
        elif inp.age < 5 or inp.age > 65:
            age_pts = 3
        elif inp.age > 50:
            age_pts = 1
    breakdown["age"] = age_pts

    # 7. Context flags bonus (0-5 pts)
    context_pts = 0
    if inp.recent_accident:     context_pts += 2
    if inp.recent_surgery:      context_pts += 1
    if inp.snake_bite:          context_pts += 3
    if inp.exposure_to_poison:  context_pts += 2
    context_pts = min(context_pts, 5)
    breakdown["context_flags"] = context_pts

    # 8. Combo trigger bonus — bump score into HIGH territory at minimum
    combo_pts = 10 if inp.combo_triggered else 0
    breakdown["combo_trigger"] = combo_pts

    # Total
    total = (
        rule_pts + symptom_pts + severity_pts + duration_pts
        + comorbidity_pts + age_pts + context_pts + combo_pts
    )
    score = max(0, min(100, total))
    breakdown["total"] = score

    return SeverityResult(
        score=score,
        risk_level=score_to_risk_level(score),
        breakdown=breakdown,
    )


def quick_severity(symptom_count: int, has_emergency_signal: bool) -> int:
    """
    Lightweight shim kept for backward compatibility.
    Returns a severity on a 1–10 scale.
    """
    if has_emergency_signal:
        return 10
    return max(1, min(10, symptom_count * 2))
