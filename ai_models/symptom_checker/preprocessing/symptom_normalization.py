"""Symptom normalization and standardization."""

import re
from typing import Dict, List, Set
from ..config.constants import SYMPTOM_SYNONYMS


class SymptomNormalizer:
    """Normalize and standardize symptom names."""
    
    def __init__(self):
        self.synonym_map = self._build_synonym_map()
        self.standardized_symptoms: Set[str] = set()
    
    def _build_synonym_map(self) -> Dict[str, str]:
        """Build mapping from synonyms to standard terms."""
        synonym_map = {}
        
        for standard_term, synonyms in SYMPTOM_SYNONYMS.items():
            # Map standard term to itself
            synonym_map[standard_term] = standard_term
            
            # Map all synonyms to standard term
            for synonym in synonyms:
                synonym_map[synonym.lower()] = standard_term
        
        return synonym_map
    
    def normalize(self, symptom: str) -> str:
        """Normalize a single symptom."""
        # Convert to lowercase and strip
        symptom = symptom.lower().strip()
        
        # Remove special characters except spaces and hyphens
        symptom = re.sub(r'[^a-z0-9\s\-]', '', symptom)
        
        # Replace multiple spaces with single space
        symptom = ' '.join(symptom.split())
        
        # Replace hyphens with spaces
        symptom = symptom.replace('-', ' ')
        
        # Check if symptom has a standard equivalent
        if symptom in self.synonym_map:
            symptom = self.synonym_map[symptom]
        
        return symptom
    
    def normalize_list(self, symptoms: List[str]) -> List[str]:
        """Normalize a list of symptoms."""
        normalized = []
        
        for symptom in symptoms:
            norm_symptom = self.normalize(symptom)
            if norm_symptom and norm_symptom not in normalized:
                normalized.append(norm_symptom)
        
        return normalized
    
    def add_synonym(self, synonym: str, standard_term: str):
        """Add a new synonym mapping."""
        self.synonym_map[synonym.lower()] = standard_term
    
    def get_standard_term(self, symptom: str) -> str:
        """Get the standard term for a symptom."""
        normalized = self.normalize(symptom)
        return self.synonym_map.get(normalized, normalized)
    
    def build_vocabulary(self, symptoms_list: List[str]) -> List[str]:
        """Build standardized symptom vocabulary."""
        vocabulary = set()
        
        for symptom in symptoms_list:
            normalized = self.normalize(symptom)
            if normalized:
                vocabulary.add(normalized)
        
        return sorted(list(vocabulary))


def standardize_symptoms_in_dataset(
    symptoms: List[str],
    normalizer: SymptomNormalizer = None
) -> List[str]:
    """Standardize symptoms in a dataset."""
    if normalizer is None:
        normalizer = SymptomNormalizer()
    
    return normalizer.normalize_list(symptoms)
