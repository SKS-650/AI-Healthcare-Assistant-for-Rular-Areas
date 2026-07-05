"""Symptom vectorization for machine learning."""

import numpy as np
import pandas as pd
from typing import List, Dict, Optional
from sklearn.feature_extraction.text import TfidfVectorizer
import joblib


class SymptomVectorizer:
    """Convert symptoms to numerical vectors."""
    
    def __init__(self, method: str = 'multi_hot'):
        """
        Initialize vectorizer.
        
        Args:
            method: 'multi_hot', 'tfidf', or 'weighted'
        """
        self.method = method
        self.symptom_to_idx: Dict[str, int] = {}
        self.idx_to_symptom: Dict[int, str] = {}
        self.symptom_weights: Dict[str, float] = {}
        self.tfidf_vectorizer: Optional[TfidfVectorizer] = None
        self.vocabulary_size = 0
    
    def fit(self, symptoms_list: List[List[str]]) -> 'SymptomVectorizer':
        """
        Fit vectorizer on symptom data.
        
        Args:
            symptoms_list: List of symptom lists for each patient
        """
        # Build vocabulary
        all_symptoms = set()
        for symptoms in symptoms_list:
            all_symptoms.update(symptoms)
        
        # Create symptom to index mapping
        for idx, symptom in enumerate(sorted(all_symptoms)):
            self.symptom_to_idx[symptom] = idx
            self.idx_to_symptom[idx] = symptom
        
        self.vocabulary_size = len(all_symptoms)
        
        # Calculate symptom weights (inverse frequency)
        symptom_freq = {}
        total_records = len(symptoms_list)
        
        for symptoms in symptoms_list:
            for symptom in set(symptoms):
                symptom_freq[symptom] = symptom_freq.get(symptom, 0) + 1
        
        for symptom, freq in symptom_freq.items():
            self.symptom_weights[symptom] = np.log(total_records / freq)
        
        # Fit TF-IDF if needed
        if self.method == 'tfidf':
            # Convert to text format for TF-IDF
            symptom_texts = [' '.join(symptoms) for symptoms in symptoms_list]
            self.tfidf_vectorizer = TfidfVectorizer()
            self.tfidf_vectorizer.fit(symptom_texts)
        
        return self
    
    def transform(self, symptoms_list: List[List[str]]) -> np.ndarray:
        """
        Transform symptoms to vectors.
        
        Args:
            symptoms_list: List of symptom lists
        
        Returns:
            2D array of symptom vectors
        """
        if self.method == 'multi_hot':
            return self._multi_hot_transform(symptoms_list)
        elif self.method == 'weighted':
            return self._weighted_transform(symptoms_list)
        elif self.method == 'tfidf':
            return self._tfidf_transform(symptoms_list)
        else:
            raise ValueError(f"Unknown method: {self.method}")
    
    def _multi_hot_transform(self, symptoms_list: List[List[str]]) -> np.ndarray:
        """Multi-hot encoding: 1 if symptom present, 0 otherwise."""
        vectors = np.zeros((len(symptoms_list), self.vocabulary_size), dtype=int)
        
        for i, symptoms in enumerate(symptoms_list):
            for symptom in symptoms:
                if symptom in self.symptom_to_idx:
                    idx = self.symptom_to_idx[symptom]
                    vectors[i, idx] = 1
        
        return vectors
    
    def _weighted_transform(self, symptoms_list: List[List[str]]) -> np.ndarray:
        """Weighted encoding: weight by inverse frequency."""
        vectors = np.zeros((len(symptoms_list), self.vocabulary_size), dtype=float)
        
        for i, symptoms in enumerate(symptoms_list):
            for symptom in symptoms:
                if symptom in self.symptom_to_idx:
                    idx = self.symptom_to_idx[symptom]
                    weight = self.symptom_weights.get(symptom, 1.0)
                    vectors[i, idx] = weight
        
        return vectors
    
    def _tfidf_transform(self, symptoms_list: List[List[str]]) -> np.ndarray:
        """TF-IDF encoding."""
        symptom_texts = [' '.join(symptoms) for symptoms in symptoms_list]
        return self.tfidf_vectorizer.transform(symptom_texts).toarray()
    
    def fit_transform(self, symptoms_list: List[List[str]]) -> np.ndarray:
        """Fit and transform in one step."""
        self.fit(symptoms_list)
        return self.transform(symptoms_list)
    
    def get_feature_names(self) -> List[str]:
        """Get feature names (symptom names)."""
        return [self.idx_to_symptom[i] for i in range(self.vocabulary_size)]
    
    def inverse_transform(self, vectors: np.ndarray, threshold: float = 0.5) -> List[List[str]]:
        """
        Convert vectors back to symptom lists.
        
        Args:
            vectors: 2D array of symptom vectors
            threshold: Threshold for considering symptom present
        
        Returns:
            List of symptom lists
        """
        symptoms_list = []
        
        for vector in vectors:
            symptoms = []
            for idx, value in enumerate(vector):
                if value >= threshold and idx in self.idx_to_symptom:
                    symptoms.append(self.idx_to_symptom[idx])
            symptoms_list.append(symptoms)
        
        return symptoms_list
    
    def save(self, filepath: str):
        """Save vectorizer to file."""
        joblib.dump({
            'method': self.method,
            'symptom_to_idx': self.symptom_to_idx,
            'idx_to_symptom': self.idx_to_symptom,
            'symptom_weights': self.symptom_weights,
            'tfidf_vectorizer': self.tfidf_vectorizer,
            'vocabulary_size': self.vocabulary_size
        }, filepath)
    
    @classmethod
    def load(cls, filepath: str) -> 'SymptomVectorizer':
        """Load vectorizer from file."""
        data = joblib.load(filepath)
        vectorizer = cls(method=data['method'])
        vectorizer.symptom_to_idx = data['symptom_to_idx']
        vectorizer.idx_to_symptom = data['idx_to_symptom']
        vectorizer.symptom_weights = data['symptom_weights']
        vectorizer.tfidf_vectorizer = data['tfidf_vectorizer']
        vectorizer.vocabulary_size = data['vocabulary_size']
        return vectorizer


def create_symptom_matrix(
    df: pd.DataFrame,
    symptom_columns: List[str]
) -> np.ndarray:
    """Create symptom matrix from dataframe columns."""
    return df[symptom_columns].values
