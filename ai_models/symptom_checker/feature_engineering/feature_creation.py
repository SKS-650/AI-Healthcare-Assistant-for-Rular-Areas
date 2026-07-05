"""Feature creation for symptom checker model."""

import pandas as pd
import numpy as np
from typing import List, Dict
from ..config.constants import AGE_GROUPS, BMI_CATEGORIES, DURATION_CATEGORIES


class FeatureEngineer:
    """Create engineered features for better predictions."""
    
    def __init__(self):
        self.feature_names = []
    
    def create_all_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """Create all engineered features."""
        df = df.copy()
        
        # Basic derived features
        if 'age' in df.columns:
            df = self.create_age_group(df)
        
        if 'weight' in df.columns and 'height' in df.columns:
            df = self.create_bmi_features(df)
        
        if 'duration' in df.columns:
            df = self.create_duration_category(df)
        
        # Symptom-based features (only if symptom_count exists)
        if 'symptom_count' in df.columns:
            # Categorize by count
            df['few_symptoms'] = (df['symptom_count'] <= 3).astype(int)
            df['many_symptoms'] = (df['symptom_count'] > 5).astype(int)
            
            # Calculate severity score
            if 'severity' in df.columns:
                df['severity_score'] = df['symptom_count'] * df['severity']
            else:
                df['severity_score'] = df['symptom_count']
        
        # Medical history features
        if 'existing_diseases' in df.columns:
            df = self.create_disease_count(df)
        
        if 'medications' in df.columns:
            df = self.create_medication_count(df)
        
        if 'allergies' in df.columns:
            df = self.create_allergy_count(df)
        
        # Risk indicators
        df = self.create_risk_indicators(df)
        
        return df
    
    def create_age_group(self, df: pd.DataFrame) -> pd.DataFrame:
        """Create age group categories."""
        def get_age_group(age):
            for group_name, (min_age, max_age) in AGE_GROUPS.items():
                if min_age <= age <= max_age:
                    return group_name
            return "adult"
        
        df['age_group'] = df['age'].apply(get_age_group)
        
        # One-hot encode age groups
        age_group_dummies = pd.get_dummies(df['age_group'], prefix='age_group')
        df = pd.concat([df, age_group_dummies], axis=1)
        
        return df
    
    def create_bmi_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """Calculate BMI and create BMI categories."""
        # Calculate BMI: weight (kg) / (height (m))^2
        # Convert height from cm to m
        df['height_m'] = df['height'] / 100
        df['bmi'] = df['weight'] / (df['height_m'] ** 2)
        
        # Create BMI category
        def get_bmi_category(bmi):
            for category, (min_bmi, max_bmi) in BMI_CATEGORIES.items():
                if min_bmi <= bmi < max_bmi:
                    return category
            return "normal"
        
        df['bmi_category'] = df['bmi'].apply(get_bmi_category)
        
        # Binary flags
        df['is_underweight'] = (df['bmi'] < 18.5).astype(int)
        df['is_overweight'] = (df['bmi'] >= 25).astype(int)
        df['is_obese'] = (df['bmi'] >= 30).astype(int)
        
        # Drop temporary column
        df = df.drop(columns=['height_m'])
        
        return df
    
    def create_duration_category(self, df: pd.DataFrame) -> pd.DataFrame:
        """Categorize symptom duration."""
        def get_duration_category(duration):
            for category, (min_days, max_days) in DURATION_CATEGORIES.items():
                if min_days <= duration < max_days:
                    return category
            return "chronic"
        
        df['duration_category'] = df['duration'].apply(get_duration_category)
        
        # Binary flags
        df['is_acute'] = (df['duration'] < 7).astype(int)
        df['is_chronic'] = (df['duration'] >= 30).astype(int)
        
        return df
    
    def create_symptom_count(self, df: pd.DataFrame, symptom_cols: List[str]) -> pd.DataFrame:
        """Count total number of symptoms."""
        df['symptom_count'] = df[symptom_cols].sum(axis=1)
        
        # Categorize by count
        df['few_symptoms'] = (df['symptom_count'] <= 3).astype(int)
        df['many_symptoms'] = (df['symptom_count'] > 5).astype(int)
        
        return df
    
    def create_symptom_severity_score(
        self,
        df: pd.DataFrame,
        symptom_cols: List[str]
    ) -> pd.DataFrame:
        """Calculate overall severity score."""
        if 'severity' in df.columns:
            # Multiply symptom count by severity level
            df['severity_score'] = df['symptom_count'] * df['severity']
        else:
            # Use symptom count as proxy
            df['severity_score'] = df['symptom_count']
        
        return df
    
    def create_disease_count(self, df: pd.DataFrame) -> pd.DataFrame:
        """Count existing diseases."""
        if df['existing_diseases'].dtype == 'object':
            # Assuming comma-separated diseases
            df['disease_count'] = df['existing_diseases'].apply(
                lambda x: len(str(x).split(',')) if pd.notna(x) and str(x).strip() else 0
            )
        else:
            df['disease_count'] = df['existing_diseases'].fillna(0)
        
        df['has_existing_disease'] = (df['disease_count'] > 0).astype(int)
        
        return df
    
    def create_medication_count(self, df: pd.DataFrame) -> pd.DataFrame:
        """Count current medications."""
        if df['medications'].dtype == 'object':
            df['medication_count'] = df['medications'].apply(
                lambda x: len(str(x).split(',')) if pd.notna(x) and str(x).strip() else 0
            )
        else:
            df['medication_count'] = df['medications'].fillna(0)
        
        df['on_medication'] = (df['medication_count'] > 0).astype(int)
        
        return df
    
    def create_allergy_count(self, df: pd.DataFrame) -> pd.DataFrame:
        """Count known allergies."""
        if df['allergies'].dtype == 'object':
            df['allergy_count'] = df['allergies'].apply(
                lambda x: len(str(x).split(',')) if pd.notna(x) and str(x).strip() else 0
            )
        else:
            df['allergy_count'] = df['allergies'].fillna(0)
        
        df['has_allergies'] = (df['allergy_count'] > 0).astype(int)
        
        return df
    
    def create_risk_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        """Create risk indicator features."""
        # Age-based risk
        if 'age' in df.columns:
            df['high_risk_age'] = ((df['age'] < 5) | (df['age'] > 65)).astype(int)
        
        # Combine multiple risk factors
        risk_factors = []
        
        if 'has_existing_disease' in df.columns:
            risk_factors.append('has_existing_disease')
        if 'high_risk_age' in df.columns:
            risk_factors.append('high_risk_age')
        if 'many_symptoms' in df.columns:
            risk_factors.append('many_symptoms')
        
        if risk_factors:
            df['risk_factor_count'] = df[risk_factors].sum(axis=1)
        
        return df
    
    def get_feature_names(self) -> List[str]:
        """Return list of created feature names."""
        return self.feature_names


def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    """Calculate BMI."""
    height_m = height_cm / 100
    return weight_kg / (height_m ** 2)


def get_age_group_name(age: int) -> str:
    """Get age group for a given age."""
    for group_name, (min_age, max_age) in AGE_GROUPS.items():
        if min_age <= age <= max_age:
            return group_name
    return "adult"
