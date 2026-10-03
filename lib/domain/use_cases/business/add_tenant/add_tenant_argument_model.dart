import 'package:tenant_tracker/core/constants.dart';

class AddTenantArgumentModel {
  final String name;
  final int rent;

  /// 1 to 31. A due day beyond a month's length falls on its last day.
  final int dueDay;

  /// `YYYY-MM`, the first month rent is owed. Not after the current month.
  final String startMonth;

  /// The group to list the tenant under. Must be an active group.
  final String groupUuid;

  const AddTenantArgumentModel({
    required this.name,
    required this.rent,
    required this.dueDay,
    required this.startMonth,
    this.groupUuid = uncategorizedGroupUuid,
  });
}
