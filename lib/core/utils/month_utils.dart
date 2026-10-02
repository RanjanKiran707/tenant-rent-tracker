// Pure helpers on text months (`YYYY-MM`) and dates (`YYYY-MM-DD`).
// Everything is in the one fixed timezone, so these never involve a zone.

final RegExp _monthPattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');
final RegExp _datePattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])-\d{2}$');

String _pad(int n) => n.toString().padLeft(2, '0');

bool isValidMonth(String value) => _monthPattern.hasMatch(value);

bool isValidDate(String value) {
  if (!_datePattern.hasMatch(value)) return false;
  final day = int.parse(value.substring(8, 10));
  return day >= 1 && day <= daysInMonth(value.substring(0, 7));
}

/// The month part of a date: `2026-03-15` -> `2026-03`.
String monthOfDate(String date) => date.substring(0, 7);

int daysInMonth(String month) {
  final year = int.parse(month.substring(0, 4));
  final m = int.parse(month.substring(5, 7));
  // Day 0 of the next month is the last day of this month.
  return DateTime.utc(year, m + 1, 0).day;
}

/// `addMonths('2026-11', 3)` -> `2027-02`. [n] may be negative.
String addMonths(String month, int n) {
  final year = int.parse(month.substring(0, 4));
  final m = int.parse(month.substring(5, 7));
  // DateTime months are 1-based and roll over out-of-range values.
  final d = DateTime.utc(year, m + n, 1);
  return '${d.year.toString().padLeft(4, '0')}-${_pad(d.month)}';
}

/// The date rent is due: the due day, or the last day of a shorter month.
String dueDateOf(String month, int dueDay) {
  final day = dueDay < daysInMonth(month) ? dueDay : daysInMonth(month);
  return '$month-${_pad(day)}';
}

/// The last day of the month.
String monthEnd(String month) => '$month-${_pad(daysInMonth(month))}';

/// Every month from [from] to [to], both included. Empty when [from] > [to].
List<String> monthsBetween(String from, String to) {
  final months = <String>[];
  // `YYYY-MM` strings compare in calendar order.
  for (var m = from; m.compareTo(to) <= 0; m = addMonths(m, 1)) {
    months.add(m);
  }
  return months;
}
