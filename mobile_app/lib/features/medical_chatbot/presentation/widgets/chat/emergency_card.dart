import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

/// Red emergency banner shown when bot detects a life-threatening situation.
class EmergencyCard extends StatelessWidget {
  const EmergencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF1744), Color(0xFF8B0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.danger.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🚨', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Text(
                'MEDICAL EMERGENCY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Your symptoms may require immediate medical attention.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _EmergencyCallButton(
                emoji: '🚑',
                label: '108\nAmbulance',
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _EmergencyCallButton(
                emoji: '🆘',
                label: '112\nEmergency',
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _EmergencyCallButton(
                emoji: '🏥',
                label: '102\nNepal',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmergencyCallButton extends StatelessWidget {
  final String emoji, label;
  final VoidCallback onTap;
  const _EmergencyCallButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white30),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
