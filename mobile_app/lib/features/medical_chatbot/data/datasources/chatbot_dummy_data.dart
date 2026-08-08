import '../models/chat_message_model.dart';
import '../models/chatbot_settings_model.dart';
import '../models/conversation_model.dart';
import '../models/language_model.dart';
import '../models/suggestion_model.dart';
import '../../domain/entities/chat_message.dart';

class ChatbotDummyData {
  // ── Languages ─────────────────────────────────────────────────────────────
  static const languages = [
    LanguageModel(code: 'en',  name: 'English',  nativeName: 'English',  flag: '🇬🇧'),
    LanguageModel(code: 'hi',  name: 'Hindi',    nativeName: 'हिंदी',    flag: '🇮🇳'),
    LanguageModel(code: 'ne',  name: 'Nepali',   nativeName: 'नेपाली',   flag: '🇳🇵'),
    LanguageModel(code: 'bho', name: 'Bhojpuri', nativeName: 'भोजपुरी',  flag: '🗣️'),
  ];

  static const settings = ChatbotSettingsModel(
    language: LanguageModel(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
  );

  static LanguageModel languageFromCode(String code) {
    return languages.firstWhere((l) => l.code == code, orElse: () => languages.first);
  }

  // ── Welcome message ───────────────────────────────────────────────────────
  static final welcomeMessage = ChatMessageModel(
    id: 'message-welcome',
    text: '🤖 **I\'m here to help with your health questions!**\n\n'
        'I can assist with:\n'
        '• 🤒 Symptoms and diseases\n'
        '• 💊 Medicine information\n'
        '• 🥗 Nutrition and diet advice\n'
        '• 🏃 Exercise recommendations\n'
        '• 🤰 Pregnancy guidance\n'
        '• 👶 Child healthcare\n'
        '• 🚨 Emergency guidance\n\n'
        'Please describe your symptoms or health question in detail so I can help you better.\n\n'
        '⚠️ _This AI provides general health information only. Always consult a qualified healthcare professional for medical advice._',
    sender: ChatSender.bot,
    createdAt: DateTime.now(),
  );

  // ── Online suggestions (8 quick starters shown by default) ───────────────
  static final suggestions = [
    const SuggestionModel(id: 's1',  text: '🤒 I have fever and cough',      category: 'Symptoms'),
    const SuggestionModel(id: 's2',  text: '🤕 What to do for headache?',    category: 'Care'),
    const SuggestionModel(id: 's3',  text: '💊 What is Paracetamol?',         category: 'Medicine'),
    const SuggestionModel(id: 's4',  text: '🥗 Foods for diabetes',           category: 'Nutrition'),
    const SuggestionModel(id: 's5',  text: '🤰 Pregnancy nutrition tips',     category: 'Pregnancy'),
    const SuggestionModel(id: 's6',  text: '👶 Child vaccination info',       category: 'Child'),
    const SuggestionModel(id: 's7',  text: '🚨 Heart attack symptoms',        category: 'Emergency'),
    const SuggestionModel(id: 's8',  text: '🧠 I feel stressed and anxious',  category: 'Mental Health'),
  ];

  // ── Offline suggestions — all 50 topics as chips ─────────────────────────
  static final offlineSuggestions = [
    const SuggestionModel(id: 'o01', text: '🚨 Heart attack / emergency',      category: 'Emergency'),
    const SuggestionModel(id: 'o02', text: '🌡️ I have fever',                  category: 'Symptoms'),
    const SuggestionModel(id: 'o03', text: '🤕 I have a headache',             category: 'Symptoms'),
    const SuggestionModel(id: 'o04', text: '😷 I have cough and cold',         category: 'Symptoms'),
    const SuggestionModel(id: 'o05', text: '🩺 I have diabetes',               category: 'Disease'),
    const SuggestionModel(id: 'o06', text: '💊 What is Paracetamol?',          category: 'Medicine'),
    const SuggestionModel(id: 'o07', text: '🧠 I feel stressed and anxious',   category: 'Mental Health'),
    const SuggestionModel(id: 'o08', text: '🤰 Pregnancy nutrition tips',      category: 'Pregnancy'),
    const SuggestionModel(id: 'o09', text: '🩺 High blood pressure guidance',  category: 'Disease'),
    const SuggestionModel(id: 'o10', text: '💨 I have asthma symptoms',        category: 'Disease'),
    const SuggestionModel(id: 'o11', text: '🦋 Thyroid health information',    category: 'Disease'),
    const SuggestionModel(id: 'o12', text: '🤢 Stomach pain and diarrhoea',    category: 'Symptoms'),
    const SuggestionModel(id: 'o13', text: '🧴 Skin rash and itching',         category: 'Symptoms'),
    const SuggestionModel(id: 'o14', text: '👁️ Red / itchy eyes',              category: 'Symptoms'),
    const SuggestionModel(id: 'o15', text: '🥗 Nutrition and diet advice',     category: 'Nutrition'),
    const SuggestionModel(id: 'o16', text: '👶 Child vaccination schedule',    category: 'Child'),
    const SuggestionModel(id: 'o17', text: '🦴 Joint pain and arthritis',      category: 'Disease'),
    const SuggestionModel(id: 'o18', text: '🩸 I feel weak — anaemia?',        category: 'Disease'),
    const SuggestionModel(id: 'o19', text: '🦷 Toothache and dental pain',     category: 'Symptoms'),
    const SuggestionModel(id: 'o20', text: '🏃 Exercise for weight loss',      category: 'Fitness'),
    const SuggestionModel(id: 'o21', text: '🧬 Cancer — warning signs',        category: 'Disease'),
    const SuggestionModel(id: 'o22', text: '🫀 High cholesterol foods',        category: 'Nutrition'),
    const SuggestionModel(id: 'o23', text: '🤧 Flu and influenza symptoms',    category: 'Symptoms'),
    const SuggestionModel(id: 'o24', text: '🧪 Typhoid fever symptoms',        category: 'Disease'),
    const SuggestionModel(id: 'o25', text: '🦟 Malaria and dengue fever',      category: 'Disease'),
    const SuggestionModel(id: 'o26', text: '💉 HIV and AIDS information',      category: 'Disease'),
    const SuggestionModel(id: 'o27', text: '🫁 Tuberculosis (TB) symptoms',    category: 'Disease'),
    const SuggestionModel(id: 'o28', text: '🧠 Epilepsy and seizures',         category: 'Disease'),
    const SuggestionModel(id: 'o29', text: '🫘 Kidney problems and stones',    category: 'Disease'),
    const SuggestionModel(id: 'o30', text: '🫀 Liver health and jaundice',     category: 'Disease'),
    const SuggestionModel(id: 'o31', text: '🤱 Breastfeeding guidance',        category: 'Child'),
    const SuggestionModel(id: 'o32', text: '🧒 Puberty health information',    category: 'Adolescent'),
    const SuggestionModel(id: 'o33', text: '👴 Elderly health and care',       category: 'Elderly'),
    const SuggestionModel(id: 'o34', text: '💊 Vitamin deficiency symptoms',   category: 'Nutrition'),
    const SuggestionModel(id: 'o35', text: '🌞 Dehydration symptoms',          category: 'Symptoms'),
    const SuggestionModel(id: 'o36', text: '🔥 Burns and wound first aid',     category: 'First Aid'),
    const SuggestionModel(id: 'o37', text: '🐍 Snakebite and poisoning',       category: 'Emergency'),
    const SuggestionModel(id: 'o38', text: '🦴 Fracture and sprain care',      category: 'First Aid'),
    const SuggestionModel(id: 'o39', text: '😴 I feel very tired and weak',    category: 'Symptoms'),
    const SuggestionModel(id: 'o40', text: '🤧 Sinusitis and sinus pain',      category: 'Symptoms'),
    const SuggestionModel(id: 'o41', text: '💧 ORS and rehydration salts',     category: 'Medicine'),
    const SuggestionModel(id: 'o42', text: '🏥 Basic first aid steps',         category: 'First Aid'),
    const SuggestionModel(id: 'o43', text: '🦠 COVID-19 symptoms and care',    category: 'Disease'),
    const SuggestionModel(id: 'o44', text: '🦠 Wound infection signs',         category: 'Symptoms'),
    const SuggestionModel(id: 'o45', text: '🩹 How to clean a wound',          category: 'First Aid'),
    const SuggestionModel(id: 'o46', text: '🩸 Menstrual pain and periods',    category: 'Women'),
    const SuggestionModel(id: 'o47', text: '🫀 Heart palpitations',            category: 'Symptoms'),
    const SuggestionModel(id: 'o48', text: '🦶 Swollen feet and ankles',       category: 'Symptoms'),
    const SuggestionModel(id: 'o49', text: '💧 Urinary tract infection (UTI)', category: 'Disease'),
    const SuggestionModel(id: 'o50', text: '🤖 What can you help me with?',    category: 'General'),
  ];

  // ── Conversation scaffolding ──────────────────────────────────────────────
  static ConversationModel initialConversation() {
    return ConversationModel(
      id: 'conversation-current',
      title: 'New Consultation',
      messages: [welcomeMessage],
      updatedAt: DateTime.now(),
    );
  }

  static List<ConversationModel> initialHistory() {
    return [
      ConversationModel(
        id: 'history-1',
        title: '🤒 Fever and cough',
        messages: [welcomeMessage],
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ConversationModel(
        id: 'history-2',
        title: '💊 Medicine information',
        messages: [welcomeMessage],
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OFFLINE RESPONSE ENGINE — 50 structured topic handlers
  // Used as fallback when device has no network connectivity.
  // Each response follows the format:
  //   TITLE → Overview → Sections (What to do / Medicines / Warning signs) → Disclaimer
  // ═══════════════════════════════════════════════════════════════════════════
  static String responseFor(String message) {
    final q = message.toLowerCase().trim();

    // ─────────────────────────────────────────────────────────────────────
    // 01. EMERGENCY (highest priority — checked first)
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('emergency') || q.contains('heart attack') ||
        q.contains('chest pain') || q.contains('stroke') ||
        q.contains('unconscious') || q.contains('not breathing') ||
        q.contains('seizure') || q.contains('convulsion') ||
        q.contains('seizing') || q.contains('haemorrhage') ||
        q.contains('heavy bleeding')) {
      return '🚨 **MEDICAL EMERGENCY — ACT IMMEDIATELY**\n\n'
          '**Call emergency services NOW:**\n'
          '• 🇮🇳 India: **108** (Ambulance) | **112** (Universal)\n'
          '• 🇳🇵 Nepal: **102** (Ambulance) | **100** (Police)\n\n'
          '**While waiting for help:**\n'
          '• Keep the person calm and still\n'
          '• Loosen tight clothing around neck and chest\n'
          '• Do NOT give food or water\n'
          '• If unconscious and breathing → recovery position (on side)\n'
          '• If not breathing → start CPR: 30 chest compressions + 2 rescue breaths\n'
          '• For severe bleeding → apply firm direct pressure with cloth\n\n'
          '⚠️ **Do not wait. Every second counts. Call 108 now.**\n\n'
          '_This AI cannot replace emergency care._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 02. FEVER
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('fever') || q.contains('bukhar') || q.contains('bukhaar') ||
        q.contains('jwaro') || q.contains('taato') || q.contains('temperature')) {
      return '🌡️ **Fever**\n\n'
          '**Normal:** 36.1–37.2°C | **Fever:** ≥ 38°C (100.4°F)\n\n'
          '**What to do:**\n'
          '• Rest and drink plenty of fluids (water, ORS, coconut water, soup)\n'
          '• Take Paracetamol 500 mg if temperature > 38.5°C\n'
          '• Wear light, breathable clothing\n'
          '• Place a cool damp cloth on the forehead\n'
          '• Avoid heavy blankets — they trap heat\n\n'
          '**Common causes:** Flu, cold, COVID-19, typhoid, malaria, UTI\n\n'
          '**Medicines (adult):**\n'
          '• Paracetamol 500 mg every 4–6 hrs (max 4 g/day)\n'
          '• Avoid Aspirin in children under 16\n\n'
          '🚨 **See a doctor immediately if:**\n'
          '• Temperature > 39.5°C (103°F)\n'
          '• Fever in a baby under 3 months\n'
          '• Fever with rash, stiff neck, or confusion\n'
          '• Fever not improving after 3 days\n\n'
          '_Always consult a healthcare professional for diagnosis._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 03. HEADACHE / MIGRAINE
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('headache') || q.contains('sar dard') || q.contains('sir dard') ||
        q.contains('टाउको') || q.contains('migraine') || q.contains('matha dukhai') ||
        q.contains('head pain')) {
      return '🤕 **Headache & Migraine**\n\n'
          '**Immediate relief:**\n'
          '• Drink 2–3 glasses of water (dehydration is a top cause)\n'
          '• Rest in a quiet, dark, cool room\n'
          '• Apply a cold compress to forehead or warm compress to neck\n'
          '• Avoid screens and bright lights\n'
          '• Gently massage temples in circular motion\n\n'
          '**Medicines (adult):**\n'
          '• Paracetamol 500 mg or Ibuprofen 400 mg with food\n'
          '• For migraine: take medicine at first sign of aura\n\n'
          '**Common triggers:** Dehydration, stress, skipped meals, poor sleep, screen time, caffeine withdrawal\n\n'
          '🚨 **Seek emergency care for:**\n'
          '• Sudden severe "thunderclap" headache (worst ever)\n'
          '• Headache with fever + stiff neck (possible meningitis)\n'
          '• Headache with vision loss, slurred speech, or weakness\n'
          '• Headache after a head injury\n\n'
          '_Consult a doctor for recurring or worsening headaches._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 04. COUGH / COLD
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('cough') || q.contains('khasi') || q.contains('khansi') ||
        q.contains('cold') || q.contains('sardi') || q.contains('runny nose') ||
        q.contains('nasal') || q.contains('sneezing') || q.contains('sore throat') ||
        q.contains('throat') || q.contains('khana') && q.contains('naak')) {
      return '😷 **Cough & Cold**\n\n'
          '**Home remedies:**\n'
          '• Honey + warm water or ginger tea — soothes throat\n'
          '• Steam inhalation (bowl of hot water + towel) — relieves congestion\n'
          '• Warm saline gargle — relieves throat pain\n'
          '• Saline nasal drops — clears blocked nose\n'
          '• Stay hydrated — warm fluids thin mucus\n'
          '• Avoid cold drinks, smoke, and dusty environments\n\n'
          '**Medicines (adult):**\n'
          '• Paracetamol — for fever and throat pain\n'
          '• Cetrizine 10 mg — for runny nose and sneezing\n'
          '• Cough syrup: dry cough → suppressant; wet cough → expectorant\n\n'
          '🚨 **See a doctor if:**\n'
          '• Cough lasts more than 2 weeks\n'
          '• Blood or yellow/green mucus in cough\n'
          '• Difficulty breathing or chest pain\n'
          '• High fever above 38.5°C\n\n'
          '_Persistent cough may indicate TB, asthma, or GERD._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 05. DIABETES
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('diabetes') || q.contains('sugar') || q.contains('madhumeha') ||
        q.contains('blood sugar') || q.contains('insulin') || q.contains('glucose') ||
        q.contains('diabetic')) {
      return '🩺 **Diabetes**\n\n'
          '**Blood sugar reference:**\n'
          '• Normal fasting: 70–100 mg/dL\n'
          '• Pre-diabetes: 100–125 mg/dL\n'
          '• Diabetes: ≥ 126 mg/dL (fasting)\n\n'
          '**Types:**\n'
          '• Type 1 — immune system destroys insulin-producing cells\n'
          '• Type 2 — body resists insulin (most common, lifestyle-related)\n'
          '• Gestational — during pregnancy (usually resolves after delivery)\n\n'
          '**Daily management:**\n'
          '• Monitor blood sugar regularly (before meals and 2 hrs after)\n'
          '• Take prescribed medicines or insulin consistently\n'
          '• Exercise 30 min/day (brisk walking is excellent)\n'
          '• Eat 3 small balanced meals + 2 healthy snacks\n\n'
          '🥗 **Prefer:** Leafy greens, whole grains, lentils, fish, nuts, curd\n'
          '❌ **Avoid:** Sugary drinks, white rice/bread, sweets, fried food, alcohol\n\n'
          '⚠️ **Low sugar (hypoglycemia) signs:** Shaking, sweating, confusion\n'
          '→ Eat sugar immediately: glucose tablet, juice, or 2 tsp sugar in water\n\n'
          '_Always follow your doctor\'s treatment plan._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 06. MEDICINES
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('paracetamol') || q.contains('ibuprofen') || q.contains('medicine') ||
        q.contains('tablet') || q.contains('dawai') || q.contains('dawa') ||
        q.contains('antibiotic') || q.contains('antacid') || q.contains('drug') ||
        q.contains('dosage') || q.contains('dose')) {
      return '💊 **Common Medicines Guide**\n\n'
          '**Paracetamol (Crocin / Dolo 650):**\n'
          '• For: Fever, mild–moderate pain, headache\n'
          '• Adult dose: 500 mg–1 g every 4–6 hrs (max 4 g/day)\n'
          '• Child dose: 15 mg/kg every 6 hrs\n'
          '• ⚠️ Avoid with liver disease or alcohol\n\n'
          '**Ibuprofen (Brufen / Advil):**\n'
          '• For: Pain, inflammation, menstrual cramps, fever\n'
          '• Adult dose: 400 mg every 6–8 hrs with food\n'
          '• ⚠️ Avoid with kidney disease, peptic ulcer, or in pregnancy\n\n'
          '**ORS (Oral Rehydration Salts):**\n'
          '• For: Diarrhoea, vomiting, dehydration\n'
          '• Mix 1 sachet in 1 litre boiled & cooled water; sip frequently\n\n'
          '**Antacids (Gelusil / Digene / Ranitidine):**\n'
          '• For: Acidity, heartburn, gas, indigestion\n'
          '• Take 30 min after meals or as needed\n\n'
          '**Cetrizine 10 mg:**\n'
          '• For: Allergies, runny nose, itching, hives\n'
          '• Adult: 1 tablet once daily (may cause drowsiness)\n\n'
          '⚠️ **Never self-medicate with antibiotics.**\n'
          'Complete the full prescribed course even if you feel better.\n\n'
          '_Consult a pharmacist or doctor before starting any new medicine._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 07. MENTAL HEALTH / STRESS / SLEEP
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('stress') || q.contains('anxious') || q.contains('anxiety') ||
        q.contains('depression') || q.contains('lonely') || q.contains('sad') ||
        q.contains('mental') || q.contains('panic') || q.contains('sleep') ||
        q.contains('insomnia') || q.contains('neend') || q.contains('worry') ||
        q.contains('overthink') || q.contains('nind nahi')) {
      return '💙 **Mental Health & Sleep**\n\n'
          '**Immediate coping strategies:**\n'
          '• Take 5 slow deep breaths: 4 sec in → hold 4 → breathe out 6\n'
          '• Go for a 10-minute walk in fresh air\n'
          '• Talk to someone you trust\n'
          '• Write down what you\'re feeling in a journal\n'
          '• Limit news and social media for a few hours\n\n'
          '**For better sleep:**\n'
          '• Go to bed and wake up at the same time every day\n'
          '• No screens 1 hour before bed\n'
          '• Keep bedroom dark, cool, and quiet\n'
          '• Avoid caffeine after 3 PM\n'
          '• Try 10 min relaxation: deep breathing or light stretching\n\n'
          '**Signs you need professional help:**\n'
          '• Persistent sadness for > 2 weeks\n'
          '• Sleep problems lasting > 1 month\n'
          '• Thoughts of self-harm\n\n'
          '**Helplines:**\n'
          '• iCall India: **9152987821**\n'
          '• Vandrevala Foundation: **1860-2662-345** (24/7)\n'
          '• Nepal: **1166** (Mental health helpline)\n\n'
          '_Your mental health matters as much as your physical health._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 08. PREGNANCY
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('pregnancy') || q.contains('pregnant') || q.contains('garbhwati') ||
        q.contains('prasav') || q.contains('garbha') || q.contains('delivery') ||
        q.contains('labour') || q.contains('antenatal') || q.contains('prenatal')) {
      return '🤰 **Pregnancy Health**\n\n'
          '**Essential nutrition:**\n'
          '• Folic acid — first trimester (prevents neural tube defects)\n'
          '• Iron — spinach, lentils, meat, fortified cereals (prevents anaemia)\n'
          '• Calcium — milk, yogurt, paneer, dark green vegetables\n'
          '• Protein — dal, eggs, fish, chicken, tofu\n'
          '• Water — 8–10 glasses daily\n\n'
          '**Safe habits:**\n'
          '• Attend all antenatal checkups (minimum 4 visits)\n'
          '• Light walking is safe and beneficial throughout pregnancy\n'
          '• Avoid alcohol, tobacco, raw fish, undercooked meat\n'
          '• Take only doctor-prescribed medicines\n'
          '• Sleep on your left side (improves blood flow after 20 weeks)\n\n'
          '🚨 **See a doctor immediately for:**\n'
          '• Severe abdominal pain or cramping\n'
          '• Heavy vaginal bleeding\n'
          '• Severe headache + swollen face/hands (pre-eclampsia)\n'
          '• Baby not moving after 28 weeks\n'
          '• Water breaking (membranes rupturing)\n\n'
          '_Regular prenatal checkups and iron-folic acid tablets save lives._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 09. BLOOD PRESSURE
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('blood pressure') || q.contains('hypertension') || q.contains('bp') ||
        q.contains('dawab') || q.contains('high bp') || q.contains('low bp') ||
        q.contains('hypotension') || q.contains('pressure')) {
      return '🩺 **Blood Pressure**\n\n'
          '**Reference ranges:**\n'
          '• Normal: below **120/80 mmHg**\n'
          '• High (Hypertension): **≥ 140/90 mmHg**\n'
          '• Low (Hypotension): below **90/60 mmHg**\n\n'
          '**For High BP — lifestyle changes:**\n'
          '• 🧂 Reduce salt intake (< 5 g/day — about 1 tsp)\n'
          '• 🏃 Exercise 30 min/day (brisk walking)\n'
          '• 🚫 Quit smoking and limit alcohol\n'
          '• 😴 Sleep 7–8 hours per night\n'
          '• 🥗 DASH diet: fruits, vegetables, whole grains, low-fat dairy\n'
          '• 😌 Manage stress (yoga, meditation, deep breathing)\n\n'
          '**For Low BP:**\n'
          '• Drink more water and add a pinch of extra salt\n'
          '• Eat small, frequent meals\n'
          '• Rise slowly from sitting or lying — avoid sudden position changes\n'
          '• Avoid standing for long periods in heat\n\n'
          '🚨 **Emergency signs:** Severe headache, blurred vision, chest pain, fainting\n'
          '→ Call **108** immediately\n\n'
          '_Never stop BP medication without your doctor\'s advice._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 10. ASTHMA
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('asthma') || q.contains('inhaler') || q.contains('wheezing') ||
        q.contains('breathless') || q.contains('shortness of breath') || q.contains('dam') ||
        q.contains('breathing difficulty') || q.contains('saans')) {
      return '💨 **Asthma**\n\n'
          '**During an asthma attack:**\n'
          '• Sit upright — do NOT lie down\n'
          '• Stay calm and breathe slowly through pursed lips\n'
          '• Use your reliever inhaler (**blue** — Salbutamol): 1 puff every minute, up to 10\n'
          '• Call **108** if no improvement after 10 puffs\n\n'
          '**Daily prevention:**\n'
          '• Use preventer inhaler (brown/purple — Budesonide) as prescribed, even when well\n'
          '• Check peak flow meter regularly\n'
          '• Always carry your reliever inhaler\n\n'
          '**Trigger avoidance:**\n'
          '• Dust mites → use dust-proof mattress covers, vacuum weekly\n'
          '• Pollen → close windows during high pollen times\n'
          '• Smoke, cold air, strong smells, pet dander — all common triggers\n'
          '• Avoid exercising in cold, dry air; warm up slowly\n\n'
          '🚨 **Emergency:** Unable to speak full sentences, lips turning blue → Call 108\n\n'
          '_Never stop inhalers without doctor\'s guidance._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 11. THYROID
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('thyroid') || q.contains('hypothyroid') || q.contains('hyperthyroid') ||
        q.contains('tsh') || q.contains('levothyroxine') || q.contains('goitre')) {
      return '🦋 **Thyroid Health**\n\n'
          '**Hypothyroidism (underactive):**\n'
          '• Symptoms: Fatigue, weight gain, cold intolerance, dry skin, hair loss, depression, slow heart rate\n'
          '• Treatment: Levothyroxine tablet — take on empty stomach, same time daily\n\n'
          '**Hyperthyroidism (overactive):**\n'
          '• Symptoms: Weight loss, rapid heartbeat, sweating, anxiety, tremors, bulging eyes\n'
          '• Treatment: Antithyroid drugs or radioiodine (doctor-prescribed)\n\n'
          '**Lifestyle tips:**\n'
          '• Get TSH levels checked every 6–12 months\n'
          '• Eat iodine-rich foods: seafood, dairy, iodised salt\n'
          '• If hypothyroid: limit raw cabbage, broccoli, soy (can block thyroid)\n'
          '• Take medication consistently — even one missed dose affects levels\n\n'
          '⚠️ **Do not adjust thyroid dose yourself** — always check with your doctor.\n\n'
          '_Thyroid conditions are very manageable with proper medication._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 12. STOMACH / DIGESTIVE
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('diarrhea') || q.contains('diarrhoea') || q.contains('loose motion') ||
        q.contains('vomit') || q.contains('nausea') || q.contains('stomach') ||
        q.contains('abdomen') || q.contains('acidity') || q.contains('gastric') ||
        q.contains('ulcer') || q.contains('pet dard') || q.contains('indigestion') ||
        q.contains('heartburn') || q.contains('gas')) {
      return '🤢 **Stomach & Digestive Issues**\n\n'
          '**For diarrhoea / loose motions:**\n'
          '• ORS (oral rehydration salts): 1 sachet in 1 litre boiled water — sip every few minutes\n'
          '• Eat light: boiled rice, banana, toast, boiled potato\n'
          '• Avoid dairy, spicy food, oily food, raw vegetables\n'
          '• Zinc tablets 20 mg/day for 10–14 days (children) reduces severity\n\n'
          '**For vomiting / nausea:**\n'
          '• Sip small amounts of water or ORS every 5–10 minutes\n'
          '• Ginger tea or ginger candy helps settle nausea\n'
          '• Avoid solid food until vomiting stops for 2 hours\n\n'
          '**For acidity / heartburn / gas:**\n'
          '• Eat smaller, more frequent meals\n'
          '• Avoid spicy, fried, acidic foods (citrus, tomatoes)\n'
          '• Antacid (Gelusil / Digene) 30 min after meals\n'
          '• Don\'t lie down within 2 hours of eating\n'
          '• Elevate the head of your bed slightly\n\n'
          '🚨 **See a doctor if:**\n'
          '• Blood in stool or vomit\n'
          '• Diarrhoea more than 3 days\n'
          '• Signs of severe dehydration: dry mouth, dark urine, dizziness, no tears\n\n'
          '_Dehydration is the main danger — keep drinking ORS._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 13. SKIN / ALLERGY / RASH
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('rash') || q.contains('skin') || q.contains('itch') ||
        q.contains('allergy') || q.contains('hives') || q.contains('urticaria') ||
        q.contains('eczema') || q.contains('khujli') || q.contains('fungal') ||
        q.contains('ringworm') || q.contains('pimple') || q.contains('acne') ||
        q.contains('psoriasis')) {
      return '🧴 **Skin & Allergy**\n\n'
          '**For mild rash / itching (urticaria):**\n'
          '• Apply calamine lotion or a cool compress\n'
          '• Cetrizine 10 mg (antihistamine) for allergic itch\n'
          '• Avoid scratching — keep nails clean and short\n'
          '• Use mild, fragrance-free soap\n\n'
          '**For fungal infection (ringworm, athlete\'s foot, jock itch):**\n'
          '• Keep area clean and completely dry\n'
          '• Apply Clotrimazole 1% cream twice daily for 2–4 weeks\n'
          '• Wear loose, breathable cotton clothing\n'
          '• Do not share towels or clothing\n\n'
          '**For eczema:**\n'
          '• Moisturise at least twice daily with unscented lotion\n'
          '• Avoid known triggers: soaps, sweat, dust, certain foods\n'
          '• Doctor may prescribe mild steroid cream for flares\n\n'
          '**For acne:**\n'
          '• Wash face twice daily with gentle cleanser\n'
          '• Avoid touching face; change pillow cover frequently\n'
          '• Benzoyl peroxide or Salicylic acid gel (OTC) for mild acne\n\n'
          '🚨 **See a doctor immediately if:**\n'
          '• Rash spreads rapidly over the whole body\n'
          '• Rash with difficulty breathing (anaphylaxis) → Call 108\n'
          '• Fever + rash (could be dengue, chickenpox, measles)\n'
          '• Blisters, open sores, or skin peeling\n\n'
          '_Most mild rashes improve with basic care within a week._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 14. EYE PROBLEMS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('eye') || q.contains('vision') || q.contains('blurry') ||
        q.contains('conjunctivitis') || q.contains('pink eye') || q.contains('ankh') ||
        q.contains('आँख') || q.contains('eyesight') || q.contains('watery eye')) {
      return '👁️ **Eye Health**\n\n'
          '**Red / itchy / watery eyes (conjunctivitis):**\n'
          '• Clean eyes by flushing with clean cool water\n'
          '• Apply a cold compress over closed eyelids\n'
          '• Do NOT share towels, pillows, or eye drops\n'
          '• Avoid touching eyes with unwashed hands\n'
          '• Antibiotic drops (e.g. Tobramycin) if bacterial — doctor prescribed\n\n'
          '**Eye strain from screens:**\n'
          '• 20-20-20 rule: every 20 min, look at something 20 feet away for 20 sec\n'
          '• Reduce screen brightness; match room lighting\n'
          '• Use lubricating / artificial tear drops (OTC)\n'
          '• Position screen slightly below eye level\n\n'
          '**Stye (painful red bump on eyelid):**\n'
          '• Apply warm compress 3–4 times/day for 10 minutes\n'
          '• Do NOT squeeze or pop\n\n'
          '🚨 **See a doctor immediately for:**\n'
          '• Sudden loss of vision\n'
          '• Severe eye pain\n'
          '• Eye injury or foreign object stuck\n'
          '• Flashes of light, floaters, or curtain-like shadow\n'
          '• Chemical splash → rinse with running water for 15 min then go to ER\n\n'
          '_Never rub an injured eye. Cover gently and seek care immediately._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 15. NUTRITION / DIET
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('nutrition') || q.contains('diet') || q.contains('food') ||
        q.contains('weight') || q.contains('vitamin') || q.contains('khana') ||
        q.contains('bhojan') || q.contains('healthy eating') || q.contains('balanced')) {
      return '🥗 **Nutrition & Diet**\n\n'
          '**The balanced plate (per meal):**\n'
          '• 🌾 Half: Whole grains — rice, roti, oats, millets\n'
          '• 🥦 Quarter: Vegetables — all colours, leafy greens\n'
          '• 🍗 Quarter: Protein — dal, eggs, fish, chicken, tofu, paneer\n'
          '• 🥛 Dairy: 2 servings/day — milk, curd, cheese\n'
          '• 🫙 Fats: Small amounts of nuts, seeds, ghee, olive oil\n\n'
          '**Key vitamins & best food sources:**\n'
          '• Vitamin C → amla, guava, lemon, bell pepper, tomatoes\n'
          '• Iron → spinach, lentils, jaggery, meat, sesame seeds\n'
          '• Calcium → milk, ragi, sesame, paneer, broccoli\n'
          '• Vitamin D → sunlight 15 min/day, eggs, fish, fortified milk\n'
          '• Vitamin B12 → meat, fish, eggs, dairy (vegans need supplements)\n\n'
          '**Healthy eating habits:**\n'
          '• Eat 3 meals + 1–2 healthy snacks at regular times\n'
          '• Drink 8 glasses of water daily\n'
          '• Avoid ultra-processed and deep-fried foods\n'
          '• Limit added sugar and salt\n'
          '• Exercise 30 min/day at least 5 days a week\n\n'
          '_Small, consistent changes give lasting health results._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 16. CHILD HEALTH / VACCINATION
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('child') || q.contains('vaccination') || q.contains('vaccine') ||
        q.contains('bachha') || q.contains('infant') || q.contains('toddler') ||
        q.contains('newborn') || q.contains('टीकाकरण') || q.contains('immunisation') ||
        q.contains('baby fever') || q.contains('child health')) {
      return '👶 **Child Health & Vaccination**\n\n'
          '**Key vaccines (India / Nepal national schedule):**\n'
          '• Birth: BCG, Hepatitis B (dose 1), OPV-0\n'
          '• 6 weeks: DPT, OPV-1, Hib, Rotavirus, Hep B (dose 2)\n'
          '• 10 & 14 weeks: DPT, OPV, Hib, Rotavirus (doses 2 & 3)\n'
          '• 9 months: Measles/MR vaccine\n'
          '• 15–18 months: DPT booster, MMR, OPV booster\n'
          '• 5–6 years: DPT booster\n\n'
          '**Child fever — key rules:**\n'
          '• Baby under 3 months with any fever → doctor immediately\n'
          '• Paracetamol dose: **15 mg/kg** every 6 hours (check weight on label)\n'
          '• Never give Aspirin to children — risk of Reye\'s syndrome\n\n'
          '**Signs a child needs urgent care:**\n'
          '• Not drinking fluids for 6+ hours\n'
          '• Unusual drowsiness, hard to wake\n'
          '• Rapid or laboured breathing\n'
          '• Rash with fever\n'
          '• Bulging fontanelle (soft spot) in infants\n\n'
          '_Keep your child\'s immunisation card updated and safe._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 17. JOINT PAIN / ARTHRITIS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('joint') || q.contains('arthritis') || q.contains('knee pain') ||
        q.contains('back pain') || q.contains('jodo') || q.contains('ghutna') ||
        q.contains('bones') || q.contains('gout') || q.contains('rheumatoid') ||
        q.contains('osteoporosis') || q.contains('joint pain')) {
      return '🦴 **Joint Pain & Arthritis**\n\n'
          '**Types:**\n'
          '• Osteoarthritis — wear-and-tear of cartilage (common in elderly, knees, hips)\n'
          '• Rheumatoid arthritis — immune system attacks joints (morning stiffness, symmetric)\n'
          '• Gout — uric acid crystals in joints (severe pain, often big toe, red swollen)\n\n'
          '**Relief measures:**\n'
          '• Apply warm compress for chronic stiffness; cold compress for acute swelling\n'
          '• Ibuprofen 400 mg with food for pain (short-term)\n'
          '• Rest the joint when acutely inflamed — do NOT push through sharp pain\n'
          '• Physiotherapy exercises strengthen supporting muscles\n\n'
          '**Long-term management:**\n'
          '• Maintain healthy weight — every kg reduces knee joint load by 3–4 kg\n'
          '• Low-impact exercise: swimming, cycling, yoga, water aerobics\n'
          '• Calcium + Vitamin D supplements (especially after 40)\n'
          '• For gout: avoid red meat, organ meats, shellfish, alcohol, sugary drinks\n\n'
          '🚨 **See a doctor if:**\n'
          '• Joint is hot, red, severely swollen (possible infection or gout attack)\n'
          '• Pain is constant, worse at night, or disrupting sleep\n'
          '• You have fever with joint pain\n\n'
          '_Do not self-medicate long-term with anti-inflammatories — they can damage kidneys._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 18. ANAEMIA / IRON DEFICIENCY
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('anaemia') || q.contains('anemia') || q.contains('weak') ||
        q.contains('pale') || q.contains('iron') || q.contains('haemoglobin') ||
        q.contains('hemoglobin') || q.contains('blood deficiency') || q.contains('khoon ki kami')) {
      return '🩸 **Anaemia (Low Haemoglobin)**\n\n'
          '**Normal Hb levels:**\n'
          '• Men: > 13 g/dL | Women: > 12 g/dL | Pregnant: > 11 g/dL\n\n'
          '**Symptoms:**\n'
          'Fatigue, weakness, pale skin/gums/nails, shortness of breath on exertion,\n'
          'dizziness, cold hands and feet, rapid heartbeat, headache\n\n'
          '**Iron-rich foods (eat daily):**\n'
          '• 🥬 Green leafy vegetables: spinach, methi (fenugreek), amaranth\n'
          '• 🫘 Lentils, rajma (kidney beans), chickpeas\n'
          '• 🌾 Ragi, jowar, fortified cereals\n'
          '• 🥩 Lean meat, chicken, fish, liver\n'
          '• 🌰 Pumpkin seeds, sesame seeds, jaggery\n\n'
          '**Boost iron absorption:**\n'
          '• Eat iron-rich foods WITH Vitamin C (lemon juice, amla, tomato)\n'
          '• Avoid tea and coffee 1 hour before/after iron-rich meals (blocks absorption)\n\n'
          '**Iron supplements:**\n'
          '• Take on empty stomach or with Vitamin C juice\n'
          '• Common side effect: dark stools, constipation — normal\n\n'
          '🚨 **See a doctor if:**\n'
          '• Hb drops below 8 g/dL (severe anaemia)\n'
          '• Chest pain or extreme breathlessness\n\n'
          '_All pregnant women and children under 5 should take iron supplements._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 19. DENTAL / TOOTHACHE
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('tooth') || q.contains('dental') || q.contains('toothache') ||
        q.contains('dant') || q.contains('gum') || q.contains('cavity') ||
        q.contains('molar') || q.contains('tooth pain') || q.contains('dant dard')) {
      return '🦷 **Dental & Oral Health**\n\n'
          '**For toothache — immediate relief:**\n'
          '• Take Ibuprofen 400 mg or Paracetamol 500 mg with food\n'
          '• Rinse with warm salt water (1 tsp salt in 1 glass water)\n'
          '• Apply clove oil (eugenol) on a cotton ball to the painful tooth\n'
          '• Avoid very hot, cold, or sweet foods on the affected side\n'
          '• Do NOT put Aspirin directly on the gum — it causes chemical burns\n\n'
          '**Daily oral hygiene:**\n'
          '• Brush teeth TWICE daily (morning and before bed) for 2 minutes\n'
          '• Floss once daily to remove food between teeth\n'
          '• Use fluoride toothpaste\n'
          '• Replace toothbrush every 3 months\n'
          '• Limit sugar intake — feeds cavity-causing bacteria\n\n'
          '**Gum disease (gingivitis/periodontitis):**\n'
          '• Signs: bleeding gums, bad breath, swollen red gums\n'
          '• Use a soft-bristle brush; massage gums gently\n'
          '• Warm saline rinses twice daily\n\n'
          '🚨 **See a dentist immediately for:**\n'
          '• Dental abscess (swollen jaw, severe pain, fever)\n'
          '• Knocked-out permanent tooth → keep in milk, see dentist within 1 hour\n\n'
          '_Visit a dentist every 6 months for check-up and cleaning._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 20. EXERCISE / FITNESS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('exercise') || q.contains('fitness') || q.contains('workout') ||
        q.contains('vyayam') || q.contains('weight loss') || q.contains('gym') ||
        q.contains('running') || q.contains('yoga') || q.contains('physical activity')) {
      return '🏃 **Exercise & Fitness**\n\n'
          '**WHO recommended physical activity:**\n'
          '• Adults: 150–300 min of moderate activity per week\n'
          '• Children 5–17: At least 60 min/day of moderate to vigorous activity\n'
          '• Muscle-strengthening: 2+ days per week\n\n'
          '**Best exercises for beginners:**\n'
          '• 🚶 Brisk walking — easiest, no equipment, suits all ages\n'
          '• 🏊 Swimming — great for joints (arthritis, obesity)\n'
          '• 🧘 Yoga — flexibility, stress relief, balance\n'
          '• 🚴 Cycling — cardio without joint stress\n'
          '• 💪 Bodyweight: squats, push-ups, planks at home\n\n'
          '**For weight loss:**\n'
          '• Combine cardio (walking, jogging) + strength training\n'
          '• Calorie deficit: burn more than you eat — even 300 cal/day deficit works\n'
          '• Consistency beats intensity — 30 min daily is better than 2 hrs once a week\n\n'
          '**Safe exercise tips:**\n'
          '• Always warm up 5 min and cool down 5 min\n'
          '• Stay hydrated — drink water before, during, and after\n'
          '• Stop if you feel chest pain, dizziness, or extreme breathlessness\n\n'
          '_Exercise is medicine — it reduces risk of diabetes, BP, depression, and cancer._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 21. CANCER AWARENESS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('cancer') || q.contains('tumour') || q.contains('tumor') ||
        q.contains('malignant') || q.contains('chemotherapy') || q.contains('biopsy') ||
        q.contains('cervical') || q.contains('breast cancer') || q.contains('kansara')) {
      return '🧬 **Cancer — Awareness & Early Warning Signs**\n\n'
          '**Common cancer warning signs (CAUTION):**\n'
          '• Change in bowel or bladder habits\n'
          '• A sore that does not heal\n'
          '• Unusual bleeding or discharge\n'
          '• Thickening or lump in breast, testicle, or anywhere\n'
          '• Indigestion or difficulty swallowing\n'
          '• Obvious change in a wart or mole\n'
          '• Nagging cough or hoarseness\n'
          '• Unexplained weight loss > 5 kg in < 3 months\n\n'
          '**Most common cancers in South Asia:**\n'
          '• Cervical cancer → prevented by HPV vaccine + Pap smear every 3 years\n'
          '• Breast cancer → self-examine monthly; mammogram after 40\n'
          '• Oral cancer → avoid tobacco (smoked and smokeless), alcohol, betel nut\n'
          '• Colorectal → colonoscopy after 50, high-fibre diet\n\n'
          '**Prevention:**\n'
          '• Quit tobacco in all forms\n'
          '• Limit alcohol\n'
          '• Maintain healthy weight and stay active\n'
          '• Eat 5 portions fruit & vegetables daily\n'
          '• Get recommended screenings and vaccines (HPV, Hepatitis B)\n\n'
          '🚨 **If you notice any warning signs, see a doctor immediately.**\n'
          '_Early detection dramatically improves survival rates._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 22. CHOLESTEROL
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('cholesterol') || q.contains('lipid') || q.contains('triglyceride') ||
        q.contains('hdl') || q.contains('ldl') || q.contains('fatty') || q.contains('statin')) {
      return '🫀 **Cholesterol**\n\n'
          '**Reference ranges:**\n'
          '• Total cholesterol: < 200 mg/dL (desirable)\n'
          '• LDL ("bad"): < 100 mg/dL | HDL ("good"): > 60 mg/dL\n'
          '• Triglycerides: < 150 mg/dL\n\n'
          '**Dietary changes:**\n'
          '• ✅ Eat: Oats, beans, flaxseed, fatty fish (omega-3), nuts, olive oil, fruits\n'
          '• ❌ Reduce: Fried food, red meat, full-fat dairy, trans fats, bakery items\n'
          '• ❌ Avoid: Vanaspati (partially hydrogenated oil), margarine\n\n'
          '**Lifestyle changes:**\n'
          '• Exercise 30 min/day — raises HDL and lowers LDL\n'
          '• Quit smoking — raises HDL\n'
          '• Limit alcohol\n'
          '• Lose excess weight — even 5% weight loss improves lipid profile\n\n'
          '**Medicines (if lifestyle isn\'t enough):**\n'
          '• Statins (Atorvastatin, Rosuvastatin) — prescribed by doctor\n'
          '• Take in the evening; report any muscle pain to doctor\n\n'
          '_High cholesterol has no symptoms — get a lipid profile test every 5 years after 20._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 23. FLU / INFLUENZA
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('flu') || q.contains('influenza') || q.contains('body ache') ||
        q.contains('chills') || q.contains('badan dard') || q.contains('viral fever')) {
      return '🤧 **Flu (Influenza)**\n\n'
          '**Symptoms (appear suddenly, more severe than a cold):**\n'
          'High fever (38–40°C), severe body aches, headache, chills, fatigue,\n'
          'dry cough, sore throat, runny nose, loss of appetite\n\n'
          '**Treatment (no antibiotic needed — it\'s viral):**\n'
          '• Rest — your body needs energy to fight the virus\n'
          '• Drink plenty of fluids: water, ORS, warm soup, herbal tea\n'
          '• Paracetamol for fever and body pain\n'
          '• Steam inhalation + saline nasal drops for congestion\n'
          '• Honey + ginger in warm water soothes throat\n\n'
          '**Recovery:** Most people recover in 7–10 days\n\n'
          '**Prevention:**\n'
          '• Annual flu vaccine (especially for elderly, children, pregnant women)\n'
          '• Wash hands frequently with soap for 20 seconds\n'
          '• Cover mouth/nose when coughing or sneezing\n'
          '• Avoid close contact with sick people\n\n'
          '🚨 **See a doctor if:**\n'
          '• Difficulty breathing or chest pain\n'
          '• Confusion, severe dizziness, or not waking\n'
          '• Fever lasting > 5 days or returning after improvement\n'
          '• Symptoms worsening after day 3\n\n'
          '_Antibiotics do NOT treat flu — they only work against bacteria._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 24. TYPHOID
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('typhoid') || q.contains('enteric fever') || q.contains('motiajwar') ||
        q.contains('widal') || q.contains('salmonella')) {
      return '🧪 **Typhoid Fever**\n\n'
          '**Symptoms (develop gradually over 1–2 weeks):**\n'
          'Prolonged high fever (39–40°C), severe headache, weakness, loss of appetite,\n'
          'stomach pain, constipation or diarrhoea, rose-coloured spots on chest/abdomen\n\n'
          '**Cause:** Salmonella Typhi bacteria — spread through contaminated water and food\n\n'
          '**Treatment (requires doctor and antibiotics):**\n'
          '• Complete the full antibiotic course (Azithromycin, Ciprofloxacin, or Cefixime)\n'
          '• Rest and drink plenty of fluids + ORS\n'
          '• Eat easily digestible food: rice, dal, khichdi, curd\n'
          '• Paracetamol for fever management\n\n'
          '**Prevention:**\n'
          '• Drink only boiled or treated/bottled water\n'
          '• Wash hands thoroughly before eating and after toilet\n'
          '• Avoid street food, unpeeled fruits, raw salads\n'
          '• Typhoid Vi vaccine (2 weekly doses) — effective for 3–5 years\n\n'
          '🚨 **Typhoid can be fatal if untreated.** See a doctor for blood/stool test.\n\n'
          '_Never stop antibiotics early — drug-resistant typhoid is increasing._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 25. MALARIA / DENGUE
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('malaria') || q.contains('dengue') || q.contains('mosquito') ||
        q.contains('platelet') || q.contains('plasmodium') || q.contains('malaira') ||
        q.contains('denga')) {
      return '🦟 **Malaria & Dengue**\n\n'
          '**Malaria symptoms:** Cyclical fever with chills and sweating (every 48–72 hrs),\n'
          'headache, muscle pain, nausea, vomiting\n\n'
          '**Dengue symptoms:** Sudden high fever, severe headache, pain behind eyes,\n'
          'joint/muscle pain ("breakbone fever"), rash, bleeding gums or nose\n\n'
          '**For both:**\n'
          '• See a doctor immediately for blood test (RDT / Widal / CBC)\n'
          '• Rest and drink plenty of fluids — especially ORS\n'
          '• Paracetamol for fever (do NOT take Aspirin or Ibuprofen — increase bleeding risk in dengue)\n\n'
          '**Dengue — watch platelet count:**\n'
          '• Normal: 1.5–4 lakh/mm³\n'
          '• < 1 lakh → close monitoring; < 20,000 → hospitalisation needed\n\n'
          '**Prevention (both):**\n'
          '• Use mosquito nets, repellents (DEET), long sleeves/pants\n'
          '• Eliminate standing water: flower pots, tyres, coolers, containers\n'
          '• Spray insecticide in living areas during outbreaks\n\n'
          '🚨 **Go to hospital immediately for:** Bleeding, severe abdominal pain, persistent vomiting, breathlessness\n\n'
          '_Malaria requires prescription antimalarials — do not self-treat._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 26. HIV / AIDS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('hiv') || q.contains('aids') || q.contains('std') ||
        q.contains('sexually transmitted') || q.contains('condom') ||
        q.contains('antiretroviral') || q.contains('art therapy')) {
      return '💉 **HIV & AIDS**\n\n'
          '**What is HIV?**\n'
          'HIV (Human Immunodeficiency Virus) attacks the immune system.\n'
          'AIDS is the advanced stage when the immune system is severely damaged.\n\n'
          '**How it spreads:**\n'
          '• Unprotected sexual contact\n'
          '• Sharing needles or syringes\n'
          '• Mother to child (during birth or breastfeeding)\n'
          '• Infected blood transfusions\n'
          '⚠️ HIV does NOT spread through hugging, sharing food, or mosquito bites\n\n'
          '**Early symptoms (acute HIV, 2–4 weeks after infection):**\n'
          'Flu-like illness, fever, sore throat, rash, swollen lymph nodes\n'
          'Many people have no symptoms for years — only a test confirms HIV\n\n'
          '**Testing & Treatment:**\n'
          '• ICTC centres across India offer free, confidential HIV testing\n'
          '• ART (Antiretroviral Therapy) — free at government hospitals\n'
          '• With ART, people with HIV live long, healthy, near-normal lives\n'
          '• Start ART as early as possible after diagnosis\n\n'
          '**Prevention:**\n'
          '• Use condoms consistently and correctly\n'
          '• PrEP (Pre-Exposure Prophylaxis) — for high-risk individuals\n'
          '• Never share needles or syringes\n\n'
          '_Knowing your HIV status is the first step. Testing is free and confidential._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 27. TUBERCULOSIS (TB)
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('tuberculosis') || q.contains(' tb ') || q.contains('tb symptoms') ||
        q.contains('kshay') || q.contains('rajyakshma') || q.contains('sputum') ||
        q.contains('mantoux') || q.contains('dots') || q.startsWith('tb')) {
      return '🫁 **Tuberculosis (TB)**\n\n'
          '**Symptoms (may be present for weeks to months):**\n'
          '• Persistent cough > 2 weeks (may have blood in sputum)\n'
          '• Fever especially in evenings / night sweats\n'
          '• Unexplained weight loss and loss of appetite\n'
          '• Fatigue and weakness\n'
          '• Chest pain while breathing or coughing\n\n'
          '**Diagnosis:** Sputum test, chest X-ray, GeneXpert, Mantoux skin test\n\n'
          '**Treatment (DOTS — Directly Observed Treatment Short-course):**\n'
          '• Free treatment available at all government health centres in India and Nepal\n'
          '• Duration: 6 months (standard TB) — MUST complete the full course\n'
          '• Drug-Resistant TB (MDR-TB): 18–24 month treatment\n'
          '• Nutritious diet and good ventilation support recovery\n\n'
          '**Nikshay Poshan Yojana (India):** ₹500/month nutritional support for TB patients\n\n'
          '**Prevention:**\n'
          '• BCG vaccine at birth protects children against severe TB\n'
          '• Ventilate rooms — open windows, avoid overcrowding\n'
          '• Cover mouth when coughing; do not spit in public\n\n'
          '🚨 **TB is curable if treated fully. Stopping treatment early causes drug resistance.**';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 28. EPILEPSY / SEIZURES
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('epilepsy') || q.contains('seizure') || q.contains('fits') ||
        q.contains('convulsion') || q.contains('mirgi') || q.contains('fitting') ||
        q.contains('mrigimaari')) {
      return '🧠 **Epilepsy & Seizures**\n\n'
          '**What to do DURING a seizure:**\n'
          '• Stay calm — most seizures stop on their own within 1–3 minutes\n'
          '• Clear the area of hard/sharp objects\n'
          '• Place person on their side (recovery position) to prevent choking\n'
          '• Put something soft under the head\n'
          '• Loosen tight clothing around neck\n'
          '• Time the seizure — note start and end\n'
          '• Do NOT: put anything in the mouth | restrain the person | give water/food during seizure\n\n'
          '**Call 108 immediately if:**\n'
          '• Seizure lasts > 5 minutes\n'
          '• Person does not regain consciousness\n'
          '• Second seizure occurs soon after\n'
          '• Injury occurs during seizure\n'
          '• First ever seizure\n'
          '• Seizure in pregnant woman or diabetic\n\n'
          '**Living with epilepsy:**\n'
          '• Take anti-epileptic medication (AEDs) consistently — never skip doses\n'
          '• Avoid known triggers: sleep deprivation, alcohol, flashing lights, fever\n'
          '• Do not drive or operate heavy machinery if seizures are not well-controlled\n'
          '• Wear a medical alert bracelet\n\n'
          '_Epilepsy is manageable — 70% of patients become seizure-free with proper medication._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 29. KIDNEY HEALTH
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('kidney') || q.contains('renal') || q.contains('gurdaa') ||
        q.contains('kidney stone') || q.contains('dialysis') || q.contains('creatinine') ||
        q.contains('uti') || q.contains('urinary') || q.contains('burning urination')) {
      return '🫘 **Kidney Health**\n\n'
          '**Warning signs of kidney problems:**\n'
          '• Swelling in face, ankles, or feet\n'
          '• Reduced or no urine output\n'
          '• Foamy or dark urine\n'
          '• Persistent fatigue and weakness\n'
          '• Severe back/flank pain (kidney stones)\n'
          '• High blood pressure that\'s hard to control\n\n'
          '**Kidney Stones:**\n'
          '• Drink 2.5–3 litres water daily — most important prevention\n'
          '• Pain (renal colic): severe flank pain radiating to groin\n'
          '• Paracetamol or Diclofenac for pain (short-term)\n'
          '• Most small stones (< 5 mm) pass on their own with fluids\n'
          '• See doctor for stones > 6 mm or with fever (infection risk)\n\n'
          '**UTI (Urinary Tract Infection):**\n'
          '• Symptoms: burning urination, frequent urge, cloudy/smelly urine, pelvic pain\n'
          '• Drink plenty of water; avoid holding urine\n'
          '• Antibiotic treatment required (Nitrofurantoin, Trimethoprim — doctor prescribed)\n\n'
          '**Kidney health habits:**\n'
          '• Stay well hydrated (2–3 litres water/day)\n'
          '• Control diabetes and blood pressure\n'
          '• Avoid excessive painkillers (NSAIDs damage kidneys long-term)\n'
          '• Limit salt and processed foods\n\n'
          '_Get creatinine and urine tests annually if diabetic or hypertensive._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 30. LIVER HEALTH / JAUNDICE
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('liver') || q.contains('jaundice') || q.contains('hepatitis') ||
        q.contains('pagoda') || q.contains('fatty liver') || q.contains('cirrhosis') ||
        q.contains('yellow skin') || q.contains('yellow eyes') || q.contains('kamla')) {
      return '🫀 **Liver Health & Jaundice**\n\n'
          '**Jaundice symptoms:**\n'
          'Yellowing of skin and whites of eyes, dark yellow urine, pale/clay-coloured stools,\n'
          'fatigue, abdominal pain (right upper abdomen), loss of appetite, nausea\n\n'
          '**Common causes:** Hepatitis A/B/E, gallstones, fatty liver, alcohol, medicines\n\n'
          '**For Hepatitis A / E (water-borne — self-limiting):**\n'
          '• Rest completely for 2–4 weeks\n'
          '• Eat light: rice, dal, boiled vegetables, curd, fruits\n'
          '• Drink plenty of fluids\n'
          '• Strictly avoid alcohol, fatty food, and all unnecessary medicines\n'
          '• Most recover fully in 4–8 weeks\n\n'
          '**For Hepatitis B/C (blood-borne):**\n'
          '• Requires specialist care and antiviral treatment\n'
          '• Hepatitis B vaccine: 3 doses (0, 1, 6 months) — highly effective\n\n'
          '**Fatty Liver prevention:**\n'
          '• Lose weight gradually (5–10% reduces liver fat)\n'
          '• Exercise 30 min/day\n'
          '• Avoid alcohol completely\n'
          '• Limit sugar, fructose (sugary drinks, sweets)\n\n'
          '🚨 **See a doctor immediately for:**\n'
          '• Severe abdominal pain + jaundice\n'
          '• Confusion or altered consciousness (liver failure)\n'
          '• Vomiting blood\n\n'
          '_Never take paracetamol or any medicine beyond the prescribed dose if you have liver problems._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 31. BREASTFEEDING
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('breastfeed') || q.contains('nursing') || q.contains('breast milk') ||
        q.contains('lactation') || q.contains('doodh pilana') || q.contains('syandanpaan')) {
      return '🤱 **Breastfeeding**\n\n'
          '**WHO recommendations:**\n'
          '• Start breastfeeding within 1 hour of birth (colostrum = gold)\n'
          '• Exclusive breastfeeding for the first 6 months (no water, no other food)\n'
          '• Continue breastfeeding up to 2 years alongside solid foods\n\n'
          '**Benefits for baby:**\n'
          '• Perfect nutrition, anti-infective antibodies, prevents diarrhoea and pneumonia\n'
          '• Reduces risk of SIDS, allergies, obesity, diabetes\n\n'
          '**Benefits for mother:**\n'
          '• Helps uterus contract; reduces postpartum bleeding\n'
          '• Lowers risk of breast and ovarian cancer, type 2 diabetes\n\n'
          '**Improving milk supply:**\n'
          '• Feed frequently — supply follows demand (8–12 times/day for newborns)\n'
          '• Ensure good latch — baby\'s mouth covers areola, not just nipple\n'
          '• Stay well hydrated and eat nutritious food\n'
          '• Rest as much as possible\n\n'
          '**Common problems:**\n'
          '• Sore nipples → check latch; apply expressed breast milk; air dry\n'
          '• Engorgement → feed frequently; warm compress before feeding\n'
          '• Mastitis (red painful lump with fever) → antibiotics needed, see doctor\n\n'
          '_Breastfeeding is one of the most powerful acts for child health._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 32. PUBERTY / ADOLESCENT HEALTH
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('puberty') || q.contains('adolescent') || q.contains('teenager') ||
        q.contains('period') && q.contains('first') || q.contains('growing up') ||
        q.contains('teen health') || q.contains('yauvan')) {
      return '🧒 **Puberty & Adolescent Health**\n\n'
          '**Puberty in girls (usually 8–13 years):**\n'
          '• Breast development, pubic/underarm hair, growth spurt\n'
          '• First menstrual period (menarche) — normal range 10–16 years\n\n'
          '**Puberty in boys (usually 9–14 years):**\n'
          '• Testicular/penile growth, pubic/facial hair, voice deepening\n'
          '• Muscle mass increase, growth spurt\n\n'
          '**Normal concerns:**\n'
          '• Acne — wash face twice daily; avoid squeezing pimples\n'
          '• Body odour — bathe daily; use deodorant\n'
          '• Mood swings — normal hormonal changes; talk to a trusted adult\n\n'
          '**Menstrual health (for girls):**\n'
          '• Normal cycle: 21–35 days; duration 2–7 days\n'
          '• Mild cramps: warm compress, Ibuprofen 400 mg\n'
          '• Use sanitary pad, tampon, or menstrual cup — change every 4–8 hours\n\n'
          '**Key health habits for teens:**\n'
          '• Sleep 8–10 hours per night\n'
          '• Eat iron-rich foods (especially girls — periods cause iron loss)\n'
          '• Exercise 60 min/day\n'
          '• Avoid tobacco, alcohol, and drugs — they permanently affect development\n\n'
          '_Changes during puberty are completely normal. Talk to a doctor if you have concerns._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 33. ELDERLY HEALTH
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('elderly') || q.contains('old age') || q.contains('senior') ||
        q.contains('bujurg') || q.contains('budhapa') || q.contains('geriatric') ||
        q.contains('old person') || q.contains('ageing') || q.contains('aging')) {
      return '👴 **Elderly Health & Care**\n\n'
          '**Key health concerns in older adults:**\n'
          '• Falls — leading cause of injury; make home fall-safe\n'
          '• Polypharmacy — multiple medicines; review with doctor regularly\n'
          '• Memory and cognitive decline — early Alzheimer\'s detection\n'
          '• Loneliness and depression — social connection is vital\n'
          '• Malnutrition — appetite decreases but nutrient needs remain high\n\n'
          '**Fall prevention:**\n'
          '• Remove loose rugs and clutter; use non-slip mats\n'
          '• Install grab bars in bathroom and beside bed\n'
          '• Ensure adequate lighting in all rooms\n'
          '• Exercise for balance: Tai Chi, yoga, leg-strengthening exercises\n'
          '• Regular vision and hearing checks\n\n'
          '**Nutrition for elderly:**\n'
          '• Protein: dal, eggs, curd, fish (prevents muscle wasting)\n'
          '• Calcium + Vitamin D: dairy, fortified foods, sunlight\n'
          '• Fibre: fruits, vegetables, whole grains (prevents constipation)\n'
          '• Water: at least 6–8 glasses (thirst sensation decreases with age)\n\n'
          '**Preventive checks (annually):**\n'
          'Blood sugar, BP, cholesterol, kidney function, eye exam, dental check, bone density (after 65)\n\n'
          '_Staying active, eating well, and staying socially connected are the pillars of healthy ageing._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 34. VITAMIN DEFICIENCY
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('vitamin') || q.contains('deficiency') || q.contains('vitamin d') ||
        q.contains('vitamin b12') || q.contains('vitamin c') || q.contains('rickets') ||
        q.contains('scurvy') || q.contains('supplement') || q.contains('multivitamin')) {
      return '💊 **Vitamin Deficiency**\n\n'
          '**Vitamin D deficiency (extremely common in South Asia):**\n'
          '• Symptoms: Bone pain, muscle weakness, fatigue, frequent infections\n'
          '• Sources: Sunlight (15 min daily skin exposure), fatty fish, egg yolk, fortified milk\n'
          '• Supplement: Vitamin D3 1000–2000 IU/day (check with doctor)\n\n'
          '**Vitamin B12 deficiency (common in vegetarians/vegans):**\n'
          '• Symptoms: Extreme fatigue, tingling in hands/feet, poor memory, pale skin\n'
          '• Sources: Meat, fish, eggs, dairy, fortified cereals\n'
          '• Supplement: Methylcobalamin 500 mcg daily or B12 injection (prescribed)\n\n'
          '**Iron deficiency (anaemia):**\n'
          '• Symptoms: Fatigue, pale skin, breathlessness, weak nails\n'
          '• See topic: Anaemia — iron-rich foods and supplements\n\n'
          '**Vitamin C deficiency:**\n'
          '• Symptoms: Bleeding gums, slow wound healing, bruising easily\n'
          '• Sources: Amla, guava, lemon, orange, bell pepper, tomatoes\n\n'
          '**Calcium deficiency:**\n'
          '• Symptoms: Muscle cramps, weak/brittle nails, frequent fractures\n'
          '• Sources: Milk, ragi, sesame, paneer, green leafy vegetables\n\n'
          '_A balanced diet prevents most vitamin deficiencies. Supplements are needed only when diet is insufficient._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 35. DEHYDRATION
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('dehydration') || q.contains('dehydrated') || q.contains('thirsty') ||
        q.contains('no water') || q.contains('dry mouth') || q.contains('paani ki kami') ||
        q.contains('not drinking water') || q.contains('dark urine')) {
      return '🌞 **Dehydration**\n\n'
          '**Signs of dehydration (mild–moderate):**\n'
          '• Thirst, dry mouth, dark yellow urine\n'
          '• Headache, dizziness, fatigue\n'
          '• Reduced urine output\n\n'
          '**Signs of severe dehydration (needs urgent care):**\n'
          '• No urine for 8+ hours, sunken eyes\n'
          '• Rapid heartbeat and breathing\n'
          '• Confusion or extreme weakness\n'
          '• Dry shrivelled skin that doesn\'t spring back\n'
          '• In infants: no tears when crying, sunken fontanelle\n\n'
          '**Treatment:**\n'
          '• Mild: Drink water, coconut water, ORS, diluted fruit juice\n'
          '• ORS recipe (if packet not available): 1 litre water + 6 tsp sugar + 0.5 tsp salt\n'
          '• Drink small sips frequently if vomiting (1 tsp every 5 minutes)\n\n'
          '**Daily water intake:**\n'
          '• Adults: 2–2.5 litres (8 glasses) under normal conditions\n'
          '• More in: hot weather, exercise, fever, diarrhoea, pregnancy\n\n'
          '🚨 **Go to hospital for:** Severe dehydration signs, especially in infants and elderly\n\n'
          '_Check your urine colour — pale yellow = well hydrated, dark yellow = drink more._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 36. BURNS / WOUNDS FIRST AID
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('burn') || q.contains('jalna') || q.contains('scald') ||
        q.contains('blister') || q.contains('wound') || q.contains('cut') ||
        q.contains('zakhm') || q.contains('bleeding') || q.contains('injury')) {
      return '🔥 **Burns & Wound First Aid**\n\n'
          '**For burns — immediate action:**\n'
          '• Cool the burn immediately under cool (not ice cold) running water for 20 minutes\n'
          '• Remove jewellery/clothing near the burn (before swelling starts)\n'
          '• Cover loosely with a clean, non-fluffy bandage or cling film\n'
          '• Give Paracetamol for pain\n'
          '• Do NOT: put butter, toothpaste, or ice on burns\n'
          '• Do NOT break blisters\n\n'
          '**Burn severity:**\n'
          '• 1st degree (red, no blisters) — treat at home\n'
          '• 2nd degree (blisters, very painful) — see doctor\n'
          '• 3rd degree (white/charred, painless) — emergency hospital immediately\n\n'
          '🚨 **Go to hospital for:** Burns > 5 cm, burns on face/hands/genitals/joints, chemical burns, electrical burns, any burn in children\n\n'
          '**For cuts / wounds:**\n'
          '• Apply firm direct pressure with clean cloth to stop bleeding\n'
          '• Once stopped, clean with clean water and mild soap\n'
          '• Apply antiseptic (Betadine / Savlon)\n'
          '• Cover with sterile dressing\n'
          '• Change dressing daily; keep wound dry\n\n'
          '**Signs of wound infection:** Increasing redness, warmth, swelling, pus, fever → see doctor\n\n'
          '_Deep cuts, wounds from rusty objects, or animal bites require immediate medical attention + tetanus injection._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 37. SNAKEBITE / POISONING
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('snakebite') || q.contains('snake bite') || q.contains('saanp kata') ||
        q.contains('poisoning') || q.contains('poisoned') || q.contains('overdose') ||
        q.contains('swallowed something') || q.contains('toxic')) {
      return '🐍 **Snakebite & Poisoning**\n\n'
          '🚨 **SNAKEBITE — EMERGENCY: Call 108 immediately**\n\n'
          '**Do:**\n'
          '• Keep the person calm and still — movement spreads venom faster\n'
          '• Immobilise the bitten limb at or below heart level\n'
          '• Remove rings, watches, tight clothing near bite site\n'
          '• Note time of bite and try to remember snake appearance\n'
          '• Transport to nearest hospital with anti-venom immediately\n\n'
          '**Do NOT:**\n'
          '• Cut the bite or try to suck out venom\n'
          '• Apply tourniquet or ice\n'
          '• Give food, drink, or traditional remedies\n\n'
          '**For other poisoning / accidental ingestion:**\n'
          '• Call Poison Control India: **1800-116-117** (Toll free)\n'
          '• Do NOT induce vomiting unless specifically told to do so\n'
          '• If skin/eye exposure: rinse with large amounts of water for 15–20 min\n'
          '• Take the container/medicine bottle to hospital for identification\n\n'
          '**Medicine overdose:**\n'
          '• Go to nearest emergency room immediately — do not wait for symptoms\n'
          '• Bring the medicine bottle/strip\n\n'
          '_All suspected snakebites are emergencies — even if no immediate symptoms._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 38. FRACTURE / SPRAIN
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('fracture') || q.contains('sprain') || q.contains('broken bone') ||
        q.contains('haddi') || q.contains('twisted ankle') || q.contains('strain') ||
        q.contains('dislocation') || q.contains('limping') || q.contains('toot gayi')) {
      return '🦴 **Fracture & Sprain First Aid**\n\n'
          '**RICE method for sprains/strains:**\n'
          '• 🧊 Rest — stop activity and avoid weight-bearing\n'
          '• 🧊 Ice — cold compress for 20 min, every 2–3 hours (first 48 hrs)\n'
          '• 🩹 Compression — elastic bandage to reduce swelling (not too tight)\n'
          '• 🦵 Elevation — raise the injured limb above heart level\n\n'
          '**For suspected fracture:**\n'
          '• Do NOT try to straighten the limb\n'
          '• Immobilise using whatever is available (rolled newspaper, cloth)\n'
          '• Support above and below the injury site\n'
          '• Apply ice pack wrapped in cloth\n'
          '• Go to hospital for X-ray immediately\n\n'
          '**Medicines:**\n'
          '• Ibuprofen 400 mg or Paracetamol 500 mg for pain and swelling\n\n'
          '**Bone healing nutrition:**\n'
          '• Calcium: dairy, ragi, sesame, leafy greens\n'
          '• Vitamin D: sunlight, eggs, fish\n'
          '• Protein: dal, eggs, meat (essential for bone repair)\n\n'
          '🚨 **Go to hospital immediately if:**\n'
          '• Bone is visibly deformed or poking through skin\n'
          '• Numbness, tingling, or inability to move\n'
          '• Severe swelling or bruising\n'
          '• Spine, neck, or hip injury (do not move — call 108)\n\n'
          '_Spinal injuries: never move the person — wait for emergency services._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 39. FATIGUE / WEAKNESS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('fatigue') || q.contains('tired') || q.contains('weak') ||
        q.contains('thakan') || q.contains('kamzori') || q.contains('no energy') ||
        q.contains('exhausted') || q.contains('always tired') || q.contains('body tired')) {
      return '😴 **Fatigue & Weakness**\n\n'
          '**Common causes:**\n'
          '• Poor sleep (< 7 hours)\n'
          '• Anaemia (low haemoglobin)\n'
          '• Diabetes or low blood sugar\n'
          '• Thyroid problems (hypothyroidism)\n'
          '• Vitamin D or B12 deficiency\n'
          '• Depression or chronic stress\n'
          '• Dehydration\n'
          '• Infections (TB, viral fever)\n\n'
          '**Self-care steps:**\n'
          '• Sleep 7–9 hours at consistent times\n'
          '• Eat iron and protein rich meals (dal, eggs, green vegetables, meat)\n'
          '• Drink 8+ glasses of water daily\n'
          '• Light exercise (20 min walk) often reduces fatigue\n'
          '• Avoid caffeine after 3 PM\n'
          '• Manage stress with breathing exercises and breaks\n\n'
          '**Get tested for:**\n'
          '• CBC (complete blood count) — check for anaemia\n'
          '• Blood sugar (fasting + HbA1c)\n'
          '• Thyroid function (TSH)\n'
          '• Vitamin B12 and D levels\n\n'
          '🚨 **See a doctor urgently if:**\n'
          '• Fatigue with chest pain, breathlessness, or fainting\n'
          '• Fatigue with unexplained weight loss\n'
          '• Severe weakness affecting daily activities\n\n'
          '_Fatigue is a symptom, not a diagnosis — get blood tests to find the cause._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 40. SINUSITIS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('sinus') || q.contains('sinusitis') || q.contains('nasal congestion') ||
        q.contains('blocked nose') || q.contains('naak band') || q.contains('postnasal') ||
        q.contains('sinus pain') || q.contains('facial pain')) {
      return '🤧 **Sinusitis (Sinus Infection)**\n\n'
          '**Symptoms:**\n'
          'Blocked or runny nose, facial pain/pressure (worse bending forward),\n'
          'headache behind forehead/eyes, thick yellow/green mucus,\n'
          'reduced smell, fatigue, fever (in bacterial sinusitis)\n\n'
          '**Home treatment (acute sinusitis — first 10 days):**\n'
          '• Steam inhalation twice daily (add a drop of eucalyptus oil)\n'
          '• Warm compress on face (over forehead and cheeks)\n'
          '• Saline nasal rinse / neti pot — clears passages naturally\n'
          '• Stay well hydrated to thin mucus\n'
          '• Decongestant nasal spray (Oxymetazoline) — max 3 days only (rebound if longer)\n'
          '• Sleep with head slightly elevated\n\n'
          '**Medicines:**\n'
          '• Paracetamol or Ibuprofen for pain\n'
          '• Cetrizine for allergic component\n'
          '• Antibiotic only if bacterial (doctor decides — amoxicillin-clavulanate)\n\n'
          '**See a doctor if:**\n'
          '• Symptoms lasting > 10 days or worsening after 7 days\n'
          '• Severe headache, high fever, stiff neck, or visual changes\n'
          '• Swelling around eyes\n\n'
          '_Most sinusitis is viral — antibiotics not needed unless bacterial confirmed._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 41. ORS / REHYDRATION
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains(' ors') || q.startsWith('ors') || q.contains('oral rehydration') ||
        q.contains('electrolyte') || q.contains('jeevan jal') || q.contains('rehydration') ||
        q.contains('salt sugar water')) {
      return '💧 **ORS — Oral Rehydration Salts**\n\n'
          '**What is ORS?**\n'
          'A simple, life-saving drink that replaces fluids and electrolytes\n'
          'lost through diarrhoea, vomiting, fever, or excessive sweating.\n\n'
          '**Standard WHO ORS — how to prepare:**\n'
          '• 1 litre of boiled and cooled safe water\n'
          '• 1 ORS sachet (commercial: Electral, ORS-L)\n'
          '• OR home-made: 6 level tsp sugar + ½ tsp salt in 1 litre water\n'
          '• Mix thoroughly until completely dissolved\n'
          '• Use within 24 hours; discard remainder and prepare fresh\n\n'
          '**How to give ORS:**\n'
          '• Adults and older children: drink freely as tolerated\n'
          '• Young children: 50–100 ml after each loose stool\n'
          '• If vomiting: give 1 teaspoon every 2–3 minutes; increase slowly\n\n'
          '**When to use ORS:**\n'
          '• Diarrhoea (start immediately at first sign)\n'
          '• Vomiting (small amounts frequently)\n'
          '• Fever (helps replace insensible fluid loss)\n'
          '• Heat exhaustion or heavy exercise\n\n'
          '🚨 **ORS does not stop diarrhoea — it prevents the dangerous dehydration it causes.**\n'
          'See a doctor if diarrhoea > 3 days, blood in stool, or severe dehydration signs.\n\n'
          '_ORS has saved millions of lives. It is on the WHO Essential Medicines List._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 42. BASIC FIRST AID
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('first aid') || q.contains('prathmik upchar') || q.contains('cpr') ||
        q.contains('choking') || q.contains('heimlich') || q.contains('unconscious person') ||
        q.contains('fainted') || q.contains('fainting')) {
      return '🏥 **Basic First Aid**\n\n'
          '**CPR (Cardiopulmonary Resuscitation):**\n'
          '• Check: Is person unconscious and not breathing normally?\n'
          '• Call 108\n'
          '• 30 chest compressions: centre of chest, hard and fast (100–120/min)\n'
          '• 2 rescue breaths: tilt head, lift chin, blow in for 1 sec\n'
          '• Continue 30:2 until help arrives or person recovers\n\n'
          '**Choking (adult/child):**\n'
          '• Encourage coughing if they can\n'
          '• 5 back blows (between shoulder blades with heel of hand)\n'
          '• 5 abdominal thrusts (Heimlich): fist above navel, sharp upward push\n'
          '• Repeat until object dislodges or person loses consciousness → start CPR\n\n'
          '**Fainting:**\n'
          '• Lay person down flat; raise legs 30 cm (improves blood flow to brain)\n'
          '• Loosen tight clothing; ensure fresh air\n'
          '• Do NOT give water until fully conscious\n'
          '• If no recovery in 1 minute → call 108\n\n'
          '**Drowning rescue:**\n'
          '• Only trained person should enter water\n'
          '• On shore: clear airway, start CPR if not breathing\n'
          '• Call 108 even if person appears to recover (secondary drowning risk)\n\n'
          '_Learn CPR — a simple skill that can save a life in minutes._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 43. COVID-19
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('covid') || q.contains('corona') || q.contains('coronavirus') ||
        q.contains('covid-19') || q.contains('omicron') || q.contains('sars-cov') ||
        q.contains('covid symptoms')) {
      return '🦠 **COVID-19**\n\n'
          '**Common symptoms:**\n'
          'Fever, cough, sore throat, runny nose, headache, body aches,\n'
          'fatigue, loss of taste/smell, diarrhoea\n\n'
          '**Home care (mild symptoms):**\n'
          '• Rest and drink plenty of fluids\n'
          '• Paracetamol for fever and pain\n'
          '• Isolate from other family members for 5 days\n'
          '• Wear mask when around others\n'
          '• Monitor oxygen saturation (SpO2) with pulse oximeter if available\n'
          '  → SpO2 < 94% → seek medical attention\n\n'
          '**Warning signs — seek emergency care:**\n'
          '• Difficulty breathing or persistent chest pain\n'
          '• SpO2 < 94% on pulse oximeter\n'
          '• Confusion or inability to stay awake\n'
          '• Bluish lips or face\n\n'
          '**Prevention:**\n'
          '• COVID-19 vaccination — highly effective against severe disease\n'
          '• Wear mask in crowded, poorly ventilated spaces\n'
          '• Hand hygiene: wash hands for 20 seconds with soap\n'
          '• Ventilate indoor spaces — open windows\n\n'
          '**Long COVID:** Symptoms persisting > 4 weeks — see doctor for assessment.\n\n'
          '_Get vaccinated and boosted as recommended by your national health authority._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 44. WOUND INFECTION / SEPSIS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('infection') || q.contains('sepsis') || q.contains('infected wound') ||
        q.contains('pus') || q.contains('abscess') || q.contains('swollen wound') ||
        q.contains('ghav') || q.contains('wound smell')) {
      return '🦠 **Wound Infection & Sepsis**\n\n'
          '**Signs of wound infection:**\n'
          '• Increasing redness, warmth, and swelling around the wound\n'
          '• Yellow or green pus discharge\n'
          '• Bad smell from the wound\n'
          '• Red streaks spreading from the wound\n'
          '• Fever and chills\n\n'
          '**Basic wound care to prevent infection:**\n'
          '• Clean with clean running water and mild soap\n'
          '• Apply antiseptic (Betadine or Savlon)\n'
          '• Cover with sterile dressing; change daily\n'
          '• Keep wound dry; avoid submerging in water\n\n'
          '**If infection develops:**\n'
          '• See a doctor for antibiotic prescription\n'
          '• Do NOT try to squeeze pus out of an abscess\n'
          '• Warm compresses may help draw out superficial infections\n\n'
          '**Sepsis — life-threatening infection response:**\n'
          '• Signs: High fever OR low temperature, rapid heartbeat, rapid breathing,\n'
          '  confusion, extreme weakness, skin mottling (blotchy)\n\n'
          '🚨 **Sepsis is a medical emergency — Call 108 immediately.**\n'
          'Every hour of delay in treatment increases risk of death.\n\n'
          '_Animal bites and deep puncture wounds always need medical attention + tetanus injection._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 45. WOUND CARE / DRESSING
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('how to clean wound') || q.contains('dress wound') ||
        q.contains('bandage') || q.contains('dressing') || q.contains('zakhm saaf') ||
        q.contains('wound care') || q.contains('wound dressing') || q.contains('antiseptic')) {
      return '🩹 **Wound Care & Dressing**\n\n'
          '**Step-by-step wound care:**\n'
          '1. 🧼 Wash hands thoroughly with soap before touching the wound\n'
          '2. 💧 Rinse wound under clean running water for 5–10 minutes\n'
          '3. 🧽 Gently clean with mild soap; remove any visible dirt or debris\n'
          '4. 🩺 Apply antiseptic solution (Betadine / Povidone-iodine / Savlon)\n'
          '5. 🩹 Cover with sterile gauze and secure with medical tape\n\n'
          '**Daily dressing change:**\n'
          '• Change dressing once or twice daily, or when wet/dirty\n'
          '• Moisten old dressing with saline if it sticks to the wound\n'
          '• Gently remove; inspect for signs of infection\n'
          '• Let wound air-dry briefly before re-dressing\n\n'
          '**Types of wounds:**\n'
          '• Abrasion (graze) — clean, antiseptic, leave open if small\n'
          '• Laceration (cut) — deep cuts may need stitches within 6 hours\n'
          '• Puncture (nail, thorn) — clean well; high tetanus risk\n'
          '• Bite wound — dog/animal bite needs rabies prophylaxis within 24 hrs\n\n'
          '🚨 **Go to hospital for:**\n'
          '• Deep wounds requiring stitches (won\'t close on own)\n'
          '• Wounds from rusty objects (tetanus injection needed)\n'
          '• Any animal bite (rabies vaccination)\n'
          '• Signs of infection (pus, fever, red streaks)\n\n'
          '_A clean wound heals faster. Keep it moist (not wet) with dressing._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 46. MENSTRUAL HEALTH
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('menstrual') || q.contains('menstruation') || q.contains('period') ||
        q.contains('maahwari') || q.contains('mc pain') || q.contains('period pain') ||
        q.contains('dysmenorrhea') || q.contains('irregular period') || q.contains('pcod') ||
        q.contains('pcos') || q.contains('heavy period') || q.contains('periods late')) {
      return '🩸 **Menstrual Health**\n\n'
          '**Normal menstrual cycle:**\n'
          '• Cycle length: 21–35 days | Duration: 2–7 days\n'
          '• Flow: light to moderate; some cramping is normal\n\n'
          '**For menstrual cramps (dysmenorrhea):**\n'
          '• Ibuprofen 400 mg with food — start 1 day before expected period\n'
          '• Warm compress on lower abdomen\n'
          '• Light exercise (walking, yoga) helps\n'
          '• Stay hydrated; avoid excessive caffeine\n\n'
          '**Irregular periods — common causes:**\n'
          '• PCOS (Polycystic Ovary Syndrome) — most common\n'
          '• Thyroid disorders\n'
          '• Stress, excessive exercise, sudden weight change\n'
          '• Pregnancy\n\n'
          '**PCOS symptoms:** Irregular/absent periods, excess hair growth, acne, weight gain\n'
          '• Management: weight loss (if overweight), exercise, low-carb diet, hormonal pills (doctor-prescribed)\n\n'
          '**Hygiene during periods:**\n'
          '• Change sanitary pad every 4–6 hours; tampon every 4–8 hours\n'
          '• Wash the vulva (external area) with water — no harsh soaps inside\n\n'
          '🚨 **See a doctor for:**\n'
          '• Periods absent for > 3 months (not pregnant)\n'
          '• Extremely heavy bleeding (soaking a pad in < 1 hour)\n'
          '• Severe pain not relieved by Ibuprofen\n'
          '• Periods with fever or foul-smelling discharge\n\n'
          '_Track your cycle on a calendar or app to spot irregularities early._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 47. HEART PALPITATIONS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('palpitation') || q.contains('heart racing') || q.contains('fast heartbeat') ||
        q.contains('irregular heartbeat') || q.contains('dhak dhak') || q.contains('dil ki dhadkan') ||
        q.contains('skipping beat') || q.contains('heart flutter')) {
      return '🫀 **Heart Palpitations**\n\n'
          '**What are palpitations?**\n'
          'The feeling of your heart beating fast, hard, or irregularly.\n'
          'Usually harmless, but can sometimes indicate a heart problem.\n\n'
          '**Common benign causes:**\n'
          '• Caffeine (tea, coffee, energy drinks)\n'
          '• Stress and anxiety\n'
          '• Dehydration\n'
          '• Anaemia\n'
          '• Thyroid overactivity\n'
          '• Strenuous exercise\n'
          '• Nicotine and alcohol\n\n'
          '**What to do during palpitations:**\n'
          '• Sit down and rest\n'
          '• Try the Valsalva manoeuvre: take a deep breath, bear down as if having a bowel movement for 15 sec\n'
          '• Splash cold water on face\n'
          '• Breathe slowly and deeply\n\n'
          '**Reduce triggers:**\n'
          '• Cut down caffeine and alcohol\n'
          '• Manage stress (yoga, breathing exercises)\n'
          '• Stay well hydrated\n'
          '• Quit smoking\n\n'
          '🚨 **Call 108 immediately for palpitations with:**\n'
          '• Chest pain or tightness\n'
          '• Difficulty breathing\n'
          '• Fainting or dizziness\n'
          '• Palpitations lasting > 30 minutes\n'
          '• Palpitations in someone with known heart disease\n\n'
          '_An ECG (electrocardiogram) can identify the type of arrhythmia._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 48. SWOLLEN FEET / LEGS
    // ─────────────────────────────────────────────────────────────────────
    if (q.contains('swollen feet') || q.contains('swollen ankle') || q.contains('swollen leg') ||
        q.contains('puffiness') || q.contains('oedema') || q.contains('edema') ||
        q.contains('foot swelling') || q.contains('pair mein sujan') || q.contains('pav sujan')) {
      return '🦶 **Swollen Feet & Ankles**\n\n'
          '**Common causes:**\n'
          '• Prolonged standing or sitting\n'
          '• Hot weather\n'
          '• High salt intake\n'
          '• Pregnancy (normal after 20 weeks)\n'
          '• Heart, kidney, or liver problems\n'
          '• Blood clot (Deep Vein Thrombosis — DVT)\n'
          '• Certain medicines (calcium channel blockers, steroids)\n\n'
          '**Simple relief measures:**\n'
          '• Elevate legs above heart level for 30 minutes, 3–4 times/day\n'
          '• Reduce salt intake\n'
          '• Take short walking breaks if sitting for long periods\n'
          '• Compression stockings (doctor-recommended)\n'
          '• Stay hydrated — paradoxically helps reduce fluid retention\n'
          '• Gentle ankle circles and calf stretches\n\n'
          '🚨 **See a doctor urgently if:**\n'
          '• Sudden swelling in one leg (DVT risk — painful, warm, red calf)\n'
          '• Swelling with shortness of breath (heart/lung problem)\n'
          '• Swelling with severe headache in pregnancy (pre-eclampsia)\n'
          '• Pitting oedema (pressing leaves an indentation that stays)\n'
          '• Swelling with skin changes or non-healing wounds\n\n'
          '_Bilateral (both legs) swelling is usually systemic; one-sided swelling is more concerning for DVT._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 49. URINARY TRACT INFECTION (UTI)
    // ─────────────────────────────────────────────────────────────────────
    if ((q.contains('urine') && (q.contains('burn') || q.contains('pain') || q.contains('smell') || q.contains('frequent'))) ||
        q.contains('uti') || q.contains('urinary tract') || q.contains('bladder infection') ||
        q.contains('burning urination') || q.contains('peshab mein jalan') ||
        q.contains('frequent urination')) {
      return '💧 **Urinary Tract Infection (UTI)**\n\n'
          '**Symptoms:**\n'
          '• Burning or pain when urinating\n'
          '• Frequent urge to urinate (even when bladder is nearly empty)\n'
          '• Cloudy, dark, or strong-smelling urine\n'
          '• Pelvic pain (in women) or rectal pressure (in men)\n'
          '• Low-grade fever (if infection has reached kidneys: high fever + back pain)\n\n'
          '**Home care (mild UTI):**\n'
          '• Drink 2.5–3 litres water daily — flush bacteria out\n'
          '• Unsweetened cranberry juice may help prevent recurrence\n'
          '• Avoid holding urine — go as soon as you feel the urge\n'
          '• Avoid caffeine, alcohol, and spicy food (irritate bladder)\n\n'
          '**Treatment:** Antibiotics are required — see a doctor for:\n'
          '• Nitrofurantoin or Trimethoprim/Sulfamethoxazole (urine culture guides choice)\n'
          '• Phenazopyridine (Pyridium) numbs urinary tract for pain relief (turns urine orange)\n\n'
          '**Prevention:**\n'
          '• Wipe front to back after toilet (women)\n'
          '• Urinate after sexual intercourse\n'
          '• Avoid harsh soaps or douches in the genital area\n'
          '• Wear cotton underwear\n\n'
          '🚨 **See a doctor immediately if:**\n'
          '• High fever, chills, severe back/flank pain (kidney infection / pyelonephritis)\n'
          '• Blood in urine\n'
          '• UTI in a child, pregnant woman, or man (unusual and needs investigation)\n\n'
          '_Untreated UTI can spread to kidneys — always complete the antibiotic course._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // 50. GREETING / GENERAL (checked last)
    // ─────────────────────────────────────────────────────────────────────
    if (q == 'hi' || q == 'hello' || q.startsWith('hi ') || q.startsWith('hello ') ||
        q.contains('नमस्ते') || q.contains('namaste') || q.contains('namaskar') ||
        q.contains('help') || q.contains('what can you') || q.contains('topics') ||
        q.contains('what do you know') || q.startsWith('hey')) {
      return '🤖 **Hello! I\'m your AI Medical Assistant**\n\n'
          '📵 _Offline mode — limited responses available_\n\n'
          '**I can help with these 50 health topics:**\n\n'
          '🚨 Emergency • 🌡️ Fever • 🤕 Headache • 😷 Cough/Cold\n'
          '🩺 Diabetes • 💊 Medicines • 💙 Mental Health • 🤰 Pregnancy\n'
          '🩺 Blood Pressure • 💨 Asthma • 🦋 Thyroid • 🤢 Stomach\n'
          '🧴 Skin/Allergy • 👁️ Eyes • 🥗 Nutrition • 👶 Child/Vaccine\n'
          '🦴 Joint Pain • 🩸 Anaemia • 🦷 Dental • 🏃 Exercise\n'
          '🧬 Cancer • 🫀 Cholesterol • 🤧 Flu • 🧪 Typhoid • 🦟 Malaria/Dengue\n'
          '💉 HIV/AIDS • 🫁 TB • 🧠 Epilepsy • 🫘 Kidney • 🫀 Liver\n'
          '🤱 Breastfeeding • 🧒 Puberty • 👴 Elderly • 💊 Vitamins\n'
          '🌞 Dehydration • 🔥 Burns • 🐍 Snakebite • 🦴 Fracture\n'
          '😴 Fatigue • 🤧 Sinusitis • 💧 ORS • 🏥 First Aid • 🦠 COVID-19\n'
          '🦠 Wound Infection • 🩹 Wound Care • 🩸 Menstrual • 🫀 Palpitations\n'
          '🦶 Swollen Feet • 💧 UTI\n\n'
          '_Just describe your symptoms or type any health question._\n'
          '⚠️ _This AI provides general information only. Always consult a qualified healthcare professional._';
    }

    // ─────────────────────────────────────────────────────────────────────
    // DEFAULT FALLBACK
    // ─────────────────────────────────────────────────────────────────────
    return '🤖 **I\'m here to help with your health questions!**\n\n'
        '📵 _You\'re offline — limited responses available_\n\n'
        'Please describe your symptoms or health question in more detail.\n\n'
        '**I cover these topics offline:**\n'
        '🚨 Emergency • 🌡️ Fever • 🤕 Headache • 😷 Cough\n'
        '🩺 Diabetes • 💊 Medicines • 💙 Mental Health • 🤰 Pregnancy\n'
        '🩺 Blood Pressure • 💨 Asthma • 🦋 Thyroid • 🤢 Stomach\n'
        '🧴 Skin • 👁️ Eyes • 🥗 Nutrition • 👶 Child Health\n'
        '🦴 Joints • 🩸 Anaemia • 🦷 Dental • 🏃 Exercise\n'
        '🦟 Malaria/Dengue • 🫁 TB • 🧠 Epilepsy • 🫘 Kidney\n'
        '🏥 First Aid • 🦠 COVID-19 • 🩸 Menstrual • 💧 UTI\n'
        '...and 20+ more!\n\n'
        '⚠️ _This AI provides general health information only._\n'
        '_Always consult a qualified healthcare professional for diagnosis and treatment._';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: build an offline ChatMessageModel from a raw response string
  // ─────────────────────────────────────────────────────────────────────────
  static ChatMessageModel botMessageFor(String message) {
    return ChatMessageModel(
      id: 'bot-offline-${DateTime.now().millisecondsSinceEpoch}',
      text: responseFor(message),
      sender: ChatSender.bot,
      createdAt: DateTime.now(),
      isOnlineMode: false,
      confidence: 0.5,
    );
  }
}
