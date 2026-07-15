"""Emergency module constants."""

from __future__ import annotations


class RiskLevel:
    LOW      = "LOW"
    MODERATE = "MODERATE"
    HIGH     = "HIGH"
    CRITICAL = "CRITICAL"


class EmergencyCategory:
    CARDIAC          = "cardiac"
    STROKE           = "stroke"
    RESPIRATORY      = "respiratory"
    SEVERE_BLEEDING  = "severe_bleeding"
    POISONING        = "poisoning"
    OVERDOSE         = "overdose"
    SNAKEBITE        = "snakebite"
    UNCONSCIOUS      = "unconscious"
    HIGH_FEVER       = "high_fever"
    SEVERE_ALLERGY   = "severe_allergy"
    CHOKING          = "choking"
    TRAUMA           = "trauma"
    PREGNANCY        = "pregnancy_emergency"
    PEDIATRIC        = "pediatric_emergency"
    SEPSIS           = "sepsis"
    SUICIDE_RISK     = "suicide_risk"
    GENERAL          = "general_emergency"


RISK_SCORE_RANGES = {
    RiskLevel.LOW:      (0,  25),
    RiskLevel.MODERATE: (26, 50),
    RiskLevel.HIGH:     (51, 75),
    RiskLevel.CRITICAL: (76, 100),
}

RISK_LEVEL_COLORS = {
    RiskLevel.LOW:      "#2ECC8B",
    RiskLevel.MODERATE: "#FFB829",
    RiskLevel.HIGH:     "#FF7B3D",
    RiskLevel.CRITICAL: "#FF4757",
}

RISK_LEVEL_EMOJI = {
    RiskLevel.LOW:      "🟢",
    RiskLevel.MODERATE: "🟡",
    RiskLevel.HIGH:     "🟠",
    RiskLevel.CRITICAL: "🔴",
}

EMERGENCY_NUMBERS = {
    "ambulance":    "102",
    "police":       "100",
    "fire":         "101",
    "disaster":     "108",
    "health":       "104",
    "women":        "1091",
    "child":        "1098",
    "mental_health":"9152987821",
}

MAX_EMERGENCY_CONTACTS = 5
SOS_COOLDOWN_SECONDS   = 30   # prevent accidental double-SOS
