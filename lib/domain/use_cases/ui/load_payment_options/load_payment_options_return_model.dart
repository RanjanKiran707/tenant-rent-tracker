/// One month the user can record money for.
class PaymentMonthOption {
  final String rentRecordUuid;

  /// `YYYY-MM`
  final String month;
  final int requiredAmount;
  final int paid;
  final int balance;

  const PaymentMonthOption({
    required this.rentRecordUuid,
    required this.month,
    required this.requiredAmount,
    required this.paid,
    required this.balance,
  });
}

class LoadPaymentOptionsReturnModel {
  final String tenantName;

  /// Today, `YYYY-MM-DD`: the default and the latest allowed date.
  final String today;

  /// Months with a balance plus the current month, newest first.
  final List<PaymentMonthOption> options;

  /// Current month if it has a balance, else the oldest month owing, else the
  /// current month. Null only when there are no options at all.
  final String? defaultRentRecordUuid;

  const LoadPaymentOptionsReturnModel({
    required this.tenantName,
    required this.today,
    required this.options,
    required this.defaultRentRecordUuid,
  });
}
