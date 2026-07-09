"""
LLM Service - Provider-independent AI integration
Supports: OpenAI, Google Gemini, and easy extension to other providers
"""
from typing import Optional, Dict, Any, List
from abc import ABC, abstractmethod
import asyncio
import time
from enum import Enum

from ..config.settings import settings
from ..utils.logger import logger
from ..utils.exceptions import LLMServiceException, LLMTimeoutException


class LLMProvider(str, Enum):
    """Supported LLM providers"""
    OPENAI = "openai"
    GEMINI = "gemini"
    ANTHROPIC = "anthropic"


class BaseLLMProvider(ABC):
    """Abstract base class for LLM providers"""
    
    @abstractmethod
    async def generate_response(
        self,
        prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 1000
    ) -> str:
        """Generate response from LLM"""
        pass
    
    @abstractmethod
    async def health_check(self) -> bool:
        """Check if LLM service is available"""
        pass


class OpenAIProvider(BaseLLMProvider):
    """OpenAI GPT provider"""
    
    def __init__(self, api_key: str, model: str = "gpt-3.5-turbo"):
        self.api_key = api_key
        self.model = model
        self.client = None
        self._initialize_client()
    
    def _initialize_client(self):
        """Initialize OpenAI client"""
        try:
            from openai import AsyncOpenAI
            self.client = AsyncOpenAI(api_key=self.api_key)
            logger.info(f"OpenAI client initialized with model: {self.model}")
        except ImportError:
            raise LLMServiceException("OpenAI package not installed. Run: pip install openai")
        except Exception as e:
            raise LLMServiceException(f"Failed to initialize OpenAI client: {str(e)}")
    
    async def generate_response(
        self,
        prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 1000
    ) -> str:
        """Generate response using OpenAI"""
        try:
            logger.debug(f"Sending request to OpenAI model: {self.model}")
            
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                temperature=temperature,
                max_tokens=max_tokens
            )
            
            result = response.choices[0].message.content
            logger.debug(f"Received response from OpenAI: {len(result)} characters")
            
            return result
            
        except Exception as e:
            logger.error(f"OpenAI API error: {str(e)}")
            raise LLMServiceException(f"OpenAI error: {str(e)}")
    
    async def health_check(self) -> bool:
        """Check OpenAI service health"""
        try:
            await self.generate_response("Test", temperature=0, max_tokens=5)
            return True
        except Exception:
            return False


class GeminiProvider(BaseLLMProvider):
    """Google Gemini provider"""
    
    def __init__(self, api_key: str, model: str = "gemini-pro"):
        self.api_key = api_key
        self.model = model
        self.client = None
        self._initialize_client()
    
    def _initialize_client(self):
        """Initialize Gemini client"""
        try:
            import google.generativeai as genai
            genai.configure(api_key=self.api_key)
            self.client = genai.GenerativeModel(self.model)
            logger.info(f"Gemini client initialized with model: {self.model}")
        except ImportError:
            raise LLMServiceException("Google Generative AI package not installed. Run: pip install google-generativeai")
        except Exception as e:
            raise LLMServiceException(f"Failed to initialize Gemini client: {str(e)}")
    
    async def generate_response(
        self,
        prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 1000
    ) -> str:
        """Generate response using Gemini"""
        try:
            logger.debug(f"Sending request to Gemini model: {self.model}")
            
            # Gemini uses blocking API, run in executor
            loop = asyncio.get_event_loop()
            response = await loop.run_in_executor(
                None,
                lambda: self.client.generate_content(
                    prompt,
                    generation_config={
                        "temperature": temperature,
                        "max_output_tokens": max_tokens
                    }
                )
            )
            
            result = response.text
            logger.debug(f"Received response from Gemini: {len(result)} characters")
            
            return result
            
        except Exception as e:
            logger.error(f"Gemini API error: {str(e)}")
            raise LLMServiceException(f"Gemini error: {str(e)}")
    
    async def health_check(self) -> bool:
        """Check Gemini service health"""
        try:
            await self.generate_response("Test", temperature=0, max_tokens=5)
            return True
        except Exception:
            return False


