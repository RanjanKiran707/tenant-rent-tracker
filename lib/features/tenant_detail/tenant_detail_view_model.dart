import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/business/delete_tenant/delete_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/ensure_rent_records/ensure_rent_records_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/undo_payment/undo_payment_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_tenant_detail/watch_tenant_detail_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_tenant_detail/watch_tenant_detail_usecase.dart';

class TenantDetailBundle {
  final String tenantUuid;
  const TenantDetailBundle({required this.tenantUuid});
}

/// One tenant: the current month, old dues and history. The same screen shows
/// an archived tenant read-only (the use case sets `readOnly`).
class TenantDetailViewModel {
  final TenantDetailBundle bundle;
  final EnsureRentRecordsUsecase _ensureRentRecords;
  final WatchTenantDetailUsecase _watchTenantDetail;
  final DeleteTenantUsecase _deleteTenant;
  final UndoPaymentUsecase _undoPayment;

  final ValueNotifier<ViewState<WatchTenantDetailReturnModel>> state =
      ValueNotifier(const ViewStateLoading());

  /// State of the "Remove this tenant" action.
  final ValueNotifier<ViewState<void>> deleteState =
      ValueNotifier(const ViewStateIdle());

  StreamSubscription<Result<WatchTenantDetailReturnModel>>? _subscription;
  int _generation = 0;
  bool _disposed = false;

  TenantDetailViewModel({
    required this.bundle,
    required EnsureRentRecordsUsecase ensureRentRecords,
    required WatchTenantDetailUsecase watchTenantDetail,
    required DeleteTenantUsecase deleteTenant,
    required UndoPaymentUsecase undoPayment,
  })  : _ensureRentRecords = ensureRentRecords,
        _watchTenantDetail = watchTenantDetail,
        _deleteTenant = deleteTenant,
        _undoPayment = undoPayment;

  /// Creates this tenant's missing monthly records, then (re)subscribes.
  /// Call it on open and when the app resumes.
  Future<void> refresh() async {
    final generation = ++_generation;
    await _subscription?.cancel();
    _subscription = null;

    final ensured =
        await _ensureRentRecords(tenantUuid: bundle.tenantUuid);
    if (_disposed || generation != _generation) return;
    if (ensured case Err<void>(:final failure)) {
      state.value = ViewStateError(failure);
      return;
    }

    _subscription =
        _watchTenantDetail(bundle.tenantUuid).listen((result) {
      state.value = result.fold(
        (failure) => ViewStateError(failure),
        (data) => ViewStateLoaded(data),
      );
    });
  }

  Future<void> onDelete() async {
    if (deleteState.value.isLoading) return; // blocking rule: ignore re-entry
    deleteState.value = const ViewStateLoading();
    final result = await _deleteTenant(bundle.tenantUuid);
    deleteState.value = result.fold(
      (failure) => ViewStateError(failure),
      (_) => const ViewStateLoaded(null),
    );
  }

  /// Removes a payment (the Undo button). Returns the failure, or null when it
  /// worked; the list updates by itself.
  Future<Failure?> undoPayment(String paymentUuid) async {
    final result = await _undoPayment(paymentUuid);
    return result.fold((failure) => failure, (_) => null);
  }

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    state.dispose();
    deleteState.dispose();
  }
}
