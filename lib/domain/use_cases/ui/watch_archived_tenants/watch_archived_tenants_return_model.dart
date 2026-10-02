class ArchivedTenantRow {
  final String tenantUuid;
  final String name;

  /// `YYYY-MM` the tenant was deleted in.
  final String deletedMonth;

  /// Rent of the tenant's latest month; null if it never had a record.
  final int? lastRent;

  const ArchivedTenantRow({
    required this.tenantUuid,
    required this.name,
    required this.deletedMonth,
    required this.lastRent,
  });
}

class WatchArchivedTenantsReturnModel {
  /// Newest deletion first.
  final List<ArchivedTenantRow> rows;

  const WatchArchivedTenantsReturnModel({required this.rows});
}
