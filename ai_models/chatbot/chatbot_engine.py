"""
Chatbot Engine — Multilingual Offline + Online AI Medical Assistant.

Pipeline:
  Text/Voice → Language Detection → Intent Classification
     → Emergency Check → Online/Offline Router → Response
     → Translation back → TTS (optional)

Languages: English, हिंदी (Hindi), नेपाली (Nepali), भोजपुरी (Bhojpuri)
"""
from __future__ import annotations
import json, logging, os, pickle, sys, time
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)

ROOT = Path(__file__).resolve().parent.parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

# ── Enums ─────────────────────────────────────────────────────────────────────
class ChatMode(str, Enum):
    ONLINE  = "online"
    OFFLINE = "offline"
    AUTO    = "auto"

# ── Response dataclass ────────────────────────────────────────────────────────
@dataclass
class ChatbotResponse:
    text: str
    language: str
    mode: ChatMode
    intent: str
    is_emergency: bool
    emergency_category: Optional[str]
    follow_up_questions: List[str]
    suggestions: List[str]
    confidence: float
    response_time: float
    audio_bytes: Optional[bytes] = None
    audio_format: str = "mp3"
    sources: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)

# ── Follow-up banks ───────────────────────────────────────────────────────────
_FOLLOW_UPS: Dict[str, List[str]] = {
    "SYMPTOM_QUERY":     ["How long have you had these symptoms? ⏱️",
                          "Do you have a fever as well? 🌡️",
                          "Are symptoms getting better or worse? 📈",
                          "Have you taken any medicine yet? 💊"],
    "MEDICATION_QUERY":  ["Are you taking any other medicines? 💊",
                          "Do you have any known allergies? ⚠️",
                          "Have you consulted a doctor? 🩺"],
    "GENERAL_MEDICAL":   ["Would you like more details about this? 📚",
                          "Should I suggest prevention tips? 🛡️",
                          "Do you want to know when to see a doctor? 🏥"],
    "MENTAL_HEALTH_QUERY":["How long have you been feeling this way? ⏳",
                           "Do you have someone you can talk to? 💙",
                           "Would you like mental health resources? 📞"],
    "PREGNANCY_QUERY":   ["How many weeks pregnant are you? 🤰",
                          "Are you attending regular prenatal checkups? 🩺",
                          "Is this your first pregnancy? 👶"],
    "NUTRITION_QUERY":   ["Do you have any dietary restrictions? 🥗",
                          "Are you managing a health condition with diet? 🩺",
                          "Would you like a simple meal plan? 📋"],
    "EMERGENCY_QUERY":   [],
}
_DEFAULT_FOLLOW_UPS = ["Would you like more details? 📚",
                       "Do you have any other symptoms? 🤒",
                       "Should I explain this more simply? 💬"]

_SUGGESTIONS = [
    "💊 Medicine information", "🥗 Nutrition guidance", "🏃 Exercise tips",
    "🤰 Pregnancy advice",     "👶 Child healthcare",  "🚨 Emergency signs",
    "🧠 Mental health",        "👴 Elderly care",
]

# ── Multilingual greeting map ─────────────────────────────────────────────────
_GREETINGS: Dict[str, str] = {
    "en":  "Hello! 😊 How can I help you today?",
    "hi":  "नमस्ते! 😊 मैं आपकी कैसे मदद कर सकता हूँ?",
    "ne":  "नमस्कार! 😊 म तपाईलाई कसरी सहयोग गर्न सक्छु?",
    "bho": "नमस्कार! 😊 हम रउआ के कइसे मदद कर सकीला?",
}

# ── Multilingual emergency messages ──────────────────────────────────────────
_EMERGENCY: Dict[str, str] = {
    "en":  "🚨 EMERGENCY! Call 108 (India) / 102 (Nepal) IMMEDIATELY.\nGo to the nearest hospital NOW.",
    "hi":  "🚨 आपातकाल! अभी 108 पर कॉल करें!\nनजदीकी अस्पताल जाएं।",
    "ne":  "🚨 आपतकाल! अहिले 102 मा फोन गर्नुहोस्!\nनजिकको अस्पताल जानुहोस्।",
    "bho": "🚨 इमरजेंसी! अभी 108 पर फोन करा!\nनजदीकी अस्पताल जाव।",
}

