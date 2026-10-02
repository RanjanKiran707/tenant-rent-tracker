import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';

/// Changes a tenant's name. Rent, due day, months and payments are untouched.
/// The name is trimmed before it is saved.
///
/// Validation errors: `name_required`, `tenant_not_found`, `tenant_deleted`.
class RenameTenantUsecase {
  final TenantRepositoryInterface _tenants;

  RenameTenantUsecase(this._tenants);

  Future<Result<void>> call(String tenantUuid, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return const Err(ValidationFailure('name_required'));

    final found = await _tenants.getTenant(tenantUuid);
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value == null) {
          return const Err(ValidationFailure('tenant_not_found'));
        }
        if (value.isDeleted) {
          return const Err(ValidationFailure('tenant_deleted'));
        }
    }
    return _tenants.renameTenant(tenantUuid, trimmed);
  }
}
