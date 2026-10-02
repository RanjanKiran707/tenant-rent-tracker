class PaymentModel {
  final String uuid;

  /// The month this payment is for (can be an older month).
  final String rentRecordUuid;
  final int amount;

  /// Date received, `YYYY-MM-DD`.
  final String paidOn;
  final DateTime createdOn;

  const PaymentModel({
    required this.uuid,
    required this.rentRecordUuid,
    required this.amount,
    required this.paidOn,
    required this.createdOn,
  });
}