# ── Rich offline response library (EN / HI / NE / BHO) ───────────────────────
_OFFLINE_RESPONSES: Dict[str, Dict[str, str]] = {
    "fever": {
        "en": "🌡️ **Fever Guidance**\n\nFever is a body temperature above 38°C (100.4°F).\n\n**What to do:**\n• Rest and drink plenty of fluids 💧\n• Take Paracetamol 500mg if temp > 38.5°C\n• Use a cool damp cloth on forehead\n• Wear light clothing\n\n⚠️ **See a doctor if:**\n• Temperature > 39.5°C\n• Fever lasts more than 3 days\n• Difficulty breathing, rash, or stiff neck\n\n_Always consult a healthcare professional for diagnosis._ 🩺",
        "hi": "🌡️ **बुखार के बारे में जानकारी**\n\nबुखार तब होता है जब शरीर का तापमान 38°C से ऊपर जाता है।\n\n**क्या करें:**\n• आराम करें और खूब पानी पिएं 💧\n• पैरासिटामोल 500mg लें (अगर तापमान > 38.5°C)\n• माथे पर ठंडा कपड़ा रखें\n\n⚠️ **डॉक्टर से मिलें अगर:**\n• तापमान 39.5°C से ऊपर हो\n• बुखार 3 दिन से ज़्यादा रहे\n• सांस लेने में दिक्कत हो\n\n_कृपया डॉक्टर से सलाह लें।_ 🩺",
        "ne": "🌡️ **ज्वरो बारे जानकारी**\n\nज्वरो भनेको शरीरको तापक्रम ३८°C भन्दा माथि हुनु हो।\n\n**के गर्ने:**\n• आराम गर्नुहोस् र धेरै पानी पिउनुहोस् 💧\n• प्यारासिटामोल ५०० mg लिनुहोस् (तापक्रम > ३८.५°C भए)\n• निधारमा चिसो कपडा राख्नुहोस्\n\n⚠️ **डाक्टरसँग जानुहोस् अगर:**\n• तापक्रम ३९.५°C भन्दा माथि छ\n• ज्वरो ३ दिनभन्दा बढी रहन्छ\n\n_कृपया स्वास्थ्यकर्मीसँग सल्लाह लिनुहोस्।_ 🩺",
        "bho": "🌡️ **बुखार के बारे में जानकारी**\n\nजब शरीर के तापमान ३८°C से ऊपर जाई त बुखार होला।\n\n**का करे:**\n• आराम करा आ खूब पानी पिया 💧\n• पेरासिटामोल गोली लिया\n• माथे पर ठंडा कपड़ा रखा\n\n⚠️ **डॉक्टर से मिला अगर:**\n• बुखार ३ दिन से ज्यादा रहे\n• सांस लेवे में तकलीफ होय\n\n_डॉक्टर से जरूर सलाह लिया।_ 🩺",
    },
    "headache": {
        "en": "🤕 **Headache Relief**\n\n**Immediate steps:**\n• Rest in a quiet, dark room 🛏️\n• Drink 2–3 glasses of water 💧\n• Apply cold/warm compress to forehead\n• Avoid bright screens and loud noise\n\n**Common triggers:** Stress, dehydration, poor sleep, eye strain\n\n🚨 **Seek emergency care if:**\n• Sudden severe 'thunderclap' headache\n• Headache + fever + stiff neck\n• Vision changes or weakness\n\n_Recurring headaches need medical evaluation._ 🩺",
        "hi": "🤕 **सिरदर्द से राहत**\n\n**तुरंत करें:**\n• अंधेरे शांत कमरे में आराम करें 🛏️\n• 2-3 गिलास पानी पिएं 💧\n• माथे पर ठंडा/गर्म कपड़ा रखें\n\n**आम कारण:** तनाव, पानी की कमी, नींद की कमी\n\n🚨 **आपातकाल में:**\n• अचानक तेज़ सिरदर्द\n• सिरदर्द + बुखार + गर्दन अकड़न\n\n_बार-बार होने पर डॉक्टर से मिलें।_ 🩺",
        "ne": "🤕 **टाउको दुखाइ राहत**\n\n**तुरुन्त गर्नुहोस्:**\n• अँध्यारो शान्त कोठामा आराम गर्नुहोस् 🛏️\n• २-३ गिलास पानी पिउनुहोस् 💧\n• निधारमा चिसो/तातो कपडा राख्नुहोस्\n\n🚨 **आपतकालमा:**\n• अचानक तीव्र टाउको दुखाइ\n• टाउको दुखाइ + ज्वरो + घाँटी अकडन\n\n_बारम्बार भए डाक्टरकहाँ जानुहोस्।_ 🩺",
        "bho": "🤕 **मथवा दरद से राहत**\n\n**फौरन करा:**\n• अंधेरा शांत कमरे में आराम करा 🛏️\n• पानी पिया 💧\n• माथे पर कपड़ा रखा\n\n_डॉक्टर से ज़रूर मिला।_ 🩺",
    },
    "cough": {
        "en": "😷 **Cough Management**\n\n• Honey + warm water soothes throat 🍯\n• Stay hydrated (warm fluids help) 💧\n• Steam inhalation for congestion\n• Avoid cold drinks and smoke 🚫\n• Ginger + tulsi tea can help\n\n⚠️ **See a doctor if:**\n• Cough lasts more than 2 weeks\n• Blood in cough 🩸\n• Difficulty breathing\n\n_Persistent cough may indicate TB or asthma._ 🩺",
        "hi": "😷 **खांसी का उपाय**\n\n• शहद + गर्म पानी से गला सुकून मिलता है 🍯\n• गर्म तरल पदार्थ पिएं 💧\n• भाप लें\n• ठंडा पानी और धूम्रपान से बचें 🚫\n\n⚠️ **डॉक्टर से मिलें अगर:**\n• खांसी 2 हफ़्ते से ज़्यादा हो\n• खून आए 🩸\n\n_डॉक्टर से सलाह लें।_ 🩺",
        "ne": "😷 **खोकी व्यवस्थापन**\n\n• मह + तातो पानी गला शान्त गर्छ 🍯\n• तातो तरल पदार्थ पिउनुहोस् 💧\n• भाप लिनुहोस्\n\n⚠️ **डाक्टरकहाँ जानुहोस् अगर:**\n• खोकी २ हप्तादेखि बढी छ\n• रगत आउँछ 🩸\n\n_डाक्टरसँग सल्लाह लिनुहोस्।_ 🩺",
        "bho": "😷 **खांसी के उपाय**\n\n• शहद + गर्म पानी से गला ठीक होई 🍯\n• गर्म पानी पिया 💧\n• भाप लिया\n\n_डॉक्टर से सलाह लिया।_ 🩺",
    },
    "diabetes": {
        "en": "🩺 **Diabetes Information**\n\nDiabetes is a chronic condition affecting how your body uses blood sugar.\n\n**Types:**\n• Type 1 — immune system destroys insulin cells\n• Type 2 — body doesn't use insulin properly (most common)\n• Gestational — during pregnancy\n\n**Management:**\n• Monitor blood sugar regularly 📊\n• Low-sugar, high-fiber diet 🥗\n• Exercise 30 min/day 🏃\n• Take prescribed medications 💊\n\n✅ **Good foods:** Vegetables, whole grains, lean protein\n❌ **Avoid:** Sugary drinks, white rice, sweets\n\n_Follow your doctor's treatment plan._ 🩺",
        "hi": "🩺 **मधुमेह (डायबिटीज) जानकारी**\n\nमधुमेह एक पुरानी बीमारी है जो रक्त शर्करा को प्रभावित करती है।\n\n**प्रबंधन:**\n• नियमित रूप से रक्त शर्करा जांचें 📊\n• कम चीनी, अधिक फाइबर वाला खाना 🥗\n• रोज़ 30 मिनट व्यायाम 🏃\n• डॉक्टर की दवाई लें 💊\n\n✅ **खाएं:** सब्जियां, साबुत अनाज\n❌ **परहेज:** मीठे पेय, सफ़ेद चावल\n\n_डॉक्टर की सलाह का पालन करें।_ 🩺",
        "ne": "🩺 **मधुमेह जानकारी**\n\nमधुमेह एक दीर्घकालीन अवस्था हो जसले रगतमा चिनीको स्तरलाई असर गर्छ।\n\n**व्यवस्थापन:**\n• नियमित रगत चिनी जाँच गर्नुहोस् 📊\n• कम चिनी, धेरै फाइबरयुक्त खाना 🥗\n• दैनिक ३० मिनेट व्यायाम 🏃\n\n_डाक्टरको उपचार योजना पालना गर्नुहोस्।_ 🩺",
        "bho": "🩺 **मधुमेह जानकारी**\n\nमधुमेह में खून में चीनी बढ़ जाला।\n\n**का करे:**\n• नियमित खून जांच करावा 📊\n• कम मीठा खावा 🥗\n• रोज व्यायाम करा 🏃\n\n_डॉक्टर के बताइल दवाई लिया।_ 🩺",
    },
    "pregnancy": {
        "en": "🤰 **Pregnancy Health Guide**\n\n**Essential nutrition:**\n• Folic acid (prevents neural tube defects) 💊\n• Iron-rich foods: spinach, lentils, meat 🥬\n• Calcium: milk, yogurt, paneer 🥛\n• 8-10 glasses of water daily 💧\n\n**Key checkups:** Month 1, 3, 5, 7, 8, 9\n\n🚨 **See doctor IMMEDIATELY if:**\n• Severe abdominal pain\n• Heavy bleeding\n• Severe headache + swollen face/hands\n• Baby not moving after 28 weeks\n\n_Regular prenatal care is essential for mother and baby._ 👶",
        "hi": "🤰 **गर्भावस्था स्वास्थ्य मार्गदर्शिका**\n\n**ज़रूरी पोषण:**\n• फोलिक एसिड 💊\n• आयरन: पालक, मसूर 🥬\n• कैल्शियम: दूध, दही 🥛\n• रोज़ 8-10 गिलास पानी 💧\n\n🚨 **तुरंत डॉक्टर के पास जाएं:**\n• तेज़ पेट दर्द\n• भारी रक्तस्राव\n• तेज़ सिरदर्द + सूजन\n\n_नियमित जांच ज़रूरी है।_ 🩺",
        "ne": "🤰 **गर्भावस्था स्वास्थ्य मार्गदर्शिका**\n\n**आवश्यक पोषण:**\n• फोलिक एसिड 💊\n• फलाम: पालक, मसुर 🥬\n• क्याल्सियम: दूध, दही 🥛\n\n🚨 **तुरुन्त डाक्टरकहाँ जानुहोस्:**\n• तीव्र पेट दुखाइ\n• भारी रक्तस्राव\n\n_नियमित जाँच गर्नुहोस्।_ 🩺",
        "bho": "🤰 **गर्भावस्था स्वास्थ्य**\n\n**जरूरी पोषण:**\n• फोलिक एसिड लिया 💊\n• पालक खाया 🥬\n• दूध पिया 🥛\n\n_नियमित डॉक्टर से मिला।_ 🩺",
    },
    "mental_health": {
        "en": "💙 **Mental Health Support**\n\nYour feelings are valid. You're not alone. 🤗\n\n**Right now, try:**\n• Take 5 slow deep breaths 🫁\n• Go for a short walk in fresh air 🚶\n• Talk to someone you trust 💬\n• Limit social media and news 📵\n\n**Professional help:**\n• iCall (India): 📞 9152987821\n• Vandrevala Foundation: 📞 1860-2662-345\n• Nepal: 📞 1166\n\n_Mental health matters as much as physical health._ 💚",
        "hi": "💙 **मानसिक स्वास्थ्य सहायता**\n\nआपकी भावनाएं मान्य हैं। आप अकेले नहीं हैं। 🤗\n\n**अभी करें:**\n• 5 गहरी सांसें लें 🫁\n• बाहर टहलें 🚶\n• किसी से बात करें 💬\n\n**सहायता:**\n• iCall: 📞 9152987821\n\n_मानसिक स्वास्थ्य भी उतना ही ज़रूरी है।_ 💚",
        "ne": "💙 **मानसिक स्वास्थ्य सहायता**\n\nतपाईंका भावनाहरू मान्य छन्। तपाईं एक्लो हुनुहुन्न। 🤗\n\n**अहिले गर्नुहोस्:**\n• ५ गहिरो श्वास लिनुहोस् 🫁\n• बाहिर हिँड्नुहोस् 🚶\n\n**सहायता:** 📞 1166\n\n_मानसिक स्वास्थ्य उत्तिकै महत्त्वपूर्ण छ।_ 💚",
        "bho": "💙 **मानसिक स्वास्थ्य सहायता**\n\nरउआ के भावना सही बा। रउआ अकेल नइखी। 🤗\n\n**अभी करा:**\n• गहरा सांस लिया 🫁\n• बाहर चला 🚶\n\n_iCall: 📞 9152987821_ 💚",
    },
}


