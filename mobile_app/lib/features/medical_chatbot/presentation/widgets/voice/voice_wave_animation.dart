import 'package:flutter/material.dart';

class VoiceWaveAnimation extends StatelessWidget {
  final bool active;

  const VoiceWaveAnimation({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final height = active ? 22.0 + (index.isEven ? 18 : 8) : 12.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
