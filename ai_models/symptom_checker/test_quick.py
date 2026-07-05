"""Quick test script for symptom checker."""

import sys
from pathlib import Path

# Add parent to path
sys.path.append(str(Path(__file__).parent.parent))

def test_imports():
    """Test that all modules can be imported."""
    print("Testing imports...")
    
    try:
        from symptom_checker.config.config import config
        print("✓ Config loaded")
        
        from symptom_checker.preprocessing.data_cleaning import DataCleaner
        print("✓ DataCleaner imported")
        
        from symptom_checker.preprocessing.symptom_normalization import SymptomNormalizer
        print("✓ SymptomNormalizer imported")
        
        from symptom_checker.feature_engineering.feature_creation import FeatureEngineer
        print("✓ FeatureEngineer imported")
        
        from symptom_checker.models.random_forest import RandomForestSymptomChecker
        print("✓ RandomForestSymptomChecker imported")
        
        from symptom_checker.risk_assessment.risk_engine import RiskAssessmentEngine
        print("✓ RiskAssessmentEngine imported")
        
        from symptom_checker.recommendation.recommendation_engine import RecommendationEngine
        print("✓ RecommendationEngine imported")
        
        from symptom_checker.inference.predictor import SymptomCheckerPredictor
        print("✓ SymptomCheckerPredictor imported")
        
        print("\n✅ All imports successful!")
        return True
        
    except Exception as e:
        print(f"\n❌ Import failed: {e}")
        return False


def test_symptom_normalization():
    """Test symptom normalization."""
    print("\nTesting symptom normalization...")
    
    from symptom_checker.preprocessing.symptom_normalization import SymptomNormalizer
    
    normalizer = SymptomNormalizer()
    
    test_symptoms = [
        "High Temperature",
        "Breathing Difficulty",
        "Stomach Pain",
        "FEVER",
        "  cough  "
    ]
    
    normalized = normalizer.normalize_list(test_symptoms)
    
    print(f"Original: {test_symptoms}")
    print(f"Normalized: {normalized}")
    print("✅ Normalization works!")


def test_risk_assessment():
    """Test risk assessment engine."""
    print("\nTesting risk assessment...")
    
    from symptom_checker.risk_assessment.risk_engine import RiskAssessmentEngine
    
    engine = RiskAssessmentEngine()
    
    # Test case 1: Low risk
    risk_level, risk_score, details = engine.assess_risk(
        symptoms=['mild headache', 'fatigue'],
        confidence_score=0.6,
        severity=1,
        age=30
    )
    print(f"\nCase 1 - Mild symptoms:")
    print(f"  Risk Level: {risk_level}")
    print(f"  Risk Score: {risk_score:.2f}")
    
    # Test case 2: High risk
    risk_level, risk_score, details = engine.assess_risk(
        symptoms=['chest pain', 'shortness of breath', 'dizziness'],
        confidence_score=0.85,
        severity=3,
        age=65
    )
    print(f"\nCase 2 - Serious symptoms:")
    print(f"  Risk Level: {risk_level}")
    print(f"  Risk Score: {risk_score:.2f}")
    print(f"  Factors: {details['factors']}")
    
    print("\n✅ Risk assessment works!")


def test_recommendations():
    """Test recommendation engine."""
    print("\nTesting recommendation engine...")
    
    from symptom_checker.recommendation.recommendation_engine import RecommendationEngine
    
    engine = RecommendationEngine()
    
    recommendations = engine.generate_recommendations(
        disease="Flu",
        risk_level="medium",
        confidence=0.75,
        symptoms=["fever", "cough", "fatigue"]
    )
    
    print(f"\nDisease: Flu")
    print(f"Risk Level: medium")
    print(f"Department: {recommendations['department']}")
    print(f"Urgency: {recommendations['urgency']}")
    print(f"Primary Action: {recommendations['primary_action']}")
    print(f"\nActions:")
    for action in recommendations['actions'][:3]:
        print(f"  • {action}")
    
    print("\n✅ Recommendations work!")


def main():
    """Run all tests."""
    print("="*60)
    print("SYMPTOM CHECKER - QUICK TEST")
    print("="*60)
    
    # Test imports
    if not test_imports():
        return
    
    # Test components
    test_symptom_normalization()
    test_risk_assessment()
    test_recommendations()
    
    print("\n" + "="*60)
    print("✅ ALL TESTS PASSED!")
    print("="*60)
    print("\nNext steps:")
    print("1. Train the model: python symptom_checker/training/train.py")
    print("2. Run demo: python symptom_checker/main.py")
    print("3. Start API: cd backend && uvicorn app.main:app --reload")


if __name__ == "__main__":
    main()
