import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_repository_interface.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_rent_change_info/load_rent_change_info_return_model.dart';

/// Fills the "Change rent" form. The effective month is the same one
/// `ChangeRentUsecase` will use. A one-time read; it never writes.
///
/// Validation errors: `tenant_not_found`, `tenant_deleted`.
class LoadRentChangeInfoUsecase {
  final TenantRepositoryInterface _tenants;
  final RentHistoryRepositoryInterface _history;
  final Clock _clock;

  LoadRentChangeInfoUsecase(this._tenants, this._history, this._clock);

  Future<Result<LoadRentChangeInfoReturnModel>> call(String tenantUuid) async {
    final found = await _tenants.getTenant(tenantUuid);
    final String name;
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
        name = value.name;
    }

    final current = _clock.currentMonth();
    final rent = await _history.getRentForMonth(tenantUuid, current);
    return rent.map(
      (amount) => LoadRentChangeInfoReturnModel(
        tenantName: name,
        currentRent: amount ?? 0,
        currentMonth: current,
        effectiveFromMonth: addMonths(current, 1),
      ),
    );
  }
}
