"""
Pytest configuration and fixtures for Medical Chatbot tests
"""
import pytest
from typing import Generator
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.auth.models import Base


# Use in-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db_session():
    """Create a fresh database session for each test"""
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db_session) -> Generator:
    """Create a test client"""
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def sample_user_data():
    """Sample user data for testing"""
    return {
        "id": 1,
        "email": "test@example.com",
        "full_name": "Test User",
        "role": "patient",
        "is_active": True
    }


@pytest.fixture
def sample_admin_data():
    """Sample admin data for testing"""
    return {
        "id": 2,
        "email": "admin@example.com",
        "full_name": "Admin User",
        "role": "admin",
        "is_active": True
    }


@pytest.fixture
def sample_conversation_data():
    """Sample conversation data for testing"""
    return {
        "title": "Test Conversation",
        "language": "en",
        "is_active": True
    }


@pytest.fixture
def sample_message_data():
    """Sample message data for testing"""
    return {
        "sender": "user",
        "message": "What are the symptoms of diabetes?",
        "tokens_used": 50,
        "response_time": 1.5,
        "confidence": 0.85,
        "emergency_detected": False
    }


@pytest.fixture
def sample_feedback_data():
    """Sample feedback data for testing"""
    return {
        "rating": 5,
        "feedback_text": "Very helpful information",
        "feedback_type": "helpful"
    }
