"""
Emergency Detector - Identifies life-threatening medical situations in real time.

Multi-tier detection:
  Tier 1 — Exact keyword match (fastest, highest precision)
  Tier 2 — Pattern / symptom combination rules
  Tier 3 — Severity score accumulation

Returns a structured EmergencyResult with category, severity, and a
ready-to-send multilingual warning message.
"""

from __future__ import annotations

import logging
import re
from dataclasses import dataclass, field
from enum import Enum
from typing import Dict, List, Optional, Tuple

logger = logging.getLogger(__name__)


# ─── Emergency Categories ────────────────────────────────────────────────────

class EmergencyCategory(str, Enum):
    CARDIAC       = "cardiac"
    STROKE        = "stroke"
    RESPIRATORY   = "respiratory"
    SEVERE_BLEED  = "severe_bleeding"
    POISONING     = "poisoning"
    OVERDOSE      = "overdose"
    SNAKEBITE     = "snakebite"
    UNCONSCIOUS   = "unconscious"
    HIGH_FEVER    = "high_fever"
    SEVERE_ALLERGY= "severe_allergy"
    DROWNING      = "drowning"
    CHOKING       = "choking"
    SUICIDE       = "suicide_ideation"
    GENERAL       = "general_emergency"


class EmergencySeverity(str, Enum):
    CRITICAL  = "critical"   # Life-threatening, call 108 immediately
    HIGH      = "high"       # Very urgent, go to ER now
    MODERATE  = "moderate"   # Needs prompt medical attention


# ─── Keyword Banks ───────────────────────────────────────────────────────────

