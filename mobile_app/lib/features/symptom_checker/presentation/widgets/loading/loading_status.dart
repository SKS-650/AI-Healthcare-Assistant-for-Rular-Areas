import 'package:flutter/material.dart';

class LoadingStatus extends StatefulWidget {
  const LoadingStatus({super.key});

  @override
  State<LoadingStatus> createState() => _LoadingStatusState();
}

class _LoadingStatusState extends State<LoadingStatus> {
  int _currentStepIndex = 0;
  
  // Simulated operational clinical processing pipelines
  final List<String> _statusSteps = [
    'Parsing localized symptom anomalies...',
    'Evaluating cross-reference medical history vectors...',
    'Synthesizing lifestyle environmental multipliers...',
    'Mapping neural probability distribution weights...',
    'Finalizing diagnostic evaluation matrices...',
  ];

  @override
  void initState() {
    super.initState();
    _loopStatusUpdates();
  }

  void _loopStatusUpdates() async {
    for (int i = 0; i < _statusSteps.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 650));
      if (mounted) {
        setState(() {
          _currentStepIndex = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _statusSteps[_currentStepIndex],
            key: ValueKey<int>(_currentStepIndex),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please do not exit or close the application.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}