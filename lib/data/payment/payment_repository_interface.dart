import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';

abstract interface class PaymentRepositoryInterface {
  Future<Result<void>> addPayment(PaymentModel payment);

  /// Removes a payment. Used only for the immediate Undo.
  Future<Result<void>> deletePayment(String uuid);

  /// Payments of one month's record, oldest `paidOn` first.
  Future<Result<List<PaymentModel>>> getPaymentsOfRecord(String rentRecordUuid);

  /// Payments of every month of one tenant, re-emitted on change.
  Stream<Result<List<PaymentModel>>> watchPaymentsOfTenant(String tenantUuid);

  /// Payments of every tenant, re-emitted on change.
  Stream<Result<List<PaymentModel>>> watchAllPayments();
}
