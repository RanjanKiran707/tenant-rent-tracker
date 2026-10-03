import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository_interface.dart';

/// Changes a group's name (trimmed). Tenants stay in the group.
///
/// Validation errors: `group_name_required`, `group_not_found`,
/// `group_deleted`, `group_default_locked` (Uncategorized), `group_name_taken`
/// (another active group has the same name, ignoring case; keeping the same
/// name, even with different capitals, is allowed).
class RenameGroupUsecase {
  final TenantGroupRepositoryInterface _groups;

  RenameGroupUsecase(this._groups);

  Future<Result<void>> call(String groupUuid, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Err(ValidationFailure('group_name_required'));
    }

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

    final active = await _groups.getActiveGroups();
    switch (active) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        final taken = value.any(
          (g) =>
              g.uuid != groupUuid &&
              g.name.trim().toLowerCase() == trimmed.toLowerCase(),
        );
        if (taken) return const Err(ValidationFailure('group_name_taken'));
    }
    return _groups.renameGroup(groupUuid, trimmed);
  }
}
