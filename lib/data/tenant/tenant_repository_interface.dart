import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';

abstract interface class TenantRepositoryInterface {
  /// Saves the tenant and its first rent (effective from `startMonth`)
  /// together: both are saved or neither.
  Future<Result<void>> addTenant(TenantModel tenant, int initialRent);

  /// Returns null inside `Ok` when no tenant has this uuid.
  Future<Result<TenantModel?>> getTenant(String uuid);

  /// One tenant, active or archived. Emits again when the tenant row changes
  /// (a rename or a delete); null inside `Ok` when no tenant has this uuid.
  Stream<Result<TenantModel?>> watchTenant(String uuid);

  /// One-shot version of [watchActiveTenants], oldest first.
  Future<Result<List<TenantModel>>> getActiveTenants();

  /// Tenants with no `deletedMonth`, oldest first.
  Stream<Result<List<TenantModel>>> watchActiveTenants();

  /// Tenants with a `deletedMonth` (the Archived list), newest deletion first.
  Stream<Result<List<TenantModel>>> watchArchivedTenants();

  /// Changes only the tenant's name. Nothing else about the tenant changes.
  Future<Result<void>> renameTenant(String uuid, String name);

  /// Moves the tenant to another group. Changes only `groupUuid`.
  Future<Result<void>> setTenantGroup(String uuid, String groupUuid);

  /// Soft delete: sets `deletedMonth` (`YYYY-MM`). All rows are kept.
  Future<Result<void>> deleteTenant(String uuid, String deletedMonth);
}
