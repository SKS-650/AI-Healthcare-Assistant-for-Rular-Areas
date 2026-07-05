"""Categorical feature encoding for symptom checker."""

import pandas as pd
import numpy as np
from typing import Dict, List, Optional
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
import joblib

from ..config.constants import GENDER_ENCODING, SEVERITY_LEVELS


class CategoricalEncoder:
    """Encode categorical features for ML models."""
    
    def __init__(self):
        self.label_encoders: Dict[str, LabelEncoder] = {}
        self.encoding_maps: Dict[str, Dict] = {
            'gender': GENDER_ENCODING,
            'severity': SEVERITY_LEVELS
        }
    
    def fit(self, df: pd.DataFrame, categorical_columns: List[str]) -> 'CategoricalEncoder':
        """Fit encoders on categorical columns."""
        for col in categorical_columns:
            if col in self.encoding_maps:
                # Use predefined mapping
                continue
            
            # Create and fit label encoder
            le = LabelEncoder()
            # Handle missing values
            valid_data = df[col].dropna()
            if len(valid_data) > 0:
                le.fit(valid_data)
                self.label_encoders[col] = le
        
        return self
    
    def transform(self, df: pd.DataFrame) -> pd.DataFrame:
        """Transform categorical columns."""
        df = df.copy()
        
        # Apply predefined encodings
        for col, mapping in self.encoding_maps.items():
            if col in df.columns:
                df[col] = df[col].map(mapping)
                # Fill any unmapped values with a default
                df[col] = df[col].fillna(0)
        
        # Apply learned encodings
        for col, encoder in self.label_encoders.items():
            if col in df.columns:
                # Handle unseen categories
                df[col] = df[col].apply(
                    lambda x: x if x in encoder.classes_ else encoder.classes_[0]
                )
                df[col] = encoder.transform(df[col])
        
        return df
    
    def fit_transform(self, df: pd.DataFrame, categorical_columns: List[str]) -> pd.DataFrame:
        """Fit and transform in one step."""
        self.fit(df, categorical_columns)
        return self.transform(df)
    
    def inverse_transform(self, df: pd.DataFrame, column: str) -> pd.DataFrame:
        """Reverse the encoding."""
        df = df.copy()
        
        if column in self.label_encoders:
            df[column] = self.label_encoders[column].inverse_transform(df[column])
        elif column in self.encoding_maps:
            # Create reverse mapping
            reverse_map = {v: k for k, v in self.encoding_maps[column].items()}
            df[column] = df[column].map(reverse_map)
        
        return df
    
    def save(self, filepath: str):
        """Save encoder to file."""
        joblib.dump({
            'label_encoders': self.label_encoders,
            'encoding_maps': self.encoding_maps
        }, filepath)
    
    @classmethod
    def load(cls, filepath: str) -> 'CategoricalEncoder':
        """Load encoder from file."""
        data = joblib.load(filepath)
        encoder = cls()
        encoder.label_encoders = data['label_encoders']
        encoder.encoding_maps = data['encoding_maps']
        return encoder


def encode_gender(gender: str) -> int:
    """Encode gender value."""
    gender = gender.lower().strip()
    return GENDER_ENCODING.get(gender, 2)  # Default to 'other'


def encode_severity(severity: str) -> int:
    """Encode severity level."""
    severity = severity.lower().strip()
    return SEVERITY_LEVELS.get(severity, 1)  # Default to 'mild'


def create_multi_hot_encoding(
    symptoms: List[str],
    all_symptoms: List[str]
) -> np.ndarray:
    """Create multi-hot encoding for symptoms.
    
    Args:
        symptoms: List of present symptoms
        all_symptoms: Complete list of all possible symptoms
    
    Returns:
        Binary array where 1 indicates symptom is present
    """
    encoding = np.zeros(len(all_symptoms), dtype=int)
    
    for i, symptom in enumerate(all_symptoms):
        if symptom in symptoms:
            encoding[i] = 1
    
    return encoding


def decode_multi_hot_encoding(
    encoding: np.ndarray,
    all_symptoms: List[str]
) -> List[str]:
    """Decode multi-hot encoding back to symptom list."""
    present_symptoms = []
    
    for i, value in enumerate(encoding):
        if value == 1 and i < len(all_symptoms):
            present_symptoms.append(all_symptoms[i])
    
    return present_symptoms
