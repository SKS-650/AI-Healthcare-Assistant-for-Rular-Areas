import '../entities/conversation.dart';
import '../repositories/chatbot_repository.dart';

class LoadChatHistory {
  final ChatbotRepository repository;

  const LoadChatHistory(this.repository);

  Future<List<Conversation>> call() {
    return repository.loadChatHistory();
  }
}
