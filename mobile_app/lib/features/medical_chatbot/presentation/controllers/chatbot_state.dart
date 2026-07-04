import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chatbot_settings.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/suggestion.dart';
import '../../domain/entities/voice_state.dart';

enum ChatbotStatus { initial, loading, ready, sending, error }

class ChatbotState {
  final ChatbotStatus status;
  final Conversation? conversation;
  final List<Suggestion> suggestions;
  final List<Conversation> history;
  final ChatbotSettings? settings;
  final VoiceState voiceState;
  final String? errorMessage;

  const ChatbotState({
    this.status = ChatbotStatus.initial,
    this.conversation,
    this.suggestions = const [],
    this.history = const [],
    this.settings,
    this.voiceState = const VoiceState(),
    this.errorMessage,
  });

  List<ChatMessage> get messages => conversation?.messages ?? const [];
  bool get isBusy =>
      status == ChatbotStatus.loading || status == ChatbotStatus.sending;

  ChatbotState copyWith({
    ChatbotStatus? status,
    Conversation? conversation,
    List<Suggestion>? suggestions,
    List<Conversation>? history,
    ChatbotSettings? settings,
    VoiceState? voiceState,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatbotState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      suggestions: suggestions ?? this.suggestions,
      history: history ?? this.history,
      settings: settings ?? this.settings,
      voiceState: voiceState ?? this.voiceState,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
