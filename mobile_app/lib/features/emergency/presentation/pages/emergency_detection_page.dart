import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controllers/emergency_state.dart';
import '../providers/emergency_provider.dart';
import 'sos_page.dart';

class EmergencyDetectionPage extends ConsumerStatefulWidget {
  const EmergencyDetectionPage({super.key});

  @override
  ConsumerState<EmergencyDetectionPage> createState() => _State();
}

class _State extends ConsumerState<EmergencyDetectionPage> {
  final _textController = TextEditingController();

  static const _quickDescriptions = [
    ('ðŸ’”', 'Chest pain', 'Chest pain and difficulty breathing'),
    ('ðŸ§ ', 'Stroke', 'Sudden severe headache, face drooping'),
    ('ðŸ©¸', 'Bleeding', 'Severe uncontrolled bleeding'),
    ('ðŸŒ¡ï¸', 'High fever', 'High fever above 104Â°F / 40Â°C'),
    ('ðŸ', 'Snake bite', 'Snake or insect bite with swelling'),
    ('ðŸ¤¢', 'Poisoning', 'Suspected poisoning or overdose'),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emergencyControllerProvider);
    final controller = ref.read(emergencyControllerProvider.notifier);
    final detecting = state.status == EmergencyStatus.detecting;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        foregroundColor: const Color(0xFF1A1035),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: DesignTokens.textStrong),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('ðŸ”', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Emergency Detection', style: TextStyle(color: DesignTokens.textStrong)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          _StatusBanner(detecting: detecting),
          const SizedBox(height: 16),

          // Input card
          Container(
            decoration: BoxDecoration(
              color: DesignTokens.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DesignTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Row(
                    children: [
                      Text('âœï¸', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text(
                        'Describe the emergency',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: DesignTokens.textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _textController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. "Chest pain and difficulty breathing" or "High fever with seizures"',
                    hintStyle: TextStyle(
                      color: DesignTokens.textSubtle,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Detect button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: detecting
                  ? null
                  : () => controller.detectEmergency(_textController.text),
              icon: detecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('ðŸ”', style: TextStyle(fontSize: 18)),
              label: Text(
                detecting ? 'Analyzing...' : 'Detect Emergency',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.danger,
                disabledBackgroundColor: DesignTokens.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quick select
          const Row(
            children: [
              Text('âš¡', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'Quick Select',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: DesignTokens.textStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: _quickDescriptions.map((q) {
              return GestureDetector(
                onTap: () {
                  _textController.text = q.$3;
                  controller.detectEmergency(q.$3);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.dangerContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DesignTokens.danger.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(q.$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          q.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: DesignTokens.danger,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Detection result
          if (state.activeEvent != null) ...[
            const SizedBox(height: 20),
            _ResultCard(event: state.activeEvent!),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SosPage()),
                ),
                icon: const Text('ðŸ†˜', style: TextStyle(fontSize: 18)),
                label: const Text(
                  'Send SOS Alert Now',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool detecting;
  const _StatusBanner({required this.detecting});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: detecting
            ? DesignTokens.danger.withValues(alpha: 0.08)
            : DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: detecting
              ? DesignTokens.danger.withValues(alpha: 0.3)
              : DesignTokens.border,
        ),
      ),
      child: Row(
        children: [
          Text(detecting ? 'ðŸ”´' : 'ðŸŸ¢', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detecting ? 'Analyzing situation...' : 'AI Detection Ready',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: detecting ? DesignTokens.danger : DesignTokens.textStrong,
                  ),
                ),
                Text(
                  detecting
                      ? 'Please wait while AI processes your description'
                      : 'Describe the emergency to get instant guidance',
                  style: const TextStyle(
                    color: DesignTokens.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (detecting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: DesignTokens.danger,
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final dynamic event;
  const _ResultCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.dangerContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ðŸš¨', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.type?.title ?? 'Emergency Detected',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: DesignTokens.danger,
                      ),
                    ),
                    Text(
                      'Severity: ${event.severity ?? 'High'}',
                      style: const TextStyle(
                        color: DesignTokens.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.description ?? 'Emergency situation detected. Immediate action required.',
            style: const TextStyle(
              color: DesignTokens.textStrong,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text('âš¡', style: TextStyle(fontSize: 12)),
              SizedBox(width: 6),
              Text(
                'Tap "Send SOS Alert" below for immediate help',
                style: TextStyle(
                  color: DesignTokens.danger,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
