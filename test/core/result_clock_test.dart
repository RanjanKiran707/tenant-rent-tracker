import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';

class _FixedClock implements Clock {
  _FixedClock(this._today);
  final String _today;

  @override
  String today() => _today;

  @override
  DateTime nowUtc() => DateTime.utc(2026);
}

void main() {
  group('Result', () {
    test('map changes an Ok value', () {
      final r = const Ok<int>(2).map((v) => v * 10);
      expect((r as Ok<int>).value, 20);
    });

    test('map leaves an Err untouched', () {
      const failure = StorageFailure('x');
      final r = const Err<int>(failure).map((v) => v * 10);
      expect((r as Err<int>).failure, same(failure));
    });

    test('flatMap chains, and the first failure wins', () {
      Result<int> half(int v) =>
          v.isEven ? Ok(v ~/ 2) : const Err(ValidationFailure('odd'));

      expect((const Ok(8).flatMap(half) as Ok<int>).value, 4);
      expect(((const Ok(8).flatMap(half)).flatMap(half) as Ok<int>).value, 2);
      expect(
        ((const Ok(6).flatMap(half)).flatMap(half) as Err<int>).failure,
        isA<ValidationFailure>(),
      );
      expect(
        (const Err<int>(StorageFailure('first')).flatMap(half) as Err<int>)
            .failure
            .message,
        'first',
      );
    });
  });

  group('Clock', () {
    test('currentMonth is the month of today', () {
      expect(_FixedClock('2026-03-15').currentMonth(), '2026-03');
    });

    test('SystemClock.today looks like YYYY-MM-DD', () {
      expect(
        const SystemClock().today(),
        matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
      );
    });

    test('SystemClock is on IST, 5h30 ahead of UTC', () {
      final utc = DateTime.now().toUtc();
      final ist = utc.add(const Duration(hours: 5, minutes: 30));
      final expected =
          '${ist.year.toString().padLeft(4, '0')}-${ist.month.toString().padLeft(2, '0')}-${ist.day.toString().padLeft(2, '0')}';
      final actual = const SystemClock().today();
      // The two readings may straddle IST midnight; accept either day.
      final later = DateTime.now().toUtc().add(
        const Duration(hours: 5, minutes: 30),
      );
      final expectedLater =
          '${later.year.toString().padLeft(4, '0')}-${later.month.toString().padLeft(2, '0')}-${later.day.toString().padLeft(2, '0')}';
      expect([expected, expectedLater], contains(actual));
    });
  });
}
