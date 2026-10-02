import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_archived_tenants/watch_archived_tenants_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_archived_tenants/watch_archived_tenants_usecase.dart';

class ArchivedViewModel {
  final ValueNotifier<ViewState<WatchArchivedTenantsReturnModel>> state =
      ValueNotifier(const ViewStateLoading());

  StreamSubscription<Result<WatchArchivedTenantsReturnModel>>? _subscription;

  ArchivedViewModel({required WatchArchivedTenantsUsecase watchArchived}) {
    _subscription = watchArchived().listen((result) {
      state.value = result.fold(
        (failure) => ViewStateError(failure),
        (data) => ViewStateLoaded(data),
      );
    });
  }

  void dispose() {
    _subscription?.cancel();
    state.dispose();
  }
}