class LLMService:
    """Main LLM service with provider abstraction"""
    
    def __init__(
        self,
        provider: LLMProvider = None,
        api_key: Optional[str] = None,
        model: Optional[str] = None,
        timeout: int = 30
    ):
        """
        Initialize LLM service
        
        Args:
            provider: LLM provider (openai, gemini)
            api_key: API key for the provider
            model: Model name
            timeout: Request timeout in seconds
        """
        # Use settings if not provided
        self.provider_name = provider or settings.LLM_PROVIDER
        self.api_key = api_key or settings.LLM_API_KEY
        self.model = model or settings.LLM_MODEL
        self.timeout = timeout or settings.LLM_REQUEST_TIMEOUT
        
        # Validate configuration
        if not self.api_key:
            raise LLMServiceException("LLM API key not configured")
        
        # Initialize provider
        self.provider = self._create_provider()
        
        logger.info(f"LLM Service initialized with provider: {self.provider_name}")
    
    def _create_provider(self) -> BaseLLMProvider:
        """Create appropriate provider instance"""
        if self.provider_name == LLMProvider.OPENAI:
            return OpenAIProvider(self.api_key, self.model)
        elif self.provider_name == LLMProvider.GEMINI:
            return GeminiProvider(self.api_key, self.model)
        else:
            raise LLMServiceException(f"Unsupported provider: {self.provider_name}")
    
    async def generate_response(
        self,
        prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 1000,
        conversation_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Generate AI response with timeout and error handling
        
        Args:
            prompt: Input prompt
            temperature: Randomness (0-1)
            max_tokens: Maximum response length
            conversation_id: For logging
            
        Returns:
            Dict with response and metadata
        """
        start_time = time.time()
        
        try:
            logger.log_llm_request(
                conversation_id=conversation_id or "unknown",
                tokens=len(prompt.split()),  # Rough estimate
                model=self.model
            )
            
            # Generate with timeout
            response_text = await asyncio.wait_for(
                self.provider.generate_response(prompt, temperature, max_tokens),
                timeout=self.timeout
            )
            
            # Validate response
            if not response_text or not response_text.strip():
                raise LLMServiceException("Empty response from LLM")
            
            response_time = time.time() - start_time
            
            logger.log_llm_response(
                conversation_id=conversation_id or "unknown",
                response_time=response_time,
                tokens_used=len(response_text.split()),  # Rough estimate
                confidence=None
            )
            
            return {
                "response": response_text.strip(),
                "provider": self.provider_name,
                "model": self.model,
                "response_time": response_time,
                "tokens_used": len(response_text.split()),
                "success": True
            }
            
        except asyncio.TimeoutError:
            logger.error(f"LLM request timeout after {self.timeout}s")
            raise LLMTimeoutException()
            
        except LLMServiceException:
            raise
            
        except Exception as e:
            logger.error(f"LLM generation error: {str(e)}", exc_info=True)
            raise LLMServiceException(f"Failed to generate response: {str(e)}")
    
    async def health_check(self) -> Dict[str, Any]:
        """
        Check LLM service health
        
        Returns:
            Dict with health status
        """
        try:
            is_healthy = await asyncio.wait_for(
                self.provider.health_check(),
                timeout=10
            )
            
            return {
                "status": "healthy" if is_healthy else "unhealthy",
                "provider": self.provider_name,
                "model": self.model,
                "configured": bool(self.api_key)
            }
            
        except Exception as e:
            logger.error(f"LLM health check failed: {str(e)}")
            return {
                "status": "unhealthy",
                "provider": self.provider_name,
                "model": self.model,
                "configured": bool(self.api_key),
                "error": str(e)
            }
    
    def get_provider_info(self) -> Dict[str, str]:
        """Get current provider information"""
        return {
            "provider": self.provider_name,
            "model": self.model,
            "configured": bool(self.api_key)
        }


# Singleton instance (optional, for convenience)
_llm_service_instance: Optional[LLMService] = None


def get_llm_service() -> LLMService:
    """Get or create LLM service instance"""
    global _llm_service_instance
    
    if _llm_service_instance is None:
        _llm_service_instance = LLMService()
    
    return _llm_service_instance


# Example usage:
# llm_service = get_llm_service()
# result = await llm_service.generate_response("What is diabetes?")
# print(result["response"])
