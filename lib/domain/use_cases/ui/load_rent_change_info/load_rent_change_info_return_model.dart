class LoadRentChangeInfoReturnModel {
  final String tenantName;

  /// Rent for the current month.
  final int currentRent;

  /// `YYYY-MM`
  final String currentMonth;

  /// `YYYY-MM`, the month the new rent will start from (next month).
  final String effectiveFromMonth;

  const LoadRentChangeInfoReturnModel({
    required this.tenantName,
    required this.currentRent,
    required this.currentMonth,
    required this.effectiveFromMonth,
  });
}
