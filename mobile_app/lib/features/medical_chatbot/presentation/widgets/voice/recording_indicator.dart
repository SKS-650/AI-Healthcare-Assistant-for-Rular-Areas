import 'package:flutter/material.dart';

class RecordingIndicator extends StatelessWidget {
  final bool isRecording;

  const RecordingIndicator({super.key, required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        isRecording ? Icons.fiber_manual_record : Icons.mic_none,
        size: 18,
      ),
      label: Text(isRecording ? 'Recording' : 'Tap microphone to start'),
    );
  }
}
