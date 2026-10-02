class RentHistoryModel {
  final String uuid;
  final String tenantUuid;

  /// `YYYY-MM`
  final String effectiveFromMonth;
  final int amount;

  const RentHistoryModel({
    required this.uuid,
    required this.tenantUuid,
    required this.effectiveFromMonth,
    required this.amount,
  });
}
