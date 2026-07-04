import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../providers/authentication_provider.dart';

class AuthSplashPage extends ConsumerStatefulWidget {
  const AuthSplashPage({super.key});

  @override
  ConsumerState<AuthSplashPage> createState() => _AuthSplashPageState();
}

class _AuthSplashPageState extends ConsumerState<AuthSplashPage>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _scaleIn = Tween(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulse = Tween(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _mainCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final repo = ref.read(authRepositoryProvider);
    final seenOnboarding = await repo.hasSeenOnboarding();
    if (!mounted) return;
    if (seenOnboarding) {
      Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
    } else {
      Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6B47E8),
                DesignTokens.primary,
                Color(0xFF4F94FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo ────────────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _mainCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _fadeIn.value,
                    child: Transform.scale(
                      scale: _scaleIn.value,
                      child: child,
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, child) =>
                        Transform.scale(scale: _pulse.value, child: child),
                    child: _LogoContainer(),
                  ),
                ),

                const SizedBox(height: 32),

                // ── App name ─────────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _mainCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _fadeIn.value,
                    child: const Column(
                      children: [
                        Text(
                          'AI Healthcare',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tagline ──────────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _mainCtrl,
                  builder: (_, child) => SlideTransition(
                    position: _taglineSlide,
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: child,
                    ),
                  ),
                  child: Text(
                    'Smart health guidance for everyone 🌿',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Loading bar ──────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _mainCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _fadeIn.value,
                    child: child,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 140,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'v1.0.0  •  AI-Powered Healthcare',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Center(
        child: Text('🏥', style: TextStyle(fontSize: 54)),
      ),
    );
  }
}
