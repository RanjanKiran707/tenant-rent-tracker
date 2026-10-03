import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_argument_model.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_add_tenant_form/load_add_tenant_form_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_add_tenant_form/load_add_tenant_form_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_groups/watch_groups_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_groups/watch_groups_usecase.dart';

class AddTenantViewModel {
  final AddTenantUsecase _addTenant;

  /// Start-month choices and the defaults.
  final LoadAddTenantFormReturnModel form;

  late final ValueNotifier<int> dueDay = ValueNotifier(form.defaultDueDay);
  late final ValueNotifier<String> startMonth = ValueNotifier(
    form.defaultStartMonth,
  );

  /// The group the tenant will be listed under.
  final ValueNotifier<String> groupUuid;

  /// The groups to choose from. Starts with Uncategorized only (it always
  /// exists) until the real list arrives.
  final ValueNotifier<List<GroupOption>> groups = ValueNotifier(const [
    GroupOption(groupUuid: uncategorizedGroupUuid, name: 'Uncategorized'),
  ]);

  /// State of the save action. `Loaded` holds the new tenant's uuid.
  final ValueNotifier<ViewState<String>> saveState = ValueNotifier(
    const ViewStateIdle(),
  );

  StreamSubscription<Result<List<GroupOption>>>? _groupsSubscription;

  /// [initialGroupUuid] is the group the user came from; Uncategorized when
  /// the form is opened from Home.
  AddTenantViewModel({
    required LoadAddTenantFormUsecase loadForm,
    required AddTenantUsecase addTenant,
    required WatchGroupsUsecase watchGroups,
    String initialGroupUuid = uncategorizedGroupUuid,
  }) : form = loadForm(),
       _addTenant = addTenant,
       groupUuid = ValueNotifier(initialGroupUuid) {
    _groupsSubscription = watchGroups().listen((result) {
      if (result case Ok(:final value)) {
        groups.value = value;
        // The chosen group is gone (deleted meanwhile): fall back.
        if (!value.any((g) => g.groupUuid == groupUuid.value)) {
          groupUuid.value = uncategorizedGroupUuid;
        }
      }
    });
  }

  Future<void> onSave({required String name, required String rentText}) async {
    if (saveState.value.isLoading) return; // blocking rule: ignore re-entry

    final rent = int.tryParse(rentText.trim());
    if (rent == null) {
      saveState.value = const ViewStateError(ValidationFailure('rent_invalid'));
      return;
    }

    saveState.value = const ViewStateLoading();
    final result = await _addTenant(
      AddTenantArgumentModel(
        name: name,
        rent: rent,
        dueDay: dueDay.value,
        startMonth: startMonth.value,
        groupUuid: groupUuid.value,
      ),
    );
    saveState.value = result.fold(
      (failure) => ViewStateError(failure),
      (uuid) => ViewStateLoaded(uuid),
    );
  }

  void dispose() {
    _groupsSubscription?.cancel();
    dueDay.dispose();
    startMonth.dispose();
    groupUuid.dispose();
    groups.dispose();
    saveState.dispose();
  }
}
