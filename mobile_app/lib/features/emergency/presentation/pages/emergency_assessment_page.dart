import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controllers/assessment_state.dart';
import '../providers/emergency_provider.dart';
import 'emergency_result_page.dart';

// ─── Symptom catalogue ────────────────────────────────────────────────────────
const _kSymptoms = [
  ('🫀', 'Chest pain'),        ('😮‍💨', 'Difficulty breathing'),
  ('🤕', 'Severe headache'),   ('😵', 'Dizziness / Fainting'),
  ('🤢', 'Nausea / Vomiting'), ('🥵', 'High fever'),
  ('💦', 'Excessive sweating'),('💪', 'Arm / leg weakness'),
  ('😶', 'Speech difficulty'), ('👁️', 'Vision problems'),
  ('🩸', 'Bleeding'),          ('🐍', 'Snake bite'),
  ('😮', 'Choking'),           ('🤧', 'Severe allergy'),
  ('🤰', 'Pregnancy pain'),    ('😴', 'Loss of consciousness'),
  ('🤒', 'Body aches'),        ('💊', 'Suspected overdose'),
  ('☠️', 'Poison exposure'),   ('🚗', 'Accident / Trauma'),
];

const _kDangerRed   = Color(0xFFDC2626);
const _kDangerLight = Color(0xFFFEF2F2);

class EmergencyAssessmentPage extends ConsumerStatefulWidget {
  const EmergencyAssessmentPage({super.key});
  @override
  ConsumerState<EmergencyAssessmentPage> createState() => _State();
}

class _State extends ConsumerState<EmergencyAssessmentPage>
    with TickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _progressCtrl;
  late Animation<double> _progressAnim;
  final _descCtrl = TextEditingController();
  final _ageCtrl  = TextEditingController();
  final _customSymCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageCtrl    = PageController();
    _progressCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 400));
    _progressAnim = Tween<double>(begin: 0, end: 1/3)
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _progressCtrl.dispose();
    _descCtrl.dispose();
    _ageCtrl.dispose();
    _customSymCtrl.dispose();
    super.dispose();
  }

  void _animateToStep(int step) {
    _progressCtrl.animateTo((step + 1) / AssessmentState.totalSteps);
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _next() {
    final ctrl = ref.read(assessmentControllerProvider.notifier);
    final state = ref.read(assessmentControllerProvider);
    if (state.currentStep < AssessmentState.totalSteps - 1) {
      ctrl.nextStep();
      _animateToStep(state.currentStep + 1);
    } else {
      _submit();
    }
  }

  void _back() {
    final ctrl  = ref.read(assessmentControllerProvider.notifier);
    final state = ref.read(assessmentControllerProvider);
    if (state.currentStep > 0) {
      ctrl.previousStep();
      _animateToStep(state.currentStep - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    final ctrl = ref.read(assessmentControllerProvider.notifier);
    await ctrl.submitAssessment();

    if (!mounted) return;
    final state = ref.read(assessmentControllerProvider);
    if (state.hasResult) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const EmergencyResultPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentControllerProvider);
    final step  = state.currentStep;

    // Navigate to result when ready (e.g. triggered from step 2 submit)
    ref.listen(assessmentControllerProvider, (prev, next) {
      if (next.hasResult && mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const EmergencyResultPage()));
      }
    });

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Column(children: [
          _Header(step: step, onBack: _back),
          _StepProgress(progress: _progressAnim),
          _StepLabel(step: step),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step0Symptoms(descCtrl: _descCtrl, customCtrl: _customSymCtrl),
                const _Step1Details(),
                const _Step2History(),
              ],
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: _ErrorBanner(message: state.errorMessage!),
            ),
          _BottomBar(
            step:      step,
            isRunning: state.isRunning,
            onNext:    _next,
            onBack:    _back,
          ),
        ]),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  const _Header({required this.step, required this.onBack});

  static const _titles = ['Describe Symptoms', 'Patient Details', 'Medical History'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: onBack,
        ),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🩺 Emergency Assessment',
                style: TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w800)),
            Text(_titles[step],
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${step + 1} / ${AssessmentState.totalSteps}',
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ]),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────
class _StepProgress extends StatelessWidget {
  final Animation<double> progress;
  const _StepProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) => LinearProgressIndicator(
        value: progress.value,
        backgroundColor: DesignTokens.border,
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
        minHeight: 3,
      ),
    );
  }
}

// ─── Step label ───────────────────────────────────────────────────────────────
class _StepLabel extends StatelessWidget {
  final int step;
  const _StepLabel({required this.step});

  static const _labels = [
    ('🔴', 'Select all symptoms you are experiencing'),
    ('🟠', 'Tell us about the patient'),
    ('🟡', 'Medical history & context'),
  ];