# ── Follow-up banks ───────────────────────────────────────────────────────────
_FOLLOW_UPS: Dict[str, List[str]] = {
    "SYMPTOM_QUERY":       ["How long have you had these symptoms? ⏱️",
                            "Do you have a fever as well? 🌡️",
                            "Have you taken any medicine? 💊"],
    "MEDICATION_QUERY":    ["Any other medicines currently? 💊",
                            "Known allergies? ⚠️"],
    "GENERAL_MEDICAL":     ["Would you like more details? 📚",
                            "Want prevention tips? 🛡️"],
    "MENTAL_HEALTH_QUERY": ["How long feeling this way? ⏳",
                            "Would you like support resources? 📞"],
    "PREGNANCY_QUERY":     ["How many weeks pregnant? 🤰",
                            "Attending prenatal checkups? 🩺"],
    "NUTRITION_QUERY":     ["Any dietary restrictions? 🥗",
                            "Managing a health condition with diet? 🩺"],
    "EMERGENCY_QUERY":     [],
}
_DEFAULT_FOLLOW_UPS = ["Would you like more details? 📚",
                       "Any other symptoms? 🤒",
                       "Should I explain more simply? 💬"]
_SUGGESTIONS = [
    "💊 Medicine information", "🥗 Nutrition guidance",
    "🏃 Exercise tips",        "🤰 Pregnancy advice",
    "👶 Child healthcare",     "🚨 Emergency signs",
    "🧠 Mental health",        "👴 Elderly care",
]
_GREETINGS: Dict[str, str] = {
    "en":  "Hello! 😊 How can I help you today?",
    "hi":  "नमस्ते! 😊 मैं आपकी कैसे मदद कर सकता हूँ?",
    "ne":  "नमस्कार! 😊 म तपाईलाई कसरी सहयोग गर्न सक्छु?",
    "bho": "नमस्कार! 😊 हम रउआ के कइसे मदद कर सकीला?",
}
_EMERGENCY_MSG: Dict[str, str] = {
    "en":  "🚨 EMERGENCY! Call 108 (India) / 102 (Nepal) NOW.\nGo to the nearest hospital immediately.",
    "hi":  "🚨 आपातकाल! अभी 108 पर कॉल करें!\nनजदीकी अस्पताल जाएं।",
    "ne":  "🚨 आपतकाल! अहिले 102 मा फोन गर्नुहोस्!\nनजिकको अस्पताल जानुहोस्।",
    "bho": "🚨 इमरजेंसी! अभी 108 पर फोन करा!\nनजदीकी अस्पताल जाव।",
}


