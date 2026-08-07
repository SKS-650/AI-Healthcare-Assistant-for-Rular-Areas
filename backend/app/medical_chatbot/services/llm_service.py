"""
LLM Service - Provider-independent AI integration
Supports: Google Gemini 2.5 Flash (primary), OpenAI, Anthropic
Uses the google-genai SDK (>=0.8) for Gemini.
"""
from __future__ import annotations

import asyncio
import time
from abc import ABC, abstractmethod
from enum import Enum
from typing import Any, Dict, List, Optional

from ..config.settings import settings
from ..utils.exceptions import LLMServiceException, LLMTimeoutException
from ..utils.logger import logger


# ─────────────────────────────────────────────────────────────────────────────
# Enums
# ─────────────────────────────────────────────────────────────────────────────

class LLMProvider(str, Enum):
    """Supported LLM providers"""
    OPENAI    = "openai"
    GEMINI    = "gemini"
    ANTHROPIC = "anthropic"


# ─────────────────────────────────────────────────────────────────────────────
# Abstract base
# ─────────────────────────────────────────────────────────────────────────────

class BaseLLMProvider(ABC):
    """Abstract base class for LLM providers"""

    @abstractmethod
    async def generate_response(
        self,
        prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 1000,
    ) -> str:
        """Generate a text response from the LLM."""

    @abstractmethod
    async def health_check(self) -> bool:
        """Return True when the provider endpoint is reachable."""


# ─────────────────────────────────────────────────────────────────────────────
# Gemini provider  (google-genai >= 0.8 SDK)
# ─────────────────────────────────────────────────────────────────────────────

class GeminiProvider(BaseLLMProvider):
    """
    Google Gemini provider using the **new** google-genai SDK.

    The new SDK exposes:
        from google import genai
        from google.genai import types

    Falls back gracefully to the legacy google-generativeai SDK if the new
    package is not installed, so the server never crashes at import time.
    """

    def __init__(self, api_key: str, model: str = "gemini-2.5-flash") -> None:
        self.api_key = api_key
        self.model   = model
        self._client = None          # new-SDK client
        self._legacy = None          # legacy GenerativeModel (fallback)
        self._use_new_sdk = False
        self._initialize_client()

    # ── Initialisation ────────────────────────────────────────────────────

    def _initialize_client(self) -> None:
        """Try new SDK first, fall back to legacy google-generativeai."""
        # 1. Try new google-genai SDK
        try:
            from google import genai  # type: ignore
            self._client    = genai.Client(api_key=self.api_key)
            self._use_new_sdk = True
            logger.info(
                f"✅ Gemini provider initialised via google-genai (new SDK), "
                f"model={self.model}"
            )
            return
        except ImportError:
            logger.warning(
                "google-genai package not found — falling back to "
                "google-generativeai (legacy SDK)."
            )
        except Exception as exc:
            logger.warning(f"google-genai init failed ({exc}), trying legacy SDK.")

        # 2. Legacy google-generativeai SDK
        try:
            import google.generativeai as genai_legacy  # type: ignore

            genai_legacy.configure(api_key=self.api_key)
            self._legacy = genai_legacy.GenerativeModel(self.model)
            logger.info(
                f"✅ Gemini provider initialised via google-generativeai (legacy SDK), "
                f"model={self.model}"
            )
        except ImportError:
            raise LLMServiceException(
                "Neither google-genai nor google-generativeai is installed. "
                "Run: pip install google-genai"
            )
        except Exception as exc:
            raise LLMServiceException(
                f"Failed to initialise Gemini client: {exc}"
            )

    # ── Generation helpers ────────────────────────────────────────────────

    async def _generate_new_sdk(
        self,
        prompt: str,
        temperature: float,
        max_tokens: int,
    ) -> str:
        """Generate via the new google-genai SDK (async-native)."""
        from google.genai import types  # type: ignore

        config = types.GenerateContentConfig(
            temperature=temperature,
            max_output_tokens=max_tokens,
            # safety_settings can be added here if needed
        )

        loop     = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: self._client.models.generate_content(
                model   = self.model,
                contents= prompt,
                config  = config,
            ),
        )

        # new SDK: response.text is the concatenated text
        text = response.text
        if not text or not text.strip():
            raise LLMServiceException("Empty response from Gemini (new SDK).")
        return text

    async def _generate_legacy_sdk(
        self,
        prompt: str,
        temperature: float,
        max_tokens: int,
    ) -> str:
        """Generate via the legacy google-generativeai SDK (thread-pool)."""
        loop     = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: self._legacy.generate_content(
                prompt,
                generation_config={
                    "temperature":      temperature,
                    "max_output_tokens": max_tokens,
                },
            ),
        )
        text = response.text
        if not text or not text.strip():
            raise LLMServiceException("Empty response from Gemini (legacy SDK).")
        return text

    # ── Public interface ──────────────────────────────────────────────────

    async def generate_response(
        self,
        prompt:      str,
        temperature: float = 0.7,
        max_tokens:  int   = 1000,
    ) -> str:
        logger.debug(
            f"Sending request to Gemini [{self.model}] "
            f"(sdk={'new' if self._use_new_sdk else 'legacy'})"
        )
        try:
            if self._use_new_sdk:
                return await self._generate_new_sdk(prompt, temperature, max_tokens)
            return await self._generate_legacy_sdk(prompt, temperature, max_tokens)
        except LLMServiceException:
            raise
        except Exception as exc:
            error_str = str(exc).lower()

            # ── Friendly error mapping ────────────────────────────────────
            if "quota" in error_str or "resource_exhausted" in error_str:
                raise LLMServiceException(
                    "⏳ Gemini quota exceeded. Please try again in a moment."
                )
            if "api_key" in error_str or "invalid" in error_str and "key" in error_str:
                raise LLMServiceException(
                    "🔑 Invalid Gemini API key. Please check your configuration."
                )
            if "timeout" in error_str or "deadline" in error_str:
                raise LLMServiceException(
                    "⌛ Gemini request timed out. Please try again."
                )
            if "rate" in error_str:
                raise LLMServiceException(
                    "🚦 Gemini rate limit reached. Please wait a moment."
                )
            if "unavailable" in error_str or "503" in error_str:
                raise LLMServiceException(
                    "🌐 Gemini service temporarily unavailable."
                )

            logger.error(f"Gemini API error: {exc}", exc_info=True)
            raise LLMServiceException(f"Gemini error: {exc}")

    async def health_check(self) -> bool:
        try:
            result = await self.generate_response(
                "Reply with exactly one word: OK", temperature=0.0, max_tokens=5
            )
            return bool(result)
        except Exception:
            return False


