import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_repository_interface.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';

/// Changes a tenant's rent. The new rent applies from NEXT month only
/// (specs.md): this month and every past month, backlog included, keep the
/// amount they already have, including the tenant's first month.
///
/// Several changes in the same month: the last one wins. If next month's
/// record already exists it gets the new amount (done by the repository in the
/// same transaction).
///
/// Validation errors: `rent_invalid`, `tenant_not_found`, `tenant_deleted`.
class ChangeRentUsecase {
  final TenantRepositoryInterface _tenants;
  final RentHistoryRepositoryInterface _history;
  final Clock _clock;

  ChangeRentUsecase(this._tenants, this._history, this._clock);

  Future<Result<void>> call(String tenantUuid, int newRent) async {
    if (newRent <= 0) return const Err(ValidationFailure('rent_invalid'));

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

    return _history.changeRent(
      tenantUuid: tenantUuid,
      effectiveFromMonth: addMonths(_clock.currentMonth(), 1),
      amount: newRent,
    );
  }
}
