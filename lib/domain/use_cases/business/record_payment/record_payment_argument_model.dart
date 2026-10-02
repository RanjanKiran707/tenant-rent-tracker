class RecordPaymentArgumentModel {
  /// The month's record the money is for (can be an older month).
  final String rentRecordUuid;
  final int amount;

  /// Date received, `YYYY-MM-DD`. Not after today.
  final String paidOn;

  const RecordPaymentArgumentModel({
    required this.rentRecordUuid,
    required this.amount,
    required this.paidOn,
  });
}
