import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/combine_latest.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/payment/payment_repository_interface.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository_interface.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/tenant_dues.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';

/// The Home screen: this month's totals and the tenant list.
///
/// Presentation only: it never writes. A tenant whose record for the current
/// month does not exist yet (before `EnsureRentRecordsUsecase` has run) is
/// listed as Pending and adds nothing to the totals.
///
/// Re-emits when tenants, records or payments change. It does not notice the
/// date changing on its own; the ViewModel re-subscribes when the app resumes.
class WatchHomeUsecase {
  final TenantRepositoryInterface _tenants;
  final RentRecordRepositoryInterface _records;
  final PaymentRepositoryInterface _payments;
  final Clock _clock;

  WatchHomeUsecase(this._tenants, this._records, this._payments, this._clock);

  Stream<Result<WatchHomeReturnModel>> call() {
    return combineLatest3(
      _tenants.watchActiveTenants(),
      _records.watchAllRecords(),
      _payments.watchAllPayments(),
      _build,
    );
  }

  WatchHomeReturnModel _build(
    List<TenantModel> tenants,
    List<RentRecordModel> records,
    List<PaymentModel> payments,
  ) {
    final today = _clock.today();
    final current = _clock.currentMonth();
    final byRecord = groupPaymentsByRecord(payments);
    final recordsByTenant = <String, List<RentRecordModel>>{};
    for (final r in records) {
      recordsByTenant.putIfAbsent(r.tenantUuid, () => []).add(r);
    }

    var received = 0;
    var toReceive = 0;
    final rows = <HomeTenantRow>[];
    for (final tenant in tenants) {
      final own = recordsByTenant[tenant.uuid] ?? const <RentRecordModel>[];
      RentRecordModel? currentRecord;
      for (final r in own) {
        if (r.month == current) currentRecord = r;
      }

      var status = MonthStatus.pending;
      if (currentRecord != null) {
        final paid = byRecord[currentRecord.uuid] ?? const <PaymentModel>[];
        status = computeMonthStatus(
          month: current,
          requiredAmount: currentRecord.requiredAmount,
          dueDay: tenant.dueDay,
          payments: paid,
          today: today,
        );
        received += paidAsOf(paid, today);
        toReceive += balanceOfRecord(currentRecord, paid, today);
      }

      rows.add(HomeTenantRow(
        tenantUuid: tenant.uuid,
        name: tenant.name,
        status: status,
        oldDues: oldDuesOf(
          records: own,
          paymentsByRecord: byRecord,
          currentMonth: current,
          today: today,
        ),
      ));
    }

    rows.sort((a, b) {
      final byRank = attentionRank(a.status, hasOldDues: a.oldDues > 0)
          .compareTo(attentionRank(b.status, hasOldDues: b.oldDues > 0));
      if (byRank != 0) return byRank;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return WatchHomeReturnModel(
      currentMonth: current,
      received: received,
      toReceive: toReceive,
      rows: rows,
    );
  }
}
