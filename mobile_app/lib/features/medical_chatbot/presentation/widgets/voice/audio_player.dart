import 'package:flutter/material.dart';

class ChatbotAudioPlayer extends StatelessWidget {
  final bool isPlaying;

  const ChatbotAudioPlayer({super.key, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isPlaying
            ? Icons.pause_circle_filled_rounded
            : Icons.play_circle_fill_rounded,
      ),
      title: const Text('Voice response preview'),
      subtitle: const Text('Text-to-speech output placeholder'),
    );
  }
}
