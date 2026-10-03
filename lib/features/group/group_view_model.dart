import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/business/delete_group/delete_group_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/ensure_rent_records/ensure_rent_records_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/rename_group/rename_group_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_group/watch_group_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_group/watch_group_usecase.dart';

class GroupBundle {
  final String groupUuid;
  const GroupBundle({required this.groupUuid});
}

/// One group: its tenants (most urgent first) and this month's totals.
class GroupViewModel {
  final GroupBundle bundle;
  final EnsureRentRecordsUsecase _ensureRentRecords;
  final WatchGroupUsecase _watchGroup;
  final RenameGroupUsecase _renameGroup;
  final DeleteGroupUsecase _deleteGroup;

  final ValueNotifier<ViewState<WatchGroupReturnModel>> state = ValueNotifier(
    const ViewStateLoading(),
  );

  /// State of the "Delete this group" action.
  final ValueNotifier<ViewState<void>> deleteState = ValueNotifier(
    const ViewStateIdle(),
  );

  StreamSubscription<Result<WatchGroupReturnModel>>? _subscription;
  int _generation = 0;
  bool _disposed = false;

  GroupViewModel({
    required this.bundle,
    required EnsureRentRecordsUsecase ensureRentRecords,
    required WatchGroupUsecase watchGroup,
    required RenameGroupUsecase renameGroup,
    required DeleteGroupUsecase deleteGroup,
  }) : _ensureRentRecords = ensureRentRecords,
       _watchGroup = watchGroup,
       _renameGroup = renameGroup,
       _deleteGroup = deleteGroup;

  /// Creates any missing monthly records, then (re)subscribes. Call it on open
  /// and when the app resumes or the (simulated) date changes, like Home does.
  Future<void> refresh() async {
    final generation = ++_generation;
    await _subscription?.cancel();
    _subscription = null;

    final ensured = await _ensureRentRecords();
    if (_disposed || generation != _generation) return;
    if (ensured case Err<void>(:final failure)) {
      state.value = ViewStateError(failure);
      return;
    }

    _subscription = _watchGroup(bundle.groupUuid).listen((result) {
      state.value = result.fold(
        (failure) => ViewStateError(failure),
        (data) => ViewStateLoaded(data),
      );
    });
  }

  /// Saves a new name. Returns the failure, or null when it worked; the title
  /// updates by itself because the group is watched.
  Future<Failure?> rename(String name) async {
    final result = await _renameGroup(bundle.groupUuid, name);
    return result.fold((failure) => failure, (_) => null);
  }

  Future<void> onDelete() async {
    if (deleteState.value.isLoading) return; // blocking rule: ignore re-entry
    deleteState.value = const ViewStateLoading();
    final result = await _deleteGroup(bundle.groupUuid);
    deleteState.value = result.fold(
      (failure) => ViewStateError(failure),
      (_) => const ViewStateLoaded(null),
    );
  }

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    state.dispose();
    deleteState.dispose();
  }
}
