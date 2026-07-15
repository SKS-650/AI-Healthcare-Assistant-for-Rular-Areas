import '../models/chat_message_model.dart';
import '../models/chatbot_settings_model.dart';
import '../models/conversation_model.dart';
import '../models/language_model.dart';
import '../models/suggestion_model.dart';
import '../../domain/entities/chat_message.dart';

class ChatbotDummyData {
  // ── All 4 primary languages + 4 extras — must match Language.all codes ───
  static const languages = [
    LanguageModel(code: 'en',  name: 'English',  nativeName: 'English',  flag: '🇬🇧'),
    LanguageModel(code: 'hi',  name: 'Hindi',    nativeName: 'हिंदी',    flag: '🇮🇳'),
    LanguageModel(code: 'ne',  name: 'Nepali',   nativeName: 'नेपाली',   flag: '🇳🇵'),
    LanguageModel(code: 'bho', name: 'Bhojpuri', nativeName: 'भोजपुरी',  flag: '🗣️'),
    LanguageModel(code: 'bn',  name: 'Bengali',  nativeName: 'বাংলা',    flag: '🇧🇩'),
    LanguageModel(code: 'ta',  name: 'Tamil',    nativeName: 'தமிழ்',    flag: '🇮🇳'),
    LanguageModel(code: 'te',  name: 'Telugu',   nativeName: 'తెలుగు',   flag: '🇮🇳'),
    LanguageModel(code: 'mr',  name: 'Marathi',  nativeName: 'मराठी',    flag: '🇮🇳'),
  ];

