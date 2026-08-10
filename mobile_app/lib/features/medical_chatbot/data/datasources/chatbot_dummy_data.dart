import '../models/chat_message_model.dart';
import '../models/chatbot_settings_model.dart';
import '../models/conversation_model.dart';
import '../models/language_model.dart';
import '../models/suggestion_model.dart';
import '../../domain/entities/chat_message.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ChatbotDummyData
// Offline engine with 100 structured health topic handlers.
// Keywords cover all 4 supported languages:
//   EN = English | HI = Hindi | NE = Nepali | BHO = Bhojpuri
// Response format: 🏷️ Title → 📖 Overview → 📋 Sections → 🚨 Warning signs → ⚠️ Disclaimer
// ═══════════════════════════════════════════════════════════════════════════════
class ChatbotDummyData {

  // ── Languages ──────────────────────────────────────────────────────────────
  static const languages = [
    LanguageModel(code: 'en',  name: 'English',  nativeName: 'English',  flag: '🇬🇧'),
    LanguageModel(code: 'hi',  name: 'Hindi',    nativeName: 'हिंदी',    flag: '🇮🇳'),
    LanguageModel(code: 'ne',  name: 'Nepali',   nativeName: 'नेपाली',   flag: '🇳🇵'),
    LanguageModel(code: 'bho', name: 'Bhojpuri', nativeName: 'भोजपुरी',  flag: '🗣️'),
  ];

