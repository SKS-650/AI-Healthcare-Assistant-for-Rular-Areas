"""
Tests for Medical Chatbot API Routes
"""
import pytest
from uuid import uuid4
from fastapi.testclient import TestClient
from datetime import datetime


class TestChatbotRoutes:
    """Test cases for chatbot API routes"""
    
    @pytest.fixture
    def auth_headers(self):
        """Mock authentication headers"""
        return {"Authorization": "Bearer test_token"}
    
    def test_chat_new_conversation(self, client: TestClient, auth_headers):
        """Test creating new conversation"""
        payload = {
            "message": "What are the symptoms of diabetes?",
            "language": "en"
        }
        
        response = client.post(
            "/api/v1/chatbot/chat",
            json=payload,
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "assistant_message" in data
        assert "conversation_id" in data
        assert "message_id" in data
        assert data["emergency_detected"] is False
    
    def test_chat_continue_conversation(self, client: TestClient, auth_headers):
        """Test continuing existing conversation"""
        # First message
        payload1 = {
            "message": "Tell me about diabetes",
            "language": "en"
        }
        response1 = client.post(
            "/api/v1/chatbot/chat",
            json=payload1,
            headers=auth_headers
        )
        assert response1.status_code == 200
        conversation_id = response1.json()["conversation_id"]
        
        # Continue conversation
        payload2 = {
            "message": "What are the risk factors?",
            "conversation_id": conversation_id,
            "language": "en"
        }
        response2 = client.post(
            "/api/v1/chatbot/chat",
            json=payload2,
            headers=auth_headers
        )
        
        assert response2.status_code == 200
        data = response2.json()
        assert data["conversation_id"] == conversation_id
    
    def test_chat_empty_message(self, client: TestClient, auth_headers):
        """Test chat with empty message"""
        payload = {
            "message": "",
            "language": "en"
        }
        
        response = client.post(
            "/api/v1/chatbot/chat",
            json=payload,
            headers=auth_headers
        )
        
        assert response.status_code == 422  # Validation error
    
    def test_chat_emergency_detection(self, client: TestClient, auth_headers):
        """Test emergency keyword detection"""
        payload = {
            "message": "I'm having severe chest pain",
            "language": "en"
        }
        
        response = client.post(
            "/api/v1/chatbot/chat",
            json=payload,
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["emergency_detected"] is True
    
    def test_chat_unauthorized(self, client: TestClient):
        """Test chat without authentication"""
        payload = {
            "message": "Hello",
            "language": "en"
        }
        
        response = client.post(
            "/api/v1/chatbot/chat",
            json=payload
        )
        
        assert response.status_code == 401
    
    def test_get_conversations(self, client: TestClient, auth_headers):
        """Test getting user's conversations"""
        response = client.get(
            "/api/v1/chatbot/conversations",
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "conversations" in data
        assert "total" in data
        assert "page" in data
        assert "page_size" in data
        assert "total_pages" in data
    
    def test_get_conversations_with_pagination(self, client: TestClient, auth_headers):
        """Test conversations with pagination"""
        response = client.get(
            "/api/v1/chatbot/conversations?page=1&page_size=10",
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["page"] == 1
        assert data["page_size"] == 10
    
    def test_get_conversations_with_search(self, client: TestClient, auth_headers):
        """Test conversations with search"""
        response = client.get(
            "/api/v1/chatbot/conversations?search=diabetes",
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "conversations" in data
    
    def test_get_conversation_by_id(self, client: TestClient, auth_headers):
        """Test getting specific conversation"""
        # Create conversation first
        payload = {
            "message": "Test message",
            "language": "en"
        }
        create_response = client.post(
            "/api/v1/chatbot/chat",
            json=payload,
            headers=auth_headers
        )
        conversation_id = create_response.json()["conversation_id"]
        
        # Get conversation
        response = client.get(
            f"/api/v1/chatbot/conversations/{conversation_id}",
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["uuid"] == conversation_id
        assert "messages" in data
    
    def test_get_conversation_not_found(self, client: TestClient, auth_headers):
        """Test getting non-existent conversation"""
        fake_id = str(uuid4())
        response = client.get(
            f"/api/v1/chatbot/conversations/{fake_id}",
            headers=auth_headers
        )
        
        assert response.status_code == 404
    
    def test_delete_conversation(self, client: TestClient, auth_headers):
        """Test deleting conversation"""
        # Create conversation first
        payload = {
            "message": "Test message",
            "language": "en"
        }
        create_response = client.post(
            "/api/v1/chatbot/chat",
            json=payload,
            headers=auth_headers
        )
        conversation_id = create_response.json()["conversation_id"]
        
        # Delete conversation
        response = client.delete(
            f"/api/v1/chatbot/conversations/{conversation_id}",
            headers=auth_headers
        )
        
        assert response.status_code == 200
        assert "message" in response.json()
    
    def test_delete_conversation_not_found(self, client: TestClient, auth_headers):
        """Test deleting non-existent conversation"""
        fake_id = str(uuid4())
        response = client.delete(
            f"/api/v1/chatbot/conversations/{fake_id}",
            headers=auth_headers
        )
        
        assert response.status_code == 404
    
    def test_submit_feedback(self, client: TestClient, auth_headers):
        """Test submitting feedback"""
        # Create conversation first
        payload = {
            "message": "Test message",
            "language": "en"
        }
        create_response = client.post(
            "/api/v1/chatbot/chat",
            json=payload,
            headers=auth_headers
        )
        conversation_id = create_response.json()["conversation_id"]
        message_id = create_response.json()["message_id"]
        
        # Submit feedback
        feedback_payload = {
            "conversation_id": conversation_id,
            "message_id": message_id,
            "rating": 5,
            "feedback_text": "Very helpful",
            "feedback_type": "helpful"
        }
        
        response = client.post(
            "/api/v1/chatbot/feedback",
            json=feedback_payload,
            headers=auth_headers
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["rating"] == 5
        assert data["feedback_type"] == "helpful"
    
    def test_submit_feedback_invalid_rating(self, client: TestClient, auth_headers):
        """Test feedback with invalid rating"""
        conversation_id = str(uuid4())
        
        feedback_payload = {
            "conversation_id": conversation_id,
            "rating": 10,  # Invalid: should be 1-5
            "feedback_text": "Test"
        }
        
        response = client.post(
            "/api/v1/chatbot/feedback",
            json=feedback_payload,
            headers=auth_headers
        )
        
        assert response.status_code == 422  # Validation error
    
    def test_health_check(self, client: TestClient):
        """Test health check endpoint"""
        response = client.get("/api/v1/chatbot/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] in ["healthy", "unhealthy"]
        assert "service" in data
        assert "version" in data
        assert "components" in data
