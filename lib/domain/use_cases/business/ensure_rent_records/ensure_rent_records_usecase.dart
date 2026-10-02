import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_model.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_repository_interface.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository_interface.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:uuid/uuid.dart';

/// Creates the monthly rent records that are missing, from each tenant's start
/// month up to the current month. Safe to run any number of times: a record
/// that exists is never touched, so its rent snapshot never changes.
///
/// A ViewModel runs this when its screen opens or the app resumes, before it
/// subscribes to the UI use cases (which never write).
class EnsureRentRecordsUsecase {
  final TenantRepositoryInterface _tenants;
  final RentHistoryRepositoryInterface _history;
  final RentRecordRepositoryInterface _records;
  final Clock _clock;
  final Uuid _uuid;

  EnsureRentRecordsUsecase(
    this._tenants,
    this._history,
    this._records,
    this._clock, {
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  /// For one tenant when [tenantUuid] is given, otherwise for every active
  /// tenant. Deleted tenants get no new records.
  Future<Result<void>> call({String? tenantUuid}) async {
    final tenants = await _tenantsToFill(tenantUuid);
    final List<TenantModel> list;
    switch (tenants) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        list = value;
    }

    final current = _clock.currentMonth();
    final missing = <RentRecordModel>[];
    for (final tenant in list) {
      final history = await _history.getHistory(tenant.uuid);
      switch (history) {
        case Err(:final failure):
          return Err(failure);
        case Ok(:final value):
          for (final month in monthsBetween(tenant.startMonth, current)) {
            final rent = _rentForMonth(value, month);
            if (rent == null) continue;
            missing.add(
              RentRecordModel(
                uuid: _uuid.v4(),
                tenantUuid: tenant.uuid,
                month: month,
                requiredAmount: rent,
              ),
            );
          }
      }
    }
    if (missing.isEmpty) return const Ok(null);
    return _records.insertMissing(missing);
  }

  Future<Result<List<TenantModel>>> _tenantsToFill(String? tenantUuid) async {
    if (tenantUuid == null) return _tenants.getActiveTenants();
    return (await _tenants.getTenant(tenantUuid)).flatMap((tenant) {
      if (tenant == null) {
        return const Err<List<TenantModel>>(
          ValidationFailure('tenant_not_found'),
        );
      }
      return Ok(tenant.isDeleted ? <TenantModel>[] : [tenant]);
    });
  }

  /// The latest change at or before [month]; [history] is oldest first.
  int? _rentForMonth(List<RentHistoryModel> history, String month) {
    int? rent;
    for (final entry in history) {
      if (entry.effectiveFromMonth.compareTo(month) > 0) break;
      rent = entry.amount;
    }
    return rent;
  }
}
