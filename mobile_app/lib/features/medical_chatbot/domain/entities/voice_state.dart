class VoiceState {
  final bool isListening;
  final bool isRecording;
  final bool isPlaying;
  final String transcript;

  const VoiceState({
    this.isListening = false,
    this.isRecording = false,
    this.isPlaying = false,
    this.transcript = '',
  });
}
