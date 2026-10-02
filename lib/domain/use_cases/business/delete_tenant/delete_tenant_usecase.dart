import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';

/// Moves a tenant to Archived (soft delete). Every record and payment is kept
/// and no new months are created for the tenant afterwards.
///
/// Deleting never blocks on money still owed: the dialog shows the amount and
/// the user decides.
///
/// Validation errors: `tenant_not_found`, `tenant_deleted`.
class DeleteTenantUsecase {
  final TenantRepositoryInterface _tenants;
  final Clock _clock;

  DeleteTenantUsecase(this._tenants, this._clock);

  Future<Result<void>> call(String tenantUuid) async {
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
    return _tenants.deleteTenant(tenantUuid, _clock.currentMonth());
  }
}
