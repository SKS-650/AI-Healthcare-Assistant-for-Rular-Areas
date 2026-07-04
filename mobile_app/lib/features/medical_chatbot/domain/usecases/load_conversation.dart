import '../entities/conversation.dart';
import '../repositories/chatbot_repository.dart';

class LoadConversation {
  final ChatbotRepository repository;

  const LoadConversation(this.repository);

  Future<Conversation> call() {
    return repository.loadConversation();
  }
}
