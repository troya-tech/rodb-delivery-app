import 'package:flutter_test/flutter_test.dart';
import 'package:rodb_delivery_app/app/pages/performance-page/performance_shift_provider.dart';

void main() {
  group('computeDateRange', () {
    test('cross-midnight shift: startHour > endHour spans to next day', () {
      final anchor = DateTime(2026, 2, 18);
      const config = ShiftConfig(startHour: 18, endHour: 3);

      final range = computeDateRange(anchor, config);

      expect(range.start, DateTime(2026, 2, 18, 18, 0));
      expect(range.end, DateTime(2026, 2, 19, 3, 0));
    });

    test('same-day shift: startHour < endHour stays on same day', () {
      final anchor = DateTime(2026, 2, 18);
      const config = ShiftConfig(startHour: 9, endHour: 17);

      final range = computeDateRange(anchor, config);

      expect(range.start, DateTime(2026, 2, 18, 9, 0));
      expect(range.end, DateTime(2026, 2, 18, 17, 0));
    });

    test('shifting anchor back one day shifts entire range', () {
      final anchor = DateTime(2026, 2, 17);
      const config = ShiftConfig(startHour: 18, endHour: 3);

      final range = computeDateRange(anchor, config);

      expect(range.start, DateTime(2026, 2, 17, 18, 0));
      expect(range.end, DateTime(2026, 2, 18, 3, 0));
    });

    test('edge case: endHour equals startHour treated as same-day (0h window)', () {
      final anchor = DateTime(2026, 2, 18);
      const config = ShiftConfig(startHour: 18, endHour: 18);

      final range = computeDateRange(anchor, config);

      // endHour == startHour → same day, 0-hour window
      expect(range.start, DateTime(2026, 2, 18, 18, 0));
      expect(range.end, DateTime(2026, 2, 18, 18, 0));
    });
  });

  group('ShiftConfig', () {
    test('default values', () {
      const config = ShiftConfig();
      expect(config.startHour, 18);
      expect(config.endHour, 3);
    });

    test('equality', () {
      const a = ShiftConfig(startHour: 18, endHour: 3);
      const b = ShiftConfig(startHour: 18, endHour: 3);
      const c = ShiftConfig(startHour: 17, endHour: 2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
