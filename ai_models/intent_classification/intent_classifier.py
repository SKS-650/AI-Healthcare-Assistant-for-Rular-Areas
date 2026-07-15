"""
Intent Classifier - Classifies user messages into medical intent categories.

Uses TF-IDF + Logistic Regression as primary, with keyword matching as fallback.
Supports all 12 intent categories defined in the system specification.
"""

from __future__ import annotations

import logging
import os
import pickle
import re
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Dict, List, Optional, Tuple

logger = logging.getLogger(__name__)


class Intent(str, Enum):
    """All supported intent categories."""

    GENERAL_CHAT = "GENERAL_CHAT"
    GENERAL_MEDICAL = "GENERAL_MEDICAL"
    SYMPTOM_QUERY = "SYMPTOM_QUERY"
    MEDICATION_QUERY = "MEDICATION_QUERY"
    NUTRITION_QUERY = "NUTRITION_QUERY"
    EXERCISE_QUERY = "EXERCISE_QUERY"
    PREGNANCY_QUERY = "PREGNANCY_QUERY"
    CHILDCARE_QUERY = "CHILDCARE_QUERY"
    ELDERLYCARE_QUERY = "ELDERLYCARE_QUERY"
    EMERGENCY_QUERY = "EMERGENCY_QUERY"
    MENTAL_HEALTH_QUERY = "MENTAL_HEALTH_QUERY"
    FOLLOW_UP_QUERY = "FOLLOW_UP_QUERY"


@dataclass
class IntentResult:
    intent: Intent
    confidence: float
    secondary_intent: Optional[Intent] = None
    keywords_matched: List[str] = None

    def __post_init__(self):
        if self.keywords_matched is None:
            self.keywords_matched = []


# ─── Keyword Rules (language-agnostic keywords + transliterations) ────────────

