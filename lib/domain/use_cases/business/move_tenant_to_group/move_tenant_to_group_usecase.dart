import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository_interface.dart';

/// Moves an active tenant to another group. Only the group changes: rent
/// history, monthly records and payments are untouched. Moving a tenant to
/// the group it is already in does nothing and succeeds.
///
/// Validation errors: `tenant_not_found`, `tenant_deleted`, `group_not_found`,
/// `group_deleted`.
class MoveTenantToGroupUsecase {
  final TenantRepositoryInterface _tenants;
  final TenantGroupRepositoryInterface _groups;

  MoveTenantToGroupUsecase(this._tenants, this._groups);

  Future<Result<void>> call(String tenantUuid, String groupUuid) async {
    final tenant = await _tenants.getTenant(tenantUuid);
    switch (tenant) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value == null) {
          return const Err(ValidationFailure('tenant_not_found'));
        }
        if (value.isDeleted) {
          return const Err(ValidationFailure('tenant_deleted'));
        }
        if (value.groupUuid == groupUuid) return const Ok(null);
    }

    final group = await _groups.getGroup(groupUuid);
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
    return _tenants.setTenantGroup(tenantUuid, groupUuid);
  }
}
