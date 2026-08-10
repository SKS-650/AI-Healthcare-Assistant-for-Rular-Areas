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
// import '../../data/services/offline_stt_service.dart';  // TODO: Implement when Whisper package is stable
// import '../../data/services/audio_recorder_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chatbot_settings.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/suggestion.dart';
import '../../domain/entities/voice_state.dart';
import '../../domain/entities/voice_type.dart';
import '../../domain/usecases/get_suggestions.dart';
import '../../domain/usecases/load_chat_history.dart';
import '../../domain/usecases/load_conversation.dart';
import '../../domain/usecases/save_chat_history.dart';
import '../../domain/usecases/send_dummy_message.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../../../../core/network/network_info.dart';
import 'chatbot_state.dart';

class ChatbotController extends StateNotifier<ChatbotState> {
  final LoadConversation  _loadConversation;
  final SendDummyMessage  _sendDummyMessage;
  final GetSuggestions    _getSuggestions;
  final LoadChatHistory   _loadChatHistory;
  final SaveChatHistory   _saveChatHistory;
  final ChatbotRepository _repository;
  final NetworkInfo       _networkInfo;

  // ── Voice services ────────────────────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts        _tts   = FlutterTts();
  final AudioPlayer       _audio = AudioPlayer();

  // ── Offline voice services (DISABLED - package not available yet) ─────────
  // final OfflineSttService    _offlineStt = OfflineSttService();
  // final AudioRecorderService _recorder   = AudioRecorderService();
  // bool _offlineSttInitialized = false;

  bool _sttInitialized = false;

