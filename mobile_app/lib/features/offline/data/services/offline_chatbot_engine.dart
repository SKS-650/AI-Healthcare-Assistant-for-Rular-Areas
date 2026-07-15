/// Offline Medical Chatbot Engine.
///
/// Pipeline:
///   User Question
///       ↓  keyword extraction
///       ↓  category detection
///       ↓  local knowledge-base retrieval
///       ↓  template-based response generation
///
/// No internet required. Covers: symptom queries, disease info,
/// nutrition questions, medication reminders, emergency advice,
/// mental health, preventive care.
library;

// ─────────────────────────────────────────────────────────────────────────────
// Knowledge base
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, Map<String, String>> _knowledgeBase = {
  // ── Emergency ──────────────────────────────────────────────────────────────
  'emergency': {
    'title': 'Emergency Guidance',
    'answer':
        '🚨 **Emergency Response**\n\n'
        'If you or someone nearby is experiencing a medical emergency:\n\n'
        '• **Call 108 (Ambulance)** or **112 (Emergency)** immediately\n'
        '• Stay calm and follow the operator instructions\n'
        '• Do NOT move someone with a suspected spinal injury\n'
        '• For chest pain → loosen tight clothing, sit upright\n'
        '• For bleeding → apply firm pressure with clean cloth\n'
        '• For unconscious person → check breathing, place in recovery position\n\n'
        '_This is offline guidance. Always contact emergency services first._',
  },

  // ── Fever ──────────────────────────────────────────────────────────────────
  'fever': {
    'title': 'Managing Fever',
    'answer':
        '🌡️ **Fever Information**\n\n'
        'Normal body temperature: 36.1–37.2 °C (97–99 °F)\n\n'
        '**When to be concerned:**\n'
        '• Adults: > 39.4 °C (103 °F)\n'
        '• Children: > 38 °C (100.4 °F) — seek care immediately\n'
        '• Fever lasting > 3 days\n\n'
        '**Home management:**\n'
        '• Stay hydrated — drink 8–10 glasses of water/day\n'
        '• Rest in a cool room\n'
        '• Paracetamol (500 mg) every 6 hours for adults\n'
        '• Lukewarm sponge bath to bring temperature down\n\n'
        '**See a doctor if:**\n'
        '• Severe headache, stiff neck, or rash appears\n'
        '• Difficulty breathing or chest pain\n'
        '• Confusion or seizures',
  },

  // ── Cough ──────────────────────────────────────────────────────────────────
  'cough': {
    'title': 'Cough Management',
    'answer':
        '😷 **Cough Information**\n\n'
        '**Types:**\n'
        '• Dry cough — no mucus, often viral\n'
        '• Wet/productive cough — mucus present\n'
        '• Persistent cough (> 3 weeks) — needs investigation\n\n'
        '**Home remedies:**\n'
        '• Honey + ginger tea (natural antitussive)\n'
        '• Steam inhalation with eucalyptus oil\n'
        '• Salt water gargle (½ tsp salt in warm water)\n'
        '• Stay well hydrated\n\n'
        '**Seek care if:**\n'
        '• Coughing up blood\n'
        '• High fever accompanies cough\n'
        '• Shortness of breath or chest pain',
  },

  // ── Headache ───────────────────────────────────────────────────────────────
  'headache': {
    'title': 'Headache Relief',
    'answer':
        '🧠 **Headache Information**\n\n'
        '**Common causes:** tension, dehydration, eye strain, migraine, sinusitis\n\n'
        '**Immediate relief:**\n'
        '• Drink 2 glasses of water (dehydration is the #1 cause)\n'
        '• Rest in a dark quiet room\n'
        '• Cold or warm compress on forehead/neck\n'
        '• Paracetamol 500–1000 mg (adults)\n\n'
        '**Red flag symptoms — see doctor immediately:**\n'
        '• Sudden severe "thunderclap" headache\n'
        '• Headache with stiff neck and fever (meningitis)\n'
        '• Headache after head injury\n'
        '• Headache with vision changes or confusion',
  },

  // ── Diabetes ───────────────────────────────────────────────────────────────
  'diabetes': {
    'title': 'Diabetes Management',
    'answer':
        '🩸 **Diabetes Information**\n\n'
        '**Warning signs:**\n'
        'Excessive thirst, frequent urination, fatigue, blurred vision, slow-healing wounds\n\n'
        '**Daily management:**\n'
        '• Monitor blood sugar regularly\n'
        '• Take medication/insulin as prescribed\n'
        '• Low-GI diet: whole grains, vegetables, legumes\n'
        '• 30 minutes of moderate exercise daily\n'
        '• Check feet daily for wounds\n\n'
        '**Hypoglycaemia (low sugar) — act fast:**\n'
        '• Drink juice or glucose water\n'
        '• Eat 3–4 glucose tablets\n'
        '• If unconscious → call emergency immediately\n\n'
        '**Regular check-ups:** HbA1c every 3 months, eye exam annually',
  },

  // ── Hypertension ───────────────────────────────────────────────────────────
  'blood pressure': {
    'title': 'Blood Pressure Management',
    'answer':
        '💊 **Blood Pressure Information**\n\n'
        '**Normal:** < 120/80 mmHg\n'
        '**High (Hypertension):** ≥ 130/80 mmHg\n'
        '**Crisis:** ≥ 180/120 mmHg → emergency care needed\n\n'
        '**Lifestyle changes:**\n'
        '• Reduce salt intake (< 5 g/day)\n'
        '• DASH diet: fruits, vegetables, whole grains, low-fat dairy\n'
        '• Exercise 30 min/day, 5 days/week\n'
        '• Quit smoking and limit alcohol\n'
        '• Manage stress (yoga, meditation)\n\n'
        '**Take medication as prescribed** — never stop without consulting your doctor',
  },

  // ── Malaria ────────────────────────────────────────────────────────────────
  'malaria': {
    'title': 'Malaria Information',
    'answer':
        '🦟 **Malaria Information**\n\n'
        '**Symptoms:** High fever with chills, sweating, headache, nausea, body aches\n\n'
        '**Prevention (very important in rural areas):**\n'
        '• Sleep under insecticide-treated mosquito nets\n'
        '• Use mosquito repellent (DEET-based)\n'
        '• Wear long-sleeved clothing at dusk/dawn\n'
        '• Eliminate stagnant water near home\n'
        '• Take prophylaxis medication if traveling to endemic areas\n\n'
        '**Treatment:**\n'
        'Artemisinin-based Combination Therapy (ACT) — prescribed by doctor\n\n'
        '**Seek care immediately** — untreated malaria can be fatal within 24–48 hours',
  },

  // ── Nutrition ─────────────────────────────────────────────────────────────
  'nutrition': {
    'title': 'Nutrition Basics',
    'answer':
        '🥗 **Nutrition Guide**\n\n'
        '**Balanced diet (daily):**\n'
        '• 3–5 servings of vegetables\n'
        '• 2–4 servings of fruits\n'
        '• 6–8 glasses of clean water\n'
        '• Whole grains over refined carbs\n'
        '• Lean protein: lentils, eggs, fish, chicken\n\n'
        '**Important nutrients:**\n'
        '• Iron: spinach, lentils, meat (prevents anaemia)\n'
        '• Calcium: dairy, ragi, greens (bone health)\n'
        '• Vitamin D: sunlight exposure + fortified foods\n'
        '• Iodine: iodised salt (prevents thyroid issues)\n\n'
        '**Avoid:** excessive salt, sugar, processed foods, trans fats',
  },

  // ── Child health ───────────────────────────────────────────────────────────
  'child': {
    'title': 'Child Health',
    'answer':
        '👶 **Child Health Guide**\n\n'
        '**Vaccination schedule (India):**\n'
        '• Birth: BCG, OPV, Hepatitis B\n'
        '• 6 weeks: DPT, IPV, Hib, Rotavirus, PCV\n'
        '• 9 months: Measles (MR vaccine)\n'
        '• 18 months: DPT booster, OPV, MR 2nd dose\n\n'
        '**Danger signs in infants — emergency:**\n'
        '• Not feeding / very sleepy\n'
        '• High fever (> 38°C in < 3 months)\n'
        '• Difficulty breathing, blue lips\n'
        '• Convulsions\n\n'
        '**Growth monitoring:** Weight check monthly for children under 2',
  },

  // ── Mental health ─────────────────────────────────────────────────────────
  'mental health': {
    'title': 'Mental Health Support',
    'answer':
        '🧠 **Mental Health Information**\n\n'
        'Mental health is as important as physical health.\n\n'
        '**Signs you may need support:**\n'
        '• Persistent sadness or hopelessness\n'
        '• Loss of interest in activities\n'
        '• Sleep problems or excessive sleeping\n'
        '• Difficulty concentrating\n'
        '• Feeling worthless or excessive guilt\n\n'
        '**Self-care strategies:**\n'
        '• Talk to someone you trust\n'
        '• Regular sleep schedule\n'
        '• Physical activity (even a short walk helps)\n'
        '• Limit social media / news intake\n'
        '• Practice deep breathing or meditation\n\n'
        '**India crisis helplines:**\n'
        '• iCall: 9152987821\n'
        '• Vandrevala Foundation: 1860-2662-345\n'
        '• NIMHANS: 080-46110007',
  },

  // ── Prenatal ──────────────────────────────────────────────────────────────
  'pregnancy': {
    'title': 'Pregnancy Care',
    'answer':
        '🤰 **Pregnancy Care Guide**\n\n'
        '**Essential visits:** At least 4 antenatal visits\n\n'
        '**Danger signs — go to hospital immediately:**\n'
        '• Severe headache + blurred vision\n'
        '• Heavy vaginal bleeding\n'
        '• Baby not moving for 12+ hours\n'
        '• High fever\n'
        '• Swelling of face/hands\n\n'
        '**Nutrition during pregnancy:**\n'
        '• Folic acid 400 mcg/day (reduces neural tube defects)\n'
        '• Iron + calcium supplements as prescribed\n'
        '• Avoid raw/undercooked meat, unpasteurised dairy\n'
        '• Drink 10–12 glasses of water daily\n\n'
        '**Vaccinations:** TT (Tetanus Toxoid) — 2 doses recommended',
  },

  // ── First aid ─────────────────────────────────────────────────────────────
  'first aid': {
    'title': 'Basic First Aid',
    'answer':
        '🩹 **Basic First Aid**\n\n'
        '**Wound care:**\n'
        '1. Wash hands\n'
        '2. Apply pressure to stop bleeding\n'
        '3. Clean with clean water or saline\n'
        '4. Apply antiseptic (betadine)\n'
        '5. Cover with bandage\n'
        '6. See doctor if wound is deep or doesn\'t stop bleeding\n\n'
        '**Burns:**\n'
        '• Cool with running water for 10–20 min\n'
        '• Do NOT apply ice, butter, or toothpaste\n'
        '• Cover with clean bandage\n\n'
        '**Snake bite:**\n'
        '• Keep calm and immobilise the limb\n'
        '• DO NOT cut wound, suck venom, or apply tourniquet\n'
        '• Rush to nearest hospital with anti-venom\n\n'
        '**Choking (Heimlich manoeuvre):**\n'
        '• 5 back blows between shoulder blades\n'
        '• 5 abdominal thrusts',
  },
};

