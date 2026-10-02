import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/business/record_payment/record_payment_argument_model.dart';
import 'package:tenant_tracker/domain/use_cases/business/record_payment/record_payment_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_payment_options/load_payment_options_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_payment_options/load_payment_options_usecase.dart';

class RecordPaymentBundle {
  final String tenantUuid;

  /// The month to preselect (for "Record old dues received"); null = default.
  final String? initialRentRecordUuid;

  const RecordPaymentBundle({
    required this.tenantUuid,
    this.initialRentRecordUuid,
  });
}

/// What the screen returns after a successful save: enough for the caller to
/// show "₹X saved" with an Undo button.
class RecordedPayment {
  final String paymentUuid;
  final int amount;

  const RecordedPayment({required this.paymentUuid, required this.amount});
}

/// What the balance will be once the typed amount is saved.
class PaymentHint {
  /// Still owed after this payment (0 when the month is fully paid).
  final int balanceAfter;

  /// Paid above the required amount (0 when none).
  final int extra;

  const PaymentHint({required this.balanceAfter, required this.extra});

  bool get fullyPaid => balanceAfter == 0;
}

class RecordPaymentViewModel {
  final RecordPaymentBundle bundle;
  final LoadPaymentOptionsUsecase _loadPaymentOptions;
  final RecordPaymentUsecase _recordPayment;

  /// The months to choose from, loaded once.
  final ValueNotifier<ViewState<LoadPaymentOptionsReturnModel>> loadState =
      ValueNotifier(const ViewStateLoading());

  /// The chosen month's record.
  final ValueNotifier<String?> selectedRecord = ValueNotifier(null);

  /// The typed amount; null while empty or not a number.
  final ValueNotifier<int?> amount = ValueNotifier(null);

  /// `YYYY-MM-DD`
  final ValueNotifier<String> date = ValueNotifier('');

  /// State of the save action. `Loaded` holds the new payment's uuid (for Undo).
  final ValueNotifier<ViewState<String>> saveState =
      ValueNotifier(const ViewStateIdle());

  RecordPaymentViewModel({
    required this.bundle,
    required LoadPaymentOptionsUsecase loadPaymentOptions,
    required RecordPaymentUsecase recordPayment,
  })  : _loadPaymentOptions = loadPaymentOptions,
        _recordPayment = recordPayment;

  Future<void> load() async {
    final result = await _loadPaymentOptions(bundle.tenantUuid);
    result.fold(
      (failure) => loadState.value = ViewStateError(failure),
      (data) {
        selectedRecord.value =
            bundle.initialRentRecordUuid ?? data.defaultRentRecordUuid;
        date.value = data.today;
        loadState.value = ViewStateLoaded(data);
      },
    );
  }

  PaymentMonthOption? get selectedOption {
    final data = loadState.value;
    if (data is! ViewStateLoaded<LoadPaymentOptionsReturnModel>) return null;
    for (final option in data.data.options) {
      if (option.rentRecordUuid == selectedRecord.value) return option;
    }
    return null;
  }

  void onMonthChanged(String rentRecordUuid) =>
      selectedRecord.value = rentRecordUuid;

  void onAmountChanged(String text) => amount.value = int.tryParse(text.trim());

  void onDateChanged(String value) => date.value = value;

  /// The balance of the chosen month, for the "fill the full balance" button.
  int get fullBalance => selectedOption?.balance ?? 0;

  /// Null until a valid amount is typed.
  PaymentHint? get hint {
    final option = selectedOption;
    final value = amount.value;
    if (option == null || value == null || value <= 0) return null;
    final left = option.balance - value;
    return PaymentHint(
      balanceAfter: left > 0 ? left : 0,
      extra: left < 0 ? -left : 0,
    );
  }

  Future<void> onSave() async {
    if (saveState.value.isLoading) return; // blocking rule: ignore re-entry

    final record = selectedRecord.value;
    final value = amount.value;
    if (record == null) {
      saveState.value =
          const ViewStateError(ValidationFailure('tenant_not_found'));
      return;
    }
    if (value == null) {
      saveState.value =
          const ViewStateError(ValidationFailure('amount_invalid'));
      return;
    }

    saveState.value = const ViewStateLoading();
    final result = await _recordPayment(RecordPaymentArgumentModel(
      rentRecordUuid: record,
      amount: value,
      paidOn: date.value,
    ));
    saveState.value = result.fold(
      (failure) => ViewStateError(failure),
      (uuid) => ViewStateLoaded(uuid),
    );
  }

  void dispose() {
    loadState.dispose();
    selectedRecord.dispose();
    amount.dispose();
    date.dispose();
    saveState.dispose();
  }
}
