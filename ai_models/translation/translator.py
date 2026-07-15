"""
Translation Service - Auto-detect language + translate between
English, Hindi, Nepali, and Bhojpuri.

Primary backend: deep-translator (Google Translate API wrapper)
Fallback:        langdetect for language detection only
"""

from __future__ import annotations

import logging
import re
from dataclasses import dataclass
from enum import Enum
from typing import Dict, List, Optional, Tuple

logger = logging.getLogger(__name__)


# ─── Supported Languages ──────────────────────────────────────────────────────

class Language(str, Enum):
    ENGLISH   = "en"
    HINDI     = "hi"
    NEPALI    = "ne"
    BHOJPURI  = "bho"   # ISO 639-3; Google maps this to Hindi (hi)
    BENGALI   = "bn"
    TAMIL     = "ta"
    TELUGU    = "te"
    MARATHI   = "mr"
    GUJARATI  = "gu"
    KANNADA   = "kn"
    MALAYALAM = "ml"
    PUNJABI   = "pa"
    AUTO      = "auto"


LANGUAGE_NAMES: Dict[str, str] = {
    "en":  "English",
    "hi":  "Hindi",
    "ne":  "Nepali",
    "bho": "Bhojpuri",
    "bn":  "Bengali",
    "ta":  "Tamil",
    "te":  "Telugu",
    "mr":  "Marathi",
    "gu":  "Gujarati",
    "kn":  "Kannada",
    "ml":  "Malayalam",
    "pa":  "Punjabi",
}

# Google Translate codes (Bhojpuri uses Hindi backend)
_GOOGLE_CODE: Dict[str, str] = {
    "en":  "en",
    "hi":  "hi",
    "ne":  "ne",
    "bho": "hi",   # closest supported code
    "bn":  "bn",
    "ta":  "ta",
    "te":  "te",
    "mr":  "mr",
    "gu":  "gu",
    "kn":  "kn",
    "ml":  "ml",
    "pa":  "pa",
}


@dataclass
class DetectionResult:
    language_code: str
    language_name: str
    confidence: float
    script: str          # "latin", "devanagari", "bengali", etc.


@dataclass
class TranslationResult:
    original_text: str
    translated_text: str
    source_language: str
    target_language: str
    success: bool
    error: Optional[str] = None


# ─── Script / Charset Detection ──────────────────────────────────────────────

_DEVANAGARI_PATTERN = re.compile(r"[\u0900-\u097F]")
_ARABIC_PATTERN     = re.compile(r"[\u0600-\u06FF]")
_BENGALI_PATTERN    = re.compile(r"[\u0980-\u09FF]")
_TAMIL_PATTERN      = re.compile(r"[\u0B80-\u0BFF]")
_TELUGU_PATTERN     = re.compile(r"[\u0C00-\u0C7F]")
_KANNADA_PATTERN    = re.compile(r"[\u0C80-\u0CFF]")
_MALAYALAM_PATTERN  = re.compile(r"[\u0D00-\u0D7F]")
_GURMUKHI_PATTERN   = re.compile(r"[\u0A00-\u0A7F]")
_GUJARATI_PATTERN   = re.compile(r"[\u0A80-\u0AFF]")


def _detect_script(text: str) -> str:
    """Return script name based on Unicode block analysis."""
    if _DEVANAGARI_PATTERN.search(text):
        return "devanagari"
    if _BENGALI_PATTERN.search(text):
        return "bengali"
    if _TAMIL_PATTERN.search(text):
        return "tamil"
    if _TELUGU_PATTERN.search(text):
        return "telugu"
    if _KANNADA_PATTERN.search(text):
        return "kannada"
    if _MALAYALAM_PATTERN.search(text):
        return "malayalam"
    if _GURMUKHI_PATTERN.search(text):
        return "gurmukhi"
    if _GUJARATI_PATTERN.search(text):
        return "gujarati"
    return "latin"


# ─── Bhojpuri / Devanagari Heuristics ────────────────────────────────────────

# Bhojpuri-specific romanised markers (not present in standard Hindi/Nepali)
_BHOJPURI_MARKERS = [
    r"\bba\b", r"\bbaa\b", r"\bhamar\b", r"\btohar\b", r"\braha\s+ba\b",
    r"\bkaisan\b", r"\bkais\b", r"\bhola\b", r"\bchhi\b", r"\bkhatir\b",
]
_BHOJPURI_RE = re.compile("|".join(_BHOJPURI_MARKERS), re.IGNORECASE)

# Nepali-specific romanised markers
_NEPALI_MARKERS = [
    r"\btapai\b", r"\btapaiko\b", r"\bmuluk\b", r"\bchha\b", r"\bgarchha\b",
    r"\bchhu\b", r"\bgarnu\b", r"\bmaile\b", r"\bhunchha\b", r"\bbhayo\b",
    r"\bchaina\b", r"\bkastai\b", r"\blaai\b",
]
_NEPALI_RE = re.compile("|".join(_NEPALI_MARKERS), re.IGNORECASE)