# ─────────────────────────────────────────────────────────────────────────────
# OpenAI provider  (unchanged — kept for multi-provider support)
# ─────────────────────────────────────────────────────────────────────────────

class OpenAIProvider(BaseLLMProvider):
    """OpenAI GPT provider"""

    def __init__(self, api_key: str, model: str = "gpt-3.5-turbo") -> None:
        self.api_key = api_key
        self.model   = model
        self.client  = None
        self._initialize_client()

    def _initialize_client(self) -> None:
        try:
            from openai import AsyncOpenAI  # type: ignore
            self.client = AsyncOpenAI(api_key=self.api_key)
            logger.info(f"OpenAI client initialised with model: {self.model}")
        except ImportError:
            raise LLMServiceException(
                "openai package not installed. Run: pip install openai"
            )
        except Exception as exc:
            raise LLMServiceException(f"Failed to initialise OpenAI client: {exc}")

    async def generate_response(
        self,
        prompt:      str,
        temperature: float = 0.7,
        max_tokens:  int   = 1000,
    ) -> str:
        try:
            response = await self.client.chat.completions.create(
                model       = self.model,
                messages    = [{"role": "user", "content": prompt}],
                temperature = temperature,
                max_tokens  = max_tokens,
            )
            return response.choices[0].message.content
        except Exception as exc:
            raise LLMServiceException(f"OpenAI error: {exc}")

    async def health_check(self) -> bool:
        try:
            await self.generate_response("Test", temperature=0, max_tokens=5)
            return True
        except Exception:
            return False


# ─────────────────────────────────────────────────────────────────────────────
# Main LLM Service  (provider-agnostic facade)
# ─────────────────────────────────────────────────────────────────────────────

