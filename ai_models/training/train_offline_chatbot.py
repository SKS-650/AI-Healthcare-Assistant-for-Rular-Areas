"""
Offline Medical Chatbot Training Script
========================================
Trains the intent classifier + builds offline FAISS knowledge index
from all datasets. Run: python train_offline_chatbot.py

Outputs saved to: ai_models/saved_models/
  - intent_classifier.pkl
  - medical_knowledge.faiss  (if sentence-transformers is installed)
  - medical_knowledge.json   (JSON fallback always created)
"""
from __future__ import annotations
import json, logging, os, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
log = logging.getLogger(__name__)

SAVED = ROOT / "ai_models" / "saved_models"
SAVED.mkdir(parents=True, exist_ok=True)

# ── Comprehensive medical knowledge dataset ───────────────────────────────────
MEDICAL_KNOWLEDGE = [
  # Symptoms
  {"id":"fever","topic":"Fever","intent":"SYMPTOM_QUERY","keywords":["fever","bukhar","jwaro","temperature","taato","bukhaar"],
   "en":"Fever is a body temperature above 38°C (100.4°F). Rest, drink 2–3L of fluids daily, take Paracetamol 500mg if temp >38.5°C. Use cool wet cloth on forehead. See doctor if >39.5°C or lasting >3 days, or with rash/stiff neck/breathing difficulty. 🌡️",
   "hi":"बुखार 38°C से ऊपर का तापमान है। आराम करें, पानी पिएं, पेरासिटामोल 500mg लें। 3 दिन से ज्यादा बुखार रहे या 39.5°C से ऊपर हो तो डॉक्टर से मिलें। 🌡️",
   "ne":"ज्वरो भनेको ३८°C भन्दा बढी तापक्रम हो। आराम गर्नुहोस्, पानी पिउनुहोस्, प्यारासिटामोल लिनुहोस्। ३ दिनभन्दा बढी रहे डाक्टर भेट्नुहोस्। 🌡️",
   "bho":"बुखार ३८°C से ऊपर के तापमान बा। आराम करा, पानी पिया, पेरासिटामोल लिया। ३ दिन से ज्यादा रहे त डॉक्टर से मिला। 🌡️"},
  {"id":"headache","topic":"Headache","intent":"SYMPTOM_QUERY","keywords":["headache","sardard","टाउको","migraine","sar dard","matha"],
   "en":"For headaches: rest in dark quiet room, drink 2-3 glasses water, cold/warm compress on forehead. Avoid bright screens. Emergency: sudden severe thunderclap headache, headache + fever + neck stiffness → call 108 immediately. 🤕",
   "hi":"सिरदर्द के लिए: अंधेरे कमरे में आराम, पानी पिएं, माथे पर ठंडा कपड़ा। अचानक तेज़ सिरदर्द + बुखार + गर्दन अकड़न हो तो 108 पर कॉल करें। 🤕",
   "ne":"टाउको दुख्दा: अँध्यारो कोठामा आराम, पानी पिउनुहोस्। अचानक तीव्र टाउको + ज्वरो + घाँटी अकडन भए 102 फोन गर्नुहोस्। 🤕",
   "bho":"मथवा दरद खातिर: अंधेरा कमरे में आराम करा, पानी पिया। अचानक तेज दर्द + बुखार + गर्दन अकड़न हो त 108 पर फोन करा। 🤕"},
  {"id":"cough","topic":"Cough","intent":"SYMPTOM_QUERY","keywords":["cough","khasi","khansi","खोकी","khaasi"],
   "en":"Cough relief: honey + warm water soothes throat, steam inhalation, ginger-tulsi tea, stay hydrated. Avoid cold drinks. See doctor if cough >2 weeks, blood in cough, or breathing difficulty. 😷",
   "hi":"खांसी: शहद + गर्म पानी, भाप लें, अदरक-तुलसी की चाय। 2 हफ्ते से ज्यादा खांसी, खून, सांस की दिक्कत हो तो डॉक्टर से मिलें। 😷",
   "ne":"खोकी: मह + तातो पानी, भाप, अदुवा-तुलसी चिया। २ हप्तादेखि बढी खोकी, रगत, सास लिन गाह्रो भए डाक्टर भेट्नुहोस्। 😷",
   "bho":"खांसी: शहद + गर्म पानी, भाप, अदरक-तुलसी चाय। २ हफ्ता से ज्यादा खांसी, खून, सांस में दिक्कत हो त डॉक्टर से मिला। 😷"},
  {"id":"cold","topic":"Common Cold","intent":"SYMPTOM_QUERY","keywords":["cold","runny nose","sneezing","naak behna","sardi"],
   "en":"For common cold: rest, drink warm fluids, saline nasal drops, steam inhalation. Vitamin C helps. Usually clears in 7-10 days. See doctor if fever >38.5°C, symptoms worsen after day 3, or ear pain develops. 🤧",
   "hi":"सर्दी-जुकाम: गर्म तरल पदार्थ, नमक के पानी की नेज़ल ड्रॉप्स, भाप। 7-10 दिन में ठीक होता है। तेज़ बुखार या कान दर्द हो तो डॉक्टर से मिलें। 🤧",
   "ne":"रुघा: तातो तरल, नुनपानी नेजल ड्रप, भाप। ७-१० दिनमा निको हुन्छ। तेज ज्वरो वा कान दुखाइ भए डाक्टर भेट्नुहोस्। 🤧",
   "bho":"सर्दी-जुकाम: गर्म तरल, नमक पानी के नेजल ड्रप, भाप। ७-१० दिन में ठीक हो जाई। 🤧"},
  # Medicines
  {"id":"paracetamol","topic":"Paracetamol","intent":"MEDICATION_QUERY","keywords":["paracetamol","acetaminophen","crocin","dolo","fever medicine"],
   "en":"Paracetamol (Acetaminophen): Used for fever and mild-moderate pain. Adult dose: 500mg-1g every 4-6 hours (max 4g/day). Safe for children and pregnancy (under guidance). ⚠️ Avoid with liver disease or heavy alcohol use. 💊",
   "hi":"पेरासिटामोल: बुखार और दर्द के लिए। वयस्क: 500mg-1g हर 4-6 घंटे (अधिकतम 4g/दिन)। लिवर रोग में न लें। 💊",
   "ne":"प्यारासिटामोल: ज्वरो र दुखाइको लागि। वयस्क: ५०० मि.ग्रा.-१ ग्राम हर ४-६ घण्टा। कलेजो रोगमा नलिनुहोस्। 💊",
   "bho":"पेरासिटामोल: बुखार आ दर्द खातिर। वयस्क: ५०० मि.ग्रा.-१ ग्राम, हर ४-६ घंटा। लिवर रोग में नाहीं लेवे के चाही। 💊"},
  {"id":"ibuprofen","topic":"Ibuprofen","intent":"MEDICATION_QUERY","keywords":["ibuprofen","brufen","combiflam","nsaid"],
   "en":"Ibuprofen: Anti-inflammatory painkiller. Adult dose: 200-400mg every 6-8 hours with food. Good for pain, fever, inflammation. ⚠️ Avoid if: stomach ulcer, kidney disease, pregnancy 3rd trimester. 💊",
   "hi":"इबुप्रोफेन: दर्द-सूजन विरोधी दवाई। खाने के साथ लें। पेट के अल्सर, किडनी रोग में न लें। 💊",
   "ne":"इबुप्रोफेन: दुखाइ र सूजन विरोधी। खाना खाएर लिनुहोस्। पेटको घाउ, मिर्गौला रोगमा नलिनुहोस्। 💊",
   "bho":"इबुप्रोफेन: दर्द-सूजन के दवाई। खाना के साथ लिया। पेट के घाव, किडनी रोग में नाहीं लेवे के चाही। 💊"},
  # Diseases
  {"id":"diabetes","topic":"Diabetes","intent":"GENERAL_MEDICAL","keywords":["diabetes","sugar","madhumeha","blood sugar","शुगर","chini"],
   "en":"Diabetes: High blood sugar condition. Type 1 (immune attacks insulin cells), Type 2 (body resists insulin). Management: Monitor blood sugar, eat low-sugar high-fiber diet, 30min exercise daily, take medications as prescribed. ✅ Eat: vegetables, whole grains, lean protein. ❌ Avoid: sugary drinks, white rice, sweets. 🩺",
   "hi":"मधुमेह: रक्त शर्करा बढना। दैनिक जांच, कम चीनी खाएं, 30 मिनट व्यायाम, दवाई नियमित लें। सब्जी, साबुत अनाज खाएं। मीठे पेय, मैदा से परहेज करें। 🩺",
   "ne":"मधुमेह: रगत चिनी बढ्ने समस्या। नियमित जाँच, कम चिनी खाना, ३० मिनेट व्यायाम, दवाई नियमित लिनुहोस्। 🩺",
   "bho":"मधुमेह: खून में चिनी बढ जाला। रोज जाँच करवा, कम मीठा खावा, ३० मिनेट व्यायाम करा, दवाई नियमित लिया। 🩺"},
  {"id":"hypertension","topic":"High Blood Pressure","intent":"GENERAL_MEDICAL","keywords":["blood pressure","hypertension","bp high","high bp","dawab khoon"],
   "en":"Hypertension (High BP): Blood pressure >140/90 mmHg. Reduce salt intake (<5g/day), exercise 30min daily, maintain healthy weight, limit alcohol. Take prescribed medications regularly. ⚠️ Can cause heart attack, stroke. Monitor BP at home. 🩺",
   "hi":"उच्च रक्तचाप: BP >140/90. नमक कम करें, व्यायाम, वजन नियंत्रण, दवाई नियमित लें। दिल का दौरा और स्ट्रोक का खतरा। 🩺",
   "ne":"उच्च रक्तचाप: BP >140/90। नुन कम खानुहोस्, व्यायाम, तौल नियन्त्रण, दवाई नियमित लिनुहोस्। 🩺",
   "bho":"उच्च रक्तचाप: BP >140/90। नमक कम खावा, व्यायाम करा, दवाई नियमित लिया। दिल के दौरा के खतरा बा। 🩺"},
  {"id":"asthma","topic":"Asthma","intent":"GENERAL_MEDICAL","keywords":["asthma","breathing","wheezing","inhaler","श्वास","dam"],
   "en":"Asthma: Chronic lung condition causing breathing difficulty. Use inhaler as prescribed. Avoid triggers: dust, pollen, smoke, cold air. During attack: sit upright, use reliever inhaler, breathe slowly. If no improvement in 10 min → call emergency. 💨",
   "hi":"अस्थमा: सांस लेने में कठिनाई। इनहेलर का उपयोग करें। धूल, धुआं से बचें। हमले के दौरान: सीधे बैठें, इनहेलर लें। 10 मिनट में सुधार न हो → 108 कॉल करें। 💨",
   "ne":"अस्थमा: सास लिन गाह्रो हुने समस्या। इन्हेलर प्रयोग गर्नुहोस्। धुलो, धुवाँबाट बच्नुहोस्। आक्रमण भए: सिधा बस्नुहोस्। 💨",
   "bho":"अस्थमा: सांस लेवे में दिक्कत। इन्हेलर इस्तेमाल करा। धूल, धुआँ से बचा। हमला होय त सीधा बैठा। 💨"},
  # Pregnancy
  {"id":"pregnancy","topic":"Pregnancy","intent":"PREGNANCY_QUERY","keywords":["pregnant","pregnancy","garbhwati","गर्भवती","baccha","prasav","trimester"],
   "en":"Pregnancy health: Folic acid (prevents neural defects), iron-rich foods (spinach, lentils), calcium (milk, yogurt), 8-10 glasses water daily. Key checkups: months 1,3,5,7,8,9. 🚨 Immediate doctor: severe abdominal pain, heavy bleeding, severe headache+swelling, baby not moving after 28 weeks. 🤰",
   "hi":"गर्भावस्था: फोलिक एसिड, पालक-मसूर, दूध-दही, रोज़ 8-10 गिलास पानी। 🚨 तुरंत डॉक्टर: तेज़ पेट दर्द, भारी रक्तस्राव, तेज़ सिरदर्द+सूजन, बच्चा न हिले। 🤰",
   "ne":"गर्भावस्था: फोलिक एसिड, पालक-मसुर, दूध-दही, रोज ८-१० गिलास पानी। 🚨 तुरुन्त डाक्टर: तीव्र पेट दुखाइ, भारी रक्तस्राव, बच्चा नहिले। 🤰",
   "bho":"गर्भावस्था: फोलिक एसिड, पालक, दूध, रोज ८-१० गिलास पानी। 🚨 फौरन डॉक्टर: तेज पेट दर्द, भारी खून, बच्चा न हिले। 🤰"},
  # Mental Health
  {"id":"mental_health","topic":"Mental Health","intent":"MENTAL_HEALTH_QUERY","keywords":["stress","anxiety","depression","mental","sad","lonely","tension","chinta"],
   "en":"Your feelings are valid. You are not alone. 💙\nTry: 5 slow deep breaths, short walk in fresh air, talk to someone trusted, limit social media.\nProfessional help: iCall (India) 📞9152987821, Vandrevala Foundation 📞1860-2662-345, Nepal: 📞1166.\nMental health matters as much as physical health. 💚",
   "hi":"आपकी भावनाएं मान्य हैं। आप अकेले नहीं हैं। 💙\n5 गहरी सांस लें, बाहर टहलें, किसी से बात करें।\niCall: 📞9152987821 💚",
   "ne":"तपाईंका भावनाहरू मान्य छन्। तपाईं एक्लो हुनुहुन्न। 💙\n५ गहिरो श्वास लिनुहोस्, बाहिर हिँड्नुहोस्।\nनेपाल: 📞1166 💚",
   "bho":"रउआ के भावना सही बा। रउआ अकेल नइखी। 💙\nगहरा सांस लिया, बाहर चला।\niCall: 📞9152987821 💚"},
  # Child care
  {"id":"child_fever","topic":"Child Fever","intent":"CHILDCARE_QUERY","keywords":["child fever","baby fever","infant","bachcha fever","shishu bukhar"],
   "en":"Child fever: Under 3 months with any fever → doctor IMMEDIATELY. 3m-3y: fever >38.5°C give paracetamol syrup by weight. Keep hydrated. Cool (not cold) compress. Never use aspirin for children. Emergency: difficulty breathing, seizure, purple rash. 👶",
   "hi":"बच्चे को बुखार: 3 महीने से कम → तुरंत डॉक्टर। 3m-3y: >38.5°C पर पेरासिटामोल सिरप दें। दौरे, सांस की दिक्कत → 108 कॉल। 👶",
   "ne":"बच्चालाई ज्वरो: ३ महिनाभन्दा कम → तुरुन्त डाक्टर। दौरे, सास लिन गाह्रो → 102 फोन गर्नुहोस्। 👶",
   "bho":"बच्चा के बुखार: ३ महिना से कम → फौरन डॉक्टर। दौरा, सांस में दिक्कत → 108 कॉल करा। 👶"},
  # Nutrition
  {"id":"nutrition_diabetes","topic":"Diabetic Diet","intent":"NUTRITION_QUERY","keywords":["diabetic food","diabetes diet","sugar food","blood sugar diet"],
   "en":"Diabetic diet: ✅ Eat: vegetables (broccoli, spinach, carrots), whole grains (brown rice, oats), legumes, lean protein (fish, chicken), nuts. ❌ Avoid: white rice/bread/pasta, sugary drinks, sweets, processed foods. Eat small meals every 3-4 hours. 🥗",
   "hi":"मधुमेह आहार: ✅ खाएं: हरी सब्जियां, साबुत अनाज, दालें, मछली, नट्स। ❌ परहेज: सफेद चावल, मीठे पेय, मिठाई। हर 3-4 घंटे में थोड़ा खाएं। 🥗",
   "ne":"मधुमेह आहार: ✅ खानुहोस्: हरियो तरकारी, सम्पूर्ण अन्न, दाल। ❌ बेगर: सेतो भात, मीठो पेय। 🥗",
   "bho":"मधुमेह खाना: ✅ खावा: हरियर सब्जी, दाल, मछरी। ❌ बेगर: सफेद चावल, मीठा पेय। 🥗"},
  # Emergency
  {"id":"heart_attack","topic":"Heart Attack","intent":"EMERGENCY_QUERY","keywords":["heart attack","chest pain","dil ka dora","cardiac","chest tightness"],
   "en":"🚨 POSSIBLE HEART ATTACK! Symptoms: crushing chest pain, pain spreading to arm/jaw/back, sweating, shortness of breath, nausea.\n\nDO NOW:\n1. CALL 108 (India) / 102 (Nepal) IMMEDIATELY\n2. Chew 1 aspirin (325mg) if not allergic\n3. Lie down, loosen clothing\n4. Stay calm, don't eat or drink\n5. Unlock door for paramedics",
   "hi":"🚨 संभावित दिल का दौरा! अभी 108 पर कॉल करें। 1 एस्पिरिन चबाएं (अगर एलर्जी न हो)। लेट जाएं, कपड़े ढीले करें। शांत रहें।",
   "ne":"🚨 सम्भावित हृदयघात! अहिले 102 मा फोन गर्नुहोस्। 1 एस्पिरिन चपाउनुहोस्। सुत्नुहोस्, कपडा खुकुलो गर्नुहोस्।",
   "bho":"🚨 दिल के दौरा के संभावना! अभी 108 पर फोन करा। 1 एस्पिरिन चबावा। लेट जावा, कपड़ा ढीला करा।"},
  {"id":"stroke","topic":"Stroke","intent":"EMERGENCY_QUERY","keywords":["stroke","paralysis","face drooping","arm weakness","speech","nas ka dora"],
   "en":"🚨 POSSIBLE STROKE! Use FAST: Face drooping? Arm weakness? Speech slurred? Time to call 108!\n\nEvery minute counts — brain cells die without blood.\nDO NOT: give food/water, let them sleep it off.\nDO: call 108 immediately, note time symptoms started, keep them calm.",
   "hi":"🚨 संभावित स्ट्रोक! FAST जांचें: चेहरा टेढ़ा? बांह कमज़ोर? बोली अस्पष्ट? → अभी 108 कॉल करें! खाना-पानी न दें।",
   "ne":"🚨 सम्भावित स्ट्रोक! FAST जाँच गर्नुहोस्: मुहार लिरो? हात कमज़ोर? बोली अस्पष्ट? → अहिले 102 फोन गर्नुहोस्!",
   "bho":"🚨 स्ट्रोक के संभावना! FAST जाँच: मुँह टेढ़? हाथ कमज़ोर? बोली साफ नाहीं? → अभी 108 फोन करा!"},
]

