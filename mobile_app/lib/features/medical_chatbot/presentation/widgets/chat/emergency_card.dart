import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../routing/route_names.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';

/// Red emergency banner injected into the chat when the bot detects a
/// life-threatening situation.  Every call button now dials for real.
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
          const Row(children: [
            Text('🚨', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text(
              'MEDICAL EMERGENCY',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5),
            ),
          ]),
          const SizedBox(height: 10),
          const Text(
            'Your symptoms may require immediate medical attention.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),

          // ── Dial buttons ──────────────────────────────────────────────
          Row(children: [
            _CallBtn(emoji: '🚑', label: '102\nAmbulance', number: '102'),
            const SizedBox(width: 8),
            _CallBtn(emoji: '🆘', label: '108\nDisaster',  number: '108'),
            const SizedBox(width: 8),
            _CallBtn(emoji: '☎️', label: '112\nEmergency', number: '112'),
          ]),
          const SizedBox(height: 10),

          // ── Full emergency hub link ────────────────────────────────────
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.emergency),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white30),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🩺', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Text('Open Emergency Hub → AI Triage + SOS',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single call button ────────────────────────────────────────────────────────
class _CallBtn extends StatelessWidget {
  final String emoji, label, number;
  const _CallBtn(
      {required this.emoji, required this.label, required this.number});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          PhoneCallService.call(context, number, label: label.split('\n').last);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white30),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.2)),
          ]),
        ),
      ),
    );
  }
}
