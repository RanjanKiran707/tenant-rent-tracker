class LoadAddTenantFormReturnModel {
  /// `YYYY-MM`, the last 12 months up to the current one, oldest first.
  final List<String> startMonthOptions;

  /// The current month.
  final String defaultStartMonth;

  final int defaultDueDay;

  const LoadAddTenantFormReturnModel({
    required this.startMonthOptions,
    required this.defaultStartMonth,
    required this.defaultDueDay,
  });
}
