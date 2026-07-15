"""
Emergency Classifier — combines rule-based + ML scoring.

Classification flow:
  1. Normalize text input
  2. Run RuleEngine (keyword + combo matching)
  3. Run MLClassifier (sklearn RandomForest if available, else fallback scoring)
  4. Merge scores — rule engine always takes precedence for CRITICAL decisions
  5. Return EmergencyClassification

The ML model is optional.  If no trained model file is found the classifier
falls back gracefully to pure rule-based scoring so the app works out-of-the-box.
"""

from __future__ import annotations

import logging
import os
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from ai_models.emergency_detection.emergency_rules import (
    ALL_EMERGENCY_KEYWORDS,
    EMERGENCY_RULES,
    EmergencyCategory,
    EmergencyRule,
    RiskLevel,
    RULES_BY_CATEGORY,
    score_to_risk_level,
)

logger = logging.getLogger(__name__)

# Where the serialised sklearn model lives (optional)
_MODEL_PATH = Path(__file__).parent / "saved_models" / "emergency_rf.pkl"


# ─── Result dataclass ─────────────────────────────────────────────────────────

@dataclass
class EmergencyClassification:
    is_emergency:     bool
    category:         Optional[EmergencyCategory]
    risk_level:       RiskLevel
    matched_keywords: List[str]         = field(default_factory=list)
    matched_combos:   List[Tuple]       = field(default_factory=list)
    rule_triggered:   bool              = False
    ml_confidence:    float             = 0.0
    rule_weight:      int               = 0
    combo_triggered:  bool              = False


# ─── Rule Engine ─────────────────────────────────────────────────────────────

class _RuleEngine:
    """Deterministic keyword + combination rule checker."""

    def __init__(self) -> None:
        # Pre-compile symptom combo patterns (lowercased)
        self._rules = EMERGENCY_RULES

    def evaluate(self, text: str) -> Optional[Tuple[EmergencyRule, List[str], List[Tuple]]]:
        """
        Returns (matched_rule, matched_keywords, matched_combos) or None.
        When multiple rules match, the one with the highest score_weight wins.
        """
        lower = text.lower()
        best_rule: Optional[EmergencyRule] = None
        best_weight = -1
        best_kws: List[str] = []
        best_combos: List[Tuple] = []

        for rule in self._rules:
            kws_found = [kw for kw in rule.keywords if kw in lower]
            combos_found = [
                combo for combo in rule.symptom_combos
                if all(part in lower for part in combo)
            ]

            if kws_found or combos_found:
                if rule.score_weight > best_weight:
                    best_weight = rule.score_weight
                    best_rule = rule
                    best_kws = kws_found
                    best_combos = combos_found

        if best_rule is None:
            return None
        return best_rule, best_kws, best_combos


# ─── ML Classifier (optional) ────────────────────────────────────────────────

class _MLClassifier:
    """
    Wraps a trained sklearn RandomForest (if present).
    Falls back to a keyword-count based score otherwise.
    """

    def __init__(self) -> None:
        self._model = None
        self._vectorizer = None
        self._load_model()

    def _load_model(self) -> None:
        if not _MODEL_PATH.exists():
            logger.debug("No trained ML model found at %s — using fallback scoring.", _MODEL_PATH)
            return
        try:
            import pickle
            with open(_MODEL_PATH, "rb") as f:
                bundle = pickle.load(f)
            self._model = bundle.get("model")
            self._vectorizer = bundle.get("vectorizer")
            logger.info("Emergency ML model loaded from %s", _MODEL_PATH)
        except Exception as exc:
            logger.warning("Could not load emergency ML model: %s", exc)

    def predict(self, text: str) -> float:
        """
        Returns a confidence float between 0.0 and 1.0.
        1.0 = definitely an emergency, 0.0 = definitely not.
        """
        if self._model is not None and self._vectorizer is not None:
            try:
                X = self._vectorizer.transform([text])
                proba = self._model.predict_proba(X)[0]
                return float(proba[1])  # probability of class=1 (emergency)
            except Exception as exc:
                logger.warning("ML predict failed: %s", exc)

        # ── Fallback: keyword density scoring ─────────────────────────────
        lower = text.lower()
        hits = sum(1 for kw in ALL_EMERGENCY_KEYWORDS if kw in lower)
        word_count = max(1, len(lower.split()))
        density = hits / word_count
        # Normalise to 0-1 with a gentle cap at density ≥ 0.4 = 1.0
        return min(1.0, density / 0.4)


# ─── Main Classifier ─────────────────────────────────────────────────────────

class EmergencyClassifier:
    """
    Unified classifier combining rule engine + ML.

    Usage
    -----
    clf = EmergencyClassifier()
    result = clf.classify(text="I have severe chest pain and my arm is numb")
    """

    def __init__(self) -> None:
        self._rules = _RuleEngine()
        self._ml = _MLClassifier()

    def classify(self, text: str) -> EmergencyClassification:
        """
        Classify free-text for emergency signals.

        Rule engine takes PRECEDENCE — if a CRITICAL rule fires the result
        is always at least CRITICAL regardless of ML confidence.
        """
        if not text or not text.strip():
            return EmergencyClassification(
                is_emergency=False,
                category=None,
                risk_level=RiskLevel.LOW,
            )

        # 1. Run rule engine
        rule_result = self._rules.evaluate(text)

        # 2. Run ML
        ml_confidence = self._ml.predict(text)

        if rule_result is not None:
            rule, kws, combos = rule_result
            # Rule engine wins — use rule risk_level
            return EmergencyClassification(
                is_emergency=True,
                category=rule.category,
                risk_level=rule.risk_level,
                matched_keywords=kws,
                matched_combos=combos,
                rule_triggered=True,
                ml_confidence=ml_confidence,
                rule_weight=rule.score_weight,
                combo_triggered=bool(combos),
            )

        # 3. No rule hit — use ML confidence alone
        if ml_confidence >= 0.65:
            risk = RiskLevel.HIGH if ml_confidence >= 0.85 else RiskLevel.MODERATE
            return EmergencyClassification(
                is_emergency=True,
                category=EmergencyCategory.GENERAL,
                risk_level=risk,
                rule_triggered=False,
                ml_confidence=ml_confidence,
                rule_weight=0,
            )

        # 4. Not an emergency
        return EmergencyClassification(
            is_emergency=False,
            category=None,
            risk_level=RiskLevel.LOW,
            ml_confidence=ml_confidence,
        )


# ─── Backward compat shim ─────────────────────────────────────────────────────

_default_classifier: Optional[EmergencyClassifier] = None


def is_emergency(text: str) -> bool:
    """Legacy one-line helper."""
    global _default_classifier
    if _default_classifier is None:
        _default_classifier = EmergencyClassifier()
    return _default_classifier.classify(text).is_emergency
