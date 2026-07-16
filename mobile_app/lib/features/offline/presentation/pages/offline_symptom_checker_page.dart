import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/offline_providers.dart';
import '../../data/services/offline_symptom_engine.dart';
import '../../domain/entities/offline_symptom_result.dart';

class OfflineSymptomCheckerPage extends ConsumerStatefulWidget {
  const OfflineSymptomCheckerPage({super.key});

  @override
  ConsumerState<OfflineSymptomCheckerPage> createState() =>
      _OfflineSymptomCheckerPageState();
}

class _OfflineSymptomCheckerPageState
    extends ConsumerState<OfflineSymptomCheckerPage> {
  // ── Design tokens ──────────────────────────────────────────────────────────
  static const _primary   = Color(0xFF6C63FF);
  static const _accent    = Color(0xFF00BCD4);
  static const _bg      = Color(0xFFF0EFFF);
  static const _cardBg  = Colors.white;

  final _engine    = const OfflineSymptomEngine();
  final _searchCtl = TextEditingController();

  int _age    = 30;
  String _gender = 'male';
  final List<String> _selected = [];
  OfflineSymptomResult? _result;
  bool _loading = false;
  String _searchQuery = '';

  // ── Symptom list (compact — full list is in symptom_dummy_data.dart) ──────
  static const List<String> _allSymptoms = [
    'fever', 'cough', 'headache', 'fatigue', 'chills', 'sore throat',
    'runny nose', 'shortness of breath', 'chest pain', 'nausea', 'vomiting',
    'diarrhea', 'body aches', 'muscle pain', 'joint pain', 'rash', 'itching',
    'dizziness', 'weakness', 'loss of appetite', 'abdominal pain', 'sweating',
    'night sweats', 'weight loss', 'blurred vision', 'frequent urination',
    'excessive thirst', 'burning urination', 'jaundice', 'wheezing',
    'chest tightness', 'difficulty breathing', 'coughing blood', 'eye pain',
    'neck pain', 'back pain', 'skin rash', 'blisters', 'pale skin',
    'cold hands', 'irregular heartbeat', 'arm pain', 'jaw pain',
    'loss of taste', 'loss of smell', 'congestion', 'sneezing', 'throat pain',
  ];

  List<String> get _filteredSymptoms => _searchQuery.isEmpty
      ? _allSymptoms
      : _allSymptoms
          .where((s) => s.contains(_searchQuery.toLowerCase()))
          .toList();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    if (_selected.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final r = _engine.predict(
      symptoms: _selected,
      age:      _age,
      gender:   _gender,
    );
    // Persist locally
    await ref.read(offlineRepositoryProvider).saveSymptomResult(r);
    ref.read(offlineStatsNotifierProvider.notifier).refresh();
    setState(() { _result = r; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Row(children: [
          Text('🤒', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Offline Symptom Checker'),
        ]),
        actions: [
          if (_result != null)
            TextButton(
              onPressed: () => setState(() { _result = null; _selected.clear(); }),
              child: const Text('Reset', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: _result != null
          ? _buildResults()
          : _buildInput(),
    );
  }

  // ── Input view ────────────────────────────────────────────────────────────

  Widget _buildInput() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoBanner(),
        const SizedBox(height: 16),
        _buildPatientInfo(),
        const SizedBox(height: 16),
        _buildSymptomSearch(),
        const SizedBox(height: 12),
        _buildSelectedChips(),
        const SizedBox(height: 8),
        _buildSymptomGrid(),
        const SizedBox(height: 24),
        _buildPredictButton(),
      ],
    );
  }

  Widget _buildInfoBanner() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _accent.withValues(alpha: 0.3)),
    ),
    child: const Row(children: [
      Icon(Icons.offline_bolt_rounded, color: Color(0xFF00BCD4), size: 18),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          '🔴 Offline Mode — AI prediction running entirely on device',
          style: TextStyle(fontSize: 12, color: Color(0xFF006064)),
        ),
      ),
    ]),
  );

  Widget _buildPatientInfo() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _cardBg,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Patient Info', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Age:', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: _age.toDouble(),
              min: 1, max: 100,
              divisions: 99,
              activeColor: _primary,
              label: '$_age yr',
              onChanged: (v) => setState(() => _age = v.round()),
            ),
          ),
          Text('$_age yr',
              style: const TextStyle(fontWeight: FontWeight.w700, color: _primary)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Gender:', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 12),
          ...['male', 'female', 'other'].map((g) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(g[0].toUpperCase() + g.substring(1)),
              selected: _gender == g,
              selectedColor: _primary,
              labelStyle: TextStyle(
                color: _gender == g ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
              onSelected: (_) => setState(() => _gender = g),
            ),
          )),
        ]),
      ],
    ),
  );

  Widget _buildSymptomSearch() => TextField(
    controller: _searchCtl,
    onChanged: (v) => setState(() => _searchQuery = v),
    decoration: InputDecoration(
      hintText: 'Search symptoms…',
      prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
      filled: true,
      fillColor: _cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  Widget _buildSelectedChips() {
    if (_selected.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected (${_selected.length})',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 6,
          children: _selected.map((s) => Chip(
            label: Text(s, style: const TextStyle(fontSize: 12)),
            backgroundColor: _primary.withValues(alpha: 0.1),
            side: BorderSide(color: _primary.withValues(alpha: 0.4)),
            deleteIcon: const Icon(Icons.close_rounded, size: 14, color: _primary),
            onDeleted: () => setState(() => _selected.remove(s)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomGrid() => Wrap(
    spacing: 8, runSpacing: 8,
    children: _filteredSymptoms.map((s) {
      final sel = _selected.contains(s);
      return GestureDetector(
        onTap: () => setState(() {
          if (sel) {
            _selected.remove(s);
          } else {
            _selected.add(s);
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: sel ? _primary : _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel ? _primary : Colors.grey.shade300,
              width: sel ? 1.5 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 6)]
                : null,
          ),
          child: Text(
            s,
            style: TextStyle(
              color: sel ? Colors.white : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _buildPredictButton() => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _selected.isEmpty ? Colors.grey.shade300 : _primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: _selected.isEmpty ? 0 : 4,
      ),
      onPressed: _selected.isEmpty || _loading ? null : _predict,
      icon: _loading
          ? const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.analytics_rounded),
      label: Text(
        _loading
            ? 'Analysing…'
            : _selected.isEmpty
                ? 'Select at least 1 symptom'
                : 'Analyse ${_selected.length} Symptom${_selected.length > 1 ? "s" : ""}',
      ),
    ),
  );

  // ── Results view ──────────────────────────────────────────────────────────

  Widget _buildResults() {
    final r = _result!;
    final riskColor = switch (r.riskLevel) {
      'critical' => const Color(0xFFF44336),
      'high'     => const Color(0xFFFF5722),
      'medium'   => const Color(0xFFFF9800),
      _          => const Color(0xFF4CAF50),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (r.isEmergency) _buildEmergencyBanner(),
        const SizedBox(height: 12),
        _buildResultHeader(r, riskColor),
        const SizedBox(height: 14),
        _buildTopDiseases(r),
        const SizedBox(height: 14),
        _buildRecommendationsCard(r),
        const SizedBox(height: 14),
        _buildDietCard(r),
        const SizedBox(height: 14),
        _buildPrecautionsCard(r),
        const SizedBox(height: 24),
        _buildOfflineDisclaimer(),
      ],
    );
  }

  Widget _buildEmergencyBanner() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF44336).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFF44336), width: 1.5),
    ),
    child: const Row(children: [
      Text('🚨', style: TextStyle(fontSize: 22)),
      SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EMERGENCY SYMPTOMS DETECTED',
              style: TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
          SizedBox(height: 2),
          Text('Call 108 or 112 immediately',
              style: TextStyle(color: Color(0xFFC62828), fontSize: 12)),
        ]),
      ),
    ]),
  ).animate().shake(duration: 600.ms);

  Widget _buildResultHeader(OfflineSymptomResult r, Color riskColor) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_primary, Color(0xFF48CAE4)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(r.primaryDisease,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _pill('${(r.confidence * 100).toStringAsFixed(0)}% match',
            Colors.white.withValues(alpha: 0.2), Colors.white),
        const SizedBox(width: 8),
        _pill(r.riskLevel.toUpperCase(),
            riskColor.withValues(alpha: 0.25), riskColor),
        if (r.isEmergency) ...[
          const SizedBox(width: 8),
          _pill('🚨 EMERGENCY', Colors.red.withValues(alpha: 0.3), Colors.white),
        ],
      ]),
      const SizedBox(height: 10),
      Text('Symptoms analysed: ${r.symptoms.join(", ")}',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
    ]),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);

  Widget _buildTopDiseases(OfflineSymptomResult r) {
    if (r.topDiseases.isEmpty) return const SizedBox.shrink();
    return _infoCard(
      title: '📊 Top Possible Conditions',
      child: Column(
        children: r.topDiseases.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Container(
                width: 22, height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == 0 ? _primary : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Text('${i + 1}',
                    style: TextStyle(
                        color: i == 0 ? Colors.white : Colors.grey.shade600,
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(d.disease, style: const TextStyle(fontSize: 13))),
              Text('${(d.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13, color: _primary)),
              const SizedBox(width: 6),
              SizedBox(
                width: 70,
                child: LinearProgressIndicator(
                  value: d.confidence,
                  backgroundColor: Colors.grey.shade200,
                  color: _primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendationsCard(OfflineSymptomResult r) => _infoCard(
    title: '💊 Recommendations',
    child: Column(
      children: r.recommendations.map((rec) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Expanded(child: Text(rec, style: const TextStyle(fontSize: 13))),
        ]),
      )).toList(),
    ),
  );

  Widget _buildDietCard(OfflineSymptomResult r) => _infoCard(
    title: '🥗 Diet Recommendations',
    child: Wrap(
      spacing: 8, runSpacing: 8,
      children: r.dietRecommendations.map((d) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
        ),
        child: Text(d, style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
      )).toList(),
    ),
  );

  Widget _buildPrecautionsCard(OfflineSymptomResult r) => _infoCard(
    title: '⚠️ Precautions',
    child: Column(
      children: r.precautions.map((p) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('•  ', style: TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.w700)),
          Expanded(child: Text(p, style: const TextStyle(fontSize: 13))),
        ]),
      )).toList(),
    ),
  );

  Widget _buildOfflineDisclaimer() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: const Text(
      '⚠️ This is an offline AI prediction and is NOT a substitute for professional medical advice. '
      'Always consult a qualified healthcare professional for diagnosis and treatment.',
      style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
      textAlign: TextAlign.center,
    ),
  );

  // ── Reusable widgets ──────────────────────────────────────────────────────

  Widget _pill(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _infoCard({required String title, required Widget child}) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _cardBg,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const Divider(height: 16),
      child,
    ]),
  ).animate().fadeIn(duration: 350.ms);
}
