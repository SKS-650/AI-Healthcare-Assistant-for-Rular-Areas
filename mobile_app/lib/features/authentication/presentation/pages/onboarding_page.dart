import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../shared/design_system/design_tokens.dart';
import '../providers/authentication_provider.dart';
import '../widgets/onboarding/onboarding_indicator.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  static const _slides = [
    _OnboardingData(
      emoji: '🩺',
      title: 'Smart Symptom\nChecker',
      subtitle:
          'Describe your symptoms and get instant AI-powered health insights tailored to you.',
      gradientColors: [Color(0xFF6B47E8), Color(0xFF926EFF)],
      accentColor: Color(0xFFE8E0FF),
    ),
    _OnboardingData(
      emoji: '🤖',
      title: 'AI Health\nChatbot',
      subtitle:
          'Chat with our intelligent assistant 24/7 for medical guidance in your own language.',
      gradientColors: [Color(0xFF4F94FF), Color(0xFF2563EB)],
      accentColor: Color(0xFFE8F1FF),
    ),
    _OnboardingData(
      emoji: '🚨',
      title: 'Emergency\nDetection',
      subtitle:
          'Real-time emergency alerts, nearby hospital locator, and one-tap SOS — always ready.',
      gradientColors: [Color(0xFF2ECC8B), Color(0xFF16A34A)],
      accentColor: Color(0xFFE4FBF0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.markOnboardingSeen();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _contentCtrl.reset();
    _contentCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final isLast = _currentPage == _slides.length - 1;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: slide.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, top: 12),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView (emoji + illustration area)
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (_, i) {
                    return Center(
                      child: AnimatedBuilder(
                        animation: _contentCtrl,
                        builder: (_, child) => SlideTransition(
                          position: _contentSlide,
                          child: FadeTransition(
                            opacity: _contentFade,
                            child: child,
                          ),
                        ),
                        child: _EmojiIllustration(
                          emoji: _slides[i].emoji,
                          accentColor: _slides[i].accentColor,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Content card
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indicator
                      OnboardingIndicator(
                        count: _slides.length,
                        current: _currentPage,
                      ),
                      const SizedBox(height: 24),

                      // Title
                      AnimatedBuilder(
                        animation: _contentCtrl,
                        builder: (_, child) => FadeTransition(
                          opacity: _contentFade,
                          child: SlideTransition(
                            position: _contentSlide,
                            child: child,
                          ),
                        ),
                        child: Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: DesignTokens.textStrong,
                            letterSpacing: -0.6,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      AnimatedBuilder(
                        animation: _contentCtrl,
                        builder: (_, child) => FadeTransition(
                          opacity: _contentFade,
                          child: child,
                        ),
                        child: Text(
                          slide.subtitle,
                          style: const TextStyle(
                            fontSize: 15,
                            color: DesignTokens.textMuted,
                            height: 1.55,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Next / Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: slide.gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: slide.gradientColors.last
                                    .withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: FilledButton(
                            onPressed: _nextPage,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLast ? 'Get Started' : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLast
                                      ? Icons.rocket_launch_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Color accentColor;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.accentColor,
  });
}

class _EmojiIllustration extends StatelessWidget {
  final String emoji;
  final Color accentColor;

  const _EmojiIllustration({
    required this.emoji,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        // Inner circle
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 70),
            ),
          ),
        ),
      ],
    );
  }
}
