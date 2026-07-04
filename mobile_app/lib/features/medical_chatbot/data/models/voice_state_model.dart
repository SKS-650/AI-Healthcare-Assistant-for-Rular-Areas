import '../../domain/entities/voice_state.dart';

class VoiceStateModel extends VoiceState {
  const VoiceStateModel({
    super.isListening,
    super.isRecording,
    super.isPlaying,
    super.transcript,
  });

  factory VoiceStateModel.fromJson(Map<String, dynamic> json) {
    return VoiceStateModel(
      isListening: json['isListening'] as bool? ?? false,
      isRecording: json['isRecording'] as bool? ?? false,
      isPlaying: json['isPlaying'] as bool? ?? false,
      transcript: json['transcript'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isListening': isListening,
      'isRecording': isRecording,
      'isPlaying': isPlaying,
      'transcript': transcript,
    };
  }
}
