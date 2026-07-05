"""Main entry point for symptom checker module."""

import sys
from pathlib import Path

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

from symptom_checker.inference.predictor import SymptomCheckerPredictor
from symptom_checker.config.paths import Paths


def main():
    """Demo of symptom checker functionality."""
    print("="*70)
    print("SYMPTOM CHECKER - DEMO")
    print("="*70)
    
    # Check if model exists
    model_path = Paths.get_model_path("random_forest_symptom_checker")
    if not model_path.exists():
        print("\n⚠️  Model not found!")
        print(f"Expected location: {model_path}")
        print("\nPlease train the model first:")
        print("  python ai_models/symptom_checker/training/train.py")
        return
    
    # Load predictor
    print("\nLoading model...")
    predictor = SymptomCheckerPredictor(str(model_path))
    
    # Example prediction
    print("\n" + "="*70)
    print("Example Prediction")
    print("="*70)
    
    patient_data = {
        'symptoms': ['fever', 'cough', 'fatigue', 'headache'],
        'age': 35,
        'gender': 'male',
        'weight': 75,
        'height': 175,
        'duration': 3,
        'severity': 2,
        'existing_diseases': [],
        'medications': [],
        'allergies': []
    }
    
    print("\nPatient Information:")
    print(f"  Symptoms: {', '.join(patient_data['symptoms'])}")
    print(f"  Age: {patient_data['age']}")
    print(f"  Gender: {patient_data['gender']}")
    print(f"  Duration: {patient_data['duration']} days")
    print(f"  Severity: {patient_data['severity']}/4")
    
    # Make prediction
    print("\nMaking prediction...")
    result = predictor.predict(**patient_data)
    
    # Display results
    print("\n" + "="*70)
    print("PREDICTION RESULTS")
    print("="*70)
    
    # Primary prediction
    prediction = result['prediction']
    print(f"\n🏥 Primary Diagnosis: {prediction['primary_disease']}")
    print(f"   Confidence: {prediction['confidence']:.2%}")
    
    # Top diseases
    print("\n📊 Top 5 Possible Diseases:")
    for i, disease_info in enumerate(prediction['top_diseases'], 1):
        print(f"   {i}. {disease_info['disease']}: {disease_info['confidence']:.2%}")
    
    # Risk assessment
    risk = result['risk_assessment']
    print(f"\n⚠️  Risk Level: {risk['risk_level'].upper()}")
    print(f"   Risk Score: {risk['risk_score']:.2%}")
    print(f"   Emergency: {'YES ⚠️⚠️⚠️' if risk['is_emergency'] else 'No'}")
    
    if risk['risk_factors']:
        print("\n   Risk Factors:")
        for factor in risk['risk_factors']:
            print(f"     • {factor}")
    
    # Recommendations
    recommendations = result['recommendations']
    print(f"\n💡 Recommendations:")
    print(f"   Department: {recommendations['department']}")
    print(f"   Urgency: {recommendations['urgency']}")
    print(f"\n   Primary Action:")
    print(f"     {recommendations['primary_action']}")
    
    print(f"\n   Suggested Actions:")
    for action in recommendations['actions'][:3]:
        print(f"     • {action}")
    
    print(f"\n   Care Advice:")
    for advice in recommendations['care_advice'][:3]:
        print(f"     • {advice}")
    
    # Emergency alert
    if 'emergency_alert' in result:
        print(f"\n🚨 {result['emergency_alert']}")
    
    print("\n" + "="*70)
    print("Demo complete!")
    print("="*70)


if __name__ == "__main__":
    main()
