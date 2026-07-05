"""Main configuration for symptom checker module."""

import os
from pathlib import Path
from typing import Dict, List

# Base paths
BASE_DIR = Path(__file__).resolve().parent.parent
ROOT_DIR = BASE_DIR.parent.parent
DATASETS_DIR = ROOT_DIR / "datasets"
ARTIFACTS_DIR = BASE_DIR / "artifacts"

# Dataset paths
RAW_DATA_DIR = BASE_DIR / "datasets" / "raw"
PROCESSED_DATA_DIR = BASE_DIR / "datasets" / "processed"
TRAINING_DATA_DIR = BASE_DIR / "datasets" / "training"
VALIDATION_DATA_DIR = BASE_DIR / "datasets" / "validation"
TESTING_DATA_DIR = BASE_DIR / "datasets" / "testing"

# Model artifacts
MODEL_DIR = ARTIFACTS_DIR / "trained_models"
ENCODER_DIR = ARTIFACTS_DIR / "encoders"
SCALER_DIR = ARTIFACTS_DIR / "scalers"
FEATURE_DIR = ARTIFACTS_DIR / "feature_names"

# Create directories
for dir_path in [
    RAW_DATA_DIR, PROCESSED_DATA_DIR, TRAINING_DATA_DIR,
    VALIDATION_DATA_DIR, TESTING_DATA_DIR, MODEL_DIR,
    ENCODER_DIR, SCALER_DIR, FEATURE_DIR
]:
    dir_path.mkdir(parents=True, exist_ok=True)


class Config:
    """Base configuration class."""
    
    # Application
    APP_NAME = "Symptom Checker"
    VERSION = "1.0.0"
    DEBUG = os.getenv("DEBUG", "false").lower() == "true"
    
    # Paths
    BASE_DIR = BASE_DIR
    DATASETS_DIR = DATASETS_DIR
    ARTIFACTS_DIR = ARTIFACTS_DIR
    
    # Model
    MODEL_NAME = "random_forest_symptom_checker"
    MODEL_VERSION = "v1.0"
    
    # Training
    TEST_SIZE = 0.15
    VALIDATION_SIZE = 0.15
    RANDOM_STATE = 42
    
    # Feature Engineering
    MAX_SYMPTOMS = 500
    MIN_SYMPTOM_FREQUENCY = 5
    
    # Model Parameters
    N_ESTIMATORS = 200
    MAX_DEPTH = 30
    MIN_SAMPLES_SPLIT = 5
    MIN_SAMPLES_LEAF = 2
    MAX_FEATURES = "sqrt"
    N_JOBS = -1
    
    # Prediction
    TOP_K_DISEASES = 5
    MIN_CONFIDENCE_THRESHOLD = 0.005  # lowered: model spreads probability across many classes
    
    # Risk Levels
    RISK_LEVELS = {
        "low": {"min": 0, "max": 0.3, "color": "green"},
        "medium": {"min": 0.3, "max": 0.6, "color": "yellow"},
        "high": {"min": 0.6, "max": 0.85, "color": "orange"},
        "critical": {"min": 0.85, "max": 1.0, "color": "red"}
    }
    
    # Emergency Keywords
    EMERGENCY_SYMPTOMS = [
        "chest pain", "severe chest pain", "difficulty breathing",
        "shortness of breath", "loss of consciousness", "unconsciousness",
        "severe bleeding", "heavy bleeding", "stroke symptoms",
        "sudden numbness", "severe headache", "confusion",
        "severe abdominal pain", "coughing blood", "vomiting blood",
        "seizures", "severe allergic reaction", "anaphylaxis"
    ]
    
    # Medical Departments
    DEPARTMENTS = {
        "general": "General Medicine",
        "cardiology": "Cardiology",
        "neurology": "Neurology",
        "gastroenterology": "Gastroenterology",
        "respiratory": "Respiratory/Pulmonology",
        "endocrinology": "Endocrinology",
        "dermatology": "Dermatology",
        "orthopedics": "Orthopedics",
        "ent": "ENT (Ear, Nose, Throat)",
        "ophthalmology": "Ophthalmology",
        "psychiatry": "Psychiatry",
        "emergency": "Emergency Department"
    }


class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True


class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False


# Select config based on environment
ENV = os.getenv("ENVIRONMENT", "development")
config = DevelopmentConfig() if ENV == "development" else ProductionConfig()
