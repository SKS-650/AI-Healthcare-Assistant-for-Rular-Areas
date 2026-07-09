"""
Tests for Knowledge Service
"""
import pytest
import pandas as pd
from unittest.mock import Mock, patch

from ..services.knowledge_service import KnowledgeService


class TestKnowledgeService:
    """Test cases for Knowledge Service"""
    
    @pytest.fixture
    def mock_dataframes(self):
        """Create mock dataframes"""
        disease_df = pd.DataFrame({
            'Disease': ['Diabetes', 'Hypertension'],
            'Symptom_1': ['Increased thirst', 'Headache'],
            'Symptom_2': ['Frequent urination', 'Dizziness'],
            'Symptom_3': ['Fatigue', 'Blurred vision']
        })
        
        description_df = pd.DataFrame({
            'Disease': ['Diabetes', 'Hypertension'],
            'Description': [
                'A condition where blood sugar levels are too high',
                'High blood pressure condition'
            ]
        })
        
        precaution_df = pd.DataFrame({
            'Disease': ['Diabetes', 'Hypertension'],
            'Precaution_1': ['Regular exercise', 'Reduce salt intake'],
            'Precaution_2': ['Healthy diet', 'Regular monitoring'],
            'Precaution_3': ['Regular checkups', 'Avoid stress'],
            'Precaution_4': ['Monitor blood sugar', 'Maintain healthy weight']
        })
        
        medquad_df = pd.DataFrame({
            'question': ['What is diabetes?', 'What causes high blood pressure?'],
            'answer': [
                'Diabetes is a disease where blood sugar is too high',
                'High blood pressure is caused by various factors'
            ]
        })
        
        return {
            'disease_symptoms': disease_df,
            'descriptions': description_df,
            'precautions': precaution_df,
            'medquad': medquad_df
        }
    
    @pytest.fixture
    def knowledge_service(self, mock_dataframes, tmp_path):
        """Create knowledge service with mock data"""
        service = KnowledgeService(dataset_path=str(tmp_path))
        
        # Inject mock dataframes
        service.disease_symptoms_df = mock_dataframes['disease_symptoms']
        service.symptom_description_df = mock_dataframes['descriptions']
        service.symptom_precaution_df = mock_dataframes['precautions']
        service.medquad_df = mock_dataframes['medquad']
        
        return service
    
    def test_search_disease_found(self, knowledge_service):
        """Test searching for existing disease"""
        result = knowledge_service.search_disease("diabetes")
        
        assert result is not None
        assert result["name"] == "Diabetes"
        assert len(result["symptoms"]) > 0
        assert "Increased thirst" in result["symptoms"]
        assert result["description"] is not None
    
    def test_search_disease_not_found(self, knowledge_service):
        """Test searching for non-existent disease"""
        result = knowledge_service.search_disease("nonexistent")
        
        assert result is None
    
    def test_get_symptom_description(self, knowledge_service):
        """Test getting disease description"""
        description = knowledge_service.get_symptom_description("Diabetes")
        
        assert description is not None
        assert "blood sugar" in description.lower()
    
    def test_get_precautions(self, knowledge_service):
        """Test getting disease precautions"""
        precautions = knowledge_service.get_precautions("Diabetes")
        
        assert len(precautions) > 0
        assert "Regular exercise" in precautions
    
    def test_search_symptoms(self, knowledge_service):
        """Test symptom search"""
        symptoms = knowledge_service.search_symptoms("thirst")
        
        assert len(symptoms) > 0
        assert any("thirst" in s.lower() for s in symptoms)
    
    def test_search_medquad(self, knowledge_service):
        """Test MedQuAD search"""
        results = knowledge_service.search_medquad("diabetes")
        
        assert len(results) > 0
        assert "question" in results[0]
        assert "answer" in results[0]
    
    def test_get_relevant_knowledge(self, knowledge_service):
        """Test getting relevant knowledge for user message"""
        knowledge = knowledge_service.get_relevant_knowledge(
            "What are symptoms of diabetes?"
        )
        
        assert "disease_info" in knowledge
        assert "symptom_info" in knowledge
        assert knowledge["disease_info"] is not None
    
    def test_get_stats(self, knowledge_service):
        """Test getting dataset statistics"""
        stats = knowledge_service.get_stats()
        
        assert "diseases" in stats
        assert "descriptions" in stats
        assert stats["diseases"] > 0
    
    def test_is_loaded(self, knowledge_service):
        """Test checking if datasets are loaded"""
        assert knowledge_service.is_loaded() is True
