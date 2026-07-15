import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class CountdownDialog extends StatefulWidget {
  final String title;
  final VoidCallback onConfirm;

  const CountdownDialog({
    super.key,
    required this.title,
    required this.onConfirm,
  });

  @override
  State<CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<CountdownDialog> {
  int _seconds = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        if (mounted) {
          Navigator.of(context).pop();
          widget.onConfirm();
        }
      } else {
        if (mounted) setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: DesignTokens.dangerContainer,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🆘', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sending SOS Alert',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Emergency: ${widget.title}',
              style: const TextStyle(
                color: DesignTokens.textMuted,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Countdown ring
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _seconds / 5,
                    strokeWidth: 5,
                    color: DesignTokens.danger,
                    backgroundColor:
                        DesignTokens.danger.withValues(alpha: 0.12),
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    '$_seconds',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: DesignTokens.danger,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'Alert will be sent automatically',
              style: TextStyle(
                color: DesignTokens.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      side: const BorderSide(color: DesignTokens.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('❌ Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                      widget.onConfirm();
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: DesignTokens.danger,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('🆘 Send Now',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
