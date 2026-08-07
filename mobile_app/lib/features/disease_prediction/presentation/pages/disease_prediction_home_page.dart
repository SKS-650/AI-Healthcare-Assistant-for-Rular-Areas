import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: prefer_const_constructors

import '../../../../../shared/design_system/design_tokens.dart';
import '../../domain/entities/prediction_result.dart';
import '../controller/disease_prediction_controller.dart';
import '../controller/disease_prediction_state.dart';
import '../providers/disease_prediction_provider.dart';
import '../widgets/history/history_card.dart';
import 'prediction_history_page.dart';
import 'prediction_loading_page.dart';
import 'prediction_result_page.dart';

// -----------------------------------------------------------------------------
// Entry point � hosts the stepper wizard
// -----------------------------------------------------------------------------

class DiseasePredictionHomePage extends ConsumerStatefulWidget {
  const DiseasePredictionHomePage({super.key});

  @override
  ConsumerState<DiseasePredictionHomePage> createState() =>
      _DiseasePredictionHomePageState();
}

class _DiseasePredictionHomePageState
    extends ConsumerState<DiseasePredictionHomePage> {
  int _step = 0; // 0 = Patient Info, 1 = Details, 2 = Symptoms

  void _next() {
    final ctrl = ref.read(diseasePredictionControllerProvider.notifier);
    if (_step == 0) {
      final err = ctrl.validateStep1();
      if (err != null) {
        _showError(err);
        return;
      }
    }
    if (_step == 2) {
      final err = ctrl.validateStep3();
      if (err != null) {
        _showError(err);
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PredictionLoadingPage()),
      );
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step--);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: DesignTokens.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  static const _stepLabels = [
    'Tell us about yourself',
    'Duration & severity',
    'Your symptoms',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diseasePredictionControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: Column(
        children: [
          _AppHeader(
            step: _step,
            stepLabels: _stepLabels,
            onHistory: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const PredictionHistoryPage()),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: switch (_step) {
                0 => const _PatientInfoStep(key: ValueKey(0)),
                1 => const _DetailsStep(key: ValueKey(1)),
                _ => const _SymptomsStep(key: ValueKey(2)),
              },
            ),
          ),

          // Latest result (only on step 0)
          if (_step == 0 && state.predictionResult != null)
            _LatestResultBanner(result: state.predictionResult!),

          _BottomNav(
            step: _step,
            onBack: _back,
            onNext: _next,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// App header with progress stepper
// -----------------------------------------------------------------------------

class _AppHeader extends StatelessWidget {
  final int step;
  final List<String> stepLabels;
  final VoidCallback onHistory;

  const _AppHeader({
    required this.step,
    required this.stepLabels,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignTokens.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Text(
                      'AI Symptom Checker',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: onHistory,
                  ),
                ],
              ),
            ),
            // Stepper dots
            _StepperRow(currentStep: step, totalSteps: stepLabels.length),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                stepLabels[step],
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepperRow(
      {required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepBefore = i ~/ 2;
            final isCompleted = currentStep > stepBefore;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
              ),
            );
          }
          final idx = i ~/ 2;
          final isCompleted = currentStep > idx;
          final isCurrent = currentStep == idx;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isCurrent
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white,
                width: isCurrent ? 2.5 : 1.5,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Color(0xFF7C3AED), size: 18)
                  : isCurrent
                      ? const Icon(Icons.person_outline_rounded,
                          color: Color(0xFF7C3AED), size: 18)
                      : const Icon(Icons.tune_rounded,
                          color: Colors.white70, size: 18),
            ),
          );
        }),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// Step 1 � Patient Information
// -----------------------------------------------------------------------------

class _PatientInfoStep extends ConsumerStatefulWidget {
  const _PatientInfoStep({super.key});

  @override
  ConsumerState<_PatientInfoStep> createState() =>
      _PatientInfoStepState();
}

