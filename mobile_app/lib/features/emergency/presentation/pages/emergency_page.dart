import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _sosTriggered = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _triggerSOS() {
    HapticFeedback.heavyImpact();
    setState(() => _sosTriggered = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sosTriggered = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Text('🚨', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Emergency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SOS Button
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Press & Hold for Emergency SOS',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.textStrong,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sends your location to emergency services',
                      style: TextStyle(
                        fontSize: 13,
                        color: DesignTokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: child,
                      ),
                      child: GestureDetector(
                        onLongPress: _triggerSOS,
                        onTap: _triggerSOS,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _sosTriggered
                                  ? [const Color(0xFF16A34A), const Color(0xFF2ECC8B)]
                                  : [const Color(0xFFFF4757), const Color(0xFFCC2233)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_sosTriggered
                                        ? DesignTokens.success
                                        : DesignTokens.danger)
                                    .withValues(alpha: 0.45),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _sosTriggered ? '✅' : '🚨',
                                style: const TextStyle(fontSize: 46),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _sosTriggered ? 'SENT!' : 'SOS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_sosTriggered)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: DesignTokens.successContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DesignTokens.success),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: DesignTokens.success, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Emergency SOS sent! Help is on the way.',
                              style: TextStyle(
                                color: DesignTokens.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Emergency Contacts
              const _SectionHeader(emoji: '📞', title: 'Emergency Contacts'),
              const SizedBox(height: 12),
              ..._emergencyContacts.map((c) => _ContactCard(contact: c)),

              const SizedBox(height: 28),

              // First Aid Tips
              const _SectionHeader(emoji: '🩹', title: 'Quick First Aid'),
              const SizedBox(height: 12),
              ..._firstAidTips.asMap().entries.map(
                    (e) => _FirstAidCard(tip: e.value, index: e.key),
                  ),

              const SizedBox(height: 28),

              // Warning Signs
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DesignTokens.dangerContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DesignTokens.danger.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('⚠️', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Text(
                          'Seek Immediate Care If You Have:',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: DesignTokens.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._warningSigns.map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: DesignTokens.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: DesignTokens.danger,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  const _SectionHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textStrong,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final _EmergencyContact contact;
  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: contact.color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: contact.color.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [contact.color, contact.color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: contact.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(contact.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: DesignTokens.textStrong,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.description,
                        style: const TextStyle(
                          color: DesignTokens.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: contact.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: contact.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_rounded,
                          size: 14, color: contact.color),
                      const SizedBox(width: 5),
                      Text(
                        contact.number,
                        style: TextStyle(
                          color: contact.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstAidCard extends StatelessWidget {
  final _FirstAidTip tip;
  final int index;
  const _FirstAidCard({required this.tip, required this.index});

  static const _colors = [
    Color(0xFF4F94FF),
    Color(0xFF2ECC8B),
    Color(0xFFFFB829),
    Color(0xFFFF5E9E),
    Color(0xFF18C8C8),
    Color(0xFF926EFF),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(tip.emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip.steps,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContact {
  final String emoji, name, description, number;
  final Color color;
  const _EmergencyContact({
    required this.emoji,
    required this.name,
    required this.description,
    required this.number,
    required this.color,
  });
}

class _FirstAidTip {
  final String emoji, title, steps;
  const _FirstAidTip(
      {required this.emoji, required this.title, required this.steps});
}

const _emergencyContacts = [
  _EmergencyContact(
    emoji: '🚑',
    name: 'Ambulance',
    description: 'Medical emergency transport',
    number: '102',
    color: Color(0xFFFF4757),
  ),
  _EmergencyContact(
    emoji: '🚒',
    name: 'Fire Brigade',
    description: 'Fire & rescue services',
    number: '101',
    color: Color(0xFFFF7B3D),
  ),
  _EmergencyContact(
    emoji: '👮',
    name: 'Police',
    description: 'Law enforcement',
    number: '100',
    color: Color(0xFF4F94FF),
  ),
  _EmergencyContact(
    emoji: '🏥',
    name: 'Disaster Relief',
    description: 'National disaster helpline',
    number: '108',
    color: Color(0xFF2ECC8B),
  ),
];

const _firstAidTips = [
  _FirstAidTip(
    emoji: '🩸',
    title: 'Bleeding',
    steps:
        'Apply direct pressure with a clean cloth. Elevate the injured area above the heart if possible.',
  ),
  _FirstAidTip(
    emoji: '🔥',
    title: 'Burns',
    steps:
        'Cool the burn under cold running water for 10–20 minutes. Do not apply ice or butter.',
  ),
  _FirstAidTip(
    emoji: '😮',
    title: 'Choking',
    steps:
        'Give 5 back blows, then 5 abdominal thrusts (Heimlich maneuver). Repeat until cleared.',
  ),
  _FirstAidTip(
    emoji: '💗',
    title: 'Cardiac Arrest',
    steps:
        'Call emergency services immediately. Begin CPR: 30 chest compressions then 2 rescue breaths.',
  ),
  _FirstAidTip(
    emoji: '🧠',
    title: 'Stroke Signs (FAST)',
    steps:
        'Face drooping, Arm weakness, Speech difficulty, Time to call emergency. Act fast — every minute counts.',
  ),
];

const _warningSigns = [
  'Chest pain or tightness',
  'Difficulty breathing or shortness of breath',
  'Sudden severe headache',
  'Loss of consciousness or fainting',
  'Uncontrolled bleeding',
  'Suspected poisoning or overdose',
  'Signs of stroke (facial drooping, arm weakness)',
];