# ── Keyword → topic map for offline responses ─────────────────────────────────
_TOPIC_KEYWORDS: Dict[str, List[str]] = {
    "fever":        ["fever", "bukhar", "jwaro", "taato", "temperature", "bukhaar",
                     "गर्मी", "ज्वरो", "बुखार", "taapman"],
    "headache":     ["headache", "sar dard", "टाउको", "migraine", "sirdard",
                     "matha dard", "sardard", "सिरदर्द", "टाउको दुख्यो"],
    "cough":        ["cough", "khasi", "khansi", "खोकी", "खांसी", "khaasi"],
    "diabetes":     ["diabetes", "sugar", "madhumeha", "मधुमेह", "chini",
                     "blood sugar", "शुगर"],
    "pregnancy":    ["pregnant", "pregnancy", "garbhwati", "गर्भवती", "prasav",
                     "गर्भावस्था", "baccha pet mein"],
    "mental_health":["stress", "anxious", "depression", "lonely", "sad",
                     "mental", "chinta", "गहराहट", "udaas", "nind nahi",
                     "tension", "takleef man mein"],
}

def _match_topic(text: str) -> Optional[str]:
    """Find the best matching offline response topic."""
    tl = text.lower()
    for topic, keywords in _TOPIC_KEYWORDS.items():
        if any(kw in tl for kw in keywords):
            return topic
    return None

