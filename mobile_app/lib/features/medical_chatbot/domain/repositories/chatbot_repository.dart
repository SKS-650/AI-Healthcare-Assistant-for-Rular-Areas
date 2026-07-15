import '../entities/chat_message.dart';
import '../entities/chatbot_settings.dart';
import '../entities/conversation.dart';
import '../entities/suggestion.dart';

abstract class ChatbotRepository {
  Future<Conversation> loadConversation();
  Future<void> selectConversation(Conversation conversation);
  Future<ChatMessage> sendDummyMessage(String message);
  Future<List<Suggestion>> getSuggestions();
  Future<List<Conversation>> loadChatHistory();
  Future<void> saveChatHistory(Conversation conversation);
  Future<ChatbotSettings> loadSettings();
  Future<ChatbotSettings> saveSettings(ChatbotSettings settings);
}
