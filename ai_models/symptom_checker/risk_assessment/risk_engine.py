"""Risk assessment engine for disease predictions."""

from typing import List, Dict, Tuple
import numpy as np

from ..config.config import config
from ..config.constants import CRITICAL_SYMPTOMS, HIGH_RISK_COMBINATIONS


class RiskAssessmentEngine:
    """Assess risk level based on symptoms and predictions."""
    
    def __init__(self):
        self.risk_levels = config.RISK_LEVELS
        self.critical_symptoms = [s.lower() for s in CRITICAL_SYMPTOMS]
        self.high_risk_combinations = [
            [s.lower() for s in combo] for combo in HIGH_RISK_COMBINATIONS
        ]
    
    def assess_risk(
        self,
        symptoms: List[str],
        confidence_score: float,
        severity: int = 1,
        age: int = None,
        existing_diseases: List[str] = None
    ) -> Tuple[str, float, Dict]:
        """
        Assess overall risk level.
        
        Args:
            symptoms: List of present symptoms
            confidence_score: Model's confidence in prediction
            severity: Symptom severity (1-4)
            age: Patient age
            existing_diseases: List of existing medical conditions
        
        Returns:
            Tuple of (risk_level, risk_score, risk_factors)
        """
        risk_score = 0.0
        risk_factors = []
        
        # 1. Base risk from confidence score
        risk_score += confidence_score * 0.4
        
        # 2. Emergency symptoms check
        emergency_score, emergency_factors = self._check_emergency_symptoms(symptoms)
        risk_score += emergency_score
        risk_factors.extend(emergency_factors)
        
        # 3. Symptom combination check
        combo_score, combo_factors = self._check_symptom_combinations(symptoms)
        risk_score += combo_score
        risk_factors.extend(combo_factors)
        
        # 4. Severity factor
        severity_score = (severity / 4) * 0.2  # Normalize to 0-0.2
        risk_score += severity_score
        if severity >= 3:
            risk_factors.append(f"High symptom severity (level {severity})")
        
        # 5. Age factor
        if age is not None:
            age_score, age_factors = self._assess_age_risk(age)
            risk_score += age_score
            risk_factors.extend(age_factors)
        
        # 6. Existing conditions factor
        if existing_diseases and len(existing_diseases) > 0:
            condition_score = min(len(existing_diseases) * 0.05, 0.15)
            risk_score += condition_score
            risk_factors.append(f"{len(existing_diseases)} existing condition(s)")
        
        # Cap risk score at 1.0
        risk_score = min(risk_score, 1.0)
        
        # Determine risk level
        risk_level = self._get_risk_level(risk_score)
        
        return risk_level, risk_score, {
            'factors': risk_factors,
            'breakdown': {
                'base_confidence': confidence_score * 0.4,
                'emergency_symptoms': emergency_score,
                'symptom_combinations': combo_score,
                'severity': severity_score
            }
        }
    
    def _check_emergency_symptoms(self, symptoms: List[str]) -> Tuple[float, List[str]]:
        """Check for critical emergency symptoms."""
        symptoms_lower = [s.lower() for s in symptoms]
        emergency_found = []
        
        for symptom in symptoms_lower:
            if any(critical in symptom for critical in self.critical_symptoms):
                emergency_found.append(symptom)
        
        if emergency_found:
            return 0.5, [f"Critical symptom: {s}" for s in emergency_found]
        
        return 0.0, []
    
    def _check_symptom_combinations(self, symptoms: List[str]) -> Tuple[float, List[str]]:
        """Check for high-risk symptom combinations."""
        symptoms_lower = [s.lower() for s in symptoms]
        combinations_found = []
        
        for combo in self.high_risk_combinations:
            if all(any(symp in s for s in symptoms_lower) for symp in combo):
                combinations_found.append(" + ".join(combo))
        
        if combinations_found:
            score = min(len(combinations_found) * 0.2, 0.3)
            return score, [f"High-risk combination: {c}" for c in combinations_found]
        
        return 0.0, []
    
    def _assess_age_risk(self, age: int) -> Tuple[float, List[str]]:
        """Assess age-based risk."""
        factors = []
        score = 0.0
        
        if age < 5:
            score = 0.15
            factors.append("Very young age (<5 years)")
        elif age < 12:
            score = 0.08
            factors.append("Young age (5-12 years)")
        elif age > 65:
            score = 0.12
            factors.append("Senior age (>65 years)")
        elif age > 75:
            score = 0.18
            factors.append("Advanced age (>75 years)")
        
        return score, factors
    
    def _get_risk_level(self, risk_score: float) -> str:
        """Determine risk level from score."""
        for level, bounds in self.risk_levels.items():
            if bounds['min'] <= risk_score < bounds['max']:
                return level
        
        return "medium"  # Default fallback
    
    def get_risk_color(self, risk_level: str) -> str:
        """Get color code for risk level."""
        return self.risk_levels.get(risk_level, {}).get('color', 'gray')
    
    def is_emergency(self, risk_level: str) -> bool:
        """Check if risk level requires emergency response."""
        return risk_level == "critical"
    
    def requires_immediate_attention(self, risk_level: str) -> bool:
        """Check if risk requires immediate medical attention."""
        return risk_level in ["high", "critical"]


class SeverityAnalyzer:
    """Analyze symptom severity."""
    
    @staticmethod
    def calculate_severity_score(
        symptom_count: int,
        severity_level: int,
        duration_days: int
    ) -> float:
        """
        Calculate overall severity score.
        
        Returns:
            Score between 0 and 1
        """
        # Symptom count factor (0-0.4)
        count_score = min(symptom_count / 10, 0.4)
        
        # Severity level factor (0-0.4)
        level_score = (severity_level / 4) * 0.4
        
        # Duration factor (0-0.2)
        if duration_days > 30:
            duration_score = 0.2
        elif duration_days > 14:
            duration_score = 0.15
        elif duration_days > 7:
            duration_score = 0.1
        else:
            duration_score = 0.05
        
        total_score = count_score + level_score + duration_score
        
        return min(total_score, 1.0)


class EmergencyDetector:
    """Detect emergency conditions."""
    
    def __init__(self):
        self.critical_symptoms = [s.lower() for s in CRITICAL_SYMPTOMS]
    
    def is_emergency(self, symptoms: List[str]) -> Tuple[bool, List[str]]:
        """
        Check if symptoms indicate an emergency.
        
        Returns:
            Tuple of (is_emergency, critical_symptoms_found)
        """
        symptoms_lower = [s.lower() for s in symptoms]
        critical_found = []
        
        for symptom in symptoms_lower:
            for critical in self.critical_symptoms:
                if critical in symptom:
                    critical_found.append(symptom)
        
        return len(critical_found) > 0, critical_found
    
    def get_emergency_message(self) -> str:
        """Get emergency alert message."""
        return (
            "⚠️ EMERGENCY: Your symptoms may indicate a serious medical condition. "
            "Please seek immediate medical attention or call emergency services."
        )
