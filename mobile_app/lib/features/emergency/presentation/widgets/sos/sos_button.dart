import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class SosButton extends StatefulWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const SosButton({
    super.key,
    this.loading = false,
    this.onPressed,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: enabled ? _scaleAnim.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: enabled ? widget.onPressed : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse rings
            if (enabled) ...[
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => Container(
                  width: 160 + _pulse.value * 20,
                  height: 160 + _pulse.value * 20,
                  decoration: BoxDecoration(
                    color: DesignTokens.danger.withValues(
                      alpha: 0.08 * (1 - _pulse.value),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  color: DesignTokens.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ],
            // Main button
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: enabled
                    ? const LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !enabled ? DesignTokens.surfaceMuted : null,
                shape: BoxShape.circle,
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: DesignTokens.danger.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: widget.loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🆘', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 4),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: enabled
                                ? Colors.white
                                : DesignTokens.textMuted,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
