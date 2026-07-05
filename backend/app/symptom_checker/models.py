"""Database models for symptom checker predictions."""

from sqlalchemy import Column, Integer, String, Float, DateTime, JSON, ForeignKey, Boolean, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

# Re-use the shared Base from auth so all tables are registered together
from app.auth.models import Base


class SymptomCheckHistory(Base):
    """Store symptom check prediction history."""
    
    __tablename__ = "symptom_check_history"
    
    id = Column(Integer, primary_key=True, index=True)
    # user_id matches users.id which is String(36) UUID
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Input data
    symptoms = Column(JSON, nullable=False)  # List of symptoms
    age = Column(Integer, nullable=False)
    gender = Column(String(10), nullable=False)
    weight = Column(Float, nullable=True)
    height = Column(Float, nullable=True)
    duration = Column(Integer, nullable=True)  # Duration in days
    severity = Column(Integer, nullable=True)  # 1-4
    existing_diseases = Column(JSON, nullable=True)
    medications = Column(JSON, nullable=True)
    allergies = Column(JSON, nullable=True)
    
    # Prediction results
    predicted_disease = Column(String(255), nullable=False, index=True)
    confidence = Column(Float, nullable=False)
    top_diseases = Column(JSON, nullable=False)  # Top 5 predictions
    
    # Risk assessment
    risk_level = Column(String(20), nullable=False, index=True)  # low, medium, high, critical
    risk_score = Column(Float, nullable=False)
    is_emergency = Column(Boolean, default=False, index=True)
    critical_symptoms = Column(JSON, nullable=True)
    risk_factors = Column(JSON, nullable=True)
    
    # Recommendations
    recommended_department = Column(String(100), nullable=True)
    recommendations = Column(JSON, nullable=True)
    emergency_alert = Column(Text, nullable=True)
    
    # Metadata
    model_version = Column(String(50), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    
    # Relationships
    user = relationship("UserModel", back_populates="symptom_checks")
    
    def __repr__(self):
        return f"<SymptomCheckHistory(id={self.id}, user_id={self.user_id}, disease='{self.predicted_disease}')>"
