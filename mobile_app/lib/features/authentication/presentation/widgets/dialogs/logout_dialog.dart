import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context,
      {required VoidCallback onConfirm}) {
    return showDialog(
      context: context,
      builder: (_) => LogoutDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DesignTokens.warningContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: DesignTokens.warning,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Log Out?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'ll need to sign in again to access your health data.',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignTokens.textMuted,
                    side: BorderSide(color: DesignTokens.border),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.danger,
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