  static const settings = ChatbotSettingsModel(
    language: LanguageModel(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
  );

  static LanguageModel languageFromCode(String code) =>
      languages.firstWhere((l) => l.code == code, orElse: () => languages.first);

  // ── Welcome message ────────────────────────────────────────────────────────
  static final welcomeMessage = ChatMessageModel(
    id: 'message-welcome',
    text: '🤖 **Namaste! I am your AI Medical Assistant 🩺**\n\n'
        '💬 Ask me in any language:\n'
        '🇬🇧 English | 🇮🇳 हिंदी | 🇳🇵 नेपाली | 🗣️ भोजपुरी\n\n'
        '📋 I can help with:\n'
        '• 🤒 Symptoms & diseases\n'
        '• 💊 Medicines & dosages\n'
        '• 🥗 Nutrition & diet\n'
        '• 🏃 Exercise & fitness\n'
        '• 🤰 Pregnancy & child care\n'
        '• 🧠 Mental health\n'
        '• 🚨 Emergency first aid\n\n'
        '⚠️ _General information only — always consult a qualified doctor for diagnosis._',
    sender: ChatSender.bot,
    createdAt: DateTime.now(),
  );

  // ── Online suggestion chips (8 shown when online) ──────────────────────────
  static final suggestions = [
    const SuggestionModel(id: 's1', text: '🌡️ I have fever',              category: 'Symptoms'),
    const SuggestionModel(id: 's2', text: '🤕 Headache relief',           category: 'Care'),
    const SuggestionModel(id: 's3', text: '💊 Paracetamol dosage',        category: 'Medicine'),
    const SuggestionModel(id: 's4', text: '🥗 Diet for diabetes',         category: 'Nutrition'),
    const SuggestionModel(id: 's5', text: '🤰 Pregnancy nutrition',       category: 'Pregnancy'),
    const SuggestionModel(id: 's6', text: '👶 Child vaccination',         category: 'Child'),
    const SuggestionModel(id: 's7', text: '🚨 Heart attack first aid',    category: 'Emergency'),
    const SuggestionModel(id: 's8', text: '💙 Stress and anxiety help',   category: 'Mental'),
  ];

  // ── Offline suggestion chips — all 100 topics shown when offline ───────────
  static final offlineSuggestions = [
    // ── Emergency & Critical ──
    const SuggestionModel(id: 'o01', text: '🚨 Emergency / Heart attack',       category: 'Emergency'),
    const SuggestionModel(id: 'o02', text: '🐍 Snakebite & poisoning',          category: 'Emergency'),
    const SuggestionModel(id: 'o03', text: '🔥 Burns & wound first aid',        category: 'First Aid'),
    const SuggestionModel(id: 'o04', text: '🏥 Basic first aid / CPR',          category: 'First Aid'),
    const SuggestionModel(id: 'o05', text: '🌡️ Heat stroke',                    category: 'Emergency'),
    const SuggestionModel(id: 'o06', text: '🐕 Dog bite & rabies',              category: 'Emergency'),
    // ── Common Symptoms ──
    const SuggestionModel(id: 'o07', text: '🌡️ I have fever / bukhar',          category: 'Symptoms'),
    const SuggestionModel(id: 'o08', text: '🤕 Headache / sar dard',            category: 'Symptoms'),
    const SuggestionModel(id: 'o09', text: '😷 Cough & cold / khasi sardi',     category: 'Symptoms'),
    const SuggestionModel(id: 'o10', text: '🤢 Stomach pain / pet dard',        category: 'Symptoms'),
    const SuggestionModel(id: 'o11', text: '😴 Fatigue & weakness / kamzori',   category: 'Symptoms'),
    const SuggestionModel(id: 'o12', text: '🌀 Dizziness / vertigo / chakkar',  category: 'Symptoms'),
    const SuggestionModel(id: 'o13', text: '👁️ Eye redness / aankhon mein dard',category: 'Symptoms'),
    const SuggestionModel(id: 'o14', text: '👂 Ear pain / kaan dard',           category: 'Symptoms'),
    const SuggestionModel(id: 'o15', text: '🫀 Heart palpitations / dhak dhak', category: 'Symptoms'),
    const SuggestionModel(id: 'o16', text: '🤧 Sinusitis / naak band',          category: 'Symptoms'),
    const SuggestionModel(id: 'o17', text: '🔔 Tinnitus / kaan mein awaz',      category: 'Symptoms'),
    const SuggestionModel(id: 'o18', text: '💧 Urinary burning / peshab jalan', category: 'Symptoms'),
    const SuggestionModel(id: 'o19', text: '🦶 Swollen feet / pair sujan',      category: 'Symptoms'),
    const SuggestionModel(id: 'o20', text: '🧴 Skin rash / khujli / daad',      category: 'Symptoms'),
    // ── Chronic Diseases ──
    const SuggestionModel(id: 'o21', text: '🩺 Diabetes / madhumeha / sugar',   category: 'Disease'),
    const SuggestionModel(id: 'o22', text: '🩺 Blood pressure / BP / dawab',    category: 'Disease'),
    const SuggestionModel(id: 'o23', text: '💨 Asthma / dam / inhaler',         category: 'Disease'),
    const SuggestionModel(id: 'o24', text: '🦋 Thyroid / TSH / gardan gaanth',  category: 'Disease'),
    const SuggestionModel(id: 'o25', text: '🫀 High cholesterol / lipid',       category: 'Disease'),
    const SuggestionModel(id: 'o26', text: '🦴 Joint pain / arthritis / gathiya',category: 'Disease'),
    const SuggestionModel(id: 'o27', text: '🧠 Epilepsy / seizure / mirgi',     category: 'Disease'),
    const SuggestionModel(id: 'o28', text: '🫘 Kidney / gurda / pathri',        category: 'Disease'),
    const SuggestionModel(id: 'o29', text: '🫀 Liver / jaundice / kamla rog',   category: 'Disease'),
    const SuggestionModel(id: 'o30', text: '🧬 Cancer warning signs',           category: 'Disease'),
    const SuggestionModel(id: 'o31', text: '🩸 Anaemia / khoon ki kami / rakt', category: 'Disease'),
    const SuggestionModel(id: 'o32', text: '🦠 COVID-19 symptoms & care',       category: 'Disease'),
    const SuggestionModel(id: 'o33', text: '🦟 Malaria / dengue / machhar',     category: 'Disease'),
    const SuggestionModel(id: 'o34', text: '🧪 Typhoid / enteric fever / masar',category: 'Disease'),
    const SuggestionModel(id: 'o35', text: '🫁 Tuberculosis TB / kshay rog',    category: 'Disease'),
    const SuggestionModel(id: 'o36', text: '💉 HIV / AIDS information',         category: 'Disease'),
    const SuggestionModel(id: 'o37', text: '🫀 Chest tightness / seene mein dard',category: 'Disease'),
    const SuggestionModel(id: 'o38', text: '🦠 Chickenpox / varicella / chechak',category: 'Disease'),
    const SuggestionModel(id: 'o39', text: '🦠 Measles / khasra / rubeola',     category: 'Disease'),
    const SuggestionModel(id: 'o40', text: '😫 Back pain / kamar dard / piṭh',  category: 'Disease'),
    // ── Infections & Parasites ──
    const SuggestionModel(id: 'o41', text: '🦠 Scabies / khaaj / khujli rog',   category: 'Infection'),
    const SuggestionModel(id: 'o42', text: '🪲 Head lice / joon / jhau',        category: 'Infection'),
    const SuggestionModel(id: 'o43', text: '🤢 Food poisoning / khaana kharaab',category: 'Infection'),
    const SuggestionModel(id: 'o44', text: '🦠 Wound infection / ghav sankarman',category: 'First Aid'),
    const SuggestionModel(id: 'o45', text: '🐝 Bee sting / madhumakhi ka dank', category: 'First Aid'),
    // ── Digestive & Abdominal ──
    const SuggestionModel(id: 'o46', text: '💩 Constipation / kabz / kaadhi',   category: 'Digestive'),
    const SuggestionModel(id: 'o47', text: '🩹 Piles / haemorrhoids / bawaseer',category: 'Digestive'),
    const SuggestionModel(id: 'o48', text: '🫙 Appendicitis / appendix dard',   category: 'Digestive'),
    const SuggestionModel(id: 'o49', text: '🫙 Gallstone / pittashaay pathri',  category: 'Digestive'),
    const SuggestionModel(id: 'o50', text: '🩺 Hernia / antra utthan',          category: 'Digestive'),
    // ── Musculoskeletal ──
    const SuggestionModel(id: 'o51', text: '🦴 Fracture & sprain / haddi tootna',category: 'Bone'),
    const SuggestionModel(id: 'o52', text: '😣 Neck pain / gardan dard',        category: 'Bone'),
    const SuggestionModel(id: 'o53', text: '💪 Shoulder pain / kandha dard',    category: 'Bone'),
    const SuggestionModel(id: 'o54', text: '🦴 Osteoporosis / haddi kamzori',   category: 'Bone'),
    // ── Women's Health ──
    const SuggestionModel(id: 'o55', text: '🩸 Menstrual / period / maahwari',  category: 'Women'),
    const SuggestionModel(id: 'o56', text: '🔄 PCOS / irregular periods',       category: 'Women'),
    const SuggestionModel(id: 'o57', text: '🌸 Menopause / ratjog / ravedi',    category: 'Women'),
    const SuggestionModel(id: 'o58', text: '🤰 Pregnancy care / garbhavastha',  category: 'Women'),
    const SuggestionModel(id: 'o59', text: '🤱 Breastfeeding / stan paan',      category: 'Women'),
    // ── Child & Adolescent ──
    const SuggestionModel(id: 'o60', text: '👶 Child vaccination / टीकाकरण',    category: 'Child'),
    const SuggestionModel(id: 'o61', text: '😭 Baby colic / shishu rone',       category: 'Child'),
    const SuggestionModel(id: 'o62', text: '🍑 Diaper rash / langot daane',     category: 'Child'),
    const SuggestionModel(id: 'o63', text: '😬 Teething / dant nikalna',        category: 'Child'),
    const SuggestionModel(id: 'o64', text: '📏 Baby growth milestones',         category: 'Child'),
    const SuggestionModel(id: 'o65', text: '🧒 Puberty / kishore swasthya',     category: 'Child'),
    const SuggestionModel(id: 'o66', text: '🧩 Autism awareness',               category: 'Child'),
    const SuggestionModel(id: 'o67', text: '🌟 Down syndrome information',      category: 'Child'),
    const SuggestionModel(id: 'o68', text: '🩸 Thalassemia / thalasimiya',      category: 'Child'),
    // ── Nutrition & Lifestyle ──
    const SuggestionModel(id: 'o69', text: '🥗 Nutrition & diet / poshan',      category: 'Nutrition'),
    const SuggestionModel(id: 'o70', text: '💊 Vitamin deficiency / kami',      category: 'Nutrition'),
    const SuggestionModel(id: 'o71', text: '💧 ORS & rehydration / jeevan jal', category: 'Medicine'),
    const SuggestionModel(id: 'o72', text: '💊 Medicines guide / dawai',        category: 'Medicine'),
    const SuggestionModel(id: 'o73', text: '⚖️ Obesity & weight loss',          category: 'Lifestyle'),
    const SuggestionModel(id: 'o74', text: '🏃 Exercise & fitness / vyayam',    category: 'Lifestyle'),
    const SuggestionModel(id: 'o75', text: '🧘 Meditation / dhyan / manasik',   category: 'Lifestyle'),
    const SuggestionModel(id: 'o76', text: '🌿 Yoga benefits / yog',            category: 'Lifestyle'),
    const SuggestionModel(id: 'o77', text: '🚬 Smoking / tambaku / cigarette',  category: 'Lifestyle'),
    const SuggestionModel(id: 'o78', text: '🍺 Alcohol / sharaab / madira',     category: 'Lifestyle'),
    const SuggestionModel(id: 'o79', text: '💉 Drug abuse / nasha / lagat',     category: 'Lifestyle'),
    const SuggestionModel(id: 'o80', text: '🌞 Dehydration / paani ki kami',    category: 'Lifestyle'),
    // ── Dental & ENT ──
    const SuggestionModel(id: 'o81', text: '🦷 Toothache / dant dard',          category: 'Dental'),
    const SuggestionModel(id: 'o82', text: '👂 Ear infection / kan pakana',     category: 'ENT'),
    const SuggestionModel(id: 'o83', text: '🔔 Tinnitus / kan mein seeti',      category: 'ENT'),
    // ── Mental Health ──
    const SuggestionModel(id: 'o84', text: '💙 Stress & anxiety / chinta',      category: 'Mental'),
    const SuggestionModel(id: 'o85', text: '😓 Depression / nirasha / udaasi',  category: 'Mental'),
    const SuggestionModel(id: 'o86', text: '😴 Sleep problems / neend nahi',    category: 'Mental'),
    const SuggestionModel(id: 'o87', text: '🧘 Stress management tips',         category: 'Mental'),
    // ── Environmental ──
    const SuggestionModel(id: 'o88', text: '🥵 Heat stroke / loo / garam lagna',category: 'Environment'),
    const SuggestionModel(id: 'o89', text: '🥶 Cold exposure / thanda / seetala',category: 'Environment'),
    const SuggestionModel(id: 'o90', text: '💧 Water quality / paani safai',    category: 'Environment'),
    const SuggestionModel(id: 'o91', text: '🌫️ Air quality / pradushan / dust', category: 'Environment'),
    // ── Elderly & Chronic ──
    const SuggestionModel(id: 'o92', text: '👴 Elderly health / budhapa swasthya',category: 'Elderly'),
    const SuggestionModel(id: 'o93', text: '🫘 Pancreatitis / pancreas dard',   category: 'Disease'),
    const SuggestionModel(id: 'o94', text: '👨 Prostate / purush svasthya',     category: 'Men'),
    const SuggestionModel(id: 'o95', text: '😔 Erectile dysfunction / napunsakta',category: 'Men'),
    // ── Newborn Special ──
    const SuggestionModel(id: 'o96', text: '🟡 Newborn jaundice / neonatal kamla',category: 'Child'),
    const SuggestionModel(id: 'o97', text: '🩸 Sickle cell disease',            category: 'Disease'),
    const SuggestionModel(id: 'o98', text: '🌡️ Flu / influenza / viral bukhar', category: 'Disease'),
    const SuggestionModel(id: 'o99', text: '😫 Neck stiffness / gardan akad',   category: 'Symptoms'),
    const SuggestionModel(id: 'o100',text: '🤖 What can you help with?',        category: 'General'),
  ];

  // ── Conversation scaffolding ───────────────────────────────────────────────
  static ConversationModel initialConversation() => ConversationModel(
    id: 'conversation-current',
    title: 'New Consultation',
    messages: [welcomeMessage],
    updatedAt: DateTime.now(),
  );

  static List<ConversationModel> initialHistory() => [
    ConversationModel(
      id: 'history-1', title: '🤒 Fever and cough',
      messages: [welcomeMessage],
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ConversationModel(
      id: 'history-2', title: '💊 Medicine information',
      messages: [welcomeMessage],
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // OFFLINE RESPONSE ENGINE — 100 structured topic handlers
  // Keywords: EN=English | HI=Hindi | NE=Nepali | BHO=Bhojpuri
  // ═══════════════════════════════════════════════════════════════════════════
  static String responseFor(String message) {
    final q = message.toLowerCase().trim();

    // ─────────────────────────────────────────────────────────────────────────
    // 01 🚨 EMERGENCY — highest priority, checked first
    // EN: emergency, heart attack, chest pain, stroke, unconscious, not breathing, seizure
    // HI: dil ka daura, seene mein dard, behoshi, saans nahi, daura
    // NE: muni dil ko rog, dhadkan rokiyo, behosh, sas rokiyo, fit aayo
    // BHO: dil ke daura, chhati mein dard, behosh ho gail, saans na chale
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('emergency') || q.contains('heart attack') || q.contains('dil ka daura') ||
        q.contains('chest pain') || q.contains('seene mein dard') || q.contains('chhati mein dard') ||
        q.contains('stroke') || q.contains('brain attack') || q.contains('laqwa') ||
        q.contains('unconscious') || q.contains('behosh') || q.contains('behoshi') ||
        q.contains('not breathing') || q.contains('saans nahi') || q.contains('sas rokiyo') ||
        q.contains('seizure') || q.contains('convulsion') || q.contains('daura') ||
        q.contains('fit aayo') || q.contains('mirgi ka daura') || q.contains('haemorrhage') ||
        q.contains('heavy bleeding') || q.contains('zyada khoon')) {
      return '🚨 **MEDICAL EMERGENCY — तुरंत कार्रवाई करें / ACT NOW**\n\n'
          '📞 **Emergency helplines / आपातकालीन नंबर:**\n'
          '• 🇮🇳 India: **108** (Ambulance) | **112** (Universal)\n'
          '• 🇳🇵 Nepal: **102** (Ambulance) | **112** (Universal)\n'
          '• 🏥 Nearest hospital — do NOT wait\n\n'
          '🩹 **While waiting / प्रतीक्षा के दौरान:**\n'
          '• 🛑 Keep person calm and still — हिलाएं नहीं\n'
          '• 👔 Loosen tight clothing around neck and chest\n'
          '• 🚫 Do NOT give food or water\n'
          '• 🔄 Unconscious + breathing → recovery position (on side)\n'
          '• 💓 Not breathing → CPR: 30 chest compressions + 2 rescue breaths\n'
          '• 🩸 Severe bleeding → firm direct pressure with clean cloth\n\n'
          '⚠️ **हर सेकंड मायने रखता है — Call 108 NOW**\n'
          '_This AI cannot replace emergency care._';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 02 🌡️ FEVER
    // EN: fever, high temperature, hot body
    // HI: bukhar, bukhaar, tez bukhaar, jwar, garmi
    // NE: jwaro, taato, jwara, sajha
    // BHO: bukhar baa, tez bukhar, garmi laagal baa
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('fever') || q.contains('bukhar') || q.contains('bukhaar') ||
        q.contains('tez bukhaar') || q.contains('jwaro') || q.contains('jwara') ||
        q.contains('taato') || q.contains('jwar') || q.contains('temperature') ||
        q.contains('garmi laagal') || q.contains('hot body') || q.contains('tez tap')) {
      return '🌡️ **Fever / बुखार / ज्वरो**\n\n'
          '📊 **Reference / सन्दर्भ:**\n'
          '• ✅ Normal: 36.1–37.2°C (97–99°F)\n'
          '• 🔴 Fever: ≥ 38°C (100.4°F)\n'
          '• 🆘 High fever: > 39.5°C (103°F) — see doctor\n\n'
          '💧 **What to do / क्या करें:**\n'
          '• 🛌 Rest — शरीर को आराम दें\n'
          '• 💧 Drink plenty of fluids: water, ORS, coconut water, soup\n'
          '• 💊 Paracetamol 500 mg if temp > 38.5°C (adult)\n'
          '• 🧊 Cool damp cloth on forehead — माथे पर ठंडा कपड़ा\n'
          '• 👕 Wear light clothing — हल्के कपड़े पहनें\n'
          '• 🚫 Avoid heavy blankets — they trap heat\n\n'
          '🔍 **Common causes / सामान्य कारण:**\n'
          'Flu 🤧, Cold 😷, COVID-19 🦠, Typhoid 🧪, Malaria 🦟, UTI 💧\n\n'
          '🚨 **See doctor immediately / तुरंत डॉक्टर दिखाएं:**\n'
          '• 🌡️ Temp > 39.5°C | 👶 Baby under 3 months\n'
          '• 💢 Fever + rash / stiff neck / confusion\n'
          '• 📅 Fever not improving after 3 days\n\n'
          '_⚠️ Consult a healthcare professional for diagnosis._';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 03 🤕 HEADACHE / MIGRAINE
    // EN: headache, migraine, head pain, throbbing head
    // HI: sar dard, sir dard, aadha sir dard, madhyantar
    // NE: टाउको दुख्छ, tauko dukha, aadha tauko
    // BHO: matha dukhai, sar mein dard, adhkepari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('headache') || q.contains('sar dard') || q.contains('sir dard') ||
        q.contains('टाउको') || q.contains('tauko dukha') || q.contains('migraine') ||
        q.contains('matha dukhai') || q.contains('head pain') || q.contains('aadha sir') ||
        q.contains('adhkepari') || q.contains('throbbing head') || q.contains('siro dukha')) {
      return '🤕 **Headache & Migraine / सिर दर्द / टाउको दुख्छ**\n\n'
          '⚡ **Immediate relief / तुरंत राहत:**\n'
          '• 💧 Drink 2–3 glasses of water — dehydration is #1 cause\n'
          '• 🛏️ Rest in a quiet, dark, cool room — अँधेरे कमरे में लेटें\n'
          '• 🧊 Cold compress on forehead OR warm compress on neck\n'
          '• 📵 Avoid screens and bright lights\n'
          '• 🤲 Gently massage temples in circular motion\n\n'
          '💊 **Medicines / दवाइयां:**\n'
          '• Paracetamol 500 mg or Ibuprofen 400 mg (with food)\n'
          '• Migraine: take medicine at first sign of aura\n\n'
          '🔍 **Common triggers / सामान्य कारण:**\n'
          'Dehydration 💧 | Stress 😰 | Poor sleep 😴 | Skipped meals 🍽️\n'
          'Eye strain 👁️ | Caffeine withdrawal ☕ | Bright light 💡\n\n'
          '🚨 **Emergency — Call 108 if:**\n'
          '• ⚡ Sudden "thunderclap" headache — worst ever\n'
          '• 🌡️ Headache + fever + stiff neck (meningitis risk)\n'
          '• 👁️ Vision loss / slurred speech / weakness\n'
          '• 🤕 After head injury\n\n'
          '_⚠️ Consult doctor for recurring or worsening headaches._';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 04 😷 COUGH / COLD / SORE THROAT
    // EN: cough, cold, runny nose, sneezing, sore throat, congestion
    // HI: khansi, khasi, sardi, nazla, gala dard, naak bana
    // NE: khoki, rughā, naak bagna, ghāntī dukhāi, sardikhoki
    // BHO: khansi baa, sardi lagal, naak bahata, gala dukhata
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('cough') || q.contains('khansi') || q.contains('khasi') ||
        q.contains('cold') || q.contains('sardi') || q.contains('nazla') ||
        q.contains('runny nose') || q.contains('naak bagna') || q.contains('naak bana') ||
        q.contains('sneezing') || q.contains('sore throat') || q.contains('gala dard') ||
        q.contains('ghāntī') || q.contains('khoki') || q.contains('rughā') ||
        q.contains('congestion') || q.contains('naak band') || q.contains('blocked nose')) {
      return '😷 **Cough & Cold / खांसी-सर्दी / खोकी-रुघा**\n\n'
          '🏠 **Home remedies / घरेलू उपाय:**\n'
          '• 🍯 Honey + warm water / ginger tea — soothes throat गला राहत\n'
          '• 💨 Steam inhalation (hot water + towel) — भाप लें\n'
          '• 🧂 Warm saline gargle — गर्म नमक पानी से गरारे\n'
          '• 💧 Saline nasal drops — नाक में नमकीन बूंदें\n'
          '• ☕ Warm fluids thin mucus — गर्म पेय पदार्थ\n'
          '• 🚫 Avoid cold drinks, smoke, dust\n\n'
          '💊 **Medicines / दवाइयां:**\n'
          '• Paracetamol — fever & throat pain\n'
          '• Cetrizine 10 mg — runny nose / sneezing\n'
          '• Dry cough → suppressant | Wet cough → expectorant\n\n'
          '🚨 **See doctor if / डॉक्टर दिखाएं अगर:**\n'
          '• 📅 Cough > 2 weeks | 🩸 Blood in cough\n'
          '• 😮‍💨 Difficulty breathing | 🌡️ High fever > 38.5°C\n'
          '• 😟 Chest pain while coughing\n\n'
          '_Persistent cough may indicate TB 🫁, asthma 💨, or GERD._';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 05 🩺 DIABETES
    // EN: diabetes, blood sugar, insulin, glucose, diabetic, sweet urine
    // HI: madhumeha, shakar ki bimari, blood sugar, insulin, meetha peshab
    // NE: madhumeha, rakta chini, shakar rog, insolin
    // BHO: madhumeha, meetha rog, khoon mein meetha, sugar ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('diabetes') || q.contains('madhumeha') || q.contains('blood sugar') ||
        q.contains('sugar') || q.contains('insulin') || q.contains('glucose') ||
        q.contains('shakar ki bimari') || q.contains('meetha rog') || q.contains('diabetic') ||
        q.contains('rakta chini') || q.contains('hba1c') || q.contains('fasting sugar')) {
      return '🩺 **Diabetes / मधुमेह / शुगर की बीमारी**\n\n'
          '📊 **Blood sugar reference / रक्त शर्करा:**\n'
          '• ✅ Normal fasting: 70–100 mg/dL\n'
          '• ⚠️ Pre-diabetes: 100–125 mg/dL\n'
          '• 🔴 Diabetes: ≥ 126 mg/dL (fasting)\n\n'
          '🔬 **Types / प्रकार:**\n'
          '• Type 1 — immune destroys insulin cells | Type 2 — insulin resistance (most common)\n'
          '• Gestational — during pregnancy (usually resolves)\n\n'
          '📋 **Daily management / दैनिक प्रबंधन:**\n'
          '• 🩸 Monitor blood sugar regularly\n'
          '• 💊 Take medicines / insulin consistently\n'
          '• 🏃 Exercise 30 min/day — walking is excellent\n'
          '• 🍽️ Eat 3 small balanced meals + 2 healthy snacks\n\n'
          '✅ **Prefer / पसंद करें:** Greens 🥬, whole grains 🌾, lentils 🫘, fish 🐟, curd 🥛\n'
          '❌ **Avoid / परहेज:** Sugary drinks 🥤, sweets 🍬, white rice, fried food 🍟\n\n'
          '⚠️ **Low sugar signs / हाइपोग्लाइसीमिया:** Shaking 😰, sweating 💦, confusion 😵\n'
          '→ Eat sugar immediately: glucose tablet / juice / 2 tsp sugar in water\n\n'
          '_Always follow your doctor\'s treatment plan._';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 06 💊 MEDICINES GUIDE
    // EN: medicine, tablet, paracetamol, ibuprofen, antibiotic, dosage, drug
    // HI: dawai, dawa, tablet, paracetamol, antibiotic, khatir, aushadh
    // NE: ausadhi, dawai, tablet, khatir, aushadhi
    // BHO: dawai, dawa, goli, paracetamol, dose
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('paracetamol') || q.contains('ibuprofen') || q.contains('medicine') ||
        q.contains('tablet') || q.contains('dawai') || q.contains('dawa') ||
        q.contains('aushadh') || q.contains('antibiotic') || q.contains('antacid') ||
        q.contains('drug') || q.contains('dosage') || q.contains('dose') ||
        q.contains('goli') || q.contains('ausadhi') || q.contains('khatir')) {
      return '💊 **Medicines Guide / दवाइयों की जानकारी**\n\n'
          '🔵 **Paracetamol (Crocin / Dolo 650):**\n'
          '• For: 🌡️ Fever, 🤕 Headache, mild–moderate pain\n'
          '• Adult: 500 mg–1 g every 4–6 hrs (max 4 g/day)\n'
          '• Child: 15 mg/kg every 6 hrs — check weight\n'
          '• ⚠️ Avoid with liver disease or alcohol\n\n'
          '🟠 **Ibuprofen (Brufen):**\n'
          '• For: 🦴 Pain, inflammation, 🩸 menstrual cramps\n'
          '• Adult: 400 mg every 6–8 hrs with food\n'
          '• ⚠️ Avoid with kidney disease / ulcer / pregnancy\n\n'
          '💧 **ORS (Electral / Jeevan Jal):**\n'
          '• For: 🤢 Diarrhoea, vomiting, dehydration\n'
          '• Mix 1 sachet in 1 litre boiled cooled water\n\n'
          '🟡 **Antacids (Gelusil / Digene):**\n'
          '• For: 🔥 Acidity, heartburn, gas — 30 min after meals\n\n'
          '🟢 **Cetrizine 10 mg:**\n'
          '• For: 🤧 Allergy, runny nose, itching, hives\n'
          '• 1 tablet daily (may cause drowsiness 😴)\n\n'
          '⚠️ **Never self-medicate with antibiotics 🚫**\n'
          'Complete the full prescribed course even if feeling better.\n\n'
          '_Consult a pharmacist or doctor before starting any new medicine._';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 07 💙 MENTAL HEALTH / STRESS / ANXIETY / SLEEP
    // EN: stress, anxiety, depression, panic, insomnia, lonely, mental health
    // HI: chinta, mansik swasthya, udaasi, neend nahi, akela, darr, ghabrahat
    // NE: mansik swasthya, chinta, nirasha, nidra na aunu, akelo
    // BHO: chinta, man ke bimari, udaas, neend nahi, darr laagata
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('stress') || q.contains('anxiety') || q.contains('anxious') ||
        q.contains('depression') || q.contains('chinta') || q.contains('udaasi') ||
        q.contains('mental') || q.contains('mansik') || q.contains('panic') ||
        q.contains('insomnia') || q.contains('sleep') || q.contains('neend') ||
        q.contains('nidra') || q.contains('lonely') || q.contains('akela') ||
        q.contains('ghabrahat') || q.contains('darr') || q.contains('nirasha') ||
        q.contains('overthink') || q.contains('worry') || q.contains('sad') ||
        q.contains('nind nahi') || q.contains('udaas')) {
      return '💙 **Mental Health / मानसिक स्वास्थ्य / मानसिक स्वास्थ्य**\n\n'
          '🧘 **Immediate coping / तुरंत राहत:**\n'
          '• 🌬️ Box breathing: 4 sec in → hold 4 → out 6 → hold 2\n'
          '• 🚶 10-min walk in fresh air — बाहर टहलें\n'
          '• 🗣️ Talk to someone you trust — विश्वसनीय व्यक्ति से बात करें\n'
          '• 📝 Write down feelings — डायरी लिखें\n'
          '• 📵 Limit social media & news for a few hours\n\n'
          '😴 **For better sleep / अच्छी नींद:**\n'
          '• 🛏️ Fixed sleep schedule every day\n'
          '• 📵 No screens 1 hour before bed\n'
          '• 🌑 Dark, cool, quiet bedroom\n'
          '• ☕ No caffeine after 3 PM\n\n'
          '🚨 **Seek professional help if / पेशेवर मदद लें अगर:**\n'
          '• Persistent sadness > 2 weeks | Sleep problems > 1 month\n'
          '• Thoughts of self-harm 🆘\n\n'
          '📞 **Helplines / हेल्पलाइन:**\n'
          '• 🇮🇳 iCall: **9152987821** | Vandrevala: **1860-2662-345** (24/7)\n'
          '• 🇳🇵 Nepal: **1166** (Mental health)\n\n'
          '_Your mental health matters as much as physical health. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 08 🤰 PREGNANCY
    // EN: pregnancy, pregnant, antenatal, prenatal, delivery, labour
    // HI: garbhawastha, garbhwati, prasav, prasuti, delivery, baccha hona
    // NE: garbhavastha, shuruaat, prasav, sūtikā, garbhini
    // BHO: garbha, pet mein bacha, prasav, delivery, garbhwati bani
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('pregnancy') || q.contains('pregnant') || q.contains('garbhwati') ||
        q.contains('garbhawastha') || q.contains('garbhavastha') || q.contains('garbha') ||
        q.contains('prasav') || q.contains('prasuti') || q.contains('delivery') ||
        q.contains('labour') || q.contains('antenatal') || q.contains('prenatal') ||
        q.contains('sūtikā') || q.contains('garbhini')) {
      return '🤰 **Pregnancy / गर्भावस्था / गर्भवती**\n\n'
          '🥗 **Essential nutrition / पोषण:**\n'
          '• 🟢 Folic acid — 1st trimester (prevents neural tube defects)\n'
          '• 🔴 Iron — spinach, lentils, meat (prevents anaemia)\n'
          '• 🥛 Calcium — milk, yogurt, paneer, greens\n'
          '• 🍗 Protein — dal, eggs, fish, tofu\n'
          '• 💧 Water — 8–10 glasses daily\n\n'
          '✅ **Safe habits / सुरक्षित आदतें:**\n'
          '• 🏥 Attend all antenatal checkups (minimum 4)\n'
          '• 🚶 Light walking is safe throughout pregnancy\n'
          '• 🚫 Avoid alcohol, tobacco, raw/undercooked food\n'
          '• 💊 Only doctor-prescribed medicines\n'
          '• 😴 Sleep on left side (after 20 weeks) — improves blood flow\n\n'
          '🚨 **See doctor immediately / तुरंत डॉक्टर दिखाएं:**\n'
          '• 🩸 Heavy vaginal bleeding\n'
          '• 💢 Severe abdominal pain\n'
          '• 🤯 Severe headache + swollen face/hands (pre-eclampsia)\n'
          '• 👶 Baby not moving after 28 weeks\n'
          '• 💧 Water breaking before due date\n\n'
          '_Regular prenatal checkups and iron-folic acid tablets save lives. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 09 🩺 BLOOD PRESSURE
    // EN: blood pressure, hypertension, low bp, high bp, hypotension
    // HI: raktachaap, uccha raktachaap, neecha raktachaap, BP, dawab
    // NE: raktachap, uccha raktachap, neecha raktachap, uccho BP
    // BHO: BP, khoon ka dabab, uccha BP, BP low
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('blood pressure') || q.contains('hypertension') || q.contains('raktachaap') ||
        q.contains('raktachap') || q.contains('high bp') || q.contains('low bp') ||
        q.contains('hypotension') || q.contains('dawab') || q.contains('uccha bp') ||
        q.contains('bp high') || q.contains('bp low') || q.contains('khoon ka dabab') ||
        (q.contains('bp') && (q.contains('high') || q.contains('low') || q.contains('problem')))) {
      return '🩺 **Blood Pressure / रक्तचाप / BP**\n\n'
          '📊 **Reference / संदर्भ:**\n'
          '• ✅ Normal: < 120/80 mmHg\n'
          '• 🟡 Elevated: 120–129 / < 80\n'
          '• 🔴 High (HTN): ≥ 140/90 mmHg\n'
          '• 🔵 Low (Hypotension): < 90/60 mmHg\n\n'
          '📋 **For High BP / उच्च रक्तचाप:**\n'
          '• 🧂 Reduce salt < 5 g/day (1 tsp)\n'
          '• 🏃 Exercise 30 min/day — walking, cycling\n'
          '• 🚭 Quit smoking | 🍺 Limit alcohol\n'
          '• 😴 Sleep 7–8 hrs | 😌 Manage stress (yoga, meditation)\n'
          '• 🥗 DASH diet: fruits, vegetables, whole grains, low-fat dairy\n\n'
          '📋 **For Low BP / निम्न रक्तचाप:**\n'
          '• 💧 Drink more water + pinch of extra salt\n'
          '• 🍽️ Small, frequent meals\n'
          '• 🐢 Rise slowly from sitting/lying\n\n'
          '🚨 **Call 108 for:** Severe headache 🤯, blurred vision 👁️, chest pain 🫀, fainting 😵\n\n'
          '_Never stop BP medication without your doctor\'s advice. 💊_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 10 💨 ASTHMA
    // EN: asthma, inhaler, wheezing, breathless, shortness of breath
    // HI: dama, dam ki bimari, inhaler, saans phoolna, seene mein ghurghurahat
    // NE: dama, sas ko rog, inhaler, sas phoulnu, sinaama ghurghurahata
    // BHO: dam, saans phoolata, inhaler, seene mein seeti aawaz
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('asthma') || q.contains('dama') || q.contains('inhaler') ||
        q.contains('wheezing') || q.contains('breathless') || q.contains('saans phoolna') ||
        q.contains('shortness of breath') || q.contains('sas phoulnu') ||
        q.contains('breathing difficulty') || q.contains('dam ki bimari') ||
        q.contains('ghurghurahat') || q.contains('saans phoolata')) {
      return '💨 **Asthma / दमा / श्वास रोग**\n\n'
          '🆘 **During attack / दौरे के दौरान:**\n'
          '• 🪑 Sit upright — do NOT lie down\n'
          '• 😌 Stay calm — धीरे-धीरे सांस लें\n'
          '• 💨 Reliever inhaler (🔵 blue — Salbutamol): 1 puff/min up to 10\n'
          '• 📞 Call 108 if no improvement after 10 puffs\n\n'
          '📅 **Daily prevention / रोज़ाना बचाव:**\n'
          '• 💜 Use preventer inhaler (brown/purple) as prescribed, even when well\n'
          '• 📊 Check peak flow meter regularly\n'
          '• 🎒 Always carry reliever inhaler\n\n'
          '🚫 **Trigger avoidance / ट्रिगर से बचें:**\n'
          '• 🌫️ Dust mites, pollen, smoke, strong smells, pet dander\n'
          '• ❄️ Cold air — warm up slowly before exercise\n'
          '• 🧹 Vacuum weekly, use dust-proof mattress covers\n\n'
          '🚨 **Emergency / आपातकाल:** Can\'t speak full sentences, lips 🔵 turning blue\n'
          '→ Call **108** immediately\n\n'
          '_Never stop inhalers without doctor\'s guidance. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 11 🦋 THYROID
    // EN: thyroid, hypothyroid, hyperthyroid, TSH, goitre, levothyroxine
    // HI: thyroid, hypothyroid, hyperthyroid, galay ki gaanth, TSH
    // NE: thyroid, gardan gaanth, hypothyroid, TSH parikshan
    // BHO: thyroid, gardan mein gaanth, TSH, thyroid ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('thyroid') || q.contains('hypothyroid') || q.contains('hyperthyroid') ||
        q.contains('tsh') || q.contains('levothyroxine') || q.contains('goitre') ||
        q.contains('gardan ki gaanth') || q.contains('gardan gaanth') ||
        q.contains('gardan mein gaanth') || q.contains('thyroid ki bimari')) {
      return '🦋 **Thyroid / थायराइड**\n\n'
          '🐢 **Hypothyroidism (underactive) / कम सक्रिय:**\n'
          '• Symptoms: 😴 Fatigue, ⚖️ weight gain, 🥶 cold intolerance, 🧖 dry skin, 💇 hair loss\n'
          '• Treatment: Levothyroxine — empty stomach, same time daily\n\n'
          '🐇 **Hyperthyroidism (overactive) / अति सक्रिय:**\n'
          '• Symptoms: ⚖️ weight loss, 💓 rapid heartbeat, 💦 sweating, 😰 anxiety, 👀 bulging eyes\n'
          '• Treatment: Antithyroid drugs / radioiodine (doctor-prescribed)\n\n'
          '📋 **Lifestyle tips / जीवनशैली:**\n'
          '• 📊 Get TSH checked every 6–12 months\n'
          '• 🧂 Eat iodine-rich: seafood 🐟, dairy 🥛, iodised salt\n'
          '• 🥦 If hypothyroid: limit raw cabbage, broccoli, soy\n'
          '• ⏰ Take medication consistently — never skip\n\n'
          '⚠️ **Do not adjust dose yourself** — always check with doctor.\n\n'
          '_Thyroid is very manageable with proper medication. 💊_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 12 🤢 STOMACH / DIGESTIVE
    // EN: diarrhoea, loose motion, vomiting, nausea, acidity, gas, stomach pain
    // HI: dast, loose motion, ulti, jee michlaana, pet dard, amlata, gas
    // NE: pkhala, banta, ulti, petko dukhai, amlata, gas
    // BHO: dast, pet dard, ulti, gas bana, amlata, pet mein dard
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('diarrhea') || q.contains('diarrhoea') || q.contains('loose motion') ||
        q.contains('dast') || q.contains('pkhala') || q.contains('vomit') ||
        q.contains('ulti') || q.contains('banta') || q.contains('nausea') ||
        q.contains('jee michlaana') || q.contains('stomach') || q.contains('pet dard') ||
        q.contains('acidity') || q.contains('amlata') || q.contains('gas') ||
        q.contains('gastric') || q.contains('ulcer') || q.contains('indigestion') ||
        q.contains('heartburn') || q.contains('abdomen pain')) {
      return '🤢 **Stomach & Digestive / पेट की समस्या / पेट दुखाई**\n\n'
          '💧 **For diarrhoea / दस्त / पखाला:**\n'
          '• ORS: 1 sachet in 1L boiled water — sip every few minutes\n'
          '• 🍚 Eat light: boiled rice, banana 🍌, toast, boiled potato\n'
          '• ❌ Avoid dairy, spicy, oily food, raw vegetables\n'
          '• 👶 Children: Zinc 20 mg/day for 10–14 days\n\n'
          '🤮 **For vomiting / उल्टी:**\n'
          '• Sip ORS/water every 5–10 min\n'
          '• 🫚 Ginger tea or ginger candy settles nausea\n'
          '• Avoid solid food until 2 hours vomiting-free\n\n'
          '🔥 **For acidity / gas / अम्लता:**\n'
          '• 🍽️ Smaller, more frequent meals\n'
          '• ❌ Avoid spicy, fried, acidic foods (citrus, tomatoes)\n'
          '• 💊 Antacid (Gelusil/Digene) 30 min after meals\n'
          '• 🛏️ Don\'t lie down within 2 hrs of eating\n\n'
          '🚨 **See doctor if / डॉक्टर दिखाएं:**\n'
          '• 🩸 Blood in stool or vomit | 📅 Diarrhoea > 3 days\n'
          '• 😵 Severe dehydration: dry mouth, dark urine, dizziness\n\n'
          '_Dehydration is the main danger — keep drinking ORS. 💧_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 13 🧴 SKIN / ALLERGY / RASH
    // EN: rash, skin, itch, allergy, eczema, fungal, ringworm, acne, hives
    // HI: khujli, daad, chamdi ki bimari, allergy, fungal, pimple, daane
    // NE: khujali, daad, chamdi ko rog, allergy, daane
    // BHO: khujli, daad, chamdi ki bimari, allergy, phunsi
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('rash') || q.contains('skin') || q.contains('itch') ||
        q.contains('khujli') || q.contains('khujali') || q.contains('allergy') ||
        q.contains('eczema') || q.contains('fungal') || q.contains('daad') ||
        q.contains('ringworm') || q.contains('hives') || q.contains('urticaria') ||
        q.contains('pimple') || q.contains('acne') || q.contains('psoriasis') ||
        q.contains('daane') || q.contains('phunsi') || q.contains('chamdi')) {
      return '🧴 **Skin & Allergy / त्वचा रोग / छाला-खुजली**\n\n'
          '🌿 **For mild rash / itching / खुजली:**\n'
          '• Apply calamine lotion or cool compress\n'
          '• 💊 Cetrizine 10 mg (antihistamine) for allergic itch\n'
          '• ❌ Avoid scratching — short clean nails\n'
          '• 🧼 Use mild, fragrance-free soap\n\n'
          '🍄 **For fungal infection / दाद-खाज:**\n'
          '• Keep area clean and completely dry\n'
          '• Apply Clotrimazole 1% cream twice daily for 2–4 weeks\n'
          '• 👕 Wear loose breathable cotton clothing\n'
          '• ❌ Do not share towels or clothing\n\n'
          '💧 **For eczema / एक्जिमा:**\n'
          '• Moisturise ≥ 2x daily with unscented lotion\n'
          '• Avoid triggers: soaps, sweat, dust, certain foods\n\n'
          '😊 **For acne / मुंहासे:**\n'
          '• Wash face 2x daily with gentle cleanser\n'
          '• Benzoyl peroxide or Salicylic acid gel (OTC)\n\n'
          '🚨 **Call 108 for:** Rash + breathing difficulty 😮‍💨 (anaphylaxis)\n'
          'See doctor for: fever + rash 🌡️, spreading rash, blisters\n\n'
          '_Most mild rashes improve with basic care within a week. ✅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 14 👁️ EYES
    // EN: eye, vision, blurry, conjunctivitis, pink eye, eye pain, watery eye
    // HI: aankh, nazar, aankh dard, aankh laal, aankhon mein jalan
    // NE: aankha, nazar, ankha dukha, ankha lal, ankha bata paani
    // BHO: aankh, nazar, aankh dukhai, aankh laal, aankhon se paani
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('eye') || q.contains('aankh') || q.contains('ankha') ||
        q.contains('vision') || q.contains('nazar') || q.contains('blurry') ||
        q.contains('conjunctivitis') || q.contains('pink eye') ||
        q.contains('aankh dard') || q.contains('ankha dukha') ||
        q.contains('aankh laal') || q.contains('watery eye') || q.contains('आँख')) {
      return '👁️ **Eye Health / आँखों की देखभाल / आँखा स्वास्थ्य**\n\n'
          '😤 **Red / itchy / watery eyes (Conjunctivitis) / आँख आना:**\n'
          '• 💧 Flush eyes with clean cool water\n'
          '• 🧊 Cold compress over closed eyelids\n'
          '• ❌ Do NOT share towels, pillows, or eye drops\n'
          '• 🙌 Avoid touching eyes with unwashed hands\n'
          '• 💊 Antibiotic drops (Tobramycin) if bacterial — doctor only\n\n'
          '💻 **Screen eye strain / स्क्रीन थकान:**\n'
          '• 20-20-20 rule: every 20 min → look 20 ft away for 20 sec\n'
          '• 🔅 Reduce screen brightness\n'
          '• 💧 Lubricating / artificial tear drops (OTC)\n\n'
          '😣 **Stye / आँख पर फुंसी:**\n'
          '• 🌡️ Warm compress 3–4 times/day for 10 minutes\n'
          '• ❌ Do NOT squeeze or pop\n\n'
          '🚨 **Emergency — Call 108 / see doctor for:**\n'
          '• ⚡ Sudden vision loss | 💢 Severe eye pain\n'
          '• 🤕 Eye injury or stuck object\n'
          '• ✨ Flashes of light / floaters / curtain-like shadow\n'
          '• ⚗️ Chemical splash → rinse 15 min then go to ER\n\n'
          '_Never rub an injured eye. Cover gently and seek care. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 15 🥗 NUTRITION / DIET / WEIGHT
    // EN: nutrition, diet, food, weight, vitamin, healthy eating, balanced diet
    // HI: poshan, khana, aahar, wajan, vitamin, balanced diet
    // NE: poshan, khaana, aahar, tauljam, vitamin, suntulita aahar
    // BHO: poshan, khana, vitamin, wajan, balanced bhojan
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('nutrition') || q.contains('poshan') || q.contains('diet') ||
        q.contains('food') || q.contains('khana') || q.contains('aahar') ||
        q.contains('khaana') || q.contains('bhojan') || q.contains('weight') ||
        q.contains('wajan') || q.contains('vitamin') || q.contains('healthy eating') ||
        q.contains('balanced') || q.contains('protein') || q.contains('tauljam')) {
      return '🥗 **Nutrition & Diet / पोषण / आहार**\n\n'
          '🍽️ **Balanced plate / संतुलित थाली:**\n'
          '• 🌾 ½ plate: Whole grains — rice, roti, oats, millets\n'
          '• 🥦 ¼ plate: Vegetables — all colours, leafy greens\n'
          '• 🍗 ¼ plate: Protein — dal, eggs, fish, chicken, tofu, paneer\n'
          '• 🥛 2 dairy servings/day — milk, curd, paneer\n'
          '• 🫙 Small fats: nuts, seeds, ghee, olive oil\n\n'
          '💊 **Key vitamins & sources / मुख्य विटामिन:**\n'
          '• Vitamin C 🍋: amla, guava, lemon, bell pepper, tomatoes\n'
          '• Iron 🔴: spinach, lentils, jaggery, meat, sesame seeds\n'
          '• Calcium 🦴: milk, ragi, sesame, paneer, broccoli\n'
          '• Vitamin D ☀️: sunlight 15 min/day, eggs, fish\n'
          '• B12 💊: meat, fish, eggs, dairy (vegans need supplements)\n\n'
          '✅ **Healthy habits / स्वस्थ आदतें:**\n'
          '• 🕐 Regular meal times | 💧 8 glasses water daily\n'
          '• ❌ Limit ultra-processed, fried, sugary foods\n'
          '• 🏃 Exercise 30 min/day at least 5 days/week\n\n'
          '_Small consistent changes give lasting results. 💪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 16 👶 CHILD HEALTH / VACCINATION
    // EN: child, baby, infant, vaccination, immunisation, newborn, toddler
    // HI: bachha, shishu, navajaata, tikakaaran, टीकाकरण, bacche ki bimari
    // NE: bachho, shishu, tikakaaran, टीकाकरण, nawajaanma
    // BHO: bacha, shishu, tika, टीकाकरण, nawajaanma bacha
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('child') || q.contains('baby') || q.contains('bachha') ||
        q.contains('bacha') || q.contains('shishu') || q.contains('infant') ||
        q.contains('toddler') || q.contains('newborn') || q.contains('navajaata') ||
        q.contains('vaccination') || q.contains('vaccine') || q.contains('tikakaaran') ||
        q.contains('टीकाकरण') || q.contains('immunisation') || q.contains('bachho')) {
      return '👶 **Child Health & Vaccination / बाल स्वास्थ्य / टीकाकरण**\n\n'
          '💉 **Vaccine schedule / टीके का समय:**\n'
          '• 🐣 Birth: BCG 💉, Hepatitis B 💉, OPV-0\n'
          '• 📅 6 wks: DPT, OPV-1, Hib, Rotavirus, Hep B-2\n'
          '• 📅 10 & 14 wks: DPT, OPV, Hib, Rotavirus boosters\n'
          '• 📅 9 months: Measles/MR\n'
          '• 📅 15–18 months: DPT booster, MMR, OPV booster\n'
          '• 📅 5–6 years: DPT booster\n\n'
          '🌡️ **Child fever rules / बच्चे का बुखार:**\n'
          '• 👶 Baby < 3 months + any fever → doctor immediately\n'
          '• 💊 Paracetamol: 15 mg/kg every 6 hrs (check weight on label)\n'
          '• 🚫 Never give Aspirin to children (Reye\'s syndrome risk)\n\n'
          '🚨 **Urgent care signs / तुरंत डॉक्टर:**\n'
          '• 💧 Not drinking fluids 6+ hours\n'
          '• 😴 Unusual drowsiness / hard to wake\n'
          '• 😮‍💨 Rapid / laboured breathing\n'
          '• 🌡️ Rash with fever\n'
          '• 🔵 Bulging fontanelle (soft spot) in infants\n\n'
          '_Keep your child\'s immunisation card updated and safe. 📋_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 17 🦴 JOINT PAIN / ARTHRITIS
    // EN: joint pain, arthritis, knee pain, gout, rheumatoid, bone pain
    // HI: jodo mein dard, gathiya, ghutna dard, haddi dard, gathiavat
    // NE: jodai dukha, gathiya, ghutna dukha, haddi ko rog
    // BHO: jod mein dard, gathiya, ghutna dukhai, haddi dukhai
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('joint') || q.contains('arthritis') || q.contains('jodo') ||
        q.contains('gathiya') || q.contains('knee pain') || q.contains('ghutna') ||
        q.contains('ghutna dard') || q.contains('jodai') || q.contains('bone pain') ||
        q.contains('haddi dard') || q.contains('gout') || q.contains('rheumatoid') ||
        q.contains('joint pain') || q.contains('back pain') || q.contains('kamar dard')) {
      return '🦴 **Joint Pain & Arthritis / जोड़ों का दर्द / गठिया**\n\n'
          '🔬 **Types / प्रकार:**\n'
          '• 🦴 Osteoarthritis — wear & tear (elderly, knees, hips)\n'
          '• 🔴 Rheumatoid — immune attacks joints (morning stiffness, symmetric)\n'
          '• 💎 Gout — uric acid crystals (severe pain, often big toe, red swollen)\n\n'
          '🌿 **Relief / राहत:**\n'
          '• 🌡️ Warm compress for chronic stiffness\n'
          '• 🧊 Cold compress for acute swelling\n'
          '• 💊 Ibuprofen 400 mg with food (short-term)\n'
          '• 🧘 Physiotherapy exercises strengthen supporting muscles\n\n'
          '📋 **Long-term management / दीर्घकालिक प्रबंधन:**\n'
          '• ⚖️ Maintain healthy weight — each kg reduces knee load 3–4 kg\n'
          '• 🏊 Low-impact exercise: swimming, cycling, yoga\n'
          '• 🦴 Calcium + Vitamin D (especially after 40)\n'
          '• 🍖 For gout: avoid red meat, organ meats, shellfish, alcohol\n\n'
          '🚨 **See doctor if:** Joint hot + red + swollen (infection/gout), pain with fever\n\n'
          '_Do not self-medicate long-term with anti-inflammatories — kidney damage risk. ⚠️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 18 🩸 ANAEMIA / IRON DEFICIENCY
    // EN: anaemia, anemia, iron deficiency, low haemoglobin, weak blood
    // HI: anaemia, khoon ki kami, haemoglobin kam, rakt alpata, iron ki kami
    // NE: rakt alpata, khoon ko kami, haemoglobin, iron kami
    // BHO: khoon ki kami, rakt kami, iron ki kami, kamzor khoon
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('anaemia') || q.contains('anemia') || q.contains('iron deficiency') ||
        q.contains('khoon ki kami') || q.contains('haemoglobin') || q.contains('hemoglobin') ||
        q.contains('rakt alpata') || q.contains('rakt kami') || q.contains('low hb') ||
        q.contains('pale skin') || q.contains('blood deficiency') || q.contains('iron kami')) {
      return '🩸 **Anaemia / रक्त अल्पता / खून की कमी**\n\n'
          '📊 **Normal Hb / सामान्य हीमोग्लोबिन:**\n'
          '• 👨 Men: > 13 g/dL | 👩 Women: > 12 g/dL | 🤰 Pregnant: > 11 g/dL\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          'Fatigue 😴, pale skin/gums/nails 😶, breathless on exertion 😮‍💨,\n'
          'dizziness 🌀, cold hands & feet 🥶, rapid heartbeat 💓, headache 🤕\n\n'
          '🥗 **Iron-rich foods / लौह तत्व वाले खाद्य पदार्थ:**\n'
          '• 🥬 Spinach, methi, amaranth, green leafy vegetables\n'
          '• 🫘 Lentils, rajma, chickpeas, soybean\n'
          '• 🌾 Ragi, jowar, fortified cereals\n'
          '• 🥩 Lean meat, chicken, fish, liver\n'
          '• 🌰 Pumpkin seeds, sesame seeds, jaggery (गुड़)\n\n'
          '⬆️ **Boost absorption / अवशोषण बढ़ाएं:**\n'
          '• 🍋 Eat with Vitamin C: lemon, amla, tomato\n'
          '• ☕ Avoid tea/coffee 1 hr before/after iron-rich meals\n\n'
          '🚨 **See doctor if:** Hb < 8 g/dL, chest pain, extreme breathlessness\n\n'
          '_All pregnant women & children under 5 should take iron supplements. 💊_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 19 🦷 DENTAL / TOOTHACHE
    // EN: toothache, dental, tooth pain, cavity, gum, abscess, tooth decay
    // HI: dant dard, daant dard, daanth dard, gum, cavity, mooh ki safai
    // NE: dant dukhāi, daant dard, dant ko rog, masuda
    // BHO: dant dukhai, daant mein dard, dant ki bimari, masuda
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('tooth') || q.contains('dental') || q.contains('dant') ||
        q.contains('daant') || q.contains('dant dard') || q.contains('daanth') ||
        q.contains('toothache') || q.contains('cavity') || q.contains('gum') ||
        q.contains('masuda') || q.contains('abscess') || q.contains('tooth decay') ||
        q.contains('dant dukhāi') || q.contains('dant dukhai')) {
      return '🦷 **Dental & Oral Health / दाँत और मसूड़े / दाँत दुखाई**\n\n'
          '⚡ **Toothache relief / दाँत दर्द में राहत:**\n'
          '• 💊 Ibuprofen 400 mg or Paracetamol 500 mg with food\n'
          '• 🧂 Warm salt water rinse (1 tsp salt in 1 glass water)\n'
          '• 🌿 Clove oil on cotton ball on painful tooth — प्राकृतिक दर्द निवारक\n'
          '• ❌ Do NOT put Aspirin directly on gum (burns tissue)\n'
          '• ❌ Avoid very hot, cold, or sweet foods\n\n'
          '🪥 **Daily oral hygiene / दैनिक देखभाल:**\n'
          '• 🦷 Brush TWICE daily for 2 minutes — fluoride toothpaste\n'
          '• 🧵 Floss once daily\n'
          '• 🪥 Replace toothbrush every 3 months\n'
          '• ❌ Limit sugar — feeds cavity bacteria\n\n'
          '😬 **Gum disease signs:** Bleeding gums 🩸, bad breath, red swollen gums\n'
          '→ Warm saline rinse twice daily; soft-bristle brush\n\n'
          '🚨 **See dentist for:**\n'
          '• 😣 Dental abscess (swollen jaw + fever + severe pain)\n'
          '• 🦷 Knocked-out tooth → keep in milk 🥛 → dentist within 1 hour\n\n'
          '_Visit dentist every 6 months for check-up and cleaning. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 20 🏃 EXERCISE / FITNESS
    // EN: exercise, fitness, workout, running, gym, yoga, weight loss
    // HI: vyayam, kasrat, wajan kam karna, daud, fitness, khelkud
    // NE: vyayam, kasrat, tauljam, wajan kamāunu, daud
    // BHO: vyayam, kasrat, wajan ghataawa, daud, fitness
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('exercise') || q.contains('vyayam') || q.contains('fitness') ||
        q.contains('workout') || q.contains('kasrat') || q.contains('gym') ||
        q.contains('running') || q.contains('daud') || q.contains('weight loss') ||
        q.contains('wajan kam') || q.contains('wajan ghataawa') || q.contains('physical activity')) {
      return '🏃 **Exercise & Fitness / व्यायाम / कसरत**\n\n'
          '📊 **WHO recommendations / WHO सिफारिश:**\n'
          '• 👨‍🦰 Adults: 150–300 min moderate activity/week\n'
          '• 👦 Children 5–17: ≥ 60 min/day\n'
          '• 💪 Muscle-strengthening: 2+ days/week\n\n'
          '🌟 **Best exercises for beginners / शुरुआती के लिए:**\n'
          '• 🚶 Brisk walking — easiest, suits all ages, free\n'
          '• 🏊 Swimming — great for joints (arthritis, obesity)\n'
          '• 🧘 Yoga — flexibility, stress relief, balance\n'
          '• 🚴 Cycling — cardio without joint stress\n'
          '• 💪 Bodyweight: squats, push-ups, planks at home\n\n'
          '⚖️ **For weight loss / वजन घटाने के लिए:**\n'
          '• Combine cardio 🏃 + strength training 💪\n'
          '• 300 cal/day deficit = steady sustainable loss\n'
          '• Consistency > intensity — 30 min daily > 2 hrs once/week\n\n'
          '✅ **Safety tips / सुरक्षा:**\n'
          '• 🔥 Warm up 5 min + cool down 5 min\n'
          '• 💧 Stay hydrated before, during, after\n'
          '• 🚨 Stop if: chest pain 🫀, dizziness 🌀, extreme breathlessness\n\n'
          '_Exercise is medicine — reduces risk of diabetes, BP, depression, cancer. 💊_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 21 🧬 CANCER AWARENESS
    // EN: cancer, tumour, malignant, chemotherapy, biopsy, cervical, breast cancer
    // HI: kansara, arbud, tumor, cancer ki bimari, cancer ke lakshan
    // NE: kansara, rog, cancer, arbud, tumor ko rog
    // BHO: kansara, cancer, tumor, cancer ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('cancer') || q.contains('kansara') || q.contains('tumour') ||
        q.contains('tumor') || q.contains('arbud') || q.contains('malignant') ||
        q.contains('chemotherapy') || q.contains('biopsy') || q.contains('cervical') ||
        q.contains('breast cancer') || q.contains('cancer ki bimari') || q.contains('rog arbud')) {
      return '🧬 **Cancer Awareness / कैंसर जागरूकता**\n\n'
          '⚠️ **Warning signs (CAUTION) / चेतावनी के संकेत:**\n'
          '• 🔄 Change in bowel or bladder habits\n'
          '• 🩹 A sore that does not heal\n'
          '• 🩸 Unusual bleeding or discharge\n'
          '• 🫁 Lump in breast, testicle, or anywhere\n'
          '• 😣 Indigestion or difficulty swallowing\n'
          '• 🔵 Change in a wart or mole\n'
          '• 😮‍💨 Nagging cough or hoarseness\n'
          '• ⚖️ Unexplained weight loss > 5 kg in < 3 months\n\n'
          '🔍 **Common cancers in South Asia / दक्षिण एशिया में:**\n'
          '• 🌸 Cervical — HPV vaccine + Pap smear every 3 years\n'
          '• 🎗️ Breast — self-examine monthly; mammogram after 40\n'
          '• 👄 Oral — avoid tobacco, alcohol, betel nut\n'
          '• 🫁 Lung — smoking is main cause; quit now\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 🚭 Quit tobacco | 🍺 Limit alcohol | ⚖️ Healthy weight\n'
          '• 🥗 5 portions fruit & veg daily | ☀️ Avoid excessive sun\n'
          '• 💉 Get HPV & Hepatitis B vaccines\n\n'
          '🚨 **If you notice warning signs → see doctor immediately.**\n'
          '_Early detection dramatically improves survival rates. ✅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 22 🫀 CHOLESTEROL
    // EN: cholesterol, lipid, triglyceride, HDL, LDL, fatty blood, statin
    // HI: cholesterol, rakta mein charbi, LDL, HDL, statin
    // NE: cholesterol, raktamā charbi, lipid, LDL, HDL
    // BHO: cholesterol, khoon mein charbi, lipid, cholesterol ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('cholesterol') || q.contains('lipid') || q.contains('triglyceride') ||
        q.contains('hdl') || q.contains('ldl') || q.contains('statin') ||
        q.contains('rakta mein charbi') || q.contains('khoon mein charbi') ||
        q.contains('raktamā charbi') || q.contains('fatty blood')) {
      return '🫀 **Cholesterol / कोलेस्ट्रॉल**\n\n'
          '📊 **Reference / संदर्भ:**\n'
          '• ✅ Total: < 200 mg/dL | LDL ("bad"): < 100 | HDL ("good"): > 60\n'
          '• ✅ Triglycerides: < 150 mg/dL\n\n'
          '🥗 **Diet changes / आहार परिवर्तन:**\n'
          '• ✅ Eat: Oats 🌾, beans 🫘, flaxseed, fatty fish 🐟, nuts 🥜, olive oil\n'
          '• ❌ Reduce: Fried food 🍟, red meat 🥩, full-fat dairy, trans fats\n'
          '• ❌ Avoid: Vanaspati / margarine / bakery items\n\n'
          '🏃 **Lifestyle / जीवनशैली:**\n'
          '• 🏃 Exercise 30 min/day — raises HDL, lowers LDL\n'
          '• 🚭 Quit smoking — raises HDL\n'
          '• 🍺 Limit alcohol | ⚖️ Lose excess weight\n\n'
          '💊 **Medicines (if needed) / दवाएं:**\n'
          '• Statins (Atorvastatin / Rosuvastatin) — evening, doctor-prescribed\n'
          '• ⚠️ Report any muscle pain to doctor immediately\n\n'
          '_High cholesterol has NO symptoms — get lipid profile test every 5 years. 🧪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 23 🤧 FLU / INFLUENZA
    // EN: flu, influenza, viral fever, body ache, chills
    // HI: flue, viral bukhar, badan dard, sardard, jukam
    // NE: flue, viral jwaro, badan dukha, jharkī
    // BHO: flu, viral bukhar, badan dard, kaapna
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('flu') || q.contains('influenza') || q.contains('viral fever') ||
        q.contains('viral bukhar') || q.contains('viral jwaro') || q.contains('body ache') ||
        q.contains('badan dard') || q.contains('chills') || q.contains('jharkī') ||
        q.contains('kaapna') || q.contains('virus')) {
      return '🤧 **Flu / Influenza / वायरल बुखार**\n\n'
          '😓 **Symptoms (sudden onset) / लक्षण:**\n'
          'High fever 🌡️, severe body aches 💢, headache 🤕, chills 🥶,\n'
          'fatigue 😴, dry cough 😷, sore throat 😣, runny nose 🤧\n\n'
          '🏠 **Treatment (no antibiotic needed) / उपचार:**\n'
          '• 🛌 Rest — body needs energy to fight the virus\n'
          '• 💧 Fluids: water, ORS, warm soup, herbal tea\n'
          '• 💊 Paracetamol for fever and body pain\n'
          '• 💨 Steam inhalation for congestion\n'
          '• 🍯 Honey + ginger in warm water soothes throat\n\n'
          '⏱️ **Recovery:** Most recover in 7–10 days\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 💉 Annual flu vaccine (elderly, children, pregnant women)\n'
          '• 🙌 Wash hands 20 sec with soap frequently\n'
          '• 😷 Cover mouth/nose when coughing or sneezing\n\n'
          '🚨 **See doctor if:** Breathing difficulty 😮‍💨, chest pain 🫀,\n'
          'confusion 😵, fever > 5 days or returning after improvement\n\n'
          '_Antibiotics do NOT treat flu. 🚫_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 24 🧪 TYPHOID
    // EN: typhoid, enteric fever, salmonella, Widal test
    // HI: typhoid, masar, miyadi bukhar, enteric fever, widal pariksha
    // NE: typhoid, enteric jwar, miyadi bukhar, widal test
    // BHO: typhoid, miyadi bukhar, enteric fever, masar ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('typhoid') || q.contains('enteric fever') || q.contains('masar') ||
        q.contains('miyadi bukhar') || q.contains('widal') || q.contains('salmonella') ||
        q.contains('miyadi jwar') || q.contains('masar ki bimari')) {
      return '🧪 **Typhoid / टाइफाइड / मियादी बुखार**\n\n'
          '😓 **Symptoms / लक्षण (gradual onset):**\n'
          'Prolonged high fever 🌡️ (39–40°C), severe headache 🤕, weakness 😓,\n'
          'loss of appetite 🚫🍽️, stomach pain 🤢, constipation or diarrhoea,\n'
          'rose-coloured spots on chest/abdomen\n\n'
          '🔬 **Cause:** Salmonella Typhi — contaminated water & food\n\n'
          '💊 **Treatment (needs antibiotics) / इलाज:**\n'
          '• Antibiotics: Azithromycin / Ciprofloxacin / Cefixime (doctor only)\n'
          '• 💧 Drink plenty of fluids + ORS\n'
          '• 🍚 Eat easily digestible: rice, dal, khichdi, curd\n'
          '• 💊 Paracetamol for fever management\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 💧 Drink only boiled or treated/bottled water\n'
          '• 🙌 Wash hands before eating and after toilet\n'
          '• ❌ Avoid street food, unpeeled fruits, raw salads\n'
          '• 💉 Typhoid Vi vaccine — effective 3–5 years\n\n'
          '🚨 **Typhoid can be fatal if untreated. See doctor for blood test.**\n\n'
          '_Never stop antibiotics early — drug-resistant typhoid is increasing. ⚠️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 25 🦟 MALARIA / DENGUE
    // EN: malaria, dengue, mosquito, platelet, fever with chills, breakbone fever
    // HI: malaria, dengue, machhar, platelet, haड्डी toda bukhar
    // NE: malaria, dengue, lamo jwar, pletalet, machhar
    // BHO: malaria, dengue, machhar se bukhar, platelet girna
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('malaria') || q.contains('dengue') || q.contains('mosquito') ||
        q.contains('machhar') || q.contains('platelet') || q.contains('plasmodium') ||
        q.contains('breakbone fever') || q.contains('dengue fever') ||
        q.contains('machhar se bukhar') || q.contains('platelet girna')) {
      return '🦟 **Malaria & Dengue / मलेरिया और डेंगू**\n\n'
          '🦟 **Malaria symptoms / मलेरिया लक्षण:**\n'
          'Cyclical fever with chills 🥶 and sweating 💦 (every 48–72 hrs),\n'
          'headache 🤕, muscle pain 💢, nausea 🤢\n\n'
          '🔴 **Dengue symptoms / डेंगू लक्षण:**\n'
          'Sudden high fever 🌡️, severe headache 🤕, pain behind eyes 👁️,\n'
          'joint/muscle pain 💢, rash 🧴, bleeding gums/nose 🩸\n\n'
          '🏠 **For both / दोनों के लिए:**\n'
          '• 🏥 See doctor immediately — blood test required\n'
          '• 🛌 Rest and drink plenty of fluids + ORS\n'
          '• 💊 Paracetamol for fever\n'
          '• 🚫 NO Aspirin or Ibuprofen in dengue — increases bleeding risk\n\n'
          '📊 **Dengue platelet watch / प्लेटलेट:**\n'
          '• Normal: 1.5–4 lakh/mm³\n'
          '• < 1 lakh → close monitoring\n'
          '• < 20,000 → hospitalisation needed\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 🦟 Mosquito nets 🕸️, repellents (DEET), long sleeves\n'
          '• ❌ Eliminate standing water: pots, tyres, coolers\n\n'
          '🚨 **Emergency:** Bleeding 🩸, severe abdominal pain, breathlessness → Call 108\n\n'
          '_Malaria requires prescription antimalarials. Do not self-treat. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 26 💉 HIV / AIDS
    // EN: HIV, AIDS, sexually transmitted, antiretroviral, condom, STD
    // HI: HIV, AIDS, youn rog, antiretroviral, condom, STD
    // NE: HIV, AIDS, youn sanchaarit rog, antiretroviral, condom
    // BHO: HIV, AIDS, youn rog, condom, antiretroviral
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('hiv') || q.contains('aids') || q.contains('antiretroviral') ||
        q.contains('youn rog') || q.contains('sexually transmitted') ||
        q.contains('std') || q.contains('condom') || q.contains('art therapy')) {
      return '💉 **HIV & AIDS**\n\n'
          '🔬 **How it spreads / कैसे फैलता है:**\n'
          '• 💑 Unprotected sexual contact\n'
          '• 💉 Sharing needles or syringes\n'
          '• 🤰 Mother to child (birth/breastfeeding)\n'
          '• 🩸 Infected blood transfusion\n'
          '✅ **Does NOT spread** through hugging 🤗, sharing food 🍽️, or mosquito bites 🦟\n\n'
          '😓 **Early symptoms (2–4 wks after infection):**\n'
          'Flu-like illness 🤧, fever 🌡️, sore throat 😣, rash 🧴, swollen lymph nodes\n'
          '⚠️ Many have NO symptoms for years — only a test confirms HIV\n\n'
          '🏥 **Testing & Treatment / परीक्षण और उपचार:**\n'
          '• 🆓 ICTC centres across India — free confidential HIV testing\n'
          '• 💊 ART (Antiretroviral Therapy) — free at government hospitals\n'
          '• ✅ With ART: people with HIV live long, healthy, near-normal lives\n'
          '• ⏰ Start ART as early as possible after diagnosis\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• ✅ Use condoms consistently | 💊 PrEP for high-risk individuals\n'
          '• 🚫 Never share needles\n\n'
          '_Knowing your HIV status is the first step. Testing is free & confidential. 🆓_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 27 🫁 TUBERCULOSIS (TB)
    // EN: tuberculosis, TB, kshay, cough blood, night sweats, DOTS
    // HI: TB, kshay rog, rajyakshma, khoon wali khansi, DOTS, sputum
    // NE: TB, kshay rog, khoon ko khansi, DOTS, sputum parikshan
    // BHO: TB, kshay rog, khoon wali khansi, rajyakshma, TB ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('tuberculosis') || q.contains('kshay') || q.contains('rajyakshma') ||
        q.contains('dots') || q.contains('sputum') || q.contains('mantoux') ||
        q.contains('night sweats') || q.contains('cough blood') ||
        q.contains('tb symptoms') || q.contains('kshay rog') ||
        (q.contains('tb') && q.length < 10)) {
      return '🫁 **Tuberculosis (TB) / क्षय रोग / टीबी**\n\n'
          '😓 **Symptoms / लक्षण (weeks to months):**\n'
          '• 😷 Persistent cough > 2 weeks (may have 🩸 blood in sputum)\n'
          '• 🌡️ Evening fever + night sweats 💦\n'
          '• ⚖️ Unexplained weight loss + loss of appetite\n'
          '• 😴 Fatigue and weakness | 🫁 Chest pain while breathing\n\n'
          '🔬 **Diagnosis:** Sputum test, Chest X-ray, GeneXpert, Mantoux test\n\n'
          '💊 **Treatment (DOTS — free) / उपचार:**\n'
          '• 🆓 Free at all govt health centres — India & Nepal\n'
          '• ⏱️ Standard TB: 6 months | Drug-resistant (MDR-TB): 18–24 months\n'
          '• ✅ MUST complete full course — stopping causes resistance\n'
          '• 🥗 Nutritious diet + well-ventilated home supports recovery\n\n'
          '💰 **Nikshay Poshan Yojana (India):** ₹500/month nutritional support\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 💉 BCG vaccine at birth protects children\n'
          '• 🌬️ Ventilate rooms — open windows, avoid overcrowding\n'
          '• 😷 Cover mouth when coughing; 🚫 no spitting in public\n\n'
          '🚨 **TB is curable if treated fully. Stopping early causes drug resistance. ⚠️**';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 28 🧠 EPILEPSY / SEIZURES
    // EN: epilepsy, seizure, convulsion, fits, blackout, falling down
    // HI: mirgi, daura, fit, jhatkha, behoshi, mirgi ka dora
    // NE: epilepsy, mirgi, fit, jhatkha, daura, behosh bhayo
    // BHO: mirgi, daura, fit, jhatkha, behosh ho gail
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('epilepsy') || q.contains('seizure') || q.contains('mirgi') ||
        q.contains('convulsion') || q.contains('fits') || q.contains('jhatkha') ||
        q.contains('daura') || q.contains('fit aayo') || q.contains('mirgi ka dora') ||
        q.contains('behosh ho gail') || q.contains('fitting')) {
      return '🧠 **Epilepsy & Seizures / मिर्गी / दौरे**\n\n'
          '🆘 **During a seizure / दौरे के दौरान:**\n'
          '• 😌 Stay calm — most stop in 1–3 minutes\n'
          '• 🧹 Clear area of hard/sharp objects\n'
          '• 🔄 Place on side (recovery position) — prevents choking\n'
          '• 🛏️ Soft cushion under head\n'
          '• 👔 Loosen tight clothing around neck\n'
          '• ⏱️ Time the seizure — note start and end\n'
          '• 🚫 Do NOT: put anything in mouth | restrain | give food/water\n\n'
          '📞 **Call 108 immediately if / तुरंत 108 कॉल करें:**\n'
          '• Seizure lasts > 5 minutes\n'
          '• No regain of consciousness | Second seizure follows\n'
          '• Injury during seizure | First ever seizure\n'
          '• Seizure in pregnant woman or diabetic\n\n'
          '📋 **Living with epilepsy / मिर्गी के साथ जीना:**\n'
          '• 💊 Take AEDs consistently — never skip doses\n'
          '• 😴 Avoid triggers: sleep deprivation, alcohol, flashing lights\n'
          '• 🚗 Do not drive until seizure-free for prescribed period\n'
          '• 🏷️ Wear medical alert bracelet\n\n'
          '_70% of patients become seizure-free with proper medication. ✅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 29 🫘 KIDNEY HEALTH / KIDNEY STONE / UTI
    // EN: kidney, renal, kidney stone, creatinine, dialysis, nephritis
    // HI: gurda, kidney, gurde ki pathri, creatinine, dialysis
    // NE: मिर्गौला, gurda, kidney stone, creatinine, pathri
    // BHO: gurda, kidney, gurde mein pathri, creatinine
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('kidney') || q.contains('renal') || q.contains('gurda') ||
        q.contains('मिर्गौला') || q.contains('kidney stone') || q.contains('gurde ki pathri') ||
        q.contains('creatinine') || q.contains('dialysis') || q.contains('nephritis') ||
        q.contains('gurde mein pathri') || q.contains('pathri')) {
      return '🫘 **Kidney Health / गुर्दे की सेहत / मिर्गौला**\n\n'
          '⚠️ **Warning signs / चेतावनी:**\n'
          '• 🦶 Swelling in face, ankles, or feet\n'
          '• 💧 Reduced or no urine output\n'
          '• 🫧 Foamy or dark urine\n'
          '• 😴 Persistent fatigue and weakness\n'
          '• 💢 Severe back/flank pain (kidney stones)\n'
          '• 🩺 High BP that\'s hard to control\n\n'
          '🪨 **Kidney Stones / पथरी:**\n'
          '• 💧 Drink 2.5–3 litres water daily — best prevention\n'
          '• 💢 Renal colic: severe flank pain radiating to groin\n'
          '• 💊 Paracetamol/Diclofenac for pain (short-term)\n'
          '• ✅ Most stones < 5 mm pass on their own with fluids\n'
          '• 🏥 Stones > 6 mm or with fever → see doctor urgently\n\n'
          '📋 **Kidney health habits / किडनी की देखभाल:**\n'
          '• 💧 Stay well hydrated (2–3 L water/day)\n'
          '• 🩺 Control diabetes and BP\n'
          '• 💊 Avoid excessive NSAIDs — damage kidneys long-term\n'
          '• 🧂 Limit salt and processed foods\n\n'
          '_Get creatinine & urine tests annually if diabetic or hypertensive. 🧪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 30 🫀 LIVER HEALTH / JAUNDICE / HEPATITIS
    // EN: liver, jaundice, hepatitis, yellow eyes, fatty liver, cirrhosis
    // HI: jigar, piliya, kamla, hepatitis, aankhein peeli, fatty liver
    // NE: कलेजो, piliya, kamla, hepatitis, aankha pahelo
    // BHO: jigar, piliya, kamla rog, aankhein peeli, hepatitis
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('liver') || q.contains('jigar') || q.contains('कलेजो') ||
        q.contains('jaundice') || q.contains('piliya') || q.contains('kamla') ||
        q.contains('hepatitis') || q.contains('yellow eyes') || q.contains('aankhein peeli') ||
        q.contains('aankha pahelo') || q.contains('fatty liver') || q.contains('cirrhosis')) {
      return '🫀 **Liver Health & Jaundice / जिगर की सेहत / पीलिया**\n\n'
          '😟 **Jaundice symptoms / पीलिया के लक्षण:**\n'
          'Yellow skin & eyes 👁️🟡, dark urine 🌑, pale/clay stools,\n'
          'fatigue 😴, right upper abdomen pain 💢, nausea 🤢\n\n'
          '🔬 **Common causes:** Hepatitis A/B/E, gallstones 🪨, fatty liver, alcohol 🍺, medicines\n\n'
          '🏠 **For Hepatitis A/E (self-limiting) / हेपेटाइटिस A/E:**\n'
          '• 🛌 Rest completely for 2–4 weeks\n'
          '• 🍚 Eat light: rice, dal, boiled vegetables, curd, fruits\n'
          '• 💧 Drink plenty of fluids\n'
          '• 🚫 Strictly avoid alcohol, fatty food, unnecessary medicines\n'
          '• ✅ Most recover fully in 4–8 weeks\n\n'
          '💊 **Hepatitis B/C (blood-borne):** Specialist care + antiviral treatment\n'
          '• 💉 Hep B vaccine: 3 doses (0, 1, 6 months) — highly effective\n\n'
          '🥗 **Fatty liver prevention / फैटी लीवर:**\n'
          '• ⚖️ Lose weight gradually (5–10% reduces liver fat)\n'
          '• 🏃 Exercise 30 min/day | 🚫 Avoid alcohol\n\n'
          '🚨 **Emergency:** Severe abdominal pain + jaundice, confusion, vomiting blood → 108\n\n'
          '_Never exceed paracetamol dose if you have liver problems. ⚠️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 31 🤱 BREASTFEEDING
    // EN: breastfeeding, nursing, breast milk, lactation, nipple pain
    // HI: stan paan, dudh pilana, breast milk, stanya, nipple dard
    // NE: stan paan, dudh khuwaaunu, breast milk, stanya
    // BHO: dudh pilawna, stan paan, breast milk, stanya
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('breastfeed') || q.contains('nursing') || q.contains('breast milk') ||
        q.contains('stan paan') || q.contains('dudh pilana') || q.contains('stanya') ||
        q.contains('lactation') || q.contains('dudh khuwaaunu') || q.contains('nipple')) {
      return '🤱 **Breastfeeding / स्तनपान / दूध पिलाना**\n\n'
          '📋 **WHO recommendations / WHO सिफारिश:**\n'
          '• ⏰ Start within 1 hour of birth — colostrum is 🥇 gold\n'
          '• ✅ Exclusive breastfeeding for first 6 months (no water, no other food)\n'
          '• ✅ Continue up to 2 years alongside solid foods\n\n'
          '👶 **Benefits for baby / शिशु के लिए:**\n'
          'Perfect nutrition 🥇, antibodies 🛡️, prevents diarrhoea & pneumonia,\n'
          'reduces SIDS risk, allergies, obesity, diabetes\n\n'
          '👩 **Benefits for mother / माँ के लिए:**\n'
          'Uterus contracts faster, lower risk of breast & ovarian cancer 🎗️, type 2 diabetes\n\n'
          '📈 **Improving milk supply / दूध बढ़ाना:**\n'
          '• Feed frequently — supply = demand (8–12 times/day for newborns)\n'
          '• ✅ Good latch: baby covers areola, not just nipple\n'
          '• 💧 Stay well hydrated + eat nutritious food\n\n'
          '🩹 **Common problems / सामान्य समस्याएं:**\n'
          '• Sore nipples → check latch; apply expressed breast milk; air dry\n'
          '• Engorgement → feed frequently; warm compress before feeding\n'
          '• 🌡️ Mastitis (red painful lump + fever) → antibiotics needed — see doctor\n\n'
          '_Breastfeeding is one of the most powerful acts for child health. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 32 🧒 PUBERTY / ADOLESCENT HEALTH
    // EN: puberty, adolescent, teenager, growing up, teen health
    // HI: yauvankaal, kishore, teenager, badhna, masik dharm, teen
    // NE: yauvankaal, kishor swasthya, teenager, badhnu
    // BHO: yauvankaal, kishor, teenager, badhna
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('puberty') || q.contains('adolescent') || q.contains('yauvankaal') ||
        q.contains('teenager') || q.contains('kishor') || q.contains('growing up') ||
        q.contains('teen health') || q.contains('badhna') || q.contains('yauvan')) {
      return '🧒 **Puberty & Adolescent Health / यौवनकाल / किशोर स्वास्थ्य**\n\n'
          '👧 **Girls (8–13 yrs) / लड़कियाँ:**\n'
          '• Breast development 🌸, pubic/underarm hair, growth spurt 📈\n'
          '• First period (menarche): normal range 10–16 years\n\n'
          '👦 **Boys (9–14 yrs) / लड़के:**\n'
          '• Testicular/penile growth, facial/pubic hair, voice deepening 🎤\n'
          '• Muscle mass increase, growth spurt\n\n'
          '😊 **Normal changes / सामान्य बदलाव:**\n'
          '• 😰 Mood swings — normal hormonal changes\n'
          '• 😤 Acne — wash face 2x daily; avoid squeezing\n'
          '• 💦 Body odour — bathe daily; use deodorant\n\n'
          '🩸 **Menstrual health / मासिक धर्म:**\n'
          '• Normal cycle: 21–35 days | Duration: 2–7 days\n'
          '• Mild cramps: warm compress 🌡️, Ibuprofen 400 mg\n'
          '• Change pad/tampon every 4–8 hours\n\n'
          '✅ **Teen health habits / स्वस्थ आदतें:**\n'
          '• 😴 Sleep 8–10 hrs | 🥗 Iron-rich foods | 🏃 60 min activity/day\n'
          '• 🚫 Avoid tobacco, alcohol, drugs — permanently affect development\n\n'
          '_Puberty changes are completely normal. Talk to a doctor if concerned. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 33 👴 ELDERLY HEALTH
    // EN: elderly, old age, senior, aging, geriatric, fall prevention
    // HI: budhapa, bujurg, senior, wriddhawastha, girne se bachna
    // NE: budhaapa, wriddhawastha, senior, bujurg, budhaa ko swasthya
    // BHO: budhapa, bujurg, senior, budhaa ke sehat
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('elderly') || q.contains('old age') || q.contains('budhapa') ||
        q.contains('bujurg') || q.contains('senior') || q.contains('wriddhawastha') ||
        q.contains('aging') || q.contains('ageing') || q.contains('geriatric') ||
        q.contains('budhaapa') || q.contains('budhaa ko')) {
      return '👴 **Elderly Health / बुज़ुर्गों की सेहत / वृद्धावस्था**\n\n'
          '⚠️ **Key concerns / प्रमुख चिंताएं:**\n'
          '• 🪜 Falls — leading cause of injury in elderly\n'
          '• 💊 Polypharmacy — multiple medicines; review regularly\n'
          '• 🧠 Memory decline — early Alzheimer\'s detection\n'
          '• 💔 Loneliness and depression — social connection vital\n'
          '• 🥗 Malnutrition — appetite falls but nutrient needs stay high\n\n'
          '🛡️ **Fall prevention / गिरने से बचाव:**\n'
          '• 🧹 Remove loose rugs and clutter\n'
          '• 🚿 Install grab bars in bathroom and beside bed\n'
          '• 💡 Ensure adequate lighting in all rooms\n'
          '• 🧘 Balance exercises: Tai Chi, yoga, leg-strengthening\n'
          '• 👓 Regular vision & hearing checks\n\n'
          '🥗 **Nutrition for elderly / पोषण:**\n'
          '• 🍗 Protein: dal, eggs, curd, fish (prevents muscle wasting)\n'
          '• 🦴 Calcium + Vit D: dairy, fortified foods, sunlight\n'
          '• 💧 Water: 6–8 glasses (thirst reduces with age)\n\n'
          '🔍 **Annual checks / वार्षिक जांच:**\n'
          'Blood sugar 🩸, BP 🩺, cholesterol 🫀, kidney 🫘, eye exam 👁️, dental 🦷\n\n'
          '_Active, well-nourished, socially connected — the 3 pillars of healthy ageing. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 34 💊 VITAMIN DEFICIENCY
    // EN: vitamin deficiency, vitamin D, vitamin B12, calcium, rickets
    // HI: vitamin ki kami, vitamin D, vitamin B12, calcium, sukha rog
    // NE: vitamin ko kami, vitamin D, vitamin B12, calcium, kami rog
    // BHO: vitamin ki kami, vitamin D, B12, calcium ki kami
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('vitamin') || q.contains('deficiency') || q.contains('vitamin d') ||
        q.contains('vitamin b12') || q.contains('vitamin c') || q.contains('calcium') ||
        q.contains('rickets') || q.contains('sukha rog') || q.contains('supplement') ||
        q.contains('vitamin ki kami') || q.contains('kami rog') || q.contains('multivitamin')) {
      return '💊 **Vitamin Deficiency / विटामिन की कमी**\n\n'
          '☀️ **Vitamin D (very common in South Asia) / विटामिन D:**\n'
          '• Symptoms: 🦴 Bone pain, 💪 muscle weakness, 😴 fatigue, 🤒 frequent infections\n'
          '• Sources: ☀️ Sunlight 15 min/day, fatty fish, egg yolk, fortified milk\n'
          '• Supplement: Vitamin D3 1000–2000 IU/day\n\n'
          '🔴 **Vitamin B12 (common in vegetarians) / विटामिन B12:**\n'
          '• Symptoms: 😴 Extreme fatigue, 🤲 tingling hands/feet, 🧠 poor memory, pale skin\n'
          '• Sources: Meat 🥩, fish 🐟, eggs 🥚, dairy 🥛, fortified cereals\n'
          '• Supplement: Methylcobalamin 500 mcg daily or B12 injection\n\n'
          '🍋 **Vitamin C:**\n'
          '• Symptoms: 🦷 Bleeding gums, slow wound healing, easy bruising\n'
          '• Sources: Amla 🟢, guava, lemon 🍋, orange 🍊, bell pepper\n\n'
          '🦴 **Calcium:**\n'
          '• Symptoms: 💢 Muscle cramps, weak/brittle nails, frequent fractures\n'
          '• Sources: Milk 🥛, ragi, sesame, paneer, green leafy vegetables\n\n'
          '_A balanced diet prevents most vitamin deficiencies. Supplements when diet insufficient. ⚠️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 35 🌞 DEHYDRATION
    // EN: dehydration, dehydrated, thirsty, dark urine, dry mouth, no water
    // HI: paani ki kami, nijalikaran, pyaas, mooh sukha, peela peshab
    // NE: paani ko kami, nijalata, tirkha, mukhko sukha
    // BHO: paani ki kami, thakaan, pyaas laagata, mooh sukha gail
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('dehydration') || q.contains('dehydrated') || q.contains('paani ki kami') ||
        q.contains('nijalikaran') || q.contains('nijalata') || q.contains('thirsty') ||
        q.contains('dark urine') || q.contains('peela peshab') || q.contains('dry mouth') ||
        q.contains('mooh sukha') || q.contains('not drinking water')) {
      return '🌞 **Dehydration / पानी की कमी / निर्जलीकरण**\n\n'
          '😓 **Signs / लक्षण:**\n'
          '• Mild-moderate: 🌡️ Thirst, dry mouth, dark yellow urine, headache, dizziness\n'
          '• Severe: No urine 8+ hrs, sunken eyes, rapid heartbeat, confusion 😵\n'
          '• 👶 Infants: No tears crying, sunken fontanelle, no wet nappy 6+ hrs\n\n'
          '💧 **Treatment / उपचार:**\n'
          '• Mild: Drink water, coconut water, ORS, diluted juice\n'
          '• 🏠 ORS recipe: 1 L water + 6 tsp sugar + ½ tsp salt\n'
          '• If vomiting: 1 tsp every 5 min\n\n'
          '📊 **Daily water intake / दैनिक पानी की जरूरत:**\n'
          '• Adults: 2–2.5 litres (8 glasses) under normal conditions\n'
          '• More needed: 🥵 Hot weather | 🏃 Exercise | 🌡️ Fever | 🤢 Diarrhoea | 🤰 Pregnancy\n\n'
          '🔍 **Urine colour check / पेशाब का रंग:**\n'
          '• 💛 Pale yellow = ✅ Well hydrated\n'
          '• 🟡 Dark yellow = ⚠️ Drink more water\n'
          '• 🟠 Orange/brown = 🚨 Severely dehydrated\n\n'
          '🚨 **Hospital for:** Severe dehydration, especially in infants and elderly → Call 108\n\n'
          '_Prevention: drink water regularly, don\'t wait until thirsty. 💧_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 36 🔥 BURNS / WOUNDS
    // EN: burn, scald, blister, wound, cut, bleeding, injury, laceration
    // HI: jalna, jalana, jalana, chot, zakhm, kata, khoon, ghav
    // NE: polnu, jalna, chot, ghāu, kata, khoon
    // BHO: jalna, chot, ghav, kata, khoon aawata, dard
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('burn') || q.contains('jalna') || q.contains('polnu') ||
        q.contains('scald') || q.contains('blister') || q.contains('wound') ||
        q.contains('zakhm') || q.contains('ghav') || q.contains('ghāu') ||
        q.contains('cut') || q.contains('kata') || q.contains('bleeding') ||
        q.contains('injury') || q.contains('laceration') || q.contains('chot')) {
      return '🔥 **Burns & Wound First Aid / जलना और घाव**\n\n'
          '🔥 **For burns / जलने पर:**\n'
          '• 💧 Cool under running water for 20 min immediately — ठंडे पानी से\n'
          '• 💍 Remove jewellery/clothing near burn (before swelling)\n'
          '• 🩹 Cover loosely with clean non-fluffy bandage or cling film\n'
          '• 💊 Paracetamol for pain\n'
          '• 🚫 Do NOT: butter 🧈, toothpaste, or ice ❄️ on burns\n'
          '• 🚫 Do NOT break blisters\n\n'
          '📊 **Burn severity / जलने की गंभीरता:**\n'
          '• 1st degree (red, no blisters) 🔴 — treat at home\n'
          '• 2nd degree (blisters, very painful) 🟠 — see doctor\n'
          '• 3rd degree (white/charred, painless) ⚫ — emergency hospital\n\n'
          '🩹 **For cuts / wounds / कटने पर:**\n'
          '• Apply firm direct pressure with clean cloth to stop bleeding\n'
          '• 💧 Clean with clean water and mild soap\n'
          '• 🟤 Apply antiseptic (Betadine / Savlon)\n'
          '• 🩹 Cover with sterile dressing; change daily\n\n'
          '🚨 **Go to hospital:** Burns > 5 cm, on face/hands/genitals, chemical/electrical burns\n'
          'Deep cuts, wounds from rusty objects, animal bites → tetanus injection needed\n\n'
          '_Infection signs: redness, warmth, pus, fever — see doctor. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 37 🐍 SNAKEBITE / POISONING
    // EN: snakebite, snake bite, poisoning, overdose, toxic, venom
    // HI: saanp kata, saanp ka zeher, zaher, overdose, zeher kha liya
    // NE: saanpko टोकाइ, bish, zeher, overdose
    // BHO: saanp katale, zeher, overdose, bish
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('snakebite') || q.contains('snake bite') || q.contains('saanp') ||
        q.contains('saanpko') || q.contains('venom') || q.contains('zeher') ||
        q.contains('bish') || q.contains('poisoning') || q.contains('poisoned') ||
        q.contains('overdose') || q.contains('toxic') || q.contains('swallowed')) {
      return '🐍 **Snakebite & Poisoning / साँप काटना / विष**\n\n'
          '🚨 **SNAKEBITE — EMERGENCY / तुरंत 108 कॉल करें!**\n\n'
          '✅ **Do / करें:**\n'
          '• 😌 Keep person calm and still — movement spreads venom faster\n'
          '• 🦵 Immobilise bitten limb at or below heart level\n'
          '• 💍 Remove rings, watches, tight clothing near bite site\n'
          '• ⏱️ Note time of bite; try to remember snake appearance\n'
          '• 🏥 Transport to nearest hospital with anti-venom immediately\n\n'
          '🚫 **Do NOT / न करें:**\n'
          '• ❌ Cut the bite or suck out venom\n'
          '• ❌ Apply tourniquet or ice\n'
          '• ❌ Give food, drink, or traditional remedies\n\n'
          '☎️ **Poison Control India: 1800-116-117** (Toll free)\n\n'
          '☠️ **For other poisoning / other ingestion:**\n'
          '• 🚫 Do NOT induce vomiting unless specifically told to\n'
          '• 💧 Skin/eye exposure: rinse 15–20 min with large amounts of water\n'
          '• 📦 Take the container/medicine bottle to hospital\n\n'
          '💊 **Medicine overdose:** Emergency room immediately — bring medicine bottle/strip\n\n'
          '_All suspected snakebites are emergencies — even if no immediate symptoms. ⚠️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 38 🦴 FRACTURE / SPRAIN
    // EN: fracture, sprain, broken bone, twisted ankle, dislocation, strain
    // HI: haddi tootna, moch, naso mein khinchav, dislocate, haड्डी टूटना
    // NE: haddi bhāchnu, moch, tarsai, dislocate
    // BHO: haddi toot gail, moch, naso mein dard, dislocate
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('fracture') || q.contains('sprain') || q.contains('haddi tootna') ||
        q.contains('haddi toot') || q.contains('haddi bhāchnu') || q.contains('broken bone') ||
        q.contains('moch') || q.contains('twisted ankle') || q.contains('dislocation') ||
        q.contains('strain') || q.contains('tarsai') || q.contains('dislocate')) {
      return '🦴 **Fracture & Sprain / हड्डी टूटना / मोच**\n\n'
          '🧊 **RICE method for sprains / मोच के लिए:**\n'
          '• 🛌 Rest — activity बंद करें\n'
          '• 🧊 Ice — 20 min every 2–3 hrs (first 48 hrs)\n'
          '• 🩹 Compression — elastic bandage (not too tight)\n'
          '• 🦵 Elevation — raise limb above heart level\n\n'
          '🦴 **For suspected fracture / हड्डी टूटने पर:**\n'
          '• 🚫 Do NOT try to straighten the limb\n'
          '• 📰 Immobilise with whatever available (rolled newspaper, cloth)\n'
          '• 🧊 Ice pack wrapped in cloth\n'
          '• 🏥 Hospital for X-ray immediately\n\n'
          '💊 **Medicines:** Ibuprofen 400 mg or Paracetamol 500 mg for pain\n\n'
          '🥗 **Bone healing nutrition / हड्डी की मरम्मत:**\n'
          '• 🦴 Calcium: dairy, ragi, sesame | ☀️ Vitamin D: sunlight, eggs, fish\n'
          '• 🍗 Protein: dal, eggs, meat (essential for bone repair)\n\n'
          '🚨 **Emergency — Call 108 for:**\n'
          '• 😱 Bone visibly deformed or through skin\n'
          '• 😶 Numbness, tingling, can\'t move\n'
          '• 🏥 Spine/neck/hip injury — do NOT move, call 108\n\n'
          '_Spinal injuries: never move the person — wait for emergency services. 🚑_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 39 😴 FATIGUE / WEAKNESS
    // EN: fatigue, tired, weakness, no energy, exhausted, always tired
    // HI: thakaan, kamzori, shakti ki kami, hamesha thaka, ulaan
    // NE: थकाइ, kamjori, shakti ko kami, hamesha thakeko
    // BHO: thakaan, kamzori, shakti ke kami, sada thaka rehata
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('fatigue') || q.contains('tired') || q.contains('thakaan') ||
        q.contains('थकाइ') || q.contains('kamzori') || q.contains('weak') ||
        q.contains('kamjori') || q.contains('no energy') || q.contains('exhausted') ||
        q.contains('always tired') || q.contains('sada thaka') || q.contains('ulaan')) {
      return '😴 **Fatigue & Weakness / थकान / कमज़ोरी**\n\n'
          '🔍 **Common causes / सामान्य कारण:**\n'
          '• 😴 Poor sleep (< 7 hours)\n'
          '• 🩸 Anaemia (low haemoglobin)\n'
          '• 🩺 Diabetes or low blood sugar\n'
          '• 🦋 Thyroid problems (hypothyroidism)\n'
          '• 💊 Vitamin D or B12 deficiency\n'
          '• 💙 Depression or chronic stress\n'
          '• 💧 Dehydration\n'
          '• 🦠 Infections (TB, viral fever)\n\n'
          '🌿 **Self-care / स्वयं देखभाल:**\n'
          '• 😴 Sleep 7–9 hours at consistent times\n'
          '• 🥗 Iron + protein rich meals (dal, eggs, green vegetables, meat)\n'
          '• 💧 Drink 8+ glasses of water daily\n'
          '• 🚶 Light exercise (20 min walk) often reduces fatigue\n'
          '• ☕ Avoid caffeine after 3 PM\n\n'
          '🧪 **Get tested for / परीक्षण करवाएं:**\n'
          '• CBC — anaemia check 🩸\n'
          '• Blood sugar (fasting + HbA1c) 🩺\n'
          '• Thyroid function (TSH) 🦋\n'
          '• Vitamin B12 and D levels 💊\n\n'
          '🚨 **See doctor urgently:** Fatigue + chest pain 🫀 / breathlessness 😮‍💨 / unexplained weight loss ⚖️\n\n'
          '_Fatigue is a symptom, not a diagnosis — blood tests find the cause. 🔬_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 40 🤧 SINUSITIS
    // EN: sinusitis, sinus, nasal congestion, blocked nose, facial pain
    // HI: sinusitis, naak band, chehra dard, sinus ka dard, nasal infection
    // NE: sinusitis, naak thuneko, sinusको दुखाइ, nasal sinkraman
    // BHO: sinusitis, naak band baa, chehra mein dard, sinus bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('sinus') || q.contains('sinusitis') || q.contains('naak band') ||
        q.contains('nasal congestion') || q.contains('blocked nose') ||
        q.contains('naak thuneko') || q.contains('facial pain') ||
        q.contains('chehra dard') || q.contains('postnasal')) {
      return '🤧 **Sinusitis / साइनसाइटिस / नाक बंद**\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          'Blocked/runny nose 🤧, facial pain/pressure 😣 (worse bending forward),\n'
          'headache 🤕 behind forehead/eyes, thick yellow/green mucus 🟡, reduced smell 👃\n\n'
          '🏠 **Home treatment / घरेलू उपचार:**\n'
          '• 💨 Steam inhalation 2x daily (add eucalyptus oil drop)\n'
          '• 🌡️ Warm compress over forehead and cheeks\n'
          '• 🧂 Saline nasal rinse / neti pot — clears passages naturally\n'
          '• 💧 Stay well hydrated to thin mucus\n'
          '• 💊 Decongestant nasal spray (Oxymetazoline) — max 3 days only\n'
          '• 🛏️ Sleep with head slightly elevated\n\n'
          '💊 **Medicines / दवाइयां:**\n'
          '• Paracetamol or Ibuprofen for pain\n'
          '• Cetrizine for allergic component\n'
          '• Antibiotic only if bacterial (doctor decides)\n\n'
          '🚨 **See doctor if:**\n'
          '• Symptoms > 10 days or worsening after 7 days\n'
          '• Severe headache, high fever 🌡️, stiff neck, vision changes 👁️\n'
          '• Swelling around eyes 👁️\n\n'
          '_Most sinusitis is viral — antibiotics NOT needed unless bacterial confirmed. 🚫_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 41 💧 ORS / REHYDRATION
    // EN: ORS, oral rehydration, electrolyte, jeevan jal, salt sugar water
    // HI: ORS, jeevan jal, namak cheeni paani, electrolyte
    // NE: ORS, jeevan jal, nimak chini pani, electrolyte
    // BHO: ORS, jeevan jal, namak cheeni ke paani, electrolyte
    // ─────────────────────────────────────────────────────────────────────────
    if ((q.contains('ors') && q.length < 15) || q.contains('oral rehydration') ||
        q.contains('jeevan jal') || q.contains('electrolyte') ||
        q.contains('nimak chini') || q.contains('namak cheeni paani') ||
        q.contains('rehydration') || q.contains('salt sugar water')) {
      return '💧 **ORS — Oral Rehydration Salts / जीवन जल**\n\n'
          '❓ **What is ORS? / ORS क्या है?**\n'
          'A simple, life-saving drink that replaces fluids and electrolytes lost\n'
          'through diarrhoea 🤢, vomiting 🤮, fever 🌡️, or excessive sweating 💦\n\n'
          '🏠 **How to prepare / कैसे बनाएं:**\n'
          '• Commercial: Electral / ORS-L sachet + 1 L boiled cooled water\n'
          '• 🏡 Home-made: **6 level tsp sugar + ½ tsp salt in 1 litre water**\n'
          '• Mix thoroughly until dissolved ✅\n'
          '• Use within 24 hours; discard remainder\n\n'
          '🥄 **How to give / कैसे दें:**\n'
          '• Adults: drink freely as tolerated\n'
          '• Young children: 50–100 ml after each loose stool\n'
          '• If vomiting: 1 teaspoon every 2–3 minutes; increase slowly\n\n'
          '✅ **When to use / कब उपयोग करें:**\n'
          'Diarrhoea 🤢 | Vomiting 🤮 | Fever 🌡️ | Heat exhaustion 🥵 | Heavy exercise 🏃\n\n'
          '🚨 **ORS prevents dehydration** — it does NOT stop diarrhoea.\n'
          'See doctor if diarrhoea > 3 days, blood in stool, or severe dehydration.\n\n'
          '_ORS has saved millions of lives. It is on the WHO Essential Medicines List. 🌍_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 42 🏥 BASIC FIRST AID / CPR
    // EN: first aid, CPR, choking, heimlich, fainting, unconscious person
    // HI: prathamik upchar, CPR, damdama, behosh, damo mein aakar
    // NE: prathamik upchar, CPR, damdama, behosh
    // BHO: prathamik ilaaj, CPR, damdama, behosh
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('first aid') || q.contains('prathamik upchar') || q.contains('cpr') ||
        q.contains('prathamik ilaaj') || q.contains('choking') || q.contains('heimlich') ||
        q.contains('fainting') || q.contains('fainted') || q.contains('damdama')) {
      return '🏥 **Basic First Aid / प्राथमिक उपचार / CPR**\n\n'
          '💓 **CPR / कार्डियोपल्मोनरी रिससिटेशन:**\n'
          '• ❓ Check: Is person unconscious + not breathing normally?\n'
          '• 📞 Call 108 immediately\n'
          '• 💪 30 chest compressions: centre of chest, hard & fast (100–120/min)\n'
          '• 💨 2 rescue breaths: tilt head, lift chin, blow 1 sec\n'
          '• 🔄 Continue 30:2 until help arrives or person recovers\n\n'
          '😮 **Choking / दम घुटना:**\n'
          '• 👏 Encourage coughing if they can\n'
          '• 👋 5 back blows (between shoulder blades with heel of hand)\n'
          '• 🤜 5 abdominal thrusts (Heimlich): fist above navel, sharp upward push\n'
          '• 🔄 Repeat until dislodged or unconscious → start CPR\n\n'
          '😵 **Fainting / बेहोशी:**\n'
          '• 🛌 Lay flat; raise legs 30 cm (improves blood flow to brain)\n'
          '• 👔 Loosen tight clothing; fresh air\n'
          '• 🚫 No water until fully conscious\n'
          '• 📞 No recovery in 1 min → call 108\n\n'
          '🏊 **Drowning / डूबना:**\n'
          '• Only trained person enters water\n'
          '• On shore: clear airway, start CPR if not breathing\n'
          '• Call 108 even if person appears to recover\n\n'
          '_Learn CPR — a simple skill that saves lives in minutes. 💪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 43 🦠 COVID-19
    // EN: COVID, corona, coronavirus, omicron, COVID symptoms
    // HI: COVID, corona, coronavirus, omicron, COVID ke lakshan
    // NE: COVID, corona, coronavirus, COVID ko lakshan
    // BHO: COVID, corona, coronavirus, COVID ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('covid') || q.contains('corona') || q.contains('coronavirus') ||
        q.contains('omicron') || q.contains('sars-cov') || q.contains('covid symptoms') ||
        q.contains('covid ki bimari') || q.contains('covid ke lakshan')) {
      return '🦠 **COVID-19**\n\n'
          '😓 **Common symptoms / लक्षण:**\n'
          'Fever 🌡️, cough 😷, sore throat 😣, runny nose 🤧, headache 🤕,\n'
          'body aches 💢, fatigue 😴, loss of taste/smell 👅👃, diarrhoea 🤢\n\n'
          '🏠 **Home care (mild) / घरेलू देखभाल:**\n'
          '• 🛌 Rest and drink plenty of fluids\n'
          '• 💊 Paracetamol for fever and pain\n'
          '• 😷 Isolate from family members for 5 days\n'
          '• 🔴 Monitor SpO2 (oxygen) with pulse oximeter\n'
          '• ⚠️ SpO2 < 94% → seek medical attention immediately\n\n'
          '🚨 **Emergency signs — Call 108 / आपातकाल:**\n'
          '• 😮‍💨 Difficulty breathing or persistent chest pain\n'
          '• 🔴 SpO2 < 94% on pulse oximeter\n'
          '• 😵 Confusion or inability to stay awake\n'
          '• 🔵 Bluish lips or face\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 💉 COVID-19 vaccination — protects against severe disease\n'
          '• 😷 Mask in crowded, poorly ventilated spaces\n'
          '• 🙌 Hand hygiene: wash 20 sec with soap\n'
          '• 🌬️ Ventilate indoor spaces — open windows\n\n'
          '🦠 **Long COVID:** Symptoms > 4 weeks → see doctor for assessment\n\n'
          '_Get vaccinated and boosted as recommended. 💉_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 44 🦠 WOUND INFECTION / SEPSIS
    // EN: wound infection, sepsis, pus, abscess, infected cut, red streaks
    // HI: ghav mein sankraman, pus, phoda, laal dhariyaan, sepsis
    // NE: ghāu ko sankraman, pus, phoda, laal dharr, sepsis
    // BHO: ghav mein sankraman, pus, phoda, laal nishaani, sepsis
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('wound infection') || q.contains('sepsis') || q.contains('pus') ||
        q.contains('abscess') || q.contains('infected') || q.contains('red streak') ||
        q.contains('sankraman') || q.contains('phoda') || q.contains('ghav mein')) {
      return '🦠 **Wound Infection & Sepsis / घाव संक्रमण / पस**\n\n'
          '⚠️ **Signs of wound infection / संक्रमण के संकेत:**\n'
          '• 🔴 Increasing redness, warmth, swelling around wound\n'
          '• 🟡 Yellow/green pus discharge\n'
          '• 👃 Bad smell from wound\n'
          '• 🔴 Red streaks spreading from wound (serious!)\n'
          '• 🌡️ Fever and chills\n\n'
          '🩹 **Basic wound care to prevent infection:**\n'
          '• 💧 Clean with running water + mild soap\n'
          '• 🟤 Apply antiseptic (Betadine / Savlon)\n'
          '• 🩹 Cover with sterile dressing; change daily\n'
          '• Keep wound dry; don\'t submerge in water\n\n'
          '💊 **If infection develops:** See doctor for antibiotic prescription\n'
          '• 🚫 Do NOT squeeze pus from abscess\n'
          '• 🌡️ Warm compress may help draw out superficial infections\n\n'
          '🆘 **Sepsis — life-threatening / जानलेवा:**\n'
          'Signs: High fever OR very low temp, rapid heartbeat 💓, rapid breathing,\n'
          'confusion 😵, extreme weakness, blotchy skin\n\n'
          '🚨 **Sepsis = Medical Emergency → Call 108 NOW**\n'
          'Every hour of delay increases risk of death.\n\n'
          '_Animal bites + deep puncture wounds → tetanus injection always needed. 💉_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 45 🩹 WOUND CARE / DRESSING
    // EN: wound care, dressing, how to clean wound, bandage, antiseptic
    // HI: ghav ki dekhbhal, patti, ghav saaf karna, antiseptic
    // NE: ghāu ko herchah, patti, ghāu saaf garnu, antiseptic
    // BHO: ghav ke dekhbhal, patti, ghav saaf karna, antiseptic
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('wound care') || q.contains('dressing') || q.contains('bandage') ||
        q.contains('antiseptic') || q.contains('how to clean wound') ||
        q.contains('ghav saaf') || q.contains('ghāu saaf') || q.contains('patti')) {
      return '🩹 **Wound Care & Dressing / घाव की देखभाल**\n\n'
          '📋 **Step-by-step / चरण-दर-चरण:**\n'
          '1. 🙌 Wash hands thoroughly with soap before touching wound\n'
          '2. 💧 Rinse wound under clean running water for 5–10 minutes\n'
          '3. 🧽 Clean gently with mild soap; remove visible dirt\n'
          '4. 🟤 Apply antiseptic (Betadine / Povidone-iodine / Savlon)\n'
          '5. 🩹 Cover with sterile gauze; secure with medical tape\n\n'
          '🔄 **Daily dressing change / रोज़ाना पट्टी बदलें:**\n'
          '• Change once or twice daily, or when wet/dirty\n'
          '• Moisten old dressing with saline if it sticks\n'
          '• Let wound air-dry briefly before re-dressing\n\n'
          '🔬 **Types of wounds / घाव के प्रकार:**\n'
          '• Abrasion (graze) 🟤 — clean, antiseptic, leave open if small\n'
          '• Laceration (cut) 🔴 — deep cuts need stitches within 6 hrs\n'
          '• Puncture (nail, thorn) ⚫ — clean well; high tetanus risk\n'
          '• Bite wound 🐕 — rabies prophylaxis within 24 hrs\n\n'
          '🚨 **Go to hospital for:**\n'
          '• Deep wounds that won\'t close | Wounds from rusty objects\n'
          '• Any animal bite | Signs of infection (pus, fever 🌡️, red streaks)\n\n'
          '_A clean moist (not wet) wound heals fastest. ✅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 46 🩸 MENSTRUAL HEALTH / PCOS
    // EN: menstrual, period, cramps, dysmenorrhea, PCOS, irregular period
    // HI: maahwari, masik dharm, period dard, PCOS, irregular period
    // NE: maahwari, masik dharma, period dukhāi, PCOS, अनियमित
    // BHO: maahwari, period, masik dard, PCOS, period nahi aawa
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('menstrual') || q.contains('menstruation') || q.contains('maahwari') ||
        q.contains('masik dharm') || q.contains('period') || q.contains('pcos') ||
        q.contains('dysmenorrhea') || q.contains('irregular period') ||
        q.contains('heavy period') || q.contains('period dard') || q.contains('period nahi')) {
      return '🩸 **Menstrual Health / मासिक धर्म / PCOS**\n\n'
          '📊 **Normal cycle / सामान्य चक्र:**\n'
          '• Length: 21–35 days | Duration: 2–7 days | Flow: light to moderate\n\n'
          '😣 **For menstrual cramps / दर्द के लिए:**\n'
          '• 💊 Ibuprofen 400 mg with food — start 1 day before expected period\n'
          '• 🌡️ Warm compress on lower abdomen\n'
          '• 🧘 Light exercise (walking, yoga) helps\n'
          '• 💧 Stay hydrated; avoid excess caffeine ☕\n\n'
          '🔄 **PCOS / पॉलीसिस्टिक ओवरी:**\n'
          '• Symptoms: Irregular/absent periods, excess hair 🧖, acne 😤, weight gain ⚖️\n'
          '• Management: Weight loss 🏃, exercise, low-carb diet, hormonal pills (doctor only)\n\n'
          '🧼 **Hygiene / स्वच्छता:**\n'
          '• Change pad every 4–6 hrs; tampon/cup every 4–8 hrs\n'
          '• Wash external area with water — no harsh soaps inside\n\n'
          '🚨 **See doctor for:**\n'
          '• ⏭️ Periods absent > 3 months (not pregnant)\n'
          '• 🩸 Soaking pad in < 1 hour (very heavy bleeding)\n'
          '• 💢 Severe pain not relieved by Ibuprofen\n'
          '• 🌡️ Period with fever or foul-smelling discharge\n\n'
          '_Track your cycle on a calendar or app. 📅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 47 🫀 HEART PALPITATIONS
    // EN: palpitation, heart racing, fast heartbeat, irregular heartbeat, flutter
    // HI: dhak dhak, dil ki dhadkan, tez dhadkan, dil ka uljhan
    // NE: dhak dhak, dil ko dhadkan, छिटो मुटु, irregular heartbeat
    // BHO: dhak dhak, dil ke dhadkan, tez dhadkan
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('palpitation') || q.contains('dhak dhak') || q.contains('heart racing') ||
        q.contains('fast heartbeat') || q.contains('dil ki dhadkan') ||
        q.contains('छिटो मुटु') || q.contains('irregular heartbeat') ||
        q.contains('heart flutter') || q.contains('skipping beat') ||
        q.contains('dil ka uljhan') || q.contains('tez dhadkan')) {
      return '🫀 **Heart Palpitations / दिल की धड़कन / धक-धक**\n\n'
          '❓ **What are palpitations? / धड़कन क्या है?**\n'
          'Feeling of heart beating fast, hard, or irregularly.\n'
          'Usually harmless, but can indicate a heart problem.\n\n'
          '🔍 **Common benign causes / सामान्य कारण:**\n'
          '☕ Caffeine | 😰 Stress & anxiety | 💧 Dehydration\n'
          '🩸 Anaemia | 🦋 Overactive thyroid | 🏋️ Strenuous exercise\n'
          '🚬 Nicotine | 🍺 Alcohol\n\n'
          '🌿 **During palpitations / धड़कन के दौरान:**\n'
          '• 🪑 Sit down and rest\n'
          '• 💪 Valsalva: deep breath, bear down 15 sec\n'
          '• 💧 Splash cold water on face\n'
          '• 🌬️ Breathe slowly and deeply\n\n'
          '📉 **Reduce triggers / ट्रिगर कम करें:**\n'
          '• ☕ Cut caffeine & alcohol | 🚭 Quit smoking\n'
          '• 🧘 Manage stress | 💧 Stay hydrated\n\n'
          '🚨 **Call 108 for palpitations WITH:**\n'
          '• 🫀 Chest pain or tightness\n'
          '• 😮‍💨 Difficulty breathing\n'
          '• 😵 Fainting or severe dizziness\n'
          '• ⏱️ Lasting > 30 minutes\n'
          '• 🩺 Known heart disease\n\n'
          '_An ECG (electrocardiogram) can identify type of arrhythmia. 🧪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 48 🦶 SWOLLEN FEET / LEGS
    // EN: swollen feet, swollen ankles, swollen leg, oedema, puffiness
    // HI: pair mein sujan, pair phoolna, paon phoolna, oedema
    // NE: खुट्टा सुन्निनु, pair mein sujan, oedema
    // BHO: pair mein sujan, paon phool gail, oedema
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('swollen feet') || q.contains('swollen ankle') || q.contains('swollen leg') ||
        q.contains('pair mein sujan') || q.contains('pair phoolna') || q.contains('paon phoolna') ||
        q.contains('खुट्टा सुन्निनु') || q.contains('oedema') || q.contains('edema') ||
        q.contains('foot swelling') || q.contains('puffiness') || q.contains('paon phool')) {
      return '🦶 **Swollen Feet & Ankles / पैरों की सूजन / खुट्टा सुन्निनु**\n\n'
          '🔍 **Common causes / सामान्य कारण:**\n'
          '• 🪑 Prolonged standing or sitting\n'
          '• 🥵 Hot weather\n'
          '• 🧂 High salt intake\n'
          '• 🤰 Pregnancy (normal after 20 weeks)\n'
          '• ❤️ Heart, kidney 🫘, or liver 🫀 problems\n'
          '• 🩸 Blood clot — DVT (Deep Vein Thrombosis)\n'
          '• 💊 Certain medicines (steroids, calcium channel blockers)\n\n'
          '🌿 **Simple relief / राहत:**\n'
          '• 🦵 Elevate legs above heart level 30 min, 3–4 times/day\n'
          '• 🧂 Reduce salt intake\n'
          '• 🚶 Take short walking breaks if sitting long\n'
          '• 🧦 Compression stockings (doctor-recommended)\n'
          '• 💧 Stay hydrated — reduces fluid retention\n'
          '• 🔄 Gentle ankle circles & calf stretches\n\n'
          '🚨 **See doctor urgently for:**\n'
          '• 🦵 Sudden swelling in ONE leg (DVT — painful, warm, red calf)\n'
          '• 😮‍💨 Swelling + shortness of breath (heart/lung problem)\n'
          '• 🤰 Swelling + severe headache in pregnancy (pre-eclampsia)\n'
          '• 👆 Pitting oedema (pressing leaves lasting indentation)\n\n'
          '_One-sided leg swelling is more concerning — DVT risk. 🚨_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 49 💧 URINARY TRACT INFECTION (UTI)
    // EN: UTI, urinary tract infection, burning urination, frequent urination
    // HI: peshab mein jalan, UTI, baar baar peshab, mutra nali sankraman
    // NE: पिसाब मा जलन, UTI, baar baar peshab, mutra sankraman
    // BHO: peshab mein jalan, UTI, baar baar peshab aawata
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('uti') || q.contains('urinary tract') || q.contains('bladder infection') ||
        q.contains('peshab mein jalan') || q.contains('पिसाब मा जलन') ||
        q.contains('burning urination') || q.contains('frequent urination') ||
        q.contains('mutra sankraman') || q.contains('baar baar peshab') ||
        (q.contains('urine') && (q.contains('burn') || q.contains('pain') || q.contains('smell')))) {
      return '💧 **Urinary Tract Infection (UTI) / पेशाब में जलन / मूत्र संक्रमण**\n\n'
          '😣 **Symptoms / लक्षण:**\n'
          '• 🔥 Burning or pain when urinating\n'
          '• 🔄 Frequent urge to urinate (even when nearly empty)\n'
          '• 🌑 Cloudy, dark, or strong-smelling urine\n'
          '• 💢 Pelvic pain (women) or rectal pressure (men)\n'
          '• 🌡️ Low-grade fever | Back pain = kidney infection\n\n'
          '🏠 **Home care / घरेलू देखभाल:**\n'
          '• 💧 Drink 2.5–3 litres water daily — flush bacteria out\n'
          '• 🫐 Unsweetened cranberry juice — helps prevent recurrence\n'
          '• 🚫 Avoid holding urine — go when you feel the urge\n'
          '• ❌ Avoid caffeine, alcohol, spicy food (irritate bladder)\n\n'
          '💊 **Treatment — antibiotics required (doctor prescribed):**\n'
          'Nitrofurantoin or Trimethoprim-Sulfamethoxazole (culture guides choice)\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 🚿 Wipe front to back after toilet (women)\n'
          '• 🚽 Urinate after sexual intercourse\n'
          '• 👙 Wear cotton underwear\n\n'
          '🚨 **See doctor immediately for:**\n'
          '• 🌡️ High fever + chills + severe back pain (kidney infection)\n'
          '• 🩸 Blood in urine | UTI in child, pregnant woman, or man\n\n'
          '_Complete the antibiotic course — untreated UTI can spread to kidneys. ⚠️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 50 🤖 GREETING / GENERAL HELP
    // EN: hello, hi, help, what can you do, topics, namaste
    // HI: namaste, namaskar, madad, kya kar sakte ho, topics
    // NE: namaste, namaskar, madad, ke garna saknu, topics
    // BHO: namaste, namaskar, madad karo, kya kar sakela
    // ─────────────────────────────────────────────────────────────────────────
    if (q == 'hi' || q == 'hello' || q.startsWith('hi ') || q.startsWith('hello ') ||
        q.contains('नमस्ते') || q.contains('namaste') || q.contains('namaskar') ||
        q.contains('help') || q.contains('madad') || q.contains('topics') ||
        q.contains('what can you') || q.contains('ke garna') || q.contains('kya kar') ||
        q.startsWith('hey') || q.contains('what do you know')) {
      return '🤖 **Namaste! / नमस्ते! / नमस्कार!**\n\n'
          '🩺 **I am your AI Medical Assistant**\n'
          '💬 Ask me in any language:\n'
          '🇬🇧 English | 🇮🇳 हिंदी | 🇳🇵 नेपाली | 🗣️ भोजपुरी\n\n'
          '📵 _Offline mode — limited responses available_\n\n'
          '📋 **I can help with 100 topics / मैं 100 विषयों में मदद कर सकता हूँ:**\n\n'
          '🚨 Emergency • 🌡️ Fever • 🤕 Headache • 😷 Cough/Cold\n'
          '🩺 Diabetes • 💊 Medicines • 💙 Mental Health • 🤰 Pregnancy\n'
          '🩺 BP • 💨 Asthma • 🦋 Thyroid • 🤢 Stomach • 🧴 Skin\n'
          '👁️ Eyes • 🥗 Nutrition • 👶 Child/Vaccine • 🦴 Joints\n'
          '🩸 Anaemia • 🦷 Dental • 🏃 Exercise • 🧬 Cancer\n'
          '🫀 Cholesterol • 🤧 Flu • 🧪 Typhoid • 🦟 Malaria/Dengue\n'
          '💉 HIV • 🫁 TB • 🧠 Epilepsy • 🫘 Kidney • 🫀 Liver\n'
          '🤱 Breastfeeding • 🧒 Puberty • 👴 Elderly • 💊 Vitamins\n'
          '🌞 Dehydration • 🔥 Burns • 🐍 Snakebite • 🦴 Fracture\n'
          '😴 Fatigue • 🤧 Sinusitis • 💧 ORS • 🏥 First Aid • 🦠 COVID\n'
          '🦠 Wound • 🩹 Dressing • 🩸 Menstrual • 🫀 Palpitations\n'
          '🦶 Swollen Feet • 💧 UTI • 🐔 Chickenpox • 🔴 Measles\n'
          '🧴 Scabies • 😫 Back Pain • 🌀 Vertigo • 👂 Ear Infection\n'
          '💩 Constipation • 🩹 Piles • 🐝 Bee Sting • 🥵 Heat Stroke\n'
          '🤢 Food Poisoning • 🚬 Smoking • 🍺 Alcohol • ⚖️ Obesity\n'
          '🧘 Meditation • 🌿 Yoga • 🩺 Prostate • 🩸 PCOS/Menopause\n'
          '🦴 Osteoporosis • 👶 Newborn Jaundice • 😭 Colic • 😬 Teething\n'
          '🧩 Autism • 🌟 Down Syndrome • 🩸 Thalassemia • +more!\n\n'
          '_Just type your symptom or health question. 📝_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 51 🐔 CHICKENPOX
    // EN: chickenpox, varicella, pox, blisters, itchy spots
    // HI: chechak, chickenpox, varicella, khujli wale daane, chhoti mata
    // NE: चिकनपक्स, chhoti mata, varicella, khujali ko daane
    // BHO: chechak, chhoti mata, chickenpox, khujli wala daane
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('chickenpox') || q.contains('chechak') || q.contains('varicella') ||
        q.contains('chhoti mata') || q.contains('pox') || q.contains('itchy spots') ||
        q.contains('khujli wale daane') || q.contains('chhoti mata')) {
      return '🐔 **Chickenpox / चेचक / छोटी माता**\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          '• 🌡️ Mild fever, headache, fatigue 1–2 days before rash\n'
          '• 🧴 Itchy rash → red spots → fluid-filled blisters → scabs\n'
          '• Rash appears first on chest/back/face, then spreads\n'
          '• Highly contagious until all blisters crust over (~7 days)\n\n'
          '🏠 **Home care / घरेलू उपचार:**\n'
          '• 💊 Paracetamol for fever (🚫 NO Aspirin — Reye\'s syndrome risk)\n'
          '• 💊 Cetrizine for itch | Calamine lotion on blisters\n'
          '• 🛁 Cool oatmeal bath reduces itch\n'
          '• ✂️ Keep nails short to prevent scratching → scarring\n'
          '• 👕 Loose, light cotton clothing\n'
          '• 🏠 Isolate until all blisters are fully crusted\n\n'
          '💉 **Prevention / बचाव:**\n'
          '• Varicella vaccine — 2 doses (12–15 months and 4–6 years)\n'
          '• Protects against both chickenpox and shingles later in life\n\n'
          '🚨 **See doctor if:**\n'
          '• 😮‍💨 Breathing difficulty | 😵 Confusion | 🌡️ High fever > 39°C\n'
          '• Blisters becoming very red, warm, with pus (bacterial infection)\n'
          '• Chickenpox in pregnant women, newborns, or immunocompromised\n\n'
          '_Avoid contact with pregnant women and newborns during infection. ⚠️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 52 🔴 MEASLES
    // EN: measles, rubeola, khasra, koplik spots, measles rash
    // HI: khasra, measles, rubeola, khasra ke daane
    // NE: कहरे, khasra, measles, rubeola
    // BHO: khasra, measles, khasra ke daane, rubeola
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('measles') || q.contains('khasra') || q.contains('rubeola') ||
        q.contains('कहरे') || q.contains('koplik') || q.contains('measles rash')) {
      return '🔴 **Measles / खसरा / कहरे**\n\n'
          '😓 **Symptoms / लक्षण (appear in stages):**\n'
          '• Stage 1 (days 1–3): High fever 🌡️, cough 😷, runny nose 🤧, red eyes 👁️\n'
          '• Stage 2 (day 2–3): Koplik spots — tiny white spots inside mouth\n'
          '• Stage 3 (day 3–5): Red blotchy rash — starts on face, spreads downward\n\n'
          '💊 **Treatment / उपचार:**\n'
          '• 🛌 Rest | 💧 Plenty of fluids\n'
          '• 💊 Paracetamol for fever\n'
          '• 💊 Vitamin A supplements (prescribed) — reduces severity\n'
          '• 😷 Isolate for 4 days after rash appears\n\n'
          '💉 **Prevention / बचाव:**\n'
          '• MMR vaccine (Measles-Mumps-Rubella): 9 months + 15–18 months\n'
          '• 2 doses provide > 97% protection\n\n'
          '🚨 **Serious complications / गंभीर जटिलताएं:**\n'
          '• 🫁 Pneumonia (most common cause of measles death)\n'
          '• 🧠 Encephalitis (brain inflammation)\n'
          '• 👂 Hearing loss\n'
          '• See doctor immediately for: breathing difficulty, neck stiffness, confusion\n\n'
          '_Measles is highly preventable — get your child vaccinated. 💉_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 53 🧴 SCABIES / LICE
    // EN: scabies, lice, mites, khaaj, joon, head lice, itchy scalp
    // HI: khaaj, khujli ki bimari, joon, sir ki joon, khaaj ki bimari
    // NE: खाज, khaaj, lice, joon, टाउको को जुँगा
    // BHO: khaaj, joon, sir mein joon, khujli bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('scabies') || q.contains('khaaj') || q.contains('mites') ||
        q.contains('lice') || q.contains('joon') || q.contains('खाज') ||
        q.contains('head lice') || q.contains('itchy scalp') || q.contains('sir ki joon') ||
        q.contains('टाउको को जुँगा') || q.contains('nits')) {
      return '🧴 **Scabies & Lice / खाज-खुजली / जूँ**\n\n'
          '🔬 **Scabies (mites) / खाज:**\n'
          '• Intense itching (worse at night) 🌙, small red bumps or burrow lines\n'
          '• Common in: hands, wrists, elbows, waist, genitals\n'
          '• Treatment: Permethrin 5% cream — apply all over body from neck down\n'
          '  Leave 8–14 hours, then wash off | Repeat after 1 week\n'
          '• All family members + close contacts should be treated simultaneously\n'
          '• Wash all bedding, clothing in hot water on same day\n\n'
          '🪲 **Head Lice / सिर की जूँ:**\n'
          '• Intense scalp itching, visible nits (eggs) on hair shafts\n'
          '• Treatment: Permethrin 1% lotion or Malathion 0.5% — apply, leave, rinse\n'
          '• Fine-tooth nit comb to remove eggs\n'
          '• Repeat treatment after 7–10 days\n'
          '• Wash pillowcases, hats, hair accessories in hot water\n'
          '• ❌ Do NOT share combs, hats, or pillows\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• Avoid direct skin-to-skin contact with infected person\n'
          '• Maintain personal hygiene and clean living conditions\n\n'
          '_Scabies and lice are not signs of poor hygiene — anyone can get them. ✅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 54 😫 BACK PAIN / NECK PAIN
    // EN: back pain, neck pain, spine, lumbar, cervical, slip disc
    // HI: kamar dard, peeth dard, gardan dard, slip disc, pith dard
    // NE: ढाड दुख्छ, kamar dukha, gardan dukha, slip disc
    // BHO: kamar mein dard, gardan mein dard, pith dard, slip disc
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('back pain') || q.contains('kamar dard') || q.contains('peeth dard') ||
        q.contains('ढाड दुख्छ') || q.contains('kamar dukha') || q.contains('neck pain') ||
        q.contains('gardan dard') || q.contains('gardan dukha') || q.contains('slip disc') ||
        q.contains('lumbar') || q.contains('cervical') || q.contains('pith dard') ||
        q.contains('spine') || q.contains('sciatica')) {
      return '😫 **Back & Neck Pain / कमर-गर्दन दर्द / ढाड दुख्छ**\n\n'
          '🔍 **Common causes / सामान्य कारण:**\n'
          '• 🪑 Poor posture while sitting/standing\n'
          '• 🛏️ Wrong sleeping position or mattress\n'
          '• 💪 Muscle strain from lifting heavy objects\n'
          '• 💻 Prolonged screen use (neck pain)\n'
          '• 🦴 Slip disc, osteoarthritis, osteoporosis\n\n'
          '🌿 **Immediate relief / तुरंत राहत:**\n'
          '• 🌡️ Warm compress for chronic stiffness | 🧊 Ice for acute injury (first 48 hrs)\n'
          '• 💊 Ibuprofen 400 mg with food for pain and inflammation\n'
          '• 🧘 Gentle stretches — avoid complete bed rest\n'
          '• 🛌 Sleep on firm mattress; side-sleeping with pillow between knees\n\n'
          '✅ **Self-care / स्वयं देखभाल:**\n'
          '• 🪑 Ergonomic seating — screen at eye level\n'
          '• 🏋️ Core-strengthening exercises (cat-cow, bird-dog, bridges)\n'
          '• ⚖️ Maintain healthy weight\n'
          '• 🚶 Walk regularly — the best medicine for back pain\n\n'
          '🚨 **Emergency — Call 108 / see doctor for:**\n'
          '• 😶 Numbness or tingling in arms/legs\n'
          '• 🚽 Loss of bladder/bowel control\n'
          '• ⚡ Pain after trauma or fall\n'
          '• 🌡️ Back pain with fever (spinal infection)\n\n'
          '_Most back pain resolves in 4–6 weeks with exercise and posture correction. ✅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 55 💪 SHOULDER PAIN
    // EN: shoulder pain, rotator cuff, frozen shoulder, kandha dard
    // HI: kandha dard, kandhe ki takleef, frozen shoulder, rotator cuff
    // NE: काँध दुख्छ, kandha dukha, frozen shoulder
    // BHO: kandha mein dard, kandhe ki takleef, frozen shoulder
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('shoulder pain') || q.contains('kandha dard') || q.contains('kandha dukha') ||
        q.contains('काँध दुख्छ') || q.contains('frozen shoulder') || q.contains('rotator cuff') ||
        q.contains('kandhe ki') || q.contains('shoulder stiff')) {
      return '💪 **Shoulder Pain / कंधे का दर्द / काँध दुख्छ**\n\n'
          '🔍 **Common causes / सामान्य कारण:**\n'
          '• 🏋️ Rotator cuff injury — overuse or strain\n'
          '• 🥶 Frozen shoulder (adhesive capsulitis) — stiffness + pain, worse at night\n'
          '• 🦴 Arthritis | 💼 Poor posture (rounded shoulders)\n'
          '• ⚡ Referred pain from neck (cervical radiculopathy)\n\n'
          '🌿 **Relief / राहत:**\n'
          '• 🧊 Ice 15–20 min for acute pain (first 48 hrs)\n'
          '• 🌡️ Warm compress for stiffness\n'
          '• 💊 Ibuprofen 400 mg for pain and inflammation\n'
          '• 🧘 Pendulum exercises, wall crawls, cross-body stretch\n'
          '• ❌ Avoid overhead activities during acute pain\n\n'
          '🏥 **Physiotherapy helps most shoulder conditions**\n'
          '• Ultrasound therapy, TENS, targeted exercises\n\n'
          '🚨 **See doctor if:**\n'
          '• Pain not improving after 2 weeks\n'
          '• 😶 Numbness or weakness in arm/hand\n'
          '• 🫀 Severe chest pain + left shoulder pain (may be heart attack)\n\n'
          '_Frozen shoulder can take 1–3 years — physiotherapy is essential. 🏥_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 56 🫀 CHEST TIGHTNESS
    // EN: chest tightness, chest pressure, tight chest, chest discomfort
    // HI: seene mein khinchav, chhati mein dabaav, seene mein takleef
    // NE: छाती अँठ्याउनु, seene mein khinchav, chhaati mein dabab
    // BHO: seene mein khinchav, chhati mein bhaari lagata, seene ki takleef
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('chest tightness') || q.contains('seene mein khinchav') ||
        q.contains('छाती अँठ्याउनु') || q.contains('chest pressure') ||
        q.contains('tight chest') || q.contains('seene mein dabaav') ||
        q.contains('chhati mein dabaav') || q.contains('chest discomfort')) {
      return '🫀 **Chest Tightness / सीने में खिंचाव**\n\n'
          '⚠️ **Important: Chest tightness can have many causes — some life-threatening.**\n\n'
          '🚨 **Call 108 immediately if chest tightness is:**\n'
          '• 💢 Severe, crushing, or squeezing\n'
          '• 🫀 Radiating to left arm, jaw, neck, or back\n'
          '• 😰 With sweating, nausea, shortness of breath\n'
          '• ⏱️ Lasting more than a few minutes\n'
          '• 😵 With dizziness or fainting\n\n'
          '🔍 **Non-emergency causes / सामान्य कारण:**\n'
          '• 😰 Anxiety / panic attack\n'
          '• 🔥 Acid reflux / GERD (burning sensation)\n'
          '• 💨 Asthma (wheezing + tightness)\n'
          '• 💪 Muscle strain (after exercise, coughing)\n'
          '• 🦠 Respiratory infection\n\n'
          '🌿 **For anxiety-related tightness / चिंता से:**\n'
          '• 🌬️ Slow deep breathing (4 sec in, hold 4, out 6)\n'
          '• 🧘 Sit upright; loosen tight clothing\n\n'
          '🔥 **For acid reflux tightness:**\n'
          '• 💊 Antacid (Gelusil / Ranitidine)\n'
          '• 🛏️ Don\'t lie down for 2 hrs after eating\n\n'
          '_When in doubt — treat as cardiac emergency and call 108. 🚨_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 57 🌀 VERTIGO / DIZZINESS
    // EN: vertigo, dizziness, spinning, lightheaded, chakkar
    // HI: chakkar, sarchakkar, sar ghoomna, vertigo, halkaapan
    // NE: चक्कर लाग्नु, vertigo, sar ghumnu, chakkar
    // BHO: chakkar aawata, sar ghumaata, vertigo, halka laagata
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('vertigo') || q.contains('dizziness') || q.contains('dizzy') ||
        q.contains('chakkar') || q.contains('sar ghoomna') || q.contains('सarchakkar') ||
        q.contains('चक्कर लाग्नु') || q.contains('spinning') || q.contains('lightheaded') ||
        q.contains('sar ghumnu') || q.contains('chakkar aawata')) {
      return '🌀 **Vertigo & Dizziness / चक्कर आना / सरचक्कर**\n\n'
          '🔍 **Types / प्रकार:**\n'
          '• 🌀 True vertigo: Room spins even when still — inner ear problem\n'
          '• 😵 Lightheadedness: Feeling faint — low BP, dehydration, anaemia\n\n'
          '🔬 **Common causes / सामान्य कारण:**\n'
          '• 👂 BPPV (Benign Paroxysmal Positional Vertigo) — most common inner ear cause\n'
          '• 🦠 Labyrinthitis (inner ear infection) — sudden onset vertigo + hearing loss\n'
          '• 🩺 Low BP, anaemia, dehydration\n'
          '• 🧠 Migraine-associated vertigo\n'
          '• 💊 Certain medicines (sedatives, diuretics)\n\n'
          '🌿 **Immediate relief / तुरंत राहत:**\n'
          '• 🛌 Sit or lie down immediately; avoid sudden movements\n'
          '• 🎯 Focus eyes on a fixed point\n'
          '• 🐢 Rise slowly from lying/sitting position\n'
          '• 💧 Drink water (if due to dehydration)\n\n'
          '🔄 **Epley manoeuvre for BPPV** — ask doctor to demonstrate; highly effective\n\n'
          '🚨 **Call 108 for dizziness WITH:**\n'
          '• 🗣️ Sudden slurred speech or confusion\n'
          '• 👁️ Double vision or sudden vision loss\n'
          '• 🦾 Weakness or numbness on one side\n'
          '• 🤕 Severe headache (possible stroke)\n\n'
          '_Most vertigo resolves with rest and manoeuvres. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 58 👂 EAR INFECTION / TINNITUS
    // EN: ear infection, ear pain, tinnitus, ringing in ears, kaan dard
    // HI: kaan dard, kaan mein dard, kaan pakna, seeti aawaz, kaan mein awaz
    // NE: कान दुख्छ, kaan dard, kaan mein seeti, tinnitus
    // BHO: kaan mein dard, kaan pakta, kaan mein seeti aawaz, tinnitus
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('ear') || q.contains('kaan') || q.contains('कान दुख्छ') ||
        q.contains('tinnitus') || q.contains('ringing in ear') || q.contains('kaan dard') ||
        q.contains('ear pain') || q.contains('ear infection') || q.contains('kaan pakna') ||
        q.contains('seeti aawaz') || q.contains('kaan mein awaz')) {
      return '👂 **Ear Infection & Tinnitus / कान दर्द / टिनिटस**\n\n'
          '😣 **Ear infection (Otitis Media) / कान पकना:**\n'
          '• Symptoms: 💢 Ear pain, 🌡️ fever, 😔 irritability in children,\n'
          '  discharge from ear 💧, muffled hearing\n'
          '• Treatment: Paracetamol for pain | Warm compress over ear\n'
          '• Antibiotic ear drops or oral antibiotic — doctor prescribed\n'
          '• 🚫 Do NOT insert cotton buds — pushes wax deeper\n\n'
          '🔔 **Tinnitus / कान में आवाज़:**\n'
          '• Ringing, buzzing, or hissing in ears without external source\n'
          '• Common causes: Loud noise exposure 🔊, ear wax, hearing loss, medicines\n'
          '• Management: Avoid loud noises; use earplugs 🎧; manage stress\n'
          '• White noise machines help mask tinnitus at night\n\n'
          '👃 **Earwax blockage / कान में मैल:**\n'
          '• Symptoms: Muffled hearing, fullness, earache\n'
          '• Use ear drops (Waxsol / olive oil) for 3–5 days to soften\n'
          '• Irrigation by a doctor or nurse to remove\n'
          '• 🚫 Never use cotton buds inside ear canal\n\n'
          '🚨 **See doctor urgently for:**\n'
          '• 🩸 Blood or pus discharge from ear\n'
          '• Sudden hearing loss | Severe ear pain + fever\n'
          '• Ear pain after head injury\n\n'
          '_Hearing loss caught early is often treatable. Get regular ear checks. 👂_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 59 💩 CONSTIPATION
    // EN: constipation, hard stool, kabz, not passing stool, straining
    // HI: kabz, mal baddhakata, kaadhi, pekhana na aana, pet saaf nahi
    // NE: कब्जियत, kaadhi, pekhana naaunu, pet saaf nahunu
    // BHO: kabz, kaadhi, pekhana nahi aawata, pet saaf nahi hota
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('constipation') || q.contains('kabz') || q.contains('kaadhi') ||
        q.contains('कब्जियत') || q.contains('hard stool') || q.contains('not passing stool') ||
        q.contains('pekhana nahi') || q.contains('pet saaf nahi') ||
        q.contains('straining to poop') || q.contains('mal baddhakata')) {
      return '💩 **Constipation / कब्ज / कब्जियत**\n\n'
          '📊 **Normal: 3 times/day to 3 times/week is normal range**\n'
          'Constipation = < 3 stools/week + straining + hard/lumpy stools\n\n'
          '🌿 **Home treatment / घरेलू उपचार:**\n'
          '• 💧 Drink 8–10 glasses of water daily — #1 remedy\n'
          '• 🌾 High-fibre foods: fruits 🍎, vegetables 🥦, whole grains, lentils\n'
          '• 🚶 Exercise 30 min/day — stimulates bowel movement\n'
          '• ☕ Warm water on empty stomach in morning\n'
          '• 🥄 1 tsp ghee in warm milk at bedtime\n'
          '• 🌱 Isabgol (Psyllium husk) — 1 tsp in water before bed\n\n'
          '💊 **Medicines / दवाइयां:**\n'
          '• Lactulose syrup — gentle, safe for all ages\n'
          '• Glycerine suppository — for immediate relief\n'
          '• ⚠️ Avoid harsh laxatives long-term — causes dependence\n\n'
          '🚨 **See doctor if:**\n'
          '• 🩸 Blood in stool | 😣 Severe abdominal pain\n'
          '• ⚖️ Unexplained weight loss with constipation\n'
          '• Constipation alternating with diarrhoea (IBS)\n'
          '• No improvement after 2 weeks\n\n'
          '_A high-fibre diet and active lifestyle prevent most constipation. 🥗_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 60 🫙 APPENDICITIS / GALLSTONE
    // EN: appendicitis, appendix pain, gallstone, gallbladder, biliary colic
    // HI: appendix dard, pittashaay ki pathri, gallstone, pittashaay
    // NE: appendix dard, pittashaya ko pathri, gallstone
    // BHO: appendix mein dard, pitte ki pathri, gallstone
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('appendicitis') || q.contains('appendix') || q.contains('gallstone') ||
        q.contains('pittashaay') || q.contains('pittashaya') || q.contains('gallbladder') ||
        q.contains('pitte ki pathri') || q.contains('biliary colic') ||
        q.contains('appendix dard') || q.contains('appendix mein dard')) {
      return '🫙 **Appendicitis & Gallstones / अपेंडिक्स और पित्ताशय**\n\n'
          '🔴 **Appendicitis / अपेंडिक्स:**\n'
          '• Symptoms: Pain starting around navel → moves to lower right abdomen\n'
          '  Nausea, vomiting, low-grade fever, loss of appetite\n'
          '• ⚠️ Pain worsens with movement, coughing, or pressing\n'
          '• 🚨 SURGICAL EMERGENCY — do not delay\n'
          '• 🚫 Do NOT eat or drink | 🚫 No painkillers (masks symptoms)\n'
          '• 📞 Call 108 or go to emergency immediately\n\n'
          '🟡 **Gallstones / पित्त पथरी:**\n'
          '• Symptoms: Severe right upper abdomen pain (after fatty meals 🍖)\n'
          '  Pain radiating to right shoulder, nausea, vomiting\n'
          '• Biliary colic: episodes lasting 1–5 hours, then resolving\n\n'
          '🏠 **Gallstone attack relief:**\n'
          '• Pain can be severe — seek medical care\n'
          '• 💊 Diclofenac / Buscopan for pain (doctor-prescribed)\n'
          '• ❌ Avoid fatty, fried, spicy foods during episodes\n\n'
          '🏥 **Treatment:** Surgery (laparoscopic cholecystectomy) for recurrent attacks\n\n'
          '🚨 **Emergency for both if:** Fever + jaundice + severe pain (cholangitis)\n\n'
          '_Never ignore persistent right-sided abdominal pain. ⚠️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 61 🩺 HERNIA / PANCREATITIS
    // EN: hernia, hernia pain, pancreatitis, pancreas pain
    // HI: hernia, antra utthan, pancreas dard, pancreatitis
    // NE: hernia, antra utthan, pancreas ko dard
    // BHO: hernia, antra mein dard, pancreas ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('hernia') || q.contains('antra utthan') || q.contains('pancreatitis') ||
        q.contains('pancreas') || q.contains('antra mein dard') || q.contains('pancreas dard')) {
      return '🩺 **Hernia & Pancreatitis / हर्निया और अग्न्याशय**\n\n'
          '🔵 **Hernia / हर्निया:**\n'
          '• What is it: Organ/tissue pushes through weak spot in muscle wall\n'
          '• Types: Inguinal (groin) — most common | Umbilical | Hiatal (stomach)\n'
          '• Symptoms: 🫁 Bulge in abdomen/groin, aching pain, pain on lifting/bending\n'
          '• 🚨 Strangulated hernia (no blood supply): EMERGENCY\n'
          '  Signs: Severe pain 💢, bulge becomes hard/red/dark, vomiting, fever\n'
          '  → Call 108 immediately\n'
          '• Treatment: Surgical repair (laparoscopic or open)\n\n'
          '🔴 **Pancreatitis / अग्न्याशय की सूजन:**\n'
          '• Symptoms: Severe upper abdominal pain radiating to back 😣,\n'
          '  worse after eating, nausea, vomiting, fever\n'
          '• Causes: 🍺 Alcohol, gallstones 🟡, certain medicines\n'
          '• Treatment: Hospital admission — IV fluids, fasting, pain management\n'
          '• 🚫 Avoid alcohol completely | Low-fat diet during recovery\n\n'
          '🚨 **Both conditions need medical evaluation. Do not self-treat. 🏥_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 62 🩹 PILES / HAEMORRHOIDS
    // EN: piles, haemorrhoids, hemorrhoids, rectal bleeding, bawaseer
    // HI: bawaseer, arsha, piles, malotsarg mein khoon, gudad mein dard
    // NE: अर्श, bawaseer, piles, gudad mein dard, rectal bleeding
    // BHO: bawaseer, arsha, piles, malotsarg mein khoon, gudad mein dard
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('piles') || q.contains('haemorrhoid') || q.contains('hemorrhoid') ||
        q.contains('bawaseer') || q.contains('arsha') || q.contains('अर्श') ||
        q.contains('rectal bleeding') || q.contains('gudad mein dard') ||
        q.contains('malotsarg mein khoon') || q.contains('anal pain')) {
      return '🩹 **Piles / Haemorrhoids / बवासीर / अर्श**\n\n'
          '🔍 **What are piles? / बवासीर क्या है?**\n'
          'Swollen veins in the rectum or anus — caused by straining during bowel movements,\n'
          'chronic constipation, pregnancy, or sitting long hours.\n\n'
          '😣 **Symptoms / लक्षण:**\n'
          '• 🩸 Bright red blood during/after passing stool (on paper or bowl)\n'
          '• 😣 Pain and discomfort during bowel movements\n'
          '• 😖 Itching or irritation around anus\n'
          '• 🔵 Lump near anus (external haemorrhoid)\n\n'
          '🌿 **Home treatment / घरेलू उपचार:**\n'
          '• 💧 Drink 8–10 glasses water | 🌾 High-fibre diet\n'
          '• 🛁 Sitz bath: sit in warm water 15 min, 2–3 times daily\n'
          '• 🧴 Witch hazel or over-the-counter haemorrhoid cream\n'
          '• 💊 Stool softener (Lactulose) — avoid straining\n'
          '• 🚶 Exercise regularly; avoid prolonged sitting\n\n'
          '🏥 **Medical treatment:** Rubber band ligation, sclerotherapy, or surgery for severe cases\n\n'
          '🚨 **See doctor if:**\n'
          '• 🩸 Large amounts of rectal bleeding\n'
          '• 🌡️ Fever + rectal pain (abscess)\n'
          '• No improvement with home treatment after 2 weeks\n\n'
          '_Rectal bleeding should always be evaluated by a doctor. 🔴_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 63 👨 PROSTATE / MALE HEALTH
    // EN: prostate, urinary difficulty, prostate enlargement, male health, BPH
    // HI: purush swasthya, prostate, peshab mein takleef, BPH, prostate badna
    // NE: purush swasthya, prostate, BPH, peshab mein takleef
    // BHO: purush ke sehat, prostate, peshab ke takleef, BPH
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('prostate') || q.contains('purush swasthya') || q.contains('male health') ||
        q.contains('bph') || q.contains('purush ke sehat') || q.contains('prostate badna') ||
        q.contains('urinary difficulty') || q.contains('weak urine stream')) {
      return '👨 **Prostate & Male Health / पुरुष स्वास्थ्य / प्रोस्टेट**\n\n'
          '🔵 **BPH (Benign Prostatic Hyperplasia) / प्रोस्टेट बढ़ना:**\n'
          '• Very common in men > 50 years\n'
          '• Symptoms: Weak urine stream, frequent urination (night), incomplete emptying,\n'
          '  difficulty starting urination, dribbling\n'
          '• Treatment: Alpha-blockers (Tamsulosin) — doctor prescribed\n'
          '• Surgery if medicines don\'t help (TURP)\n\n'
          '🔴 **Prostate Cancer / प्रोस्टेट कैंसर:**\n'
          '• Symptoms: Similar to BPH + blood in urine/semen, bone pain\n'
          '• PSA blood test screens for prostate cancer — men > 50 should discuss with doctor\n'
          '• Early detection dramatically improves outcomes\n\n'
          '✅ **Male health tips / पुरुष स्वास्थ्य सुझाव:**\n'
          '• 🥗 Eat tomatoes 🍅 (lycopene), pumpkin seeds 🌰 (zinc)\n'
          '• 🏃 Exercise regularly | ⚖️ Maintain healthy weight\n'
          '• 🍺 Limit alcohol | 🚭 Don\'t smoke\n'
          '• 💧 Limit caffeine and fluids before bed (reduces night urination)\n\n'
          '🚨 **See doctor for:**\n'
          '• 🩸 Blood in urine or semen\n'
          '• Complete inability to urinate (urinary retention) → emergency\n'
          '• Any change in urinary pattern persisting > 2 weeks\n\n'
          '_Annual health checks for men over 40 are important. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 64 😔 ERECTILE DYSFUNCTION / IMPOTENCE
    // EN: erectile dysfunction, impotence, ED, sexual health
    // HI: napunsakta, stambhan dosh, ED, youn asakshamta, purush ki kamzori
    // NE: napunsaktā, stambhan dosh, ED, purush ko kamjori
    // BHO: napunsakta, stambhan dosh, ED, youn kamzori
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('erectile') || q.contains('impotence') || q.contains('napunsakta') ||
        q.contains('stambhan dosh') || q.contains('napunsaktā') || q.contains(' ed ') ||
        q.contains('sexual health') || q.contains('youn kamzori') || q.contains('purush ki kamzori')) {
      return '😔 **Erectile Dysfunction / नपुंसकता / स्तंभन दोष**\n\n'
          '❓ **What is ED?** Difficulty getting or maintaining an erection sufficient for sex.\n'
          'Very common — affects up to 50% of men over 40 at some point.\n\n'
          '🔍 **Common causes / सामान्य कारण:**\n'
          '• 🩺 Diabetes, high BP, heart disease (most common physical causes)\n'
          '• 🧠 Stress, anxiety, depression (psychological causes — very common)\n'
          '• 🍺 Alcohol, smoking, obesity\n'
          '• 💊 Certain medicines (antidepressants, BP medications)\n'
          '• 🔵 Low testosterone\n\n'
          '🌿 **Lifestyle improvements / जीवनशैली सुधार:**\n'
          '• 🏃 Exercise regularly — improves blood flow\n'
          '• ⚖️ Lose excess weight | 🚭 Quit smoking\n'
          '• 🍺 Reduce alcohol | 😌 Manage stress and anxiety\n'
          '• 😴 Improve sleep quality\n\n'
          '💊 **Medical treatment:**\n'
          '• PDE-5 inhibitors (Sildenafil/Tadalafil) — doctor prescribed only\n'
          '• Psychological counselling for anxiety-related ED\n\n'
          '🚨 **See doctor — ED can be an early warning sign of heart disease. 🫀**\n\n'
          '_ED is treatable. There is no shame in seeking help. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 65 🌸 MENOPAUSE
    // EN: menopause, hot flashes, periods stopped, ratjog, postmenopause
    // HI: ritu nivrutti, menopause, hot flash, period band ho gaya
    // NE: रजोनिवृत्ति, menopause, hot flash, mahina band bhayo
    // BHO: menopause, hot flash, mahina band ho gail, ritu nivritti
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('menopause') || q.contains('ritu nivrutti') || q.contains('रजोनिवृत्ति') ||
        q.contains('hot flash') || q.contains('period band') || q.contains('mahina band') ||
        q.contains('postmenopause') || q.contains('ratjog') || q.contains('ritu nivritti')) {
      return '🌸 **Menopause / रजोनिवृत्ति / मेनोपॉज़**\n\n'
          '❓ **What is menopause?** Natural end of menstrual periods.\n'
          'Diagnosed after 12 consecutive months without a period.\n'
          'Average age: 45–55 years\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          '• 🔥 Hot flashes (sudden warmth, sweating, flushing)\n'
          '• 😴 Sleep disturbances and night sweats\n'
          '• 😢 Mood changes, irritability, depression\n'
          '• 💧 Vaginal dryness and discomfort\n'
          '• 🦴 Bone loss (osteoporosis risk increases)\n'
          '• 💓 Palpitations | 😴 Fatigue | 🧠 Memory changes\n\n'
          '🌿 **Management / प्रबंधन:**\n'
          '• 🏃 Regular exercise — reduces hot flashes and mood swings\n'
          '• 🌬️ Dress in layers; keep room cool\n'
          '• 😌 Relaxation techniques for mood and sleep\n'
          '• 🦴 Calcium + Vitamin D to protect bones\n'
          '• ❌ Avoid caffeine, alcohol, spicy food (trigger hot flashes)\n\n'
          '💊 **Medical options / चिकित्सा:**\n'
          '• HRT (Hormone Replacement Therapy) — discuss benefits/risks with doctor\n'
          '• Local vaginal oestrogen for vaginal dryness\n\n'
          '🚨 **See doctor for:**\n'
          '• Heavy/irregular bleeding in perimenopause\n'
          '• Severe symptoms affecting daily life\n\n'
          '_Menopause is a natural transition — not an illness. Support is available. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 66 🦴 OSTEOPOROSIS
    // EN: osteoporosis, weak bones, bone density, fracture risk, calcium deficiency
    // HI: haddi kamzori, osteoporosis, haddi ghisaav, calcium ki kami
    // NE: हड्डी कमजोरी, osteoporosis, haddi kamjori, calcium ko kami
    // BHO: haddi kamzori, osteoporosis, haddi ki kamzori, calcium kami
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('osteoporosis') || q.contains('haddi kamzori') || q.contains('हड्डी कमजोरी') ||
        q.contains('bone density') || q.contains('weak bones') || q.contains('fracture risk') ||
        q.contains('haddi kamjori') || q.contains('haddi ki kamzori') || q.contains('calcium kami')) {
      return '🦴 **Osteoporosis / हड्डी कमज़ोरी / ऑस्टियोपोरोसिस**\n\n'
          '❓ **What is it?** Bones become less dense and brittle — fracture easily.\n'
          'Silent disease — often discovered only after a fracture.\n\n'
          '⚠️ **Risk factors / जोखिम कारक:**\n'
          '• 👩 Women > 50, especially post-menopause\n'
          '• ☀️ Vitamin D deficiency | 🦴 Low calcium intake\n'
          '• 🚭 Smoking | 🍺 Alcohol | 🛋️ Sedentary lifestyle\n'
          '• 🦋 Thyroid disease | 💊 Long-term steroids | 🩺 Diabetes\n\n'
          '🛡️ **Prevention & Treatment / बचाव:**\n'
          '• 🦴 Calcium: 1000–1200 mg/day (dairy, ragi, sesame, greens)\n'
          '• ☀️ Vitamin D3: 1000–2000 IU/day + 15 min sunlight daily\n'
          '• 🏋️ Weight-bearing exercise: walking, jogging, dancing, resistance training\n'
          '• 🚭 Quit smoking | 🍺 Limit alcohol\n'
          '• 💊 Bisphosphonates (Alendronate, Risedronate) — doctor prescribed\n\n'
          '🔬 **DEXA Scan** — measures bone density; recommended for women > 65, men > 70\n\n'
          '🚨 **Fracture prevention / गिरने से बचाव:**\n'
          '• Remove home hazards, install grab bars, ensure good lighting\n'
          '• Regular vision checks\n\n'
          '_Osteoporosis is preventable and treatable — start calcium and exercise early. 💪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 67 🔴 MUMPS
    // EN: mumps, parotitis, swollen jaw, ear swelling, gal phoolna
    // HI: mumps, parotitis, gal phoolna, kaanphoolni
    // NE: कण्ठमाला, mumps, gal phulnu, kaanphoolni
    // BHO: mumps, gal phool gail, kaanphoolni, parotitis
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('mumps') || q.contains('parotitis') || q.contains('gal phoolna') ||
        q.contains('कण्ठमाला') || q.contains('gal phulnu') || q.contains('swollen jaw') ||
        q.contains('kaanphoolni') || q.contains('swollen cheek')) {
      return '🔴 **Mumps / कण्ठमाला / गाल फूलना**\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          '• 😶 Painful swelling of parotid glands (cheeks/jaw area) — one or both sides\n'
          '• 🌡️ Fever, headache, muscle aches, fatigue\n'
          '• 😣 Pain while chewing or swallowing\n'
          '• Incubation: 12–25 days after exposure\n\n'
          '🏠 **Treatment / उपचार:**\n'
          '• 🛌 Rest | 💧 Plenty of fluids\n'
          '• 💊 Paracetamol for pain and fever\n'
          '• 🌡️ Warm or cold compress on swollen area\n'
          '• 🍦 Soft foods — chewing is painful\n'
          '• 🏠 Isolate for 5 days after swelling starts\n'
          '• ❌ Avoid sour foods and drinks (stimulate saliva → pain)\n\n'
          '⚠️ **Complications / जटिलताएं:**\n'
          '• 🧠 Meningitis | 🔊 Hearing loss\n'
          '• 🍒 Orchitis in teenage/adult males (testicular swelling)\n'
          '• 🤰 Miscarriage if in first trimester\n\n'
          '💉 **Prevention:** MMR vaccine — 2 doses provides excellent protection\n\n'
          '🚨 **See doctor for:** Severe headache + stiff neck, testicular pain, confusion\n\n'
          '_Mumps is vaccine-preventable. Ensure MMR vaccination is up to date. 💉_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 68 🩹 FISTULA / ANAL ABSCESS
    // EN: fistula, anal fistula, rectal abscess, bhagandara
    // HI: bhagandara, fistula, gudad ka phoda, anal fistula
    // NE: भगंदर, bhagandara, fistula, gudad ko phoda
    // BHO: bhagandara, fistula, gudad mein phoda, anal fistula
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('fistula') || q.contains('bhagandara') || q.contains('भगंदर') ||
        q.contains('anal abscess') || q.contains('rectal abscess') || q.contains('gudad ka phoda')) {
      return '🩹 **Anal Fistula & Abscess / भगंदर / फिस्टुला**\n\n'
          '❓ **What is a fistula?** An abnormal tunnel connecting the anal canal to skin.\n'
          'Usually begins as an anal abscess (infection near anus).\n\n'
          '😣 **Symptoms / लक्षण:**\n'
          '• 💢 Throbbing pain near anus (worse when sitting)\n'
          '• 🌡️ Swelling, redness, fever\n'
          '• 💧 Discharge of pus or blood near anus\n'
          '• 😷 Persistent irritation and itching\n\n'
          '⚠️ **Anal abscess (urgent) / तुरंत देखभाल:**\n'
          '• Never ignore — abscess must be drained by a doctor\n'
          '• 💊 Antibiotics alone are NOT enough for abscess\n'
          '• 🏥 Surgical incision and drainage required\n\n'
          '🌿 **General care:**\n'
          '• 🛁 Sitz bath (warm water) 3–4 times/day for relief\n'
          '• 💧 High-fibre diet and plenty of water\n'
          '• 💊 Paracetamol for pain\n\n'
          '🏥 **Treatment:** Surgery (Fistulotomy) — the only cure for fistula\n\n'
          '🚨 **See a colorectal surgeon — do not delay.**\n\n'
          '_Fistulas rarely heal on their own. Medical evaluation is essential. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 69 🔄 PCOS (DETAILED)
    // EN: PCOS, polycystic ovary syndrome, ovarian cysts, irregular periods, hirsutism
    // HI: PCOS, andashay me gandh, irregular periods, adhik baal, ovarian cysts
    // NE: PCOS, andashaya ko gandh, irregular periods, adhik aaul
    // BHO: PCOS, andashay mein ganth, irregular period, adhik baal
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('pcos') || q.contains('polycystic') || q.contains('ovarian cyst') ||
        q.contains('andashay') || q.contains('hirsutism') || q.contains('excess hair') ||
        q.contains('ovary problem') || q.contains('irregular ovulation')) {
      return '🔄 **PCOS (Polycystic Ovary Syndrome) / पॉलीसिस्टिक ओवरी**\n\n'
          '❓ **What is PCOS?** Hormonal disorder causing irregular periods, excess androgen,\n'
          'and/or small cysts in ovaries. Affects 1 in 5 women in India.\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          '• 🔄 Irregular, absent, or heavy periods\n'
          '• 🧖 Excess facial/body hair (hirsutism)\n'
          '• 😤 Acne on face/back/chest\n'
          '• ⚖️ Weight gain, especially around abdomen\n'
          '• 🔵 Thinning scalp hair | 🖤 Darkened skin patches (acanthosis nigricans)\n'
          '• 🤰 Difficulty getting pregnant\n\n'
          '🌿 **Management / प्रबंधन:**\n'
          '• ⚖️ Weight loss of even 5–10% significantly improves symptoms\n'
          '• 🏃 Exercise 30–60 min/day — most effective single intervention\n'
          '• 🥗 Low glycaemic index diet: whole grains, vegetables, lean protein\n'
          '• ❌ Reduce sugar, refined carbs, processed food\n\n'
          '💊 **Medical treatments (doctor prescribed) / दवाइयां:**\n'
          '• Combined oral contraceptive pill — regulates periods\n'
          '• Metformin — improves insulin resistance\n'
          '• Anti-androgens (Spironolactone) — for hair/acne\n'
          '• Clomiphene/Letrozole — if trying to conceive\n\n'
          '🚨 **See gynaecologist for:**\n'
          '• Fertility concerns | Severe symptoms | Diabetes risk screening\n\n'
          '_PCOS is manageable — lifestyle changes are the cornerstone of treatment. 💪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 70 🧠 STRESS MANAGEMENT (DETAILED)
    // EN: stress management, relaxation, breathing exercises, mindfulness
    // HI: tanav prabandhan, shithilta, saans ki kasrat, mindfulness
    // NE: तनाव व्यवस्थापन, shithilta, saans ko kasrat, mindfulness
    // BHO: tanav prabandhan, shithilta, saans ki kasrat
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('stress management') || q.contains('tanav prabandhan') ||
        q.contains('relaxation') || q.contains('breathing exercise') ||
        q.contains('shithilta') || q.contains('mindfulness') ||
        q.contains('तनाव व्यवस्थापन') || q.contains('how to reduce stress')) {
      return '🧠 **Stress Management / तनाव प्रबंधन / मन की शांति**\n\n'
          '🌬️ **Breathing techniques / सांस की तकनीक:**\n'
          '• Box breathing: 4 sec in → hold 4 → out 4 → hold 4 → repeat 5x\n'
          '• 4-7-8 breathing: in 4 → hold 7 → out 8 → activates relaxation response\n'
          '• Alternate nostril breathing (Nadi Shodhana) — traditional yogic technique\n\n'
          '🧘 **Progressive muscle relaxation:**\n'
          '• Tense each muscle group for 5 sec → release → feel the difference\n'
          '• Start from feet → work up to head\n\n'
          '🌿 **Daily habits / दैनिक आदतें:**\n'
          '• 📝 Journaling — write 3 things you\'re grateful for each day\n'
          '• 📵 Digital detox — 1 hr screen-free before bed\n'
          '• 🚶 Nature walks — proven to lower cortisol levels\n'
          '• 🎵 Music therapy — listen to calming music\n'
          '• 🤝 Social connection — talk to a friend or family member\n\n'
          '⏰ **Time management / समय प्रबंधन:**\n'
          '• Break large tasks into small steps\n'
          '• Prioritise — identify what\'s urgent vs. important\n'
          '• Learn to say no to unnecessary commitments\n\n'
          '📞 **Professional help / पेशेवर मदद:**\n'
          '• Cognitive Behavioural Therapy (CBT) — highly effective\n'
          '• iCall India: 9152987821 | Vandrevala: 1860-2662-345 (24/7)\n\n'
          '_Managing stress is a skill — it improves with practice. 💪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 71 🧘 MEDITATION
    // EN: meditation, dhyan, mindfulness, guided meditation, calm mind
    // HI: dhyan, meditation, maun, maunshadhan, shant man
    // NE: ध्यान, dhyan, meditation, maun, shant man
    // BHO: dhyan, meditation, man ke shanti, maun
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('meditation') || q.contains('dhyan') || q.contains('ध्यान') ||
        q.contains('mindfulness') || q.contains('maun') || q.contains('shant man') ||
        q.contains('guided meditation') || q.contains('calm mind')) {
      return '🧘 **Meditation / ध्यान / मेडिटेशन**\n\n'
          '❓ **What is meditation?** Training attention and awareness to achieve clarity,\n'
          'emotional calm, and a stable state of mind.\n\n'
          '✅ **Proven benefits / सिद्ध लाभ:**\n'
          '• 😌 Reduces stress, anxiety, depression\n'
          '• 😴 Improves sleep quality\n'
          '• 🩺 Lowers blood pressure | 💓 Reduces cortisol\n'
          '• 🧠 Improves focus and memory\n'
          '• 🌡️ Boosts immune system\n\n'
          '🌟 **How to start (5 min/day) / शुरुआत कैसे करें:**\n'
          '1. 🪑 Sit comfortably — spine straight, eyes closed\n'
          '2. 🌬️ Breathe naturally; focus on sensation of each breath\n'
          '3. 💭 When thoughts come (they will) — gently return focus to breath\n'
          '4. ⏱️ Start with 5 min/day → gradually increase to 20 min\n\n'
          '🔤 **Types / प्रकार:**\n'
          '• 🌬️ Mindfulness — focus on present moment\n'
          '• 🕉️ Mantra — repeat a word or phrase (e.g. "Om", "So Hum")\n'
          '• 💚 Loving-kindness (Metta) — cultivate compassion\n'
          '• 🧘 Vipassana — insight meditation (popular in India/Nepal)\n\n'
          '📱 **Free apps / मुफ्त ऐप:**\n'
          'Insight Timer, Headspace (free tier), Smiling Mind\n\n'
          '_Even 5 minutes of daily meditation produces measurable brain changes. 🧠_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 72 🌿 YOGA
    // EN: yoga, asana, pranayama, yoga benefits, stretching, flexibility
    // HI: yog, yog abhyas, asana, pranayam, yog ke fayde
    // NE: योग, yog, asana, pranayam, yog ko faida
    // BHO: yog, asana, pranayam, yog ke fayde
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('yoga') || q.contains('yog') || q.contains('योग') ||
        q.contains('asana') || q.contains('pranayama') || q.contains('pranayam') ||
        q.contains('surya namaskar') || q.contains('yoga benefits') || q.contains('flexibility')) {
      return '🌿 **Yoga / योग / योगाभ्यास**\n\n'
          '✅ **Benefits of regular yoga / नियमित योग के फायदे:**\n'
          '• 🧘 Reduces stress and anxiety\n'
          '• 💪 Improves flexibility, strength, and balance\n'
          '• 🩺 Lowers BP, blood sugar, and cholesterol\n'
          '• 😴 Improves sleep quality\n'
          '• 😣 Reduces chronic pain (back, neck, arthritis)\n'
          '• 🫁 Improves breathing (especially for asthma)\n\n'
          '🌟 **Beginner poses / शुरुआती आसन:**\n'
          '• 🙏 Tadasana (Mountain pose) — posture and grounding\n'
          '• 🐱 Cat-Cow — spine mobility, back pain relief\n'
          '• 🐶 Downward Dog — full body stretch\n'
          '• 🧘 Balasana (Child\'s pose) — rest and stress relief\n'
          '• 🪑 Virabhadrasana (Warrior) — strength and confidence\n\n'
          '🌬️ **Pranayama (breathing) / प्राणायाम:**\n'
          '• Anulom-Vilom (alternate nostril) — calms nervous system\n'
          '• Kapalbhati — energising breath (🚫 avoid in high BP)\n'
          '• Bhramari (humming bee) — reduces anxiety immediately\n\n'
          '☀️ **Surya Namaskar (Sun Salutation):**\n'
          '12-step sequence — full body workout, 15 min/day is excellent\n\n'
          '⚠️ **Precautions / सावधानियां:**\n'
          '• During pregnancy, injury, or surgery — consult doctor first\n\n'
          '_Yoga is for everyone, any age, any fitness level. Start today. 🌅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 73 ⚖️ OBESITY / WEIGHT MANAGEMENT
    // EN: obesity, overweight, weight loss, BMI, fat, losing weight
    // HI: mota, wajan zyada, wajan ghataana, moti hona, BMI
    // NE: मोटोपन, motaapa, wajan ghataunu, BMI
    // BHO: mota hona, wajan zyada, wajan ghataawa, BMI
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('obesity') || q.contains('overweight') || q.contains('mota') ||
        q.contains('motaapa') || q.contains('मोटोपन') || q.contains('bmi') ||
        q.contains('wajan zyada') || q.contains('losing weight') || q.contains('weight management') ||
        q.contains('wajan ghataana') || q.contains('wajan ghataawa')) {
      return '⚖️ **Obesity & Weight Management / मोटापा / वजन प्रबंधन**\n\n'
          '📊 **BMI categories / BMI श्रेणी:**\n'
          '• ✅ Normal: 18.5–24.9 | ⚠️ Overweight: 25–29.9\n'
          '• 🔴 Obese: ≥ 30 | Formula: weight (kg) ÷ height² (m²)\n\n'
          '⚠️ **Health risks of obesity / मोटापे के खतरे:**\n'
          '• 🩺 Type 2 diabetes | 🩺 Hypertension | 🫀 Heart disease\n'
          '• 😴 Sleep apnoea | 🦴 Joint pain | 🧬 Increased cancer risk\n'
          '• 🤰 Difficulty conceiving | 😢 Depression and low self-esteem\n\n'
          '🌿 **Weight loss approach / वजन घटाने का तरीका:**\n'
          '• 🎯 Aim for 0.5–1 kg loss per week — sustainable and safe\n'
          '• 🍽️ Calorie deficit: eat 300–500 cal/day less than you burn\n'
          '• 🥗 Portion control: smaller plates, no second servings\n'
          '• 💧 Drink water before meals — reduces appetite\n'
          '• ❌ Cut sugary drinks, packaged snacks, deep-fried food\n'
          '• 🏃 Exercise 300 min/week for weight loss (more than 150 for maintenance)\n\n'
          '💊 **Medical options:**\n'
          '• Weight loss medicines — only if BMI > 30 with risk factors\n'
          '• Bariatric surgery — for BMI > 40 or > 35 with comorbidities\n\n'
          '_Crash diets don\'t work long-term. Gradual, sustained changes do. 🌟_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 74 💧 WATER QUALITY / SAFE WATER
    // EN: water quality, safe water, contaminated water, purification, boiling water
    // HI: paani ki safai, surakshit paani, paani pradushan, paani ubalna
    // NE: पानी सफाई, surakshit pani, pani pradushan, pani umalnu
    // BHO: paani ke safai, surakshit paani, paani pradushan, paani ubalna
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('water quality') || q.contains('safe water') || q.contains('paani ki safai') ||
        q.contains('पानी सफाई') || q.contains('contaminated water') || q.contains('boiling water') ||
        q.contains('water purification') || q.contains('paani pradushan') || q.contains('pani umalnu')) {
      return '💧 **Water Quality & Safety / पानी की सुरक्षा / पानी सफाई**\n\n'
          '⚠️ **Waterborne diseases from unsafe water / गंदे पानी से बीमारियां:**\n'
          'Diarrhoea 🤢, Typhoid 🧪, Cholera, Hepatitis A 🫀, Polio, Worm infections 🪱\n\n'
          '🔥 **Making water safe / पानी को सुरक्षित बनाएं:**\n'
          '1. 💧 **Boiling** (most effective): Boil vigorously for 1 min; let cool before drinking\n'
          '2. ☀️ **Solar disinfection (SODIS)**: Fill clear PET bottle, place in direct sun 6+ hours\n'
          '3. 🧪 **Chlorination**: Add 2 drops bleach per litre; wait 30 min before drinking\n'
          '4. 🏺 **Water filter**: Ceramic, activated carbon, or RO — follow maintenance instructions\n\n'
          '✅ **Safe water habits / सुरक्षित आदतें:**\n'
          '• 🏺 Store in clean, covered container\n'
          '• 🚫 Never store in same container used for collection\n'
          '• 🙌 Wash hands before handling water or food\n'
          '• 🚫 Avoid ice from unknown sources\n'
          '• 🥗 Wash fruits and vegetables with safe water\n\n'
          '🚰 **When travelling / यात्रा के दौरान:**\n'
          '• Drink only bottled water or boiled water\n'
          '• Avoid street food washed with tap water\n\n'
          '_Safe water prevents more diseases than any single medicine. 🌍_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 75 🌫️ AIR QUALITY / POLLUTION
    // EN: air quality, pollution, dust, smog, respiratory, AQI
    // HI: vayu pradushan, dhool, dhuaan, AQI, pradushan
    // NE: वायु प्रदूषण, vayu pradushan, dhool, AQI
    // BHO: vayu pradushan, dhool, dhuaan, AQI
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('air quality') || q.contains('pollution') || q.contains('vayu pradushan') ||
        q.contains('वायु प्रदूषण') || q.contains('aqi') || q.contains('smog') ||
        q.contains('dust allergy') || q.contains('dhool') || q.contains('dhuaan')) {
      return '🌫️ **Air Quality & Pollution / वायु प्रदूषण / AQI**\n\n'
          '📊 **AQI levels / AQI स्तर:**\n'
          '• 🟢 0–50: Good | 🟡 51–100: Moderate\n'
          '• 🟠 101–150: Unhealthy for sensitive groups\n'
          '• 🔴 151–200: Unhealthy | 🟣 201+: Very Unhealthy\n\n'
          '😮‍💨 **Health effects of poor air / खराब हवा के असर:**\n'
          '• Coughing 😷, wheezing 💨, breathlessness 😮‍💨\n'
          '• Eye 👁️ and throat 😣 irritation\n'
          '• Worsening asthma, COPD, and heart disease\n'
          '• Long-term: lung cancer 🫁, reduced life expectancy\n\n'
          '🛡️ **Protection on high pollution days / बचाव:**\n'
          '• 😷 Wear N95 mask outdoors (surgical masks insufficient for PM2.5)\n'
          '• 🏠 Stay indoors during peak pollution hours (morning)\n'
          '• 🌬️ Use air purifier indoors | Keep windows closed\n'
          '• 🏃 Avoid outdoor exercise on very bad air days\n'
          '• 💧 Drink plenty of water — helps clear respiratory tract\n\n'
          '🌱 **Indoor air quality / घर की हवा:**\n'
          '• 🪟 Ventilate when outdoor air is clean\n'
          '• 🌿 Houseplants (Spider plant, Peace lily) reduce some pollutants\n'
          '• 🚫 No smoking indoors | 🍳 Use exhaust fan while cooking\n'
          '• 🕯️ Avoid incense/candles in poorly ventilated spaces\n\n'
          '_Check AQI daily on apps: AQI India, IQAir, Sameer (India). 📱_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 76 🐕 RABIES / DOG BITE
    // EN: rabies, dog bite, animal bite, kutta kata, rabies vaccine
    // HI: kutta kata, rabies, janwar ka kata, rabies tika
    // NE: कुकुर टोकाइ, rabies, janwar ko tokāi, rabies tika
    // BHO: kutta katale, rabies, janwar katale, rabies tika
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('rabies') || q.contains('dog bite') || q.contains('kutta kata') ||
        q.contains('कुकुर टोकाइ') || q.contains('animal bite') || q.contains('kutta katale') ||
        q.contains('janwar ka kata') || q.contains('rabies tika') || q.contains('janwar ko tokāi')) {
      return '🐕 **Dog Bite & Rabies / कुत्ते का काटना / रेबीज़**\n\n'
          '🚨 **IMMEDIATE ACTION / तुरंत करें:**\n'
          '1. 💧 Wash wound vigorously with soap and water for 15 minutes\n'
          '   (This single step reduces rabies risk by ~80%)\n'
          '2. 🟤 Apply antiseptic (Betadine / Povidone-iodine)\n'
          '3. 🏥 Go to hospital/GHMC centre within 24 hours for:\n'
          '   • 💉 Anti-Rabies Vaccination (ARV) — free at government hospitals\n'
          '   • 💉 Rabies Immunoglobulin (RIG) for severe bites\n'
          '   • 💉 Tetanus injection\n\n'
          '📋 **Bite categories / काटने की श्रेणी:**\n'
          '• Category I (licking unbroken skin) — wash only, no vaccine\n'
          '• Category II (scratches, minor bites) — wash + ARV\n'
          '• Category III (deep bites, face/neck/hands) — wash + ARV + RIG\n\n'
          '💉 **Vaccine schedule / टीके का समय:**\n'
          'Days 0, 3, 7, 14, 28 — must complete all 5 doses\n\n'
          '⚠️ **About the animal:**\n'
          '• Observe dog for 10 days — if healthy after 10 days, rabies less likely\n'
          '• If dog dies or disappears → complete full vaccine course\n\n'
          '🚨 **Rabies is 100% fatal once symptoms appear — vaccination is the only protection.**\n\n'
          '_Never delay — go to hospital on the same day as the bite. 🏥_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 77 🐝 BEE STING / INSECT BITE
    // EN: bee sting, wasp sting, insect bite, madhumakhi, dank
    // HI: madhumakhi ka dank, bhida ka dank, keede ka kata
    // NE: माहुरी डसेको, madhumakhi ko dank, kira kateko
    // BHO: madhumakhi katale, bhida ka dank, keeda katale
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('bee sting') || q.contains('madhumakhi') || q.contains('wasp') ||
        q.contains('माहुरी डसेको') || q.contains('insect bite') || q.contains('dank') ||
        q.contains('kira kateko') || q.contains('keede ka kata') || q.contains('bhida ka dank')) {
      return '🐝 **Bee Sting & Insect Bites / मधुमक्खी का डंक**\n\n'
          '🌿 **Bee/wasp sting — immediate care:**\n'
          '1. 🪗 Remove stinger if visible — scrape sideways with card/nail (don\'t squeeze)\n'
          '2. 💧 Wash area with soap and water\n'
          '3. 🧊 Apply ice pack wrapped in cloth for 10–15 minutes\n'
          '4. 💊 Ibuprofen 400 mg or Paracetamol for pain\n'
          '5. 💊 Cetrizine 10 mg for itching and local swelling\n\n'
          '🌿 **Natural remedies / घरेलू उपाय:**\n'
          '• 🍯 Raw honey on sting site — anti-inflammatory\n'
          '• 🧂 Baking soda paste (bee sting — acidic) or vinegar (wasp sting — alkaline)\n'
          '• 🌿 Aloe vera gel soothes and cools\n\n'
          '🚨 **ANAPHYLAXIS — Life-threatening allergic reaction / कॉल 108:**\n'
          '• 😮‍💨 Difficulty breathing | 🤧 Throat swelling\n'
          '• 💢 Severe hives all over body\n'
          '• 😵 Dizziness or fainting | 🤮 Nausea/vomiting\n'
          '• 💓 Rapid pulse\n\n'
          '🚨 **If known allergy:** Use Epinephrine (EpiPen) auto-injector immediately\n'
          'Call 108 even after EpiPen use — effects are temporary\n\n'
          '🐜 **For other insect bites (mosquito, ant, mite):**\n'
          '• 🚫 Don\'t scratch | Cool compress | Cetrizine for itching\n'
          '• ⚠️ Watch for signs of infection or tick-borne illness\n\n'
          '_People with known severe allergies should always carry an EpiPen. 💉_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 78 🥵 HEAT STROKE / HEAT EXHAUSTION
    // EN: heat stroke, heat exhaustion, loo, heat wave, overheating
    // HI: loo, garmi ki maar, tapish, heat stroke, loo lagana
    // NE: घाम लाग्नु, gham lagnu, loo, heat stroke
    // BHO: loo lagal, garmi ki maar, heat stroke, tapish
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('heat stroke') || q.contains('heat exhaustion') || q.contains('loo') ||
        q.contains('garmi ki maar') || q.contains('घाम लाग्नु') || q.contains('loo lagal') ||
        q.contains('overheating') || q.contains('heat wave') || q.contains('tapish')) {
      return '🥵 **Heat Stroke & Exhaustion / लू / घाम लाग्नु**\n\n'
          '🔥 **Heat Exhaustion (less severe) / Heat Exhaustion:**\n'
          'Heavy sweating 💦, weakness, cold/pale/clammy skin, fast weak pulse,\n'
          'nausea 🤢, muscle cramps, fainting\n\n'
          '🆘 **Heat Stroke (EMERGENCY) / Heat Stroke:**\n'
          'High body temp > 40°C 🌡️, hot/red/dry skin (NO sweating), rapid strong pulse,\n'
          'confusion 😵, slurred speech, loss of consciousness\n\n'
          '🚨 **Heat Stroke = Call 108 immediately**\n\n'
          '🌿 **Treatment / उपचार:**\n'
          '• 🏠 Move to cool, shaded area immediately\n'
          '• ❄️ Cool the person rapidly — most important step:\n'
          '  Cool wet cloths on neck, armpits, groin | Fan while misting with water\n'
          '  Ice packs if available\n'
          '• 💧 Give cool water/ORS to drink IF conscious and not vomiting\n'
          '• 🚫 Do NOT give fluids if unconscious\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 💧 Drink 2–3 litres water daily during summer\n'
          '• ☀️ Avoid outdoor work 11 AM – 4 PM during heat waves\n'
          '• 👒 Wear light, loose, light-coloured clothing; hat and umbrella\n'
          '• 🏠 Never leave children or elderly in parked cars\n'
          '• 💧 ORS or lemon-salt water during heavy outdoor work\n\n'
          '_Children, elderly, and outdoor workers are most at risk. Watch them closely. 👁️_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 79 🥶 COLD EXPOSURE / HYPOTHERMIA
    // EN: cold exposure, hypothermia, frostbite, extreme cold, thanda lagana
    // HI: thanda lagana, seethaapan, hypothermia, frostbite
    // NE: जाडो लाग्नु, thanda lagnu, hypothermia, frostbite
    // BHO: thanda laagal, hypothermia, frostbite, setha lagal
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('cold exposure') || q.contains('hypothermia') || q.contains('frostbite') ||
        q.contains('thanda lagana') || q.contains('जाडो लाग्नु') || q.contains('thanda laagal') ||
        q.contains('extreme cold') || q.contains('seethaapan')) {
      return '🥶 **Cold Exposure & Hypothermia / ठंड लगना / जाडो**\n\n'
          '⚠️ **Hypothermia** — body temperature drops dangerously below 35°C\n\n'
          '😓 **Mild signs:** Shivering 🥶, confusion 😵, slurred speech, drowsiness 😴\n'
          '🚨 **Severe signs:** Stiff muscles, very slow breathing, weak pulse, loss of consciousness\n\n'
          '🌿 **Treatment / उपचार:**\n'
          '• 🏠 Move to warm, sheltered location immediately\n'
          '• 👕 Remove wet clothing; replace with dry, warm layers\n'
          '• 🍵 Warm sweet drinks if conscious (NOT alcohol)\n'
          '• 🤗 Body warmth — hold person close, share body heat\n'
          '• 🌡️ Warm blankets; cover head (most heat lost through head)\n'
          '• 🚫 Do NOT rub limbs vigorously (can cause cardiac arrest)\n'
          '• 🚑 Call 108 for severe hypothermia\n\n'
          '❄️ **Frostbite (frozen tissue — usually fingers, toes, nose, ears):**\n'
          '• Symptoms: White/grey skin, numbness, hard/waxy texture\n'
          '• Rewarm in warm (not hot) water 37–40°C for 20–30 min\n'
          '• 🚫 Do NOT rub frostbitten area\n'
          '• 💊 Ibuprofen reduces tissue damage after rewarming\n'
          '• 🏥 Hospital needed for severe frostbite\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• Dress in layers: base (moisture-wicking), insulating, outer (windproof)\n'
          '• 🧤 Protect extremities: gloves, warm socks, hat, face cover\n\n'
          '_Hypothermia is a medical emergency — act fast. 🚨_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 80 🤢 FOOD POISONING
    // EN: food poisoning, contaminated food, bad food, stomach infection
    // HI: khaana kharab, food poisoning, khaana ka zeher, pet ka sankraman
    // NE: खाना विषाक्तता, khaana kharaab, food poisoning
    // BHO: khaana kharaab ho gail, food poisoning, khaana ke zeher
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('food poisoning') || q.contains('khaana kharab') || q.contains('khaana kharaab') ||
        q.contains('खाना विषाक्तता') || q.contains('bad food') || q.contains('contaminated food') ||
        q.contains('khaana ke zeher') || q.contains('stomach infection from food')) {
      return '🤢 **Food Poisoning / खाना खराब / खाद्य विषाक्तता**\n\n'
          '😓 **Symptoms (appear 1–72 hrs after eating) / लक्षण:**\n'
          'Nausea 🤮, vomiting, diarrhoea 💩, stomach cramps 😣, fever 🌡️, weakness 😴\n\n'
          '🏠 **Home treatment / घरेलू उपचार:**\n'
          '• 💧 ORS — most important — sip frequently to replace fluids\n'
          '• 🛌 Rest | 🍚 Eat bland food (rice, toast, banana) when feeling better\n'
          '• ❌ Avoid dairy, spicy, fatty, fried food for 48 hours\n'
          '• 💊 Paracetamol for fever | 🚫 Avoid anti-diarrhoea medicines\n'
          '   (allow body to flush out the infection naturally)\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• 🙌 Wash hands before handling food and after toilet\n'
          '• 🌡️ Cook meat/poultry/eggs thoroughly\n'
          '• ❄️ Refrigerate perishables within 2 hours\n'
          '• 🚫 Avoid raw/undercooked seafood and unpasteurised dairy\n'
          '• 🚫 Don\'t eat from roadside vendors with questionable hygiene\n'
          '• 🥗 Peel or wash fruits/vegetables with safe water\n\n'
          '🚨 **See doctor immediately for:**\n'
          '• 🩸 Blood in stool or vomit\n'
          '• Severe dehydration (no urine, dry mouth, dizziness)\n'
          '• High fever > 38.5°C | Symptoms lasting > 3 days\n'
          '• Symptoms in pregnant women, elderly, or children < 5\n\n'
          '_Most food poisoning resolves in 1–3 days with ORS and rest. 💧_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 81 🍺 ALCOHOL USE / HARM
    // EN: alcohol, drinking, alcoholism, quit alcohol, sharaab
    // HI: sharaab, madira, daru, alcohol peena, nasha, sharaab chhod
    // NE: रक्सी, sharaab, madira, alcohol, raksi pinu
    // BHO: sharaab, daru, madira, alcohol peena
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('alcohol') || q.contains('sharaab') || q.contains('daru') ||
        q.contains('रक्सी') || q.contains('madira') || q.contains('raksi') ||
        q.contains('drinking problem') || q.contains('alcoholism') || q.contains('quit alcohol')) {
      return '🍺 **Alcohol Use & Harm / शराब / रक्सी**\n\n'
          '⚠️ **Health harms of excess alcohol / अत्यधिक शराब के नुकसान:**\n'
          '• 🫀 Liver disease (fatty liver → hepatitis → cirrhosis)\n'
          '• 🩺 High BP | 🫀 Heart disease | 🧬 Cancer (liver, mouth, throat, breast)\n'
          '• 🧠 Brain damage | 😢 Depression and anxiety\n'
          '• 🤰 Fetal Alcohol Syndrome (if drunk during pregnancy)\n'
          '• 😴 Poor sleep quality | ⚖️ Weight gain\n\n'
          '📊 **Safe limits (if you drink) / सुरक्षित सीमा:**\n'
          '• Men: ≤ 2 standard drinks/day | Women: ≤ 1 standard drink/day\n'
          '• No alcohol: pregnant women, people on medicines, drivers\n\n'
          '🌿 **How to reduce / cut down:**\n'
          '• Set a drink limit before you go out\n'
          '• Alternate alcoholic with non-alcoholic drinks\n'
          '• Eat before/during drinking (slows absorption)\n'
          '• Identify triggers (stress, social pressure) and plan alternatives\n\n'
          '⚠️ **Alcohol withdrawal (in heavy drinkers) can be dangerous:**\n'
          'Do NOT stop suddenly — seek medical supervision\n'
          'Symptoms: Shaking, sweating, seizures, confusion\n\n'
          '📞 **Help / मदद:**\n'
          '• iCall: 9152987821 | Vandrevala: 1860-2662-345\n'
          '• NIMHANS Helpline: 080-46110007\n\n'
          '_Reducing alcohol is one of the best things you can do for your health. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 82 🚬 SMOKING / TOBACCO
    // EN: smoking, cigarette, tobacco, quit smoking, tambaku, bidi
    // HI: tambaaku, cigarette, bidi, dhoomrapaan, smoking chhodna
    // NE: धुम्रपान, tambaaku, cigarette, bidi, smoking chhadnu
    // BHO: tambaaku, cigarette, bidi, smoking, dhoomrapaan
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('smoking') || q.contains('cigarette') || q.contains('tambaaku') ||
        q.contains('धुम्रपान') || q.contains('tobacco') || q.contains('bidi') ||
        q.contains('quit smoking') || q.contains('dhoomrapaan') || q.contains('smoking chhadnu')) {
      return '🚬 **Smoking & Tobacco / धूम्रपान / तम्बाकू**\n\n'
          '☠️ **Health harms / स्वास्थ्य को नुकसान:**\n'
          '• 🫁 Lung cancer (85% caused by smoking) | COPD | Chronic bronchitis\n'
          '• 🫀 Heart disease | Stroke 🧠 | Peripheral artery disease\n'
          '• 👄 Mouth, throat, oesophageal, bladder, kidney cancer\n'
          '• 😷 Reduced immunity | ⚖️ Poor wound healing\n'
          '• 🤰 Miscarriage, premature birth, low birth weight\n\n'
          '✅ **Benefits of quitting / छोड़ने के फायदे:**\n'
          '• 20 min: BP and heart rate normalise\n'
          '• 12 hrs: Blood CO levels normalise\n'
          '• 1 year: Heart disease risk halved\n'
          '• 10 years: Lung cancer risk halved\n\n'
          '🌿 **How to quit / कैसे छोड़ें:**\n'
          '• 📅 Set a quit date\n'
          '• 🧠 Nicotine Replacement Therapy (patches, gum, lozenges) — very effective\n'
          '• 💊 Varenicline (Champix) — most effective medicine — doctor prescribed\n'
          '• 🤝 Tell family and friends — social support helps\n'
          '• 🏃 Exercise reduces cravings | 💧 Drink water when cravings hit\n\n'
          '📞 **iQuit India:** 1800-11-2356 (free tobacco helpline)\n\n'
          '_Every cigarette you don\'t smoke is a victory. You CAN quit. 💪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 83 💉 DRUG ABUSE / SUBSTANCE USE
    // EN: drug abuse, addiction, substance, nasha, drugs, overdose
    // HI: nasha, vyasanata, drug abuse, nesha, addiction
    // NE: लागुपदार्थ, nasha, drug abuse, lagupradath
    // BHO: nasha, drug abuse, vyasanata, nasha ki lat
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('drug abuse') || q.contains('addiction') || q.contains('nasha') ||
        q.contains('लागुपदार्थ') || q.contains('substance') || q.contains('lagupradath') ||
        q.contains('vyasanata') || q.contains('nasha ki lat') || q.contains('heroin') ||
        q.contains('cocaine') || q.contains('cannabis') || q.contains('drugs')) {
      return '💉 **Drug Abuse & Addiction / नशा / व्यसन**\n\n'
          '⚠️ **Signs of drug addiction / नशे के संकेत:**\n'
          '• Strong cravings and inability to stop\n'
          '• Neglecting responsibilities, family, work\n'
          '• Using despite knowing it\'s harmful\n'
          '• Withdrawal symptoms when stopping\n'
          '• Secrecy, behavioural changes, mood swings\n\n'
          '🧠 **Why addiction happens / नशे की लत क्यों:**\n'
          'Drugs hijack the brain\'s reward system — creating intense artificial pleasure,\n'
          'then making normal activities seem less rewarding without the substance.\n\n'
          '🌿 **Recovery is possible / स्वस्थ होना संभव है:**\n'
          '• Seek professional help — don\'t try to quit alone for severe addiction\n'
          '• Medically-supervised detox is safest\n'
          '• Behavioural therapy + medication + support groups\n'
          '• NIMS (National Institute of Mental Health) | NIMHANS centres\n\n'
          '🆘 **Overdose emergency / ओवरडोज़ — Call 108 immediately:**\n'
          '• Unconscious, not breathing, lips/face blue\n'
          '• Seizure | Unresponsive | Very slow breathing\n\n'
          '📞 **Helplines / मदद:**\n'
          '• NIMHANS: **080-46110007**\n'
          '• iCall: **9152987821**\n'
          '• Vandrevala: **1860-2662-345** (24/7)\n\n'
          '_Addiction is a disease, not a moral failure. Help is available. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 84 🟡 NEWBORN JAUNDICE
    // EN: newborn jaundice, neonatal jaundice, yellow baby, bilirubin
    // HI: navajaata shishu ki piliya, neonatal jaundice, paida hone ke baad piliya
    // NE: नवजात शिशु पिलियो, neonatal jaundice, newborn yellow
    // BHO: nawajaanma bacha ke piliya, neonatal jaundice, bacha peela
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('newborn jaundice') || q.contains('neonatal jaundice') ||
        q.contains('नवजात शिशु पिलियो') || q.contains('yellow baby') ||
        q.contains('bilirubin') || q.contains('nawajaanma bacha ke piliya') ||
        q.contains('bacha peela') || q.contains('navajaata ki piliya')) {
      return '🟡 **Newborn Jaundice / नवजात पीलिया / नवजात शिशु**\n\n'
          '❓ **What is it?** Yellowing of skin and eyes in newborns due to high bilirubin.\n'
          'Very common — affects 60% of term babies and 80% of premature babies.\n\n'
          '📊 **Types / प्रकार:**\n'
          '• ✅ Physiological (normal): Appears day 2–3, peaks day 3–5, resolves by day 14\n'
          '• ⚠️ Pathological (abnormal): Appears < 24 hrs of birth, very high bilirubin\n\n'
          '🌞 **Treatment / उपचार:**\n'
          '• 🤱 Frequent breastfeeding (8–12 times/day) helps clear bilirubin\n'
          '• ☀️ Indirect sunlight for 15–20 min/day (near window — never direct noon sun)\n'
          '• 💡 Phototherapy (blue light) — used in hospital for significant jaundice\n\n'
          '🚨 **See doctor immediately if:**\n'
          '• Yellow appears within 24 hours of birth\n'
          '• Yellow spreads to arms and legs\n'
          '• Baby is very sleepy, not feeding, arching back\n'
          '• High-pitched crying\n'
          '• Jaundice not improving by day 14 (breastfed) or day 7 (formula-fed)\n\n'
          '⚠️ **Untreated severe jaundice → brain damage (kernicterus)**\n\n'
          '_All jaundiced babies should be evaluated by a doctor. Never treat alone. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 85 😭 BABY COLIC
    // EN: colic, baby crying, inconsolable crying, infant colic
    // HI: shishu ka rona, colic, pet mein dard bacha, bachhe ka rona
    // NE: शिशु रुनु, shishu ko ruwāi, colic, bachho ko rokna namilne ruwāi
    // BHO: bacha bahut rota, colic, shishu ke pet mein dard
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('colic') || q.contains('shishu ka rona') || q.contains('शिशु रुनु') ||
        q.contains('baby crying') || q.contains('inconsolable') || q.contains('infant cry') ||
        q.contains('bacha bahut rota') || q.contains('bachhe ka rona')) {
      return '😭 **Baby Colic / शिशु कोलिक / बच्चे का रोना**\n\n'
          '❓ **What is colic?** Frequent, prolonged, intense crying in an otherwise healthy baby.\n'
          'Rule of 3: Crying > 3 hrs/day, > 3 days/week, for > 3 weeks\n'
          'Peak age: 2–6 weeks | Usually resolves by 3–4 months\n\n'
          '🔍 **Possible causes / संभावित कारण:**\n'
          '• 🌬️ Gas / abdominal discomfort\n'
          '• 🤱 Overfeeding or swallowing air during feeding\n'
          '• 🥛 Cow\'s milk protein sensitivity (in formula-fed)\n'
          '• 😰 Overstimulation or overtiredness\n\n'
          '🌿 **Soothing strategies / शांत करने के उपाय:**\n'
          '• 🤱 Hold and rock gently — continuous motion helps\n'
          '• 🎵 White noise: fan, running water, "shhhh" sound\n'
          '• 🚗 Car ride — vibration often calms colicky babies\n'
          '• 🤲 Tummy massage: gentle clockwise circles\n'
          '• 🍼 After each feed: burp baby properly (upright, pat back)\n'
          '• 🤱 If breastfed: mother try eliminating dairy for 2 weeks\n'
          '• 🍼 If formula-fed: try hydrolysed protein formula\n\n'
          '🚨 **See doctor if:**\n'
          '• 🌡️ Fever in baby | Not feeding properly\n'
          '• 🩸 Blood in stool | Vomiting\n'
          '• Weight not increasing\n\n'
          '_Colic is stressful for parents too. Take turns and ask for help. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 86 🍑 DIAPER RASH
    // EN: diaper rash, nappy rash, red bottom, langot daane
    // HI: langot daane, nappy rash, diaper rash, bacche ki gaand mein daane
    // NE: ल्यांगट दाने, diaper rash, nappy rash, bacche ko chhala
    // BHO: langot daane, diaper rash, bacha ke peeche daane
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('diaper rash') || q.contains('nappy rash') || q.contains('langot daane') ||
        q.contains('ल्यांगट दाने') || q.contains('red bottom') || q.contains('baby rash') ||
        q.contains('nappy') || q.contains('bacha ke peeche daane')) {
      return '🍑 **Diaper Rash / लंगोट दाने / नैपी रैश**\n\n'
          '😓 **Signs / लक्षण:**\n'
          'Red, irritated, puffy skin in diaper area; baby cries when area touched/cleaned\n\n'
          '🌿 **Treatment / उपचार:**\n'
          '• 💨 Air time — leave baby without diaper 10–15 min several times/day\n'
          '• 🧴 Zinc oxide cream (Sudocrem / Desitin) — thick barrier at each change\n'
          '• 💧 Clean gently with plain warm water at each change (no wipes on broken skin)\n'
          '• 🔄 Change nappy frequently — do NOT let baby sit in wet/dirty nappy\n'
          '• 👶 Pat dry gently (don\'t rub) before applying cream\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• Change nappy every 2–3 hours and immediately after stools\n'
          '• Use fragrance-free, alcohol-free wipes\n'
          '• Apply thin layer of barrier cream at every change\n'
          '• Avoid tight-fitting nappies — air circulation helps\n\n'
          '🔴 **Fungal nappy rash (Candida):**\n'
          '• Bright red rash with satellite spots beyond the main area\n'
          '• Treatment: Clotrimazole cream + zinc oxide cream — doctor confirms\n\n'
          '🚨 **See doctor if:**\n'
          '• Rash not improving in 2–3 days with treatment\n'
          '• Blisters, oozing, or open sores | Rash spreading to abdomen/thighs\n'
          '• 🌡️ Fever with rash\n\n'
          '_Most diaper rashes clear within 3 days with proper care. ✅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 87 😬 TEETHING
    // EN: teething, baby teeth, tooth eruption, dant nikalna, gum pain baby
    // HI: dant nikalna, daant aana, shishu ke dant, masude mein dard
    // NE: दाँत उम्रनु, dant nikalna, shishu ko dant, masuda dukha
    // BHO: dant nikalta, shishu ke dant aawata, masuda mein dard
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('teething') || q.contains('dant nikalna') || q.contains('दाँत उम्रनु') ||
        q.contains('baby teeth') || q.contains('tooth eruption') || q.contains('shishu ke dant') ||
        q.contains('dant nikalta') || q.contains('masuda dukha')) {
      return '😬 **Teething / दाँत निकलना / दाँत उम्रनु**\n\n'
          '📅 **When do teeth come? / दाँत कब आते हैं?**\n'
          '• First tooth: Usually 6–10 months (can vary 4–14 months)\n'
          '• All 20 baby teeth: By age 3 years\n\n'
          '😓 **Common symptoms / लक्षण:**\n'
          '• 🤤 Drooling excessively\n'
          '• 😣 Swollen, tender gums\n'
          '• 😤 Irritability and fussiness\n'
          '• 🤤 Chewing on everything\n'
          '• 🌡️ Low-grade temperature (≤ 38°C) — teething can cause slight warmth\n'
          '• ⚠️ Teething does NOT cause high fever, diarrhoea, or vomiting\n'
          '   (If these occur, another illness is the cause)\n\n'
          '🌿 **Relief / राहत:**\n'
          '• ❄️ Cold teething ring (refrigerated, NOT frozen)\n'
          '• 🤲 Clean finger massage on gums\n'
          '• 🧊 Cold wet washcloth to chew\n'
          '• 💊 Paracetamol if clearly very uncomfortable (per weight dose)\n'
          '• 🚫 Avoid: teething gels with benzocaine (risk), amber necklaces (choking/strangulation risk)\n\n'
          '🦷 **First dental visit:** By age 1 or within 6 months of first tooth\n\n'
          '🪥 **Early dental care:**\n'
          '• Clean gums with damp cloth from birth\n'
          '• When first tooth appears: soft toothbrush + smear of fluoride toothpaste\n\n'
          '_Teething is uncomfortable but temporary. It will pass! 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 88 📏 BABY GROWTH MILESTONES
    // EN: growth milestones, baby development, when to walk, speech delay
    // HI: shishu vikas, milestones, chalna kab seekhega, bolna kab seekhega
    // NE: शिशु विकास, milestones, bacche ko vikas, kathne kab
    // BHO: shishu ke vikas, milestones, bacha kab bolega, kab chalega
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('milestone') || q.contains('baby development') || q.contains('shishu vikas') ||
        q.contains('शिशु विकास') || q.contains('growth chart') || q.contains('when to walk') ||
        q.contains('speech delay') || q.contains('kab chalega') || q.contains('kab bolega')) {
      return '📏 **Baby Growth Milestones / शिशु विकास / बच्चे की प्रगति**\n\n'
          '📅 **Key milestones / प्रमुख मील के पत्थर:**\n'
          '• 2 months: Smiles 😊, holds head briefly, tracks with eyes\n'
          '• 4 months: Laughs 😄, reaches for objects, holds head steady\n'
          '• 6 months: Sits with support, transfers objects hand to hand, babbles 🗣️\n'
          '• 9 months: Crawls 🐣, pulls to stand, says "mama/dada"\n'
          '• 12 months: Stands alone, first steps 👶, 2–3 words\n'
          '• 18 months: Walks well, ~10 words, feeds self with spoon\n'
          '• 2 years: Runs, 50+ words, two-word phrases\n'
          '• 3 years: Climbs stairs, sentences, toilet training starts\n\n'
          '⚠️ **Red flags — see doctor if / डॉक्टर दिखाएं:**\n'
          '• 2 months: No smile, doesn\'t respond to sounds\n'
          '• 4 months: Doesn\'t hold head up\n'
          '• 6 months: No babbling, doesn\'t reach for objects\n'
          '• 12 months: No words, doesn\'t point, can\'t stand with support\n'
          '• 18 months: No walking, < 6 words\n'
          '• 2 years: No 2-word phrases\n\n'
          '📊 **Growth charts:**\n'
          '• Plot weight and height monthly (under 1 year) / quarterly (1–5 years)\n'
          '• Use WHO growth charts at your health centre\n\n'
          '🥗 **Supporting development:**\n'
          '• Talk, sing, read to baby from birth\n'
          '• Tummy time daily from newborn stage\n'
          '• Limit screen time: ZERO under 2 years\n\n'
          '_Every child develops at their own pace — but red flags deserve early evaluation. 🩺_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 89 🧩 AUTISM
    // EN: autism, autism spectrum, ASD, speech delay, social difficulty
    // HI: autism, ASD, autism spectrum, baat nahi karta, samajik samasya
    // NE: अटिज्म, autism, ASD, boli boltaina, samajik samasya
    // BHO: autism, ASD, baat nahi karta, samajik samasya
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('autism') || q.contains('asd') || q.contains('अटिज्म') ||
        q.contains('autism spectrum') || q.contains('speech delay') ||
        q.contains('baat nahi karta') || q.contains('samajik samasya') ||
        q.contains('social difficulty child')) {
      return '🧩 **Autism (ASD) / ऑटिज्म / अटिज्म**\n\n'
          '❓ **What is Autism Spectrum Disorder?**\n'
          'A neurodevelopmental condition affecting communication, social interaction,\n'
          'and behaviour. Present from birth — detected usually age 2–3 years.\n\n'
          '🔍 **Early signs / प्रारंभिक संकेत:**\n'
          '• No babbling by 12 months, no words by 16 months\n'
          '• No two-word phrases by 24 months\n'
          '• Limited eye contact, doesn\'t respond to name being called\n'
          '• Lack of pointing or waving gestures\n'
          '• Loss of previously acquired language skills\n'
          '• Repetitive movements (hand flapping, rocking, spinning)\n'
          '• Intense focus on specific objects or topics\n\n'
          '✅ **Early intervention is key / शीघ्र हस्तक्षेप:**\n'
          '• Applied Behaviour Analysis (ABA) therapy\n'
          '• Speech and language therapy\n'
          '• Occupational therapy\n'
          '• Special education support\n\n'
          '💚 **What autism is NOT:**\n'
          '• NOT caused by vaccines 💉 (this is a proven myth)\n'
          '• NOT a disease to be "cured"\n'
          '• NOT the parents\' fault\n\n'
          '📞 **India support:** NIMHANS Bangalore: 080-46110007\n'
          'Action for Autism: 011-45501692\n\n'
          '_With early support, autistic children can thrive. Seek evaluation early. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 90 🌟 DOWN SYNDROME
    // EN: Down syndrome, trisomy 21, intellectual disability, mongol
    // HI: Down syndrome, trisomy 21, mansik viklaangata
    // NE: डाउन सिन्ड्रोम, Down syndrome, trisomy 21
    // BHO: Down syndrome, trisomy 21, mansik viklaangata
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('down syndrome') || q.contains('trisomy 21') || q.contains('डाउन सिन्ड्रोम') ||
        q.contains('down\'s syndrome') || q.contains('intellectual disability') ||
        q.contains('mansik viklaangata') || q.contains('down syndrome child')) {
      return '🌟 **Down Syndrome / डाउन सिंड्रोम**\n\n'
          '❓ **What is Down Syndrome?**\n'
          'A genetic condition where a person has an extra copy of chromosome 21.\n'
          'Causes intellectual disability and characteristic physical features.\n\n'
          '🔍 **Features / विशेषताएं:**\n'
          '• Flat facial features, upward-slanting eyes, small ears\n'
          '• Low muscle tone (hypotonia) at birth\n'
          '• Intellectual disability (mild to moderate in most)\n'
          '• Short stature\n'
          '• Risk of heart defects (50%), thyroid problems, hearing loss\n\n'
          '🏥 **Health checks needed / स्वास्थ्य जांच:**\n'
          '• ❤️ Heart screening (echocardiogram) soon after birth\n'
          '• 🦋 Thyroid function (TSH) regularly\n'
          '• 👂 Hearing tests | 👁️ Vision checks\n'
          '• Cervical spine X-ray before sports participation\n\n'
          '✅ **Support & development:**\n'
          '• Early intervention: physiotherapy, speech therapy, occupational therapy\n'
          '• Inclusive education with support\n'
          '• Regular health monitoring throughout life\n\n'
          '💚 **With support, people with Down Syndrome can:**\n'
          'Learn, work, live semi-independently, and lead fulfilling lives\n\n'
          '📞 **Down Syndrome Federation of India:** www.downsyndromefederation.in\n\n'
          '_Down Syndrome is a part of human diversity. Support and inclusion matter. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 91 🩸 THALASSEMIA
    // EN: thalassemia, blood disorder, haemoglobin disorder, thalasimiya
    // HI: thalassemia, khoon ki genetic bimari, haemoglobin rog
    // NE: थैलेसेमिया, thalassemia, raktako genetic rog
    // BHO: thalassemia, khoon ki bimari, thalasimiya
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('thalassemia') || q.contains('thalasimiya') || q.contains('थैलेसेमिया') ||
        q.contains('haemoglobin disorder') || q.contains('blood disorder genetic') ||
        q.contains('raktako genetic') || q.contains('thalassemia major')) {
      return '🩸 **Thalassemia / थैलेसेमिया**\n\n'
          '❓ **What is Thalassemia?**\n'
          'An inherited blood disorder where the body makes abnormal or insufficient haemoglobin.\n'
          'Very common in India, Pakistan, Nepal — 1 in 25 people are carriers.\n\n'
          '🔬 **Types / प्रकार:**\n'
          '• 🟢 Thalassemia Trait (minor) — carrier; usually no symptoms; important to know before having children\n'
          '• 🔴 Thalassemia Major — requires regular blood transfusions every 3–4 weeks to survive\n'
          '• 🟡 Thalassemia Intermedia — moderate; may need occasional transfusions\n\n'
          '😓 **Symptoms of Thalassemia Major:**\n'
          'Severe anaemia 😴, pale/yellow skin, enlarged spleen/liver, growth failure,\n'
          'bone deformities (untreated)\n\n'
          '🏥 **Treatment / उपचार:**\n'
          '• Regular blood transfusions + iron chelation therapy (to remove excess iron)\n'
          '• 🦴 Bone marrow transplant — potential cure\n'
          '• Folic acid supplements\n\n'
          '🛡️ **Prevention / बचाव:**\n'
          '• Both parents should be tested before having children\n'
          '• If both are carriers — prenatal testing available\n'
          '• 💉 All couples should get thalassemia screening before marriage/pregnancy\n\n'
          '📞 **Thalassemia India:** thalaemeia.in\n\n'
          '_Early diagnosis and regular care allow patients to live active lives. ✅_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 92 🩸 SICKLE CELL DISEASE
    // EN: sickle cell, sickle cell disease, sickle cell anaemia, SCD
    // HI: sickle cell, drepanositosis, sickle cell anaemia
    // NE: सिकल सेल, sickle cell, sickle cell anaemia
    // BHO: sickle cell, drepanositosis, sickle cell anaemia
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('sickle cell') || q.contains('drepanositosis') || q.contains('सिकल सेल') ||
        q.contains('sickle cell anaemia') || q.contains('sickle cell disease') ||
        q.contains('scd') || q.contains('sickle')) {
      return '🩸 **Sickle Cell Disease / सिकल सेल रोग**\n\n'
          '❓ **What is it?**\n'
          'Inherited disorder where red blood cells become rigid, sticky, and shaped like sickles.\n'
          'Common in Central India (tribal populations), and parts of Africa.\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          '• 💢 Pain crises (vaso-occlusive) — sudden severe pain in bones, chest, joints\n'
          '• 😴 Anaemia and fatigue\n'
          '• 🌡️ Frequent infections (spleen damaged)\n'
          '• 🧠 Stroke risk in children | 🫁 Acute chest syndrome\n'
          '• 😟 Delayed growth and puberty\n\n'
          '🏥 **Management / प्रबंधन:**\n'
          '• 💧 Stay well hydrated daily (prevents sickling)\n'
          '• 💊 Folic acid daily | Hydroxyurea (reduces crises) — doctor prescribed\n'
          '• 💉 Penicillin prophylaxis (children < 5)\n'
          '• Vaccinations: Pneumococcal, Meningococcal, Influenza\n'
          '• 🩸 Blood transfusions for severe anaemia or stroke prevention\n'
          '• 🦴 Bone marrow transplant — potential cure\n\n'
          '🔴 **Pain crisis — go to hospital:**\n'
          '• 💊 Painkillers, IV fluids, warmth\n'
          '• 🚫 Do NOT delay — complications can be life-threatening\n\n'
          '🛡️ **Genetic counselling:** Both parents should be tested before having children\n\n'
          '_With modern care, people with sickle cell disease lead active lives. 💪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 93 😴 SLEEP APNEA / SNORING
    // EN: sleep apnea, snoring, kharrate, breathing stops during sleep
    // HI: kharrate, neend mein saans rukna, sleep apnea
    // NE: घुर्र्याउनु, sleep apnea, neend mein saans rukna
    // BHO: kharrate, neend mein saans band, sleep apnea
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('sleep apnea') || q.contains('snoring') || q.contains('kharrate') ||
        q.contains('घुर्र्याउनु') || q.contains('saans rukna') || q.contains('breathing stops') ||
        q.contains('apnea') || q.contains('kharrate') || q.contains('neend mein saans band')) {
      return '😴 **Sleep Apnea & Snoring / खर्राटे / नींद में सांस रुकना**\n\n'
          '❓ **What is Sleep Apnea?**\n'
          'Repeated episodes where breathing stops during sleep — can last seconds to minutes.\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          '• 🔊 Loud snoring | 😮 Gasping or choking during sleep\n'
          '• 😴 Excessive daytime sleepiness despite full night\'s sleep\n'
          '• 🤕 Morning headaches | 😕 Poor concentration and memory\n'
          '• 😢 Irritability and mood changes\n\n'
          '⚠️ **Health risks if untreated / अनुपचारित खतरे:**\n'
          '• 🩺 High BP | 🫀 Heart disease and arrhythmias\n'
          '• 🧠 Stroke | 🩺 Worsening diabetes\n'
          '• 🚗 Increased road accident risk (sleepiness)\n\n'
          '🌿 **Lifestyle changes / जीवनशैली:**\n'
          '• ⚖️ Lose weight — obesity is #1 risk factor\n'
          '• 🍺 Avoid alcohol and sedatives (relax throat muscles)\n'
          '• 🔄 Sleep on your side, not back\n'
          '• 🚭 Quit smoking\n'
          '• 😴 Maintain regular sleep schedule\n\n'
          '🏥 **Medical treatment / चिकित्सा:**\n'
          '• 💨 CPAP machine — gold standard; keeps airway open\n'
          '• Dental device (for mild-moderate)\n'
          '• Surgery in selected cases\n\n'
          '🩺 **See doctor for sleep study (polysomnography) to confirm diagnosis.**\n\n'
          '_Sleep apnea is very treatable. Getting diagnosed changes lives. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 94 🫁 COPD / CHRONIC LUNG DISEASE
    // EN: COPD, chronic bronchitis, emphysema, chronic lung disease
    // HI: COPD, puraani khansi, phephde ki bimari, dhool se khansi
    // NE: COPD, puraano khansi, phokso ko puraano rog
    // BHO: COPD, puraani khansi, phephde ki bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('copd') || q.contains('chronic bronchitis') || q.contains('emphysema') ||
        q.contains('puraani khansi') || q.contains('phephde ki bimari') ||
        q.contains('puraano khansi') || q.contains('chronic lung')) {
      return '🫁 **COPD / Chronic Lung Disease / पुरानी खांसी**\n\n'
          '❓ **What is COPD?**\n'
          'Chronic Obstructive Pulmonary Disease — progressive lung disease causing\n'
          'breathing difficulty. Main types: Chronic Bronchitis and Emphysema.\n\n'
          '🔍 **Causes / कारण:**\n'
          '• 🚬 Smoking — by far the #1 cause\n'
          '• 🌫️ Long-term exposure to dust, chemicals, biomass smoke (chulha/cooking fire)\n\n'
          '😓 **Symptoms / लक्षण:**\n'
          '• 😮‍💨 Persistent breathlessness (worse with exertion)\n'
          '• 😷 Chronic cough with mucus (especially morning)\n'
          '• 💨 Wheezing | 😴 Fatigue\n'
          '• Frequent respiratory infections\n\n'
          '📋 **Management / प्रबंधन:**\n'
          '• 🚭 Quit smoking — slows progression dramatically\n'
          '• 💨 Bronchodilator inhalers (Tiotropium, Salbutamol) — prescribed\n'
          '• 💉 Annual flu vaccine + pneumococcal vaccine\n'
          '• 🏃 Pulmonary rehabilitation exercises\n'
          '• 🏠 Improve indoor ventilation; avoid smoke and dust\n\n'
          '🚨 **See doctor for:**\n'
          '• Sudden worsening breathlessness | Bluish lips or fingertips\n'
          '• Increased mucus production with colour change\n\n'
          '_COPD is not curable but is very manageable. Quitting smoking is the best treatment. 🚭_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 95 🩺 GENERAL HEALTH CHECK / PREVENTIVE CARE
    // EN: health checkup, preventive care, health screening, annual checkup
    // HI: swasthya jaanch, niyamit check-up, samanyajanch, jaanch
    // NE: स्वास्थ्य जाँच, niyamit checkup, swasthya parikshan
    // BHO: swasthya jaanch, niyamit check-up, checkup kaise kare
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('health checkup') || q.contains('health check') || q.contains('preventive') ||
        q.contains('annual checkup') || q.contains('swasthya jaanch') || q.contains('स्वास्थ्य जाँच') ||
        q.contains('niyamit check') || q.contains('health screening') || q.contains('checkup kaise')) {
      return '🩺 **Preventive Health Checkup / नियमित स्वास्थ्य जाँच**\n\n'
          '📅 **Recommended annual tests (adults) / वयस्कों के लिए:**\n'
          '• 🩸 Complete Blood Count (CBC) — checks for anaemia, infection\n'
          '• 🩺 Blood pressure measurement\n'
          '• 🩸 Fasting blood sugar + HbA1c (diabetes screening)\n'
          '• 🫀 Lipid profile (cholesterol)\n'
          '• 🫘 Kidney function (creatinine, urea)\n'
          '• 🫀 Liver function tests (if drinking, fatty liver risk)\n'
          '• 🦋 Thyroid (TSH) — especially women over 30\n'
          '• 🪶 Vitamin D and B12 levels\n\n'
          '👩 **Women-specific / महिलाओं के लिए:**\n'
          '• 🌸 Pap smear every 3 years (age 21–65)\n'
          '• 🎗️ Breast self-exam monthly; mammogram after 40\n'
          '• 💉 HPV vaccine (9–45 years, if not vaccinated)\n\n'
          '👨 **Men-specific / पुरुषों के लिए:**\n'
          '• Prostate (PSA) — discuss with doctor after age 50\n'
          '• Testicular self-exam monthly\n\n'
          '👁️🦷👂 **Other regular checks:**\n'
          '• Eye exam every 2 years | Dental check every 6 months | Hearing check after 50\n\n'
          '💉 **Keep vaccinations up to date / टीकाकरण:**\n'
          'Flu vaccine annually | COVID booster | Tetanus every 10 years\n\n'
          '_Prevention is better than cure. Regular checkups save lives. 💚_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 96 🏥 FINDING HEALTHCARE / FREE SERVICES
    // EN: free hospital, government hospital, health centre, ASHA worker
    // HI: sarkari aspatal, muft ilaaj, swasthya kendra, ASHA karyakarta
    // NE: सरकारी अस्पताल, muft ilaaj, swasthya kendra
    // BHO: sarkari aspatal, muft ilaaj, swasthya kendra, ASHA
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('free hospital') || q.contains('government hospital') || q.contains('sarkari aspatal') ||
        q.contains('सरकारी अस्पताल') || q.contains('asha worker') || q.contains('health centre') ||
        q.contains('muft ilaaj') || q.contains('free treatment') || q.contains('swasthya kendra')) {
      return '🏥 **Free Healthcare Services / मुफ्त स्वास्थ्य सेवाएं**\n\n'
          '🇮🇳 **India / भारत:**\n'
          '• 🏥 Government hospitals & PHC (Primary Health Centres) — free OPD care\n'
          '• 👩 ASHA workers — community health workers at village level\n'
          '• 💊 Jan Aushadhi Kendras — generic medicines at 50–90% lower cost\n'
          '• 💉 National Immunisation Programme — all childhood vaccines free\n'
          '• 🤰 Janani Suraksha Yojana — free institutional delivery + cash incentive\n'
          '• 🫁 DOTS centres — free TB treatment\n'
          '• 💉 ART centres — free HIV treatment\n'
          '• 🩸 Blood banks — free for BPL card holders\n'
          '• 📞 Ayushman Bharat (PM-JAY): Free hospitalization up to ₹5 lakh/year\n\n'
          '🇳🇵 **Nepal / नेपाल:**\n'
          '• Free healthcare at government health posts and hospitals\n'
          '• Free immunisation program\n'
          '• Free TB and HIV treatment\n'
          '• Female Community Health Volunteers (FCHVs) at village level\n\n'
          '📞 **National Health Helplines / राष्ट्रीय हेल्पलाइन:**\n'
          '• 🇮🇳 India health helpline: **104** (Medical advice, free)\n'
          '• 🇮🇳 Ambulance: **108** | Mental health: **iCall 9152987821**\n'
          '• 🇳🇵 Nepal: **1115** (Health helpline)\n\n'
          '_Always check eligibility for government schemes at your local PHC. 🏥_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 97 🍽️ FASTING / RELIGIOUS FASTING
    // EN: fasting, roza, vrat, upvaas, intermittent fasting
    // HI: vrat, upvaas, roza, faasting, bhojan nahi khana
    // NE: उपवास, vrat, upvaas, roza, faasting
    // BHO: vrat, upvaas, roza, faasting, bhojan na khaana
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('fasting') || q.contains('vrat') || q.contains('upvaas') ||
        q.contains('उपवास') || q.contains('roza') || q.contains('intermittent fasting') ||
        q.contains('bhojan nahi') || q.contains('faasting')) {
      return '🍽️ **Fasting & Health / उपवास / व्रत**\n\n'
          '✅ **General safe fasting tips / सुरक्षित उपवास:**\n'
          '• 💧 Stay well hydrated — water, coconut water, lemon water\n'
          '• 🚫 Avoid caffeine if going caffeine-free — can cause headache\n'
          '• 🍎 Break fast with easily digestible food: fruits, curd, khichdi\n'
          '• 🚫 Avoid binge eating after fast — stress on digestive system\n\n'
          '⚠️ **Who should NOT fast without doctor\'s advice:**\n'
          '• 🩺 Diabetics (especially on insulin or medicines causing hypoglycemia)\n'
          '• 🤰 Pregnant or breastfeeding women\n'
          '• 👶 Children under 12\n'
          '• 💊 People on daily essential medications\n'
          '• 😴 Anyone with low weight or eating disorders\n\n'
          '🩺 **Diabetes + fasting:**\n'
          '• Always consult doctor before fasting\n'
          '• Doctor may adjust medicines for the fasting period\n'
          '• Monitor blood sugar closely during fast\n'
          '• Break fast immediately if sugar drops (hypoglycemia)\n\n'
          '⏰ **Intermittent fasting (16:8, 5:2):**\n'
          '• Can aid weight loss and metabolic health\n'
          '• Not suitable for everyone — discuss with doctor\n\n'
          '_Religious fasting is safe for most healthy adults with proper hydration. 💧_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 98 🧬 GENETIC / HEREDITARY CONDITIONS
    // EN: genetic disease, hereditary, family history, inherited condition
    // HI: vanshaanut bimari, hereditary, parivaar mein bimari, genetic
    // NE: वंशाणुगत रोग, hereditary, parivar ko rog, genetic
    // BHO: vanshaanut bimari, hereditary, parivar mein bimari
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('genetic') || q.contains('hereditary') || q.contains('vanshaanut') ||
        q.contains('वंशाणुगत') || q.contains('family history') || q.contains('inherited') ||
        q.contains('parivaar mein bimari') || q.contains('parivar ko rog')) {
      return '🧬 **Genetic & Hereditary Conditions / आनुवंशिक रोग**\n\n'
          '❓ **What is a genetic condition?**\n'
          'Caused by abnormalities in genes or chromosomes — can be inherited from parents\n'
          'or occur as new mutations.\n\n'
          '🔍 **Common inherited conditions in South Asia:**\n'
          '• 🩸 Thalassemia | Sickle Cell Disease\n'
          '• 🩺 Diabetes (strong family component)\n'
          '• 🫀 Heart disease (familial hypercholesterolaemia)\n'
          '• 🎗️ BRCA gene mutations (breast/ovarian cancer)\n'
          '• 👁️ Hereditary cataracts and glaucoma\n'
          '• 🧠 Certain epilepsies and intellectual disabilities\n\n'
          '🛡️ **If family history of genetic disease / परिवार में बीमारी है तो:**\n'
          '• 💑 Pre-marital genetic screening (especially thalassemia, SCD)\n'
          '• 🤰 Prenatal testing available (amniocentesis, chorionic villus sampling)\n'
          '• 🧬 Genetic counselling — understand your risk and options\n\n'
          '✅ **Genetic counselling centres:**\n'
          '• Available at major government hospitals and AIIMS\n'
          '• Refer to state genetic disease programme\n\n'
          '_Knowing your family history empowers you to take preventive action. 💪_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 99 🩺 PAIN MANAGEMENT
    // EN: pain, chronic pain, pain relief, dard, analgesia
    // HI: dard, peeda, chronic dard, dard se rahat, pain management
    // NE: दुखाइ, dard, chronic dard, dard ko upchar
    // BHO: dard, peeda, chronic dard, dard mein rahat
    // ─────────────────────────────────────────────────────────────────────────
    if ((q.contains('pain') && !q.contains('back pain') && !q.contains('chest pain') &&
         !q.contains('stomach') && !q.contains('head') && !q.contains('knee') &&
         !q.contains('joint') && !q.contains('tooth') && !q.contains('ear') &&
         !q.contains('shoulder') && !q.contains('neck')) ||
        q.contains('dard se rahat') || q.contains('chronic dard') ||
        q.contains('दुखाइ') || q.contains('peeda') || q.contains('pain management') ||
        q.contains('analgesia')) {
      return '🩺 **Pain Management / दर्द से राहत / दुखाइ**\n\n'
          '💊 **Pain medicines / दर्द की दवाइयां (WHO Pain Ladder):**\n'
          '• 🟢 Mild pain: Paracetamol 500 mg–1 g every 6 hrs\n'
          '• 🟡 Moderate pain: Ibuprofen 400 mg (with food) every 6–8 hrs\n'
          '• 🔴 Severe pain: Prescription opioids (doctor only)\n\n'
          '🌿 **Non-medicine techniques / दवाइयों के बिना:**\n'
          '• 🧊 Cold compress: acute injuries, inflammation (first 48 hrs)\n'
          '• 🌡️ Heat compress: muscle stiffness, chronic pain, cramps\n'
          '• 🧘 Relaxation & breathing: reduces pain perception\n'
          '• 🏃 Gentle movement: walking, swimming, yoga (counterintuitively helps)\n'
          '• 🤲 TENS therapy (transcutaneous electrical nerve stimulation)\n'
          '• 💆 Massage therapy | Acupuncture\n\n'
          '⚠️ **Safe use of painkillers:**\n'
          '• Paracetamol: max 4 g/day; avoid with alcohol/liver disease\n'
          '• NSAIDs (Ibuprofen): always with food; avoid long-term; protect kidneys\n'
          '• Never take two NSAIDs together\n\n'
          '🚨 **See doctor for:**\n'
          '• Pain unrelieved by OTC medicines\n'
          '• Pain waking you from sleep\n'
          '• Sudden new severe pain\n'
          '• Chronic pain for > 3 months\n\n'
          '_Chronic pain is a real condition that deserves proper medical treatment. 💙_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 100 🌡️ TEMPERATURE / THERMOMETER
    // EN: how to take temperature, thermometer, body temperature
    // HI: taapmaan, thermometer, sharir ka taapmaan kaise naapen
    // NE: तापक्रम, thermometer, sharir ko taapmaan
    // BHO: taapmaan, thermometer, sharir ka taapmaan
    // ─────────────────────────────────────────────────────────────────────────
    if (q.contains('thermometer') || q.contains('taapmaan') || q.contains('तापक्रम') ||
        q.contains('body temperature') || q.contains('how to check fever') ||
        q.contains('sharir ka taapmaan') || q.contains('temperature check')) {
      return '🌡️ **How to Check Temperature / तापमान कैसे लें**\n\n'
          '📊 **Normal ranges / सामान्य तापमान:**\n'
          '• Oral (mouth): 36.1–37.2°C (97–99°F)\n'
          '• Axillary (armpit): 35.5–36.9°C (add 0.5°C for oral equivalent)\n'
          '• Rectal (infant): 36.6–38.0°C (most accurate for babies)\n'
          '• Ear (tympanic): 35.8–38.0°C\n'
          '• Forehead (temporal): 36.1–37.2°C\n\n'
          '🌡️ **Types of thermometers / प्रकार:**\n'
          '• Digital thermometer (oral/axillary) — recommended, accurate\n'
          '• Ear (tympanic) thermometer — fast, good for children\n'
          '• Forehead (infrared) — quick screening, less accurate\n'
          '• 🚫 Mercury thermometers — NOT recommended (toxic if broken)\n\n'
          '📋 **How to use (oral) / कैसे उपयोग करें:**\n'
          '1. Wait 30 min after eating/drinking hot/cold\n'
          '2. Place tip under tongue, close mouth\n'
          '3. Keep for ~30 seconds (digital) until beep\n'
          '4. Read and record the temperature\n\n'
          '📋 **Axillary (armpit) — for children:**\n'
          '1. Place tip in armpit, hold arm close to body\n'
          '2. Keep for 1 minute (digital)\n'
          '3. Add 0.5°C to get approximate oral equivalent\n\n'
          '🌡️ **Fever interpretation:**\n'
          '• ✅ Normal | ⚠️ Low-grade: 37.5–38°C | 🔴 Fever: ≥ 38°C\n'
          '• 🆘 High fever: > 39.5°C — see doctor\n\n'
          '_Clean thermometer with alcohol wipe before and after each use. 🧹_';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DEFAULT FALLBACK — when no topic matches
    // ─────────────────────────────────────────────────────────────────────────
    return '🤖 **I\'m here to help! / मैं मदद के लिए यहाँ हूँ!**\n\n'
        '📵 _Offline mode — I can answer 100 common health questions_\n\n'
        'Please describe your symptoms or health question in more detail.\n'
        'हिंदी / नेपाली / भोजपुरी में भी पूछ सकते हैं।\n\n'
        '📋 **I can help with / मैं इनमें मदद कर सकता हूँ:**\n'
        '🚨 Emergency • 🌡️ Fever • 🤕 Headache • 😷 Cough/Cold\n'
        '🩺 Diabetes • 💊 Medicines • 💙 Mental Health • 🤰 Pregnancy\n'
        '🩺 BP • 💨 Asthma • 🦋 Thyroid • 🤢 Stomach • 🧴 Skin\n'
        '👁️ Eyes • 🥗 Nutrition • 👶 Child/Vaccine • 🦴 Joints\n'
        '🩸 Anaemia • 🦷 Dental • 🏃 Exercise • 🧬 Cancer\n'
        '🫀 Cholesterol • 🤧 Flu • 🧪 Typhoid • 🦟 Malaria/Dengue\n'
        '💉 HIV • 🫁 TB • 🧠 Epilepsy • 🫘 Kidney • 🫀 Liver\n'
        '🤱 Breastfeeding • 🧒 Puberty • 👴 Elderly • 💊 Vitamins\n'
        '🌞 Dehydration • 🔥 Burns • 🐍 Snakebite • 🦴 Fracture\n'
        '😴 Fatigue • 🤧 Sinusitis • 💧 ORS • 🏥 First Aid • 🦠 COVID\n'
        '🩸 Menstrual • 🫀 Palpitations • 🦶 Swollen Feet • 💧 UTI\n'
        '🐔 Chickenpox • 🔴 Measles • 🧴 Scabies • 😫 Back Pain\n'
        '🌀 Vertigo • 👂 Ear • 💩 Constipation • 🩹 Piles • 🐝 Bee Sting\n'
        '🥵 Heat Stroke • 🤢 Food Poisoning • 🚬 Smoking • 🍺 Alcohol\n'
        '⚖️ Obesity • 🧘 Meditation • 🌿 Yoga • 🐕 Dog Bite\n'
        '👶 Newborn Jaundice • 😭 Colic • 🍑 Diaper Rash • 😬 Teething\n'
        '🧩 Autism • 🌟 Down Syndrome • 🩸 Thalassemia • 🩸 Sickle Cell\n'
        '😴 Sleep Apnea • 🫁 COPD • 🩺 Health Checkup • ...and more!\n\n'
        '⚠️ _General information only — always consult a qualified healthcare professional._';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper: build an offline ChatMessageModel
  // ═══════════════════════════════════════════════════════════════════════════
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
