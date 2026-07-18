import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../controllers/emergency_state.dart';
import '../providers/emergency_provider.dart';
import '../widgets/sos/countdown_dialog.dart';
import '../widgets/sos/sos_button.dart';

/// National emergency numbers shown on the SOS page.
const _kEmergencyNumbers = [
  ('🚑', 'Ambulance',     '102', Color(0xFFDC2626)),
  ('🚓', 'Police',        '100', Color(0xFF1D4ED8)),
  ('🔥', 'Fire Brigade',  '101', Color(0xFFEA580C)),
  ('🏥', 'Health',        '104', Color(0xFF059669)),
  ('🆘', 'Disaster',      '108', Color(0xFF7C3AED)),
  ('👶', 'Child Helpline','1098',Color(0xFFDB2777)),
];

class SosPage extends ConsumerWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state      = ref.watch(emergencyControllerProvider);
    final controller = ref.read(emergencyControllerProvider.notifier);
    final selectedType = state.types.isEmpty ? null : state.types.first;
    final isSending  = state.status == EmergencyStatus.sendingSos;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────────────────
          SliverToBoxAdapter(child: _SosHeader()),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Warning banner ───────────────────────────────────────
                  _WarningBanner(),
                  const SizedBox(height: 20),

                  // ── SOS button + status ──────────────────────────────────
                  Center(
                    child: SosButton(
                      loading: isSending,
                      onPressed: selectedType == null
                          ? null
                          : () {
                              HapticFeedback.heavyImpact();
                              showDialog<void>(
                                context: context,
                                builder: (_) => CountdownDialog(
                                  title: selectedType.title,
                                  onConfirm: () =>
                                      controller.triggerSos(selectedType),
                                ),
                              );
                            },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // SOS status / success feedback
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: state.activeEvent != null
                        ? _SosSuccessBanner(status: state.activeEvent!.status)
                        : Text(
                            isSending
                                ? '⏳  Sending alert to your contacts…'
                                : 'Hold the button above to send SOS',
                            key: const ValueKey('idle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: DesignTokens.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),

                  const SizedBox(height: 28),

                  // ── Section title ────────────────────────────────────────
                  const Row(children: [
                    Text('📞', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'Call Emergency Services Directly',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: DesignTokens.textStrong,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap any number below to dial immediately',
                    style: TextStyle(
                        fontSize: 12, color: DesignTokens.textMuted),
                  ),
                  const SizedBox(height: 14),

                  // ── Emergency number grid ────────────────────────────────
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: _kEmergencyNumbers
                        .map((e) => _EmergencyNumberTile(
                              emoji:  e.$1,
                              label:  e.$2,
                              number: e.$3,
                              color:  e.$4,
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // ── "What happens when you press SOS?" info card ─────────
                  _SosInfoCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient header ───────────────────────────────────────────────────────────
class _SosHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 16,
        bottom: 18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🆘  SOS Emergency Alert',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3)),
            Text('Send alert or call emergency services',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

// ── Warning banner ────────────────────────────────────────────────────────────
class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use SOS only for genuine emergencies. Misuse wastes '
              'emergency responder time and may be an offence.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SOS success banner ────────────────────────────────────────────────────────
class _SosSuccessBanner extends StatelessWidget {
  final String status;
  const _SosSuccessBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.successContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.success.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Text('✅', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            status,
            style: const TextStyle(
              color: DesignTokens.success,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Emergency number tile ─────────────────────────────────────────────────────
class _EmergencyNumberTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String number;
  final Color color;

  const _EmergencyNumberTile({
    required this.emoji,
    required this.label,
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.mediumImpact();
          // Emergency numbers dial immediately — no confirmation
          PhoneCallService.call(context, number, label: label);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: DesignTokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────
class _SosInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      ('📱', 'Your emergency contacts receive an SMS alert with your name.'),
      ('📍', 'Your last known location is included in the message.'),
      ('🚨', 'Nearby hospitals and ambulance services are listed for you.'),
      ('⏱️', 'A 5-second countdown lets you cancel accidental triggers.'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('ℹ️', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text('What happens when you press SOS?',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: DesignTokens.textStrong)),
          ]),
          const SizedBox(height: 12),
          ...steps.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.$1, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(s.$2,
                      style: const TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textStrong,
                          height: 1.4)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
