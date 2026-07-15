"""
Emergency Rule Engine — deterministic, rule-based detection.

This layer runs BEFORE any ML model.  Medical emergencies must never
be delayed by model cold-start or inference latency, so rules are
evaluated in pure Python with zero external dependencies.

Rule structure:
  Each rule contains:
  - category       : EmergencyCategory enum value
  - risk_level     : RiskLevel (LOW / MODERATE / HIGH / CRITICAL)
  - keywords       : list of exact lowercase substrings
  - symptom_combos : list of symptom-pair/triple tuples → triggers if ALL present
  - age_factors    : min_age / max_age thresholds that ELEVATE severity
  - score_weight   : how much this rule contributes to the risk score (0–100)
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional, Tuple


# ─── Enumerations ─────────────────────────────────────────────────────────────

class EmergencyCategory(str, Enum):
    CARDIAC         = "cardiac"
    STROKE          = "stroke"
    RESPIRATORY     = "respiratory"
    SEVERE_BLEEDING = "severe_bleeding"
    POISONING       = "poisoning"
    OVERDOSE        = "overdose"
    SNAKEBITE       = "snakebite"
    UNCONSCIOUS     = "unconscious"
    HIGH_FEVER      = "high_fever"
    SEVERE_ALLERGY  = "severe_allergy"
    CHOKING         = "choking"
    DROWNING        = "drowning"
    TRAUMA          = "trauma"
    PREGNANCY       = "pregnancy_emergency"
    PEDIATRIC       = "pediatric_emergency"
    SEPSIS          = "sepsis"
    SUICIDE_RISK    = "suicide_risk"
    GENERAL         = "general_emergency"


class RiskLevel(str, Enum):
    LOW      = "LOW"        # 0-25   — home care
    MODERATE = "MODERATE"   # 26-50  — doctor visit
    HIGH     = "HIGH"       # 51-75  — hospital now
    CRITICAL = "CRITICAL"   # 76-100 — call ambulance immediately


# ─── Rule dataclass ───────────────────────────────────────────────────────────

@dataclass
class EmergencyRule:
    category:       EmergencyCategory
    risk_level:     RiskLevel
    keywords:       List[str]                        = field(default_factory=list)
    symptom_combos: List[Tuple[str, ...]]            = field(default_factory=list)
    min_age:        Optional[int]                    = None   # elevate if age >= min_age
    max_age:        Optional[int]                    = None   # elevate if age <= max_age
    score_weight:   int                              = 60     # base score contribution


# ─── Rule bank ────────────────────────────────────────────────────────────────

EMERGENCY_RULES: List[EmergencyRule] = [

    # ── Cardiac ──────────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.CARDIAC,
        risk_level=RiskLevel.CRITICAL,
        score_weight=90,
        keywords=[
            "heart attack", "cardiac arrest", "chest pain severe",
            "crushing chest", "chest pressure", "chest tightness",
            "left arm pain", "jaw pain heart", "heart stopped",
            "dil ka dora", "dil band", "seena dard",
        ],
        symptom_combos=[
            ("chest pain", "difficulty breathing"),
            ("chest pain", "sweating"),
            ("chest pain", "nausea"),
            ("chest pain", "left arm"),
            ("chest pain", "jaw pain"),
        ],
        min_age=40,
    ),

    # ── Stroke ───────────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.STROKE,
        risk_level=RiskLevel.CRITICAL,
        score_weight=92,
        keywords=[
            "stroke", "brain attack", "face drooping", "facial drooping",
            "arm weakness", "speech slurred", "sudden numbness",
            "sudden severe headache", "worst headache of my life",
            "paralysis", "one side weak", "can't speak", "loss of balance",
        ],
        symptom_combos=[
            ("face drooping", "arm weakness"),
            ("face drooping", "speech"),
            ("arm weakness", "speech difficulty"),
            ("sudden headache", "vision"),
            ("sudden numbness", "confusion"),
        ],
    ),

    # ── Respiratory ──────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.RESPIRATORY,
        risk_level=RiskLevel.CRITICAL,
        score_weight=88,
        keywords=[
            "can't breathe", "cannot breathe", "difficulty breathing",
            "stopped breathing", "no breathing", "suffocating",
            "bluish lips", "blue lips", "cyanosis",
            "respiratory failure", "saans nahi", "saans band",
        ],
        symptom_combos=[
            ("difficulty breathing", "wheezing"),
            ("difficulty breathing", "blue lips"),
            ("shortness of breath", "chest pain"),
            ("rapid breathing", "confusion"),
        ],
    ),

    # ── Severe Bleeding ──────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.SEVERE_BLEEDING,
        risk_level=RiskLevel.CRITICAL,
        score_weight=85,
        keywords=[
            "severe bleeding", "bleeding heavily", "bleeding won't stop",
            "blood everywhere", "spurting blood", "arterial bleed",
            "khoon nahi ruk raha", "bahut khoon",
            "uncontrolled bleeding",
        ],
        symptom_combos=[
            ("bleeding", "unconscious"),
            ("bleeding", "pale"),
        ],
    ),

    # ── Poisoning ────────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.POISONING,
        risk_level=RiskLevel.CRITICAL,
        score_weight=87,
        keywords=[
            "poisoning", "swallowed poison", "ingested chemical",
            "rat poison", "household cleaner", "zeher kha liya",
            "pesticide ingested", "chemical poisoning",
        ],
        symptom_combos=[
            ("vomiting", "confusion", "chemical"),
            ("seizures", "vomiting"),
        ],
    ),

    # ── Overdose ─────────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.OVERDOSE,
        risk_level=RiskLevel.CRITICAL,
        score_weight=90,
        keywords=[
            "overdose", "too many pills", "too much medicine",
            "drug overdose", "medicine overdose", "dawai zyada",
            "tablet zyada kha li",
        ],
        symptom_combos=[
            ("pills", "unconscious"),
            ("medicine", "not breathing"),
        ],
    ),

    # ── Snakebite ────────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.SNAKEBITE,
        risk_level=RiskLevel.CRITICAL,
        score_weight=88,
        keywords=[
            "snake bite", "snakebite", "bitten by snake", "snake attack",
            "saap ne kata", "saanp ka daank",
        ],
        symptom_combos=[
            ("bite", "swelling", "snake"),
            ("bite marks", "breathing problems"),
        ],
    ),

    # ── Unconscious ──────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.UNCONSCIOUS,
        risk_level=RiskLevel.CRITICAL,
        score_weight=95,
        keywords=[
            "unconscious", "not responding", "passed out", "unresponsive",
            "won't wake up", "cannot wake", "behosh", "hosh nahi",
        ],
    ),

    # ── High Fever ───────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.HIGH_FEVER,
        risk_level=RiskLevel.HIGH,
        score_weight=72,
        keywords=[
            "very high fever", "fever 40", "fever 41", "fever 42",
            "temperature 104", "temperature 105", "febrile seizure",
            "104 fever", "105 fever", "bukhar bahut tej",
        ],
        symptom_combos=[
            ("high fever", "seizure"),
            ("high fever", "confusion"),
            ("fever", "stiff neck"),
        ],
        max_age=5,   # pediatric — more severe
    ),

    # ── Severe Allergy / Anaphylaxis ─────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.SEVERE_ALLERGY,
        risk_level=RiskLevel.CRITICAL,
        score_weight=90,
        keywords=[
            "anaphylaxis", "anaphylactic shock", "throat closing",
            "tongue swelling", "throat swelling", "epipen",
            "severe allergic reaction",
        ],
        symptom_combos=[
            ("throat closing", "difficulty breathing"),
            ("swollen tongue", "difficulty breathing"),
            ("allergy", "difficulty breathing", "hives"),
        ],
    ),

    # ── Choking ──────────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.CHOKING,
        risk_level=RiskLevel.CRITICAL,
        score_weight=88,
        keywords=[
            "choking", "something stuck in throat", "food stuck throat",
            "airway blocked", "gala band", "cannot swallow",
        ],
    ),

    # ── Trauma / Accidents ───────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.TRAUMA,
        risk_level=RiskLevel.HIGH,
        score_weight=80,
        keywords=[
            "road accident", "car accident", "severe head injury",
            "skull fracture", "internal bleeding", "bone protruding",
            "spinal injury", "hit by vehicle",
        ],
        symptom_combos=[
            ("accident", "unconscious"),
            ("head injury", "confusion"),
            ("accident", "severe bleeding"),
        ],
    ),

    # ── Pregnancy Emergencies ─────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.PREGNANCY,
        risk_level=RiskLevel.HIGH,
        score_weight=82,
        keywords=[
            "eclampsia", "heavy bleeding pregnancy", "pregnancy emergency",
            "severe abdominal pain pregnancy", "premature labor",
            "convulsions pregnancy",
        ],
        symptom_combos=[
            ("pregnancy", "heavy bleeding"),
            ("pregnant", "convulsion"),
            ("pregnant", "severe headache", "high blood pressure"),
        ],
    ),

    # ── Sepsis ───────────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.SEPSIS,
        risk_level=RiskLevel.HIGH,
        score_weight=78,
        keywords=[
            "sepsis", "blood poisoning", "septicemia",
        ],
        symptom_combos=[
            ("high fever", "rapid heartbeat", "confusion"),
            ("fever", "low blood pressure", "rapid breathing"),
        ],
    ),

    # ── Suicide Risk ─────────────────────────────────────────────────────────
    EmergencyRule(
        category=EmergencyCategory.SUICIDE_RISK,
        risk_level=RiskLevel.HIGH,
        score_weight=85,
        keywords=[
            "want to die", "kill myself", "end my life", "suicide",
            "self harm", "cut myself", "marna chahta",
        ],
    ),
]


# ─── Convenience lookup ───────────────────────────────────────────────────────

RULES_BY_CATEGORY: dict[EmergencyCategory, EmergencyRule] = {
    r.category: r for r in EMERGENCY_RULES
}

# All keywords flattened for rapid pre-filter
ALL_EMERGENCY_KEYWORDS: frozenset[str] = frozenset(
    kw for rule in EMERGENCY_RULES for kw in rule.keywords
)


def get_risk_score_range(level: RiskLevel) -> tuple[int, int]:
    """Return (min, max) score for a given risk level."""
    return {
        RiskLevel.LOW:      (0,  25),
        RiskLevel.MODERATE: (26, 50),
        RiskLevel.HIGH:     (51, 75),
        RiskLevel.CRITICAL: (76, 100),
    }[level]


def score_to_risk_level(score: int) -> RiskLevel:
    if score <= 25:
        return RiskLevel.LOW
    elif score <= 50:
        return RiskLevel.MODERATE
    elif score <= 75:
        return RiskLevel.HIGH
    return RiskLevel.CRITICAL