  @override
  Widget build(BuildContext context) {
    final item = _labels[step];
    return Container(
      width: double.infinity,
      color: _kDangerLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Text(item.$1, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(child: Text(item.$2,
            style: const TextStyle(fontSize: 12,
                color: Color(0xFF991B1B), fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// ─── Step 0 — Symptoms ────────────────────────────────────────────────────────
class _Step0Symptoms extends ConsumerStatefulWidget {
  final TextEditingController descCtrl;
  final TextEditingController customCtrl;
  const _Step0Symptoms({required this.descCtrl, required this.customCtrl});
  @override
  ConsumerState<_Step0Symptoms> createState() => _Step0State();
}

class _Step0State extends ConsumerState<_Step0Symptoms> {
  void _addCustom() {
    final v = widget.customCtrl.text.trim();
    if (v.isEmpty) return;
    ref.read(assessmentControllerProvider.notifier).addCustomSymptom(v);
    widget.customCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(assessmentControllerProvider);
    final ctrl     = ref.read(assessmentControllerProvider.notifier);
    final selected = state.selectedSymptoms;

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), children: [
      // Description box
      Container(
        decoration: BoxDecoration(color: DesignTokens.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DesignTokens.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text('✏️  Describe the emergency (optional)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                    color: DesignTokens.textStrong)),
          ),
          TextField(
            controller: widget.descCtrl,
            minLines: 2, maxLines: 4,
            onChanged: ctrl.setDescription,
            decoration: const InputDecoration(
              hintText: 'e.g. "Severe chest pain radiating to left arm"',
              hintStyle: TextStyle(color: DesignTokens.textSubtle, fontSize: 12),
              border: InputBorder.none, contentPadding: EdgeInsets.fromLTRB(14, 4, 14, 12),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 14),

      // Severity slider
      _SeveritySlider(level: state.severityLevel, onChanged: ctrl.setSeverityLevel),
      const SizedBox(height: 14),

      // Duration picker
      _DurationPicker(hours: state.durationHours, onChanged: ctrl.setDurationHours),
      const SizedBox(height: 14),

      // Symptom chips
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Select symptoms:', style: TextStyle(fontWeight: FontWeight.w800,
            fontSize: 14, color: DesignTokens.textStrong)),
        if (selected.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _kDangerRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Text('${selected.length} selected',
                style: const TextStyle(color: _kDangerRed, fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ..._kSymptoms.map((s) {
          final isSelected = selected.contains(s.$2);
          return GestureDetector(
            onTap: () => ctrl.toggleSymptom(s.$2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _kDangerRed : DesignTokens.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? _kDangerRed : DesignTokens.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(s.$1, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(s.$2, style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : DesignTokens.textStrong)),
              ]),
            ),
          );
        }),
      ]),
      const SizedBox(height: 14),

      // Custom symptom input
      Row(children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(color: DesignTokens.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DesignTokens.border)),
            child: TextField(
              controller: widget.customCtrl,
              onSubmitted: (_) => _addCustom(),
              decoration: const InputDecoration(
                hintText: '+ Add other symptom',
                hintStyle: TextStyle(color: DesignTokens.textSubtle, fontSize: 12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _addCustom,
          child: Container(
            height: 42, width: 42,
            decoration: BoxDecoration(color: _kDangerRed,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    ]);
  }
}

// ─── Severity slider widget ───────────────────────────────────────────────────
class _SeveritySlider extends StatelessWidget {
  final int level;
  final ValueChanged<int> onChanged;
  const _SeveritySlider({required this.level, required this.onChanged});

  static const _labels = ['Mild', 'Moderate', 'Significant', 'Severe', 'Extreme'];
  static const _colors = [
    Color(0xFF2ECC8B), Color(0xFFFFB829),
    Color(0xFFFF7B3D), Color(0xFFFF4757), Color(0xFF991B1B),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[level - 1];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Pain / Severity Level',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                  color: DesignTokens.textStrong)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Text('${_labels[level - 1]} ($level/5)',
                style: TextStyle(color: color, fontWeight: FontWeight.w800,
                    fontSize: 11)),
          ),
        ]),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color, thumbColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            overlayColor: color.withValues(alpha: 0.1),
            trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: level.toDouble(), min: 1, max: 5, divisions: 4,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('😊 Mild', style: TextStyle(fontSize: 10, color: _colors[0])),
          Text('😱 Extreme', style: TextStyle(fontSize: 10, color: _colors[4])),
        ]),
      ]),
    );
  }
}

// ─── Duration picker ──────────────────────────────────────────────────────────
class _DurationPicker extends StatelessWidget {
  final double hours;
  final ValueChanged<double> onChanged;
  const _DurationPicker({required this.hours, required this.onChanged});

