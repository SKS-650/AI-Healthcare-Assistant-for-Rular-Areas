"""API routes for symptom checker."""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import List

from .schemas import (
    SymptomCheckRequest,
    SymptomCheckResponse,
    SymptomListResponse,
    DiseaseListResponse,
    HealthStatusResponse
)
from .service import symptom_checker_service
from ..auth.dependencies import get_current_user
from ..auth.models import UserModel

router = APIRouter(prefix="/symptom-checker", tags=["Symptom Checker"])


@router.post("/predict", response_model=SymptomCheckResponse)
async def predict_disease(
    request: SymptomCheckRequest,
    current_user: UserModel = Depends(get_current_user)
):
    """
    Predict possible diseases based on symptoms.
    
    **Required fields:**
    - symptoms: List of symptom names
    - age: Patient age (0-120)
    - gender: male/female/other
    
    **Optional fields:**
    - weight: Weight in kg
    - height: Height in cm
    - duration: Symptom duration in days
    - severity: Severity level (1-4)
    - existing_diseases: List of existing conditions
    - medications: List of current medications
    - allergies: List of allergies
    - pregnancy_status: Boolean
    
    **Returns:**
    - Top 5 possible diseases with confidence scores
    - Risk assessment (low/medium/high/critical)
    - Medical recommendations
    - Emergency alerts if needed
    """
    # Check if model is loaded
    if not symptom_checker_service.is_model_loaded():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Symptom checker model is not available. Please contact administrator."
        )
    
    # Perform prediction
    result = symptom_checker_service.check_symptoms(request)
    
    if result.get("status") == "error":
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=result.get("message", "Prediction failed")
        )
    
    return result


@router.get("/symptoms", response_model=SymptomListResponse)
async def get_symptoms():
    """
    Get list of available symptoms that the model recognizes.
    
    Use this endpoint to get the complete list of symptoms
    that can be used in prediction requests.
    """
    symptoms = symptom_checker_service.get_available_symptoms()
    
    return {
        "symptoms": symptoms,
        "total": len(symptoms)
    }


