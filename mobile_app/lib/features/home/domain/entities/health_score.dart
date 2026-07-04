// lib/features/home/domain/entities/health_score.dart
class HealthScore {
  final int score;
  final String status; // e.g., "Excellent", "Good", "Action Needed"
  final String description;

  const HealthScore({
    required this.score,
    required this.status,
    required this.description,
  });
}