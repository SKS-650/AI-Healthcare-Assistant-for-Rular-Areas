import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../../../../shared/utils/phone_call_service.dart';
import '../../domain/entities/emergency_assessment.dart';
import '../../domain/entities/first_aid_guide.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/entities/risk_level.dart';
import '../providers/emergency_provider.dart';
import 'sos_page.dart';

class EmergencyResultPage extends ConsumerWidget {
  const EmergencyResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assessmentControllerProvider);
    final result = state.result;

    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _ResultHeader(result: result)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _RiskGaugeCard(result: result),
              const SizedBox(height: 16),
              if (result.isEmergency) ...[
                _WarningBanner(message: result.warningMessage),
                const SizedBox(height: 16),
              ],
              if (result.firstAid != null) ...[
                _FirstAidCard(guide: result.firstAid!),
                const SizedBox(height: 16),
              ],
              if (result.hospitalRecommendations.isNotEmpty) ...[
                _HospitalsCard(hospitals: result.hospitalRecommendations),
                const SizedBox(height: 16),
              ],
              _MetadataCard(result: result),
              const SizedBox(height: 16),
              _ActionButtons(result: result),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─── Gradient header ──────────────────────────────────────────────────────────
class _ResultHeader extends StatelessWidget {
  final EmergencyAssessment result;
  const _ResultHeader({required this.result});

  static Color _headerColor(RiskLevel level) => switch (level) {
    RiskLevel.low      => const Color(0xFF059669),
    RiskLevel.moderate => const Color(0xFFD97706),
    RiskLevel.high     => const Color(0xFFEA580C),
    RiskLevel.critical => const Color(0xFFDC2626),
  };

  @override
  Widget build(BuildContext context) {
    final color = _headerColor(result.riskLevel);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text('Assessment Result',
                style: TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ),
          const Text('🩺', style: TextStyle(fontSize: 24)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Text(result.riskLevel.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(result.riskLevel.displayName,
                style: const TextStyle(color: Colors.white,
                    fontSize: 22, fontWeight: FontWeight.w900,
                    letterSpacing: -0.5)),
            Text(result.possibleEmergency,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ])),
        ]),
      ]),
    );
  }
}

// ─── Risk gauge card ──────────────────────────────────────────────────────────
class _RiskGaugeCard extends StatefulWidget {
  final EmergencyAssessment result;
  const _RiskGaugeCard({required this.result});
  @override
  State<_RiskGaugeCard> createState() => _RiskGaugeCardState();
}

class _RiskGaugeCardState extends State<_RiskGaugeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.result.riskScore / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _riskColor => switch (widget.result.riskLevel) {
    RiskLevel.low      => const Color(0xFF059669),
    RiskLevel.moderate => const Color(0xFFD97706),
    RiskLevel.high     => const Color(0xFFEA580C),
    RiskLevel.critical => const Color(0xFFDC2626),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.border),
        boxShadow: [BoxShadow(color: _riskColor.withValues(alpha: 0.08),
            blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Risk Score', style: TextStyle(fontWeight: FontWeight.w700,
              fontSize: 15, color: DesignTokens.textStrong)),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Text(
              '${(_anim.value * 100).round()} / 100',
              style: TextStyle(fontWeight: FontWeight.w900,
                  fontSize: 22, color: _riskColor),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => LinearProgressIndicator(
              value: _anim.value,
              backgroundColor: DesignTokens.border,
              valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Four risk level indicators
        Row(children: [
          for (final r in RiskLevel.values) Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(children: [
              Text(r.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(r.label, style: TextStyle(fontSize: 9,
                  fontWeight: widget.result.riskLevel == r
                      ? FontWeight.w900 : FontWeight.w500,
                  color: widget.result.riskLevel == r
                      ? _riskColor : DesignTokens.textSubtle)),
            ]),
          )),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _riskColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(widget.result.riskLevel.advice,
              textAlign: TextAlign.center,
              style: TextStyle(color: _riskColor, fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ]),
    );
  }
}

// ─── Warning banner ───────────────────────────────────────────────────────────
class _WarningBanner extends StatefulWidget {
  final String message;
  const _WarningBanner({required this.message});
  @override
  State<_WarningBanner> createState() => _WarningBannerState();
}

