import 'package:flutter/foundation.dart';

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

/// Developer tool: the real clock, unless a date is simulated. The time of day
/// on a simulated date is noon UTC. It notifies listeners when the date
/// changes, so open screens can reload.
class SimulatedClock extends ChangeNotifier implements Clock {
  final Clock _real;
  String? _simulatedDate;

  SimulatedClock(this._real, {String? simulatedDate})
    : _simulatedDate = simulatedDate;

  /// `YYYY-MM-DD`, or null when the real date is used.
  String? get simulatedDate => _simulatedDate;

  set simulatedDate(String? value) {
    if (value == _simulatedDate) return;
    _simulatedDate = value;
    notifyListeners();
  }

  @override
  String today() => _simulatedDate ?? _real.today();

  @override
  DateTime nowUtc() {
    final date = _simulatedDate;
    return date == null ? _real.nowUtc() : DateTime.parse('${date}T12:00:00Z');
  }
}