_INTENT_KEYWORDS: Dict[Intent, List[str]] = {
    Intent.EMERGENCY_QUERY: [
        # English
        "emergency", "urgent", "heart attack", "stroke", "chest pain",
        "can't breathe", "cannot breathe", "unconscious", "fainted",
        "severe bleeding", "bleeding heavily", "snake bite", "snakebite",
        "poisoning", "overdose", "choking", "drowning", "seizure",
        "high fever above 40", "paralysis", "loss of consciousness",
        "911", "108", "ambulance", "hospital immediately",
        # Hindi transliteration
        "dil ka dora", "sans nahi", "behosh", "khoon bahut aa raha",
        "saap ne kata", "zeher", "dil dard",
        # Nepali transliteration
        "marne wala", "beshoshi", "ati tato jwaro",
        # Bhojpuri transliteration
        "haath nahi chal raha", "nas kat gayi",
    ],
    Intent.SYMPTOM_QUERY: [
        "symptom", "symptoms", "feel", "feeling", "pain", "ache",
        "fever", "cough", "cold", "nausea", "vomiting", "diarrhea",
        "headache", "dizziness", "fatigue", "tired", "weak", "rash",
        "swelling", "itching", "bleeding", "discharge", "sore throat",
        "i have", "suffering from", "experiencing", "troubled by",
        # Hindi/Nepali/Bhojpuri
        "dard", "bukhar", "khasi", "sans", "ulti", "chakkar",
        "dast", "sardarad", "kamzori", "taklif", "bimari",
        "mujhe ho raha", "pet dard", "sar dard",
        "tapai lai", "mujhe", "hamra", "hamar",
    ],
    Intent.MEDICATION_QUERY: [
        "medicine", "medication", "drug", "tablet", "capsule", "syrup",
        "dose", "dosage", "prescription", "paracetamol", "ibuprofen",
        "antibiotic", "painkiller", "insulin", "metformin", "aspirin",
        "side effect", "overdose", "drug interaction", "pharmacy",
        # Hindi/Nepali
        "dawai", "dawa", "aushadhi", "tablet", "injection",
    ],
    Intent.NUTRITION_QUERY: [
        "food", "diet", "nutrition", "eat", "eating", "meal", "drink",
        "vitamin", "protein", "calcium", "iron", "fiber", "calorie",
        "weight", "obesity", "anemia", "diabetes diet", "blood pressure diet",
        "what should i eat", "foods for", "healthy food",
        # Hindi/Nepali
        "khana", "khaana", "bhojan", "kha", "diet",
    ],
    Intent.EXERCISE_QUERY: [
        "exercise", "workout", "yoga", "walk", "walking", "running",
        "fitness", "physical activity", "gym", "weight loss", "obesity",
        "stretching", "physio", "physiotherapy", "sport",
        # Hindi/Nepali
        "vyayam", "kasrat", "daudna", "paidal chalna",
    ],
    Intent.PREGNANCY_QUERY: [
        "pregnant", "pregnancy", "prenatal", "antenatal", "baby",
        "trimester", "morning sickness", "delivery", "labor",
        "miscarriage", "breastfeeding", "lactation", "birth",
        "fetal", "fetus", "womb", "uterus",
        # Hindi/Nepali
        "garbhwati", "baccha", "prasav", "delivery", "dudh pilana",
    ],
    Intent.CHILDCARE_QUERY: [
        "child", "children", "baby", "infant", "toddler", "kid",
        "vaccination", "immunization", "growth", "development",
        "feeding", "pediatric", "newborn", "child fever",
        # Hindi/Nepali
        "baccha", "shishu", "bacha", "tikakaran", "immunization",
    ],
    Intent.ELDERLYCARE_QUERY: [
        "elderly", "old age", "senior", "aging", "dementia",
        "arthritis", "osteoporosis", "fall prevention", "memory",
        "blood pressure elderly", "diabetes elderly", "retirement",
        # Hindi/Nepali
        "buzurg", "vriddha", "budha", "joron ka dard",
    ],
    Intent.MENTAL_HEALTH_QUERY: [
        "stress", "anxiety", "depression", "mental health", "sad",
        "lonely", "fear", "panic", "sleep", "insomnia", "worried",
        "suicide", "self harm", "crying", "hopeless", "therapy",
        "counseling", "psychiatrist", "psychologist",
        # Hindi/Nepali
        "chinta", "ghabrahat", "udaas", "nind nahi", "darpok",
    ],
    Intent.NUTRITION_QUERY: [
        "food", "diet", "eat", "nutrition", "vitamin", "protein",
        "minerals", "calorie", "healthy eating", "weight gain",
    ],
    Intent.GENERAL_MEDICAL: [
        "disease", "condition", "health", "medical", "doctor",
        "hospital", "clinic", "treatment", "diagnosis", "cure",
        "prevention", "vaccine", "blood test", "scan", "x-ray",
        "diabetes", "hypertension", "asthma", "allergy", "cancer",
        "infection", "virus", "bacteria",
    ],
    Intent.FOLLOW_UP_QUERY: [
        "what about", "and also", "what else", "tell me more",
        "can you explain", "what does that mean", "so what should i",
        "you said", "earlier you mentioned", "continue", "go on",
    ],
    Intent.GENERAL_CHAT: [
        "hello", "hi", "hey", "how are you", "good morning", "good evening",
        "thank you", "thanks", "bye", "goodbye", "what is your name",
        "who are you", "help", "what can you do",
    ],
}


