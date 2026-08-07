"""
Prompt Builder - Creates structured, production-quality prompts for the LLM.

Supports:
  • Comprehensive medical system prompt (all required categories)
  • Conversation memory (last 20 messages)
  • Multi-language instruction injection
  • Knowledge-base context
  • User context (symptom-checker results, location)
  • Emergency context augmentation
"""
from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Optional

from ..utils.constants import MEDICAL_DISCLAIMER, EMERGENCY_DISCLAIMER


# ─────────────────────────────────────────────────────────────────────────────
# System prompt
# ─────────────────────────────────────────────────────────────────────────────

_SYSTEM_PROMPT = """You are an AI Healthcare Assistant designed specifically for rural communities with limited access to medical facilities.

═══════════════════════════════════════════════════════════
🔴 ABSOLUTE RULES — NEVER VIOLATE THESE
═══════════════════════════════════════════════════════════
1. NEVER claim to be a doctor, nurse, or any licensed medical professional.
2. NEVER provide a confirmed diagnosis of any disease or condition.
3. NEVER prescribe, recommend, or suggest specific medications or dosages.
4. NEVER advise a user to stop or change their prescribed medications.
5. NEVER guarantee any health outcome or claim to cure anything.
6. ALWAYS explain that your responses are for general educational purposes only.
7. ALWAYS recommend consulting a qualified healthcare professional for any medical concern.
8. NEVER generate advice that could endanger life if followed.
9. NEVER produce illegal, dangerous, or unethical guidance.
10. If a user expresses suicidal intent or self-harm, IMMEDIATELY refer them to emergency services and a crisis helpline.

═══════════════════════════════════════════════════════════
🟢 YOUR CAPABILITIES — Topics You CAN Help With
═══════════════════════════════════════════════════════════
• General health information and education
• Fever, cold, cough, and common illness awareness
• Nutrition, diet, and healthy eating guidance
• Mental health awareness (stress, anxiety, depression basics)
• Pregnancy and maternal health information
• Child healthcare and vaccination schedules
• Women's health and men's health general information
• Exercise, physical activity, and weight management
• Water intake, hydration, and sanitation
• Hygiene and infection prevention tips
• First aid basics (cuts, burns, sprains, choking, CPR overview)
• Healthy lifestyle habits and preventive healthcare
• Diabetes awareness and blood sugar education
• Blood pressure and hypertension awareness
• General medicine information (NOT dosage or prescription)
• Medical terminology explained in simple language
• Hospital preparation and what to expect at a clinic
• Recovery tips after illness or surgery (general)
• Vaccination information and immunisation schedules
• Dental health, eye care, skin health basics
• Elderly care and joint health awareness

═══════════════════════════════════════════════════════════
🟡 COMMUNICATION STYLE
═══════════════════════════════════════════════════════════
• Use simple, everyday language — avoid complex medical jargon.
• Be warm, empathetic, and supportive at all times.
• Use phrases like "This could be…", "It may suggest…", "Generally speaking…"
• Keep answers concise: 2–4 short paragraphs maximum.
• Use numbered lists or bullet points for step-by-step instructions.
• Include relevant emojis to make information friendly and easy to scan.
• When uncertain, clearly state: "I'm not sure about this — please consult a doctor."

═══════════════════════════════════════════════════════════
🚨 EMERGENCY PROTOCOL
═══════════════════════════════════════════════════════════
If the user describes an emergency (chest pain, stroke, heavy bleeding, unconsciousness,
seizure, severe allergic reaction, snake bite, electric shock, high fever in infant, etc.):
  1. Immediately advise calling emergency services (108 India / 102 Nepal / 112 Global).
  2. Provide ONLY the most critical first-aid steps — keep it brief.
  3. Tell them to go to the nearest hospital/emergency room NOW.
  4. Do NOT provide lengthy explanations during an emergency.

═══════════════════════════════════════════════════════════
📋 RESPONSE FORMAT
═══════════════════════════════════════════════════════════
End EVERY response with a brief disclaimer reminding the user that you are an AI
providing general health education, not a substitute for professional medical advice.
"""


