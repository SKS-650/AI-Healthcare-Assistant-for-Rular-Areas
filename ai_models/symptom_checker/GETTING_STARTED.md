# Symptom Checker - Getting Started Guide

## Overview

The Symptom Checker is an AI-powered disease prediction system that analyzes patient symptoms and provides:
- Top 5 disease predictions with confidence scores
- Risk assessment (Low, Medium, High, Critical)
- Medical department recommendations
- Emergency detection and alerts
- Personalized care recommendations

## Quick Start

### 1. Installation

```bash
# Navigate to symptom checker directory
cd ai_models/symptom_checker

# Install dependencies
pip install -r requirements.txt
```

### 2. Prepare Dataset

Place your training data in one of these locations:
- `ai_models/symptom_checker/datasets/raw/`
- `D:/MinorProject/datasets/all_in_one/`

Expected format:
- CSV file with columns: `disease`, `symptoms`, `age`, `gender`, etc.
- Or the system will generate synthetic data for demo purposes

### 3. Train the Model

```bash
# From ai_models directory
python symptom_checker/training/train.py
```

This will:
- Load and clean the dataset
- Engineer features
- Train a Random Forest model
- Evaluate performance
- Save the trained model to `artifacts/trained_models/`

Expected output:
```
Training Random Forest with 200 trees...
Training complete. Model trained on 700 samples.

Training Metrics:
  accuracy: 0.9857
  precision: 0.9862
  recall: 0.9857
  f1_score: 0.9859

Validation Metrics:
  accuracy: 0.9200
  precision: 0.9185
  recall: 0.9200
  f1_score: 0.9187
```

### 4. Test the Model

```bash
# Run demo
python symptom_checker/main.py
```

This will show an example prediction with:
- Patient symptoms
- Disease predictions
- Risk assessment
- Recommendations

### 5. Use via API

#### Start the backend server:

```bash
# From backend directory
cd ../../backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Make API requests:

```bash
# Check service health
curl http://localhost:8000/api/v1/symptom-checker/health

# Get available symptoms
curl http://localhost:8000/api/v1/symptom-checker/symptoms

# Make a prediction (requires authentication)
curl -X POST http://localhost:8000/api/v1/symptom-checker/predict \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "symptoms": ["fever", "cough", "headache", "fatigue"],
    "age": 35,
    "gender": "male",
    "weight": 75,
    "height": 175,
    "duration": 3,
    "severity": 2
  }'
```

## Architecture

### Input Processing Pipeline

```
User Input
    ↓
Symptom Normalization (standardize symptom names)
    ↓
Feature Engineering (BMI, age groups, symptom counts)
    ↓
Symptom Vectorization (multi-hot encoding)
    ↓
Feature Matrix (symptoms + patient features)
```

### Prediction Pipeline

```
Feature Matrix
    ↓
Random Forest Model
    ↓
Top K Disease Predictions
    ↓
Risk Assessment Engine
    ↓
Emergency Detection
    ↓
Recommendation Engine
    ↓
Final Result (predictions + recommendations)
```

## Key Components

### 1. Preprocessing
- **Data Cleaning**: Remove duplicates, handle missing values
- **Symptom Normalization**: Standardize symptom terminology
- **Categorical Encoding**: Encode gender, severity levels

### 2. Feature Engineering
- **BMI Calculation**: weight / (height^2)
- **Age Groups**: Infant, child, teen, adult, senior
- **Symptom Counts**: Total symptom count
- **Severity Score**: symptom_count × severity_level
- **Risk Indicators**: High-risk age, existing diseases

### 3. Model
- **Algorithm**: Random Forest Classifier
- **Parameters**:
  - n_estimators: 200
  - max_depth: 30
  - class_weight: balanced (handles class imbalance)
- **Features**: 500+ symptom features + patient demographics

### 4. Risk Assessment
Factors considered:
- Prediction confidence score
- Emergency symptoms (chest pain, difficulty breathing, etc.)
- High-risk symptom combinations
- Severity level (1-4)
- Age-based risk (very young or elderly)
- Existing medical conditions

Risk Levels:
- **Low** (0-0.3): Home care, monitor symptoms
- **Medium** (0.3-0.6): Visit clinic within 2-3 days
- **High** (0.6-0.85): Seek medical attention today
- **Critical** (0.85-1.0): Emergency - call ambulance

### 5. Recommendation Engine
Provides:
- Appropriate medical department
- Urgency level
- Specific action items
- Home care advice
- Follow-up recommendations

## API Endpoints

### POST /api/v1/symptom-checker/predict
Predict diseases from symptoms

**Request:**
```json
{
  "symptoms": ["fever", "cough"],
  "age": 35,
  "gender": "male",
  "weight": 75,
  "height": 175,
  "duration": 3,
  "severity": 2
}
```

**Response:**
```json
{
  "status": "success",
  "prediction": {
    "primary_disease": "Flu",
    "confidence": 0.87,
    "top_diseases": [
      {"disease": "Flu", "confidence": 0.87},
      {"disease": "Common Cold", "confidence": 0.78}
    ]
  },
  "risk_assessment": {
    "risk_level": "medium",
    "risk_score": 0.45,
    "is_emergency": false
  },
  "recommendations": {
    "department": "General Medicine",
    "urgency": "Moderate - Within 2-3 days",
    "primary_action": "Visit a local clinic or general practitioner"
  }
}
```

### GET /api/v1/symptom-checker/symptoms
Get list of recognized symptoms

### GET /api/v1/symptom-checker/diseases
Get list of predictable diseases

### GET /api/v1/symptom-checker/health
Check service health status

## Performance Metrics

Target metrics:
- **Accuracy**: > 85%
- **Top-3 Accuracy**: > 95%
- **Precision**: > 80%
- **Recall**: > 80%
- **F1 Score**: > 80%

## Troubleshooting

### Model not loading
```
Error: Model not found at artifacts/trained_models/...
```
**Solution**: Train the model first using `python symptom_checker/training/train.py`

### Low accuracy
**Solutions**:
1. Use more training data
2. Perform hyperparameter tuning
3. Check data quality and balance
4. Add more features

### API returning 503
**Solution**: Ensure model is trained and loaded before starting the API

## Configuration

Edit `config/config.py` to customize:
- Model parameters (n_estimators, max_depth)
- Risk thresholds
- Emergency symptoms list
- Department mappings

## Next Steps

1. **Collect Real Data**: Replace synthetic data with real medical datasets
2. **Improve Model**: Try ensemble methods, hyperparameter tuning
3. **Add Features**: Medical history, family history, lab results
4. **Deploy**: Set up production environment
5. **Monitor**: Track prediction accuracy and user feedback

## Support

For issues or questions:
1. Check logs in `logs/` directory
2. Review error messages
3. Ensure all dependencies are installed
4. Verify dataset format

## License

Part of the AI Healthcare Assistant project.
