import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';

class HomeTenantRow {
  final String tenantUuid;
  final String groupUuid;
  final String name;

  /// State of the current month.
  final MonthStatus status;

  /// Still owed for months before the current one. 0 when none.
  final int oldDues;

  /// Received for the current month. 0 when the month has no record yet.
  final int received;

  /// Still to receive for the current month. 0 when the month has no record
  /// yet.
  final int toReceive;

  const HomeTenantRow({
    required this.tenantUuid,
    required this.groupUuid,
    required this.name,
    required this.status,
    required this.oldDues,
    required this.received,
    required this.toReceive,
  });
}

/// One group card on Home.
class HomeGroupRow {
  final String groupUuid;

  /// As stored. For Uncategorized the screen shows its translated name
  /// instead.
  final String name;

  final int tenantCount;

  /// Status of the group's most urgent tenant; null when the group is empty.
  final MonthStatus? worstStatus;

  /// Whether the most urgent tenant has old dues (used for ordering).
  final bool worstHasOldDues;

  /// Old dues of all tenants in the group.
  final int oldDues;

  /// Still to receive this month, all tenants in the group.
  final int toReceive;

  const HomeGroupRow({
    required this.groupUuid,
    required this.name,
    required this.tenantCount,
    required this.worstStatus,
    required this.worstHasOldDues,
    required this.oldDues,
    required this.toReceive,
  });

  bool get isUncategorized => groupUuid == uncategorizedGroupUuid;
}

class WatchHomeReturnModel {
  /// `YYYY-MM`, the month the totals are for.
  final String currentMonth;

  /// Money received for the current month, all active tenants.
  final int received;

  /// Still to receive for the current month, all active tenants.
  final int toReceive;

  /// Needs-attention first (the most urgent tenant decides), then by name.
  /// Empty groups come last. Uncategorized is left out while it is empty.
  final List<HomeGroupRow> groups;

  const WatchHomeReturnModel({
    required this.currentMonth,
    required this.received,
    required this.toReceive,
    required this.groups,
  });
}