_EMERGENCY_RULES: Dict[EmergencyCategory, Dict] = {
    EmergencyCategory.CARDIAC: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "heart attack", "cardiac arrest", "chest pain severe",
            "crushing chest", "chest pressure", "left arm pain",
            "jaw pain heart", "heart stopped", "dil ka dora",
            "dil band", "seena dard", "heart fail",
        ],
        "patterns": [
            r"chest\s*(pain|pressure|tight|heaviness)",
            r"heart\s*(attack|arrest|stop|fail)",
            r"left\s+arm\s+(pain|numb)",
        ],
    },
    EmergencyCategory.STROKE: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "stroke", "brain attack", "face drooping", "arm weakness",
            "speech slurred", "sudden numbness", "sudden confusion",
            "sudden vision loss", "sudden severe headache",
            "paralysis", "one side weak",
        ],
        "patterns": [
            r"(face|arm|leg)\s+(drooping|numb|weak|paralys)",
            r"sudden\s+(numbness|confusion|vision|headache|weakness)",
            r"can.t\s+(speak|talk|move)",
            r"slurred?\s+speech",
        ],
    },
    EmergencyCategory.RESPIRATORY: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "can't breathe", "cannot breathe", "difficulty breathing",
            "stopped breathing", "no breathing", "suffocating",
            "choke", "airway blocked", "sans nahi aa raha",
            "saans band", "breathing stopped",
        ],
        "patterns": [
            r"(can.t|cannot|hard to|trouble|difficulty|unable to)\s+breath",
            r"breath(ing)?\s+(stop|block|fail|no|zero)",
            r"oxygen\s+(low|drop|zero)",
        ],
    },
    EmergencyCategory.SEVERE_BLEED: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "severe bleeding", "bleeding heavily", "bleeding won't stop",
            "blood everywhere", "spurting blood", "arterial bleed",
            "khoon nahi ruk raha", "bahut khoon",
        ],
        "patterns": [
            r"bleed(ing)?\s+(heavy|severe|lot|won.t stop|not stop)",
            r"(blood|khoon)\s+(everywhere|spurting|pouring)",
        ],
    },
    EmergencyCategory.POISONING: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "poisoning", "swallowed poison", "ingested chemical",
            "rat poison", "household cleaner ingested", "zeher kha liya",
            "zeher pi liya", "pesticide ingested",
        ],
        "patterns": [
            r"(swallow|drink|eat|ingest|consume)\w*\s+(poison|chemical|bleach|acid)",
            r"zeher\s+(kha|pi)",
        ],
    },
    EmergencyCategory.OVERDOSE: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "overdose", "took too many pills", "too much medicine",
            "drug overdose", "medicine overdose", "dawai zyada le li",
            "tablet zyada kha li",
        ],
        "patterns": [
            r"(took?|taken|consumed?)\s+(too many|too much|overdose)",
            r"over\s*dose",
        ],
    },
    EmergencyCategory.SNAKEBITE: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "snake bite", "snakebite", "bitten by snake", "snake attack",
            "saap ne kata", "saanp ka daank",
        ],
        "patterns": [
            r"snake\s*(bit|bite|attack|sting)",
            r"(bit|bitten)\s+by\s+(a\s+)?snake",
        ],
    },
    EmergencyCategory.UNCONSCIOUS: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "unconscious", "not responding", "passed out", "fainted",
            "unresponsive", "won't wake up", "cannot wake",
            "behosh", "hosh nahi", "behosh ho gaya",
        ],
        "patterns": [
            r"(not|won.t|cannot|can.t)\s+(respond|wake|conscious)",
            r"(unconscious|unresponsive|passed out|fainted)",
        ],
    },
    EmergencyCategory.HIGH_FEVER: {
        "severity": EmergencySeverity.HIGH,
        "keywords": [
            "very high fever", "fever 40", "fever 41", "fever 42",
            "temperature 104", "temperature 105", "temperature 106",
            "40 degree fever", "104 fever", "febrile seizure",
        ],
        "patterns": [
            r"fever\s+(40|41|42|43)",
            r"temperature\s+(10[4-9]|1[1-9]\d)",
            r"(40|41|42)\s*(degree|°|celsius|centigrade)",
        ],
    },
    EmergencyCategory.SEVERE_ALLERGY: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "anaphylaxis", "anaphylactic shock", "throat closing",
            "tongue swelling", "severe allergic reaction",
            "epipen", "allergy severe",
        ],
        "patterns": [
            r"(throat|tongue|airway)\s+(clos|swell|block)",
            r"anaphylax",
            r"severe\s+allerg",
        ],
    },
    EmergencyCategory.CHOKING: {
        "severity": EmergencySeverity.CRITICAL,
        "keywords": [
            "choking", "something stuck in throat", "food stuck throat",
            "airway blocked", "heimlich", "gala band",
        ],
        "patterns": [
            r"(choking|chok(e|ed))",
            r"(food|object|something)\s+(stuck|lodged|block)\w*\s+(in\s+)?(throat|airway)",
        ],
    },
    EmergencyCategory.SUICIDE: {
        "severity": EmergencySeverity.HIGH,
        "keywords": [
            "want to die", "kill myself", "end my life", "suicide",
            "self harm", "cut myself", "overdose on purpose",
            "marna chahta", "khud ko hurt karna",
        ],
        "patterns": [
            r"(want|going|plan)\w*\s+(to\s+)?(die|kill\s+myself|end\s+(my\s+)?life)",
            r"(suicide|self\s*harm|cut\s+myself)",
        ],
    },
}

# Compile all regex patterns
_COMPILED_RULES: Dict[EmergencyCategory, Dict] = {}
for _cat, _rule in _EMERGENCY_RULES.items():
    _COMPILED_RULES[_cat] = {
        "severity": _rule["severity"],
        "keywords": [kw.lower() for kw in _rule["keywords"]],
        "patterns": [re.compile(p, re.IGNORECASE) for p in _rule.get("patterns", [])],
    }


# ─── Result dataclass ─────────────────────────────────────────────────────────

@dataclass
class EmergencyResult:
    is_emergency: bool
    category: Optional[EmergencyCategory] = None
    severity: Optional[EmergencySeverity] = None
    matched_keywords: List[str] = field(default_factory=list)
    confidence: float = 0.0
    warning_message: str = ""
    action_steps: List[str] = field(default_factory=list)


# ─── Multilingual warning messages ───────────────────────────────────────────