  /// Cached set of TTS locales supported by this device (lowercase).
  /// Populated once at init. Null means we haven't queried yet.
  /// Empty set means query failed — skip setLanguage entirely.
  Set<String>? _ttsAvailableLocales;

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
    required NetworkInfo       networkInfo,
  })  : _loadConversation = loadConversation,
        _sendDummyMessage = sendDummyMessage,
        _getSuggestions   = getSuggestions,
        _loadChatHistory  = loadChatHistory,
        _saveChatHistory  = saveChatHistory,
        _repository       = repository,
        _networkInfo      = networkInfo,
        super(const ChatbotState()) {
    load();
    _initTts();
    // _initOfflineStt();  // TODO: Enable when Whisper package is available
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
    // Pre-cache available TTS locales so setLanguage never throws at speak time.
    _prefetchTtsLocales();
  }

  /// Initialize offline STT service (Whisper) in the background.
  /// 
  /// DISABLED: Whisper Flutter package not available on pub.dev yet.
  /// TODO: Enable this when a stable Whisper package is available.
  /*
  Future<void> _initOfflineStt() async {
    try {
      print('🔄 Initializing offline STT (Whisper)...');
      await _offlineStt.initialize();
      _offlineSttInitialized = true;
      print('✅ Offline STT ready for all languages');
    } catch (e) {
      print('⚠️ Offline STT initialization failed: $e');
      print('   Voice input will require internet connection');
      _offlineSttInitialized = false;
    }
  }
  */

  /// Queries the TTS engine for available locales once and caches the result.
  /// Uses runZonedGuarded to catch any native RangeError that the plugin
  /// throws inside the platform channel before Dart's try-catch can intercept.
  Future<void> _prefetchTtsLocales() async {
    try {
      // flutter_tts getLanguages can throw a RangeError on Android when the
      // TTS engine's language list has fewer entries than expected.
      // We wrap in Future.sync to ensure any synchronous throw is also caught.
      final raw = await Future<dynamic>.sync(() => _tts.getLanguages);
      if (raw is List) {
        _ttsAvailableLocales = raw
            .whereType<Object>()
            .map((e) => e.toString().toLowerCase().trim())
            .where((s) => s.isNotEmpty)
            .toSet();
      } else {
        _ttsAvailableLocales = {};
      }
    } catch (_) {
      // Engine threw RangeError or any other error during locale enumeration.
      // Empty set signals: skip setLanguage and rely on engine default.
      _ttsAvailableLocales = {};
    }
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

    // ── Check connectivity ─────────────────────────────────────────────────
    final hasInternet = await _networkInfo.isConnected;

    // Try offline STT first (on-device recognition)
    // If device doesn't support it, will fall back to online automatically
    await _startOfflineOrOnlineListening(preferOffline: !hasInternet);
  }

  /// Start listening using offline or online STT based on connectivity.
  Future<void> _startOfflineOrOnlineListening({bool preferOffline = false}) async {
    if (!mounted) return; // Safety check
    
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
          if (_continuousMode && mounted) {
            _restartListenTimer?.cancel();
            _restartListenTimer = Timer(const Duration(seconds: 2), () {
              if (mounted && _continuousMode) _startListening();
            });
          }
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            if (!mounted) return;
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

    if (!mounted) return; // Safety check

    if (!_sttInitialized) {
      if (!mounted) return;
      state = state.copyWith(
        voiceState: state.voiceState.copyWith(
          errorMessage: '🎙️ Speech recognition not available on this device.',
        ),
      );
      return;
    }

    // ── Check available locales ────────────────────────────────────────────
    final availableLocales = await _speech.locales();
    if (!mounted) return; // Safety check
    
    final requestedLocale = _sttLocale(state.selectedLanguage);
    
    // Try to find best matching locale
    String? actualLocale = _findBestMatchingLocale(
      availableLocales, 
      requestedLocale,
      state.selectedLanguage,
    );

    if (actualLocale == null) {
      if (!mounted) return;
      // No matching locale found - show helpful error
      final langName = _languageName(state.selectedLanguage);
      state = state.copyWith(
        voiceState: state.voiceState.copyWith(
          errorMessage: 
            '🌐 $langName voice recognition not available.\n\n'
            '💡 Your device may need to download the language pack.\n'
            'Go to: Settings → System → Languages & input → On-device recognition\n\n'
            'Switching to English for now...',
        ),
      );
      // Fallback to English
      actualLocale = 'en-IN';
    }

    if (!mounted) return; // Safety check

    state = state.copyWith(
      voiceState: state.voiceState.copyWith(
        isListening: true,
        isRecording: true,
        transcript:  '',
        clearError:  true,
        sttEngine:   preferOffline ? 'offline' : 'online',
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
        localeId:       actualLocale,
        listenFor:      const Duration(seconds: 60),
        pauseFor:       const Duration(seconds: 4),
        onDevice:       preferOffline, // ← Enable on-device recognition when offline
      ),
    );
  }

  /// Find the best matching locale from available locales.
  /// 
  /// Priority:
  /// 1. Exact match (e.g., 'hi-IN')
  /// 2. Language code match (e.g., 'hi' matches 'hi-IN', 'hi-PK')
  /// 3. Special fallbacks (Bhojpuri → Hindi, Nepali → Hindi if ne-NP unavailable)
  /// 4. null (not available)
  String? _findBestMatchingLocale(
    List<stt.LocaleName> availableLocales,
    String requestedLocale,
    String langCode,
  ) {
    final requested = requestedLocale.toLowerCase();
    final langPrefix = langCode.toLowerCase();

    // Debug: Print available locales (helps troubleshooting)
    // print('🔍 Available STT locales: ${availableLocales.map((l) => l.localeId).join(", ")}');
    // print('🎯 Requested: $requested for language: $langCode');

    // 1. Exact match
    for (final locale in availableLocales) {
      if (locale.localeId.toLowerCase() == requested) {
        return locale.localeId;
      }
    }

    // 2. Language prefix match (hi matches hi-IN, hi-PK, etc.)
    for (final locale in availableLocales) {
      final localeId = locale.localeId.toLowerCase();
      if (localeId.startsWith(langPrefix) || localeId.startsWith('$langPrefix-')) {
        return locale.localeId;
      }
    }

    // 3. Special case: Nepali (ne/ne-NP) - try broader search
    if (langCode == 'ne') {
      // Try any locale containing 'ne' or 'nep'
      for (final locale in availableLocales) {
        final localeId = locale.localeId.toLowerCase();
        if (localeId.contains('ne-') || localeId.contains('nep')) {
          return locale.localeId;
        }
      }
      // Fallback: If Nepali not available, use Hindi (similar script/phonetics)
      for (final locale in availableLocales) {
        if (locale.localeId.toLowerCase().startsWith('hi')) {
          // Show warning that we're using Hindi fallback
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                state = state.copyWith(
                  voiceState: state.voiceState.copyWith(
                    errorMessage: 
                      '⚠️ Nepali voice pack not installed.\n'
                      'Using Hindi recognition as fallback.\n\n'
                      'Download Nepali: Settings → Languages → On-device recognition',
                  ),
                );
              }
            });
          }
          return locale.localeId;
        }
      }
    }

    // 4. For Bhojpuri (bho), try Hindi variants
    if (langCode == 'bho') {
      for (final locale in availableLocales) {
        if (locale.localeId.toLowerCase().startsWith('hi')) {
          return locale.localeId;
        }
      }
    }

    return null;
  }

  /// Get human-readable language name for error messages.
  String _languageName(String code) {
    const names = {
      'en':  'English',
      'hi':  'Hindi',
      'ne':  'Nepali',
      'bho': 'Bhojpuri',
      'bn':  'Bengali',
      'ta':  'Tamil',
      'te':  'Telugu',
      'mr':  'Marathi',
    };
    return names[code] ?? 'Selected language';
  }

  Future<void> _stopListening() async {
    // Stop STT engine
    await _speech.stop();
    // await _recorder.stopRecording();  // TODO: Enable when offline STT is ready
    
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
    final lang        = language ?? state.selectedLanguage;
    final sliderSpeed = state.settings?.voiceSpeed ?? 1.0;
    final voiceType   = state.settings?.voiceType ?? VoiceType.neutral;
    
    // Apply voice-specific speed modifier
    final speedModifier = voiceType.speechRateModifier;
    final baseRate      = lang == 'en' ? 0.50 : 0.44;
    final ttsRate       = (baseRate * sliderSpeed * speedModifier).clamp(0.2, 0.9);
    final clipped       = _stripMarkdown(text); // clips to 900 chars

    if (clipped.isEmpty) return;

    // ── 1. Resolve the safest available locale ────────────────────────────
    // If prefetch hasn't finished yet, wait briefly for it (max 1 sec).
    if (_ttsAvailableLocales == null) {
      await Future.any([
        _prefetchTtsLocales(),
        Future<void>.delayed(const Duration(seconds: 1)),
      ]);
    }

    final resolvedLocale = _resolveLocaleFromCache(_ttsLocale(lang));

    // ── 2. Get pitch from voice type settings ─────────────────────────────
    final ttsPitch = voiceType.getPitchForLanguage(lang);

    // ── 3. Select appropriate voice based on voice type ───────────────────
    await _selectBestVoiceForType(voiceType, lang);

    // ── 4. Apply TTS settings — each call isolated so one failure can't
    //        crash the whole speak sequence. ──────────────────────────────
    if (resolvedLocale != null) {
      try { await _tts.setLanguage(resolvedLocale); } catch (_) {}
    }
    try { await _tts.setSpeechRate(ttsRate); }       catch (_) {}
    try { await _tts.setVolume(1.0); }               catch (_) {}
    try {
      await _tts.setPitch(ttsPitch);
    } catch (_) {}

    // ── 5. Speak ──────────────────────────────────────────────────────────
    try {
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isSpeaking: true));
      await _tts.speak(clipped);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
          voiceState: state.voiceState.copyWith(isSpeaking: false));
    }
  }

  /// Select the best available voice for the given voice type and language.
  /// 
  /// This method queries available TTS voices and attempts to find one that
  /// matches the desired gender and quality. Different devices have different
  /// voice sets, so we use pattern matching to find the best match.
  Future<void> _selectBestVoiceForType(VoiceType voiceType, String lang) async {
    try {
      // Get all available voices from TTS engine
      final voices = await _tts.getVoices;
      
      if (voices == null || (voices as List).isEmpty) {
        // No voices available, TTS will use default
        return;
      }

      // Get voice name patterns for this voice type and language
      final patterns = voiceType.getVoiceNamePatterns(lang);
      final gender = voiceType.gender;
      
      // Search for best matching voice
      dynamic bestVoice;
      int bestScore = 0;

      for (final voice in voices as List) {
        final voiceMap = voice as Map<dynamic, dynamic>;
        final voiceName = (voiceMap['name'] as String? ?? '').toLowerCase();
        final voiceLocale = (voiceMap['locale'] as String? ?? '').toLowerCase();
        
        int score = 0;

        // Score based on pattern matching (highest priority)
        for (int i = 0; i < patterns.length; i++) {
          if (voiceName.contains(patterns[i].toLowerCase())) {
            score += (patterns.length - i) * 10; // Earlier patterns get higher scores
            break;
          }
        }

        // Score based on gender match
        if (voiceName.contains(gender.toLowerCase())) {
          score += 5;
        }

        // Score based on locale match
        final targetLocale = _ttsLocale(lang).toLowerCase();
        if (voiceLocale.contains(targetLocale) || 
            targetLocale.contains(voiceLocale)) {
          score += 3;
        }

        // Update best voice if this one scores higher
        if (score > bestScore) {
          bestScore = score;
          bestVoice = voice;
        }
      }

      // If we found a good match, set it
      if (bestVoice != null && bestScore > 0) {
        await _tts.setVoice(bestVoice);
      }
    } catch (e) {
      // Voice selection failed, continue with default voice
      // TTS will still work with pitch and rate adjustments
    }
  }

  /// Returns the best available locale string from the cached set,
  /// or null if the cache is empty / the engine should use its default.
  ///
  /// Priority:
  ///   1. Exact match       (e.g. "hi-in")
  ///   2. Language prefix   (e.g. "hi" in "hi-in")
  ///   3. en-IN / en-US / en-GB / any English
  ///   4. null  → skip setLanguage, let engine use its default
  String? _resolveLocaleFromCache(String wanted) {
    final cache = _ttsAvailableLocales;

    // Empty cache means engine threw during enumeration — skip setLanguage
    if (cache == null || cache.isEmpty) return null;

    final w = wanted.toLowerCase().trim();

    // 1. Exact match
    if (cache.contains(w)) return w;

    // 2. Language-code prefix match (e.g. wanted="ne-np", cache has "ne-xx")
    final prefix = w.split('-').first;
    final prefixMatch = cache.where((l) => l.startsWith(prefix)).toList();
    if (prefixMatch.isNotEmpty) {
      // Prefer region-qualified over bare code (better TTS quality)
      prefixMatch.sort((a, b) => b.length.compareTo(a.length));
      return prefixMatch.first;
    }

    // 3. English fallback chain
    for (final fb in ['en-in', 'en-us', 'en-gb', 'en-au']) {
      if (cache.contains(fb)) return fb;
    }
    final anyEnglish = cache.where((l) => l.startsWith('en')).toList();
    if (anyEnglish.isNotEmpty) return anyEnglish.first;

    // 4. Absolute last resort — first locale in cache
    return cache.first;
  }

  /// Returns [wanted] if the device TTS engine supports it,
  /// otherwise falls back through a priority list to 'en-IN'.
  ///
  /// Delegates to the cached locale set — for external/test use.
  Future<String> safeResolveTtsLocale(String wanted) async {
    if (_ttsAvailableLocales == null) {
      await _prefetchTtsLocales();
    }
    return _resolveLocaleFromCache(wanted) ?? 'en-IN';
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
    _restartListenTimer = null;
    
    // Stop all voice services
    _speech.stop().catchError((_) {});
    _tts.stop().catchError((_) {});
    _audio.dispose();
    
    // TODO: Dispose offline STT resources when implemented
    // _offlineStt.dispose();
    // _recorder.dispose();
    // AudioRecorderService.cleanupOldRecordings();
    
    super.dispose();
  }
}
