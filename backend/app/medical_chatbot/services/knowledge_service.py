"""
Knowledge Service - Loads and searches medical datasets
"""
from typing import Optional, Dict, Any, List
import pandas as pd
from pathlib import Path
import re

from ..utils.logger import logger
from ..utils.exceptions import ChatbotException


class KnowledgeService:
    """Service for loading and searching medical knowledge base"""
    
    def __init__(self, dataset_path: Optional[str] = None):
        """
        Initialize knowledge service
        
        Args:
            dataset_path: Path to chatbot datasets (default: auto-detect)
        """
        if dataset_path:
            self.dataset_path = Path(dataset_path)
        else:
            # Auto-detect dataset path
            self.dataset_path = self._find_dataset_path()
        
        # Dataset storage
        self.disease_symptoms_df: Optional[pd.DataFrame] = None
        self.symptom_description_df: Optional[pd.DataFrame] = None
        self.symptom_precaution_df: Optional[pd.DataFrame] = None
        self.symptom_severity_df: Optional[pd.DataFrame] = None
        self.medquad_df: Optional[pd.DataFrame] = None
        
        # Load datasets
        self._load_datasets()
        
        logger.info(f"Knowledge Service initialized with {self.get_stats()}")
    
    def _find_dataset_path(self) -> Path:
        """Auto-detect dataset path"""
        # Try different possible locations
        possible_paths = [
            Path("datasets/chatbot_dataset"),
            Path("../datasets/chatbot_dataset"),
            Path("../../datasets/chatbot_dataset"),
            Path(__file__).parent.parent.parent.parent.parent / "datasets" / "chatbot_dataset"
        ]
        
        for path in possible_paths:
            if path.exists():
                logger.info(f"Found dataset path: {path.absolute()}")
                return path.absolute()
        
        # Default fallback
        default_path = Path("datasets/chatbot_dataset")
        logger.warning(f"Dataset path not found, using default: {default_path}")
        return default_path
    
    def _load_datasets(self):
        """Load all CSV datasets"""
        try:
            disease_path = self.dataset_path / "DiseaseSymptomPredictionDataset"
            medquad_path = self.dataset_path / "MedQuAD_Dataset"
            
            # Load disease-symptom dataset
            if (disease_path / "dataset.csv").exists():
                self.disease_symptoms_df = pd.read_csv(disease_path / "dataset.csv")
                logger.info(f"Loaded disease symptoms: {len(self.disease_symptoms_df)} records")
            
            # Load symptom descriptions
            if (disease_path / "symptom_Description.csv").exists():
                self.symptom_description_df = pd.read_csv(disease_path / "symptom_Description.csv")
                logger.info(f"Loaded symptom descriptions: {len(self.symptom_description_df)} records")
            
            # Load symptom precautions
            if (disease_path / "symptom_precaution.csv").exists():
                self.symptom_precaution_df = pd.read_csv(disease_path / "symptom_precaution.csv")
                logger.info(f"Loaded symptom precautions: {len(self.symptom_precaution_df)} records")
            
            # Load symptom severity
            if (disease_path / "Symptom-severity.csv").exists():
                self.symptom_severity_df = pd.read_csv(disease_path / "Symptom-severity.csv")
                logger.info(f"Loaded symptom severity: {len(self.symptom_severity_df)} records")
            
            # Load MedQuAD dataset
            if (medquad_path / "medquad.csv").exists():
                self.medquad_df = pd.read_csv(medquad_path / "medquad.csv")
                logger.info(f"Loaded MedQuAD: {len(self.medquad_df)} records")
            
        except Exception as e:
            logger.error(f"Error loading datasets: {str(e)}", exc_info=True)
            # Don't fail completely, just log the error
    
    def search_disease(self, disease_name: str) -> Optional[Dict[str, Any]]:
        """
        Search for disease information
        
        Args:
            disease_name: Name of the disease
            
        Returns:
            Dict with disease information or None
        """
        if self.disease_symptoms_df is None:
            return None
        
        try:
            # Normalize disease name
            disease_name = disease_name.strip().lower()
            
            # Search in disease column (case-insensitive)
            mask = self.disease_symptoms_df['Disease'].str.lower().str.contains(disease_name, na=False)
            matches = self.disease_symptoms_df[mask]
            
            if matches.empty:
                return None
            
            # Get first match
            disease_row = matches.iloc[0]
            disease_exact_name = disease_row['Disease']
            
            # Get symptoms (non-null columns starting with 'Symptom')
            symptom_cols = [col for col in disease_row.index if col.startswith('Symptom')]
            symptoms = [disease_row[col] for col in symptom_cols if pd.notna(disease_row[col])]
            
            # Get description
            description = self.get_symptom_description(disease_exact_name)
            
            # Get precautions
            precautions = self.get_precautions(disease_exact_name)
            
            return {
                "name": disease_exact_name,
                "symptoms": symptoms,
                "description": description,
                "precautions": precautions
            }
            
        except Exception as e:
            logger.error(f"Error searching disease: {str(e)}")
            return None
    
    def get_symptom_description(self, disease_name: str) -> Optional[str]:
        """Get disease/symptom description"""
        if self.symptom_description_df is None:
            return None
        
        try:
            mask = self.symptom_description_df['Disease'].str.lower() == disease_name.lower()
            matches = self.symptom_description_df[mask]
            
            if matches.empty:
                return None
            
            return matches.iloc[0]['Description']
            
        except Exception as e:
            logger.error(f"Error getting description: {str(e)}")
            return None
    
    def get_precautions(self, disease_name: str) -> List[str]:
        """Get precautions for a disease"""
        if self.symptom_precaution_df is None:
            return []
        
        try:
            mask = self.symptom_precaution_df['Disease'].str.lower() == disease_name.lower()
            matches = self.symptom_precaution_df[mask]
            
            if matches.empty:
                return []
            
            precaution_row = matches.iloc[0]
            
            # Get precautions (columns Precaution_1 to Precaution_4)
            precautions = []
            for i in range(1, 5):
                col = f'Precaution_{i}'
                if col in precaution_row.index and pd.notna(precaution_row[col]):
                    precautions.append(precaution_row[col])
            
            return precautions
            
        except Exception as e:
            logger.error(f"Error getting precautions: {str(e)}")
            return []
    
    def search_symptoms(self, symptom_query: str) -> List[str]:
        """
        Search for related symptoms
        
        Args:
            symptom_query: Symptom search term
            
        Returns:
            List of matching symptom names
        """
        if self.disease_symptoms_df is None:
            return []
        
        try:
            symptom_query = symptom_query.lower()
            
            # Get all symptom columns
            symptom_cols = [col for col in self.disease_symptoms_df.columns if col.startswith('Symptom')]
            
            # Find matching symptoms
            matching_symptoms = set()
            
            for col in symptom_cols:
                symptoms = self.disease_symptoms_df[col].dropna().unique()
                for symptom in symptoms:
                    if symptom_query in str(symptom).lower():
                        matching_symptoms.add(symptom)
            
            return sorted(list(matching_symptoms))[:10]  # Limit to 10 results
            
        except Exception as e:
            logger.error(f"Error searching symptoms: {str(e)}")
            return []
    
    def search_medquad(self, query: str, limit: int = 3) -> List[Dict[str, str]]:
        """
        Search MedQuAD medical Q&A dataset
        
        Args:
            query: Search query
            limit: Maximum number of results
            
        Returns:
            List of relevant Q&A pairs
        """
        if self.medquad_df is None:
            return []
        
        try:
            query = query.lower()
            
            # Search in question and answer columns
            if 'question' in self.medquad_df.columns and 'answer' in self.medquad_df.columns:
                mask = (
                    self.medquad_df['question'].str.lower().str.contains(query, na=False) |
                    self.medquad_df['answer'].str.lower().str.contains(query, na=False)
                )
                
                matches = self.medquad_df[mask].head(limit)
                
                results = []
                for _, row in matches.iterrows():
                    results.append({
                        "question": row['question'],
                        "answer": row['answer']
                    })
                
                return results
            
            return []
            
        except Exception as e:
            logger.error(f"Error searching MedQuAD: {str(e)}")
            return []
    
    def get_relevant_knowledge(self, user_message: str) -> Dict[str, Any]:
        """
        Get relevant knowledge for user message
        
        Args:
            user_message: User's question
            
        Returns:
            Dict with relevant knowledge
        """
        knowledge = {
            "disease_info": None,
            "symptom_info": None,
            "medquad_info": None,
            "general_info": None
        }
        
        try:
            # Extract potential disease names (simple keyword matching)
            common_diseases = [
                "diabetes", "hypertension", "fever", "cold", "cough", "asthma",
                "malaria", "dengue", "typhoid", "tuberculosis", "pneumonia",
                "covid", "headache", "migraine", "arthritis", "allergy"
            ]
            
            user_message_lower = user_message.lower()
            
            # Search for disease info
            for disease in common_diseases:
                if disease in user_message_lower:
                    disease_info = self.search_disease(disease)
                    if disease_info:
                        knowledge["disease_info"] = disease_info
                        break
            
            # Search for symptoms
            symptoms = self.search_symptoms(user_message)
            if symptoms:
                knowledge["symptom_info"] = symptoms
            
            # Search MedQuAD for relevant Q&A
            medquad_results = self.search_medquad(user_message, limit=2)
            if medquad_results:
                knowledge["medquad_info"] = medquad_results
                # Format as general info
                general_parts = []
                for qa in medquad_results:
                    general_parts.append(f"Q: {qa['question']}\nA: {qa['answer'][:200]}...")
                knowledge["general_info"] = "\n\n".join(general_parts)
            
        except Exception as e:
            logger.error(f"Error getting relevant knowledge: {str(e)}")
        
        return knowledge
    
    def get_stats(self) -> Dict[str, int]:
        """Get dataset statistics"""
        stats = {
            "diseases": len(self.disease_symptoms_df) if self.disease_symptoms_df is not None else 0,
            "descriptions": len(self.symptom_description_df) if self.symptom_description_df is not None else 0,
            "precautions": len(self.symptom_precaution_df) if self.symptom_precaution_df is not None else 0,
            "medquad_entries": len(self.medquad_df) if self.medquad_df is not None else 0
        }
        return stats
    
    def is_loaded(self) -> bool:
        """Check if datasets are loaded"""
        return any([
            self.disease_symptoms_df is not None,
            self.symptom_description_df is not None,
            self.medquad_df is not None
        ])


# Singleton instance
_knowledge_service_instance: Optional[KnowledgeService] = None


def get_knowledge_service() -> KnowledgeService:
    """Get or create knowledge service instance"""
    global _knowledge_service_instance
    
    if _knowledge_service_instance is None:
        _knowledge_service_instance = KnowledgeService()
    
    return _knowledge_service_instance


# Example usage:
# knowledge = get_knowledge_service()
# disease_info = knowledge.search_disease("diabetes")
# symptoms = knowledge.search_symptoms("fever")
# relevant = knowledge.get_relevant_knowledge("What are symptoms of diabetes?")