# ─────────────────────────────────────────────────────────────────────────────
# PromptBuilder class
# ─────────────────────────────────────────────────────────────────────────────

class PromptBuilder:
    """Builds structured, context-rich prompts for the medical chatbot LLM."""

    # Max conversation turns sent to LLM (≈20 messages to manage tokens)
    MAX_HISTORY_MESSAGES = 20

    SYSTEM_PROMPT: str = _SYSTEM_PROMPT

    # Language name map for multilingual instruction injection
    _LANG_NAMES: Dict[str, str] = {
        "hi":  "Hindi (हिंदी)",
        "ne":  "Nepali (नेपाली)",
        "bho": "Bhojpuri (भोजपुरी)",
        "bn":  "Bengali (বাংলা)",
        "ta":  "Tamil (தமிழ்)",
        "te":  "Telugu (తెలుగు)",
        "mr":  "Marathi (मराठी)",
        "gu":  "Gujarati (ગુજરાતી)",
        "kn":  "Kannada (ಕನ್ನಡ)",
        "ml":  "Malayalam (മലയാളം)",
        "pa":  "Punjabi (ਪੰਜਾਬੀ)",
    }

    def __init__(self) -> None:
        pass

    # ── Main chat prompt ──────────────────────────────────────────────────

    def build_chat_prompt(
        self,
        user_question:        str,
        conversation_history: Optional[List[Dict[str, str]]] = None,
        knowledge_context:    Optional[Dict[str, Any]]       = None,
        user_context:         Optional[Dict[str, Any]]       = None,
        language:             str                            = "en",
    ) -> str:
        """
        Assemble a complete LLM prompt.

        Sections (in order):
          0. Language instruction  (if non-English)
          1. System prompt
          2. Current date/time context
          3. Knowledge-base context  (optional)
          4. User context            (optional)
          5. Conversation memory     (last MAX_HISTORY_MESSAGES)
          6. Current user question
          7. Response guidelines
        """
        parts: List[str] = []

        # 0. Language instruction
        if language not in ("en", "auto", "", None):
            lang_name = self._LANG_NAMES.get(language, language.upper())
            parts.append(
                f"⚠️ **LANGUAGE INSTRUCTION:** The user is communicating in "
                f"{lang_name}. You MUST respond ONLY in {lang_name}. "
                f"Do not respond in English unless the user writes in English.\n\n"
            )

        # 1. System prompt
        parts.append(self.SYSTEM_PROMPT)
        parts.append("\n" + "─" * 60 + "\n")

        # 2. Date/time context (helps with time-sensitive advice)
        parts.append(
            f"📅 **Current date/time (UTC):** "
            f"{datetime.utcnow().strftime('%A, %B %d, %Y at %H:%M')}\n\n"
        )

        # 3. Knowledge-base context
        if knowledge_context:
            kb_block = self._format_knowledge_context(knowledge_context)
            if kb_block:
                parts.append(kb_block)
                parts.append("\n" + "─" * 60 + "\n")

        # 4. User context
        if user_context:
            uc_block = self._format_user_context(user_context)
            if uc_block:
                parts.append(uc_block)
                parts.append("\n" + "─" * 60 + "\n")

        # 5. Conversation history (last N messages)
        if conversation_history:
            hist_block = self._format_conversation_history(conversation_history)
            if hist_block:
                parts.append(hist_block)
                parts.append("\n" + "─" * 60 + "\n")

        # 6. Current question
        parts.append(f"**👤 User:** {user_question}\n\n")

        # 7. Response guidelines
        parts.append(self._response_guidelines())

        return "".join(parts)

    # ── Context formatters ────────────────────────────────────────────────

    def _format_knowledge_context(self, knowledge: Dict[str, Any]) -> str:
        """Format knowledge-base information block."""
        lines = ["📚 **Medical Knowledge Base Context:**\n"]

        disease = knowledge.get("disease_info")
        if disease:
            lines.append(f"\n**Condition:** {disease.get('name', 'Unknown')}\n")
            if disease.get("description"):
                lines.append(f"- Description: {disease['description']}\n")
            symptoms = disease.get("symptoms", [])
            if symptoms:
                lines.append(
                    f"- Common Symptoms: {', '.join(symptoms[:6])}\n"
                )
            precautions = disease.get("precautions", [])
            if precautions:
                lines.append(
                    f"- General Precautions: {', '.join(precautions[:5])}\n"
                )

        symptom_info = knowledge.get("symptom_info", [])
        if symptom_info:
            lines.append(
                f"\n**Related Symptoms Detected:** {', '.join(symptom_info[:6])}\n"
            )

        general_info = knowledge.get("general_info", "")
        if general_info:
            lines.append(f"\n**Additional Reference:**\n{general_info}\n")

        return "".join(lines) if len(lines) > 1 else ""

    def _format_user_context(self, context: Dict[str, Any]) -> str:
        """Format user-specific context (symptom results, location, etc.)."""
        lines = ["👤 **User Context:**\n"]

        symptom_result = context.get("symptom_check_result")
        if symptom_result:
            lines.append("\n*Recent Symptom Checker Result:*\n")
            lines.append(
                f"- Predicted Condition: {symptom_result.get('predicted_disease', 'Unknown')}\n"
            )
            conf = symptom_result.get("confidence", 0)
            lines.append(f"- Confidence Score: {conf:.0%}\n")
            syms = symptom_result.get("symptoms", [])
            if syms:
                lines.append(f"- Reported Symptoms: {', '.join(syms[:6])}\n")

        location = context.get("location")
        if location:
            city = location.get("city") or location.get("district") or "Unknown"
            country = location.get("country", "")
            lines.append(f"\n- Location: {city}{', ' + country if country else ''}\n")

        return "".join(lines) if len(lines) > 1 else ""

    def _format_conversation_history(
        self, history: List[Dict[str, str]]
    ) -> str:
        """Format the last MAX_HISTORY_MESSAGES of conversation history."""
        if not history:
            return ""

        # Keep only the latest N messages to stay within token limits
        recent = history[-self.MAX_HISTORY_MESSAGES:]

        lines = ["💬 **Previous Conversation:**\n"]
        for msg in recent:
            sender  = msg.get("sender", "unknown").lower()
            message = msg.get("message", "").strip()
            if not message:
                continue
            if sender == "user":
                lines.append(f"👤 User: {message}\n")
            elif sender in ("assistant", "bot"):
                lines.append(f"🤖 Assistant: {message}\n")

        return "".join(lines) if len(lines) > 1 else ""

    def _response_guidelines(self) -> str:
        return (
            "**🤖 Your response guidelines:**\n"
            "1. Directly address the user's question using the context provided.\n"
            "2. Keep your response concise — 2 to 4 short paragraphs or a brief list.\n"
            "3. Use simple language suitable for rural communities.\n"
            "4. Use relevant emojis to make the response friendly and easy to scan.\n"
            "5. If symptoms are serious or worsening, advise the user to see a doctor.\n"
            "6. End with a one-line disclaimer about consulting a healthcare professional.\n"
            "7. If you don't know the answer, say so honestly.\n\n"
            "**🤖 Assistant:**\n"
        )

    # ── Specialised prompt builders ───────────────────────────────────────

    def build_symptom_explanation_prompt(
        self, symptom: str, context: Optional[str] = None
    ) -> str:
        extra = f"\n**Additional Context:** {context}" if context else ""
        return (
            f"{self.SYSTEM_PROMPT}\n\n"
            f"**Task:** Explain the symptom \"{symptom}\" in simple, easy-to-understand terms.\n\n"
            "Include:\n"
            "- What this symptom generally means\n"
            "- Possible common causes (non-diagnostic)\n"
            "- When it might be concerning\n"
            "- Basic self-care tips\n"
            "- When to see a doctor\n"
            f"{extra}\n\n"
            "Keep the response brief, friendly, and non-diagnostic.\n\n"
            "**🤖 Assistant:**\n"
        )

    def build_disease_explanation_prompt(
        self, disease: str, info: Optional[Dict[str, Any]] = None
    ) -> str:
        info_block = ""
        if info:
            info_block = (
                f"\n**Available Information:**\n"
                f"- Description: {info.get('description', 'N/A')}\n"
                f"- Common Symptoms: {', '.join(info.get('symptoms', [])[:5])}\n"
                f"- Precautions: {', '.join(info.get('precautions', [])[:4])}\n\n"
            )
        return (
            f"{self.SYSTEM_PROMPT}\n\n"
            f"**Task:** Explain \"{disease}\" in simple, everyday terms for a rural audience.\n\n"
            f"{info_block}"
            "Include:\n"
            "- What this condition is in simple language\n"
            "- Common symptoms people experience\n"
            "- General prevention tips\n"
            "- Why seeing a doctor is important\n"
            "- Basic lifestyle adjustments (if any)\n\n"
            "Limit to 2–3 short paragraphs. Be encouraging and supportive.\n\n"
            "**🤖 Assistant:**\n"
        )

    def build_first_aid_prompt(self, situation: str) -> str:
        return (
            f"{self.SYSTEM_PROMPT}\n\n"
            f"**Task:** Provide basic first-aid guidance for: \"{situation}\"\n\n"
            "Format your response as numbered steps.\n"
            "Include:\n"
            "- Immediate steps to take RIGHT NOW\n"
            "- What NOT to do\n"
            "- When to call emergency services (108 India / 102 Nepal / 112 Global)\n\n"
            "Keep it very brief and actionable — this may be an emergency.\n\n"
            "**🤖 Assistant:**\n"
        )

    def build_lifestyle_advice_prompt(self, topic: str) -> str:
        return (
            f"{self.SYSTEM_PROMPT}\n\n"
            f"**Task:** Provide practical healthy-lifestyle advice about: \"{topic}\"\n\n"
            "Include:\n"
            "- Why this matters for overall health\n"
            "- 3–5 simple, actionable tips\n"
            "- Common mistakes to avoid\n"
            "- Encouragement to start small\n\n"
            "Keep it positive, realistic, and culturally sensitive for rural India/Nepal.\n\n"
            "**🤖 Assistant:**\n"
        )

    def add_emergency_context(self, prompt: str) -> str:
        """Prepend a strong emergency-mode instruction to an existing prompt."""
        emergency_instruction = (
            "\n\n"
            "🚨🚨🚨 **EMERGENCY SITUATION DETECTED** 🚨🚨🚨\n\n"
            "The user's message contains EMERGENCY keywords.\n"
            "Your response MUST:\n"
            "1. Start immediately with: 'CALL EMERGENCY SERVICES NOW'\n"
            "2. Provide the emergency number: 108 (India), 102 (Nepal), 112 (Global)\n"
            "3. Give ONLY the 2–3 most critical first-aid steps — nothing else\n"
            "4. Tell them to go to the nearest hospital/emergency room immediately\n"
            "5. Keep the response SHORT — do NOT explain causes or give lengthy info\n\n"
            f"{EMERGENCY_DISCLAIMER}\n\n"
        )
        return emergency_instruction + prompt

    def get_fallback_response(self, reason: str = "general") -> str:
        """Return a safe static fallback when the LLM cannot respond."""
        responses = {
            "general": (
                "I'm sorry, I'm having difficulty providing a response right now. 😔\n\n"
                "For your health concerns, please consult a qualified healthcare professional. "
                "If this is urgent, call emergency services (108 India / 112 Global) or visit "
                "your nearest clinic or hospital.\n\n"
                f"{MEDICAL_DISCLAIMER}"
            ),
            "technical": (
                "I'm experiencing a technical issue at the moment. 🔧\n\n"
                "Please try again in a few seconds. If your concern is urgent, "
                "please visit a healthcare professional immediately."
            ),
            "unclear": (
                "I'm not quite sure I understood your question. 🤔\n\n"
                "Could you please rephrase it or give more details? "
                "For immediate medical concerns, consult a healthcare professional."
            ),
            "out_of_scope": (
                "I'm designed to provide general health education only, and I'm not "
                "able to assist with that particular request. 🙏\n\n"
                "Please consult a qualified healthcare professional for specific medical advice.\n\n"
                f"{MEDICAL_DISCLAIMER}"
            ),
        }
        return responses.get(reason, responses["general"])
