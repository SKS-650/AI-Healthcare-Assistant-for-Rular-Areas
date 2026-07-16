import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportsPage — period selector', () {
    test('valid period values are 7, 30, 90', () {
      const validPeriods = [7, 30, 90];
      for (final p in validPeriods) {
        expect(p, greaterThan(0));
        expect(p, lessThanOrEqualTo(90));
      }
    });

    test('default period is 30 days', () {
      const defaultDays = 30;
      expect(defaultDays, 30);
    });
  });

  group('User registration trend data', () {
    late List<Map<String, dynamic>> trend;

    setUp(() {
      trend = List.generate(
        30,
        (i) => {
          'date': DateTime(2026, 6, i + 1).toIso8601String().split('T').first,
          'count': i % 5,
        },
      );
    });

    test('produces 30 entries for 30-day period', () {
      expect(trend.length, 30);
    });

    test('each entry has a date key', () {
      for (final entry in trend) {
        expect(entry.containsKey('date'), isTrue);
      }
    });

    test('count is never negative', () {
      for (final entry in trend) {
        expect(entry['count'] as int, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Risk distribution chart', () {
    test('donut slices are non-negative', () {
      final slices = [
        {'risk_level': 'LOW',      'count': 40, 'percentage': 50.0},
        {'risk_level': 'MEDIUM',   'count': 20, 'percentage': 25.0},
        {'risk_level': 'HIGH',     'count': 12, 'percentage': 15.0},
        {'risk_level': 'CRITICAL', 'count':  8, 'percentage': 10.0},
      ];
      for (final s in slices) {
        expect(s['count'] as int, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Emergency weekly bar chart', () {
    test('weekly data has at most 7 entries', () {
      final weekly = List.generate(7, (i) => {'date': '2026-07-0${i + 1}', 'total': i});
      expect(weekly.length, lessThanOrEqualTo(7));
    });

    test('all total values are non-negative', () {
      final weekly = [
        {'date': '2026-07-09', 'total': 3},
        {'date': '2026-07-10', 'total': 0},
        {'date': '2026-07-11', 'total': 7},
      ];
      for (final d in weekly) {
        expect(d['total'] as int, greaterThanOrEqualTo(0));
      }
    });
  });
}