// ── Keyword → category mapping ────────────────────────────────────────────────
const Map<String, List<String>> _keywordMap = {
  'emergency':      ['emergency', 'critical', 'dying', 'unconscious', 'collapse',
                     'heart attack', 'stroke', 'poison', 'accident'],
  'fever':          ['fever', 'temperature', 'hot', 'chills', 'shivering'],
  'cough':          ['cough', 'coughing', 'throat', 'phlegm', 'mucus', 'bronchitis'],
  'headache':       ['headache', 'head pain', 'migraine', 'head hurts'],
  'diabetes':       ['diabetes', 'blood sugar', 'insulin', 'glucose', 'diabetic'],
  'blood pressure': ['blood pressure', 'hypertension', 'bp', 'heart', 'cardiac'],
  'malaria':        ['malaria', 'mosquito', 'plasmodium'],
  'nutrition':      ['diet', 'nutrition', 'food', 'eat', 'eating', 'vitamin',
                     'minerals', 'calories', 'weight', 'obesity'],
  'child':          ['child', 'baby', 'infant', 'newborn', 'toddler', 'vaccination',
                     'vaccine', 'immunisation'],
  'mental health':  ['mental', 'depression', 'anxiety', 'stress', 'sad', 'worry',
                     'panic', 'sleep', 'insomnia', 'trauma'],
  'pregnancy':      ['pregnant', 'pregnancy', 'antenatal', 'prenatal', 'foetus', 'fetus'],
  'first aid':      ['first aid', 'wound', 'cut', 'burn', 'bleeding', 'snake', 'bite',
                     'choking', 'fracture', 'sprain'],
};