  static const settings = ChatbotSettingsModel(
    language: LanguageModel(
        code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
  );

  // ── Safe language lookup — never crashes ─────────────────────────────────
  static LanguageModel languageFromCode(String code) {
    return languages.firstWhere(
      (l) => l.code == code,
      orElse: () => languages.first,
    );
  }

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

  // ── Rich suggestion chips ─────────────────────────────────────────────────
  static final suggestions = [
    const SuggestionModel(
        id: 's1', text: '🤒 I have fever and cough',    category: 'Symptoms'),
    const SuggestionModel(
        id: 's2', text: '🤕 What to do for headache?',  category: 'Care'),
    const SuggestionModel(
        id: 's3', text: '💊 What is Paracetamol?',       category: 'Medicine'),
    const SuggestionModel(
        id: 's4', text: '🥗 Foods for diabetes',         category: 'Nutrition'),
    const SuggestionModel(
        id: 's5', text: '🤰 Pregnancy nutrition tips',   category: 'Pregnancy'),
    const SuggestionModel(
        id: 's6', text: '👶 Child vaccination info',     category: 'Child'),
    const SuggestionModel(
        id: 's7', text: '🚨 Heart attack symptoms',      category: 'Emergency'),
    const SuggestionModel(
        id: 's8', text: '🧠 I feel stressed and anxious',category: 'Mental Health'),
  ];

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

  // ── Smart fallback responses ─────────────────────────────────────────────
  static String responseFor(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('fever') || lower.contains('bukhar') ||
        lower.contains('jwaro') || lower.contains('taato')) {
      return '🌡️ **Fever detected in your message.**\n\n'
          'Common causes include flu, cold, COVID-19, or infections.\n\n'
          '**What to do:**\n'
          '• Rest and drink plenty of fluids\n'
          '• Take Paracetamol if temperature > 38.5°C\n'
          '• Use a cool damp cloth on the forehead\n\n'
          '⚠️ **See a doctor immediately if:**\n'
          '• Temperature exceeds 39.5°C\n'
          '• You have difficulty breathing\n'
          '• Fever lasts more than 3 days\n\n'
          '_I\'m an AI assistant — please consult a healthcare professional for diagnosis._';
    }

    if (lower.contains('headache') || lower.contains('sar dard') ||
        lower.contains('टाउको') || lower.contains('migraine')) {
      return '🤕 **Headache guidance:**\n\n'
          '**Immediate relief:**\n'
          '• Rest in a quiet, dark room\n'
          '• Drink 2–3 glasses of water\n'
          '• Apply a cold or warm compress\n'
          '• Avoid screen time\n\n'
          '**Common triggers:** stress, dehydration, lack of sleep, eye strain\n\n'
          '🚨 **Seek emergency care if:**\n'
          '• Sudden severe headache ("thunderclap")\n'
          '• Headache with fever + neck stiffness\n'
          '• Vision loss or weakness\n\n'
          '_Consult a doctor for recurring headaches._';
    }

    if (lower.contains('cough') || lower.contains('khasi') ||
        lower.contains('khansi')) {
      return '😷 **Cough management:**\n\n'
          '• Honey + warm water soothes throat\n'
          '• Stay hydrated (warm fluids help)\n'
          '• Steam inhalation for congestion\n'
          '• Avoid cold drinks and smoke\n\n'
          '⚠️ **See a doctor if:**\n'
          '• Cough lasts more than 2 weeks\n'
          '• Blood in cough\n'
          '• Difficulty breathing\n\n'
          '_Persistent cough may indicate infection or asthma._';
    }

    if (lower.contains('diabetes') || lower.contains('sugar') ||
        lower.contains('madhumeha')) {
      return '🩺 **Diabetes information:**\n\n'
          'Diabetes is a condition where blood sugar levels are too high.\n\n'
          '**Types:**\n'
          '• Type 1 — immune system attacks insulin cells\n'
          '• Type 2 — body doesn\'t use insulin properly (most common)\n\n'
          '**Management:**\n'
          '• Monitor blood sugar regularly\n'
          '• Follow a low-sugar, high-fiber diet\n'
          '• Exercise 30 min/day\n'
          '• Take prescribed medications\n\n'
          '🥗 **Foods to prefer:** vegetables, whole grains, lean protein\n'
          '❌ **Foods to avoid:** sugary drinks, white rice, sweets\n\n'
          '_Always follow your doctor\'s treatment plan._';
    }

    if (lower.contains('paracetamol') || lower.contains('medicine') ||
        lower.contains('tablet') || lower.contains('dawai')) {
      return '💊 **Medicine information:**\n\n'
          'I can provide general information about common medicines.\n\n'
          '**Paracetamol (Acetaminophen):**\n'
          '• Used for: fever, mild to moderate pain\n'
          '• Adult dose: 500mg–1g every 4–6 hours (max 4g/day)\n'
          '• Safe for: children, pregnant women (under guidance)\n'
          '• ⚠️ Avoid with liver disease or alcohol\n\n'
          '**Important:** Always follow your doctor or pharmacist\'s instructions.\n'
          'Never self-medicate for serious conditions.\n\n'
          '_Which medicine would you like to know more about?_';
    }

    if (lower.contains('emergency') || lower.contains('chest pain') ||
        lower.contains('heart') || lower.contains('stroke') ||
        lower.contains('breathing')) {
      return '🚨 **POSSIBLE EMERGENCY**\n\n'
          'Your symptoms may require immediate medical attention.\n\n'
          '**Call emergency services NOW:**\n'
          '• 🇮🇳 India: **108** (Ambulance) | **112**\n'
          '• 🇳🇵 Nepal: **102** (Ambulance) | **100**\n\n'
          '**While waiting:**\n'
          '• Stay calm and keep the person still\n'
          '• Loosen tight clothing\n'
          '• Do NOT give food or water\n\n'
          '⚠️ This AI cannot replace emergency care. **Act immediately.**';
    }

    if (lower.contains('stress') || lower.contains('anxious') ||
        lower.contains('depression') || lower.contains('lonely') ||
        lower.contains('sad') || lower.contains('mental')) {
      return '💙 **Mental health support:**\n\n'
          'It\'s okay to feel this way. You\'re not alone.\n\n'
          '**Immediate coping strategies:**\n'
          '• Take 5 slow deep breaths\n'
          '• Go for a short walk in fresh air\n'
          '• Talk to someone you trust\n'
          '• Limit news and social media\n\n'
          '**Professional support:**\n'
          '• iCall (India): 9152987821\n'
          '• Vandrevala Foundation: 1860-2662-345\n\n'
          '_Your mental health matters just as much as physical health._\n'
          'Would you like to talk more about what you\'re feeling?';
    }

    if (lower.contains('pregnancy') || lower.contains('pregnant') ||
        lower.contains('garbhwati') || lower.contains('prasav')) {
      return '🤰 **Pregnancy health guidance:**\n\n'
          '**Essential nutrition:**\n'
          '• Folic acid (first trimester — prevents birth defects)\n'
          '• Iron-rich foods: spinach, lentils, meat\n'
          '• Calcium: milk, yogurt, paneer\n'
          '• Stay hydrated: 8–10 glasses water/day\n\n'
          '**Warning signs — see doctor immediately:**\n'
          '• Severe abdominal pain\n'
          '• Heavy bleeding\n'
          '• Severe headache + swollen hands/face\n'
          '• Baby not moving\n\n'
          '_Regular prenatal checkups are very important._';
    }

    if (lower.contains('hypertension') || lower.contains('blood pressure') ||
        lower.contains('bp high') || lower.contains('dawab')) {
      return '🩺 **High Blood Pressure (Hypertension)**\n\n'
          'Normal BP: below 120/80 mmHg\nHigh BP: 140/90 mmHg or above\n\n'
          '**Lifestyle changes:**\n'
          '• 🧂 Reduce salt (<5g/day)\n'
          '• 🏃 Exercise 30 min/day\n'
          '• 🚫 Limit alcohol & smoking\n'
          '• 😴 Get 7-8 hours sleep\n'
          '• 🥗 DASH diet (fruits, vegetables, low-fat dairy)\n\n'
          '⚠️ **Warning signs:** severe headache, blurred vision, chest pain → **Call 108 immediately!**\n\n'
          '_Take prescribed medications regularly. Never stop without doctor advice._ 🩺';
    }

    if (lower.contains('asthma') || lower.contains('inhaler') ||
        lower.contains('wheezing') || lower.contains('dam')) {
      return '💨 **Asthma Management**\n\n'
          '**During an asthma attack:**\n'
          '• Sit upright, stay calm\n'
          '• Use reliever inhaler (usually blue)\n'
          '• Take 1 puff every minute for up to 10 puffs\n'
          '• Call 108 if no improvement in 10 minutes\n\n'
          '**Daily prevention:**\n'
          '• Avoid triggers: dust, pollen, smoke, cold air, pets\n'
          '• Use preventer inhaler as prescribed\n'
          '• Keep home well-ventilated\n\n'
          '_Always carry your reliever inhaler._ 🩺';
    }

    if (lower.contains('नमस्ते') || lower.contains('namaskar') ||
        lower.contains('namaste') || lower.contains('hello') ||
        lower.contains('hi ') || lower == 'hi') {
      return '🤖 **Namaste / Hello! 😊**\n\n'
          'I am your AI Medical Assistant! I speak:\n'
          '• 🇬🇧 **English**\n'
          '• 🇮🇳 **हिंदी** (Hindi)\n'
          '• 🇳🇵 **नेपाली** (Nepali)\n'
          '• 🗣️ **भोजपुरी** (Bhojpuri)\n\n'
          'How can I help you today? You can:\n'
          '• 💬 Type your question\n'
          '• 🎙️ Use voice chat\n'
          '• 🌍 Ask in any of the 4 languages\n\n'
          '_What health question do you have?_ 🩺';
    }

    return '🤖 **I\'m here to help with your health questions!**\n\n'
        'I can assist with:\n'
        '• 🤒 Symptoms and diseases\n'
        '• 💊 Medicine information\n'
        '• 🥗 Nutrition and diet advice\n'
        '• 🏃 Exercise recommendations\n'
        '• 🤰 Pregnancy guidance\n'
        '• 👶 Child healthcare\n'
        '• 🚨 Emergency guidance\n\n'
        'Please describe your symptoms or health question in detail so I can help you better.\n\n'
        '⚠️ _This AI provides general health information only. Always consult a qualified healthcare professional for medical advice._';
  }

  static ChatMessageModel botMessageFor(String message) {
    return ChatMessageModel(
      id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
      text: responseFor(message),
      sender: ChatSender.bot,
      createdAt: DateTime.now(),
    );
  }
}