def save_knowledge_json():
    """Always-available JSON knowledge base."""
    out = SAVED / "medical_knowledge.json"
    with open(out, "w", encoding="utf-8") as f:
        json.dump(MEDICAL_KNOWLEDGE, f, ensure_ascii=False, indent=2)
    log.info(f"✅ Medical knowledge JSON saved: {out} ({len(MEDICAL_KNOWLEDGE)} entries)")


def train_intent_classifier():
    """Train TF-IDF + Logistic Regression intent classifier."""
    try:
        from sklearn.feature_extraction.text import TfidfVectorizer
        from sklearn.linear_model import LogisticRegression
        import pickle

        X, y = [], []
        templates = [
            "{kw}", "I have {kw}", "what is {kw}", "tell me about {kw}",
            "help with {kw}", "I feel {kw}", "my {kw}", "suffering from {kw}",
            "{kw} problem", "{kw} treatment", "how to cure {kw}",
            "{kw} symptoms", "medicine for {kw}", "{kw} in children",
        ]

        # Add from keyword bank
        from ai_models.intent_classification.intent_classifier import _INTENT_KEYWORDS, Intent
        for intent, keywords in _INTENT_KEYWORDS.items():
            for kw in keywords:
                for tpl in templates:
                    X.append(tpl.format(kw=kw).lower())
                    y.append(intent.value)

        # Add from medical knowledge
        for item in MEDICAL_KNOWLEDGE:
            for kw in item["keywords"]:
                for tpl in templates[:6]:
                    X.append(tpl.format(kw=kw).lower())
                    y.append(item["intent"])

        vectorizer = TfidfVectorizer(ngram_range=(1, 3), max_features=25000, sublinear_tf=True)
        X_vec = vectorizer.fit_transform(X)

        from sklearn.preprocessing import LabelEncoder
        le = LabelEncoder()
        y_enc = le.fit_transform(y)

        model = LogisticRegression(max_iter=2000, C=2.0, class_weight="balanced", solver="lbfgs")
        model.fit(X_vec, y_enc)
        model.classes_ = le.classes_

        out = SAVED / "intent_classifier.pkl"
        with open(out, "wb") as f:
            pickle.dump({"vectorizer": vectorizer, "model": model, "label_encoder": le}, f)
        log.info(f"✅ Intent classifier trained: {out} ({len(X)} samples)")
        return True
    except ImportError:
        log.warning("scikit-learn not installed — skipping classifier training")
        log.warning("Install: pip install scikit-learn")
        return False


