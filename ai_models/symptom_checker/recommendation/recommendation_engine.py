"""Recommendation engine for medical advice based on predictions."""

from typing import List, Dict, Optional
from ..config.constants import RECOMMENDATIONS
from ..config.config import config


class RecommendationEngine:
    """Generate medical recommendations based on risk and predictions."""
    
    def __init__(self):
        self.recommendations = RECOMMENDATIONS
        self.departments = config.DEPARTMENTS
        
        # Disease to department mapping
        self.disease_department_map = {
            # Cardiovascular
            'heart attack': 'emergency',
            'angina': 'cardiology',
            'hypertension': 'cardiology',
            'arrhythmia': 'cardiology',
            
            # Respiratory
            'pneumonia': 'respiratory',
            'asthma': 'respiratory',
            'bronchitis': 'respiratory',
            'copd': 'respiratory',
            
            # Neurological
            'stroke': 'emergency',
            'migraine': 'neurology',
            'epilepsy': 'neurology',
            'meningitis': 'emergency',
            
            # Digestive
            'appendicitis': 'emergency',
            'gastritis': 'gastroenterology',
            'ulcer': 'gastroenterology',
            'hepatitis': 'gastroenterology',
            
            # Endocrine
            'diabetes': 'endocrinology',
            'thyroid': 'endocrinology',
            'hyperthyroidism': 'endocrinology',
            
            # Dermatology
            'eczema': 'dermatology',
            'psoriasis': 'dermatology',
            'dermatitis': 'dermatology',
            
            # Orthopedics
            'fracture': 'emergency',
            'arthritis': 'orthopedics',
            'osteoporosis': 'orthopedics',
            
            # ENT
            'sinusitis': 'ent',
            'tonsillitis': 'ent',
            'otitis': 'ent',
            
            # Ophthalmology
            'glaucoma': 'ophthalmology',
            'conjunctivitis': 'ophthalmology',
            'cataract': 'ophthalmology',
            
            # Infectious
            'covid-19': 'general',
            'influenza': 'general',
            'malaria': 'general',
            'dengue': 'general'
        }
    
    def generate_recommendations(
        self,
        disease: str,
        risk_level: str,
        confidence: float,
        symptoms: List[str] = None
    ) -> Dict:
        """
        Generate comprehensive recommendations.
        
        Args:
            disease: Predicted disease name
            risk_level: Risk level (low, medium, high, critical)
            confidence: Prediction confidence
            symptoms: List of symptoms
        
        Returns:
            Dictionary with recommendations
        """
        # Base recommendation from risk level
        base_rec = self.recommendations.get(risk_level, self.recommendations['medium'])
        
        # Determine department
        department = self._get_department(disease)
        
        # Generate specific actions
        actions = self._generate_actions(disease, risk_level, confidence)
        
        # Generate care advice
        care_advice = self._generate_care_advice(disease, risk_level)
        
        # Generate follow-up recommendations
        follow_up = self._generate_follow_up(risk_level, confidence)
        
        return {
            'risk_level': risk_level,
            'primary_action': base_rec['action'],
            'department': self.departments.get(department, 'General Medicine'),
            'department_code': department,
            'actions': actions,
            'care_advice': care_advice,
            'follow_up': follow_up,
            'urgency': self._get_urgency_level(risk_level),
            'emergency_contact': risk_level == 'critical'
        }
    
    def _get_department(self, disease: str) -> str:
        """Determine appropriate medical department."""
        disease_lower = disease.lower()
        
        # Check direct mappings
        for key, dept in self.disease_department_map.items():
            if key in disease_lower:
                return dept
        
        # Default to general medicine
        return 'general'
    
    def _generate_actions(
        self,
        disease: str,
        risk_level: str,
        confidence: float
    ) -> List[str]:
        """Generate specific action items."""
        actions = []
        
        if risk_level == 'critical':
            actions.extend([
                "Call emergency services (911/108) immediately",
                "Do not attempt to drive yourself",
                "Have someone stay with you",
                "Prepare medical history and medication list"
            ])
        elif risk_level == 'high':
            actions.extend([
                "Visit hospital emergency department or urgent care today",
                "Bring valid ID and insurance information",
                "List all current medications and allergies",
                "Have someone accompany you if possible"
            ])
        elif risk_level == 'medium':
            actions.extend([
                "Schedule appointment with doctor within 2-3 days",
                "Monitor symptoms for any worsening",
                "Keep a symptom diary",
                "Prepare questions for your doctor"
            ])
        else:  # low
            actions.extend([
                "Monitor symptoms over next few days",
                "Practice self-care and rest",
                "Consult doctor if symptoms persist beyond 7 days",
                "Maintain proper hydration and nutrition"
            ])
        
        return actions
    
    def _generate_care_advice(self, disease: str, risk_level: str) -> List[str]:
        """Generate home care advice."""
        general_advice = [
            "Get adequate rest and sleep",
            "Stay well hydrated",
            "Maintain a balanced diet",
            "Avoid strenuous activities"
        ]
        
        disease_lower = disease.lower()
        specific_advice = []
        
        # Add disease-specific advice
        if 'fever' in disease_lower or 'flu' in disease_lower:
            specific_advice.extend([
                "Monitor body temperature regularly",
                "Use fever-reducing medication if needed (consult pharmacist)",
                "Apply cool compresses if temperature is high"
            ])
        
        if 'cough' in disease_lower or 'respiratory' in disease_lower:
            specific_advice.extend([
                "Avoid cold air and irritants",
                "Use steam inhalation",
                "Keep head elevated while sleeping"
            ])
        
        if 'pain' in disease_lower:
            specific_advice.extend([
                "Apply hot/cold compress as appropriate",
                "Avoid activities that worsen pain",
                "Note pain patterns and triggers"
            ])
        
        if risk_level in ['low', 'medium']:
            return general_advice + specific_advice
        else:
            return ["Seek immediate medical care - do not attempt self-care"]
    
    def _generate_follow_up(self, risk_level: str, confidence: float) -> Dict:
        """Generate follow-up recommendations."""
        if risk_level == 'critical':
            return {
                'when': 'Immediate',
                'action': 'Emergency medical evaluation required',
                'monitoring': 'Continuous medical supervision'
            }
        elif risk_level == 'high':
            return {
                'when': 'Within 24 hours',
                'action': 'Medical evaluation required',
                'monitoring': 'Monitor symptoms closely, report any worsening'
            }
        elif risk_level == 'medium':
            return {
                'when': 'Within 2-3 days',
                'action': 'Schedule doctor appointment',
                'monitoring': 'Track symptoms daily, seek earlier care if worsening'
            }
        else:
            return {
                'when': 'If symptoms persist beyond 7 days',
                'action': 'Consult with healthcare provider',
                'monitoring': 'Monitor for any new or worsening symptoms'
            }
    
    def _get_urgency_level(self, risk_level: str) -> str:
        """Get urgency description."""
        urgency_map = {
            'critical': 'IMMEDIATE - Emergency',
            'high': 'URGENT - Same day',
            'medium': 'Moderate - Within 2-3 days',
            'low': 'Routine - Monitor and consult if needed'
        }
        return urgency_map.get(risk_level, 'Moderate')


class DepartmentMapper:
    """Map diseases to appropriate medical departments."""
    
    def __init__(self):
        self.departments = config.DEPARTMENTS
    
    def get_department(self, disease: str, symptoms: List[str] = None) -> str:
        """Get appropriate department for a disease."""
        engine = RecommendationEngine()
        return engine._get_department(disease)
    
    def get_all_departments(self) -> Dict[str, str]:
        """Get all available departments."""
        return self.departments
