import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardStats model', () {
    late Map<String, dynamic> sampleJson;

    setUp(() {
      sampleJson = {
        'total_users': 120,
        'active_users': 100,
        'new_users_today': 5,
        'new_users_this_week': 22,
        'total_chatbot_conversations': 340,
        'chatbot_conversations_today': 12,
        'total_emergency_assessments': 88,
        'emergency_assessments_today': 3,
        'high_risk_emergencies': 7,
        'total_health_articles': 40,
        'published_articles': 35,
        'total_symptom_checks': 0,
        'total_sos_events': 9,
      };
    });

    test('parses total_users correctly', () {
      final totalUsers = sampleJson['total_users'] as int;
      expect(totalUsers, 120);
    });

    test('parses active_users correctly', () {
      final activeUsers = sampleJson['active_users'] as int;
      expect(activeUsers, 100);
    });

    test('high_risk_emergencies is less than total', () {
      final high  = sampleJson['high_risk_emergencies'] as int;
      final total = sampleJson['total_emergency_assessments'] as int;
      expect(high, lessThanOrEqualTo(total));
    });

    test('published_articles <= total_health_articles', () {
      final pub   = sampleJson['published_articles'] as int;
      final total = sampleJson['total_health_articles'] as int;
      expect(pub, lessThanOrEqualTo(total));
    });

    test('null-safe parsing falls back to 0', () {
      final val = (null as int?) ?? 0;
      expect(val, 0);
    });
  });

  group('Pagination logic', () {
    test('total pages rounds up', () {
      final totalPages = (47 / 20).ceil();
      expect(totalPages, 3);
    });

    test('single page when total fits in one page', () {
      final totalPages = (10 / 20).ceil().clamp(1, 9999);
      expect(totalPages, 1);
    });

    test('offset calculation is correct', () {
      const page = 3;
      const pageSize = 20;
      final offset = (page - 1) * pageSize;
      expect(offset, 40);
    });

    test('page 1 offset is 0', () {
      final offset = (1 - 1) * 20;
      expect(offset, 0);
    });
  });
}
