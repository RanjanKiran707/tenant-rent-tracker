import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_group/add_group_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/ensure_rent_records/ensure_rent_records_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_usecase.dart';

class HomeViewModel {
  final EnsureRentRecordsUsecase _ensureRentRecords;
  final AddGroupUsecase _addGroup;
  final WatchHomeUsecase _watchHome;

  final ValueNotifier<ViewState<WatchHomeReturnModel>> state = ValueNotifier(
    const ViewStateLoading(),
  );

  StreamSubscription<Result<WatchHomeReturnModel>>? _subscription;

  /// Bumped by every [refresh], so an older refresh that is still waiting on
  /// the database does not subscribe after a newer one.
  int _generation = 0;
  bool _disposed = false;

  HomeViewModel({
    required EnsureRentRecordsUsecase ensureRentRecords,
    required AddGroupUsecase addGroup,
    required WatchHomeUsecase watchHome,
  }) : _ensureRentRecords = ensureRentRecords,
       _addGroup = addGroup,
       _watchHome = watchHome;

  /// Creates any missing monthly records, then (re)subscribes to the home
  /// list. Call it when the screen opens and when the app comes back to the
  /// front, so the list is right after midnight or a new month.
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

    _subscription = _watchHome().listen((result) {
      state.value = result.fold(
        (failure) => ViewStateError(failure),
        (data) => ViewStateLoaded(data),
      );
    });
  }

  /// Adds a group. Returns the failure (an empty or taken name), or null when
  /// it worked; the group list updates by itself.
  Future<Failure?> addGroup(String name) async {
    final result = await _addGroup(name);
    return result.fold((failure) => failure, (_) => null);
  }

  void dispose() {
    _disposed = true;
    _subscription?.cancel(); // cancel first, so no event arrives after dispose
    state.dispose();
  }
}