  static const _options = [
    (0.5,  '< 1 hr'),  (1.0, '1 hr'),  (2.0, '2 hrs'),
    (6.0,  '6 hrs'),   (12.0,'12 hrs'), (24.0,'1 day'),
    (48.0, '2 days'),  (72.0,'3+ days'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('How long have symptoms lasted?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
              color: DesignTokens.textStrong)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _options.map((o) {
        final selected = hours == o.$1;
        return GestureDetector(
          onTap: () => onChanged(o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? _kDangerRed : DesignTokens.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? _kDangerRed : DesignTokens.border),
            ),
            child: Text(o.$2, style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : DesignTokens.textStrong)),
          ),
        );
      }).toList()),
    ]);
  }
}

// ─── Step 1 — Patient Details ─────────────────────────────────────────────────
class _Step1Details extends ConsumerStatefulWidget {
  const _Step1Details();
  @override
  ConsumerState<_Step1Details> createState() => _Step1State();
}

class _Step1State extends ConsumerState<_Step1Details> {
  final _ageCtrl    = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void dispose() { _ageCtrl.dispose(); _weightCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentControllerProvider);
    final ctrl  = ref.read(assessmentControllerProvider.notifier);

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), children: [
      // Age
      const _FormLabel(emoji: '🎂', label: 'Age'),
      const SizedBox(height: 6),
      _InputField(
        controller: _ageCtrl,
        hint: 'Enter age (years)',
        keyboardType: TextInputType.number,
        onChanged: (v) => ctrl.setAge(int.tryParse(v)),
      ),
      const SizedBox(height: 14),

      // Gender
      const _FormLabel(emoji: '👤', label: 'Gender'),
      const SizedBox(height: 8),
      Row(children: [
        for (final g in [('Male', '♂️'), ('Female', '♀️'), ('Other', '⚧️')])
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => ctrl.setGender(g.$1.toLowerCase()),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: state.gender == g.$1.toLowerCase()
                      ? _kDangerRed : DesignTokens.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: state.gender == g.$1.toLowerCase()
                          ? _kDangerRed : DesignTokens.border),
                ),
                child: Column(children: [
                  Text(g.$2, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(g.$1, style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: state.gender == g.$1.toLowerCase()
                          ? Colors.white : DesignTokens.textStrong)),
                ]),
              ),
            ),
          )),
      ]),
      const SizedBox(height: 14),

      // Weight
      const _FormLabel(emoji: '⚖️', label: 'Weight (kg) — optional'),
      const SizedBox(height: 6),
      _InputField(
        controller: _weightCtrl,
        hint: 'e.g. 65',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) => ctrl.setWeight(double.tryParse(v)),
      ),
      const SizedBox(height: 14),

      // Pregnancy
      if (state.gender == 'female') ...[
        _ToggleCard(
          emoji: '🤰',
          label: 'Currently pregnant?',
          subtitle: 'Important for risk assessment',
          value: state.isPregnant,
          onChanged: ctrl.setIsPregnant,
          activeColor: const Color(0xFFEC4899),
        ),
        const SizedBox(height: 14),
      ],

      // Info banner
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DesignTokens.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(children: [
          Text('💡', style: TextStyle(fontSize: 14)),
          SizedBox(width: 8),
          Expanded(child: Text(
            'Age and weight help the AI calculate accurate risk scores for children and elderly patients.',
            style: TextStyle(color: DesignTokens.primaryDark,
                fontSize: 12, height: 1.4),
          )),
        ]),
      ),
    ]);
  }
}

