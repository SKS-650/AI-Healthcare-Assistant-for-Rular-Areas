// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final LoadConversation  _loadConversation;
  final SendDummyMessage  _sendDummyMessage;
  final GetSuggestions    _getSuggestions;
  final LoadChatHistory   _loadChatHistory;
  final SaveChatHistory   _saveChatHistory;
  final ChatbotRepository _repository;

  // ── Voice services ────────────────────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts        _tts   = FlutterTts();
  final AudioPlayer       _audio = AudioPlayer();

  bool _sttInitialized = false;

  /// When true the assistant will auto-listen after speaking (Siri mode)
  bool _continuousMode = false;
  Timer? _restartListenTimer;

  ChatbotController({
    required LoadConversation  loadConversation,
    required SendDummyMessage  sendDummyMessage,
    required GetSuggestions    getSuggestions,
    required LoadChatHistory   loadChatHistory,
    required SaveChatHistory   saveChatHistory,
    required ChatbotRepository repository,
  })  : _loadConversation = loadConversation,
        _sendDummyMessage = sendDummyMessage,
        _getSuggestions   = getSuggestions,
        _loadChatHistory  = loadChatHistory,
        _saveChatHistory  = saveChatHistory,
        _repository       = repository,
        super(const ChatbotState()) {
    load();
    _initTts();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

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
        status:           ChatbotStatus.ready,
        conversation:     results[0] as Conversation,
        suggestions:      (results[1] as List).cast<Suggestion>(),
        history:          (results[2] as List).cast<Conversation>(),
        settings:         results[3] as ChatbotSettings,
        selectedLanguage: (results[3] as ChatbotSettings).language.code,
      );
    } catch (_) {
      state = state.copyWith(
        status:       ChatbotStatus.error,
        errorMessage: '⚠️ Unable to load the medical assistant. Tap retry.',
      );
    }
  }

  void _initTts() {
    _tts.setStartHandler(() {
      if (!mounted) return;
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isSpeaking: true));
    });
    _tts.setCompletionHandler(() {
      if (!mounted) return;
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isSpeaking: false));
      // Siri-mode: after speaking, listen again automatically
      if (_continuousMode) {
        _restartListenTimer = Timer(const Duration(milliseconds: 600), () {
          if (mounted && _continuousMode) _startListening();
        });
      }
    });
    _tts.setErrorHandler((_) {
      if (!mounted) return;
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isSpeaking: false));
    });
    _tts.setCancelHandler(() {
      if (!mounted) return;
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isSpeaking: false));
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Language
  // ─────────────────────────────────────────────────────────────────────────

  void updateLanguageCode(String code) {
    state = state.copyWith(selectedLanguage: code);
    final current =
        state.settings ?? const ChatbotSettings(language: Language.english);
    updateSettings(
      ChatbotSettingsModel.fromEntity(current)
          .copyWith(language: Language.fromCode(code)),
    );
  }

  Future<void> updateSettings(ChatbotSettings settings) async {
    final saved = await _repository.saveSettings(settings);
    state =
        state.copyWith(settings: saved, selectedLanguage: saved.language.code);
  }

  Future<void> updateLanguage(Language language) => updateSettings(
        ChatbotSettingsModel.fromEntity(
          state.settings ?? ChatbotSettings(language: language),
        ).copyWith(language: language),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // STT — Siri-style continuous listening
  // ─────────────────────────────────────────────────────────────────────────

  /// Toggle mic on/off.  If [continuous] is true, re-listens after each reply.
  Future<void> toggleListening({bool continuous = false}) async {
    _continuousMode = continuous;
    if (state.voiceState.isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  /// Start a Siri-like continuous conversation session.
  /// The mic opens → you speak → bot responds (voice) → mic opens again.
  Future<void> startContinuousConversation() async {
    _continuousMode = true;
    await _startListening();
  }

  Future<void> stopContinuousConversation() async {
    _continuousMode = false;
    _restartListenTimer?.cancel();
    await _stopListening();
    await _tts.stop();
  }

  Future<void> _startListening() async {
    // Stop TTS before listening (no echo)
    if (state.voiceState.isSpeaking) await _tts.stop();

    if (!_sttInitialized) {
      _sttInitialized = await _speech.initialize(
        onError: (e) {
          if (!mounted) return;
          state = state.copyWith(
            voiceState: state.voiceState.copyWith(
              isListening:  false,
              isRecording:  false,
              clearError:   false,
              errorMessage: '🎙️ Mic error: ${e.errorMsg}',
            ),
          );
          // In continuous mode, retry after a short delay
          if (_continuousMode) {
            _restartListenTimer = Timer(const Duration(seconds: 2), () {
              if (mounted && _continuousMode) _startListening();
            });
          }
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            state = state.copyWith(
              voiceState: state.voiceState.copyWith(
                isListening: false,
                isRecording: false,
              ),
            );
          }
        },
      );
    }

    if (!_sttInitialized) {
      state = state.copyWith(
        voiceState: state.voiceState.copyWith(
          errorMessage: '🎙️ Speech recognition not available on this device.',
        ),
      );
      return;
    }

    final localeId = _sttLocale(state.selectedLanguage);

    state = state.copyWith(
      voiceState: state.voiceState.copyWith(
        isListening: true,
        isRecording: true,
        transcript:  '',
        clearError:  true,
      ),
    );

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        state = state.copyWith(
          voiceState: state.voiceState.copyWith(
            transcript:  result.recognizedWords,
            isListening: !result.finalResult,
            isRecording: !result.finalResult,
          ),
        );
        if (result.finalResult &&
            result.recognizedWords.trim().isNotEmpty) {
          final words = result.recognizedWords.trim();
          sendMessage(words, isVoiceMessage: true);
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              state = state.copyWith(
                voiceState: state.voiceState.copyWith(transcript: ''),
              );
            }
          });
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError:  true,
        listenMode:     stt.ListenMode.dictation,
        localeId:       localeId,
        listenFor:      const Duration(seconds: 60),
        pauseFor:       const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (!mounted) return;
    state = state.copyWith(
      voiceState: state.voiceState.copyWith(
        isListening: false,
        isRecording: false,
      ),
    );
  }

  void clearTranscript() {
    state = state.copyWith(voiceState: const VoiceState());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TTS — speak response aloud (Siri-style)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> speakText(String text, {String? language}) async {
    final lang     = language ?? state.selectedLanguage;
    // Read voiceSpeed from settings (slider range 0.6–1.6, default 1.0)
    // flutter_tts setSpeechRate expects 0.0–1.0, so we scale:
    //   slider 0.6 → tts 0.36,  slider 1.0 → tts 0.50,  slider 1.6 → tts 0.72
    final sliderSpeed = state.settings?.voiceSpeed ?? 1.0;
    // Base rate per language (non-English slightly slower for clarity)
    final baseRate = lang == 'en' ? 0.50 : 0.44;
    // Scale: slider 1.0 = base rate, proportionally faster/slower
    final ttsRate  = (baseRate * sliderSpeed).clamp(0.2, 0.9);

    try {
      await _tts.setLanguage(_ttsLocale(lang));
      await _tts.setSpeechRate(ttsRate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(lang == 'hi' || lang == 'bho' ? 1.05 : 1.0);

      final clean   = _stripMarkdown(text);
      // _stripMarkdown already clips to 900 chars
      final clipped = clean;

      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isSpeaking: true));
      await _tts.speak(clipped);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isSpeaking: false));
    }
  }

  Future<void> stopSpeaking() async {
    _continuousMode = false;
    _restartListenTimer?.cancel();
    await _tts.stop();
    if (!mounted) return;
    state = state.copyWith(
        voiceState: state.voiceState.copyWith(isSpeaking: false));
  }

  /// Play base64 MP3 audio returned by backend TTS endpoint.
  Future<void> playAudioBase64(String base64Audio) async {
    try {
      final bytes = base64Decode(base64Audio);
      if (!mounted) return;
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isPlaying: true));
      await _audio.play(BytesSource(bytes));
      _audio.onPlayerComplete.first.then((_) {
        if (!mounted) return;
        state = state.copyWith(
            voiceState: state.voiceState.copyWith(isPlaying: false));
        // Siri-mode: re-listen after audio completes
        if (_continuousMode) {
          _restartListenTimer =
              Timer(const Duration(milliseconds: 600), () {
            if (mounted && _continuousMode) _startListening();
          });
        }
      });
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isPlaying: false));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Chat
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text,
      {bool isVoiceMessage = false}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isBusy) return;

    final current = state.conversation;
    if (current == null) return;

    // Build user message
    final userMsg = ChatMessageModel(
      id:             'user-${DateTime.now().microsecondsSinceEpoch}',
      text:           trimmed,
      sender:         ChatSender.user,
      createdAt:      DateTime.now(),
      isVoiceMessage: isVoiceMessage,
    );
    final withUser = _appendMessage(current, userMsg);

    state = state.copyWith(
      status:            ChatbotStatus.sending,
      conversation:      withUser,
      clearError:        true,
      followUpQuestions: const [],
    );

    try {
      final botMsg = await _sendDummyMessage(trimmed);

      bool         isEmergency = false;
      List<String> followUps   = const [];
      bool         online      = state.isOnlineMode;
      String?      intent;
      String?      audioB64;

      if (botMsg is ChatMessageModel) {
        isEmergency = botMsg.isEmergency;
        followUps   = botMsg.followUpQuestions;
        online      = botMsg.isOnlineMode;
        intent      = botMsg.intent;
        audioB64    = botMsg.audioBase64;
      }

      final updated = _appendMessage(withUser, botMsg);
      state = state.copyWith(
        status:                   ChatbotStatus.ready,
        conversation:             updated,
        lastResponseWasEmergency: isEmergency,
        followUpQuestions:        followUps,
        isOnlineMode:             online,
        lastIntent:               intent,
      );

      // ── Auto-speak the response (Siri behaviour) ──────────────────────
      final shouldSpeak = isVoiceMessage ||
          (state.settings?.voiceResponsesEnabled ?? true);
      if (shouldSpeak) {
        if (audioB64 != null && audioB64.isNotEmpty) {
          await playAudioBase64(audioB64);
        } else {
          await speakText(botMsg.text, language: state.selectedLanguage);
        }
      }

      // Save history
      if (state.settings?.saveHistory ?? true) {
        await _saveChatHistory(updated);
        await refreshHistory();
      }
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        status:       ChatbotStatus.error,
        errorMessage: '❌ Could not send message. Please try again.',
      );
    }
  }

  Future<void> refreshHistory() async {
    final history = await _loadChatHistory();
    if (!mounted) return;
    state = state.copyWith(history: history);
  }

  /// Delete a single conversation from local history (and backend if online).
  Future<void> deleteConversation(String id) async {
    final newHistory = state.history.where((c) => c.id != id).toList();
    state = state.copyWith(history: newHistory);

    // Best-effort backend delete (non-blocking)
    try {
      await _repository.deleteConversation(id);
    } catch (_) {
      // Silently ignore — local removal is enough for UX
    }
  }

  /// Clear ALL conversation history (local + backend).
  Future<void> clearAllHistory() async {
    state = state.copyWith(history: const []);

    // Best-effort backend clear (non-blocking)
    try {
      await _repository.clearAllHistory();
    } catch (_) {}
  }

  /// Start a completely fresh conversation (resets active chat + backend session).
  Future<void> startNewConversation() async {
    await _repository.startNewConversation();
    final freshConv = await _repository.loadConversation();
    if (!mounted) return;
    state = state.copyWith(
      conversation:             freshConv,
      status:                   ChatbotStatus.ready,
      followUpQuestions:        const [],
      lastResponseWasEmergency: false,
      clearError:               true,
    );
  }

  /// Retry the last user message if the previous request failed.
  Future<void> retryLastMessage() async {
    final msgs = state.conversation?.messages ?? [];

    // Find the last user message
    final lastUserMsg = msgs
        .where((m) => m.sender == ChatSender.user)
        .fold<ChatMessage?>(null, (_, m) => m);

    if (lastUserMsg == null) return;

    // Remove the last bot message if it's an error/empty response
    final withoutLastBot = msgs.last.sender == ChatSender.bot
        ? msgs.sublist(0, msgs.length - 1)
        : msgs;

    final conv = state.conversation!;
    final trimmedConv = ConversationModel(
      id:        conv.id,
      title:     conv.title,
      messages:  withoutLastBot,
      updatedAt: conv.updatedAt,
    );

    state = state.copyWith(
      conversation: trimmedConv,
      clearError:   true,
    );

    await sendMessage(lastUserMsg.text);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  ConversationModel _appendMessage(Conversation conv, ChatMessage msg) {
    final isFirstUserMsg =
        conv.messages.where((m) => m.sender == ChatSender.user).isEmpty;
    final title = (isFirstUserMsg && msg.sender == ChatSender.user)
        ? _titleFromMessage(msg.text)
        : conv.title;
    return ConversationModel(
      id:        conv.id,
      title:     title,
      messages:  [...conv.messages, msg],
      updatedAt: DateTime.now(),
    );
  }

  String _titleFromMessage(String text) =>
      text.length <= 42 ? text : '${text.substring(0, 39)}…';

  // ── BCP-47 locale maps ────────────────────────────────────────────────────

  static String _sttLocale(String code) {
    const map = {
      'en':  'en-IN',
      'hi':  'hi-IN',
      'ne':  'ne-NP',
      'bho': 'hi-IN', // Bhojpuri → Hindi STT model
      'bn':  'bn-IN',
      'ta':  'ta-IN',
      'te':  'te-IN',
      'mr':  'mr-IN',
    };
    return map[code] ?? 'en-IN';
  }

  static String _ttsLocale(String code) {
    const map = {
      'en':  'en-IN',
      'hi':  'hi-IN',
      'ne':  'ne-NP',
      'bho': 'hi-IN',
      'bn':  'bn-IN',
      'ta':  'ta-IN',
      'te':  'te-IN',
      'mr':  'mr-IN',
    };
    return map[code] ?? 'en-IN';
  }

  /// Strip markdown syntax so TTS reads clean natural prose.
  ///
  /// Fixes:
  ///   - r'$1' was outputting literal "$1" — now uses replaceAllMapped
  ///   - Consecutive sentences now have proper pauses between them
  ///   - Bullet points become natural spoken sentences
  static String _stripMarkdown(String text) {
    String s = text;

    // 1. Bold **text** → just the text (using replaceAllMapped, NOT r'$1')
    s = s.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*', dotAll: true),
      (m) => m.group(1) ?? '',
    );

    // 2. Italic *text* → just the text
    s = s.replaceAllMapped(
      RegExp(r'\*(.+?)\*', dotAll: true),
      (m) => m.group(1) ?? '',
    );

    // 3. Inline code `text` → just the text
    s = s.replaceAllMapped(
      RegExp(r'`(.+?)`', dotAll: true),
      (m) => m.group(1) ?? '',
    );

    // 4. Links [label](url) → just the label
    s = s.replaceAllMapped(
      RegExp(r'\[(.+?)\]\(.+?\)', dotAll: true),
      (m) => m.group(1) ?? '',
    );

    // 5. Headings ### → remove the # symbols
    s = s.replaceAll(RegExp(r'#{1,6}\s*'), '');

    // 6. Bullet / list items (- or * or + or numbered) →
    //    replace with ". " so TTS reads a natural pause between items
    s = s.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '. ');
    s = s.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '. ');

    // 7. Horizontal rules --- or *** → pause
    s = s.replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '. ');

    // 8. Multiple newlines → ". " so sentences are spoken separately
    //    Single newlines → " " (space, not period — avoids double periods)
    s = s.replaceAll(RegExp(r'\n{2,}'), '. ');
    s = s.replaceAll('\n', ' ');

    // 9. Remove all emojis (they break TTS or get read as "emoji" / symbol names)
    s = s.replaceAll(
      RegExp(
        r'[\u{1F000}-\u{1FFFF}]|'
        r'[\u{2600}-\u{27BF}]|'
        r'[\u{FE00}-\u{FE0F}]|'
        r'[\u{1F900}-\u{1F9FF}]|'
        r'⚠️|🚨|💊|🤒|🩺|🌡️|😷|🥗|🏃|🤰|👶|💙|💚|✅|❌|📞|🔴|🟢|🟡',
        unicode: true,
      ),
      '',
    );

    // 10. Remove leftover markdown symbols
    s = s.replaceAll(RegExp(r'[_~>|]'), '');

    // 11. Fix multiple consecutive periods or spaces
    s = s.replaceAll(RegExp(r'\.\s*\.+'), '.');
    s = s.replaceAll(RegExp(r'\s{2,}'), ' ');

    // 12. Clip to 900 chars for natural TTS length
    s = s.trim();
    if (s.length > 900) {
      s = '${s.substring(0, 897)}...';
    }

    return s;
  }

  @override
  void dispose() {
    _restartListenTimer?.cancel();
    _speech.stop();
    _tts.stop();
    _audio.dispose();
    super.dispose();
  }
}
