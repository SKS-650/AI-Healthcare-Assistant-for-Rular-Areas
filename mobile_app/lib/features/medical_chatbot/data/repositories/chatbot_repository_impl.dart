import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';
import '../../../../constants/api_constants.dart';
import '../../../authentication/data/repositories/authentication_repository_impl.dart';
import '../../../authentication/presentation/providers/authentication_provider.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chatbot_settings.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/suggestion.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_dummy_data.dart';
import '../models/chat_message_model.dart';
import '../models/chatbot_settings_model.dart';
import '../models/conversation_model.dart';
import '../models/suggestion_model.dart';

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

  Map<String, String> _headers() {
    final h = <String, String>{'Content-Type': 'application/json'};
    final t = _token;
    if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    return h;
  }

  // ── ChatbotRepository interface ──────────────────────────────────────────

  @override
  Future<Conversation> loadConversation() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _conversation;
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

        final responseText = data['response']?.toString()
            ?? data['message']?.toString()
            ?? data['content']?.toString()
            ?? 'I received your message but could not generate a response. Please try again.';

        return ChatMessageModel(
          id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
          text: responseText,
          sender: ChatSender.bot,
          createdAt: DateTime.now(),
        );
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
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_history);
  }

  @override
  Future<void> saveChatHistory(Conversation conversation) async {
    _conversation = ConversationModel(
      id: conversation.id,
      title: conversation.title,
      messages: conversation.messages,
      updatedAt: conversation.updatedAt,
    );
    final existingIndex = _history.indexWhere(
      (item) => item.id == conversation.id,
    );
    if (existingIndex >= 0) {
      _history[existingIndex] = conversation;
    } else {
      _history.insert(0, conversation);
    }
  }

  @override
  Future<ChatbotSettings> loadSettings() async {
    return _settings;
  }

  @override
  Future<ChatbotSettings> saveSettings(ChatbotSettings settings) async {
    _settings = ChatbotSettingsModel.fromEntity(settings);
    return _settings;
  }
}
