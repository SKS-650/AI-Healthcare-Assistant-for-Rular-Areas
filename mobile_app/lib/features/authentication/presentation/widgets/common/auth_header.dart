import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? emoji;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (emoji != null) ...[
          Text(emoji!, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textStrong,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: DesignTokens.textMuted,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
