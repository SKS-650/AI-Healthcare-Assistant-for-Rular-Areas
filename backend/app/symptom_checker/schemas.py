"""Pydantic schemas for symptom checker API."""

from typing import List, Optional, Dict
from pydantic import BaseModel, Field, field_validator
from datetime import datetime


class SymptomCheckRequest(BaseModel):
    """Request schema for symptom checking."""
    
    symptoms: List[str] = Field(..., description="List of symptoms", min_items=1)
    age: int = Field(..., description="Patient age", ge=0, le=120)
    gender: str = Field(..., description="Patient gender")
    weight: Optional[float] = Field(None, description="Weight in kg", ge=1, le=300)
    height: Optional[float] = Field(None, description="Height in cm", ge=30, le=250)
    duration: Optional[int] = Field(None, description="Symptom duration in days", ge=0)
    severity: Optional[int] = Field(1, description="Severity level 1-4", ge=1, le=4)
    existing_diseases: Optional[List[str]] = Field(None, description="Existing medical conditions")
    medications: Optional[List[str]] = Field(None, description="Current medications")
    allergies: Optional[List[str]] = Field(None, description="Known allergies")
    pregnancy_status: Optional[bool] = Field(False, description="Pregnancy status")
    
    @field_validator('gender')
    @classmethod
    def validate_gender(cls, v):
        """Validate gender field."""
        allowed = ['male', 'female', 'other']
        if v.lower() not in allowed:
            raise ValueError(f"Gender must be one of: {allowed}")
        return v.lower()
    
    @field_validator('symptoms')
    @classmethod
    def validate_symptoms(cls, v):
        """Validate symptoms list."""
        if not v or len(v) == 0:
            raise ValueError("At least one symptom is required")
        # Clean symptom strings
        return [s.strip() for s in v if s.strip()]
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "symptoms": ["fever", "cough", "headache", "fatigue"],
                "age": 35,
                "gender": "male",
                "weight": 75,
                "height": 175,
                "duration": 3,
                "severity": 2,
                "existing_diseases": [],
                "medications": [],
                "allergies": [],
                "pregnancy_status": False
            }
        }
    }


class DiseaseConfidence(BaseModel):
    """Disease prediction with confidence score."""
    
    disease: str = Field(..., description="Disease name")
    confidence: float = Field(..., description="Confidence score 0-1", ge=0, le=1)


class RiskAssessment(BaseModel):
    """Risk assessment details."""
    
    risk_level: str = Field(..., description="Risk level: low, medium, high, critical")
    risk_score: float = Field(..., description="Numerical risk score 0-1", ge=0, le=1)
    is_emergency: bool = Field(..., description="Whether this is an emergency")
    critical_symptoms: List[str] = Field(..., description="Critical symptoms found")
    risk_factors: List[str] = Field(..., description="Contributing risk factors")


class Recommendation(BaseModel):
    """Medical recommendations."""
    
    risk_level: str
    primary_action: str
    department: str
    department_code: str
    actions: List[str]
    care_advice: List[str]
    follow_up: Dict
    urgency: str
    emergency_contact: bool


class SymptomCheckResponse(BaseModel):
    """Response schema for symptom checking."""
    
    status: str = Field(..., description="Response status")
    prediction: Dict = Field(..., description="Disease predictions")
    risk_assessment: RiskAssessment = Field(..., description="Risk assessment")
    recommendations: Recommendation = Field(..., description="Medical recommendations")
    input_summary: Dict = Field(..., description="Summary of input data")
    metadata: Dict = Field(..., description="Response metadata")
    emergency_alert: Optional[str] = Field(None, description="Emergency alert message")


class PredictionHistory(BaseModel):
    """Prediction history record."""
    
    id: int
    user_id: int
    symptoms: List[str]
    predicted_disease: str
    confidence: float
    risk_level: str
    risk_score: float
    created_at: datetime
    
    model_config = {"from_attributes": True}


class SymptomListResponse(BaseModel):
    """Response for symptom list."""
    
    symptoms: List[str] = Field(..., description="List of available symptoms")
    total: int = Field(..., description="Total number of symptoms")


class DiseaseListResponse(BaseModel):
    """Response for disease list."""
    
    diseases: List[str] = Field(..., description="List of diseases model can predict")
    total: int = Field(..., description="Total number of diseases")


class HealthStatusResponse(BaseModel):
    """Health check response."""
    
    status: str
    model_loaded: bool
    model_version: Optional[str]
    available_symptoms: int
    message: str

    model_config = {"protected_namespaces": ()}
