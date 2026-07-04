// lib/features/home/domain/entities/quick_action.dart
class QuickAction {
  final String id;
  final String title;
  final String iconPath;
  final String routeName;

  const QuickAction({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.routeName,
  });
}