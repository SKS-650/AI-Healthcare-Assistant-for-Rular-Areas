import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../routing/route_names.dart';
import '../../../domain/entities/quick_action.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuickActionGrid  —  2 × 3 ultra-premium layout  (6 unique colour themes)
// ─────────────────────────────────────────────────────────────────────────────

class QuickActionGrid extends StatelessWidget {
  final List<QuickAction> actions;
  const QuickActionGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final items = actions.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.55,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => _QuickActionCard(
          action: items[i],
          index: i,
          onTap: () => _navigate(context, items[i].id),
        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Card — handles press animation + stagger entrance
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.action,
    required this.index,
    required this.onTap,
  });
  final QuickAction  action;
  final int          index;
  final VoidCallback onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double>   _scaleAnim;
  late final Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _CardCfg.of(widget.action.id);

    return AnimatedBuilder(
      animation: _pressCtrl,
      builder: (_, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: _CardBody(cfg: cfg, title: widget.action.title, glowAnim: _glowAnim),
      ),
    )
        .animate(delay: Duration(milliseconds: 150 + widget.index * 80))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card body
// ─────────────────────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.cfg,
    required this.title,
    required this.glowAnim,
  });
  final _CardCfg         cfg;
  final String           title;
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: cfg.cardGrad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: cfg.iconGrad[0]
                .withValues(alpha: 0.20 + glowAnim.value * 0.35),
            width: 1.5,
          ),
          boxShadow: [
            // Coloured glow shadow
            BoxShadow(
              color: cfg.iconGrad[0]
                  .withValues(alpha: 0.18 + glowAnim.value * 0.20),
              blurRadius: 20 + glowAnim.value * 10,
              spreadRadius: glowAnim.value * 2,
              offset: const Offset(0, 6),
            ),
            // Subtle depth shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Decorative orbs ─────────────────────────────────────────
            Positioned(
              right: -18, top: -18,
              child: _Orb(
                size: 88,
                color: cfg.iconGrad[0],
                opacity: 0.13 + glowAnim.value * 0.07,
              ),
            ),
            Positioned(
              left: -10, bottom: -22,
              child: _Orb(
                size: 66,
                color: cfg.iconGrad[1],
                opacity: 0.09,
              ),
            ),
            // Extra sparkle orb — unique per card via cfg.accentOrb
            Positioned(
              right: 20, bottom: 10,
              child: _Orb(
                size: 28,
                color: cfg.iconGrad[0],
                opacity: 0.20,
              ),
            ),

            // ── Shimmer overlay on press ─────────────────────────────────
            if (glowAnim.value > 0)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: glowAnim.value * 1.5,
                        sigmaY: glowAnim.value * 1.5),
                    child: Container(
                      color: cfg.iconGrad[0]
                          .withValues(alpha: glowAnim.value * 0.05),
                    ),
                  ),
                ),
              ),

            // ── Content ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon box with floating shadow
                  _IconBox(cfg: cfg, glowAnim: glowAnim),
                  const SizedBox(width: 12),
                  // Text column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.2,
                            color: cfg.textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _BadgeChip(label: cfg.badge, cfg: cfg),
                      ],
                    ),
                  ),
                  // Arrow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: EdgeInsets.only(
                        left: glowAnim.value * 3),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: cfg.iconGrad[0].withValues(alpha: 0.50),
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

// ─────────────────────────────────────────────────────────────────────────────
// Animated icon box with floating shadow + emoji pulse
// ─────────────────────────────────────────────────────────────────────────────

class _IconBox extends StatefulWidget {
  const _IconBox({required this.cfg, required this.glowAnim});
  final _CardCfg         cfg;
  final Animation<double> glowAnim;

  @override
  State<_IconBox> createState() => _IconBoxState();
}

