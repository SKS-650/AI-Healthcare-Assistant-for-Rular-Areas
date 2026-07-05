"""Random Forest model for disease prediction."""

import numpy as np
import pandas as pd
from typing import List, Tuple, Dict, Optional
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score
import joblib

from ..config.config import config


class RandomForestSymptomChecker:
    """Random Forest classifier for disease prediction."""
    
    def __init__(
        self,
        n_estimators: int = None,
        max_depth: int = None,
        min_samples_split: int = None,
        min_samples_leaf: int = None,
        max_features: str = None,
        random_state: int = None,
        n_jobs: int = None
    ):
        """Initialize Random Forest model with configurable parameters."""
        self.n_estimators = n_estimators or config.N_ESTIMATORS
        self.max_depth = max_depth or config.MAX_DEPTH
        self.min_samples_split = min_samples_split or config.MIN_SAMPLES_SPLIT
        self.min_samples_leaf = min_samples_leaf or config.MIN_SAMPLES_LEAF
        self.max_features = max_features or config.MAX_FEATURES
        self.random_state = random_state or config.RANDOM_STATE
        self.n_jobs = n_jobs or config.N_JOBS
        
        self.model = RandomForestClassifier(
            n_estimators=self.n_estimators,
            max_depth=self.max_depth,
            min_samples_split=self.min_samples_split,
            min_samples_leaf=self.min_samples_leaf,
            max_features=self.max_features,
            random_state=self.random_state,
            n_jobs=self.n_jobs,
            class_weight='balanced',  # Handle class imbalance
            verbose=0
        )
        
        self.classes_ = None
        self.feature_importance_ = None
        self.n_features_ = None
    
    def fit(self, X: np.ndarray, y: np.ndarray) -> 'RandomForestSymptomChecker':
        """
        Train the model.
        
        Args:
            X: Feature matrix (n_samples, n_features)
            y: Target labels (n_samples,)
        
        Returns:
            Self for method chaining
        """
        print(f"Training Random Forest with {self.n_estimators} trees...")
        
        self.model.fit(X, y)
        self.classes_ = self.model.classes_
        self.feature_importance_ = self.model.feature_importances_
        self.n_features_ = X.shape[1]
        
        print(f"Training complete. Model trained on {X.shape[0]} samples.")
        
        return self
    
    def predict(self, X: np.ndarray) -> np.ndarray:
        """
        Predict disease for given symptoms.
        
        Args:
            X: Feature matrix
        
        Returns:
            Predicted disease labels
        """
        return self.model.predict(X)
    
    def predict_proba(self, X: np.ndarray) -> np.ndarray:
        """
        Predict probabilities for each disease.
        
        Args:
            X: Feature matrix
        
        Returns:
            Probability matrix (n_samples, n_classes)
        """
        return self.model.predict_proba(X)
    
    def predict_top_k(
        self,
        X: np.ndarray,
        k: int = 5
    ) -> List[List[Tuple[str, float]]]:
        """
        Predict top K diseases with confidence scores.
        
        Args:
            X: Feature matrix
            k: Number of top predictions to return
        
        Returns:
            List of [(disease, confidence)] for each sample
        """
        probabilities = self.predict_proba(X)
        predictions = []
        
        for probs in probabilities:
            # Get top k indices
            top_k_idx = np.argsort(probs)[-k:][::-1]
            top_k_diseases = [
                (self.classes_[idx], probs[idx])
                for idx in top_k_idx
                if probs[idx] > config.MIN_CONFIDENCE_THRESHOLD
            ]
            predictions.append(top_k_diseases)
        
        return predictions
    
    def evaluate(self, X: np.ndarray, y: np.ndarray) -> Dict[str, float]:
        """
        Evaluate model performance.
        
        Args:
            X: Feature matrix
            y: True labels
        
        Returns:
            Dictionary of evaluation metrics
        """
        from sklearn.metrics import (
            accuracy_score, precision_score, recall_score,
            f1_score, classification_report
        )
        
        y_pred = self.predict(X)
        
        metrics = {
            'accuracy': accuracy_score(y, y_pred),
            'precision': precision_score(y, y_pred, average='weighted', zero_division=0),
            'recall': recall_score(y, y_pred, average='weighted', zero_division=0),
            'f1_score': f1_score(y, y_pred, average='weighted', zero_division=0)
        }
        
        return metrics
    
    def cross_validate(
        self,
        X: np.ndarray,
        y: np.ndarray,
        cv: int = 5
    ) -> Dict[str, float]:
        """
        Perform cross-validation.
        
        Args:
            X: Feature matrix
            y: Target labels
            cv: Number of cross-validation folds
        
        Returns:
            Cross-validation scores
        """
        scores = cross_val_score(self.model, X, y, cv=cv, n_jobs=self.n_jobs)
        
        return {
            'mean_cv_score': scores.mean(),
            'std_cv_score': scores.std(),
            'cv_scores': scores.tolist()
        }
    
    def get_feature_importance(
        self,
        feature_names: Optional[List[str]] = None,
        top_n: int = 20
    ) -> pd.DataFrame:
        """
        Get feature importance rankings.
        
        Args:
            feature_names: Names of features
            top_n: Number of top features to return
        
        Returns:
            DataFrame with feature importance
        """
        if self.feature_importance_ is None:
            raise ValueError("Model must be trained first")
        
        if feature_names is None:
            feature_names = [f"feature_{i}" for i in range(self.n_features_)]
        
        importance_df = pd.DataFrame({
            'feature': feature_names,
            'importance': self.feature_importance_
        })
        
        importance_df = importance_df.sort_values('importance', ascending=False)
        
        return importance_df.head(top_n)
    
    def save(self, filepath: str):
        """Save model to file."""
        model_data = {
            'model': self.model,
            'classes': self.classes_,
            'feature_importance': self.feature_importance_,
            'n_features': self.n_features_,
            'hyperparameters': {
                'n_estimators': self.n_estimators,
                'max_depth': self.max_depth,
                'min_samples_split': self.min_samples_split,
                'min_samples_leaf': self.min_samples_leaf,
                'max_features': self.max_features
            }
        }
        joblib.dump(model_data, filepath)
        print(f"Model saved to {filepath}")
    
    @classmethod
    def load(cls, filepath: str) -> 'RandomForestSymptomChecker':
        """Load model from file."""
        model_data = joblib.load(filepath)
        
        instance = cls()
        instance.model = model_data['model']
        instance.classes_ = model_data['classes']
        instance.feature_importance_ = model_data['feature_importance']
        instance.n_features_ = model_data['n_features']
        
        # Restore hyperparameters
        if 'hyperparameters' in model_data:
            for key, value in model_data['hyperparameters'].items():
                setattr(instance, key, value)
        
        print(f"Model loaded from {filepath}")
        return instance
