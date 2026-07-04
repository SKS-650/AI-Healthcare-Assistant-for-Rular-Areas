import '../entities/chat_message.dart';
import '../repositories/chatbot_repository.dart';

class SendDummyMessage {
  final ChatbotRepository repository;

  const SendDummyMessage(this.repository);

  Future<ChatMessage> call(String message) {
    return repository.sendDummyMessage(message);
  }
}