def build_faiss_index():
    """Build FAISS vector index for semantic search (optional)."""
    try:
        from sentence_transformers import SentenceTransformer
        import faiss, numpy as np

        log.info("Building FAISS index with sentence-transformers...")
        model = SentenceTransformer("all-MiniLM-L6-v2")

        texts = [f"{k['topic']}: {k['en']}" for k in MEDICAL_KNOWLEDGE]
        embeddings = model.encode(texts, show_progress_bar=True, convert_to_numpy=True)
        embeddings = embeddings.astype(np.float32)

        dim = embeddings.shape[1]
        index = faiss.IndexFlatL2(dim)
        index.add(embeddings)

        faiss.write_index(index, str(SAVED / "medical_knowledge.faiss"))

        meta = [{"id": k["id"], "topic": k["topic"], "intent": k["intent"]} for k in MEDICAL_KNOWLEDGE]
        with open(SAVED / "faiss_metadata.json", "w", encoding="utf-8") as f:
            json.dump(meta, f, ensure_ascii=False)

        log.info(f"✅ FAISS index built: {len(texts)} vectors, dim={dim}")
        return True
    except ImportError:
        log.info("sentence-transformers/faiss not installed — FAISS index skipped")
        log.info("Install: pip install sentence-transformers faiss-cpu")
        return False


if __name__ == "__main__":
    log.info("=" * 60)
    log.info("🏥 AI Medical Chatbot — Offline Training")
    log.info("=" * 60)
    save_knowledge_json()
    train_intent_classifier()
    build_faiss_index()
    log.info("=" * 60)
    log.info("✅ Training complete! Saved to: ai_models/saved_models/")
    log.info("=" * 60)