class _IconBoxState extends State<_IconBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double>   _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -2.5, end: 2.5).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnim, widget.glowAnim]),
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.cfg.iconGrad,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: widget.cfg.iconGrad[0].withValues(
                    alpha: 0.45 + widget.glowAnim.value * 0.25),
                blurRadius: 14 + widget.glowAnim.value * 6,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.cfg.emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge chip
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.cfg});
  final String   label;
  final _CardCfg cfg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.iconGrad[0].withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: cfg.iconGrad[0].withValues(alpha: 0.20), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: cfg.iconGrad[0],
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative circle orb
// ─────────────────────────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color, required this.opacity});
  final double size;
  final Color  color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Card configuration — 6 distinct colour themes
// ─────────────────────────────────────────────────────────────────────────────

class _CardCfg {
  final String      emoji;
  final List<Color> cardGrad;   // background gradient
  final List<Color> iconGrad;   // icon box gradient + accent
  final Color       textColor;
  final String      badge;

  const _CardCfg({
    required this.emoji,
    required this.cardGrad,
    required this.iconGrad,
    required this.textColor,
    required this.badge,
  });

  static _CardCfg of(String id) => switch (id) {
        // ── 1. Symptom Checker — Purple ──────────────────────────────────
        'symptom' => const _CardCfg(
          emoji:     '🩺',
          cardGrad:  [Color(0xFFF5F0FF), Color(0xFFEDE4FF)],
          iconGrad:  [Color(0xFF9B5DE5), Color(0xFF6B21A8)],
          textColor: Color(0xFF3B0764),
          badge:     'Check Symptoms',
        ),

        // ── 2. AI Prediction — Sky Blue ───────────────────────────────────
        'prediction' => const _CardCfg(
          emoji:     '🧠',
          cardGrad:  [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          iconGrad:  [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          textColor: Color(0xFF1E3A8A),
          badge:     'AI Prediction',
        ),

        // ── 3. AI Chatbot — Teal / Cyan ───────────────────────────────────
        'chatbot' => const _CardCfg(
          emoji:     '🤖',
          cardGrad:  [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
          iconGrad:  [Color(0xFF06B6D4), Color(0xFF0E7490)],
          textColor: Color(0xFF164E63),
          badge:     'Ask AI',
        ),

        // ── 4. Emergency — Vivid Red / Coral ─────────────────────────────
        'emergency' => const _CardCfg(
          emoji:     '🚨',
          cardGrad:  [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
          iconGrad:  [Color(0xFFF43F5E), Color(0xFFBE123C)],
          textColor: Color(0xFF881337),
          badge:     'SOS & Triage',
        ),

        // ── 5. Health Records — Light Blue ────────────────────────────────
        'records' => const _CardCfg(
          emoji:     '📋',
          cardGrad:  [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          iconGrad:  [Color(0xFF38BDF8), Color(0xFF0284C7)],
          textColor: Color(0xFF0C4A6E),
          badge:     'My Records',
        ),

        // ── 6. Education — Light Green ─────────────────────────────────────
        'education' => const _CardCfg(
          emoji:     '📚',
          cardGrad:  [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
          iconGrad:  [Color(0xFF4ADE80), Color(0xFF16A34A)],
          textColor: Color(0xFF14532D),
          badge:     'Learn & Explore',
        ),

        // ── 7. Profile — Rose / Pink ──────────────────────────────────────
        'profile' => const _CardCfg(
          emoji:     '👤',
          cardGrad:  [Color(0xFFFFF0F6), Color(0xFFFFE4F0)],
          iconGrad:  [Color(0xFFEC4899), Color(0xFF9D174D)],
          textColor: Color(0xFF831843),
          badge:     'My Profile',
        ),

        // ── Default ───────────────────────────────────────────────────────
        _ => const _CardCfg(
          emoji:     '⚕️',
          cardGrad:  [Color(0xFFF5F0FF), Color(0xFFEDE4FF)],
          iconGrad:  [Color(0xFF9B5DE5), Color(0xFF6B21A8)],
          textColor: Color(0xFF3B0764),
          badge:     'Open',
        ),
      };
}
