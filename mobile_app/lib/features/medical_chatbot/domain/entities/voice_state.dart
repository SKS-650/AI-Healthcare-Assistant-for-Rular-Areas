/// Full voice state for the AI medical assistant.
/// Tracks STT listening, TTS speaking, transcript, error and audio playback.
class VoiceState {
  final bool isListening;    // microphone is active (STT)
  final bool isRecording;    // raw audio is being captured
  final bool isSpeaking;     // TTS is playing bot response
  final bool isPlaying;      // audioplayer is active
  final bool isProcessing;   // STT → server round-trip in progress
  final String transcript;   // live / final STT text
  final String? errorMessage;
  final String? lastAudioBase64; // latest TTS MP3 from backend
  final double volume;       // 0.0–1.0  (mic amplitude hint)

  const VoiceState({
    this.isListening    = false,
    this.isRecording    = false,
    this.isSpeaking     = false,
    this.isPlaying      = false,
    this.isProcessing   = false,
    this.transcript     = '',
    this.errorMessage,
    this.lastAudioBase64,
    this.volume         = 0.0,
  });

  VoiceState copyWith({
    bool?   isListening,
    bool?   isRecording,
    bool?   isSpeaking,
    bool?   isPlaying,
    bool?   isProcessing,
    String? transcript,
    String? errorMessage,
    String? lastAudioBase64,
    double? volume,
    bool    clearError = false,
    bool    clearAudio = false,
  }) {
    return VoiceState(
      isListening    : isListening    ?? this.isListening,
      isRecording    : isRecording    ?? this.isRecording,
      isSpeaking     : isSpeaking     ?? this.isSpeaking,
      isPlaying      : isPlaying      ?? this.isPlaying,
      isProcessing   : isProcessing   ?? this.isProcessing,
      transcript     : transcript     ?? this.transcript,
      errorMessage   : clearError     ? null : errorMessage ?? this.errorMessage,
      lastAudioBase64: clearAudio     ? null : lastAudioBase64 ?? this.lastAudioBase64,
      volume         : volume         ?? this.volume,
    );
  }

  /// True when any voice activity is happening.
  bool get isActive => isListening || isSpeaking || isProcessing;
}
