"""
AI Chat Service — OpenRouter primary, Gemini / Groq fallback.

Uses OpenRouter free tier with automatic model failover when a model is
rate-limited.  No paid credits needed.

Environment variables (backend/.env):
    CHATBOT_OPENROUTER_API_KEY   = sk-or-v1-...
    CHATBOT_OPENROUTER_MODEL     = google/gemma-4-26b-a4b-it:free
    CHATBOT_LLM_API_KEY          = AIzaSy...  (Gemini fallback, optional)
    CHATBOT_LLM_MAX_TOKENS       = 800
    CHATBOT_LLM_TEMPERATURE      = 0.7
    CHATBOT_LLM_REQUEST_TIMEOUT  = 60
"""
from __future__ import annotations

import asyncio
import os
import time
from typing import Any, Dict, List, Optional

from ..utils.logger import logger

# ─────────────────────────────────────────────────────────────────────────────
# System prompt (concise to reduce latency on free models)
# ─────────────────────────────────────────────────────────────────────────────

MEDICAL_SYSTEM_PROMPT = """You are an AI Healthcare Assistant for Rural Areas.

RULES:
- Never diagnose diseases or prescribe medicines.
- Always recommend consulting a doctor for medical concerns.
- Keep replies concise (2-3 paragraphs or a short bullet list).
- Use simple, friendly language with helpful emojis.
- **IMPORTANT LANGUAGE RULES:**
  * If user speaks ENGLISH → Reply in English (Latin script)
  * If user speaks HINDI → Reply in PURE HINDI using Devanagari script (हिंदी)
  * If user speaks NEPALI → Reply in PURE NEPALI using Devanagari script (नेपाली)
  * If user speaks BHOJPURI → Reply in PURE BHOJPURI using Devanagari script (भोजपुरी)
  * NEVER use Romanized text (Latin script) for Hindi/Nepali/Bhojpuri
  * ALWAYS write Hindi/Nepali/Bhojpuri in their native Devanagari script
- For emergencies: immediately tell them to call 108 (India) / 102 (Nepal) / 112 (Global).
- End every reply with: ⚠️ I am an AI providing general health education only — always consult a qualified doctor.

You can assist with: symptoms, nutrition, first aid basics, child health, pregnancy awareness,
diabetes/BP/asthma awareness, hygiene, mental health basics, vaccination schedules.
"""

# ─────────────────────────────────────────────────────────────────────────────
# Free OpenRouter models — tried in order when rate-limited
# ─────────────────────────────────────────────────────────────────────────────

FREE_MODELS_FALLBACK = [
    "google/gemma-4-26b-a4b-it:free",
    "google/gemma-4-31b-it:free",
    "nvidia/nemotron-3-super-120b-a12b:free",
    "nvidia/nemotron-3-nano-30b-a3b:free",
    "nvidia/nemotron-nano-9b-v2:free",
    "openai/gpt-oss-20b:free",
    "nvidia/nemotron-3-ultra-550b-a55b:free",
    "inclusionai/ling-3.0-tiny:free",
    "poolside/laguna-xs-2.1:free",
]

# ─────────────────────────────────────────────────────────────────────────────
# Emergency detection — runs BEFORE any API call
# ─────────────────────────────────────────────────────────────────────────────

_EMERGENCY_KEYWORDS = [
    "chest pain", "heart attack", "cardiac arrest",
    "can't breathe", "cannot breathe", "difficulty breathing", "not breathing",
    "severe bleeding", "heavy bleeding",
    "stroke", "face drooping", "slurred speech", "sudden numbness",
    "unconscious", "not responding", "fainted",
    "seizure", "convulsion",
    "overdose", "swallowed poison", "poisoning",
    "snake bite", "snakebite",
    "severe injury", "electric shock",
    "सीने में दर्द", "सांस नहीं", "बेहोश", "साँप ने काटा",
    "छाती दुख्यो", "saans nahi",
]
_MENTAL_HEALTH_KEYWORDS = [
    "suicide", "kill myself", "want to die", "end my life",
    "self harm", "self-harm", "cutting myself",
    "खुदकुशी", "आत्महत्या",
]