@router.get("/symptoms/categorized")
async def get_symptoms_categorized():
    """
    Get all 230 symptoms organized by body-system category.
    Each entry has: name (exact model feature name), display_name, category, icon.
    """
    symptoms = symptom_checker_service.get_available_symptoms()
    
    # Map symptoms to categories
    CATEGORY_MAP = {
        # General / Systemic
        "fever": "General", "chills": "General", "fatigue": "General",
        "weakness": "General", "sweating": "General", "ache all over": "General",
        "weight gain": "General", "flu-like syndrome": "General",
        "feeling ill": "General", "restlessness": "General",
        "sleepiness": "General", "lack of growth": "General",
        # Respiratory
        "cough": "Respiratory", "shortness of breath": "Respiratory",
        "difficulty breathing": "Respiratory", "wheezing": "Respiratory",
        "nasal congestion": "Respiratory", "sore throat": "Respiratory",
        "hoarse voice": "Respiratory", "coughing up sputum": "Respiratory",
        "sneezing": "Respiratory", "congestion in chest": "Respiratory",
        "breathing fast": "Respiratory", "hurts to breath": "Respiratory",
        "hemoptysis": "Respiratory", "apnea": "Respiratory",
        "abnormal breathing sounds": "Respiratory", "sinus congestion": "ENT",
        "painful sinuses": "ENT", "throat swelling": "ENT",
        "difficulty in swallowing": "ENT", "difficulty speaking": "ENT",
        # Cardiovascular
        "palpitations": "Cardiovascular", "irregular heartbeat": "Cardiovascular",
        "increased heart rate": "Cardiovascular", "decreased heart rate": "Cardiovascular",
        "chest tightness": "Cardiovascular", "sharp chest pain": "Cardiovascular",
        "burning chest pain": "Cardiovascular", "peripheral edema": "Cardiovascular",
        # Neurological
        "headache": "Neurological", "frontal headache": "Neurological",
        "dizziness": "Neurological", "fainting": "Neurological",
        "seizures": "Neurological", "insomnia": "Neurological",
        "paresthesia": "Neurological", "loss of sensation": "Neurological",
        "focal weakness": "Neurological", "disturbance of memory": "Neurological",
        "abnormal involuntary movements": "Neurological",
        "problems with movement": "Neurological",
        # Digestive
        "nausea": "Digestive", "vomiting": "Digestive", "diarrhea": "Digestive",
        "constipation": "Digestive", "sharp abdominal pain": "Digestive",
        "upper abdominal pain": "Digestive", "lower abdominal pain": "Digestive",
        "burning abdominal pain": "Digestive", "stomach bloating": "Digestive",
        "blood in stool": "Digestive", "vomiting blood": "Digestive",
        "melena": "Digestive", "rectal bleeding": "Digestive",
        "heartburn": "Digestive", "regurgitation": "Digestive",
        "regurgitation.1": "Digestive", "changes in stool appearance": "Digestive",
        "decreased appetite": "Digestive", "pain of the anus": "Digestive",
        "mass or swelling around the anus": "Digestive",
        # Musculoskeletal
        "back pain": "Musculoskeletal", "low back pain": "Musculoskeletal",
        "neck pain": "Musculoskeletal", "joint pain": "Musculoskeletal",
        "leg pain": "Musculoskeletal", "hip pain": "Musculoskeletal",
        "knee pain": "Musculoskeletal", "ankle pain": "Musculoskeletal",
        "foot or toe pain": "Musculoskeletal", "elbow pain": "Musculoskeletal",
        "shoulder pain": "Musculoskeletal", "arm pain": "Musculoskeletal",
        "wrist pain": "Musculoskeletal", "hand or finger pain": "Musculoskeletal",
        "cramps and spasms": "Musculoskeletal", "bones are painful": "Musculoskeletal",
        "rib pain": "Musculoskeletal", "groin pain": "Musculoskeletal",
        "lower body pain": "Musculoskeletal", "side pain": "Musculoskeletal",
        "knee swelling": "Musculoskeletal", "leg swelling": "Musculoskeletal",
        "foot or toe swelling": "Musculoskeletal", "ankle swelling": "Musculoskeletal",
        "elbow swelling": "Musculoskeletal", "arm swelling": "Musculoskeletal",
        "wrist swelling": "Musculoskeletal", "hand or finger swelling": "Musculoskeletal",
        "arm stiffness or tightness": "Musculoskeletal",
        "hand or finger stiffness or tightness": "Musculoskeletal",
        "knee stiffness or tightness": "Musculoskeletal",
        "shoulder stiffness or tightness": "Musculoskeletal",
        "hip stiffness or tightness": "Musculoskeletal",
        "back stiffness or tightness": "Musculoskeletal",
        "back cramps or spasms": "Musculoskeletal",
        "back mass or lump": "Musculoskeletal",
        "arm lump or mass": "Musculoskeletal",
        "hand or finger lump or mass": "Musculoskeletal",
        "hand or finger weakness": "Musculoskeletal",
        "arm weakness": "Musculoskeletal", "leg weakness": "Musculoskeletal",
        # Skin
        "skin rash": "Skin", "acne or pimples": "Skin", "skin lesion": "Skin",
        "abnormal appearing skin": "Skin", "itching of skin": "Skin",
        "skin growth": "Skin", "skin moles": "Skin", "skin swelling": "Skin",
        "warts": "Skin", "itchy scalp": "Skin", "irregular appearing scalp": "Skin",
        "irregular appearing nails": "Skin",
        "skin dryness, peeling, scaliness, or roughness": "Skin",
        "skin irritation": "Skin", "jaundice": "Skin",
        "eyelid lesion or rash": "Skin", "diaper rash": "Skin",
        # ENT
        "ear pain": "ENT", "ringing in ear": "ENT", "plugged feeling in ear": "ENT",
        "itchy ear(s)": "ENT", "diminished hearing": "ENT", "fluid in ear": "ENT",
        "pus draining from ear": "ENT", "bleeding from ear": "ENT",
        "pulling at ears": "ENT", "redness in ear": "ENT",
        "mouth ulcer": "ENT", "toothache": "ENT", "gum pain": "ENT",
        "mouth dryness": "ENT", "mouth pain": "ENT", "bleeding gums": "ENT",
        "pain in gums": "ENT", "lip swelling": "ENT", "facial pain": "ENT",
        "jaw swelling": "ENT", "nosebleed": "ENT",
        "swollen or red tonsils": "ENT", "coryza": "ENT",
        # Eyes
        "diminished vision": "Eyes", "double vision": "Eyes",
        "pain in eye": "Eyes", "eye redness": "Eyes", "lacrimation": "Eyes",
        "itchiness of eye": "Eyes", "white discharge from eye": "Eyes",
        "blindness": "Eyes", "eye burns or stings": "Eyes",
        "spots or clouds in vision": "Eyes", "swollen eye": "Eyes",
        "eyelid swelling": "Eyes", "mass on eyelid": "Eyes",
        "abnormal movement of eyelid": "Eyes",
        "foreign body sensation in eye": "Eyes",
        "symptoms of eye": "Eyes", "bleeding from eye": "Eyes",
        # Urinary
        "painful urination": "Urinary", "frequent urination": "Urinary",
        "blood in urine": "Urinary", "retention of urine": "Urinary",
        "involuntary urination": "Urinary",
        "unusual color or odor to urine": "Urinary",
        "excessive urination at night": "Urinary",
        "low urine output": "Urinary", "hesitancy": "Urinary",
        "suprapubic pain": "Urinary", "symptoms of bladder": "Urinary",
        "symptoms of the kidneys": "Urinary", "kidney mass": "Urinary",
        # Mental Health
        "anxiety and nervousness": "Mental Health", "depression": "Mental Health",
        "depressive or psychotic symptoms": "Mental Health",
        "excessive anger": "Mental Health", "hostile behavior": "Mental Health",
        "abusing alcohol": "Mental Health", "drug abuse": "Mental Health",
        "fears and phobias": "Mental Health",
        "delusions or hallucinations": "Mental Health",
        "obsessions and compulsions": "Mental Health",
        "antisocial behavior": "Mental Health", "temper problems": "Mental Health",
        "hysterical behavior": "Mental Health", "low self-esteem": "Mental Health",
        # Reproductive / Gynecological
        "vaginal itching": "Reproductive", "vaginal discharge": "Reproductive",
        "vaginal pain": "Reproductive", "vaginal redness": "Reproductive",
        "painful menstruation": "Reproductive",
        "heavy menstrual flow": "Reproductive",
        "long menstrual periods": "Reproductive",
        "frequent menstruation": "Reproductive",
        "unpredictable menstruation": "Reproductive",
        "intermenstrual bleeding": "Reproductive",
        "spotting or bleeding during pregnancy": "Reproductive",
        "problems during pregnancy": "Reproductive",
        "pain during pregnancy": "Reproductive",
        "recent pregnancy": "Reproductive", "uterine contractions": "Reproductive",
        "hot flashes": "Reproductive", "infertility": "Reproductive",
        "pain during intercourse": "Reproductive",
        "blood clots during menstrual periods": "Reproductive",
        # Male
        "symptoms of the scrotum and testes": "Reproductive",
        "swelling of scrotum": "Reproductive",
        "pain in testicles": "Reproductive", "impotence": "Reproductive",
        "symptoms of prostate": "Reproductive",
        # Other
        "allergic reaction": "Immune", "fluid retention": "General",
        "neck mass": "General", "neck swelling": "General",
        "pelvic pain": "General", "symptoms of the face": "General",
        "infant feeding problem": "General", "irritable infant": "General",
        "lack of growth": "General",
    }
    
    def make_display_name(symptom: str) -> str:
        return " ".join(word.capitalize() for word in symptom.split())
    
    categorized = {}
    for symptom in symptoms:
        category = CATEGORY_MAP.get(symptom, "General")
        if category not in categorized:
            categorized[category] = []
        categorized[category].append({
            "name": symptom,
            "display_name": make_display_name(symptom),
            "category": category,
        })
    
    # Sort categories alphabetically, symptoms within each
    result = {}
    for cat in sorted(categorized.keys()):
        result[cat] = sorted(categorized[cat], key=lambda x: x["name"])
    
    total = sum(len(v) for v in result.values())
    return {"categories": result, "total": total}


