import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/combine_latest.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/payment/payment_repository_interface.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_model.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_repository_interface.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository_interface.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/tenant_dues.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_tenant_detail/watch_tenant_detail_return_model.dart';

/// The tenant detail screen, for an active tenant and for an archived one
/// (`readOnly`).
///
/// Presentation only: it never writes. Emits `Err(ValidationFailure(
/// 'tenant_not_found'))` once if the uuid is unknown. Re-emits when the
/// tenant's records, payments or rent history change; the tenant itself is
/// read when the stream starts (deleting a tenant leaves this screen).
class WatchTenantDetailUsecase {
  final TenantRepositoryInterface _tenants;
  final RentRecordRepositoryInterface _records;
  final PaymentRepositoryInterface _payments;
  final RentHistoryRepositoryInterface _history;
  final Clock _clock;

  WatchTenantDetailUsecase(
    this._tenants,
    this._records,
    this._payments,
    this._history,
    this._clock,
  );

  Stream<Result<WatchTenantDetailReturnModel>> call(String tenantUuid) async* {
    final found = await _tenants.getTenant(tenantUuid);
    final TenantModel tenant;
    switch (found) {
      case Err(:final failure):
        yield Err(failure);
        return;
      case Ok(:final value):
        if (value == null) {
          yield const Err(ValidationFailure('tenant_not_found'));
          return;
        }
        tenant = value;
    }

    yield* combineLatest3(
      _records.watchRecordsOfTenant(tenantUuid),
      _payments.watchPaymentsOfTenant(tenantUuid),
      _history.watchHistory(tenantUuid),
      (records, payments, history) =>
          _build(tenant, records, payments, history),
    );
  }

  WatchTenantDetailReturnModel _build(
    TenantModel tenant,
    List<RentRecordModel> records,
    List<PaymentModel> payments,
    List<RentHistoryModel> history,
  ) {
    final today = _clock.today();
    final current = _clock.currentMonth();
    final byRecord = groupPaymentsByRecord(payments);
    final readOnly = tenant.isDeleted;

    // Months that count: from the start month up to now, newest first.
    final visible =
        records
            .where(
              (r) =>
                  r.month.compareTo(current) <= 0 &&
                  r.month.compareTo(tenant.startMonth) >= 0,
            )
            .toList()
          ..sort((a, b) => b.month.compareTo(a.month));

    MonthDetail detailOf(RentRecordModel r) {
      final paid = byRecord[r.uuid] ?? const <PaymentModel>[];
      final received = paidAsOf(paid, today);
      final ordered = [...paid]
        ..sort((a, b) {
          final byDay = a.paidOn.compareTo(b.paidOn);
          return byDay != 0 ? byDay : a.createdOn.compareTo(b.createdOn);
        });
      return MonthDetail(
        rentRecordUuid: r.uuid,
        month: r.month,
        status: computeMonthStatus(
          month: r.month,
          requiredAmount: r.requiredAmount,
          dueDay: tenant.dueDay,
          payments: paid,
          today: today,
        ),
        requiredAmount: r.requiredAmount,
        paid: received,
        balance: balanceOf(r.requiredAmount, received),
        extra: received > r.requiredAmount ? received - r.requiredAmount : 0,
        dueDate: dueDateOf(r.month, tenant.dueDay),
        payments: [
          for (final p in ordered)
            PaymentItem(uuid: p.uuid, amount: p.amount, paidOn: p.paidOn),
        ],
      );
    }

    final currentRecord = visible.where((r) => r.month == current).firstOrNull;
    final currentMonthDetail = currentRecord == null
        ? null
        : detailOf(currentRecord);

    // Once this month is fully paid it moves down to History and the top card
    // is empty ("No pending due"). An archived tenant keeps its latest month.
    final currentPaidUp =
        currentMonthDetail != null && currentMonthDetail.balance == 0;
    final top = readOnly
        ? (visible.isEmpty ? null : visible.first)
        : (currentPaidUp ? null : currentRecord);
    final listed = readOnly
        ? visible
        : visible
              .where((r) => r.month != current || currentPaidUp)
              .toList();

    final oldest = oldestOwingRecord(
      records: visible,
      paymentsByRecord: byRecord,
      currentMonth: current,
      today: today,
    );
    final oldDues = oldDuesOf(
      records: visible,
      paymentsByRecord: byRecord,
      currentMonth: current,
      today: today,
    );
    final topDetail = top == null ? null : detailOf(top);

    final pending = history.where(
      (h) => h.effectiveFromMonth.compareTo(current) > 0,
    );

    return WatchTenantDetailReturnModel(
      tenantUuid: tenant.uuid,
      name: tenant.name,
      dueDay: tenant.dueDay,
      readOnly: readOnly,
      deletedMonth: tenant.deletedMonth,
      currentRent:
          topDetail?.requiredAmount ??
          currentMonthDetail?.requiredAmount ??
          _rentFromHistory(history, current),
      topMonth: topDetail,
      oldDues: oldDues,
      oldestOwingMonth: oldest?.month,
      oldestOwingRentRecordUuid: oldest?.uuid,
      totalOwed: oldDues + (currentMonthDetail?.balance ?? 0),
      pendingRentMonth: pending.lastOrNull?.effectiveFromMonth,
      pendingRentAmount: pending.lastOrNull?.amount,
      months: listed.map(detailOf).toList(),
    );
  }

  /// The rent in force for [month]; 0 only if the history is empty.
  int _rentFromHistory(List<RentHistoryModel> history, String month) {
    int? rent;
    for (final h in history) {
      if (h.effectiveFromMonth.compareTo(month) > 0) break;
      rent = h.amount;
    }
    return rent ?? (history.isEmpty ? 0 : history.first.amount);
  }
}
