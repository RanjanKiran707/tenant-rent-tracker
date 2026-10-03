import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_argument_model.dart';
import 'package:tenant_tracker/domain/use_cases/business/ensure_rent_records/ensure_rent_records_usecase.dart';
import 'package:uuid/uuid.dart';

/// Adds a tenant with the first rent, then creates the monthly records from
/// the start month up to now. Returns the new tenant's uuid.
///
/// Validation errors: `name_required`, `rent_invalid`, `due_day_invalid`,
/// `start_month_invalid`, `start_month_in_future`, `group_not_found`,
/// `group_deleted` (the chosen group must exist and be active).
///
/// If the records cannot be created after the tenant was saved, the failure is
/// returned but the tenant stays; the next `EnsureRentRecordsUsecase` run
/// creates the missing months.
class AddTenantUsecase {
  final TenantRepositoryInterface _tenants;
  final TenantGroupRepositoryInterface _groups;
  final EnsureRentRecordsUsecase _ensureRentRecords;
  final Clock _clock;
  final Uuid _uuid;

  AddTenantUsecase(
    this._tenants,
    this._groups,
    this._ensureRentRecords,
    this._clock, {
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  Future<Result<String>> call(AddTenantArgumentModel model) async {
    final name = model.name.trim();
    if (name.isEmpty) return const Err(ValidationFailure('name_required'));
    if (model.rent <= 0) return const Err(ValidationFailure('rent_invalid'));
    if (model.dueDay < 1 || model.dueDay > 31) {
      return const Err(ValidationFailure('due_day_invalid'));
    }
    if (!isValidMonth(model.startMonth)) {
      return const Err(ValidationFailure('start_month_invalid'));
    }
    if (model.startMonth.compareTo(_clock.currentMonth()) > 0) {
      return const Err(ValidationFailure('start_month_in_future'));
    }

    final group = await _groups.getGroup(model.groupUuid);
    switch (group) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value == null) {
          return const Err(ValidationFailure('group_not_found'));
        }
        if (value.isDeleted) {
          return const Err(ValidationFailure('group_deleted'));
        }
    }

    final tenant = TenantModel(
      uuid: _uuid.v4(),
      groupUuid: model.groupUuid,
      name: name,
      createdOn: _clock.nowUtc(),
      dueDay: model.dueDay,
      startMonth: model.startMonth,
    );
    final saved = await _tenants.addTenant(tenant, model.rent);
    if (saved is Err<void>) return Err(saved.failure);

    final ensured = await _ensureRentRecords(tenantUuid: tenant.uuid);
    return ensured.map((_) => tenant.uuid);
  }
}
