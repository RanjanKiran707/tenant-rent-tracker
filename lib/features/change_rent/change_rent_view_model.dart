import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/business/change_rent/change_rent_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_rent_change_info/load_rent_change_info_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_rent_change_info/load_rent_change_info_usecase.dart';

class ChangeRentBundle {
  final String tenantUuid;
  const ChangeRentBundle({required this.tenantUuid});
}

/// How the typed rent compares with the current one.
class RentHint {
  /// New minus current: positive = up, negative = down, 0 = same.
  final int difference;

  const RentHint(this.difference);
}

class ChangeRentViewModel {
  final ChangeRentBundle bundle;
  final LoadRentChangeInfoUsecase _loadInfo;
  final ChangeRentUsecase _changeRent;

  final ValueNotifier<ViewState<LoadRentChangeInfoReturnModel>> loadState =
      ValueNotifier(const ViewStateLoading());

  /// The typed rent; null while empty or not a number.
  final ValueNotifier<int?> newRent = ValueNotifier(null);

  final ValueNotifier<ViewState<void>> saveState = ValueNotifier(
    const ViewStateIdle(),
  );

  ChangeRentViewModel({
    required this.bundle,
    required LoadRentChangeInfoUsecase loadInfo,
    required ChangeRentUsecase changeRent,
  }) : _loadInfo = loadInfo,
       _changeRent = changeRent;

  Future<void> load() async {
    final result = await _loadInfo(bundle.tenantUuid);
    loadState.value = result.fold(
      (failure) => ViewStateError(failure),
      (info) => ViewStateLoaded(info),
    );
  }

  void onRentChanged(String text) => newRent.value = int.tryParse(text.trim());

  /// Null until a valid rent is typed.
  RentHint? get hint {
    final info = loadState.value;
    final value = newRent.value;
    if (info is! ViewStateLoaded<LoadRentChangeInfoReturnModel> ||
        value == null ||
        value <= 0) {
      return null;
    }
    return RentHint(value - info.data.currentRent);
  }

  Future<void> onSave() async {
    if (saveState.value.isLoading) return; // blocking rule: ignore re-entry

    final value = newRent.value;
    if (value == null) {
      saveState.value = const ViewStateError(ValidationFailure('rent_invalid'));
      return;
    }

    saveState.value = const ViewStateLoading();
    final result = await _changeRent(bundle.tenantUuid, value);
    saveState.value = result.fold(
      (failure) => ViewStateError(failure),
      (_) => const ViewStateLoaded(null),
    );
  }

  void dispose() {
    loadState.dispose();
    newRent.dispose();
    saveState.dispose();
  }
}
