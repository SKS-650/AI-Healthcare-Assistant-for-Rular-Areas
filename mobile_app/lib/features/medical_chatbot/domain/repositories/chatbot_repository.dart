import '../entities/chat_message.dart';
import '../entities/chatbot_settings.dart';
import '../entities/conversation.dart';
import '../entities/suggestion.dart';

abstract class ChatbotRepository {
  // ── Conversation CRUD ────────────────────────────────────────────────────
  Future<Conversation> loadConversation();
  Future<void> selectConversation(Conversation conversation);
  Future<ChatMessage> sendDummyMessage(String message);
  Future<List<Suggestion>> getSuggestions();
  Future<List<Conversation>> loadChatHistory();
  Future<void> saveChatHistory(Conversation conversation);

  /// Delete a specific conversation (local + backend).
  Future<void> deleteConversation(String conversationId);

  /// Clear all conversation history (local + backend).
  Future<void> clearAllHistory();

  /// Reset the active conversation to a fresh empty one.
  Future<void> startNewConversation();

  // ── Settings ─────────────────────────────────────────────────────────────
  Future<ChatbotSettings> loadSettings();
  Future<ChatbotSettings> saveSettings(ChatbotSettings settings);
}
