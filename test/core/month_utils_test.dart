import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';

void main() {
  group('daysInMonth', () {
    test('normal months', () {
      expect(daysInMonth('2026-01'), 31);
      expect(daysInMonth('2026-04'), 30);
    });

    test('February, leap and not leap', () {
      expect(daysInMonth('2026-02'), 28);
      expect(daysInMonth('2028-02'), 29);
      expect(daysInMonth('2100-02'), 28); // century, not a leap year
    });
  });

  group('addMonths', () {
    test('within a year', () => expect(addMonths('2026-03', 2), '2026-05'));
    test('across a year end', () => expect(addMonths('2026-11', 3), '2027-02'));
    test('December plus one', () => expect(addMonths('2026-12', 1), '2027-01'));
    test('negative', () {
      expect(addMonths('2026-01', -1), '2025-12');
      expect(addMonths('2026-03', -14), '2025-01');
    });
    test('zero', () => expect(addMonths('2026-03', 0), '2026-03'));
  });

  group('dueDateOf', () {
    test('a normal due day', () => expect(dueDateOf('2026-03', 10), '2026-03-10'));

    test('due day 31 falls back to the last day of a shorter month', () {
      expect(dueDateOf('2026-04', 31), '2026-04-30');
      expect(dueDateOf('2026-02', 31), '2026-02-28');
      expect(dueDateOf('2028-02', 30), '2028-02-29');
    });

    test('due day equal to the last day', () {
      expect(dueDateOf('2026-04', 30), '2026-04-30');
    });
  });

  test('monthEnd', () {
    expect(monthEnd('2026-02'), '2026-02-28');
    expect(monthEnd('2026-12'), '2026-12-31');
  });

  test('monthOfDate', () => expect(monthOfDate('2026-03-15'), '2026-03'));

  group('monthsBetween', () {
    test('both ends included', () {
      expect(monthsBetween('2026-11', '2027-02'),
          ['2026-11', '2026-12', '2027-01', '2027-02']);
    });
    test('same month', () => expect(monthsBetween('2026-03', '2026-03'), ['2026-03']));
    test('from after to is empty', () {
      expect(monthsBetween('2026-04', '2026-03'), isEmpty);
    });
  });

  group('validation', () {
    test('isValidMonth', () {
      expect(isValidMonth('2026-03'), isTrue);
      expect(isValidMonth('2026-13'), isFalse);
      expect(isValidMonth('2026-00'), isFalse);
      expect(isValidMonth('2026-3'), isFalse);
      expect(isValidMonth('2026-03-01'), isFalse);
      expect(isValidMonth(''), isFalse);
    });

    test('isValidDate', () {
      expect(isValidDate('2026-03-15'), isTrue);
      expect(isValidDate('2026-02-29'), isFalse); // not a leap year
      expect(isValidDate('2028-02-29'), isTrue);
      expect(isValidDate('2026-04-31'), isFalse);
      expect(isValidDate('2026-03-00'), isFalse);
      expect(isValidDate('2026-03'), isFalse);
      expect(isValidDate('abc'), isFalse);
    });
  });
}
