import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../../domain/entities/emergency_history.dart';
import '../providers/emergency_provider.dart';

class EmergencyHistoryPage extends ConsumerWidget {
  const EmergencyHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(children: [
          Text('📋', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text('Emergency History',
              style: TextStyle(
                  color: DesignTokens.textStrong, fontWeight: FontWeight.w700)),
        ]),
        actions: [
          // Quick-call 102 from history page
          TextButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              PhoneCallService.call(context, '102', label: 'Ambulance');
            },
            icon: const Icon(Icons.call_rounded, size: 16, color: DesignTokens.danger),
            label: const Text('102',
                style: TextStyle(
                    color: DesignTokens.danger,
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
          ),
        ],
      ),
      body: state.history.isEmpty
          ? const _EmptyHistory()
          : Column(children: [
              // Summary banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: DesignTokens.dangerContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: DesignTokens.danger.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  const Text('📊', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    '${state.history.length} emergency event${state.history.length == 1 ? '' : 's'} recorded',
                    style: const TextStyle(
                        color: DesignTokens.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ]),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: state.history.length,
                  itemBuilder: (context, i) =>
                      _HistoryCard(history: state.history[i]),
                ),
              ),
            ]),
    );
  }
}

// ─── History card ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final EmergencyHistory history;
  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final isSos   = history.event.sosSent;
    final color   = isSos ? DesignTokens.danger  : DesignTokens.warning;
    final bgColor = isSos ? DesignTokens.dangerContainer : DesignTokens.warningContainer;

    final dateStr = _fmtDate(history.savedAt);
    final timeStr = _fmtTime(history.savedAt);

    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      isSos ? '🆘' : '⚠️',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                            history.event.type.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: DesignTokens.textStrong),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSos ? '🆘 SOS Sent' : '🔍 Detected',
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 4),

                      // Action taken description
                      Text(
                        history.actionTaken,
                        style: const TextStyle(
                            color: DesignTokens.textMuted,
                            fontSize: 12,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Footer row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(children: [
              // Location
              const Icon(Icons.location_on_rounded,
                  size: 12, color: DesignTokens.textMuted),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  history.event.location,
                  style: const TextStyle(
                      color: DesignTokens.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Date + time
              Text(
                '📅 $dateStr  •  🕐 $timeStr',
                style: const TextStyle(
                    color: DesignTokens.textSubtle, fontSize: 10),
              ),
            ]),
          ),

          // ── Call action strip (for SOS events) ──────────────────────────
          if (isSos) ...[
            const Divider(height: 1, indent: 14, endIndent: 14,
                color: DesignTokens.borderMuted),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(children: [
                _QuickCallBtn(
                  emoji: '🚑', label: '102', sublabel: 'Ambulance',
                  onTap: () => PhoneCallService.call(context, '102',
                      label: 'Ambulance'),
                ),
                const SizedBox(width: 8),
                _QuickCallBtn(
                  emoji: '🚓', label: '100', sublabel: 'Police',
                  onTap: () => PhoneCallService.call(context, '100',
                      label: 'Police'),
                ),
                const SizedBox(width: 8),
                _QuickCallBtn(
                  emoji: '🔥', label: '101', sublabel: 'Fire',
                  onTap: () => PhoneCallService.call(context, '101',
                      label: 'Fire Brigade'),
                ),
                const SizedBox(width: 8),
                _QuickCallBtn(
                  emoji: '🆘', label: '108', sublabel: 'Disaster',
                  onTap: () => PhoneCallService.call(context, '108',
                      label: 'Disaster'),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  static String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  static String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Quick call chip ──────────────────────────────────────────────────────────
class _QuickCallBtn extends StatelessWidget {
  final String emoji, label, sublabel;
  final VoidCallback onTap;
  const _QuickCallBtn({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: DesignTokens.danger.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 1),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: DesignTokens.danger)),
              Text(sublabel,
                  style: const TextStyle(
                      fontSize: 8,
                      color: DesignTokens.danger,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📋', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            const Text('No emergency history',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: DesignTokens.textStrong)),
            const SizedBox(height: 8),
            const Text(
              'SOS alerts and emergency detections\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: DesignTokens.textMuted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            // Emergency call strip even on empty state
            const Text('Need help right now?',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: DesignTokens.textStrong)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const _EmergencyPill(
                emoji: '🚑', number: '102', label: 'Ambulance',
                color: DesignTokens.danger,
              ),
              const SizedBox(width: 10),
              const _EmergencyPill(
                emoji: '🚓', number: '100', label: 'Police',
                color: Color(0xFF1D4ED8),
              ),
              const SizedBox(width: 10),
              const _EmergencyPill(
                emoji: '🔥', number: '101', label: 'Fire',
                color: Color(0xFFEA580C),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _EmergencyPill extends StatelessWidget {
  final String emoji, number, label;
  final Color color;
  const _EmergencyPill({
    required this.emoji,
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.mediumImpact();
          PhoneCallService.call(context, number, label: label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(number,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: color,
                    letterSpacing: -0.5)),
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    color: DesignTokens.textMuted,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