def _load_json_knowledge() -> dict:
    """Load the trained JSON knowledge base if available."""
    candidates = [
        ROOT / "ai_models" / "saved_models" / "medical_knowledge.json",
        Path(__file__).parent.parent / "saved_models" / "medical_knowledge.json",
    ]
    for p in candidates:
        if p.exists():
            try:
                with open(p, "r", encoding="utf-8") as f:
                    items = json.load(f)
                result = {}
                for item in items:
                    for kw in item.get("keywords", []):
                        result[kw.lower()] = item
                logger.info(f"Loaded JSON knowledge base: {len(items)} entries")
                return result
            except Exception as e:
                logger.warning(f"Could not load JSON knowledge: {e}")
    return {}

_JSON_KNOWLEDGE: Optional[dict] = None

def _get_json_knowledge() -> dict:
    global _JSON_KNOWLEDGE
    if _JSON_KNOWLEDGE is None:
        _JSON_KNOWLEDGE = _load_json_knowledge()
    return _JSON_KNOWLEDGE


def _offline_response(text: str, language: str) -> tuple[str, str]:
    """
    Generate offline response using dataset knowledge.
    Returns (response_text, intent).
    """
    lang = language if language in ("en", "hi", "ne", "bho") else "en"

    # Try JSON knowledge base first (trained dataset)
    jk = _get_json_knowledge()
    if jk:
        tl = text.lower()
        best_match = None
        for kw, item in jk.items():
            if kw in tl:
                best_match = item
                break
        if best_match:
            resp = best_match.get(lang) or best_match.get("en", "")
            if resp:
                intent = best_match.get("intent", "GENERAL_MEDICAL")
                return f"**{best_match['topic']}** 🩺\n\n{resp}\n\n⚠️ _This AI provides general health information only. Always consult a qualified healthcare professional._ 🏥", intent

    topic = _match_topic(text)

    if topic and topic in _OFFLINE_RESPONSES:
        resp = _OFFLINE_RESPONSES[topic].get(lang) or _OFFLINE_RESPONSES[topic]["en"]
        intent_map = {
            "fever": "SYMPTOM_QUERY", "headache": "SYMPTOM_QUERY",
            "cough": "SYMPTOM_QUERY", "diabetes": "GENERAL_MEDICAL",
            "pregnancy": "PREGNANCY_QUERY", "mental_health": "MENTAL_HEALTH_QUERY",
        }
        return resp, intent_map.get(topic, "GENERAL_MEDICAL")

    # Generic helpful offline response
    generic = {
        "en": ("🤖 **I'm here to help!**\n\n"
               "I can assist with:\n• 🤒 Symptoms\n• 💊 Medicines\n• 🥗 Nutrition\n"
               "• 🏃 Exercise\n• 🤰 Pregnancy\n• 👶 Child care\n• 🚨 Emergency\n\n"
               "Please describe your symptoms in detail.\n\n"
               "⚠️ _This AI gives general health info only. Consult a doctor._ 🩺"),
        "hi": ("🤖 **मैं यहाँ मदद के लिए हूँ!**\n\n"
               "आप क्या जानना चाहते हैं?\n• 🤒 लक्षण\n• 💊 दवाइयां\n• 🥗 पोषण\n\n"
               "⚠️ _यह AI सामान्य जानकारी देता है। डॉक्टर से ज़रूर मिलें।_ 🩺"),
        "ne": ("🤖 **म यहाँ सहयोगको लागि छु!**\n\n"
               "कृपया आफ्नो लक्षणहरू विस्तारमा बताउनुहोस्।\n\n"
               "⚠️ _यो AI सामान्य जानकारी दिन्छ। डाक्टरसँग सल्लाह लिनुहोस्।_ 🩺"),
        "bho": ("🤖 **हम मदद करे के लिए तैयार बानी!**\n\n"
                "अपना लक्षण बताया।\n\n"
                "⚠️ _डॉक्टर से ज़रूर मिला।_ 🩺"),
    }
    return generic.get(lang, generic["en"]), "GENERAL_MEDICAL"


