import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';

/// One group's screen: its tenants and this month's totals for them.
class WatchGroupReturnModel {
  final String groupUuid;

  /// As stored. For Uncategorized the screen shows its translated name
  /// instead.
  final String name;

  /// `YYYY-MM`, the month the totals are for.
  final String currentMonth;

  /// Money received for the current month, tenants of this group.
  final int received;

  /// Still to receive for the current month, tenants of this group.
  final int toReceive;

  /// Needs-attention first, then by name.
  final List<HomeTenantRow> rows;

  const WatchGroupReturnModel({
    required this.groupUuid,
    required this.name,
    required this.currentMonth,
    required this.received,
    required this.toReceive,
    required this.rows,
  });

  bool get isUncategorized => groupUuid == uncategorizedGroupUuid;
}
