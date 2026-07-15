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

  // Language selected in UI (ISO 639-1 or BCP-47 tag)
  final String selectedLanguage;

  // Whether the last response came from online (LLM) or offline (FAISS)
  final bool isOnlineMode;

  // Latest bot response metadata
  final bool lastResponseWasEmergency;
  final List<String> followUpQuestions;
  final String? lastIntent;

  const ChatbotState({
    this.status = ChatbotStatus.initial,
    this.conversation,
    this.suggestions = const [],
    this.history = const [],
    this.settings,
    this.voiceState = const VoiceState(),
    this.errorMessage,
    this.selectedLanguage = 'en',
    this.isOnlineMode = true,
    this.lastResponseWasEmergency = false,
    this.followUpQuestions = const [],
    this.lastIntent,
  });

  List<ChatMessage> get messages => conversation?.messages ?? const [];
  bool get isBusy =>
      status == ChatbotStatus.loading || status == ChatbotStatus.sending;

  ChatbotState copyWith({
    ChatbotStatus?    status,
    Conversation?     conversation,
    List<Suggestion>? suggestions,
    List<Conversation>? history,
    ChatbotSettings?  settings,
    VoiceState?       voiceState,
    String?           errorMessage,
    String?           selectedLanguage,
    bool?             isOnlineMode,
    bool?             lastResponseWasEmergency,
    List<String>?     followUpQuestions,
    String?           lastIntent,
    bool              clearError = false,
  }) {
    return ChatbotState(
      status:                    status                    ?? this.status,
      conversation:              conversation              ?? this.conversation,
      suggestions:               suggestions               ?? this.suggestions,
      history:                   history                   ?? this.history,
      settings:                  settings                  ?? this.settings,
      voiceState:                voiceState                ?? this.voiceState,
      errorMessage:              clearError ? null         : errorMessage ?? this.errorMessage,
      selectedLanguage:          selectedLanguage          ?? this.selectedLanguage,
      isOnlineMode:              isOnlineMode              ?? this.isOnlineMode,
      lastResponseWasEmergency:  lastResponseWasEmergency  ?? this.lastResponseWasEmergency,
      followUpQuestions:         followUpQuestions         ?? this.followUpQuestions,
      lastIntent:                lastIntent                ?? this.lastIntent,
    );
  }
}
