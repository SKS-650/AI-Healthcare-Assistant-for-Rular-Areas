"""Data cleaning utilities for symptom checker."""

import pandas as pd
import numpy as np
from typing import List, Optional
import re


class DataCleaner:
    """Clean and standardize medical data."""
    
    def __init__(self):
        self.removed_records = []
    
    def clean_dataset(self, df: pd.DataFrame) -> pd.DataFrame:
        """Apply all cleaning operations."""
        df = df.copy()
        
        # Remove duplicates
        df = self.remove_duplicates(df)
        
        # Handle missing values
        df = self.handle_missing_values(df)
        
        # Standardize text columns
        text_columns = df.select_dtypes(include=['object']).columns
        for col in text_columns:
            df[col] = df[col].apply(self.standardize_text)
        
        # Validate numeric ranges
        df = self.validate_numeric_ranges(df)
        
        # Remove invalid entries
        df = self.remove_invalid_entries(df)
        
        return df
    
    def remove_duplicates(self, df: pd.DataFrame) -> pd.DataFrame:
        """Remove duplicate records."""
        initial_count = len(df)
        df = df.drop_duplicates()
        removed = initial_count - len(df)
        
        if removed > 0:
            print(f"Removed {removed} duplicate records")
        
        return df
    
    def handle_missing_values(self, df: pd.DataFrame) -> pd.DataFrame:
        """Handle missing values appropriately."""
        # Get missing value statistics
        missing_stats = df.isnull().sum()
        missing_pct = (missing_stats / len(df)) * 100
        
        # Drop columns with > 50% missing values
        cols_to_drop = missing_pct[missing_pct > 50].index.tolist()
        if cols_to_drop:
            print(f"Dropping columns with >50% missing: {cols_to_drop}")
            df = df.drop(columns=cols_to_drop)
        
        # Drop rows with missing target variable
        if 'disease' in df.columns:
            df = df.dropna(subset=['disease'])
        
        # Fill missing symptoms with 0 (not present)
        symptom_cols = [col for col in df.columns if 'symptom' in col.lower()]
        for col in symptom_cols:
            df[col] = df[col].fillna(0)
        
        # Fill missing numeric values with median
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        for col in numeric_cols:
            if df[col].isnull().any():
                df[col] = df[col].fillna(df[col].median())
        
        return df
    
    def standardize_text(self, text: str) -> str:
        """Standardize text data."""
        if pd.isna(text) or not isinstance(text, str):
            return ""
        
        # Convert to lowercase
        text = text.lower()
        
        # Remove extra whitespace
        text = ' '.join(text.split())
        
        # Remove special characters (keep only alphanumeric and spaces)
        text = re.sub(r'[^a-z0-9\s]', '', text)
        
        return text.strip()
    
    def validate_numeric_ranges(self, df: pd.DataFrame) -> pd.DataFrame:
        """Validate numeric columns are within acceptable ranges."""
        validations = {
            'age': (0, 120),
            'weight': (1, 300),  # kg
            'height': (30, 250),  # cm
            'temperature': (35, 42),  # Celsius
            'systolic_bp': (60, 250),
            'diastolic_bp': (40, 150),
            'heart_rate': (30, 200)
        }
        
        for col, (min_val, max_val) in validations.items():
            if col in df.columns:
                # Flag invalid values
                invalid_mask = (df[col] < min_val) | (df[col] > max_val)
                invalid_count = invalid_mask.sum()
                
                if invalid_count > 0:
                    print(f"Found {invalid_count} invalid values in {col}")
                    # Replace with median
                    median_val = df.loc[~invalid_mask, col].median()
                    df.loc[invalid_mask, col] = median_val
        
        return df
    
    def remove_invalid_entries(self, df: pd.DataFrame) -> pd.DataFrame:
        """Remove entries with invalid or suspicious data."""
        initial_count = len(df)
        
        # Remove rows where all symptoms are 0
        symptom_cols = [col for col in df.columns if 'symptom' in col.lower()]
        if symptom_cols:
            symptom_sum = df[symptom_cols].sum(axis=1)
            df = df[symptom_sum > 0]
        
        # Remove rows with no disease label
        if 'disease' in df.columns:
            df = df[df['disease'].notna() & (df['disease'] != '')]
        
        removed = initial_count - len(df)
        if removed > 0:
            print(f"Removed {removed} invalid entries")
        
        return df
    
    def get_cleaning_report(self) -> dict:
        """Get report of cleaning operations."""
        return {
            "total_removed": len(self.removed_records),
            "removed_records": self.removed_records
        }


def clean_symptom_names(symptoms: List[str]) -> List[str]:
    """Clean and standardize symptom names."""
    cleaned = []
    
    for symptom in symptoms:
        # Convert to lowercase
        symptom = symptom.lower().strip()
        
        # Remove punctuation
        symptom = re.sub(r'[^\w\s]', '', symptom)
        
        # Replace underscores with spaces
        symptom = symptom.replace('_', ' ')
        
        # Remove extra spaces
        symptom = ' '.join(symptom.split())
        
        if symptom:
            cleaned.append(symptom)
    
    return cleaned


def normalize_disease_names(diseases: List[str]) -> List[str]:
    """Normalize disease names."""
    normalized = []
    
    for disease in diseases:
        # Convert to title case
        disease = disease.strip().title()
        
        # Remove extra spaces
        disease = ' '.join(disease.split())
        
        if disease:
            normalized.append(disease)
    
    return normalized
