// ignore_for_file: prefer_initializing_formals

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_message_model.dart';
import '../../data/models/chatbot_settings_model.dart';
import '../../data/models/conversation_model.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chatbot_settings.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/suggestion.dart';
import '../../domain/entities/voice_state.dart';
import '../../domain/usecases/get_suggestions.dart';
import '../../domain/usecases/load_chat_history.dart';
import '../../domain/usecases/load_conversation.dart';
import '../../domain/usecases/save_chat_history.dart';
import '../../domain/usecases/send_dummy_message.dart';
import '../../domain/repositories/chatbot_repository.dart';
import 'chatbot_state.dart';

class ChatbotController extends StateNotifier<ChatbotState> {
  final LoadConversation _loadConversation;
  final SendDummyMessage _sendDummyMessage;
  final GetSuggestions _getSuggestions;
  final LoadChatHistory _loadChatHistory;
  final SaveChatHistory _saveChatHistory;
  final ChatbotRepository _repository;

  ChatbotController({
    required LoadConversation loadConversation,
    required SendDummyMessage sendDummyMessage,
    required GetSuggestions getSuggestions,
    required LoadChatHistory loadChatHistory,
    required SaveChatHistory saveChatHistory,
    required ChatbotRepository repository,
  }) : _loadConversation = loadConversation,
       _sendDummyMessage = sendDummyMessage,
       _getSuggestions = getSuggestions,
       _loadChatHistory = loadChatHistory,
       _saveChatHistory = saveChatHistory,
       _repository = repository,
       super(const ChatbotState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: ChatbotStatus.loading, clearError: true);
    try {
      final results = await Future.wait<dynamic>([
        _loadConversation(),
        _getSuggestions(),
        _loadChatHistory(),
        _repository.loadSettings(),
      ]);
      state = state.copyWith(
        status: ChatbotStatus.ready,
        conversation: results[0] as Conversation,
        suggestions: (results[1] as List).cast<Suggestion>(),
        history: (results[2] as List).cast<Conversation>(),
        settings: results[3] as ChatbotSettings,
      );
    } catch (_) {
      state = state.copyWith(
        status: ChatbotStatus.error,
        errorMessage: 'Unable to load the medical chatbot.',
      );
    }
  }

  Future<void> sendMessage(String text, {bool isVoiceMessage = false}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isBusy) return;

    final current = state.conversation;
    if (current == null) return;

    final userMessage = ChatMessageModel(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      text: trimmed,
      sender: ChatSender.user,
      createdAt: DateTime.now(),
      isVoiceMessage: isVoiceMessage,
    );
    final withUserMessage = _appendMessage(current, userMessage);

    state = state.copyWith(
      status: ChatbotStatus.sending,
      conversation: withUserMessage,
      clearError: true,
    );

    try {
      final botMessage = await _sendDummyMessage(trimmed);
      final updated = _appendMessage(withUserMessage, botMessage);
      state = state.copyWith(
        status: ChatbotStatus.ready,
        conversation: updated,
      );
      if (state.settings?.saveHistory ?? true) {
        await _saveChatHistory(updated);
        await refreshHistory();
      }
    } catch (_) {
      state = state.copyWith(
        status: ChatbotStatus.error,
        errorMessage: 'Could not send your message. Please try again.',
      );
    }
  }

  Future<void> refreshHistory() async {
    final history = await _loadChatHistory();
    state = state.copyWith(history: history);
  }

  Future<void> updateSettings(ChatbotSettings settings) async {
    final saved = await _repository.saveSettings(settings);
    state = state.copyWith(settings: saved);
  }

  Future<void> updateLanguage(Language language) {
    final current = state.settings ?? ChatbotSettings(language: language);
    return updateSettings(
      ChatbotSettingsModel.fromEntity(current).copyWith(language: language),
    );
  }

  void toggleListening() {
    final current = state.voiceState;
    state = state.copyWith(
      voiceState: VoiceState(
        isListening: !current.isListening,
        isRecording: !current.isRecording,
        isPlaying: current.isPlaying,
        transcript: current.isListening
            ? current.transcript
            : 'I have fever and cough',
      ),
    );
  }

  void clearTranscript() {
    state = state.copyWith(voiceState: const VoiceState());
  }

  ConversationModel _appendMessage(
    Conversation conversation,
    ChatMessage message,
  ) {
    final title =
        conversation.messages.length <= 1 && message.sender == ChatSender.user
        ? _titleFromMessage(message.text)
        : conversation.title;
    return ConversationModel(
      id: conversation.id,
      title: title,
      messages: [...conversation.messages, message],
      updatedAt: DateTime.now(),
    );
  }

  String _titleFromMessage(String text) {
    if (text.length <= 32) return text;
    return '${text.substring(0, 29)}...';
  }
}
