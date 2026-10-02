class AddTenantArgumentModel {
  final String name;
  final int rent;

  /// 1 to 31. A due day beyond a month's length falls on its last day.
  final int dueDay;

  /// `YYYY-MM`, the first month rent is owed. Not after the current month.
  final String startMonth;

  const AddTenantArgumentModel({
    required this.name,
    required this.rent,
    required this.dueDay,
    required this.startMonth,
  });
}
