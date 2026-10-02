import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_add_tenant_form/load_add_tenant_form_return_model.dart';

/// Fills the "Add a tenant" form. Nothing is read from storage, so it cannot
/// fail and returns the model directly.
class LoadAddTenantFormUsecase {
  final Clock _clock;

  LoadAddTenantFormUsecase(this._clock);

  LoadAddTenantFormReturnModel call() {
    final current = _clock.currentMonth();
    return LoadAddTenantFormReturnModel(
      startMonthOptions: monthsBetween(addMonths(current, -11), current),
      defaultStartMonth: current,
      defaultDueDay: defaultDueDay,
    );
  }
}
