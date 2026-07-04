import 'package:equatable/equatable.dart';

class OnboardingSlide extends Equatable {
  final String emoji;
  final String title;
  final String subtitle;
  final List<String> colors; // hex strings for gradient

  const OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  @override
  List<Object?> get props => [emoji, title, subtitle, colors];
}
