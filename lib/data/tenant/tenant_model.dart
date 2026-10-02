class TenantModel {
  final String uuid;
  final String name;
  final DateTime createdOn;

  /// 1-31. If a month is shorter, the last day of that month is used.
  final int dueDay;

  /// First month with a record, `YYYY-MM`.
  final String startMonth;

  /// null = active, set = deleted (archived), `YYYY-MM`.
  final String? deletedMonth;

  const TenantModel({
    required this.uuid,
    required this.name,
    required this.createdOn,
    required this.dueDay,
    required this.startMonth,
    this.deletedMonth,
  });

  bool get isDeleted => deletedMonth != null;
}
