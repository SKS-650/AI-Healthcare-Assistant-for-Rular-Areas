import '../entities/conversation.dart';
import '../repositories/chatbot_repository.dart';

class SaveChatHistory {
  final ChatbotRepository repository;

  const SaveChatHistory(this.repository);

  Future<void> call(Conversation conversation) {
    return repository.saveChatHistory(conversation);
  }
}
