/// A structured first-aid guide returned by the AI pipeline.
class FirstAidGuide {
  final String title;
  final String emoji;
  final List<String> steps;
  final List<String> doNotSteps;
  final String callToAction;

  const FirstAidGuide({
    required this.title,
    required this.emoji,
    required this.steps,
    required this.doNotSteps,
    required this.callToAction,
  });

  static const empty = FirstAidGuide(
    title: '',
    emoji: '🚨',
    steps: [],
    doNotSteps: [],
    callToAction: 'Call 102',
  );
}
