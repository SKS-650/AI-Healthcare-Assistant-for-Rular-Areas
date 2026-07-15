import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../../constants/api_constants.dart';
import '../../../../core/local_db/local_db_service.dart';
import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chatbot_settings.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/suggestion.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_dummy_data.dart';
import '../models/chat_message_model.dart';
import '../models/chatbot_settings_model.dart';
import '../models/conversation_model.dart';

/// Production implementation that calls the backend chatbot API.
/// Falls back to local dummy data for non-critical operations (suggestions,
/// history) when the backend is unavailable.
class ChatbotRepositoryImpl implements ChatbotRepository {
  /// The auth repository is needed to read the access token.
  /// Passed in via the provider so we don't create a second instance.
  final AuthenticationRepositoryImpl _authRepo;

  Conversation _conversation = ChatbotDummyData.initialConversation();
  final List<Conversation> _history = [];
  ChatbotSettings _settings = ChatbotDummyData.settings;

  // Track the current backend conversation id (null = not started yet)
  String? _backendConversationId;

  ChatbotRepositoryImpl(this._authRepo);

  // ── Auth helpers ─────────────────────────────────────────────────────────

  String? get _token => _authRepo.accessToken;

  // ── ChatbotRepository interface ──────────────────────────────────────────

  @override
  Future<Conversation> loadConversation() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _conversation;
  }

  @override
  Future<void> selectConversation(Conversation conversation) async {
    _conversation = ConversationModel(
      id:       conversation.id,
      title:    conversation.title,
      messages: conversation.messages,
      updatedAt: conversation.updatedAt,
    );
    _backendConversationId = null; // reset backend session for the new conversation
  }

  /// Send a message to the real backend `/api/v1/chatbot/chat` endpoint.
  /// On any network / auth failure falls back to local dummy response so
  /// the UI never crashes.
  @override
  Future<ChatMessage> sendDummyMessage(String message) async {
    // If user is a guest (no token) use local fallback immediately
    if (_token == null || _token!.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return ChatbotDummyData.botMessageFor(message);
    }

    try {
      final body = <String, dynamic>{
        'message': message,
        'language': _settings.language.code,
      };
      if (_backendConversationId != null) {
        body['conversation_id'] = _backendConversationId;
      }

      final response = await _authRepo
          .authenticatedRequest(
            (headers) => http
                .post(
                  Uri.parse('${ApiConfig.baseUrl}${ApiConstants.chatbotChatPath}'),
                  headers: headers,
                  body: jsonEncode(body),
                )
                .timeout(const Duration(seconds: 30)),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Save the backend conversation ID for follow-up messages
        final convId = data['conversation_id']?.toString();
        if (convId != null && convId.isNotEmpty) {
          _backendConversationId = convId;
        }

        return ChatMessageModel.fromBackendResponse(data);
      }

      // 401 after retry means session is fully expired — prompt re-login
      if (response.statusCode == 401) {
        return ChatMessageModel(
          id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
          text: 'Your session has expired. Please log in again to continue chatting with the AI assistant.',
          sender: ChatSender.bot,
          createdAt: DateTime.now(),
        );
      }

      // Any other error: fall back to local response
      return ChatbotDummyData.botMessageFor(message);
    } catch (_) {
      // Network error: fall back gracefully
      return ChatbotDummyData.botMessageFor(message);
    }
  }

  @override
  Future<List<Suggestion>> getSuggestions() async {
    // Suggestions are static for now; backend endpoint not yet implemented
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return ChatbotDummyData.suggestions;
  }

  @override
  Future<List<Conversation>> loadChatHistory() async {
    // Try local DB first, fall back to in-memory
    try {
      final persisted = await LocalDbService.instance.loadConversations();
      if (persisted.isNotEmpty) {
        _history
          ..clear()
          ..addAll(persisted);
        return List.unmodifiable(persisted);
      }
    } catch (_) {}
    return List.unmodifiable(_history);
  }

  @override
  Future<void> saveChatHistory(Conversation conversation) async {
    final model = ConversationModel(
      id:        conversation.id,
      title:     conversation.title,
      messages:  conversation.messages,
      updatedAt: conversation.updatedAt,
    );
    _conversation = model;

    final existingIndex =
        _history.indexWhere((item) => item.id == conversation.id);
    if (existingIndex >= 0) {
      _history[existingIndex] = model;
    } else {
      _history.insert(0, model);
    }

    // Persist to Hive + SQLite
    try {
      await LocalDbService.instance.saveConversation(model);
      await LocalDbService.instance.saveMessages(
        conversation.id,
        conversation.messages,
      );
    } catch (_) {}
  }

  @override
  Future<ChatbotSettings> loadSettings() async {
    final lang = LocalDbService.instance.getSetting<String>('language', defaultValue: 'en') ?? 'en';
    final tts  = LocalDbService.instance.getSetting<bool>('tts_enabled', defaultValue: true) ?? true;
    final save = LocalDbService.instance.getSetting<bool>('save_history', defaultValue: true) ?? true;
    _settings = ChatbotSettingsModel(
      language:             Language.fromCode(lang),
      voiceResponsesEnabled: tts,
      saveHistory:          save,
    );
    return _settings;
  }

  @override
  Future<ChatbotSettings> saveSettings(ChatbotSettings settings) async {
    _settings = ChatbotSettingsModel.fromEntity(settings);
    await LocalDbService.instance.saveSetting('language',    settings.language.code);
    await LocalDbService.instance.saveSetting('tts_enabled', settings.voiceResponsesEnabled);
    await LocalDbService.instance.saveSetting('save_history', settings.saveHistory);
    return _settings;
  }
}
