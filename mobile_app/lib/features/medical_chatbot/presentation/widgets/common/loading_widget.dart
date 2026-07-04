import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class ChatbotLoadingWidget extends StatefulWidget {
  const ChatbotLoadingWidget({super.key});

  @override
  State<ChatbotLoadingWidget> createState() => _ChatbotLoadingWidgetState();
}

class _ChatbotLoadingWidgetState extends State<ChatbotLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignTokens.primary, DesignTokens.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 3,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 38))),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Starting AI assistant...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
