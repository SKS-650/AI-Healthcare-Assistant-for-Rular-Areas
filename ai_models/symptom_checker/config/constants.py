"""Constants for symptom checker module."""

from typing import Dict, List

# Symptom Severity Levels
SEVERITY_LEVELS = {
    "mild": 1,
    "moderate": 2,
    "severe": 3,
    "critical": 4
}

# Age Groups
AGE_GROUPS = {
    "infant": (0, 2),
    "child": (3, 12),
    "teen": (13, 19),
    "young_adult": (20, 35),
    "adult": (36, 55),
    "senior": (56, 200)
}

# BMI Categories
BMI_CATEGORIES = {
    "underweight": (0, 18.5),
    "normal": (18.5, 24.9),
    "overweight": (25, 29.9),
    "obese": (30, 100)
}

# Gender Encoding
GENDER_ENCODING = {
    "male": 0,
    "female": 1,
    "other": 2
}

# Duration Categories (in days)
DURATION_CATEGORIES = {
    "acute": (0, 7),       # Less than a week
    "subacute": (7, 30),   # 1 week to 1 month
    "chronic": (30, 9999)  # More than 1 month
}

# Common Symptom Mappings (standardization)
# Maps user-facing display names AND common terms → exact feature names used in the trained model
SYMPTOM_SYNONYMS: Dict[str, List[str]] = {
    # General
    "fever": ["high temperature", "pyrexia", "febrile", "high fever"],
    "chills": ["shivering", "rigors"],
    "fatigue": ["tiredness", "exhaustion", "lethargy", "weakness", "tired", "lack of energy"],
    "weakness": ["general weakness", "body weakness"],
    "sweating": ["excessive sweating", "night sweats", "perspiration"],
    "ache all over": ["body aches", "generalized aches", "body pain", "muscle aches"],
    "weight gain": ["gaining weight", "increased weight"],
    "flu-like syndrome": ["flu like symptoms", "influenza like", "flu symptoms"],
    "feeling ill": ["unwell", "malaise", "general discomfort"],
    "restlessness": ["agitation", "unable to rest"],
    "sleepiness": ["drowsiness", "somnolence", "excessive sleepiness"],

    # Respiratory
    "cough": ["coughing", "tussis", "dry cough"],
    "shortness of breath": [
        "dyspnea", "breathing difficulty", "breathlessness",
        "difficulty breathing", "short of breath", "sob",
        "can't breathe", "trouble breathing"
    ],
    "difficulty breathing": ["hard to breathe", "labored breathing"],
    "wheezing": ["whistling breath", "noisy breathing"],
    "nasal congestion": ["blocked nose", "stuffy nose", "congestion"],
    "sore throat": ["throat pain", "pharyngitis", "throat soreness", "throat irritation"],
    "hoarse voice": ["hoarseness", "husky voice", "raspy voice"],
    "coughing up sputum": ["productive cough", "phlegm", "mucus cough"],
    "sneezing": ["sneezes"],
    "congestion in chest": ["chest congestion", "chest fullness"],
    "breathing fast": ["rapid breathing", "fast breathing", "tachypnea"],
    "hurts to breath": ["painful breathing", "pleuritic pain"],
    "hemoptysis": ["coughing blood", "blood in sputum"],
    "apnea": ["sleep apnea", "breathing stops"],
    "abnormal breathing sounds": ["abnormal breath sounds", "crackles", "rhonchi"],
    "sinus congestion": ["sinus blockage", "sinusitis"],
    "painful sinuses": ["sinus pain", "sinus pressure"],

    # Cardiovascular
    "palpitations": ["heart palpitations", "racing heart"],
    "irregular heartbeat": ["arrhythmia", "heart irregularity"],
    "increased heart rate": ["tachycardia", "fast heart rate", "rapid heartbeat"],
    "decreased heart rate": ["bradycardia", "slow heart rate"],
    "chest tightness": ["tight chest", "chest pressure"],
    "sharp chest pain": ["sharp pain in chest", "stabbing chest pain"],
    "burning chest pain": ["chest burning", "heartburn like chest pain"],
    "peripheral edema": ["leg swelling", "ankle swelling", "edema", "swelling in legs"],

    # Neurological
    "headache": ["head pain", "cephalalgia", "migraine", "head ache"],
    "frontal headache": ["forehead pain", "frontal pain"],
    "dizziness": ["lightheadedness", "vertigo", "dizzy"],
    "fainting": ["loss of consciousness", "syncope", "blackout", "passing out"],
    "seizures": ["epilepsy", "convulsions", "fits"],
    "insomnia": ["sleeplessness", "can't sleep", "trouble sleeping"],
    "paresthesia": ["tingling", "numbness tingling", "pins and needles"],
    "loss of sensation": ["numbness", "numb"],
    "focal weakness": ["one-sided weakness", "hemiparesis"],
    "disturbance of memory": ["memory loss", "forgetfulness", "memory problems"],
    "abnormal involuntary movements": ["tremors", "involuntary movements", "shaking"],
    "problems with movement": ["movement problems", "difficulty moving"],

    # Digestive / GI
    "nausea": ["feeling sick", "queasiness", "nauseated"],
    "vomiting": ["throwing up", "emesis", "puking"],
    "diarrhea": ["loose stool", "loose motion", "watery stool"],
    "constipation": ["difficulty passing stool", "no bowel movement"],
    "abdominal pain": ["stomach pain", "belly pain", "stomach ache"],
    "sharp abdominal pain": ["severe abdominal pain", "acute abdomen"],
    "upper abdominal pain": ["epigastric pain", "upper stomach pain"],
    "lower abdominal pain": ["lower stomach pain", "pelvic discomfort"],
    "burning abdominal pain": ["burning stomach"],
    "stomach bloating": ["bloating", "abdominal bloating", "distension"],
    "blood in stool": ["bloody stool", "rectal blood"],
    "vomiting blood": ["hematemesis"],
    "melena": ["black stool", "tarry stool"],
    "rectal bleeding": ["rectal blood", "bleeding from rectum"],
    "heartburn": ["acid reflux", "gerd", "indigestion"],
    "regurgitation": ["regurgitating", "food coming back up"],
    "changes in stool appearance": ["stool changes", "abnormal stool"],
    "loss of appetite": ["decreased appetite", "anorexia", "no appetite", "not hungry"],
    "decreased appetite": ["poor appetite", "appetite loss"],
    "pain of the anus": ["anal pain", "bottom pain"],
    "mass or swelling around the anus": ["anal mass", "hemorrhoids"],
    "blood clots during menstrual periods": ["clots in period"],

    # Musculoskeletal / Pain
    "back pain": ["backache", "lumbar pain", "upper back pain"],
    "low back pain": ["lower back pain", "lumbar ache"],
    "neck pain": ["cervical pain", "stiff neck"],
    "joint pain": ["arthralgia", "joint ache"],
    "leg pain": ["leg ache", "pain in leg"],
    "hip pain": ["hip ache", "pain in hip"],
    "knee pain": ["knee ache", "pain in knee"],
    "ankle pain": ["ankle ache", "pain in ankle"],
    "foot or toe pain": ["foot pain", "toe pain"],
    "elbow pain": ["elbow ache"],
    "shoulder pain": ["shoulder ache"],
    "arm pain": ["arm ache", "pain in arm"],
    "wrist pain": ["wrist ache"],
    "hand or finger pain": ["hand pain", "finger pain"],
    "cramps and spasms": ["muscle cramps", "muscle spasms", "spasms"],
    "bones are painful": ["bone pain", "bone ache"],
    "rib pain": ["rib ache", "pain in ribs"],
    "groin pain": ["groin ache", "inguinal pain"],
    "lower body pain": ["lower limb pain"],
    "side pain": ["flank pain", "side ache"],

    # Skin
    "skin rash": ["rash", "skin eruption", "body rash"],
    "acne or pimples": ["acne", "pimples", "breakout"],
    "skin lesion": ["skin sore", "wound", "lesion"],
    "abnormal appearing skin": ["abnormal skin", "discolored skin"],
    "itching of skin": ["skin itch", "skin itching", "itchy skin", "pruritus"],
    "skin growth": ["growth on skin"],
    "skin moles": ["moles"],
    "skin swelling": ["swollen skin"],
    "warts": ["skin warts"],
    "skin dryness, peeling, scaliness, or roughness": [
        "dry skin", "peeling skin", "flaky skin", "rough skin"
    ],
    "skin irritation": ["irritated skin"],
    "jaundice": ["yellow skin", "yellow eyes", "icterus"],
    "skin growth": ["skin tag"],

    # ENT / Head
    "ear pain": ["earache", "otalgia"],
    "ringing in ear": ["tinnitus"],
    "plugged feeling in ear": ["blocked ear", "ear blockage"],
    "itchy ear(s)": ["itchy ear", "ear itching"],
    "diminished hearing": ["hearing loss", "hard of hearing", "deaf"],
    "fluid in ear": ["ear fluid"],
    "pus draining from ear": ["ear discharge", "otorrhea"],
    "bleeding from ear": ["ear bleeding"],
    "pulling at ears": ["ear pulling"],
    "redness in ear": ["red ear"],
    "mouth ulcer": ["oral ulcer", "canker sore", "mouth sore"],
    "toothache": ["tooth pain", "dental pain"],
    "gum pain": ["gum ache"],
    "mouth dryness": ["dry mouth", "xerostomia"],
    "mouth pain": ["oral pain"],
    "bleeding gums": ["gum bleeding"],
    "pain in gums": ["gum pain"],
    "lip swelling": ["swollen lip"],
    "facial pain": ["face pain"],
    "throat swelling": ["swollen throat"],
    "difficulty in swallowing": ["dysphagia", "difficulty swallowing", "trouble swallowing"],
    "difficulty speaking": ["speech difficulty", "speech problems"],
    "hoarse voice": ["hoarseness"],
    "jaw swelling": ["swollen jaw"],
    "nosebleed": ["epistaxis", "nose bleed", "bleeding from nose"],

    # Eyes
    "diminished vision": ["blurred vision", "blurry vision", "vision loss", "poor vision"],
    "double vision": ["diplopia"],
    "pain in eye": ["eye pain", "ocular pain"],
    "eye redness": ["red eyes", "bloodshot eyes"],
    "lacrimation": ["watery eyes", "excessive tearing"],
    "itchiness of eye": ["itchy eyes", "eye itching"],
    "white discharge from eye": ["eye discharge"],
    "blindness": ["loss of vision", "can't see"],
    "eye burns or stings": ["burning eyes", "stinging eyes"],
    "spots or clouds in vision": ["floaters", "visual spots"],
    "swollen eye": ["swollen eyes"],
    "eyelid swelling": ["puffy eyelids"],
    "eyelid lesion or rash": ["eyelid rash"],
    "mass on eyelid": ["eyelid lump"],
    "abnormal movement of eyelid": ["eyelid twitching"],
    "foreign body sensation in eye": ["something in eye"],
    "symptoms of eye": ["eye problem", "eye symptoms"],
    "bleeding from eye": ["eye bleeding"],

    # Urinary / Reproductive
    "painful urination": ["dysuria", "burning urination", "pain when urinating"],
    "frequent urination": ["urinary frequency", "going to toilet often"],
    "blood in urine": ["hematuria", "blood in pee"],
    "retention of urine": ["urine retention", "unable to urinate", "urinary retention"],
    "involuntary urination": ["urinary incontinence", "leaking urine"],
    "unusual color or odor to urine": ["dark urine", "smelly urine"],
    "excessive urination at night": ["nocturia", "waking to urinate"],
    "low urine output": ["oliguria", "reduced urine"],
    "hesitancy": ["difficulty starting urination", "urinary hesitancy"],
    "suprapubic pain": ["pelvic pressure"],
    "symptoms of bladder": ["bladder symptoms", "bladder problems"],
    "symptoms of the kidneys": ["kidney problems", "kidney symptoms"],
    "kidney mass": ["kidney lump"],

    # Mental / Behavioral
    "anxiety and nervousness": ["anxiety", "nervousness", "anxious", "panic"],
    "depression": ["depressed", "low mood", "feeling depressed"],
    "depressive or psychotic symptoms": ["psychotic symptoms"],
    "insomnia": ["sleeplessness"],
    "excessive anger": ["anger issues", "irritability", "irritable"],
    "hostile behavior": ["aggressive behavior"],
    "abusing alcohol": ["alcohol abuse", "alcoholism"],
    "drug abuse": ["substance abuse"],
    "fears and phobias": ["phobia", "fear"],
    "delusions or hallucinations": ["hallucinations", "delusions"],
    "obsessions and compulsions": ["ocd", "obsessive thoughts"],
    "antisocial behavior": ["social withdrawal"],
    "temper problems": ["temper tantrums"],
    "hysterical behavior": ["hysteria"],
    "low self-esteem": ["poor self-esteem"],

    # Other specific
    "allergic reaction": ["allergy", "allergic response", "allergic"],
    "fluid retention": ["water retention", "edema"],
    "neck mass": ["neck lump"],
    "neck swelling": ["swollen neck"],
    "knee swelling": ["swollen knee"],
    "leg swelling": ["swollen legs"],
    "foot or toe swelling": ["swollen foot"],
    "ankle swelling": ["swollen ankle"],
    "elbow swelling": ["swollen elbow"],
    "arm swelling": ["swollen arm"],
    "hand or finger swelling": ["swollen hand", "swollen fingers"],
    "wrist swelling": ["swollen wrist"],
    "arm stiffness or tightness": ["stiff arm"],
    "hand or finger stiffness or tightness": ["stiff fingers"],
    "knee stiffness or tightness": ["stiff knee"],
    "shoulder stiffness or tightness": ["stiff shoulder"],
    "hip stiffness or tightness": ["stiff hip"],
    "back stiffness or tightness": ["stiff back"],
    "back cramps or spasms": ["back spasms", "back cramps"],
    "back mass or lump": ["back lump"],
    "arm lump or mass": ["arm lump"],
    "hand or finger lump or mass": ["hand lump"],
    "hand or finger weakness": ["weak hands", "weak fingers"],
    "arm weakness": ["weak arm"],
    "leg weakness": ["weak legs"],
    "focal weakness": ["one-sided weakness"],
    "irregular appearing scalp": ["scalp problems"],
    "itchy scalp": ["scalp itch"],
    "irregular appearing nails": ["nail problems", "abnormal nails"],

    # Female-specific
    "vaginal itching": ["vaginal itch"],
    "vaginal discharge": ["vaginal secretion"],
    "vaginal pain": ["vaginal discomfort"],
    "vaginal redness": ["vaginal irritation"],
    "painful menstruation": ["period pain", "dysmenorrhea", "menstrual cramps"],
    "heavy menstrual flow": ["heavy periods", "menorrhagia"],
    "long menstrual periods": ["prolonged periods"],
    "frequent menstruation": ["frequent periods"],
    "unpredictable menstruation": ["irregular periods"],
    "intermenstrual bleeding": ["spotting", "mid-cycle bleeding"],
    "spotting or bleeding during pregnancy": ["pregnancy bleeding"],
    "problems during pregnancy": ["pregnancy complications"],
    "pain during pregnancy": ["pregnancy pain"],
    "recent pregnancy": ["just had baby", "postpartum"],
    "uterine contractions": ["contractions"],
    "hot flashes": ["hot flush", "hot flushes"],
    "infertility": ["trouble conceiving", "can't get pregnant"],
    "pain during intercourse": ["dyspareunia"],

    # Male-specific
    "symptoms of the scrotum and testes": ["testicular symptoms"],
    "swelling of scrotum": ["scrotal swelling"],
    "pain in testicles": ["testicular pain"],
    "impotence": ["erectile dysfunction", "ed"],

    # Other
    "coryza": ["common cold", "runny nose", "rhinorrhea", "nasal drip", "runny nse"],
    "lack of growth": ["growth retardation", "stunted growth"],
    "irritable infant": ["fussy baby", "crying baby"],
    "infant feeding problem": ["feeding difficulty"],
    "diaper rash": ["nappy rash"],
    "pelvic pain": ["pelvic discomfort"],
    "swollen or red tonsils": ["tonsillitis", "swollen tonsils"],
    "congestion in chest": ["chest congestion"],
    "symptoms of prostate": ["prostate problems"],
    "symptoms of the face": ["face symptoms"],
    "irregular appearing scalp": ["scalp issue"],
    "blood clots during menstrual periods": ["menstrual clots"],
}

