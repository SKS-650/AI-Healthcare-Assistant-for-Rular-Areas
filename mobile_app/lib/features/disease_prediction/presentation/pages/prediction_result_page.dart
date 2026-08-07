import 'dart:math' as math;
// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/prediction_result.dart';
import '../../../medical_chatbot/presentation/pages/chat_page.dart';
import '../widgets/charts/confidence_chart.dart';
import 'disease_detail_page.dart';
import 'recommendation_page.dart';

class PredictionResultPage extends StatelessWidget {
  final PredictionResult result;

  const PredictionResultPage({super.key, required this.result});

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return DesignTokens.success;
      case 'medium':
      case 'moderate':
        return DesignTokens.warning;
      case 'high':
        return DesignTokens.orange;
      case 'critical':
        return DesignTokens.danger;
      default:
        return DesignTokens.primary;
    }
  }

  void _shareResult(BuildContext context) {
    final riskPct = (result.riskScore * 100).round();
    final text = 'AI Symptom Checker Result\n\n'
        'Primary diagnosis: ${result.disease.name}\n'
        'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%\n'
        'Risk level: ${result.riskLevel} ($riskPct%)\n\n'
        'This is an AI assessment only — not a medical diagnosis.\n'
        'Please consult a qualified healthcare professional.';
    // Show a share sheet using a dialog (no share plugin dependency needed)
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DesignTokens.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(children: [
          Text('📤', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Share Result',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                  color: DesignTokens.textStrong)),
        ]),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DesignTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DesignTokens.border),
          ),
          child: Text(text,
              style: const TextStyle(fontSize: 13, color: DesignTokens.textMuted,
                  height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rc = _riskColor(result.riskLevel);
    final riskPct = (result.riskScore * 100).round();

    return Scaffold(
      backgroundColor: DesignTokens.background,
      // No AppBar — navigation is embedded in the hero banner to avoid overlap
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Hero banner (includes back/home buttons) ────────────────────
          _HeroBanner(result: result, riskColor: rc, riskPct: riskPct),

          // ── Emergency alert ───────────────────────────────────────────────
          if (result.isEmergency || result.emergencyAlert != null)
            _EmergencyAlert(message: result.emergencyAlert),

          const SizedBox(height: 12),

          // ── Risk Assessment card ──────────────────────────────────────────
          _SectionCard(
            children: [
              _SectionHeader(
                icon: Icons.monitor_heart_outlined,
                label: 'Risk Assessment',
                sub: 'Based on your symptoms and profile',
                badge: result.riskLevel,
                badgeColor: rc,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child:
                          ConfidenceChart(confidence: result.confidence)),
                  Container(width: 1, height: 90, color: DesignTokens.border),
                  Expanded(
                      child: _RiskScoreGauge(
                          riskScore: result.riskScore,
                          riskLevel: result.riskLevel)),
                ],
              ),
              if (result.riskFactors.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: DesignTokens.border),
                const SizedBox(height: 12),
                const Text('Contributing Factors',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: DesignTokens.textStrong)),
                const SizedBox(height: 8),
                ...result.riskFactors.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: rc,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(f,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: DesignTokens.textMuted,
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ── Primary Diagnosis ─────────────────────────────────────────────
          _SectionCard(
            children: [
              _SectionHeader(
                icon: Icons.biotech_outlined,
                label: 'Primary Diagnosis',
                sub: 'Most likely condition',
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignTokens.primary,
                      DesignTokens.primary.withValues(alpha: 0.75)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.disease.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Confidence',
                        style: TextStyle(
                            color: Colors.white60, fontSize: 11)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: result.confidence.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(result.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Differential Diagnosis ────────────────────────────────────────
          if (result.topDiseases.length > 1)
            _SectionCard(
              children: [
                _SectionHeader(
                  icon: Icons.format_list_bulleted_rounded,
                  label: 'Differential Diagnosis',
                  sub: 'Other possible conditions',
                ),
                const SizedBox(height: 12),
                ...result.topDiseases
                    .skip(1)
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final rank = entry.key + 2;
                  final d = entry.value;
                  final pct = (d.value * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: DesignTokens.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('$rank',
                                style: const TextStyle(
                                  color: DesignTokens.primaryDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                )),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(d.key,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: DesignTokens.textStrong,
                                  )),
                              const SizedBox(height: 3),
                              LinearProgressIndicator(
                                value: d.value.clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor: DesignTokens.border,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  DesignTokens.primary
                                      .withValues(alpha: 0.6),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 42,
                          child: Text(
                            '${pct.toStringAsFixed(1)}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),

          // ── Critical symptoms ─────────────────────────────────────────────
          if (result.criticalSymptoms.isNotEmpty)
            _SectionCard(
              children: [
                _SectionHeader(
                  icon: Icons.warning_amber_rounded,
                  label: 'Critical Symptoms Detected',
                  sub: 'These symptoms require prompt attention',
                  badgeColor: DesignTokens.danger,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.criticalSymptoms
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: DesignTokens.danger
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: DesignTokens.danger
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(s,
                                style: const TextStyle(
                                    color: DesignTokens.danger,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ],
            ),

          // ── Patient Profile Summary ────────────────────────────────────────
          _PatientProfileCard(result: result),

          // ── Action buttons ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline_rounded, size: 18),
                    label: const Text('Disease Info',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DiseaseDetailPage(disease: result.disease),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.primary,
                      side: const BorderSide(color: DesignTokens.primary),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.healing_rounded, size: 18),
                    label: const Text('Care Plan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecommendationPage(result: result),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Chat with AI button ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _ChatbotQueryButton(result: result),
          ),

          // ── New Analysis + Share row ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('New Analysis',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => _shareResult(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.primary,
                      side: const BorderSide(color: DesignTokens.primary),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Disclaimer ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DesignTokens.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: DesignTokens.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This AI assessment is not a medical diagnosis. Always consult a qualified healthcare professional.',
                      style: TextStyle(
                          color: DesignTokens.textMuted,
                          fontSize: 11,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero banner — self-contained with nav buttons, no AppBar needed
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final PredictionResult result;
  final Color riskColor;
  final int riskPct;

  const _HeroBanner({
    required this.result,
    required this.riskColor,
    required this.riskPct,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [riskColor, riskColor.withValues(alpha: 0.80)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // ── Navigation row ──────────────────────────────────────────────
          SizedBox(height: topPad + 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Results',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.home_rounded,
                      size: 22, color: Colors.white),
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ],
            ),
          ),
          // ── Content ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Analysis Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.riskLevel} Risk  •  Risk Score $riskPct%',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Risk score gauge  (replaces the old half-circle with a clear numeric display)
// ─────────────────────────────────────────────────────────────────────────────

class _RiskScoreGauge extends StatelessWidget {
  final double riskScore;
  final String riskLevel;

  const _RiskScoreGauge(
      {required this.riskScore, required this.riskLevel});

  Color _color(String r) {
    switch (r.toLowerCase()) {
      case 'low':
        return DesignTokens.success;
      case 'medium':
      case 'moderate':
        return DesignTokens.warning;
      case 'high':
        return DesignTokens.orange;
      case 'critical':
        return DesignTokens.danger;
      default:
        return DesignTokens.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = (riskScore * 100).round();
    final color = _color(riskLevel);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arc  (top half only via CustomPaint)
              CustomPaint(
                size: const Size(80, 80),
                painter: _ArcPainter(
                  value: riskScore.clamp(0.0, 1.0),
                  color: color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$pct%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1,
                      )),
                  const Text('Risk Score',
                      style: TextStyle(
                          fontSize: 9,
                          color: DesignTokens.textMuted,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${riskLevel[0].toUpperCase()}${riskLevel.substring(1)} Risk',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value; // 0-1
  final Color color;

  const _ArcPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;
    final radius = size.width * 0.42;
    final rect =
        Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    const startAngle = math.pi;
    const sweepFull = math.pi;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepFull, false, bgPaint);
    canvas.drawArc(
        rect, startAngle, sweepFull * value, false, fgPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.value != value || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _EmergencyAlert extends StatelessWidget {
  final String? message;

  const _EmergencyAlert({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: DesignTokens.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🚨', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message ??
                  'This may be an emergency. Seek immediate medical attention.',
              style: const TextStyle(
                  color: DesignTokens.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final String? badge;
  final Color? badgeColor;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.sub,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: DesignTokens.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: DesignTokens.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: DesignTokens.textStrong)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 11, color: DesignTokens.textMuted)),
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (badgeColor ?? DesignTokens.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: (badgeColor ?? DesignTokens.primary)
                      .withValues(alpha: 0.4)),
            ),
            child: Text(badge!,
                style: TextStyle(
                    color: badgeColor ?? DesignTokens.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Patient Profile Summary card  (shows how profile influenced the analysis)
// ─────────────────────────────────────────────────────────────────────────────

class _PatientProfileCard extends StatelessWidget {
  final PredictionResult result;
  const _PatientProfileCard({required this.result});

  @override
  Widget build(BuildContext context) {
    // Only render if there is something useful to show
    final hasBmi = result.bmi != null;
    final hasDuration = result.durationCategory != null;
    final hasSeverity = result.severityLabel != null;
    final hasConditions = result.existingConditions.isNotEmpty;
    final hasMeds = result.medications.isNotEmpty;
    final hasAllergies = result.allergies.isNotEmpty;
    final hasAugLog = result.augmentationLog.isNotEmpty;
    final hasAny = hasBmi || hasDuration || hasSeverity ||
        hasConditions || hasMeds || hasAllergies || hasAugLog;
    if (!hasAny) return const SizedBox.shrink();

    return _SectionCard(
      children: [
        _SectionHeader(
          icon: Icons.person_outlined,
          label: 'Profile Used in Analysis',
          sub: 'How your information shaped the result',
        ),
        const SizedBox(height: 12),

        // ── Key metrics row ───────────────────────────────────────────────
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (hasBmi)
              _ProfileChip(
                icon: Icons.monitor_weight_outlined,
                label: 'BMI ${result.bmi!.toStringAsFixed(1)}',
                sub: result.bmiCategory ?? '',
                color: _bmiColor(result.bmi!),
              ),
            if (hasDuration)
              _ProfileChip(
                icon: Icons.schedule_rounded,
                label: result.durationCategory!,
                sub: 'Duration',
                color: DesignTokens.blue,
              ),
            if (hasSeverity)
              _ProfileChip(
                icon: Icons.bar_chart_rounded,
                label: result.severityLabel!,
                sub: 'Severity',
                color: _severityColor(result.severityLabel!),
              ),
          ],
        ),

        // ── Conditions / meds / allergies ────────────────────────────────
        if (hasConditions) ...[
          const SizedBox(height: 10),
          _ProfileTagRow(
            label: 'Conditions',
            tags: result.existingConditions,
            color: DesignTokens.violet,
          ),
        ],
        if (hasMeds) ...[
          const SizedBox(height: 6),
          _ProfileTagRow(
            label: 'Medications',
            tags: result.medications,
            color: DesignTokens.blue,
          ),
        ],
        if (hasAllergies) ...[
          const SizedBox(height: 6),
          _ProfileTagRow(
            label: 'Allergies',
            tags: result.allergies,
            color: DesignTokens.orange,
          ),
        ],

        // ── Augmentation log (collapsible) ───────────────────────────────
        if (hasAugLog) ...[
          const SizedBox(height: 10),
          const Divider(height: 1, color: DesignTokens.border),
          const SizedBox(height: 10),
          _AugmentationLogSection(
            log: result.augmentationLog,
            augmentedCount: result.augmentedSymptomCount,
          ),
        ],
      ],
    );
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return DesignTokens.warning;
    if (bmi < 25) return DesignTokens.success;
    if (bmi < 30) return DesignTokens.warning;
    return DesignTokens.danger;
  }

  Color _severityColor(String label) {
    switch (label.toLowerCase()) {
      case 'mild':     return DesignTokens.success;
      case 'moderate': return DesignTokens.warning;
      case 'severe':   return DesignTokens.orange;
      case 'critical': return DesignTokens.danger;
      default:         return DesignTokens.primary;
    }
  }
}

class _ProfileChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  const _ProfileChip({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: color)),
              if (sub.isNotEmpty)
                Text(sub,
                    style: const TextStyle(
                        fontSize: 10, color: DesignTokens.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileTagRow extends StatelessWidget {
  final String label;
  final List<String> tags;
  final Color color;
  const _ProfileTagRow({
    required this.label,
    required this.tags,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textMuted)),
        ),
        Expanded(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: tags
                .take(4)
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(t,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AugmentationLogSection extends StatefulWidget {
  final List<String> log;
  final int? augmentedCount;
  const _AugmentationLogSection({required this.log, this.augmentedCount});

  @override
  State<_AugmentationLogSection> createState() =>
      _AugmentationLogSectionState();
}

class _AugmentationLogSectionState extends State<_AugmentationLogSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 14, color: DesignTokens.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'AI clinical augmentation'
                  '${widget.augmentedCount != null ? " · ${widget.log.length} additions" : ""}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.primary),
                ),
              ),
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: DesignTokens.primary,
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Text(
            'Your profile caused ${widget.log.length} additional symptom(s) '
            'to be included in the model analysis:',
            style: const TextStyle(
                fontSize: 11, color: DesignTokens.textMuted, height: 1.5),
          ),
          const SizedBox(height: 6),
          ...widget.log.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: DesignTokens.primary, fontSize: 11)),
                    Expanded(
                      child: Text(entry,
                          style: const TextStyle(
                              fontSize: 11,
                              color: DesignTokens.textMuted,
                              height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Chatbot Query Button
// Opens the chat page pre-loaded with the diagnosis as context
// ─────────────────────────────────────────────────────────────────────────────

class _ChatbotQueryButton extends StatelessWidget {
  final PredictionResult result;

  const _ChatbotQueryButton({required this.result});

  String _buildInitialMessage() {
    final disease = result.disease.name;
    final risk = result.riskLevel;
    final confidence = (result.confidence * 100).toStringAsFixed(1);
    final symptoms = result.disease.symptoms.take(4).join(', ');
    return 'I just used the AI Symptom Checker. '
        'The result shows "$disease" as the most likely condition '
        '($confidence% confidence, $risk risk).'
        '${symptoms.isNotEmpty ? " My symptoms include: $symptoms." : ""} '
        'Can you explain this condition and what I should do next?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  initialMessage: _buildInitialMessage(),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ask AI Chatbot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Get detailed explanation & follow-up advice',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
