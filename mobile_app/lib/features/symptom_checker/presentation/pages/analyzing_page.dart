import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/design_system/design_tokens.dart';
import '../controllers/symptom_state.dart';
import '../providers/symptom_provider.dart';
import 'result_page.dart';

class AnalyzingPage extends ConsumerStatefulWidget {
  const AnalyzingPage({super.key});

  @override
  ConsumerState<AnalyzingPage> createState() => _AnalyzingPageState();
}

class _AnalyzingPageState extends ConsumerState<AnalyzingPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _progressController;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _progressAnim;
  int _currentStep = 0;

  static const _steps = [
    ('🔍', 'Analyzing symptoms...'),
    ('🧬', 'Cross-referencing database...'),
    ('🤖', 'Running AI model...'),
    ('📊', 'Calculating risk scores...'),
    ('✅', 'Preparing your results...'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    Future.microtask(() async {
      for (var i = 0; i < _steps.length; i++) {
        await Future.delayed(const Duration(milliseconds: 650));
        if (mounted) setState(() => _currentStep = i);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SymptomState>(symptomControllerProvider, (prev, next) {
      if (next.status == SymptomStatus.success &&
          next.predictionResult != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResultPage()),
        );
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
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DesignTokens.primary, DesignTokens.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🧠', style: TextStyle(fontSize: 56)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'AI Analysis in Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textStrong,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Our AI is carefully analyzing your health data\nto provide the most accurate assessment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DesignTokens.textMuted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, _) => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _progressAnim.value,
                        minHeight: 8,
                        backgroundColor: DesignTokens.primaryContainer,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          DesignTokens.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progressAnim.value * 100).toInt()}% Complete',
                      style: const TextStyle(
                        color: DesignTokens.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DesignTokens.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DesignTokens.border),
                ),
                child: Column(
                  children: _steps.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final step = entry.value;
                    final isDone = idx < _currentStep;
                    final isCurrent = idx == _currentStep;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isDone
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: DesignTokens.success,
                                      size: 20,
                                      key: ValueKey('done'),
                                    )
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
                                          decoration: const BoxDecoration(
                                            color: DesignTokens.surfaceMuted,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            step.$1,
                            style: const TextStyle(fontSize: 14),
                          ),
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