_EMERGENCY_RESPONSE = (
    "🚨 **EMERGENCY — CALL EMERGENCY SERVICES NOW!**\n\n"
    "📞 **108** (Ambulance — India) | **102** (Nepal) | **112** (Global)\n\n"
    "**While waiting for help:**\n"
    "1. Stay calm and keep the person still.\n"
    "2. Loosen tight clothing around neck and chest.\n"
    "3. Do NOT give food, water, or medication by mouth.\n"
    "4. Turn them on their side if unconscious or vomiting.\n"
    "5. Start CPR if the person is not breathing and you know how.\n\n"
    "⚠️ Do not rely on this chatbot in an emergency — get professional help immediately!"
)
_MENTAL_HEALTH_RESPONSE = (
    "🚨 **MENTAL HEALTH CRISIS — YOU ARE NOT ALONE** 💙\n\n"
    "📞 **iCall (India):** 9152987821\n"
    "📞 **Vandrevala Foundation:** 1860-2662-345 (24/7)\n"
    "📞 **Emergency:** 108 (India) | 112 (Global)\n\n"
    "Your life has value. Please talk to someone you trust, "
    "or go to the nearest hospital emergency room if you feel unsafe right now.\n\n"
    "⚠️ Please seek help immediately — you do not have to face this alone."
)


# ─────────────────────────────────────────────────────────────────────────────
# GeminiService  (name kept for compatibility — now OpenRouter-first)
# ─────────────────────────────────────────────────────────────────────────────

