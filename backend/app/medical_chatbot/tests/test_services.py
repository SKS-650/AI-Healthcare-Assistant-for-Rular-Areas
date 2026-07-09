"""
Tests for Medical Chatbot Services
"""
import pytest
from uuid import uuid4
from unittest.mock import Mock, AsyncMock, patch

from ..services.chatbot_service import ChatbotService
from ..schemas.request import ChatRequest
from ..utils.exceptions import (
    ConversationNotFoundException,
    ConversationAccessDeniedException,
    EmptyMessageException
)


class TestChatbotService:
    """Test cases for ChatbotService"""
    
    @pytest.fixture
    def mock_conversation_repo(self):
        """Mock conversation repository"""
        repo = Mock()
        repo.create_conversation = AsyncMock()
        repo.get_conversation_by_uuid = AsyncMock()
        repo.get_user_conversations = AsyncMock()
        repo.add_message = AsyncMock()
        repo.get_conversation_message_count = AsyncMock(return_value=5)
        repo.get_user_message_count_today = AsyncMock(return_value=10)
        repo.delete_conversation = AsyncMock()
        return repo
    
    @pytest.fixture
    def mock_feedback_repo(self):
        """Mock feedback repository"""
        repo = Mock()
        repo.create_feedback = AsyncMock()
        return repo
    
    @pytest.fixture
    def service(self, mock_conversation_repo, mock_feedback_repo):
        """Create service instance with mocked dependencies"""
        return ChatbotService(mock_conversation_repo, mock_feedback_repo)
    
    @pytest.mark.asyncio
    async def test_process_chat_new_conversation(
        self, 
        service,
        mock_conversation_repo
    ):
        """Test processing chat for new conversation"""
        # Setup mocks
        mock_conversation = Mock()
        mock_conversation.id = 1
        mock_conversation.uuid = uuid4()
        mock_conversation.user_id = 1
        
        mock_conversation_repo.create_conversation.return_value = mock_conversation
        
        mock_message = Mock()
        mock_message.id = 1
        mock_message.created_at = "2026-07-06T12:00:00Z"
        
        mock_conversation_repo.add_message.return_value = mock_message
        
        # Create request
        request = ChatRequest(
            message="What is diabetes?",
            language="en"
        )
        
        # Process chat
        response = await service.process_chat(user_id=1, request=request)
        
        # Assertions
        assert response.conversation_id == mock_conversation.uuid
        assert response.message_id == mock_message.id
        assert mock_conversation_repo.create_conversation.called
        assert mock_conversation_repo.add_message.call_count == 2  # User + Assistant
    
    @pytest.mark.asyncio
    async def test_process_chat_continue_conversation(
        self,
        service,
        mock_conversation_repo
    ):
        """Test continuing existing conversation"""
        conversation_uuid = uuid4()
        
        # Setup mocks
        mock_conversation = Mock()
        mock_conversation.id = 1
        mock_conversation.uuid = conversation_uuid
        mock_conversation.user_id = 1
        
        mock_conversation_repo.get_conversation_by_uuid.return_value = mock_conversation
        
        mock_message = Mock()
        mock_message.id = 2
        mock_message.created_at = "2026-07-06T12:00:00Z"
        
        mock_conversation_repo.add_message.return_value = mock_message
        
        # Create request
        request = ChatRequest(
            message="Tell me more",
            conversation_id=conversation_uuid,
            language="en"
        )
        
        # Process chat
        response = await service.process_chat(user_id=1, request=request)
        
        # Assertions
        assert response.conversation_id == conversation_uuid
        assert not mock_conversation_repo.create_conversation.called
        assert mock_conversation_repo.get_conversation_by_uuid.called
    
    @pytest.mark.asyncio
    async def test_process_chat_empty_message(self, service):
        """Test processing empty message"""
        request = ChatRequest(
            message="   ",  # Only whitespace
            language="en"
        )
        
        with pytest.raises(EmptyMessageException):
            await service.process_chat(user_id=1, request=request)
    
    @pytest.mark.asyncio
    async def test_process_chat_emergency_detection(
        self,
        service,
        mock_conversation_repo
    ):
        """Test emergency keyword detection"""
        # Setup mocks
        mock_conversation = Mock()
        mock_conversation.id = 1
        mock_conversation.uuid = uuid4()
        mock_conversation.user_id = 1
        
        mock_conversation_repo.create_conversation.return_value = mock_conversation
        
        mock_message = Mock()
        mock_message.id = 1
        mock_message.created_at = "2026-07-06T12:00:00Z"
        
        mock_conversation_repo.add_message.return_value = mock_message
        
        # Create request with emergency keyword
        request = ChatRequest(
            message="I'm having severe chest pain",
            language="en"
        )
        
        # Process chat
        response = await service.process_chat(user_id=1, request=request)
        
        # Assertions
        assert response.emergency_detected is True
    
    @pytest.mark.asyncio
    async def test_get_conversation_not_found(
        self,
        service,
        mock_conversation_repo
    ):
        """Test getting non-existent conversation"""
        mock_conversation_repo.get_conversation_by_uuid.return_value = None
        
        conversation_uuid = uuid4()
        
        with pytest.raises(ConversationNotFoundException):
            await service.get_conversation(
                user_id=1,
                conversation_uuid=conversation_uuid
            )
    
    @pytest.mark.asyncio
    async def test_get_conversation_access_denied(
        self,
        service,
        mock_conversation_repo
    ):
        """Test accessing another user's conversation"""
        mock_conversation = Mock()
        mock_conversation.user_id = 2  # Different user
        
        mock_conversation_repo.get_conversation_by_uuid.return_value = mock_conversation
        
        conversation_uuid = uuid4()
        
        with pytest.raises(ConversationAccessDeniedException):
            await service.get_conversation(
                user_id=1,
                conversation_uuid=conversation_uuid,
                is_admin=False
            )
    
    @pytest.mark.asyncio
    async def test_get_conversation_admin_access(
        self,
        service,
        mock_conversation_repo
    ):
        """Test admin accessing any conversation"""
        mock_conversation = Mock()
        mock_conversation.user_id = 2  # Different user
        
        mock_conversation_repo.get_conversation_by_uuid.return_value = mock_conversation
        
        conversation_uuid = uuid4()
        
        # Should not raise exception for admin
        result = await service.get_conversation(
            user_id=1,
            conversation_uuid=conversation_uuid,
            is_admin=True
        )
        
        assert result == mock_conversation
    
    @pytest.mark.asyncio
    async def test_delete_conversation(
        self,
        service,
        mock_conversation_repo
    ):
        """Test deleting conversation"""
        mock_conversation = Mock()
        mock_conversation.id = 1
        mock_conversation.user_id = 1
        
        mock_conversation_repo.get_conversation_by_uuid.return_value = mock_conversation
        mock_conversation_repo.delete_conversation.return_value = True
        
        conversation_uuid = uuid4()
        
        result = await service.delete_conversation(
            user_id=1,
            conversation_uuid=conversation_uuid
        )
        
        assert result is True
        assert mock_conversation_repo.delete_conversation.called
    
    @pytest.mark.asyncio
    async def test_submit_feedback(
        self,
        service,
        mock_conversation_repo,
        mock_feedback_repo
    ):
        """Test submitting feedback"""
        mock_conversation = Mock()
        mock_conversation.id = 1
        mock_conversation.user_id = 1
        
        mock_conversation_repo.get_conversation_by_uuid.return_value = mock_conversation
        
        mock_feedback = Mock()
        mock_feedback.id = 1
        mock_feedback.rating = 5
        
        mock_feedback_repo.create_feedback.return_value = mock_feedback
        
        conversation_uuid = uuid4()
        
        result = await service.submit_feedback(
            user_id=1,
            conversation_uuid=conversation_uuid,
            rating=5,
            feedback_text="Great!",
            feedback_type="helpful"
        )
        
        assert result.id == 1
        assert mock_feedback_repo.create_feedback.called