@router.get("/diseases", response_model=DiseaseListResponse)
async def get_diseases():
    """
    Get list of diseases that the model can predict.
    
    Returns all disease categories that the trained model
    is capable of identifying.
    """
    diseases = symptom_checker_service.get_available_diseases()
    
    return {
        "diseases": diseases,
        "total": len(diseases)
    }


@router.get("/health", response_model=HealthStatusResponse)
async def health_check():
    """
    Check health status of symptom checker service.
    
    Returns information about model availability and readiness.
    """
    model_info = symptom_checker_service.get_model_info()
    
    if model_info.get("loaded"):
        return {
            "status": "healthy",
            "model_loaded": True,
            "model_version": model_info.get("model_version"),
            "available_symptoms": model_info.get("n_symptoms", 0),
            "message": "Symptom checker service is operational"
        }
    else:
        return {
            "status": "unavailable",
            "model_loaded": False,
            "model_version": None,
            "available_symptoms": 0,
            "message": "Symptom checker model is not loaded"
        }


@router.post("/batch-predict")
async def batch_predict(
    requests: List[SymptomCheckRequest],
    current_user: UserModel = Depends(get_current_user)
):
    """
    Perform batch prediction for multiple patients.
    
    **Note:** This endpoint processes multiple symptom check requests.
    Use with caution as it may take longer for large batches.
    """
    if not symptom_checker_service.is_model_loaded():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Symptom checker model is not available"
        )
    
    results = []
    for req in requests:
        result = symptom_checker_service.check_symptoms(req)
        results.append(result)
    
    return {
        "status": "success",
        "total_requests": len(requests),
        "results": results
    }


@router.get("/model-info")
async def get_model_info():
    """
    Get detailed information about the loaded model.
    
    Returns model version, capabilities, and statistics.
    """
    model_info = symptom_checker_service.get_model_info()
    
    if not model_info.get("loaded"):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Model not loaded"
        )
    
    return model_info


@router.post("/reload-model")
async def reload_model():
    """
    Hot-reload the symptom checker model from disk without restarting.

    Call this after:
    - Running train_large_dataset.py to retrain the model
    - Fixing corrupted artifacts on disk
    - Any time the running model produces unexpected results

    Returns the new model info after reload.
    """
    try:
        info = symptom_checker_service.reload_model()
        n = info.get("n_features", 0)
        if n != 230:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=(
                    f"Model reloaded but still has {n} features (expected 230). "
                    "Re-run train_large_dataset.py to regenerate correct artifacts."
                )
            )
        return {
            "status": "reloaded",
            "message": f"Model successfully reloaded: {n} features, "
                       f"{info.get('n_diseases', 0)} diseases.",
            "model_info": info,
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Reload failed: {str(e)}"
        )
