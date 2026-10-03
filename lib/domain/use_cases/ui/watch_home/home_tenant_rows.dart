import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/tenant_dues.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';

/// One row per tenant, most urgent first (see `attentionRank`), then by name.
/// Shared by Home (which rolls the rows up per group) and the group screen.
///
/// A tenant whose record for [current] does not exist yet (before
/// `EnsureRentRecordsUsecase` has run) is listed as Pending and adds nothing
/// to the money.
List<HomeTenantRow> buildTenantRows({
  required List<TenantModel> tenants,
  required List<RentRecordModel> records,
  required List<PaymentModel> payments,
  required String today,
  required String current,
}) {
  final byRecord = groupPaymentsByRecord(payments);
  final recordsByTenant = <String, List<RentRecordModel>>{};
  for (final r in records) {
    recordsByTenant.putIfAbsent(r.tenantUuid, () => []).add(r);
  }

  final rows = <HomeTenantRow>[];
  for (final tenant in tenants) {
    final own = recordsByTenant[tenant.uuid] ?? const <RentRecordModel>[];
    RentRecordModel? currentRecord;
    for (final r in own) {
      if (r.month == current) currentRecord = r;
    }

    var status = MonthStatus.pending;
    var received = 0;
    var toReceive = 0;
    if (currentRecord != null) {
      final paid = byRecord[currentRecord.uuid] ?? const <PaymentModel>[];
      status = computeMonthStatus(
        month: current,
        requiredAmount: currentRecord.requiredAmount,
        dueDay: tenant.dueDay,
        payments: paid,
        today: today,
      );
      received = paidAsOf(paid, today);
      toReceive = balanceOfRecord(currentRecord, paid, today);
    }

    rows.add(
      HomeTenantRow(
        tenantUuid: tenant.uuid,
        groupUuid: tenant.groupUuid,
        name: tenant.name,
        status: status,
        oldDues: oldDuesOf(
          records: own,
          paymentsByRecord: byRecord,
          currentMonth: current,
          today: today,
        ),
        received: received,
        toReceive: toReceive,
      ),
    );
  }

  rows.sort((a, b) {
    final byRank = attentionRank(
      a.status,
      hasOldDues: a.oldDues > 0,
    ).compareTo(attentionRank(b.status, hasOldDues: b.oldDues > 0));
    if (byRank != 0) return byRank;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return rows;
}
