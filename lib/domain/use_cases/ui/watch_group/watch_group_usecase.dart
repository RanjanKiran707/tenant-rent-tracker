import 'package:tenant_tracker/core/errors/failure.dart';
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
import 'package:tenant_tracker/domain/use_cases/ui/watch_group/watch_group_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/home_tenant_rows.dart';

/// The screen of one group: its active tenants, most urgent first, and this
/// month's totals for them. Presentation only: it never writes.
///
/// Emits `Err(ValidationFailure('group_not_found'))` when the group does not
/// exist or has been deleted (also if that happens while the screen is open).
/// Re-emits when the group (a rename), its tenants, records or payments change.
class WatchGroupUsecase {
  final TenantGroupRepositoryInterface _groups;
  final TenantRepositoryInterface _tenants;
  final RentRecordRepositoryInterface _records;
  final PaymentRepositoryInterface _payments;
  final Clock _clock;

  WatchGroupUsecase(
    this._groups,
    this._tenants,
    this._records,
    this._payments,
    this._clock,
  );

  Stream<Result<WatchGroupReturnModel>> call(String groupUuid) {
    final others = combineLatest3(
      _tenants.watchActiveTenants(),
      _records.watchAllRecords(),
      _payments.watchAllPayments(),
      (tenants, records, payments) => (tenants, records, payments),
    );
    return combineLatest2(
      _groups.watchActiveGroups(),
      others,
      (groups, o) => _build(groupUuid, groups, o.$1, o.$2, o.$3),
    ).map((result) => result.flatMap((inner) => inner));
  }

  Result<WatchGroupReturnModel> _build(
    String groupUuid,
    List<TenantGroupModel> groups,
    List<TenantModel> tenants,
    List<RentRecordModel> records,
    List<PaymentModel> payments,
  ) {
    TenantGroupModel? group;
    for (final g in groups) {
      if (g.uuid == groupUuid) group = g;
    }
    if (group == null) return const Err(ValidationFailure('group_not_found'));

    final current = _clock.currentMonth();
    final rows = buildTenantRows(
      tenants: [
        for (final t in tenants)
          if (t.groupUuid == groupUuid) t,
      ],
      records: records,
      payments: payments,
      today: _clock.today(),
      current: current,
    );
    return Ok(
      WatchGroupReturnModel(
        groupUuid: group.uuid,
        name: group.name,
        currentMonth: current,
        received: rows.fold(0, (sum, r) => sum + r.received),
        toReceive: rows.fold(0, (sum, r) => sum + r.toReceive),
        rows: rows,
      ),
    );
  }
}