class ChatbotEngine:
    """
    Master AI engine — Alexa/Siri-like medical assistant.
    Online: LLM (Gemini/OpenAI). Offline: FAISS + keyword responses.
    Supports EN/HI/NE/BHO.
    """
    def __init__(self, mode: ChatMode = ChatMode.AUTO, enable_tts: bool = False):
        self.mode = mode
        self.enable_tts = enable_tts
        self._translator = None
        self._intent_clf = None
        self._emergency_det = None
        self._faiss = None
        self._embeddings = None
        self._tts = None
        self._memory_store = None
        self._clf_model = None
        self._clf_vectorizer = None
        self._try_load_classifier()
        logger.info(f"ChatbotEngine ready (mode={mode})")

    def _try_load_classifier(self) -> None:
        clf_path = ROOT / "ai_models" / "saved_models" / "intent_classifier.pkl"
        if clf_path.exists():
            try:
                with open(clf_path, "rb") as f:
                    bundle = pickle.load(f)
                self._clf_vectorizer = bundle.get("vectorizer")
                self._clf_model = bundle.get("model")
                logger.info("Loaded trained intent classifier.")
            except Exception as e:
                logger.warning(f"Could not load classifier: {e}")

    def _lazy(self, attr: str, factory):
        if getattr(self, attr) is None:
            try:
                setattr(self, attr, factory())
            except Exception as e:
                logger.debug(f"Lazy load {attr} failed: {e}")
        return getattr(self, attr)

    def _get_translator(self):
        return self._lazy("_translator", lambda: __import__(
            "ai_models.translation.translator", fromlist=["get_translator"]
        ).get_translator())

    def _get_emergency(self):
        return self._lazy("_emergency_det", lambda: __import__(
            "ai_models.emergency_detection.emergency_detector",
            fromlist=["get_emergency_detector"]
        ).get_emergency_detector())

    def _get_faiss(self):
        return self._lazy("_faiss", lambda: __import__(
            "ai_models.vector_database.faiss_engine",
            fromlist=["get_faiss_engine"]
        ).get_faiss_engine())

    def _get_embeddings(self):
        return self._lazy("_embeddings", lambda: __import__(
            "ai_models.embeddings.embedding_service",
            fromlist=["get_embedding_service"]
        ).get_embedding_service())

    def _get_memory(self, conv_id: str):
        if self._memory_store is None:
            try:
                from ai_models.memory.conversation_memory import get_memory_store
                self._memory_store = get_memory_store()
            except Exception:
                return None
        return self._memory_store.get(conv_id) if self._memory_store else None

    def _classify_intent(self, text: str) -> tuple[str, float]:
        if self._clf_model and self._clf_vectorizer:
            try:
                vec = self._clf_vectorizer.transform([text.lower()])
                proba = self._clf_model.predict_proba(vec)[0]
                idx = int(proba.argmax())
                return self._clf_model.classes_[idx], float(proba[idx])
            except Exception:
                pass
        # Fallback keyword intent
        tl = text.lower()
        if any(k in tl for k in ["chest pain", "heart attack", "stroke", "bleeding",
                                   "unconscious", "can't breathe", "emergency"]):
            return "EMERGENCY_QUERY", 0.95
        if any(k in tl for k in ["fever", "headache", "cough", "pain", "symptom",
                                   "bukhar", "jwaro", "sardard", "khasi"]):
            return "SYMPTOM_QUERY", 0.80
        if any(k in tl for k in ["medicine", "tablet", "drug", "dose", "dawai"]):
            return "MEDICATION_QUERY", 0.80
        if any(k in tl for k in ["pregnant", "pregnancy", "garbhwati"]):
            return "PREGNANCY_QUERY", 0.85
        if any(k in tl for k in ["stress", "anxious", "mental", "sad", "depression"]):
            return "MENTAL_HEALTH_QUERY", 0.80
        if any(k in tl for k in ["food", "diet", "eat", "nutrition", "khana"]):
            return "NUTRITION_QUERY", 0.75
        if any(k in tl for k in ["hello", "hi", "namaste", "namaskar"]):
            return "GENERAL_CHAT", 0.90
        return "GENERAL_MEDICAL", 0.60

    def process(self, user_input: str, conversation_id: str = "default",
                language_hint: Optional[str] = None, force_offline: bool = False,
                knowledge_context: Optional[Dict] = None) -> ChatbotResponse:
        t0 = time.time()

        # 1. Language detection
        detected_lang = language_hint or "en"
        english_input = user_input
        translator = self._get_translator()
        if translator:
            try:
                det = translator.detect(user_input)
                detected_lang = det.language_code
                if detected_lang not in ("en", "auto"):
                    tr = translator.translate_to_english(user_input)
                    if tr.success and tr.translated_text:
                        english_input = tr.translated_text
            except Exception:
                pass

        lang = detected_lang if detected_lang in ("en", "hi", "ne", "bho") else "en"

        # 2. Emergency check
        is_emergency, emergency_category = False, None
        em_det = self._get_emergency()
        if em_det:
            try:
                em_result = em_det.detect(english_input, lang)
                is_emergency = em_result.is_emergency
                emergency_category = em_result.category.value if em_result.category else None
            except Exception:
                pass

        if is_emergency:
            response_text = _EMERGENCY_MSG.get(lang, _EMERGENCY_MSG["en"])
            intent, confidence = "EMERGENCY_QUERY", 1.0
            follow_ups, mode_used = [], ChatMode.OFFLINE
        else:
            # 3. Intent classification
            intent, confidence = self._classify_intent(english_input)

            # 4. Routing: online vs offline
            use_offline = force_offline or (self.mode == ChatMode.OFFLINE)
            if self.mode == ChatMode.AUTO and not force_offline:
                use_offline = not self._is_online()

            if use_offline:
                response_text, intent = _offline_response(english_input, lang)
                mode_used = ChatMode.OFFLINE
            else:
                response_text, mode_used = self._online_respond(
                    english_input, intent, knowledge_context,
                    self._get_memory(conversation_id), lang, conversation_id
                )

            # 5. Translate response back to user language
            if lang not in ("en", "auto") and translator and mode_used == ChatMode.ONLINE:
                try:
                    tr_resp = translator.translate_response(response_text, lang)
                    if tr_resp.success and tr_resp.translated_text:
                        response_text = tr_resp.translated_text
                except Exception:
                    pass

            follow_ups = _FOLLOW_UPS.get(intent, _DEFAULT_FOLLOW_UPS)[:3]

        # 6. TTS (optional)
        audio_bytes, audio_fmt = None, "mp3"
        if self.enable_tts and response_text:
            try:
                from ai_models.speech.text_to_speech import get_tts_service
                tts_result = get_tts_service().synthesize(response_text[:600], language=lang)
                if tts_result.success:
                    audio_bytes = tts_result.audio_bytes
                    audio_fmt   = tts_result.format
            except Exception:
                pass

        # 7. Memory
        mem = self._get_memory(conversation_id)
        if mem:
            try:
                mem.add_turn(user_input, response_text, lang, intent, is_emergency)
            except Exception:
                pass

        return ChatbotResponse(
            text=response_text, language=lang, mode=mode_used,
            intent=intent, is_emergency=is_emergency,
            emergency_category=emergency_category,
            follow_up_questions=follow_ups,
            suggestions=_SUGGESTIONS[:4] if not is_emergency else [],
            confidence=confidence, response_time=time.time() - t0,
            audio_bytes=audio_bytes, audio_format=audio_fmt,
        )

    def _online_respond(self, english_input: str, intent: str,
                        knowledge_context, memory, lang: str,
                        conv_id: str) -> tuple[str, ChatMode]:
        try:
            from backend.app.medical_chatbot.services.llm_service import get_llm_service
            from backend.app.medical_chatbot.services.prompt_builder import PromptBuilder
            import asyncio
            history = memory.get_history_for_prompt(last_n=6) if memory else []
            pb = PromptBuilder()
            prompt = pb.build_chat_prompt(
                user_question=english_input, conversation_history=history,
                knowledge_context=knowledge_context, language=lang
            )
            llm = get_llm_service()
            loop = asyncio.new_event_loop()
            result = loop.run_until_complete(
                llm.generate_response(prompt, conversation_id=conv_id)
            )
            loop.close()
            return result["response"], ChatMode.ONLINE
        except Exception as exc:
            logger.warning(f"Online LLM failed, using offline: {exc}")
            resp, _ = _offline_response(english_input, lang)
            return resp, ChatMode.OFFLINE

    @staticmethod
    def _is_online() -> bool:
        import socket
        try:
            socket.setdefaulttimeout(2)
            socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect(("8.8.8.8", 53))
            return True
        except Exception:
            return False

    def get_greeting(self, language: str = "en") -> str:
        return _GREETINGS.get(language, _GREETINGS["en"])

# ── Singleton ─────────────────────────────────────────────────────────────────
_engine: Optional[ChatbotEngine] = None

def get_chatbot_engine(mode: ChatMode = ChatMode.AUTO,
                       enable_tts: bool = False) -> ChatbotEngine:
    global _engine
    if _engine is None:
        _engine = ChatbotEngine(mode=mode, enable_tts=enable_tts)
    return _engine
