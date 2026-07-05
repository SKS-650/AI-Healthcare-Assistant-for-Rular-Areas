"""Path management for symptom checker module."""

from pathlib import Path
from typing import Optional

BASE_DIR = Path(__file__).resolve().parent.parent
ROOT_DIR = BASE_DIR.parent.parent


class Paths:
    """Centralized path management."""
    
    # Base directories
    BASE = BASE_DIR
    ROOT = ROOT_DIR
    
    # Data directories
    DATASETS = BASE / "datasets"
    RAW_DATA = DATASETS / "raw"
    PROCESSED_DATA = DATASETS / "processed"
    INTERIM_DATA = DATASETS / "interim"
    TRAINING_DATA = DATASETS / "training"
    VALIDATION_DATA = DATASETS / "validation"
    TESTING_DATA = DATASETS / "testing"
    EXTERNAL_DATA = DATASETS / "external"
    SAMPLE_DATA = DATASETS / "sample"
    
    # Artifacts
    ARTIFACTS = BASE / "artifacts"
    MODELS = ARTIFACTS / "trained_models"
    ENCODERS = ARTIFACTS / "encoders"
    SCALERS = ARTIFACTS / "scalers"
    TRANSFORMERS = ARTIFACTS / "transformers"
    FEATURE_NAMES = ARTIFACTS / "feature_names"
    LABEL_ENCODERS = ARTIFACTS / "label_encoders"
    
    # Logs
    LOGS = BASE / "logs"
    TRAINING_LOGS = LOGS / "training"
    INFERENCE_LOGS = LOGS / "inference"
    ERROR_LOGS = LOGS / "errors"
    
    # Reports
    REPORTS = BASE / "reports"
    EVALUATION_REPORTS = REPORTS / "evaluation"
    TRAINING_REPORTS = REPORTS / "training"
    
    # Config
    CONFIG = BASE / "config"
    
    @classmethod
    def ensure_directories(cls):
        """Create all necessary directories."""
        directories = [
            cls.RAW_DATA, cls.PROCESSED_DATA, cls.INTERIM_DATA,
            cls.TRAINING_DATA, cls.VALIDATION_DATA, cls.TESTING_DATA,
            cls.EXTERNAL_DATA, cls.SAMPLE_DATA,
            cls.MODELS, cls.ENCODERS, cls.SCALERS, cls.TRANSFORMERS,
            cls.FEATURE_NAMES, cls.LABEL_ENCODERS,
            cls.TRAINING_LOGS, cls.INFERENCE_LOGS, cls.ERROR_LOGS,
            cls.EVALUATION_REPORTS, cls.TRAINING_REPORTS
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
    
    @classmethod
    def get_model_path(cls, model_name: str, version: Optional[str] = None) -> Path:
        """Get path for a specific model."""
        if version:
            return cls.MODELS / f"{model_name}_{version}.pkl"
        return cls.MODELS / f"{model_name}.pkl"
    
    @classmethod
    def get_encoder_path(cls, encoder_name: str) -> Path:
        """Get path for an encoder."""
        return cls.ENCODERS / f"{encoder_name}.pkl"
    
    @classmethod
    def get_scaler_path(cls, scaler_name: str) -> Path:
        """Get path for a scaler."""
        return cls.SCALERS / f"{scaler_name}.pkl"


# Initialize directories
Paths.ensure_directories()
