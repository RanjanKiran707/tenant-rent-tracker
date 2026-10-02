/// The app's source of "now". Everything date-related reads it, so tests
/// can fix the date.
abstract interface class Clock {
  /// Today in the app's fixed timezone, `YYYY-MM-DD`.
  String today();

  /// The moment now, for audit timestamps.
  DateTime nowUtc();
}

extension ClockMonth on Clock {
  /// This month in the app's fixed timezone, `YYYY-MM`.
  String currentMonth() => today().substring(0, 7);
}

/// Real clock. The app's fixed timezone is IST (UTC+5:30).
class SystemClock implements Clock {
  const SystemClock();

  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  String today() {
    final ist = nowUtc().add(_istOffset);
    final m = ist.month.toString().padLeft(2, '0');
    final d = ist.day.toString().padLeft(2, '0');
    return '${ist.year.toString().padLeft(4, '0')}-$m-$d';
  }
}
