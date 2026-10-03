import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/data/payment/payment_repository_interface.dart';

/// Corrects the amount and the date received of a payment that was already
/// recorded. The month the payment is for does not change, and neither does
/// the order of payments received on the same day.
///
/// The month's status and balance are not stored, so they follow by
/// themselves: for example, lowering an amount can turn Completed into
/// Partial, and moving the date past the due day can turn it into Late
/// Completed.
///
/// Validation errors: `amount_invalid`, `date_invalid`, `date_in_future`,
/// `payment_not_found`.
class EditPaymentUsecase {
  final PaymentRepositoryInterface _payments;
  final Clock _clock;

  EditPaymentUsecase(this._payments, this._clock);

  Future<Result<void>> call(
    String paymentUuid, {
    required int amount,
    required String paidOn,
  }) async {
    if (amount <= 0) return const Err(ValidationFailure('amount_invalid'));
    if (!isValidDate(paidOn)) {
      return const Err(ValidationFailure('date_invalid'));
    }
    if (paidOn.compareTo(_clock.today()) > 0) {
      return const Err(ValidationFailure('date_in_future'));
    }

    final found = await _payments.getPayment(paymentUuid);
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value == null) {
          return const Err(ValidationFailure('payment_not_found'));
        }
    }
    return _payments.updatePayment(paymentUuid, amount: amount, paidOn: paidOn);
  }
}