class LLMService:
    """
    Provider-agnostic LLM service.

    Reads configuration from ChatbotSettings (which reads from environment
    variables CHATBOT_LLM_PROVIDER / CHATBOT_LLM_MODEL / CHATBOT_LLM_API_KEY).
    """

    def __init__(
        self,
        provider:  Optional[LLMProvider] = None,
        api_key:   Optional[str]         = None,
        model:     Optional[str]         = None,
        timeout:   int                   = 30,
    ) -> None:
        self.provider_name = provider or settings.LLM_PROVIDER
        self.api_key       = api_key  or settings.LLM_API_KEY
        self.model         = model    or settings.LLM_MODEL
        self.timeout       = timeout  or settings.LLM_REQUEST_TIMEOUT

        if not self.api_key:
            raise LLMServiceException(
                "LLM API key not configured. "
                "Set CHATBOT_LLM_API_KEY in your .env file."
            )

        self.provider: BaseLLMProvider = self._create_provider()
        logger.info(
            f"LLMService ready: provider={self.provider_name}, model={self.model}"
        )

    # ── Factory ───────────────────────────────────────────────────────────

    def _create_provider(self) -> BaseLLMProvider:
        p = str(self.provider_name).lower()
        if p == LLMProvider.GEMINI:
            return GeminiProvider(self.api_key, self.model)
        if p == LLMProvider.OPENAI:
            return OpenAIProvider(self.api_key, self.model)
        raise LLMServiceException(f"Unsupported LLM provider: {self.provider_name}")

    # ── Public API ────────────────────────────────────────────────────────

    async def generate_response(
        self,
        prompt:          str,
        temperature:     float          = 0.7,
        max_tokens:      int            = 1000,
        conversation_id: Optional[str]  = None,
    ) -> Dict[str, Any]:
        """
        Generate an AI response with timeout, error handling, and metadata.

        Returns:
            {
                "response":      str,
                "provider":      str,
                "model":         str,
                "response_time": float,
                "tokens_used":   int,
                "success":       bool,
            }
        """
        start = time.time()

        try:
            logger.log_llm_request(
                conversation_id = conversation_id or "unknown",
                tokens          = len(prompt.split()),
                model           = self.model,
            )

            response_text = await asyncio.wait_for(
                self.provider.generate_response(prompt, temperature, max_tokens),
                timeout=self.timeout,
            )

            if not response_text or not response_text.strip():
                raise LLMServiceException("LLM returned an empty response.")

            elapsed = time.time() - start

            logger.log_llm_response(
                conversation_id = conversation_id or "unknown",
                response_time   = elapsed,
                tokens_used     = len(response_text.split()),
                confidence      = None,
            )

            return {
                "response":      response_text.strip(),
                "provider":      self.provider_name,
                "model":         self.model,
                "response_time": elapsed,
                "tokens_used":   len(response_text.split()),
                "success":       True,
            }

        except asyncio.TimeoutError:
            logger.error(f"LLM request timed out after {self.timeout}s")
            raise LLMTimeoutException()

        except LLMServiceException:
            raise

        except Exception as exc:
            logger.error(f"LLM generation error: {exc}", exc_info=True)
            raise LLMServiceException(f"Failed to generate response: {exc}")

    async def health_check(self) -> Dict[str, Any]:
        """Return health-check payload."""
        try:
            ok = await asyncio.wait_for(self.provider.health_check(), timeout=10)
            return {
                "status":     "healthy" if ok else "unhealthy",
                "provider":   self.provider_name,
                "model":      self.model,
                "configured": bool(self.api_key),
            }
        except Exception as exc:
            return {
                "status":     "unhealthy",
                "provider":   self.provider_name,
                "model":      self.model,
                "configured": bool(self.api_key),
                "error":      str(exc),
            }

    def get_provider_info(self) -> Dict[str, str]:
        """Return basic provider information."""
        return {
            "provider":   self.provider_name,
            "model":      self.model,
            "configured": str(bool(self.api_key)),
        }


# ─────────────────────────────────────────────────────────────────────────────
# Singleton helper
# ─────────────────────────────────────────────────────────────────────────────

_llm_service_instance: Optional[LLMService] = None


def get_llm_service() -> LLMService:
    """Return a process-level singleton LLMService."""
    global _llm_service_instance
    if _llm_service_instance is None:
        _llm_service_instance = LLMService()
    return _llm_service_instance