# Disease Categories
DISEASE_CATEGORIES = [
    "Respiratory Diseases",
    "Digestive Diseases",
    "Cardiovascular Diseases",
    "Neurological Diseases",
    "Infectious Diseases",
    "Skin Diseases",
    "Endocrine Diseases",
    "Orthopedic Conditions",
    "Eye Conditions",
    "ENT Conditions",
    "Mental Health",
    "Autoimmune Diseases"
]

# Critical Symptoms requiring immediate attention
CRITICAL_SYMPTOMS = [
    "severe chest pain",
    "difficulty breathing",
    "loss of consciousness",
    "severe bleeding",
    "stroke symptoms",
    "sudden numbness",
    "severe headache with confusion",
    "seizures",
    "severe allergic reaction",
    "coughing blood",
    "vomiting blood"
]

# High-Risk Symptom Combinations
HIGH_RISK_COMBINATIONS = [
    ["chest pain", "shortness of breath"],
    ["fever", "severe headache", "stiff neck"],
    ["severe abdominal pain", "vomiting"],
    ["confusion", "high fever"],
    ["chest pain", "dizziness", "sweating"]
]

# Default Recommendations by Risk Level
RECOMMENDATIONS = {
    "low": {
        "action": "Monitor symptoms and practice self-care",
        "details": [
            "Rest adequately",
            "Stay hydrated",
            "Monitor symptoms for changes",
            "Consult a doctor if symptoms worsen"
        ]
    },
    "medium": {
        "action": "Visit a local clinic or general practitioner",
        "details": [
            "Schedule an appointment within 2-3 days",
            "Keep track of symptom progression",
            "Bring list of current medications",
            "Note any allergies"
        ]
    },
    "high": {
        "action": "Seek medical attention today",
        "details": [
            "Visit a hospital or specialist",
            "Do not delay treatment",
            "Bring medical history",
            "Consider emergency care if symptoms worsen"
        ]
    },
    "critical": {
        "action": "EMERGENCY - Seek immediate medical attention",
        "details": [
            "Call emergency services (ambulance)",
            "Go to nearest emergency department",
            "Do not drive yourself",
            "Alert family members"
        ]
    }
}
