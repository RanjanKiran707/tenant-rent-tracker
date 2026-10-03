import 'package:intl/intl.dart';
import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

final NumberFormat _money = NumberFormat.decimalPattern('en_IN');

/// 12500 -> `12,500` (Indian grouping).
String formatMoney(int amount) => _money.format(amount);

/// `2026-10` -> `Oct 2026` / `ಅಕ್ಟೋಬರ್ 2026`.
String formatMonth(AppLocalizations l, String month) =>
    '${l.monthName(int.parse(month.substring(5, 7)).toString())} '
    '${month.substring(0, 4)}';

/// `2026-10-05` -> `5 Oct`.
String formatDayMonth(AppLocalizations l, String date) =>
    '${int.parse(date.substring(8, 10))} '
    '${l.monthName(int.parse(date.substring(5, 7)).toString())}';

/// `2026-10-05` -> `5 Oct 2026`.
String formatDate(AppLocalizations l, String date) =>
    '${formatDayMonth(l, date)} ${date.substring(0, 4)}';

/// The name to show for a group. The built-in Uncategorized group is stored
/// with an English name, so its translated text is used instead.
String groupDisplayName(AppLocalizations l, String groupUuid, String name) =>
    groupUuid == uncategorizedGroupUuid ? l.uncategorized : name;
