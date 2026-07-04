import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controller/disease_prediction_state.dart';
import '../providers/disease_prediction_provider.dart';
import 'prediction_result_page.dart';

class PredictionLoadingPage extends ConsumerStatefulWidget {
  const PredictionLoadingPage({super.key});

  @override
  ConsumerState<PredictionLoadingPage> createState() =>
      _PredictionLoadingPageState();
}

class _PredictionLoadingPageState extends ConsumerState<PredictionLoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _progressAnim;
  int _currentStep = 0;

  static const _steps = [
    ('🔍', 'Analyzing symptoms...'),
    ('🧬', 'Cross-referencing disease database...'),
    ('🤖', 'Running AI prediction model...'),
    ('📊', 'Calculating confidence scores...'),
    ('✅', 'Preparing your results...'),
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..forward();

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));

    Future.microtask(() async {
      for (var i = 0; i < _steps.length; i++) {
        await Future.delayed(const Duration(milliseconds: 650));
        if (mounted) setState(() => _currentStep = i);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(diseasePredictionControllerProvider.notifier).predict();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(diseasePredictionControllerProvider, (previous, next) {
      if (next.status == DiseasePredictionStatus.success &&
          next.predictionResult != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                PredictionResultPage(result: next.predictionResult!),
          ),
        );
      } else if (next.status == DiseasePredictionStatus.failure) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              next.errorMessage ?? 'Prediction failed. Please try again.'),
          backgroundColor: DesignTokens.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing AI Brain
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) =>
                    Transform.scale(scale: _pulseAnim.value, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        DesignTokens.primary,
                        DesignTokens.blue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.primary.withValues(alpha: 0.45),
                        blurRadius: 36,
                        spreadRadius: 6,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child:
                      const Center(child: Text('🧠', style: TextStyle(fontSize: 58))),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'AI Analysis in Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: DesignTokens.textStrong,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Our AI is carefully analyzing your symptoms\nto provide the most accurate assessment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DesignTokens.textMuted,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 32),

              // Progress bar
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Progress',
                            style: TextStyle(
                                color: DesignTokens.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Text(
                          '${(_progressAnim.value * 100).toInt()}%',
                          style: const TextStyle(
                            color: DesignTokens.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _progressAnim.value,
                        minHeight: 8,
                        backgroundColor: DesignTokens.primaryContainer,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            DesignTokens.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Analysis steps
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DesignTokens.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: DesignTokens.border),
                ),
                child: Column(
                  children: _steps.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final step = entry.value;
                    final isDone = idx < _currentStep;
                    final isCurrent = idx == _currentStep;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isDone
                                  ? const Icon(Icons.check_circle_rounded,
                                      color: DesignTokens.success,
                                      size: 22,
                                      key: ValueKey('done'))
                                  : isCurrent
                                      ? SizedBox(
                                          key: const ValueKey('current'),
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: DesignTokens.primary,
                                          ),
                                        )
                                      : Container(
                                          key: const ValueKey('pending'),
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: DesignTokens.surfaceMuted,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: DesignTokens.border),
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(step.$1,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              step.$2,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDone || isCurrent
                                    ? DesignTokens.textStrong
                                    : DesignTokens.textSubtle,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
