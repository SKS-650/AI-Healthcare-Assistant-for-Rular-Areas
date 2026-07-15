import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/symptom_check_response.dart';

class ResultsPage extends StatefulWidget {
  final SymptomCheckResponse response;
  const ResultsPage({super.key, required this.response});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _scoreCtrl;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _scoreAnim;

  static const _primary = Color(0xFF6C63FF);
  static const _bg = Color(0xFFF8F7FF);

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scoreCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideUp = Tween<double>(begin: 40, end: 0).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _scoreAnim = CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic);

    Future.delayed(const Duration(milliseconds: 100), () {
      _entryCtrl.forward();
      _scoreCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final risk = widget.response.riskAssessment;
    final riskColor = _riskColor(risk.riskLevel);

    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: _entryCtrl,
        builder: (_, __) => Opacity(
          opacity: _fadeIn.value,
          child: Transform.translate(
            offset: Offset(0, _slideUp.value),
            child: CustomScrollView(
              slivers: [
                _buildSliverHeader(riskColor),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (risk.isEmergency) _buildEmergencyAlert(),
                      const SizedBox(height: 4),
                      _buildRiskScoreCard(riskColor),
                      const SizedBox(height: 16),
                      _buildPrimaryDiagnosisCard(),
                      const SizedBox(height: 16),
                      _buildDifferentialDiagnosis(),
                      const SizedBox(height: 16),
                      _buildRecommendationsCard(),
                      const SizedBox(height: 16),
                      _buildSymptomSummary(),
                      const SizedBox(height: 16),
                      _buildDisclaimerCard(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(Color riskColor) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: riskColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [riskColor, riskColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Icon(_riskIcon(widget.response.riskAssessment.riskLevel), color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text('Analysis Complete', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.response.riskAssessment.riskLevelLabel,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              ],
            ),
          ),
        ),
        title: const Text('Results', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
    );
  }

  Widget _buildEmergencyAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade400, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ EMERGENCY ALERT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(widget.response.emergencyAlert ?? 'Seek immediate medical attention.',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12, height: 1.4)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call Emergency (108)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskScoreCard(Color riskColor) {
    final risk = widget.response.riskAssessment;
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              _sectionIcon(Icons.monitor_heart_rounded, riskColor),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Risk Assessment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333360))),
                    Text('Based on your symptoms and profile', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: riskColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(risk.riskLevelLabel, style: TextStyle(color: riskColor, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _scoreAnim,
            builder: (_, __) => SizedBox(
              height: 130,
              child: CustomPaint(
                painter: _RiskGaugePainter(
                  score: risk.riskScore * _scoreAnim.value,
                  color: riskColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${(risk.riskScore * _scoreAnim.value * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: riskColor),
                      ),
                      const Text('Risk Score', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (risk.riskFactors.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Contributing Factors', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: risk.riskFactors.map((f) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: riskColor.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(20)),
                child: Text(f, style: TextStyle(color: riskColor, fontSize: 12, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
          ],
          if (risk.criticalSymptoms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Critical: ${risk.criticalSymptoms.join(', ')}',
                        style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryDiagnosisCard() {
    final conf = widget.response.primaryConfidence;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIcon(Icons.biotech_rounded, _primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Primary Diagnosis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333360))),
                    Text('Most likely condition', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(widget.response.primaryDisease),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Confidence', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AnimatedBuilder(
                              animation: _scoreAnim,
                              builder: (_, __) => LinearProgressIndicator(
                                value: conf * _scoreAnim.value,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    AnimatedBuilder(
                      animation: _scoreAnim,
                      builder: (_, __) => Text(
                        '${(conf * _scoreAnim.value * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferentialDiagnosis() {
    final diseases = widget.response.topDiseases;
    if (diseases.length <= 1) return const SizedBox.shrink();
    final others = diseases.skip(1).toList();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIcon(Icons.list_alt_rounded, Colors.teal),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Differential Diagnosis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333360))),
                  Text('Other possible conditions', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...others.take(4).toList().asMap().entries.map((e) {
            final idx = e.key;
            final d = e.value;
            final pct = d.confidence;
            final color = [Colors.teal, Colors.blue, Colors.indigo, Colors.purple][idx % 4];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Center(child: Text('${idx + 2}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_capitalize(d.disease), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333360))),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AnimatedBuilder(
                            animation: _scoreAnim,
                            builder: (_, __) => LinearProgressIndicator(
                              value: pct * _scoreAnim.value,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation(color),
                              minHeight: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: _scoreAnim,
                    builder: (_, __) => Text(
                      '${(pct * _scoreAnim.value * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final rec = widget.response.recommendations;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIcon(Icons.local_hospital_rounded, Colors.green),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333360))),
                  Text('Medical advice based on your results', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Primary action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services_rounded, color: Colors.green, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(rec.primaryAction, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Department + Urgency
          Row(
            children: [
              Expanded(child: _infoChip(Icons.apartment_rounded, 'Department', rec.department, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _infoChip(Icons.access_time_rounded, 'Urgency', rec.urgency, Colors.orange)),
            ],
          ),
          if (rec.actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _subheading('Suggested Actions'),
            const SizedBox(height: 8),
            ...rec.actions.take(4).map((a) => _bulletItem(a, Icons.check_circle_outline_rounded, Colors.green)),
          ],
          if (rec.careAdvice.isNotEmpty) ...[
            const SizedBox(height: 14),
            _subheading('Care Advice'),
            const SizedBox(height: 8),
            ...rec.careAdvice.take(4).map((a) => _bulletItem(a, Icons.info_outline_rounded, Colors.blue)),
          ],
          if (rec.emergencyContact) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.phone_in_talk_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('Emergency contact recommended — call 108', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomSummary() {
    final summary = widget.response.inputSummary;
    final symptoms = (summary['symptoms'] as List?)?.cast<String>() ?? [];
    if (symptoms.isEmpty) return const SizedBox.shrink();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIcon(Icons.assignment_rounded, Colors.indigo),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Input Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333360))),
                  Text('${symptoms.length} symptom(s) analyzed', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: symptoms.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
              ),
              child: Text(_capitalize(s), style: const TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryChip(Icons.calendar_today_rounded, 'Duration', '${summary['duration_days'] ?? '-'} days'),
              const SizedBox(width: 8),
              _summaryChip(Icons.warning_rounded, 'Severity', _severityLabel(summary['severity'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This AI analysis is for informational purposes only and does not replace professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider.',
              style: TextStyle(color: Colors.amber.shade800, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          label: const Text('New Analysis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share_rounded, color: _primary),
          label: const Text('Share With Doctor', style: TextStyle(color: _primary, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: const BorderSide(color: _primary, width: 1.5),
          ),
        ),
      ],
    );
  }

  // ─── Helper Widgets ──────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _sectionIcon(IconData icon, Color color) {
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
                Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333360))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _subheading(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF555580)));

  Widget _bulletItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF555580), height: 1.4))),
        ],
      ),
    );
  }

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low': return const Color(0xFF00B894);
      case 'medium': return const Color(0xFFFF9F43);
      case 'high': return const Color(0xFFFF6B35);
      case 'critical': return const Color(0xFFE63946);
      default: return Colors.grey;
    }
  }

  IconData _riskIcon(String level) {
    switch (level.toLowerCase()) {
      case 'low': return Icons.check_circle_rounded;
      case 'medium': return Icons.info_rounded;
      case 'high': return Icons.warning_rounded;
      case 'critical': return Icons.emergency_rounded;
      default: return Icons.help_rounded;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  String _severityLabel(dynamic sev) {
    switch (sev) {
      case 1: return 'Mild';
      case 2: return 'Moderate';
      case 3: return 'Severe';
      case 4: return 'Critical';
      default: return '$sev';
    }
  }
}

// ─── Gauge Painter ────────────────────────────────────────────────────────
class _RiskGaugePainter extends CustomPainter {
  final double score; // 0..1
  final Color color;
  const _RiskGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.85;
    final r = size.width * 0.4;
    const start = math.pi;
    const sweep = math.pi;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      start, sweep, false,
      Paint()..color = Colors.grey.shade200..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round,
    );

    // Gradient arc
    final gradPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: math.pi,
        endAngle: math.pi * 2,
        colors: [color.withValues(alpha: 0.3), color],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      start, sweep * score, false,
      gradPaint,
    );

    // Indicator dot
    final angle = start + sweep * score;
    final dotX = cx + r * math.cos(angle);
    final dotY = cy + r * math.sin(angle);
    canvas.drawCircle(Offset(dotX, dotY), 8, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(dotX, dotY), 8, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(_RiskGaugePainter old) => old.score != score;
}
