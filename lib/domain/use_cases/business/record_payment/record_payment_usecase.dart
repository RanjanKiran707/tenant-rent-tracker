import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/payment/payment_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/business/record_payment/record_payment_argument_model.dart';
import 'package:uuid/uuid.dart';

/// Records money received for a month. Returns the payment's uuid, which the
/// Undo snackbar passes to `UndoPaymentUsecase`.
///
/// Validation errors: `amount_invalid`, `date_invalid`, `date_in_future`.
/// An unknown `rentRecordUuid` is rejected by the database (foreign key) and
/// comes back as a `StorageFailure`.
class RecordPaymentUsecase {
  final PaymentRepositoryInterface _payments;
  final Clock _clock;
  final Uuid _uuid;

  RecordPaymentUsecase(this._payments, this._clock,
      {Uuid uuid = const Uuid()})
      : _uuid = uuid;

  Future<Result<String>> call(RecordPaymentArgumentModel model) async {
    if (model.amount <= 0) {
      return const Err(ValidationFailure('amount_invalid'));
    }
    if (!isValidDate(model.paidOn)) {
      return const Err(ValidationFailure('date_invalid'));
    }
    if (model.paidOn.compareTo(_clock.today()) > 0) {
      return const Err(ValidationFailure('date_in_future'));
    }

    final payment = PaymentModel(
      uuid: _uuid.v4(),
      rentRecordUuid: model.rentRecordUuid,
      amount: model.amount,
      paidOn: model.paidOn,
      createdOn: _clock.nowUtc(),
    );
    final saved = await _payments.addPayment(payment);
    return saved.map((_) => payment.uuid);
  }
}
