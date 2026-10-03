import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/combine_latest.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/payment/payment_repository_interface.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository_interface.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_model.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/home_tenant_rows.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';

/// The Home screen: this month's totals and one card per group.
///
/// Presentation only: it never writes. A tenant whose record for the current
/// month does not exist yet (before `EnsureRentRecordsUsecase` has run) is
/// counted as Pending and adds nothing to the totals.
///
/// Every active group is listed, even when empty, except Uncategorized, which
/// is listed only while it has tenants. The totals at the top cover all active
/// tenants, whatever their group.
///
/// Re-emits when groups, tenants, records or payments change. It does not
/// notice the date changing on its own; the ViewModel re-subscribes when the
/// app resumes.
class WatchHomeUsecase {
  final TenantGroupRepositoryInterface _groups;
  final TenantRepositoryInterface _tenants;
  final RentRecordRepositoryInterface _records;
  final PaymentRepositoryInterface _payments;
  final Clock _clock;

  WatchHomeUsecase(
    this._groups,
    this._tenants,
    this._records,
    this._payments,
    this._clock,
  );

  Stream<Result<WatchHomeReturnModel>> call() {
    final others = combineLatest3(
      _tenants.watchActiveTenants(),
      _records.watchAllRecords(),
      _payments.watchAllPayments(),
      (tenants, records, payments) => (tenants, records, payments),
    );
    return combineLatest2(
      _groups.watchActiveGroups(),
      others,
      (groups, o) => _build(groups, o.$1, o.$2, o.$3),
    );
  }

  WatchHomeReturnModel _build(
    List<TenantGroupModel> groups,
    List<TenantModel> tenants,
    List<RentRecordModel> records,
    List<PaymentModel> payments,
  ) {
    final rows = buildTenantRows(
      tenants: tenants,
      records: records,
      payments: payments,
      today: _clock.today(),
      current: _clock.currentMonth(),
    );
    final rowsByGroup = <String, List<HomeTenantRow>>{};
    for (final row in rows) {
      rowsByGroup.putIfAbsent(row.groupUuid, () => []).add(row);
    }

    final cards = <HomeGroupRow>[];
    for (final group in groups) {
      final own = rowsByGroup[group.uuid] ?? const <HomeTenantRow>[];
      if (group.isUncategorized && own.isEmpty) continue;
      // Rows are most urgent first, so the first one decides the card.
      final worst = own.isEmpty ? null : own.first;
      cards.add(
        HomeGroupRow(
          groupUuid: group.uuid,
          name: group.name,
          tenantCount: own.length,
          worstStatus: worst?.status,
          worstHasOldDues: worst != null && worst.oldDues > 0,
          oldDues: own.fold(0, (sum, r) => sum + r.oldDues),
          toReceive: own.fold(0, (sum, r) => sum + r.toReceive),
        ),
      );
    }

    // Empty groups last; otherwise by the most urgent tenant, then by name.
    double rankOf(HomeGroupRow g) => g.worstStatus == null
        ? double.infinity
        : attentionRank(g.worstStatus!, hasOldDues: g.worstHasOldDues);
    cards.sort((a, b) {
      final byRank = rankOf(a).compareTo(rankOf(b));
      if (byRank != 0) return byRank;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return WatchHomeReturnModel(
      currentMonth: _clock.currentMonth(),
      received: rows.fold(0, (sum, r) => sum + r.received),
      toReceive: rows.fold(0, (sum, r) => sum + r.toReceive),
      groups: cards,
    );
  }
}