// ─────────────────────────────────────────────────────────────────────────────
// Engine class
// ─────────────────────────────────────────────────────────────────────────────

class OfflineChatbotEngine {
  const OfflineChatbotEngine();

  /// Returns an offline answer for [question].
  OfflineChatResponse answer(String question) {
    final lower = question.toLowerCase();

    // 1. Keyword-based category detection
    String? matchedCategory;
    int bestScore = 0;

    _keywordMap.forEach((category, keywords) {
      int score = 0;
      for (final kw in keywords) {
        if (lower.contains(kw)) score++;
      }
      if (score > bestScore) {
        bestScore    = score;
        matchedCategory = category;
      }
    });

    if (matchedCategory != null && bestScore > 0) {
      final category = matchedCategory!;
      final entry = _knowledgeBase[category]!;
      return OfflineChatResponse(
        answer:    entry['answer']!,
        title:     entry['title']!,
        category:  category,
        isOffline: true,
        confidence: (bestScore / (_keywordMap[category]!.length)).clamp(0.1, 1.0),
      );
    }

    // 2. Fallback — generic health guidance
    return OfflineChatResponse(
      answer: '🏥 **Medical Information (Offline Mode)**\n\n'
          'I\'m currently in offline mode and couldn\'t find a specific answer for your question.\n\n'
          '**I can help you with:**\n'
          '• Fever management 🌡️\n'
          '• Cough & cold care 😷\n'
          '• Diabetes guidance 🩸\n'
          '• Blood pressure information 💊\n'
          '• Malaria prevention 🦟\n'
          '• Nutrition & diet 🥗\n'
          '• Child health & vaccines 👶\n'
          '• Mental health support 🧠\n'
          '• Emergency first aid 🩹\n\n'
          'Please try asking about one of these topics, or connect to the internet for AI-powered answers.',
      title:    'Offline Health Assistant',
      category: 'general',
      isOffline: true,
      confidence: 0.0,
    );
  }

  /// Quick symptom triage — returns risk level string.
  String triageSymptoms(List<String> symptoms) {
    final lower = symptoms.map((s) => s.toLowerCase()).toList();
    final hasEmergency = lower.any((s) => [
          'chest pain', 'shortness of breath', 'difficulty breathing',
          'unconscious', 'seizure', 'stroke', 'coughing blood',
        ].any((e) => s.contains(e)));

    if (hasEmergency) return 'critical';
    if (symptoms.length >= 5) return 'high';
    if (symptoms.length >= 3) return 'medium';
    return 'low';
  }
}

class OfflineChatResponse {
  const OfflineChatResponse({
    required this.answer,
    required this.title,
    required this.category,
    required this.isOffline,
    required this.confidence,
  });

  final String answer;
  final String title;
  final String category;
  final bool   isOffline;
  final double confidence;
}
