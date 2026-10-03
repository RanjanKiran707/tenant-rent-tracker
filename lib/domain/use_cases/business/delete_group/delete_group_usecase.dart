import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository_interface.dart';

/// Deletes a group (soft delete: the row is kept, because archived tenants
/// still point at it). Allowed only when no active tenant is in the group.
///
/// Validation errors: `group_not_found`, `group_deleted`,
/// `group_default_locked` (Uncategorized), `group_not_empty`.
class DeleteGroupUsecase {
  final TenantGroupRepositoryInterface _groups;
  final TenantRepositoryInterface _tenants;
  final Clock _clock;

  DeleteGroupUsecase(this._groups, this._tenants, this._clock);

  Future<Result<void>> call(String groupUuid) async {
    final found = await _groups.getGroup(groupUuid);
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value == null) {
          return const Err(ValidationFailure('group_not_found'));
        }
        if (value.isDeleted) {
          return const Err(ValidationFailure('group_deleted'));
        }
        if (value.isUncategorized) {
          return const Err(ValidationFailure('group_default_locked'));
        }
    }

    final active = await _tenants.getActiveTenants();
    switch (active) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value.any((t) => t.groupUuid == groupUuid)) {
          return const Err(ValidationFailure('group_not_empty'));
        }
    }
    return _groups.deleteGroup(groupUuid, _clock.currentMonth());
  }
}
