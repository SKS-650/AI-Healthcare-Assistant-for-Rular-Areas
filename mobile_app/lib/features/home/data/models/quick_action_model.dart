// lib/features/home/data/models/quick_action_model.dart
import '../../domain/entities/quick_action.dart';

class QuickActionModel extends QuickAction {
  const QuickActionModel({
    required super.id,
    required super.title,
    required super.iconPath,
    required super.routeName,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      iconPath: json['iconPath'] as String,
      routeName: json['routeName'] as String,
    );
  }
}