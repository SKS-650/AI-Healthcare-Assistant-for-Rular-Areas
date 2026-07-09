import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';
import '../../data/repositories/chatbot_repository_impl.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../../domain/usecases/get_suggestions.dart';
import '../../domain/usecases/load_chat_history.dart';
import '../../domain/usecases/load_conversation.dart';
import '../../domain/usecases/save_chat_history.dart';
import '../../domain/usecases/send_dummy_message.dart';
import '../controllers/chatbot_controller.dart';
import '../controllers/chatbot_state.dart';

final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  // Pass the shared auth repository so the chatbot can read the access token
  // and use the automatic refresh logic.
  final authRepo =
      ref.watch(authRepositoryProvider) as AuthenticationRepositoryImpl;
  return ChatbotRepositoryImpl(authRepo);
});

final chatbotControllerProvider =
    StateNotifierProvider<ChatbotController, ChatbotState>((ref) {
  final repository = ref.watch(chatbotRepositoryProvider);
  return ChatbotController(
    loadConversation: LoadConversation(repository),
    sendDummyMessage: SendDummyMessage(repository),
    getSuggestions: GetSuggestions(repository),
    loadChatHistory: LoadChatHistory(repository),
    saveChatHistory: SaveChatHistory(repository),
    repository: repository,
  );
});
