import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/payment/payment_repository_interface.dart';

/// Removes a payment that was just recorded (the Undo snackbar). Payments are
/// otherwise never deleted.
class UndoPaymentUsecase {
  final PaymentRepositoryInterface _payments;

  UndoPaymentUsecase(this._payments);

  Future<Result<void>> call(String paymentUuid) =>
      _payments.deletePayment(paymentUuid);
}