class _PatientInfoStepState extends ConsumerState<_PatientInfoStep> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  bool _weightError = false;
  bool _heightError = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(diseasePredictionControllerProvider);
    if (s.weight != null) _weightCtrl.text = s.weight!.toStringAsFixed(1);
    if (s.height != null) _heightCtrl.text = s.height!.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _onWeightChanged(String v, DiseasePredictionController ctrl) {
    if (v.trim().isEmpty) {
      ctrl.setWeight(null);
      setState(() => _weightError = false);
      return;
    }
    final d = double.tryParse(v);
    final valid = d != null && d >= 1 && d <= 300;
    setState(() => _weightError = !valid);
    if (valid) ctrl.setWeight(d);
  }

  void _onHeightChanged(String v, DiseasePredictionController ctrl) {
    if (v.trim().isEmpty) {
      ctrl.setHeight(null);
      setState(() => _heightError = false);
      return;
    }
    final d = double.tryParse(v);
    final valid = d != null && d >= 30 && d <= 250;
    setState(() => _heightError = !valid);
    if (valid) ctrl.setHeight(d);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diseasePredictionControllerProvider);
    final ctrl =
        ref.read(diseasePredictionControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        _StepHeader(
          icon: Icons.person_outline_rounded,
          title: 'Patient Information',
          subtitle: 'Help the AI provide a more accurate assessment',
          color: DesignTokens.primary,
        ),

        // Age slider
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Age',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.age} yr',
                      style: const TextStyle(
                        color: DesignTokens.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: state.age.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                activeColor: DesignTokens.primary,
                inactiveColor:
                    DesignTokens.primary.withValues(alpha: 0.18),
                onChanged: (v) => ctrl.setAge(v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('1', style: TextStyle(color: DesignTokens.textMuted, fontSize: 11)),
                  Text('100', style: TextStyle(color: DesignTokens.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Biological sex
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Biological Sex',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _GenderChip(
                    label: 'Male',
                    icon: Icons.male_rounded,
                    selected: state.gender == 'male',
                    onTap: () => ctrl.setGender('male'),
                  ),
                  const SizedBox(width: 10),
                  _GenderChip(
                    label: 'Female',
                    icon: Icons.female_rounded,
                    selected: state.gender == 'female',
                    onTap: () => ctrl.setGender('female'),
                  ),
                  const SizedBox(width: 10),
                  _GenderChip(
                    label: 'Other',
                    icon: Icons.person_outline_rounded,
                    selected: state.gender == 'other',
                    onTap: () => ctrl.setGender('other'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Physical measurements
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Physical Measurements (Optional)',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _weightCtrl,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight_outlined,
                      hasError: _weightError,
                      errorText: '1�300',
                      onChanged: (v) => _onWeightChanged(v, ctrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      controller: _heightCtrl,
                      label: 'Height (cm)',
                      icon: Icons.straighten_rounded,
                      hasError: _heightError,
                      errorText: '30�250',
                      onChanged: (v) => _onHeightChanged(v, ctrl),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// -----------------------------------------------------------------------------
// Step 2 � Additional Details (duration, severity, conditions, meds, allergies)
// -----------------------------------------------------------------------------

class _DetailsStep extends ConsumerStatefulWidget {
  const _DetailsStep({super.key});

  @override
  ConsumerState<_DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends ConsumerState<_DetailsStep> {
  final _conditionCtrl = TextEditingController();
  final _medCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();

  @override
  void dispose() {
    _conditionCtrl.dispose();
    _medCtrl.dispose();
    _allergyCtrl.dispose();
    super.dispose();
  }

  String _durationLabel(int days) {
    if (days <= 3) return 'Acute (just started)';
    if (days <= 7) return 'Short-term (< 1 week)';
    if (days <= 14) return 'Sub-acute (1-2 weeks)';
    if (days <= 30) return 'Moderate (2-4 weeks)';
    return 'Chronic (> 1 month)';
  }

  Color _durationColor(int days) {
    if (days <= 3) return DesignTokens.success;
    if (days <= 14) return DesignTokens.warning;
    return DesignTokens.danger;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diseasePredictionControllerProvider);
    final ctrl =
        ref.read(diseasePredictionControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        _StepHeader(
          icon: Icons.tune_rounded,
          title: 'Additional Details',
          subtitle: 'Duration and severity help refine the diagnosis',
          color: const Color(0xFF06B6D4),
        ),

        // Duration slider
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How long have you had these symptoms?',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _durationColor(state.durationDays),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _durationLabel(state.durationDays),
                        style: TextStyle(
                          color: _durationColor(state.durationDays),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.durationDays} days',
                      style: const TextStyle(
                        color: Color(0xFF0891B2),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: state.durationDays.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                activeColor: const Color(0xFF06B6D4),
                inactiveColor:
                    const Color(0xFF06B6D4).withValues(alpha: 0.18),
                onChanged: (v) => ctrl.setDurationDays(v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('1 day',
                      style: TextStyle(
                          color: DesignTokens.textMuted, fontSize: 11)),
                  Text('60 days',
                      style: TextStyle(
                          color: DesignTokens.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Severity picker
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How severe are your symptoms?',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                children: SymptomSeverity.values.map((sev) {
                  final selected = state.severity == sev;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _SeverityChip(
                        severity: sev,
                        selected: selected,
                        onTap: () => ctrl.setSeverity(sev),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Existing conditions
        _TagInputCard(
          title: 'Existing Conditions (Optional)',
          hint: 'e.g. Diabetes, Hypertension...',
          controller: _conditionCtrl,
          tags: state.existingConditions,
          color: DesignTokens.violet,
          onAdd: ctrl.addCondition,
          onRemove: ctrl.removeCondition,
        ),
        const SizedBox(height: 12),

        // Medications
        _TagInputCard(
          title: 'Current Medications (Optional)',
          hint: 'e.g. Aspirin, Metformin...',
          controller: _medCtrl,
          tags: state.medications,
          color: DesignTokens.blue,
          onAdd: ctrl.addMedication,
          onRemove: ctrl.removeMedication,
        ),
        const SizedBox(height: 12),

        // Allergies
        _TagInputCard(
          title: 'Known Allergies (Optional)',
          hint: 'e.g. Penicillin, Peanuts...',
          controller: _allergyCtrl,
          tags: state.allergies,
          color: DesignTokens.orange,
          onAdd: ctrl.addAllergy,
          onRemove: ctrl.removeAllergy,
        ),
        const SizedBox(height: 12),

        // Privacy note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DesignTokens.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: DesignTokens.success.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined,
                  color: DesignTokens.success, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your data is only used for this analysis and is not stored on our servers.',
                  style: TextStyle(
                      color: DesignTokens.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// -----------------------------------------------------------------------------
// Step 3 � Symptoms
// -----------------------------------------------------------------------------

class _SymptomsStep extends ConsumerStatefulWidget {
  const _SymptomsStep({super.key});

  @override
  ConsumerState<_SymptomsStep> createState() => _SymptomsStepState();
}

class _SymptomsStepState extends ConsumerState<_SymptomsStep> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diseasePredictionControllerProvider);
    final ctrl =
        ref.read(diseasePredictionControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        _StepHeader(
          icon: Icons.medical_information_outlined,
          title: 'Your Symptoms',
          subtitle: 'Add all symptoms you are currently experiencing',
          color: DesignTokens.success,
        ),

        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText:
                            'e.g. fever, headache, cough...',
                        hintStyle: const TextStyle(
                            color: DesignTokens.textSubtle,
                            fontSize: 14),
                        prefixIcon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: DesignTokens.primary,
                            size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: DesignTokens.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: DesignTokens.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: DesignTokens.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      textCapitalization:
                          TextCapitalization.sentences,
                      onSubmitted: (v) {
                        ctrl.addSymptom(v);
                        _ctrl.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () {
                      ctrl.addSymptom(_ctrl.text);
                      _ctrl.clear();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primary,
                      minimumSize: const Size(52, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white),
                  ),
                ],
              ),

              // Chips
              if (state.symptoms.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.symptoms.map((s) {
                    return Container(
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DesignTokens.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s,
                              style: const TextStyle(
                                color: DesignTokens.primaryDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => ctrl.removeSymptom(s),
                            child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: DesignTokens.primaryDark),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              if (state.symptoms.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      'No symptoms added yet.\nType above and tap Add.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DesignTokens.textSubtle,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (state.symptoms.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${state.symptoms.length} symptom${state.symptoms.length == 1 ? '' : 's'} added � tap any chip to remove',
              style: const TextStyle(
                  color: DesignTokens.textSubtle,
                  fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}


// -----------------------------------------------------------------------------
// Bottom nav bar
// -----------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNav(
      {required this.step, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        border: Border(top: BorderSide(color: DesignTokens.border)),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            label: const Text('Back',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: DesignTokens.textStrong,
              side: const BorderSide(color: DesignTokens.border),
              minimumSize: const Size(110, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onNext,
              icon: Icon(
                isLast
                    ? Icons.science_outlined
                    : Icons.chevron_right_rounded,
                size: 20,
              ),
              label: Text(
                isLast ? 'Analyze Symptoms' : 'Continue',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isLast ? DesignTokens.success : DesignTokens.primary,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Latest result banner
// -----------------------------------------------------------------------------

class _LatestResultBanner extends ConsumerWidget {
  final PredictionResult result;

  const _LatestResultBanner({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Latest Result',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: DesignTokens.textStrong)),
          ),
          HistoryCard(
            result: result,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PredictionResultPage(result: result),
            )),
          ),
        ],
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// Shared small widgets
// -----------------------------------------------------------------------------

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                Text(subtitle,
                    style: const TextStyle(
                        color: DesignTokens.textMuted,
                        fontSize: 12,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.border),
      ),
      child: child,
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? DesignTokens.primary
                : DesignTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? DesignTokens.primary
                  : DesignTokens.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 22,
                  color: selected
                      ? Colors.white
                      : DesignTokens.textMuted),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : DesignTokens.textMuted,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}


class _SeverityChip extends StatelessWidget {
  final SymptomSeverity severity;
  final bool selected;
  final VoidCallback onTap;

  const _SeverityChip({
    required this.severity,
    required this.selected,
    required this.onTap,
  });

  Color _color() {
    switch (severity) {
      case SymptomSeverity.mild:
        return DesignTokens.success;
      case SymptomSeverity.moderate:
        return DesignTokens.warning;
      case SymptomSeverity.severe:
        return DesignTokens.orange;
      case SymptomSeverity.critical:
        return DesignTokens.danger;
    }
  }

  String _emoji() {
    switch (severity) {
      case SymptomSeverity.mild:
        return '??';
      case SymptomSeverity.moderate:
        return '??';
      case SymptomSeverity.severe:
        return '??';
      case SymptomSeverity.critical:
        return '??';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c : c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? c : c.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji(), style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              severity.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool hasError;
  final String errorText;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hasError,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: hasError ? DesignTokens.danger : DesignTokens.textMuted,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon,
            size: 18,
            color:
                hasError ? DesignTokens.danger : DesignTokens.textMuted),
        errorText: hasError ? errorText : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? DesignTokens.danger : DesignTokens.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? DesignTokens.danger : DesignTokens.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError
                ? DesignTokens.danger
                : DesignTokens.primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: onChanged,
    );
  }
}

/// A card with a title, text input, and removable tag chips.
class _TagInputCard extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final List<String> tags;
  final Color color;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _TagInputCard({
    required this.title,
    required this.hint,
    required this.controller,
    required this.tags,
    required this.color,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                        color: DesignTokens.textSubtle, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: DesignTokens.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: DesignTokens.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: DesignTokens.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (v) {
                    onAdd(v);
                    controller.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  onAdd(controller.text);
                  controller.clear();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.add_rounded, color: color, size: 20),
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => onRemove(t),
                        child: Icon(Icons.close_rounded,
                            size: 13, color: color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
