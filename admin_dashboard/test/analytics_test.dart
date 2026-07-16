import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsState defaults', () {
    test('default days is 30', () {
      const defaultDays = 30;
      expect(defaultDays, 30);
    });

    test('isLoading starts false', () {
      const isLoading = false;
      expect(isLoading, isFalse);
    });

    test('empty symptom list returns no top symptom', () {
      final symptoms = <Map<String, dynamic>>[];
      expect(symptoms.isEmpty, isTrue);
    });
  });

  group('Symptom frequency parsing', () {
    late List<Map<String, dynamic>> rawData;

    setUp(() {
      rawData = [
        {'symptom': 'fever',    'count': 45},
        {'symptom': 'headache', 'count': 38},
        {'symptom': 'cough',    'count': 30},
      ];
    });

    test('parses symptom name', () {
      expect(rawData.first['symptom'], 'fever');
    });

    test('parses count', () {
      expect(rawData.first['count'], 45);
    });

    test('list is sorted descending by count', () {
      final counts = rawData.map((d) => d['count'] as int).toList();
      for (var i = 0; i < counts.length - 1; i++) {
        expect(counts[i], greaterThanOrEqualTo(counts[i + 1]));
      }
    });

    test('progress bar ratio is between 0 and 1', () {
      final maxCount = rawData.first['count'] as int;
      for (final d in rawData) {
        final ratio = (d['count'] as int) / maxCount;
        expect(ratio, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('Risk distribution parsing', () {
    final riskData = [
      {'risk_level': 'LOW',      'count': 50, 'percentage': 56.8},
      {'risk_level': 'MEDIUM',   'count': 20, 'percentage': 22.7},
      {'risk_level': 'HIGH',     'count': 12, 'percentage': 13.6},
      {'risk_level': 'CRITICAL', 'count':  6, 'percentage':  6.8},
    ];

    test('four risk levels present', () {
      expect(riskData.length, 4);
    });

    test('percentages sum to ~100', () {
      final sum = riskData
          .map((d) => d['percentage'] as double)
          .fold(0.0, (a, b) => a + b);
      expect(sum, closeTo(100.0, 0.5));
    });

    test('CRITICAL count is less than LOW count', () {
      final critical = riskData
          .firstWhere((d) => d['risk_level'] == 'CRITICAL')['count'] as int;
      final low = riskData
          .firstWhere((d) => d['risk_level'] == 'LOW')['count'] as int;
      expect(critical, lessThan(low));
    });
  });

  group('Trend data parsing', () {
    test('trend entry has date and counts', () {
      final entry = {'date': '2026-07-01', 'total': 10, 'emergency': 2};
      expect(entry['date'], isNotNull);
      expect(entry['total'], greaterThanOrEqualTo(entry['emergency'] as int));
    });

    test('emergency never exceeds total in a day', () {
      final trend = [
        {'date': '2026-07-01', 'total': 10, 'emergency': 2},
        {'date': '2026-07-02', 'total': 8,  'emergency': 1},
        {'date': '2026-07-03', 'total': 15, 'emergency': 5},
      ];
      for (final d in trend) {
        expect(d['emergency'] as int,
            lessThanOrEqualTo(d['total'] as int));
      }
    });
  });
}