def _heuristic_detect(text: str) -> Optional[Tuple[str, float]]:
    """
    Heuristic language detection for Bhojpuri/Nepali in Latin script
    where standard detectors often misclassify.

    Returns (language_code, confidence) or None.
    """
    if _BHOJPURI_RE.search(text):
        return ("bho", 0.75)
    if _NEPALI_RE.search(text):
        return ("ne", 0.70)
    return None


# ─── Translator Class ─────────────────────────────────────────────────────────

class Translator:
    """
    Multi-language translator with auto-detection.

    Example
    -------
    t = Translator()
    result = t.detect("मलाई टाउको दुखेको छ")
    translated = t.translate("मलाई बुखार छ", target="en")
    """

    def __init__(self) -> None:
        self._deep_translator_available = self._check_deep_translator()
        self._langdetect_available      = self._check_langdetect()
        logger.info(
            f"Translator init: deep_translator={self._deep_translator_available}, "
            f"langdetect={self._langdetect_available}"
        )

    # ─── Availability checks ──────────────────────────────────────────────────

    @staticmethod
    def _check_deep_translator() -> bool:
        try:
            import deep_translator  # noqa: F401
            return True
        except ImportError:
            logger.warning("deep-translator not installed. Run: pip install deep-translator")
            return False

    @staticmethod
    def _check_langdetect() -> bool:
        try:
            import langdetect  # noqa: F401
            return True
        except ImportError:
            logger.warning("langdetect not installed. Run: pip install langdetect")
            return False

    # ─── Detection ────────────────────────────────────────────────────────────

    def detect(self, text: str) -> DetectionResult:
        """Detect the language of *text*."""
        script = _detect_script(text)

        # Devanagari script — decide between Hindi and Nepali by word frequency
        if script == "devanagari":
            code, conf = self._devanagari_detect(text)
            return DetectionResult(
                language_code=code,
                language_name=LANGUAGE_NAMES.get(code, code),
                confidence=conf,
                script="devanagari",
            )

        # Non-Latin scripts → map directly
        script_map = {
            "bengali":   ("bn", 0.95),
            "tamil":     ("ta", 0.95),
            "telugu":    ("te", 0.95),
            "kannada":   ("kn", 0.95),
            "malayalam": ("ml", 0.95),
            "gurmukhi":  ("pa", 0.95),
            "gujarati":  ("gu", 0.95),
        }
        if script in script_map:
            code, conf = script_map[script]
            return DetectionResult(
                language_code=code,
                language_name=LANGUAGE_NAMES.get(code, code),
                confidence=conf,
                script=script,
            )

        # Latin script — try Bhojpuri/Nepali heuristics first
        heuristic = _heuristic_detect(text)
        if heuristic:
            code, conf = heuristic
            return DetectionResult(
                language_code=code,
                language_name=LANGUAGE_NAMES.get(code, code),
                confidence=conf,
                script="latin",
            )

        # Fall back to langdetect
        if self._langdetect_available:
            try:
                from langdetect import detect as ld_detect, detect_langs
                langs = detect_langs(text)
                if langs:
                    top = langs[0]
                    code = str(top.lang)
                    conf = float(top.prob)
                    return DetectionResult(
                        language_code=code,
                        language_name=LANGUAGE_NAMES.get(code, code.upper()),
                        confidence=conf,
                        script="latin",
                    )
            except Exception as exc:
                logger.debug(f"langdetect error: {exc}")

        # Ultimate fallback: English
        return DetectionResult(
            language_code="en",
            language_name="English",
            confidence=0.5,
            script="latin",
        )

    def _devanagari_detect(self, text: str) -> Tuple[str, float]:
        """
        Distinguish Hindi vs Nepali vs Bhojpuri written in Devanagari.
        Uses a small word-frequency heuristic.
        """
        # Nepali-specific Devanagari words
        nepali_words = {"छ", "छन्", "गर्छ", "हुन्छ", "भयो", "गर्नु", "तपाई", "हामी",
                        "यो", "त्यो", "कति", "कहाँ", "मलाई", "तिमी", "हाम्रो"}
        # Bhojpuri Devanagari markers
        bhojpuri_words = {"बा", "बाड़े", "हमार", "तोहार", "रहल", "बाटे", "कइसे"}

        tokens = set(text.split())
        nepali_hits    = len(tokens & nepali_words)
        bhojpuri_hits  = len(tokens & bhojpuri_words)

        if bhojpuri_hits > 0:
            return ("bho", min(0.60 + bhojpuri_hits * 0.08, 0.90))
        if nepali_hits > 0:
            return ("ne",  min(0.65 + nepali_hits  * 0.06, 0.92))
        return ("hi", 0.80)

    # ─── Translation ──────────────────────────────────────────────────────────

    def translate(
        self,
        text: str,
        target: str = "en",
        source: str = "auto",
    ) -> TranslationResult:
        """
        Translate *text* from *source* language to *target* language.

        If source == "auto" the language is detected first.
        """
        if not text or not text.strip():
            return TranslationResult(
                original_text=text,
                translated_text=text,
                source_language=source,
                target_language=target,
                success=True,
            )

        # Resolve source
        if source == "auto":
            detected = self.detect(text)
            source = detected.language_code

        # Map to Google codes
        target_code = _GOOGLE_CODE.get(target, target)
        source_code = _GOOGLE_CODE.get(source, source)

        # Same language — skip API call
        if source_code == target_code:
            return TranslationResult(
                original_text=text,
                translated_text=text,
                source_language=source,
                target_language=target,
                success=True,
            )

        if not self._deep_translator_available:
            return TranslationResult(
                original_text=text,
                translated_text=text,
                source_language=source,
                target_language=target,
                success=False,
                error="deep-translator not installed",
            )

        try:
            from deep_translator import GoogleTranslator
            translated = GoogleTranslator(source=source_code, target=target_code).translate(text)
            return TranslationResult(
                original_text=text,
                translated_text=translated or text,
                source_language=source,
                target_language=target,
                success=True,
            )
        except Exception as exc:
            logger.error(f"Translation error ({source}→{target}): {exc}")
            return TranslationResult(
                original_text=text,
                translated_text=text,
                source_language=source,
                target_language=target,
                success=False,
                error=str(exc),
            )

    def translate_to_english(self, text: str) -> TranslationResult:
        """Auto-detect source and translate to English."""
        return self.translate(text, target="en", source="auto")

    def translate_response(self, english_response: str, target_language: str) -> TranslationResult:
        """Translate an English bot response into the user's language."""
        if target_language in ("en", "auto"):
            return TranslationResult(
                original_text=english_response,
                translated_text=english_response,
                source_language="en",
                target_language=target_language,
                success=True,
            )
        return self.translate(english_response, target=target_language, source="en")

    def get_greeting(self, language_code: str) -> str:
        """Return a language-appropriate greeting."""
        greetings = {
            "en":  "Hello! 😊 How can I help you today?",
            "hi":  "नमस्ते! 😊 मैं आपकी कैसे मदद कर सकता हूँ?",
            "ne":  "नमस्कार! 😊 म तपाईलाई कसरी सहयोग गर्न सक्छु?",
            "bho": "नमस्कार! 😊 हम रउआ के कइसे मदद कर सकीला?",
            "bn":  "নমস্কার! 😊 আমি আপনাকে কীভাবে সাহায্য করতে পারি?",
            "ta":  "வணக்கம்! 😊 நான் உங்களுக்கு எப்படி உதவலாம்?",
        }
        return greetings.get(language_code, greetings["en"])

    def get_emergency_message(self, language_code: str) -> str:
        """Return an emergency warning in the user's language."""
        messages = {
            "en": (
                "🚨 EMERGENCY DETECTED!\n\n"
                "Your symptoms may indicate a medical emergency. "
                "Please call emergency services immediately:\n"
                "• India: 108 (Ambulance) | 112 (All emergencies)\n"
                "• Nepal: 102 (Ambulance) | 100 (Police)\n\n"
                "Go to the nearest hospital NOW."
            ),
            "hi": (
                "🚨 आपातकालीन स्थिति!\n\n"
                "आपके लक्षण एक चिकित्सा आपातकाल का संकेत दे सकते हैं।\n"
                "तुरंत आपातकालीन सेवाओं को कॉल करें:\n"
                "• एम्बुलेंस: 108\n"
                "• सभी आपात: 112\n\n"
                "अभी नजदीकी अस्पताल जाएं।"
            ),
            "ne": (
                "🚨 आपतकालीन अवस्था!\n\n"
                "तपाईंको लक्षणहरू चिकित्सा आपतकाल संकेत गर्न सक्छन्।\n"
                "तुरुन्त आपतकालीन सेवालाई फोन गर्नुहोस्:\n"
                "• नेपाल: 102 (एम्बुलेन्स) | 100 (प्रहरी)\n\n"
                "अहिले नजिकको अस्पताल जानुहोस्।"
            ),
            "bho": (
                "🚨 इमरजेंसी बा!\n\n"
                "रउआ के लक्षण मेडिकल इमरजेंसी के संकेत दे सकता बा।\n"
                "अभी एम्बुलेंस बोलावा: 108\n\n"
                "नजदीकी अस्पताल जाव।"
            ),
        }
        return messages.get(language_code, messages["en"])


# ─── Singleton ────────────────────────────────────────────────────────────────

_instance: Optional[Translator] = None


def get_translator() -> Translator:
    global _instance
    if _instance is None:
        _instance = Translator()
    return _instance