class _WarningBannerState extends State<_WarningBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFFFEF2F2),
              const Color(0xFFFFE4E4), _pulse.value),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDC2626)
              .withValues(alpha: 0.5 + _pulse.value * 0.3)),
        ),
        child: child,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🚨', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Text(widget.message,
            style: const TextStyle(color: Color(0xFF991B1B),
                fontWeight: FontWeight.w700, fontSize: 13, height: 1.5))),
      ]),
    );
  }
}

// ─── First aid card ───────────────────────────────────────────────────────────
class _FirstAidCard extends StatefulWidget {
  final FirstAidGuide guide;
  const _FirstAidCard({required this.guide});
  @override
  State<_FirstAidCard> createState() => _FirstAidCardState();
}

class _FirstAidCardState extends State<_FirstAidCard> {
  bool _showDontDo = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DesignTokens.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF047857)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Text(widget.guide.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🩹 First Aid Guide',
                  style: TextStyle(color: Colors.white70, fontSize: 11,
                      fontWeight: FontWeight.w600)),
              Text(widget.guide.title, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800,
                  fontSize: 15)),
            ])),
          ]),
        ),
        // Steps
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ...widget.guide.steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 24, height: 24,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text('${e.key + 1}',
                      style: const TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669)))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value, style: const TextStyle(
                    fontSize: 13, color: DesignTokens.textStrong, height: 1.4))),
              ]),
            )),
            if (widget.guide.doNotSteps.isNotEmpty) ...[
              GestureDetector(
                onTap: () => setState(() => _showDontDo = !_showDontDo),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Text('🚫', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('What NOT to do',
                        style: TextStyle(fontWeight: FontWeight.w700,
                            fontSize: 13, color: Color(0xFFDC2626)))),
                    Icon(_showDontDo
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFFDC2626)),
                  ]),
                ),
              ),
              if (_showDontDo) ...[
                const SizedBox(height: 8),
                ...widget.guide.doNotSteps.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('❌', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s, style: const TextStyle(
                        fontSize: 12, color: Color(0xFF991B1B), height: 1.4))),
                  ]),
                )),
              ],
            ],
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF059669)
                    .withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Text('☎️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.guide.callToAction,
                    style: const TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 12, color: Color(0xFF059669)))),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Hospitals card ───────────────────────────────────────────────────────────
class _HospitalsCard extends StatelessWidget {
  final List<Hospital> hospitals;
  const _HospitalsCard({required this.hospitals});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F94FF), Color(0xFF2563EB)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            const Text('🏥', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Nearby Hospitals', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                Text('Go to emergency department immediately',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${hospitals.length} found',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        // Hospital list
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: hospitals.asMap().entries.map((e) {
            final h = e.value;
            final isFirst = e.key == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFirst
                    ? const Color(0xFFEFF6FF)
                    : DesignTokens.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFirst
                      ? const Color(0xFF4F94FF).withValues(alpha: 0.3)
                      : DesignTokens.border,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: isFirst
                        ? const Color(0xFF4F94FF).withValues(alpha: 0.15)
                        : DesignTokens.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(h.emergencyAvailable ? '🏥' : '🏛️',
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(h.name, style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13,
                        color: DesignTokens.textStrong))),
                    if (isFirst)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F94FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Nearest', style: TextStyle(
                            color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.w700)),
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Text(h.address, style: const TextStyle(
                      color: DesignTokens.textMuted, fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Text('📍', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 3),
                    Text('${h.distanceKm} km away',
                        style: const TextStyle(
                            fontSize: 11, color: DesignTokens.textMuted)),
                    const Spacer(),
                    GestureDetector(
                      onTap: h.emergencyAvailable
                          ? () {
                              HapticFeedback.mediumImpact();
                              PhoneCallService.call(context, h.phoneNumber,
                                  label: h.name);
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: h.emergencyAvailable
                              ? const Color(0xFFDC2626)
                              : DesignTokens.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.phone_rounded, size: 11,
                              color: h.emergencyAvailable
                                  ? Colors.white : DesignTokens.textMuted),
                          const SizedBox(width: 4),
                          Text(h.phoneNumber, style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800,
                              color: h.emergencyAvailable
                                  ? Colors.white : DesignTokens.textMuted)),
                        ]),
                      ),
                    ),
                  ]),
                ])),
              ]),
            );
          }).toList()),
        ),
      ]),
    );
  }
}

