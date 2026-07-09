"""
Tests for LLM Service
"""
import pytest
from unittest.mock import Mock, AsyncMock, patch

from ..services.llm_service import (
    LLMService,
    OpenAIProvider,
    GeminiProvider,
    LLMProvider
)
from ..utils.exceptions import LLMServiceException, LLMTimeoutException


class TestLLMService:
    """Test cases for LLM Service"""
    
    @pytest.fixture
    def mock_openai_provider(self):
        """Mock OpenAI provider"""
        provider = Mock(spec=OpenAIProvider)
        provider.generate_response = AsyncMock(return_value="Test response")
        provider.health_check = AsyncMock(return_value=True)
        return provider
    
    @pytest.fixture
    def mock_gemini_provider(self):
        """Mock Gemini provider"""
        provider = Mock(spec=GeminiProvider)
        provider.generate_response = AsyncMock(return_value="Test response")
        provider.health_check = AsyncMock(return_value=True)
        return provider
    
    @pytest.mark.asyncio
    async def test_generate_response_success(self, mock_openai_provider):
        """Test successful response generation"""
        with patch('app.medical_chatbot.services.llm_service.OpenAIProvider', return_value=mock_openai_provider):
            service = LLMService(
                provider=LLMProvider.OPENAI,
                api_key="test_key",
                model="gpt-3.5-turbo"
            )
            
            result = await service.generate_response("Test prompt")
            
            assert result["success"] is True
            assert result["response"] == "Test response"
            assert "response_time" in result
            assert result["provider"] == LLMProvider.OPENAI
    
    @pytest.mark.asyncio
    async def test_generate_response_timeout(self, mock_openai_provider):
        """Test timeout handling"""
        mock_openai_provider.generate_response = AsyncMock(
            side_effect=TimeoutError()
        )
        
        with patch('app.medical_chatbot.services.llm_service.OpenAIProvider', return_value=mock_openai_provider):
            service = LLMService(
                provider=LLMProvider.OPENAI,
                api_key="test_key",
                timeout=1
            )
            
            with pytest.raises(LLMTimeoutException):
                await service.generate_response("Test prompt")
    
    @pytest.mark.asyncio
    async def test_generate_response_empty(self, mock_openai_provider):
        """Test empty response handling"""
        mock_openai_provider.generate_response = AsyncMock(return_value="")
        
        with patch('app.medical_chatbot.services.llm_service.OpenAIProvider', return_value=mock_openai_provider):
            service = LLMService(
                provider=LLMProvider.OPENAI,
                api_key="test_key"
            )
            
            with pytest.raises(LLMServiceException):
                await service.generate_response("Test prompt")
    
    @pytest.mark.asyncio
    async def test_health_check_success(self, mock_openai_provider):
        """Test health check"""
        with patch('app.medical_chatbot.services.llm_service.OpenAIProvider', return_value=mock_openai_provider):
            service = LLMService(
                provider=LLMProvider.OPENAI,
                api_key="test_key"
            )
            
            result = await service.health_check()
            
            assert result["status"] == "healthy"
            assert result["configured"] is True
    
    def test_missing_api_key(self):
        """Test initialization without API key"""
        with pytest.raises(LLMServiceException):
            LLMService(provider=LLMProvider.OPENAI, api_key=None)
    
    def test_unsupported_provider(self):
        """Test unsupported provider"""
        with pytest.raises(LLMServiceException):
            LLMService(provider="unsupported", api_key="test_key")
    
    def test_get_provider_info(self, mock_openai_provider):
        """Test getting provider information"""
        with patch('app.medical_chatbot.services.llm_service.OpenAIProvider', return_value=mock_openai_provider):
            service = LLMService(
                provider=LLMProvider.OPENAI,
                api_key="test_key",
                model="gpt-3.5-turbo"
            )
            
            info = service.get_provider_info()
            
            assert info["provider"] == LLMProvider.OPENAI
            assert info["model"] == "gpt-3.5-turbo"
            assert info["configured"] is True
