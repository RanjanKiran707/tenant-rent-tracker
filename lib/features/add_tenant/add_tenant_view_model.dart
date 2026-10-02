import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_argument_model.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_add_tenant_form/load_add_tenant_form_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_add_tenant_form/load_add_tenant_form_usecase.dart';

class AddTenantViewModel {
  final AddTenantUsecase _addTenant;

  /// Start-month choices and the defaults.
  final LoadAddTenantFormReturnModel form;

  late final ValueNotifier<int> dueDay = ValueNotifier(form.defaultDueDay);
  late final ValueNotifier<String> startMonth =
      ValueNotifier(form.defaultStartMonth);

  /// State of the save action. `Loaded` holds the new tenant's uuid.
  final ValueNotifier<ViewState<String>> saveState =
      ValueNotifier(const ViewStateIdle());

  AddTenantViewModel({
    required LoadAddTenantFormUsecase loadForm,
    required AddTenantUsecase addTenant,
  })  : form = loadForm(),
        _addTenant = addTenant;

  Future<void> onSave({required String name, required String rentText}) async {
    if (saveState.value.isLoading) return; // blocking rule: ignore re-entry

    final rent = int.tryParse(rentText.trim());
    if (rent == null) {
      saveState.value = const ViewStateError(ValidationFailure('rent_invalid'));
      return;
    }

    saveState.value = const ViewStateLoading();
    final result = await _addTenant(AddTenantArgumentModel(
      name: name,
      rent: rent,
      dueDay: dueDay.value,
      startMonth: startMonth.value,
    ));
    saveState.value = result.fold(
      (failure) => ViewStateError(failure),
      (uuid) => ViewStateLoaded(uuid),
    );
  }

  void dispose() {
    dueDay.dispose();
    startMonth.dispose();
    saveState.dispose();
  }
}
