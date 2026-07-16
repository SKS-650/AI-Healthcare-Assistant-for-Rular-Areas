import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RiskBadge color logic', () {
    Color riskColor(String level) => switch (level.toUpperCase()) {
          'CRITICAL' => const Color(0xFF7C3AED),
          'HIGH'     => const Color(0xFFEF4444),
          'MEDIUM'   => const Color(0xFFF59E0B),
          _          => const Color(0xFF10B981),
        };

    test('CRITICAL maps to purple', () {
      expect(riskColor('CRITICAL'), const Color(0xFF7C3AED));
    });

    test('HIGH maps to red', () {
      expect(riskColor('HIGH'), const Color(0xFFEF4444));
    });

    test('MEDIUM maps to amber', () {
      expect(riskColor('MEDIUM'), const Color(0xFFF59E0B));
    });

    test('LOW maps to green', () {
      expect(riskColor('LOW'), const Color(0xFF10B981));
    });

    test('unknown level defaults to green', () {
      expect(riskColor('UNKNOWN'), const Color(0xFF10B981));
    });
  });

  group('StatusBadge label logic', () {
    String statusLabel(bool active) => active ? 'Active' : 'Inactive';

    test('active returns Active', () {
      expect(statusLabel(true), 'Active');
    });

    test('inactive returns Inactive', () {
      expect(statusLabel(false), 'Inactive');
    });
  });

  group('Pagination display string', () {
    String rangeLabel(int page, int pageSize, int total) {
      final from = (page - 1) * pageSize + 1;
      final to   = (page * pageSize).clamp(0, total);
      return 'Showing $from–$to of $total';
    }

    test('page 1 of 47 items (pageSize 20)', () {
      expect(rangeLabel(1, 20, 47), 'Showing 1–20 of 47');
    });

    test('page 2 of 47 items (pageSize 20)', () {
      expect(rangeLabel(2, 20, 47), 'Showing 21–40 of 47');
    });

    test('last page clamps to total', () {
      expect(rangeLabel(3, 20, 47), 'Showing 41–47 of 47');
    });
  });

  group('DatasetType badge color', () {
    // Matches _TypeBadge logic in dataset_page.dart
    bool hasPrimaryColor(String type) => type.toLowerCase() == 'symptom';

    test('symptom type gets primary color', () {
      expect(hasPrimaryColor('symptom'), isTrue);
    });

    test('chatbot type does not get primary color', () {
      expect(hasPrimaryColor('chatbot'), isFalse);
    });
  });

  group('Short label truncation', () {
    String shortLabel(String label) =>
        label.length > 12 ? '${label.substring(0, 10)}…' : label;

    test('short label stays unchanged', () {
      expect(shortLabel('Fever'), 'Fever');
    });

    test('long label is truncated with ellipsis', () {
      final result = shortLabel('Acute Respiratory Distress');
      expect(result.endsWith('…'), isTrue);
      expect(result.length, lessThanOrEqualTo(13));
    });
  });
}

// Minimal Color stub so tests run without Flutter binding
class Color {
  final int value;
  const Color(this.value);
  @override
  bool operator ==(Object other) => other is Color && other.value == value;
  @override
  int get hashCode => value.hashCode;
}
