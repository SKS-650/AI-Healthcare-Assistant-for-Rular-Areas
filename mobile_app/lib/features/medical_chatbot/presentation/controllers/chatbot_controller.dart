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
    final lang = language ?? state.selectedLanguage;
    try {
      // Configure TTS for the selected language
      await _tts.setLanguage(_ttsLocale(lang));
      // Natural speaking rate: slightly slower for non-English (more natural)
      await _tts.setSpeechRate(lang == 'en' ? 0.52 : 0.46);
      await _tts.setVolume(1.0);
      await _tts.setPitch(lang == 'hi' || lang == 'bho' ? 1.05 : 1.0);

      final clean   = _stripMarkdown(text);
      // Siri clips at ~250 words for natural feel
      final clipped =
          clean.length > 800 ? '${clean.substring(0, 797)}…' : clean;

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

  Future<void> deleteConversation(String id) async {
    final newHistory = state.history.where((c) => c.id != id).toList();
    state = state.copyWith(history: newHistory);
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

  /// Strip markdown syntax so TTS reads clean prose.
  static String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*', dotAll: true), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*',     dotAll: true), r'$1')
        .replaceAll(RegExp(r'#{1,6}\s?'),     '')
        .replaceAll(RegExp(r'`(.+?)`',        dotAll: true), r'$1')
        .replaceAll(RegExp(r'\[(.+?)\]\(.+?\)', dotAll: true), r'$1')
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '')
        .replaceAll(RegExp(r'\n{2,}'), '. ')
        .replaceAll(RegExp(r'⚠️|🚨|💊|🤒|🩺|🌡️|😷|🥗|🏃|🤰|👶|💙|💚'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
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
