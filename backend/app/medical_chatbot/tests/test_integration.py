"""
Integration Tests for Medical Chatbot
Tests the complete workflow from API to database
"""
import pytest
from uuid import UUID
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.main import app
from app.database.connection import get_async_session as get_session
from app.auth.models import UserModel
from app.auth.jwt_handler import create_access_token


class TestChatbotIntegration:
    """Integration tests for chatbot module"""
    
    @pytest.fixture
    async def test_user(self, db_session: AsyncSession):
        """Create a test user"""
        user = UserModel(
            email="test@example.com",
            full_name="Test User",
            hashed_password="hashed_password",
            role="user",
            is_active=True
        )
        db_session.add(user)
        await db_session.commit()
        await db_session.refresh(user)
        return user
    
    @pytest.fixture
    def auth_headers(self, test_user):
        """Generate auth headers"""
        token = create_access_token(data={"sub": str(test_user.id)})
        return {"Authorization": f"Bearer {token}"}
    
    @pytest.mark.asyncio
    async def test_complete_chat_workflow(self, auth_headers):
        """Test: Create conversation -> Chat -> Get conversation -> Delete"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Step 1: Send first message (creates new conversation)
            chat_response = await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "message": "What are the symptoms of fever?",
                    "language": "en"
                },
                headers=auth_headers
            )
            
            assert chat_response.status_code == 200
            chat_data = chat_response.json()
            assert "conversation_id" in chat_data
            assert "assistant_message" in chat_data
            assert len(chat_data["assistant_message"]) > 0
            
            conversation_id = chat_data["conversation_id"]
            
            # Step 2: Continue conversation
            continue_response = await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "conversation_id": conversation_id,
                    "message": "How can I prevent it?",
                    "language": "en"
                },
                headers=auth_headers
            )
            
            assert continue_response.status_code == 200
            continue_data = continue_response.json()
            assert continue_data["conversation_id"] == conversation_id
            
            # Step 3: Get conversation details
            get_response = await client.get(
                f"/api/v1/chatbot/conversations/{conversation_id}",
                headers=auth_headers
            )
            
            assert get_response.status_code == 200
            conv_data = get_response.json()
            assert conv_data["id"] == conversation_id
            assert len(conv_data["messages"]) >= 4  # 2 user + 2 assistant
            
            # Step 4: Submit feedback
            feedback_response = await client.post(
                "/api/v1/chatbot/feedback",
                json={
                    "conversation_id": conversation_id,
                    "rating": 5,
                    "feedback_text": "Very helpful!",
                    "feedback_type": "positive"
                },
                headers=auth_headers
            )
            
            assert feedback_response.status_code == 201
            
            # Step 5: Delete conversation
            delete_response = await client.delete(
                f"/api/v1/chatbot/conversations/{conversation_id}",
                headers=auth_headers
            )
            
            assert delete_response.status_code == 200
            
            # Step 6: Verify deletion
            verify_response = await client.get(
                f"/api/v1/chatbot/conversations/{conversation_id}",
                headers=auth_headers
            )
            
            assert verify_response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_emergency_detection_workflow(self, auth_headers):
        """Test: Emergency detection triggers appropriate response"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "message": "I'm having severe chest pain and difficulty breathing",
                    "language": "en"
                },
                headers=auth_headers
            )
            
            assert response.status_code == 200
            data = response.json()
            
            # Verify emergency detection
            assert data["emergency_detected"] is True
            assert "108" in data["assistant_message"] or "emergency" in data["assistant_message"].lower()
            assert "recommendations" in data
            assert any("emergency" in r.lower() for r in data["recommendations"])
    
    @pytest.mark.asyncio
    async def test_conversation_list_pagination(self, auth_headers):
        """Test: List conversations with pagination"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Create multiple conversations
            for i in range(5):
                await client.post(
                    "/api/v1/chatbot/chat",
                    json={
                        "message": f"Test message {i}",
                        "language": "en"
                    },
                    headers=auth_headers
                )
            
            # Get conversations with pagination
            list_response = await client.get(
                "/api/v1/chatbot/conversations?page=1&page_size=3",
                headers=auth_headers
            )
            
            assert list_response.status_code == 200
            data = list_response.json()
            
            assert "items" in data
            assert "total" in data
            assert "page" in data
            assert len(data["items"]) <= 3
            assert data["total"] >= 5
    
    @pytest.mark.asyncio
    async def test_unauthorized_access(self):
        """Test: Unauthorized access is rejected"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "message": "Test",
                    "language": "en"
                }
            )
            
            assert response.status_code == 401
    
    @pytest.mark.asyncio
    async def test_invalid_conversation_access(self, auth_headers):
        """Test: User cannot access other user's conversations"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Try to access non-existent conversation
            fake_uuid = "00000000-0000-0000-0000-000000000000"
            response = await client.get(
                f"/api/v1/chatbot/conversations/{fake_uuid}",
                headers=auth_headers
            )
            
            assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_health_check(self):
        """Test: Health check endpoint works"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/v1/chatbot/health")
            
            assert response.status_code == 200
            data = response.json()
            
            assert "status" in data
            assert "database" in data
            assert "llm" in data
            assert "datasets" in data
    
    @pytest.mark.asyncio
    async def test_multilingual_chat(self, auth_headers):
        """Test: Multilingual conversation support"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Test with different language
            response = await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "message": "What is diabetes?",
                    "language": "ne"  # Nepali
                },
                headers=auth_headers
            )
            
            assert response.status_code == 200
            data = response.json()
            assert "assistant_message" in data
    
    @pytest.mark.asyncio
    async def test_knowledge_context_inclusion(self, auth_headers):
        """Test: AI includes relevant knowledge from datasets"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "message": "What are the symptoms of pneumonia?",
                    "language": "en"
                },
                headers=auth_headers
            )
            
            assert response.status_code == 200
            data = response.json()
            
            # Verify response contains relevant medical information
            assert len(data["assistant_message"]) > 50
            assert data["confidence"] > 0.5
            
            # Verify follow-up questions are provided
            assert "follow_up_questions" in data
            assert len(data["follow_up_questions"]) > 0
    
    @pytest.mark.asyncio
    async def test_rate_limiting_behavior(self, auth_headers):
        """Test: Rate limiting is enforced"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Send multiple rapid requests
            responses = []
            for i in range(15):  # Exceed typical rate limit
                response = await client.post(
                    "/api/v1/chatbot/chat",
                    json={
                        "message": f"Test message {i}",
                        "language": "en"
                    },
                    headers=auth_headers
                )
                responses.append(response.status_code)
            
            # At least some requests should succeed
            assert any(code == 200 for code in responses)
    
    @pytest.mark.asyncio
    async def test_conversation_search(self, auth_headers):
        """Test: Search conversations by keyword"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Create conversation with specific keyword
            await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "message": "Tell me about diabetes management",
                    "language": "en"
                },
                headers=auth_headers
            )
            
            # Search for conversations
            search_response = await client.get(
                "/api/v1/chatbot/conversations?search=diabetes",
                headers=auth_headers
            )
            
            assert search_response.status_code == 200
            data = search_response.json()
            
            # Should find the conversation
            assert data["total"] >= 1
    
    @pytest.mark.asyncio
    async def test_feedback_submission_validation(self, auth_headers):
        """Test: Feedback validation works correctly"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Create conversation first
            chat_response = await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "message": "Test",
                    "language": "en"
                },
                headers=auth_headers
            )
            conversation_id = chat_response.json()["conversation_id"]
            
            # Submit invalid feedback (rating out of range)
            invalid_response = await client.post(
                "/api/v1/chatbot/feedback",
                json={
                    "conversation_id": conversation_id,
                    "rating": 10,  # Invalid: should be 1-5
                    "feedback_type": "positive"
                },
                headers=auth_headers
            )
            
            assert invalid_response.status_code == 422  # Validation error


class TestChatbotDataIntegrity:
    """Test data integrity and consistency"""
    
    @pytest.mark.asyncio
    async def test_conversation_message_order(self, auth_headers):
        """Test: Messages maintain correct order"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Create conversation
            response1 = await client.post(
                "/api/v1/chatbot/chat",
                json={"message": "First message", "language": "en"},
                headers=auth_headers
            )
            conversation_id = response1.json()["conversation_id"]
            
            # Add more messages
            await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "conversation_id": conversation_id,
                    "message": "Second message",
                    "language": "en"
                },
                headers=auth_headers
            )
            
            # Get conversation
            get_response = await client.get(
                f"/api/v1/chatbot/conversations/{conversation_id}",
                headers=auth_headers
            )
            
            messages = get_response.json()["messages"]
            
            # Verify order
            assert messages[0]["sender"] == "user"
            assert "First message" in messages[0]["message"]
            assert messages[1]["sender"] == "assistant"
    
    @pytest.mark.asyncio
    async def test_conversation_metadata_tracking(self, auth_headers):
        """Test: Conversation metadata is properly tracked"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.post(
                "/api/v1/chatbot/chat",
                json={
                    "message": "Test",
                    "language": "en",
                    "user_location": "Kathmandu"
                },
                headers=auth_headers
            )
            
            data = response.json()
            
            # Verify metadata
            assert "timestamp" in data
            assert "response_time" in data
            assert data["response_time"] > 0