_WARNING_MESSAGES: Dict[EmergencyCategory, Dict[str, str]] = {
    EmergencyCategory.CARDIAC: {
        "en": "🚨 HEART EMERGENCY! Call 108 immediately. Do NOT drive yourself. Chew aspirin if not allergic. Lie down and stay calm.",
        "hi": "🚨 दिल की आपातकाल! तुरंत 108 पर कॉल करें। एस्पिरिन चबाएं (अगर एलर्जी नहीं है)। लेट जाएं।",
        "ne": "🚨 मुटुको आपतकाल! तुरुन्त 108 मा कल गर्नुहोस्।",
        "bho": "🚨 दिल के इमरजेंसी! फौरन 108 पर फोन करा।",
    },
    EmergencyCategory.STROKE: {
        "en": "🚨 POSSIBLE STROKE! Call 108 NOW. Note the time symptoms started. Do NOT give food or water. Act FAST.",
        "hi": "🚨 स्ट्रोक के लक्षण! अभी 108 कॉल करें। खाना-पानी न दें।",
        "ne": "🚨 स्ट्रोकको लक्षण! अहिले नै 108 मा फोन गर्नुहोस्।",
        "bho": "🚨 लकवा के लक्षण! अभी 108 पर फोन करा।",
    },
    EmergencyCategory.RESPIRATORY: {
        "en": "🚨 BREATHING EMERGENCY! Call 108 immediately. If unconscious and not breathing, begin CPR.",
        "hi": "🚨 सांस की आपातकाल! तुरंत 108 कॉल करें। CPR शुरू करें अगर सांस बंद हो।",
        "ne": "🚨 सास फेर्न नसकिने! 108 मा तुरुन्त फोन गर्नुहोस्।",
        "bho": "🚨 सांस के इमरजेंसी! अभी 108 पर फोन करा।",
    },
    EmergencyCategory.SNAKEBITE: {
        "en": "🚨 SNAKEBITE! Keep still, immobilize the bitten limb below heart level. Call 108. Do NOT suck out venom or cut the wound.",
        "hi": "🚨 साँप ने काटा! हिलें मत, काटी हुई जगह को दिल से नीचे रखें। 108 कॉल करें। जहर न चूसें।",
        "ne": "🚨 सर्पदंश! नहल्नुहोस्। 108 मा फोन गर्नुहोस्।",
        "bho": "🚨 साँप काट लिहिस! मत हिला। 108 पर फोन करा।",
    },
}

_DEFAULT_WARNING: Dict[str, str] = {
    "en": "🚨 MEDICAL EMERGENCY DETECTED!\n\nYour symptoms may be life-threatening. Please:\n• Call emergency services immediately: 108 (Ambulance) | 112\n• Go to the nearest hospital NOW\n• Do NOT wait — every second counts\n\n⚠️ This AI cannot replace emergency care.",
    "hi": "🚨 चिकित्सा आपातकाल!\n\nआपके लक्षण जानलेवा हो सकते हैं।\n• तुरंत एम्बुलेंस बुलाएं: 108\n• नजदीकी अस्पताल जाएं\n\n⚠️ AI डॉक्टर की जगह नहीं ले सकता।",
    "ne": "🚨 चिकित्सा आपतकाल!\n\nतपाईंको लक्षणहरू जीवन-खतरनाक हुन सक्छन्।\n• एम्बुलेन्स: 102 | प्रहरी: 100\n• नजिकको अस्पताल जानुहोस्।",
    "bho": "🚨 मेडिकल इमरजेंसी!\n\nरउआ के लक्षण खतरनाक बा।\n• एम्बुलेंस: 108\n• अस्पताल जाव।",
}


# ─── Action step banks ────────────────────────────────────────────────────────

