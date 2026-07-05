# Symptom Checker AI Module

## Overview
A comprehensive AI-powered symptom checker that predicts potential diseases based on patient symptoms and provides risk assessment and recommendations.

## Features
- Multi-symptom disease prediction
- Confidence scoring
- Risk level assessment (Low, Medium, High, Critical)
- Medical department recommendations
- Emergency detection
- Prediction history tracking

## Architecture

### Input Features
- Symptoms (multi-select)
- Age
- Gender
- Weight & Height (BMI calculation)
- Duration of symptoms
- Symptom severity
- Existing diseases
- Allergies
- Current medications
- Pregnancy status (if applicable)

### Output
- Top 5 possible diseases with confidence scores
- Risk level
- Recommended medical department
- Suggested next action
- Emergency alert (if needed)

## Model Architecture
- **Algorithm**: Random Forest Classifier
- **Features**: 500+ symptoms encoded using multi-hot encoding
- **Disease Categories**: 200+ diseases across 10 medical domains

## Directory Structure
```
symptom_checker/
├── config/              # Configuration files
├── datasets/            # Training and validation data
├── preprocessing/       # Data cleaning and preprocessing
├── feature_engineering/ # Feature creation and selection
├── models/             # ML model implementations
├── training/           # Training scripts
├── evaluation/         # Model evaluation
├── inference/          # Prediction pipeline
├── risk_assessment/    # Risk scoring engine
├── recommendation/     # Recommendation system
├── api/                # FastAPI integration
├── artifacts/          # Saved models and encoders
└── tests/              # Unit tests
```

## Quick Start

### Training
```bash
python symptom_checker/training/train.py
```

### Inference
```bash
python symptom_checker/inference/predictor.py
```

### API
```bash
# Integrated with main backend API
POST /api/v1/symptom-checker/predict
```

## Performance Metrics
- Accuracy: Target > 85%
- Top-3 Accuracy: Target > 95%
- Precision: Target > 80%
- Recall: Target > 80%
- F1 Score: Target > 80%
