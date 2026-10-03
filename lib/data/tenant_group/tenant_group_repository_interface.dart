import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_model.dart';

abstract interface class TenantGroupRepositoryInterface {
  Future<Result<void>> addGroup(TenantGroupModel group);

  /// Returns null inside `Ok` when no group has this uuid. Deleted groups are
  /// returned too (check `isDeleted`).
  Future<Result<TenantGroupModel?>> getGroup(String uuid);

  /// Groups with no `deletedMonth`, oldest first.
  Future<Result<List<TenantGroupModel>>> getActiveGroups();

  /// Same list as [getActiveGroups], kept up to date.
  Stream<Result<List<TenantGroupModel>>> watchActiveGroups();

  /// Every group, deleted ones included (an archived tenant may point at a
  /// deleted group), oldest first.
  Stream<Result<List<TenantGroupModel>>> watchAllGroups();

  /// Changes only the name.
  Future<Result<void>> renameGroup(String uuid, String name);

  /// Soft delete: sets `deletedMonth` (`YYYY-MM`). The row is kept because
  /// archived tenants may still point at it.
  Future<Result<void>> deleteGroup(String uuid, String deletedMonth);
}