_ACTION_STEPS: Dict[EmergencyCategory, List[str]] = {
    EmergencyCategory.CARDIAC: [
        "Call emergency services (108) immediately",
        "Have the person lie down and stay calm",
        "Loosen tight clothing",
        "Give aspirin to chew if not allergic and conscious",
        "Prepare to perform CPR if needed",
    ],
    EmergencyCategory.STROKE: [
        "Call emergency services (108) immediately",
        "Note exact time symptoms started",
        "Have person lie down with head slightly elevated",
        "Do NOT give food or water",
        "Do NOT give aspirin for stroke",
    ],
    EmergencyCategory.RESPIRATORY: [
        "Call emergency services (108) immediately",
        "Keep the person upright or in recovery position",
        "If unconscious and not breathing, start CPR",
        "Do not leave the person alone",
    ],
    EmergencyCategory.SNAKEBITE: [
        "Keep the person still and calm",
        "Immobilize the bitten limb below heart level",
        "Remove rings/watches from the bitten limb",
        "Call 108 or get to hospital immediately",
        "Do NOT cut the wound, suck venom, or apply tourniquet",
    ],
    EmergencyCategory.OVERDOSE: [
        "Call emergency services (108) immediately",
        "Tell them what was taken and how much",
        "Keep person awake and talking if possible",
        "If unconscious, place in recovery position",
        "Do NOT induce vomiting unless instructed",
    ],
    EmergencyCategory.CHOKING: [
        "Ask 'Are you choking?'",
        "If they can cough — encourage coughing",
        "If they cannot cough — perform 5 back blows",
        "Then 5 abdominal thrusts (Heimlich maneuver)",
        "Call 108 if obstruction doesn't clear",
    ],
    EmergencyCategory.SUICIDE: [
        "Stay with the person — do not leave them alone",
        "Listen without judgment — take them seriously",
        "Remove access to harmful objects if safe to do so",
        "Call mental health crisis line: iCall 9152987821",
        "Take to nearest hospital if immediate danger",
    ],
}

_DEFAULT_ACTIONS = [
    "Call emergency services (108) immediately",
    "Go to the nearest hospital",
    "Do not leave the person alone",
    "Stay calm and reassure the patient",
]


# ─── Main Detector ────────────────────────────────────────────────────────────

class EmergencyDetector:
    """
    Detects medical emergencies from free-text input.

    Usage
    -----
    detector = EmergencyDetector()
    result = detector.detect("I have severe chest pain and my left arm is numb")
    if result.is_emergency:
        print(result.warning_message)
    """

    def detect(
        self, text: str, language: str = "en"
    ) -> EmergencyResult:
        """
        Analyse *text* for emergency signals.

        Parameters
        ----------
        text     : user message (any language, Devanagari or Latin)
        language : detected language code for response localisation

        Returns
        -------
        EmergencyResult
        """
        if not text or not text.strip():
            return EmergencyResult(is_emergency=False)

        text_lower = text.lower()
        best_category: Optional[EmergencyCategory] = None
        best_severity: Optional[EmergencySeverity] = None
        all_matched: List[str] = []
        best_score = 0

        for category, rule in _COMPILED_RULES.items():
            score = 0
            matched: List[str] = []

            # Keyword matching
            for kw in rule["keywords"]:
                if kw in text_lower:
                    score += 2
                    matched.append(kw)

            # Pattern matching
            for pattern in rule["patterns"]:
                m = pattern.search(text)
                if m:
                    score += 3
                    matched.append(m.group(0))

            if score > best_score:
                best_score = score
                best_category = category
                best_severity = rule["severity"]
                all_matched = matched

        if best_score == 0:
            return EmergencyResult(is_emergency=False)

        # Compute confidence (0–1)
        confidence = min(1.0, best_score / 8.0)

        # Get localised warning
        lang = language if language in ("en", "hi", "ne", "bho") else "en"
        cat_warnings = _WARNING_MESSAGES.get(best_category, {})
        warning = cat_warnings.get(lang) or _DEFAULT_WARNING.get(lang, _DEFAULT_WARNING["en"])

        actions = _ACTION_STEPS.get(best_category, _DEFAULT_ACTIONS)

        logger.warning(
            f"Emergency detected: category={best_category}, "
            f"severity={best_severity}, score={best_score}, "
            f"keywords={all_matched[:3]}"
        )

        return EmergencyResult(
            is_emergency=True,
            category=best_category,
            severity=best_severity,
            matched_keywords=all_matched[:5],
            confidence=confidence,
            warning_message=warning,
            action_steps=actions,
        )

    def is_emergency(self, text: str) -> bool:
        """Quick boolean check."""
        return self.detect(text).is_emergency


# ─── Singleton ────────────────────────────────────────────────────────────────

_instance: Optional[EmergencyDetector] = None


def get_emergency_detector() -> EmergencyDetector:
    global _instance
    if _instance is None:
        _instance = EmergencyDetector()
    return _instance
