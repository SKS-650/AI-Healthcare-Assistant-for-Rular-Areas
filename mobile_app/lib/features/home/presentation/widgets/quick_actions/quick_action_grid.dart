import 'package:flutter/material.dart';

import '../../../../../routing/route_names.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/quick_action.dart';

class QuickActionGrid extends StatelessWidget {
  final List<QuickAction> actions;
  const QuickActionGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.86,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _QuickActionItem(
        action: actions[i],
        onTap: () => _navigate(context, actions[i].id),
      ),
    );
  }

  void _navigate(BuildContext context, String id) {
    switch (id) {
      case 'symptom':
        Navigator.of(context).pushNamed(RouteNames.symptomChecker);
      case 'prediction':
        Navigator.of(context).pushNamed(RouteNames.diseasePrediction);
      case 'chatbot':
        Navigator.of(context).pushNamed(RouteNames.chatbot);
      case 'emergency':
        Navigator.of(context).pushNamed(RouteNames.emergency);
      case 'records':
        Navigator.of(context).pushNamed(RouteNames.healthRecords);
      case 'hospitals':
        Navigator.of(context).pushNamed(RouteNames.nearbyHealthcare);
      case 'education':
        Navigator.of(context).pushNamed(RouteNames.healthEducation);
      case 'profile':
        Navigator.of(context).pushNamed(RouteNames.profile);
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon!')),
        );
    }
  }
}

class _QuickActionItem extends StatefulWidget {
  final QuickAction action;
  final VoidCallback onTap;
  const _QuickActionItem({required this.action, required this.onTap});

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1, end: 0.91)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _ActionCfg.of(widget.action.id);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: cfg.bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cfg.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: cfg.iconGrad[0].withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gradient icon container with emoji
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: cfg.iconGrad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: cfg.iconGrad[0].withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(cfg.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.action.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: DesignTokens.textStrong,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCfg {
  final String emoji;
  final Color bg;
  final Color border;
  final List<Color> iconGrad;

  const _ActionCfg({
    required this.emoji,
    required this.bg,
    required this.border,
    required this.iconGrad,
  });

  static _ActionCfg of(String id) {
    switch (id) {
      case 'symptom':
        return const _ActionCfg(
          emoji: '🩺',
          bg: Color(0xFFF0EBFF),
          border: Color(0xFFD4C8FF),
          iconGrad: [Color(0xFF926EFF), Color(0xFF6B47E8)],
        );
      case 'prediction':
        return const _ActionCfg(
          emoji: '🧠',
          bg: Color(0xFFE8F1FF),
          border: Color(0xFFBFD4FF),
          iconGrad: [Color(0xFF4F94FF), Color(0xFF2563EB)],
        );
      case 'chatbot':
        return const _ActionCfg(
          emoji: '🤖',
          bg: Color(0xFFE4FAFA),
          border: Color(0xFFAAE8E8),
          iconGrad: [Color(0xFF18C8C8), Color(0xFF0B9B9B)],
        );
      case 'emergency':
        return const _ActionCfg(
          emoji: '🚨',
          bg: Color(0xFFFFECED),
          border: Color(0xFFFFBEC2),
          iconGrad: [Color(0xFFFF4757), Color(0xFFCC2233)],
        );
      case 'records':
        return const _ActionCfg(
          emoji: '📋',
          bg: Color(0xFFFFF0E8),
          border: Color(0xFFFFCAA8),
          iconGrad: [Color(0xFFFF7B3D), Color(0xFFE55A1A)],
        );
      case 'hospitals':
        return const _ActionCfg(
          emoji: '🏥',
          bg: Color(0xFFE4FBF0),
          border: Color(0xFFAAEFCF),
          iconGrad: [Color(0xFF2ECC8B), Color(0xFF16A34A)],
        );
      case 'education':
        return const _ActionCfg(
          emoji: '📚',
          bg: Color(0xFFFFF8E6),
          border: Color(0xFFFFE08A),
          iconGrad: [Color(0xFFFFB829), Color(0xFFD98E00)],
        );
      default:
        return const _ActionCfg(
          emoji: '⚕️',
          bg: Color(0xFFF0EBFF),
          border: Color(0xFFD4C8FF),
          iconGrad: [Color(0xFF926EFF), Color(0xFF6B47E8)],
        );
    }
  }
}
