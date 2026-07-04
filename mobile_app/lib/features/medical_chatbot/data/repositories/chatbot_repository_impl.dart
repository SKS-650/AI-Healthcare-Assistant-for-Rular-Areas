import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chatbot_settings.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/suggestion.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_dummy_data.dart';
import '../models/chatbot_settings_model.dart';
import '../models/conversation_model.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  Conversation _conversation = ChatbotDummyData.initialConversation();
  final List<Conversation> _history = ChatbotDummyData.initialHistory();
  ChatbotSettings _settings = ChatbotDummyData.settings;

  @override
  Future<Conversation> loadConversation() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _conversation;
  }

  @override
  Future<ChatMessage> sendDummyMessage(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return ChatbotDummyData.botMessageFor(message);
  }

  @override
  Future<List<Suggestion>> getSuggestions() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return ChatbotDummyData.suggestions;
  }

  @override
  Future<List<Conversation>> loadChatHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_history);
  }

  @override
  Future<void> saveChatHistory(Conversation conversation) async {
    _conversation = ConversationModel(
      id: conversation.id,
      title: conversation.title,
      messages: conversation.messages,
      updatedAt: conversation.updatedAt,
    );
    final existingIndex = _history.indexWhere(
      (item) => item.id == conversation.id,
    );
    if (existingIndex >= 0) {
      _history[existingIndex] = conversation;
    } else {
      _history.insert(0, conversation);
    }
  }

  @override
  Future<ChatbotSettings> loadSettings() async {
    return _settings;
  }

  @override
  Future<ChatbotSettings> saveSettings(ChatbotSettings settings) async {
    _settings = ChatbotSettingsModel.fromEntity(settings);
    return _settings;
  }
}
