import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _emoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️';
    if (h < 17) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF926EFF), Color(0xFF6B47E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text('JD',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(_greeting(),
                      style: const TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textMuted,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  Text(_emoji(), style: const TextStyle(fontSize: 12)),
                ],
              ),
              const Text('John Doe',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.3,
                      color: DesignTokens.textStrong)),
            ],
          ),
        ),
      ],
    );
  }
}
