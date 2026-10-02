import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';

/// Payments grouped by the month's record they belong to.
Map<String, List<PaymentModel>> groupPaymentsByRecord(
  Iterable<PaymentModel> payments,
) {
  final grouped = <String, List<PaymentModel>>{};
  for (final p in payments) {
    grouped.putIfAbsent(p.rentRecordUuid, () => []).add(p);
  }
  return grouped;
}

/// Still owed for one month as of [today].
int balanceOfRecord(
  RentRecordModel record,
  List<PaymentModel> payments,
  String today,
) =>
    balanceOf(record.requiredAmount, paidAsOf(payments, today));

/// Total still owed for months before [currentMonth] ("Old dues").
/// [records] are one tenant's records.
int oldDuesOf({
  required Iterable<RentRecordModel> records,
  required Map<String, List<PaymentModel>> paymentsByRecord,
  required String currentMonth,
  required String today,
}) {
  var total = 0;
  for (final r in records) {
    if (r.month.compareTo(currentMonth) >= 0) continue;
    total += balanceOfRecord(r, paymentsByRecord[r.uuid] ?? const [], today);
  }
  return total;
}

/// The oldest month before [currentMonth] that still has a balance, or null.
RentRecordModel? oldestOwingRecord({
  required Iterable<RentRecordModel> records,
  required Map<String, List<PaymentModel>> paymentsByRecord,
  required String currentMonth,
  required String today,
}) {
  RentRecordModel? oldest;
  for (final r in records) {
    if (r.month.compareTo(currentMonth) >= 0) continue;
    if (balanceOfRecord(r, paymentsByRecord[r.uuid] ?? const [], today) == 0) {
      continue;
    }
    if (oldest == null || r.month.compareTo(oldest.month) < 0) oldest = r;
  }
  return oldest;
}
