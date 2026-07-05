"""Simple test of trained model."""

import sys
from pathlib import Path
import numpy as np

sys.path.append(str(Path(__file__).parent.parent))

from symptom_checker.models.random_forest import RandomForestSymptomChecker
from symptom_checker.config.paths import Paths

def main():
    print("="*60)
    print("SIMPLE MODEL TEST")
    print("="*60)
    
    # Load model
    model_path = Paths.get_model_path("random_forest_symptom_checker")
    if not model_path.exists():
        print(f"Model not found at {model_path}")
        return
    
    print(f"\nLoading model from {model_path}")
    model = RandomForestSymptomChecker.load(str(model_path))
    print("✓ Model loaded successfully")
    
    print(f"\nModel Info:")
    print(f"  Number of features: {model.n_features_}")
    print(f"  Number of classes: {len(model.classes_)}")
    print(f"  Sample classes: {list(model.classes_[:5])}")
    
    # Create test data with correct number of features
    print(f"\n Creating test input with {model.n_features_} features...")
    
    # Test case 1: All zeros (no symptoms)
    X_test1 = np.zeros((1, model.n_features_))
    X_test1[0, 5] = 35  # age
    X_test1[0, 6] = 0   # gender (male)
    
    print("\nTest Case 1: No symptoms, age 35, male")
    predictions = model.predict_top_k(X_test1, k=3)
    for i, (disease, conf) in enumerate(predictions[0], 1):
        print(f"  {i}. {disease}: {conf:.2%}")
    
    # Test case 2: With some symptoms
    X_test2 = np.zeros((1, model.n_features_))
    X_test2[0, 0] = 1   # fever
    X_test2[0, 1] = 1   # cough
    X_test2[0, 5] = 45  # age
    X_test2[0, 6] = 1   # gender (female)
    
    print("\nTest Case 2: Fever + Cough, age 45, female")
    predictions = model.predict_top_k(X_test2, k=3)
    for i, (disease, conf) in enumerate(predictions[0], 1):
        print(f"  {i}. {disease}: {conf:.2%}")
    
    print("\n" + "="*60)
    print("✅ Model is working!")
    print("="*60)
    print("\nNote: Low confidence is expected with limited training data")
    print("To improve accuracy:")
    print("1. Add more training samples")
    print("2. Add more symptom features")
    print("3. Balance the dataset")

if __name__ == "__main__":
    main()
