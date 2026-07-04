import '../models/chat_message_model.dart';
import '../models/chatbot_settings_model.dart';
import '../models/conversation_model.dart';
import '../models/language_model.dart';
import '../models/suggestion_model.dart';
import '../../domain/entities/chat_message.dart';

class ChatbotDummyData {
  static const languages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
    LanguageModel(code: 'ne', name: 'Nepali', nativeName: 'Nepali'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'Hindi'),
  ];

  static const settings = ChatbotSettingsModel(
    language: LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
  );

  static final welcomeMessage = ChatMessageModel(
    id: 'message-welcome',
    text:
        'Hi, I am your medical assistant. Tell me your symptoms and I can share general guidance. For emergencies, contact a doctor or local emergency service immediately.',
    sender: ChatSender.bot,
    createdAt: DateTime.now(),
  );

  static final suggestions = [
    const SuggestionModel(
      id: 's1',
      text: 'I have fever and cough',
      category: 'Symptoms',
    ),
    const SuggestionModel(
      id: 's2',
      text: 'What should I do for headache?',
      category: 'Care',
    ),
    const SuggestionModel(
      id: 's3',
      text: 'When should I visit a doctor?',
      category: 'Safety',
    ),
    const SuggestionModel(
      id: 's4',
      text: 'How can I prevent flu?',
      category: 'Prevention',
    ),
  ];

  static ConversationModel initialConversation() {
    return ConversationModel(
      id: 'conversation-current',
      title: 'Current consultation',
      messages: [welcomeMessage],
      updatedAt: DateTime.now(),
    );
  }

  static List<ConversationModel> initialHistory() {
    return [
      ConversationModel(
        id: 'history-1',
        title: 'Fever and cough',
        messages: [
          welcomeMessage,
          ChatMessageModel(
            id: 'history-1-user',
            text: 'I have fever and cough',
            sender: ChatSender.user,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ChatMessageModel(
            id: 'history-1-bot',
            text: responseFor('I have fever and cough'),
            sender: ChatSender.bot,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static String responseFor(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('fever') || lower.contains('cough')) {
      return 'Fever and cough can happen with flu, cold, COVID, or other infections. Rest, drink fluids, and monitor temperature. Seek care urgently for breathing difficulty, chest pain, confusion, dehydration, or persistent high fever.';
    }

    if (lower.contains('headache') || lower.contains('migraine')) {
      return 'For headache, rest in a quiet room, hydrate, and avoid bright screens. Seek urgent care for sudden severe headache, weakness, fever with neck stiffness, confusion, or vision loss.';
    }

    if (lower.contains('doctor') || lower.contains('emergency')) {
      return 'Visit a doctor if symptoms are severe, worsening, unusual for you, or lasting longer than expected. Emergency warning signs include breathing trouble, chest pain, fainting, severe bleeding, or altered consciousness.';
    }

    if (lower.contains('prevent') || lower.contains('flu')) {
      return 'Prevention basics include hand washing, masking when sick, good sleep, hydration, vaccination when available, and avoiding close contact with people who have respiratory symptoms.';
    }

    return 'Thanks for sharing. I can provide general health guidance, but this is not a diagnosis. Please describe your main symptom, duration, severity, age, and any warning signs so I can guide you better.';
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
