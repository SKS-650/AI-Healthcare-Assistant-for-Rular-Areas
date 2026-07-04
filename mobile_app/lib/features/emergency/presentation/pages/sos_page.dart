import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controllers/emergency_state.dart';
import '../providers/emergency_provider.dart';
import '../widgets/sos/countdown_dialog.dart';
import '../widgets/sos/sos_button.dart';

class SosPage extends ConsumerWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyControllerProvider);
    final controller = ref.read(emergencyControllerProvider.notifier);
    final selectedType = state.types.isEmpty ? null : state.types.first;
    final isSending = state.status == EmergencyStatus.sendingSos;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('SOS Alert'),
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignTokens.textStrong, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Warning banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DesignTokens.warningContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DesignTokens.warningLight),
                ),
                child: Row(
                  children: [
                    const Text('âš ï¸', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Use SOS only for genuine medical or safety emergencies. Misuse may prevent real emergency responders from helping others.',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Status display
              if (state.activeEvent != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.successContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DesignTokens.emeraldContainer),
                  ),
                  child: Row(
                    children: [
                      const Text('âœ…', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.activeEvent!.status,
                          style: const TextStyle(
                            color: DesignTokens.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // SOS Button
              SosButton(
                loading: isSending,
                onPressed: selectedType == null
                    ? null
                    : () => showDialog<void>(
                        context: context,
                        builder: (_) => CountdownDialog(
                          title: selectedType.title,
                          onConfirm: () => controller.triggerSos(selectedType),
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              Text(
                state.activeEvent?.status ?? 'Ready to send alert',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textMuted,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Emergency numbers
              const _EmergencyNumbers(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyNumbers extends StatelessWidget {
  const _EmergencyNumbers();

  @override
  Widget build(BuildContext context) {
    final numbers = [
      ('ðŸš‘', 'Ambulance', '102'),
      ('ðŸš“', 'Police', '100'),
      ('ðŸ”¥', 'Fire', '101'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((item) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: DesignTokens.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DesignTokens.border),
            ),
            child: Column(
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DesignTokens.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.$3,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: DesignTokens.danger,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