// ─── Metadata card ────────────────────────────────────────────────────────────
class _MetadataCard extends StatelessWidget {
  final EmergencyAssessment result;
  const _MetadataCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, String)>[
      ('🏥', 'Recommended Dept', result.recommendedDept),
      ('🤖', 'AI Confidence',
          '${(result.mlConfidence * 100).toStringAsFixed(0)}%'),
      ('🔍', 'Emergency Type',
          result.emergencyType ?? 'General assessment'),
      ('🕐', 'Assessed at',
          _fmt(result.createdAt)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('📋', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Text('Assessment Details', style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 14,
              color: DesignTokens.textStrong)),
        ]),
        const SizedBox(height: 12),
        ...rows.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.$1, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 10),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.$2, style: const TextStyle(
                  fontSize: 11, color: DesignTokens.textMuted,
                  fontWeight: FontWeight.w500)),
              const SizedBox(height: 1),
              Text(r.$3, style: const TextStyle(
                  fontSize: 13, color: DesignTokens.textStrong,
                  fontWeight: FontWeight.w600)),
            ])),
          ]),
        )),
        if (result.matchedKeywords.isNotEmpty) ...[
          const Divider(height: 12),
          const Text('🔑 Matched signals:',
              style: TextStyle(fontSize: 11,
                  color: DesignTokens.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6,
              children: result.matchedKeywords.take(6).map((kw) =>
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: DesignTokens.dangerContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(kw, style: const TextStyle(
                      fontSize: 10, color: DesignTokens.danger,
                      fontWeight: FontWeight.w600)),
                ),
              ).toList()),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: DesignTokens.warningContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DesignTokens.warningLight),
          ),
          child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('⚠️', style: TextStyle(fontSize: 12)),
            SizedBox(width: 8),
            Expanded(child: Text(
              'This AI assessment is for guidance only. Always consult a qualified medical professional for diagnosis and treatment.',
              style: TextStyle(fontSize: 11, color: Color(0xFF92400E),
                  height: 1.4),
            )),
          ]),
        ),
      ]),
    );
  }

  static String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
  }
}

// ─── Action buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends ConsumerWidget {
  final EmergencyAssessment result;
  const _ActionButtons({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      // SOS — only show for high/critical
      if (result.sosRequired)
        _BigActionButton(
          emoji: '🆘',
          label: 'Send SOS Alert',
          sublabel: 'Alert contacts + share location',
          gradient: const [Color(0xFFDC2626), Color(0xFFB91C1C)],
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SosPage()),
            );
          },
        ),

      if (result.sosRequired) const SizedBox(height: 10),

      // Call ambulance — real dial
      _BigActionButton(
        emoji: '🚑',
        label: 'Call Ambulance — 102',
        sublabel: 'Free emergency service',
        gradient: const [Color(0xFFEA580C), Color(0xFFC2410C)],
        onTap: () {
          HapticFeedback.heavyImpact();
          PhoneCallService.call(context, '102', label: 'Ambulance');
        },
      ),
      const SizedBox(height: 10),

      // Row: New Assessment + Share
      Row(children: [
        Expanded(
          child: _SmallActionButton(
            emoji: '🔄',
            label: 'New Assessment',
            color: DesignTokens.primary,
            onTap: () {
              ref.read(assessmentControllerProvider.notifier).resetAssessment();
              Navigator.of(context).pop();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallActionButton(
            emoji: '📤',
            label: 'Share Result',
            color: const Color(0xFF059669),
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                _snack('📤 Sharing…', const Color(0xFF059669)),
              );
            },
          ),
        ),
      ]),
    ]);
  }

  static SnackBar _snack(String msg, Color color) => SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

class _BigActionButton extends StatelessWidget {
  final String emoji, label, sublabel;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _BigActionButton({
    required this.emoji, required this.label, required this.sublabel,
    required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w800, fontSize: 15)),
            Text(sublabel, style: const TextStyle(
                color: Colors.white70, fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.white70, size: 22),
        ]),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _SmallActionButton({
    required this.emoji, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
      ),
    );
  }
}
