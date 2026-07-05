# 🚀 Quick Start - Symptom Checker

## ⚡ 5-Minute Setup

### Step 1: Install Dependencies (1 min)
```bash
cd ai_models/symptom_checker
pip install -r requirements.txt
```

### Step 2: Train the Model (2 min)
```bash
python training/train.py
```

### Step 3: Test (1 min)
```bash
# Quick test
python test_quick.py

# Full demo
python main.py
```

### Step 4: Start API (1 min)
```bash
cd ../../backend
uvicorn app.main:app --reload
```

### Step 5: Access the API
Open browser: http://localhost:8000/docs

---

## 🧪 Test the API

### Method 1: Swagger UI
1. Go to http://localhost:8000/docs
2. Click on `POST /api/v1/symptom-checker/predict`
3. Click "Try it out"
4. Use this test data:

```json
{
  "symptoms": ["fever", "cough", "headache", "fatigue"],
  "age": 35,
  "gender": "male",
  "weight": 75,
  "height": 175,
  "duration": 3,
  "severity": 2
}
```

5. Click "Execute"

### Method 2: cURL
```bash
curl -X POST http://localhost:8000/api/v1/symptom-checker/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["fever", "cough", "fatigue"],
    "age": 35,
    "gender": "male",
    "duration": 3,
    "severity": 2
  }'
```

### Method 3: Python
```python
import requests

response = requests.post(
    'http://localhost:8000/api/v1/symptom-checker/predict',
    json={
        'symptoms': ['fever', 'cough', 'headache'],
        'age': 35,
        'gender': 'male',
        'duration': 3,
        'severity': 2
    }
)

print(response.json())
```

---

## 📱 Run Mobile App

```bash
cd mobile_app
flutter pub get
flutter run
```

Navigate to: **Symptom Checker** from the app menu

---

## ✅ Verification Checklist

- [ ] Model trained successfully (see `artifacts/trained_models/`)
- [ ] Test script passes all checks
- [ ] API health check returns "healthy"
- [ ] Sample prediction works
- [ ] Mobile app connects to API

---

## 🎯 What You Get

**Input**: Patient symptoms + demographics

**Output**: 
- ✅ Top 5 disease predictions
- ✅ Risk level (Low/Medium/High/Critical)
- ✅ Recommended medical department
- ✅ Specific action items
- ✅ Care advice
- ✅ Emergency alerts

---

## 📊 Expected Results

### Example Input:
```
Symptoms: fever, cough, headache, fatigue
Age: 35
Gender: male
Duration: 3 days
Severity: Moderate
```

### Example Output:
```
Primary Disease: Flu (87% confidence)

Top Diseases:
1. Flu - 87%
2. Common Cold - 78%
3. COVID-19 - 65%
4. Pneumonia - 42%
5. Bronchitis - 38%

Risk Level: MEDIUM (45% risk score)
Department: General Medicine
Urgency: Moderate - Within 2-3 days

Actions:
• Schedule appointment within 2-3 days
• Monitor symptoms for worsening
• Keep symptom diary

Care Advice:
• Get adequate rest
• Stay hydrated
• Monitor body temperature
```

---

## 🔧 Troubleshooting

### Model Training Fails
```bash
# Check Python version
python --version  # Should be 3.8+

# Install dependencies again
pip install --upgrade numpy pandas scikit-learn joblib
```

### API Returns 503
```
Service unavailable = Model not loaded
```
**Solution**: Train the model first (Step 2)

### Import Errors
```bash
# Make sure you're in the right directory
cd ai_models
python symptom_checker/training/train.py
```

---

## 📞 Quick Help

**Check Model Exists**:
```bash
ls ai_models/symptom_checker/artifacts/trained_models/
```

**Check API Health**:
```bash
curl http://localhost:8000/api/v1/symptom-checker/health
```

**View API Logs**:
Backend terminal shows all requests/responses

---

## 🎓 Learn More

- **Full Documentation**: See `SYMPTOM_CHECKER_COMPLETE.md`
- **API Reference**: http://localhost:8000/docs
- **Model Details**: `ai_models/symptom_checker/README.md`

---

## 🎉 You're Ready!

Your symptom checker is now:
- ✅ **Trained** with AI model
- ✅ **Running** on API
- ✅ **Tested** and verified
- ✅ **Ready** for mobile app

**Next**: Integrate with your mobile app and start checking symptoms!

---

**Need help?** Check logs in:
- Training: `ai_models/symptom_checker/logs/training.log`
- API: Backend terminal output
- Mobile: Flutter console
