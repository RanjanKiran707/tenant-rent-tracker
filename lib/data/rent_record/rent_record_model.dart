class RentRecordModel {
  final String uuid;
  final String tenantUuid;

  /// `YYYY-MM`
  final String month;

  /// Snapshot of the rent for that month.
  final int requiredAmount;

  const RentRecordModel({
    required this.uuid,
    required this.tenantUuid,
    required this.month,
    required this.requiredAmount,
  });
}