class GeminiService:
    """
    Online AI service for the medical chatbot.

    Provider priority:
      1. OpenRouter  (CHATBOT_OPENROUTER_API_KEY)
      2. Gemini      (CHATBOT_LLM_API_KEY — AIzaSy... only)
      3. Groq        (CHATBOT_GROQ_API_KEY)
    """

    MAX_HISTORY_MESSAGES: int = 20

    def __init__(self) -> None:
        self.temperature: float = float(os.getenv("CHATBOT_LLM_TEMPERATURE", "0.7"))
        self.max_tokens: int    = int(os.getenv("CHATBOT_LLM_MAX_TOKENS", "800"))
        self.timeout: int       = int(os.getenv("CHATBOT_LLM_REQUEST_TIMEOUT", "60"))

        self._provider: str  = "none"
        self._client         = None   # openai.OpenAI for OpenRouter/Groq
        self._gemini_client  = None   # google.genai.Client
        self.model: str      = ""
        self.api_key: str    = ""

        # Compatibility attributes (used by health-check controller)
        self._use_new_sdk: bool    = False
        self._is_oauth_token: bool = False

        self._initialize()

    # ── Initialization ─────────────────────────────────────────────────────

    def _initialize(self) -> None:
        if self._init_openrouter():
            return
        if self._init_gemini():
            return
        if self._init_groq():
            return
        raise RuntimeError(
            "No AI provider configured.\n"
            "Set CHATBOT_OPENROUTER_API_KEY in backend/.env\n"
            "Get a free key at: https://openrouter.ai/keys"
        )

    def _init_openrouter(self) -> bool:
        key = os.getenv("CHATBOT_OPENROUTER_API_KEY", "").strip()
        if not key or key == "YOUR_OPENROUTER_KEY_HERE":
            return False
        try:
            from openai import OpenAI  # type: ignore
            self._client = OpenAI(
                api_key=key,
                base_url="https://openrouter.ai/api/v1",
            )
            self._provider = "openrouter"
            self.model = os.getenv(
                "CHATBOT_OPENROUTER_MODEL", "google/gemma-4-26b-a4b-it:free"
            )
            self.api_key = key
            logger.info(f"✅ AI Service ready: OpenRouter ({self.model})")
            return True
        except Exception as exc:
            logger.warning(f"OpenRouter init failed: {exc}")
            return False

    def _init_gemini(self) -> bool:
        key = os.getenv("CHATBOT_LLM_API_KEY", "").strip()
        if not key or key in ("YOUR_GEMINI_API_KEY_HERE", "") or key.startswith("AQ."):
            return False
        try:
            from google import genai  # type: ignore
            self._gemini_client = genai.Client(api_key=key)
            self._provider = "gemini"
            self.model = os.getenv("CHATBOT_LLM_MODEL", "gemini-2.0-flash")
            self.api_key = key
            self._use_new_sdk = True
            logger.info(f"✅ AI Service ready: Gemini ({self.model})")
            return True
        except Exception as exc:
            logger.warning(f"Gemini init failed: {exc}")
            return False

    def _init_groq(self) -> bool:
        key = os.getenv("CHATBOT_GROQ_API_KEY", "").strip()
        if not key or key == "YOUR_GROQ_KEY_HERE":
            return False
        try:
            from groq import Groq  # type: ignore
            self._client = Groq(api_key=key)
            self._provider = "groq"
            self.model = os.getenv("CHATBOT_GROQ_MODEL", "llama-3.3-70b-versatile")
            self.api_key = key
            logger.info(f"✅ AI Service ready: Groq ({self.model})")
            return True
        except Exception as exc:
            logger.warning(f"Groq init failed: {exc}")
            return False

    # ── Emergency detection ────────────────────────────────────────────────

    @staticmethod
    def _detect_emergency(message: str) -> Optional[str]:
        msg = message.lower()
        for kw in _MENTAL_HEALTH_KEYWORDS:
            if kw in msg:
                return _MENTAL_HEALTH_RESPONSE
        for kw in _EMERGENCY_KEYWORDS:
            if kw in msg:
                return _EMERGENCY_RESPONSE
        return None

    # ── Prompt building ────────────────────────────────────────────────────

    @staticmethod
    def _get_language_instruction(language: str) -> str:
        """Get explicit language instruction for the AI based on selected language."""
        language_map = {
            "en": "Reply in ENGLISH using Latin script.",
            "hi": "Reply in PURE HINDI using ONLY Devanagari script (हिंदी में उत्तर दें). NEVER use Romanized/Latin script for Hindi.",
            "ne": "Reply in PURE NEPALI using ONLY Devanagari script (नेपालीमा जवाफ दिनुहोस्). NEVER use Romanized/Latin script for Nepali.",
            "bho": "Reply in PURE BHOJPURI using ONLY Devanagari script (भोजपुरी में जवाब दीं). NEVER use Romanized/Latin script for Bhojpuri.",
        }
        return language_map.get(language, language_map["en"])

    @staticmethod
    def _build_messages(
        user_message: str,
        history: Optional[List[Dict[str, str]]],
        language: str = "en",
    ) -> List[Dict[str, str]]:
        """Chat-completion messages array (OpenRouter / Groq)."""
        # Add language-specific instruction to system prompt
        lang_instruction = GeminiService._get_language_instruction(language)
        system_prompt = f"{MEDICAL_SYSTEM_PROMPT}\n\n**LANGUAGE FOR THIS CONVERSATION:** {lang_instruction}"
        
        messages: List[Dict[str, str]] = [
            {"role": "system", "content": system_prompt}
        ]
        if history:
            for turn in history[-GeminiService.MAX_HISTORY_MESSAGES:]:
                role    = turn.get("role", "").lower()
                content = turn.get("content", "").strip()
                if content and role in ("user", "assistant"):
                    messages.append({"role": role, "content": content})
        messages.append({"role": "user", "content": user_message})
        return messages

    @staticmethod
    def _build_full_prompt(
        user_message: str,
        history: Optional[List[Dict[str, str]]],
        language: str = "en",
    ) -> str:
        """Plain-text prompt for Gemini (non-chat SDK)."""
        lang_instruction = GeminiService._get_language_instruction(language)
        parts = [
            MEDICAL_SYSTEM_PROMPT,
            f"\n**LANGUAGE FOR THIS CONVERSATION:** {lang_instruction}\n",
            "\n" + "─" * 60 + "\n"
        ]
        if history:
            for turn in history[-GeminiService.MAX_HISTORY_MESSAGES:]:
                role    = turn.get("role", "").lower()
                content = turn.get("content", "").strip()
                if content:
                    label = "User" if role == "user" else "Assistant"
                    parts.append(f"{label}: {content}\n")
            parts.append("─" * 60 + "\n")
        parts.append(f"User: {user_message}\n\nAssistant:\n")
        return "".join(parts)

    # ── Generation ─────────────────────────────────────────────────────────

    async def _call_openai_compat(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
    ) -> str:
        """Call OpenRouter or Groq via the OpenAI-compatible SDK."""
        use_model = model or self.model
        loop = asyncio.get_event_loop()

        def _sync() -> str:
            resp = self._client.chat.completions.create(
                model=use_model,
                messages=messages,
                temperature=self.temperature,
                max_tokens=self.max_tokens,
            )
            return resp.choices[0].message.content or ""

        text = await loop.run_in_executor(None, _sync)
        if not text.strip():
            raise RuntimeError("AI returned an empty response.")
        return text.strip()

    async def _call_gemini(self, prompt: str) -> str:
        from google.genai import types  # type: ignore
        config = types.GenerateContentConfig(
            temperature=self.temperature,
            max_output_tokens=self.max_tokens,
        )
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: self._gemini_client.models.generate_content(
                model=self.model, contents=prompt, config=config
            ),
        )
        text = response.text
        if not text or not text.strip():
            raise RuntimeError("Gemini returned an empty response.")
        return text.strip()

    # ── Public interface ────────────────────────────────────────────────────

    async def chat(
        self,
        user_message: str,
        history: Optional[List[Dict[str, str]]] = None,
        language: str = "en",
    ) -> Dict[str, Any]:
        """
        Send a message to the AI with automatic model failover.

        Returns:
            reply, emergency, tokens_used, response_time, model, provider
        """
        start = time.time()

        # Step 1 — Emergency shortcut (no API call needed)
        emergency_reply = self._detect_emergency(user_message)
        if emergency_reply:
            return {
                "reply":         emergency_reply,
                "emergency":     True,
                "tokens_used":   0,
                "response_time": time.time() - start,
                "model":         self.model,
                "provider":      self._provider,
            }

        # Step 2 — Call AI with failover
        reply_text = ""
        used_model = self.model

        if self._provider in ("openrouter", "groq"):
            messages = self._build_messages(user_message, history, language)
            # Try primary model, then fallbacks if rate-limited
            models_to_try = [self.model] + [
                m for m in FREE_MODELS_FALLBACK if m != self.model
            ]
            last_error: Exception = RuntimeError("No model available.")

            for attempt_model in models_to_try:
                try:
                    reply_text = await asyncio.wait_for(
                        self._call_openai_compat(messages, model=attempt_model),
                        timeout=self.timeout,
                    )
                    used_model = attempt_model
                    # Update primary model to the one that worked
                    if attempt_model != self.model:
                        logger.info(f"Switched to model: {attempt_model}")
                        self.model = attempt_model
                    break
                except asyncio.TimeoutError:
                    last_error = TimeoutError(
                        f"⌛ AI timed out after {self.timeout}s. Please try again."
                    )
                    break  # timeout = don't try more models
                except Exception as exc:
                    err = str(exc).lower()
                    if "429" in err or "rate" in err or "quota" in err or "upstream" in err:
                        logger.warning(f"Rate limited on {attempt_model}, trying next...")
                        last_error = exc
                        continue  # try next model
                    # Any other error — map and raise
                    last_error = exc
                    break
            else:
                # All models exhausted
                raise RuntimeError(
                    "⏳ All free AI models are currently rate-limited. "
                    "Please wait 1 minute and try again."
                )

            if not reply_text:
                err_msg = str(last_error).lower()
                if "timeout" in err_msg or "timed out" in err_msg:
                    raise TimeoutError(str(last_error))
                if "401" in err_msg or "403" in err_msg or "api_key" in err_msg:
                    raise ValueError(
                        "🔑 AI authentication failed. Check CHATBOT_OPENROUTER_API_KEY in backend/.env"
                    )
                raise RuntimeError(
                    "⏳ AI service is temporarily busy. Please try again in a moment."
                )

        elif self._provider == "gemini":
            try:
                prompt = self._build_full_prompt(user_message, history, language)
                reply_text = await asyncio.wait_for(
                    self._call_gemini(prompt), timeout=self.timeout
                )
            except asyncio.TimeoutError:
                raise TimeoutError(
                    f"⌛ AI response timed out after {self.timeout}s. Please try again."
                )
            except Exception as exc:
                err = str(exc).lower()
                if "quota" in err or "429" in err:
                    raise RuntimeError("⏳ Gemini quota exceeded. Please try again.")
                raise RuntimeError(f"Gemini error: {exc}")
        else:
            raise RuntimeError("No AI provider configured.")

        elapsed = time.time() - start
        logger.info(
            f"AI reply in {elapsed:.2f}s | {self._provider}/{used_model} | "
            f"~{len(reply_text.split())} tokens"
        )

        return {
            "reply":         reply_text,
            "emergency":     False,
            "tokens_used":   len(reply_text.split()),
            "response_time": elapsed,
            "model":         used_model,
            "provider":      self._provider,
        }

    async def health_check(self) -> Dict[str, Any]:
        try:
            result = await asyncio.wait_for(
                self.chat("Reply with one word: OK"), timeout=20
            )
            return {
                "status":   "healthy" if result.get("reply") else "unhealthy",
                "provider": self._provider,
                "model":    self.model,
            }
        except Exception as exc:
            return {
                "status":   "unhealthy",
                "provider": self._provider,
                "error":    str(exc),
            }


# ─────────────────────────────────────────────────────────────────────────────
# Singleton
# ─────────────────────────────────────────────────────────────────────────────

_instance: Optional[GeminiService] = None


def get_gemini_service() -> GeminiService:
    global _instance
    if _instance is None:
        _instance = GeminiService()
    return _instance


def reset_gemini_service() -> None:
    global _instance
    _instance = None
