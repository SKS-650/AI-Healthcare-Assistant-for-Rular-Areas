import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';

class ResendTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onResend;

  const ResendTimer({
    super.key,
    this.seconds = 60,
    required this.onResend,
  });

  @override
  State<ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<ResendTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _handleResend() {
    widget.onResend();
    setState(() => _remaining = widget.seconds);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining > 0) {
      return Text.rich(
        TextSpan(
          text: "Didn't receive the code? ",
          style: const TextStyle(
            color: DesignTokens.textMuted,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: 'Resend in ${_remaining}s',
              style: const TextStyle(
                color: DesignTokens.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return TextButton(
      onPressed: _handleResend,
      style: TextButton.styleFrom(
        foregroundColor: DesignTokens.primary,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Resend OTP',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}