// ─── Step 2 — Medical History ─────────────────────────────────────────────────
class _Step2History extends ConsumerWidget {
  const _Step2History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assessmentControllerProvider);
    final ctrl  = ref.read(assessmentControllerProvider.notifier);

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), children: [
      const _SectionTitle(emoji: '🏥', title: 'Existing Medical Conditions'),
      const SizedBox(height: 8),
      _ToggleCard(emoji: '🫀', label: 'Cardiac / Heart disease',
          subtitle: 'History of heart attack, angina, arrhythmia',
          value: state.hasCardiacHistory,   onChanged: ctrl.setCardiacHistory),
      _ToggleCard(emoji: '🩺', label: 'Diabetes',
          subtitle: 'Type 1 or Type 2',
          value: state.hasDiabetes,         onChanged: ctrl.setDiabetes),
      _ToggleCard(emoji: '💉', label: 'Hypertension',
          subtitle: 'High blood pressure',
          value: state.hasHypertension,     onChanged: ctrl.setHypertension),
      _ToggleCard(emoji: '🫁', label: 'Respiratory disease',
          subtitle: 'Asthma, COPD, or similar',
          value: state.hasRespiratoryDisease, onChanged: ctrl.setRespiratoryDisease),
      _ToggleCard(emoji: '🛡️', label: 'Weakened immune system',
          subtitle: 'On chemotherapy, HIV, or immunosuppressants',
          value: state.isImmunocompromised, onChanged: ctrl.setImmunocompromised),
      const SizedBox(height: 14),

      const _SectionTitle(emoji: '⚡', title: 'Recent Events'),
      const SizedBox(height: 8),
      _ToggleCard(emoji: '🚗', label: 'Recent accident / trauma',
          subtitle: 'In the last 7 days',
          value: state.recentAccident,  onChanged: ctrl.setRecentAccident,
          activeColor: const Color(0xFFF97316)),
      _ToggleCard(emoji: '🔪', label: 'Recent surgery',
          subtitle: 'In the last 30 days',
          value: state.recentSurgery,   onChanged: ctrl.setRecentSurgery,
          activeColor: const Color(0xFFF97316)),
      _ToggleCard(emoji: '✈️', label: 'Recent travel',
          subtitle: 'To tropical or epidemic regions',
          value: state.recentTravel,    onChanged: ctrl.setRecentTravel,
          activeColor: const Color(0xFF0EA5E9)),
      _ToggleCard(emoji: '🐍', label: 'Snake / animal bite',
          subtitle: 'Within the last 24 hours',
          value: state.snakeBite,       onChanged: ctrl.setSnakeBite,
          activeColor: const Color(0xFFDC2626)),
      _ToggleCard(emoji: '☠️', label: 'Exposure to poison / chemical',
          subtitle: 'Ingested, inhaled, or skin contact',
          value: state.exposureToPoison, onChanged: ctrl.setExposureToPoison,
          activeColor: const Color(0xFFDC2626)),
      const SizedBox(height: 14),

      // Final warning
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kDangerLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kDangerRed.withValues(alpha: 0.3)),
        ),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('⚠️', style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(child: Text(
            'This AI assessment does not replace a doctor. Always call 102 if you suspect a life-threatening emergency.',
            style: TextStyle(color: Color(0xFF991B1B), fontSize: 12, height: 1.5),
          )),
        ]),
      ),
    ]);
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int step;
  final bool isRunning;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _BottomBar({required this.step, required this.isRunning,
      required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isLast = step == AssessmentState.totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: DesignTokens.surface,
        border: Border(top: BorderSide(color: DesignTokens.border)),
      ),
      child: Row(children: [
        if (step > 0)
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: isRunning ? null : onBack,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.textStrong,
                side: const BorderSide(color: DesignTokens.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (step > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: isRunning ? null : onNext,
            icon: isRunning
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(isLast ? Icons.analytics_rounded : Icons.arrow_forward_ios_rounded,
                    size: 16),
            label: Text(
              isRunning ? 'Analyzing...'
                  : isLast  ? 'Run Assessment'
                  : 'Next Step',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isLast ? _kDangerRed : DesignTokens.primary,
              disabledBackgroundColor: DesignTokens.border,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String emoji, label;
  const _FormLabel({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 15)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontWeight: FontWeight.w700,
        fontSize: 13, color: DesignTokens.textStrong)),
  ]);
}

class _SectionTitle extends StatelessWidget {
  final String emoji, title;
  const _SectionTitle({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 16)),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontWeight: FontWeight.w800,
        fontSize: 15, color: DesignTokens.textStrong)),
  ]);
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  const _InputField({required this.controller, required this.hint,
      required this.keyboardType, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    decoration: BoxDecoration(color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.border)),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: DesignTokens.textSubtle, fontSize: 13),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  );
}

class _ToggleCard extends StatelessWidget {
  final String emoji, label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  const _ToggleCard({required this.emoji, required this.label,
      required this.subtitle, required this.value, required this.onChanged,
      this.activeColor = _kDangerRed});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value ? activeColor.withValues(alpha: 0.07) : DesignTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value ? activeColor.withValues(alpha: 0.4) : DesignTokens.border),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700,
              fontSize: 13, color: value ? activeColor : DesignTokens.textStrong)),
          Text(subtitle, style: const TextStyle(
              color: DesignTokens.textMuted, fontSize: 11)),
        ])),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: value ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: value ? activeColor : DesignTokens.border, width: 2),
          ),
          child: value ? const Icon(Icons.check_rounded,
              color: Colors.white, size: 14) : null,
        ),
      ]),
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: _kDangerLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kDangerRed.withValues(alpha: 0.4))),
    child: Row(children: [
      const Text('⚠️', style: TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Expanded(child: Text(message, style: const TextStyle(
          color: _kDangerRed, fontSize: 12))),
    ]),
  );
}
