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

/// Production implementation that calls the FastAPI → Gemini backend.
///
/// Flow:
///   Flutter  →  POST /api/v1/chatbot/chat  →  FastAPI  →  Gemini  →  FastAPI  →  Flutter
///
/// The app NEVER contacts Gemini directly — every AI request goes through the
/// backend.  Dummy data is only used for static UI elements (suggestions,
/// quick starters) and as an offline safety-net when the network is
/// completely unreachable.
class ChatbotRepositoryImpl implements ChatbotRepository {
  final AuthenticationRepositoryImpl _authRepo;

  Conversation _conversation = ChatbotDummyData.initialConversation();
  final List<Conversation> _history = [];
  ChatbotSettings _settings = ChatbotDummyData.settings;

  /// Backend conversation UUID — persisted across messages in the same session
  /// so Gemini receives full conversation history.
  String? _backendConversationId;

  ChatbotRepositoryImpl(this._authRepo);

  // ── Auth helpers ─────────────────────────────────────────────────────────

  String? get _token => _authRepo.accessToken;

  // ── ChatbotRepository interface ──────────────────────────────────────────

  @override
  Future<Conversation> loadConversation() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _conversation;
  }

  @override
  Future<void> selectConversation(Conversation conversation) async {
    _conversation = ConversationModel(
      id: conversation.id,
      title: conversation.title,
      messages: conversation.messages,
      updatedAt: conversation.updatedAt,
    );
    // Reset so the next message continues from this conversation on the backend.
    _backendConversationId = conversation.id.startsWith('conv-')
        ? null   // local-only id — start fresh on backend
        : conversation.id;
  }

  // ── Core: send message to FastAPI → Gemini ───────────────────────────────

  @override
  Future<ChatMessage> sendDummyMessage(String message) async {
    // Guest users: show a prompt to log in
    if (_token == null || _token!.isEmpty) {
      return ChatMessageModel(
        id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
        text: '🔐 **Please log in to use the AI Medical Assistant.**\n\n'
            'Create a free account or sign in to get AI-powered health guidance.',
        sender: ChatSender.bot,
        createdAt: DateTime.now(),
        isOnlineMode: false,
      );
    }

    // Build request body
    final body = <String, dynamic>{
      'message': message,
      'language': _settings.language.code,
    };
    if (_backendConversationId != null) {
      body['conversation_id'] = _backendConversationId;
    }

    try {
      final response = await _authRepo.authenticatedRequest(
        (headers) => http
            .post(
              Uri.parse('${ApiConfig.baseUrl}${ApiConstants.chatbotChatPath}'),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 40)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Persist the backend conversation UUID for follow-up messages
        final convId = data['conversation_id']?.toString();
        if (convId != null && convId.isNotEmpty) {
          _backendConversationId = convId;
        }

        return ChatMessageModel.fromBackendResponse(data);
      }

      // Session expired
      if (response.statusCode == 401) {
        return _errorMessage(
          '🔐 Your session has expired. Please log in again to continue.',
        );
      }

      // Server-side AI error (e.g. quota exceeded, bad key)
      if (response.statusCode == 502 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        String detail = 'The AI service is temporarily unavailable.';
        try {
          final err = jsonDecode(response.body) as Map<String, dynamic>;
          detail = err['detail']?.toString() ?? detail;
        } catch (_) {}
        return _errorMessage('⚠️ $detail\n\nPlease try again in a moment.');
      }

      // Any other HTTP error
      return _errorMessage(
        '⚠️ Server returned status ${response.statusCode}. '
        'Please try again.',
      );
    } on http.ClientException catch (e) {
      return _errorMessage(
        '📵 Could not reach the server.\n\n'
        'Please check your internet connection.\n\n'
        '_Error: ${e.message}_',
      );
    } catch (e) {
      // Catch-all — never crash the UI
      return _errorMessage(
        '❌ An unexpected error occurred.\n\n'
        'Please try again. If the problem persists, restart the app.',
      );
    }
  }

  // ── Suggestions (static) ─────────────────────────────────────────────────

  @override
  Future<List<Suggestion>> getSuggestions() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return ChatbotDummyData.suggestions;
  }

  // ── History (local + Hive persistence) ───────────────────────────────────

  @override
  Future<List<Conversation>> loadChatHistory() async {
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
      id: conversation.id,
      title: conversation.title,
      messages: conversation.messages,
      updatedAt: conversation.updatedAt,
    );
    _conversation = model;

    final idx = _history.indexWhere((c) => c.id == conversation.id);
    if (idx >= 0) {
      _history[idx] = model;
    } else {
      _history.insert(0, model);
    }

    try {
      await LocalDbService.instance.saveConversation(model);
      await LocalDbService.instance.saveMessages(
        conversation.id,
        conversation.messages,
      );
    } catch (_) {}
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  @override
  Future<ChatbotSettings> loadSettings() async {
    final lang =
        LocalDbService.instance.getSetting<String>('language', defaultValue: 'en') ?? 'en';
    final tts =
        LocalDbService.instance.getSetting<bool>('tts_enabled', defaultValue: true) ?? true;
    final save =
        LocalDbService.instance.getSetting<bool>('save_history', defaultValue: true) ?? true;
    _settings = ChatbotSettingsModel(
      language: Language.fromCode(lang),
      voiceResponsesEnabled: tts,
      saveHistory: save,
    );
    return _settings;
  }

  @override
  Future<ChatbotSettings> saveSettings(ChatbotSettings settings) async {
    _settings = ChatbotSettingsModel.fromEntity(settings);
    await LocalDbService.instance.saveSetting('language', settings.language.code);
    await LocalDbService.instance.saveSetting('tts_enabled', settings.voiceResponsesEnabled);
    await LocalDbService.instance.saveSetting('save_history', settings.saveHistory);
    return _settings;
  }

  // ── Conversation management ───────────────────────────────────────────────

  @override
  Future<void> deleteConversation(String conversationId) async {
    _history.removeWhere((c) => c.id == conversationId);

    if (_token == null || _token!.isEmpty) return;
    try {
      await _authRepo.authenticatedRequest(
        (headers) => http
            .delete(
              Uri.parse(
                '${ApiConfig.baseUrl}${ApiConstants.chatbotConversationsPath}/$conversationId',
              ),
              headers: headers,
            )
            .timeout(const Duration(seconds: 15)),
      );
    } catch (_) {}
  }

  @override
  Future<void> clearAllHistory() async {
    _history.clear();

    if (_token == null || _token!.isEmpty) return;
    try {
      await _authRepo.authenticatedRequest(
        (headers) => http
            .delete(
              Uri.parse(
                '${ApiConfig.baseUrl}${ApiConstants.chatbotConversationsPath}',
              ),
              headers: headers,
            )
            .timeout(const Duration(seconds: 15)),
      );
    } catch (_) {}
  }

  @override
  Future<void> startNewConversation() async {
    _backendConversationId = null;
    _conversation = ConversationModel(
      id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Conversation',
      messages: const [],
      updatedAt: DateTime.now(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static ChatMessageModel _errorMessage(String text) => ChatMessageModel(
        id: 'bot-err-${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        sender: ChatSender.bot,
        createdAt: DateTime.now(),
        isOnlineMode: false,
      );
}
