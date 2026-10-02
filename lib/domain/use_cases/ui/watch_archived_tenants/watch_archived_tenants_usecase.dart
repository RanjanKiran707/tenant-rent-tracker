import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/combine_latest.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository_interface.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_archived_tenants/watch_archived_tenants_return_model.dart';

/// The Archived list (Settings -> Archived). Presentation only.
class WatchArchivedTenantsUsecase {
  final TenantRepositoryInterface _tenants;
  final RentRecordRepositoryInterface _records;

  WatchArchivedTenantsUsecase(this._tenants, this._records);

  Stream<Result<WatchArchivedTenantsReturnModel>> call() {
    return combineLatest2(
      _tenants.watchArchivedTenants(),
      _records.watchAllRecords(),
      _build,
    );
  }

  WatchArchivedTenantsReturnModel _build(
    List<TenantModel> tenants,
    List<RentRecordModel> records,
  ) {
    // Each tenant's latest month decides the rent shown.
    final latest = <String, RentRecordModel>{};
    for (final r in records) {
      final seen = latest[r.tenantUuid];
      if (seen == null || r.month.compareTo(seen.month) > 0) {
        latest[r.tenantUuid] = r;
      }
    }
    return WatchArchivedTenantsReturnModel(
      rows: [
        for (final t in tenants)
          ArchivedTenantRow(
            tenantUuid: t.uuid,
            name: t.name,
            deletedMonth: t.deletedMonth!,
            lastRent: latest[t.uuid]?.requiredAmount,
          ),
      ],
    );
  }
}
