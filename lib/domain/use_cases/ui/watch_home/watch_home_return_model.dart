import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';

class HomeTenantRow {
  final String tenantUuid;
  final String name;

  /// State of the current month.
  final MonthStatus status;

  /// Still owed for months before the current one. 0 when none.
  final int oldDues;

  const HomeTenantRow({
    required this.tenantUuid,
    required this.name,
    required this.status,
    required this.oldDues,
  });
}

class WatchHomeReturnModel {
  /// `YYYY-MM`, the month the totals are for.
  final String currentMonth;

  /// Money received for the current month, all active tenants.
  final int received;

  /// Still to receive for the current month, all active tenants.
  final int toReceive;

  /// Needs-attention first (see `attentionRank`), then by name.
  final List<HomeTenantRow> rows;

  const WatchHomeReturnModel({
    required this.currentMonth,
    required this.received,
    required this.toReceive,
    required this.rows,
  });
}
