import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class EmergencyLoadingWidget extends StatefulWidget {
  const EmergencyLoadingWidget({super.key});

  @override
  State<EmergencyLoadingWidget> createState() => _EmergencyLoadingWidgetState();
}

class _EmergencyLoadingWidgetState extends State<EmergencyLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _anim,
              builder: (_, child) => Transform.scale(
                scale: _anim.value,
                child: child,
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [DesignTokens.danger, Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.danger.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                    child: Text('🚨', style: TextStyle(fontSize: 40))),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading emergency support...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