class IntentClassifier:
    """
    Multi-tier intent classifier.

    Tier 1: Loaded sklearn model (if available)
    Tier 2: Embedding cosine similarity (if embedding service is available)
    Tier 3: Keyword matching (always available)
    """

    def __init__(self, model_path: Optional[str] = None) -> None:
        self._model = None
        self._vectorizer = None
        self._label_encoder = None

        if model_path:
            self._load_model(Path(model_path))
        else:
            self._try_auto_load()

    def _try_auto_load(self) -> None:
        """Try to load from default saved_models location."""
        candidates = [
            Path("ai_models/saved_models/intent_classifier.pkl"),
            Path("../ai_models/saved_models/intent_classifier.pkl"),
            Path(__file__).parent.parent / "saved_models" / "intent_classifier.pkl",
        ]
        for p in candidates:
            if p.exists():
                self._load_model(p)
                return

    def _load_model(self, path: Path) -> None:
        try:
            with open(path, "rb") as f:
                bundle = pickle.load(f)
            self._vectorizer = bundle["vectorizer"]
            self._model = bundle["model"]
            self._label_encoder = bundle.get("label_encoder")
            logger.info(f"Intent classifier loaded from {path}")
        except Exception as exc:
            logger.warning(f"Could not load intent classifier from {path}: {exc}")

    # ─── Classification ───────────────────────────────────────────────────────

    def classify(self, text: str) -> IntentResult:
        """Classify text into an intent category."""
        text_lower = text.lower().strip()

        # Tier 1: sklearn model
        if self._model is not None and self._vectorizer is not None:
            try:
                vec = self._vectorizer.transform([text_lower])
                proba = self._model.predict_proba(vec)[0]
                classes = self._model.classes_
                top_idx = int(proba.argmax())
                top_label = classes[top_idx]
                confidence = float(proba[top_idx])
                intent = self._to_intent(top_label)
                if confidence > 0.55:
                    return IntentResult(intent=intent, confidence=confidence)
            except Exception as exc:
                logger.debug(f"Sklearn intent failed: {exc}")

        # Tier 2: Keyword matching
        return self._keyword_classify(text_lower)

    def _keyword_classify(self, text: str) -> IntentResult:
        """Score every intent by keyword matching."""
        scores: Dict[Intent, Tuple[int, List[str]]] = {}

        for intent, keywords in _INTENT_KEYWORDS.items():
            matched = [kw for kw in keywords if kw.lower() in text]
            if matched:
                # Weight emergency higher
                weight = 2 if intent == Intent.EMERGENCY_QUERY else 1
                scores[intent] = (len(matched) * weight, matched)

        if not scores:
            return IntentResult(
                intent=Intent.GENERAL_CHAT,
                confidence=0.5,
                keywords_matched=[],
            )

        # Sort by score desc
        sorted_intents = sorted(scores.items(), key=lambda x: x[1][0], reverse=True)
        best_intent, (best_count, best_kws) = sorted_intents[0]

        # Normalise confidence
        max_count = max(sc for _, (sc, _) in sorted_intents)
        confidence = min(0.95, 0.50 + (best_count / max(max_count, 1)) * 0.45)

        secondary = None
        if len(sorted_intents) > 1:
            secondary = sorted_intents[1][0][0] if isinstance(sorted_intents[1][0], tuple) else sorted_intents[1][0]

        return IntentResult(
            intent=best_intent,
            confidence=confidence,
            secondary_intent=secondary,
            keywords_matched=best_kws[:5],
        )

    @staticmethod
    def _to_intent(label: str) -> Intent:
        try:
            return Intent(label.upper())
        except ValueError:
            return Intent.GENERAL_MEDICAL

    def save_model(
        self,
        vectorizer,
        model,
        label_encoder=None,
        output_path: Optional[str] = None,
    ) -> None:
        """Persist a trained sklearn model bundle."""
        if output_path is None:
            output_path = str(
                Path(__file__).parent.parent / "saved_models" / "intent_classifier.pkl"
            )
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        bundle = {"vectorizer": vectorizer, "model": model, "label_encoder": label_encoder}
        with open(output_path, "wb") as f:
            pickle.dump(bundle, f)
        logger.info(f"Intent classifier saved to {output_path}")


# ─── Training Helper ─────────────────────────────────────────────────────────


def train_intent_classifier(
    output_path: Optional[str] = None,
) -> IntentClassifier:
    """
    Train a TF-IDF + Logistic Regression classifier from the keyword bank.

    Augments each keyword phrase with simple sentence templates to create
    a small but effective training set.
    """
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.linear_model import LogisticRegression
    from sklearn.preprocessing import LabelEncoder

    templates = [
        "{kw}", "I have {kw}", "what is {kw}", "tell me about {kw}",
        "help me with {kw}", "I feel {kw}", "my {kw} is bad",
        "suffering from {kw}", "dealing with {kw}", "{kw} problem",
        "question about {kw}", "{kw} treatment",
    ]

    X, y = [], []
    for intent, keywords in _INTENT_KEYWORDS.items():
        for kw in keywords:
            for tpl in templates:
                X.append(tpl.format(kw=kw).lower())
                y.append(intent.value)

    le = LabelEncoder()
    y_enc = le.fit_transform(y)

    vectorizer = TfidfVectorizer(ngram_range=(1, 3), max_features=20_000)
    X_vec = vectorizer.fit_transform(X)

    model = LogisticRegression(max_iter=1000, C=1.5, class_weight="balanced")
    model.fit(X_vec, y_enc)
    # Reattach string labels so predict() returns Intent values
    model.classes_ = le.classes_

    clf = IntentClassifier()
    clf._model = model
    clf._vectorizer = vectorizer
    clf._label_encoder = le
    clf.save_model(vectorizer, model, le, output_path)

    logger.info(f"Intent classifier trained on {len(X)} samples")
    return clf


# ─── Singleton ───────────────────────────────────────────────────────────────

_instance: Optional[IntentClassifier] = None


def get_intent_classifier() -> IntentClassifier:
    global _instance
    if _instance is None:
        _instance = IntentClassifier()
    return _instance
