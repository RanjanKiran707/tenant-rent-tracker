import 'package:drift/drift.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/database/repository_guard.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/payment/payment_repository_interface.dart';

class PaymentRepository implements PaymentRepositoryInterface {
  final AppDatabase _db;

  PaymentRepository(this._db);

  @override
  Future<Result<void>> addPayment(PaymentModel payment) {
    return guard(() async {
      await _db.into(_db.payments).insert(
            PaymentsCompanion.insert(
              uuid: payment.uuid,
              rentRecordUuid: payment.rentRecordUuid,
              amount: payment.amount,
              paidOn: payment.paidOn,
              createdOn: payment.createdOn,
            ),
          );
    });
  }

  @override
  Future<Result<void>> deletePayment(String uuid) {
    return guard(() async {
      await (_db.delete(_db.payments)..where((p) => p.uuid.equals(uuid))).go();
    });
  }

  @override
  Future<Result<List<PaymentModel>>> getPaymentsOfRecord(
    String rentRecordUuid,
  ) {
    return guard(() async {
      final rows = await (_db.select(_db.payments)
            ..where((p) => p.rentRecordUuid.equals(rentRecordUuid))
            ..orderBy([
              (p) => OrderingTerm.asc(p.paidOn),
              (p) => OrderingTerm.asc(p.createdOn),
            ]))
          .get();
      return rows.map(_fromRow).toList();
    });
  }

  @override
  Stream<Result<List<PaymentModel>>> watchPaymentsOfTenant(String tenantUuid) {
    final query = _db.select(_db.payments).join([
      innerJoin(
        _db.rentRecords,
        _db.rentRecords.uuid.equalsExp(_db.payments.rentRecordUuid),
      ),
    ])
      ..where(_db.rentRecords.tenantUuid.equals(tenantUuid))
      ..orderBy([
        OrderingTerm.asc(_db.payments.paidOn),
        OrderingTerm.asc(_db.payments.createdOn),
      ]);
    return guardStream(
      query.watch().map(
            (rows) =>
                rows.map((r) => _fromRow(r.readTable(_db.payments))).toList(),
          ),
    );
  }

  @override
  Stream<Result<List<PaymentModel>>> watchAllPayments() {
    final query = _db.select(_db.payments)
      ..orderBy([
        (p) => OrderingTerm.asc(p.paidOn),
        (p) => OrderingTerm.asc(p.createdOn),
      ]);
    return guardStream(
      query.watch().map((rows) => rows.map(_fromRow).toList()),
    );
  }

  PaymentModel _fromRow(PaymentRow r) => PaymentModel(
        uuid: r.uuid,
        rentRecordUuid: r.rentRecordUuid,
        amount: r.amount,
        paidOn: r.paidOn,
        createdOn: r.createdOn,
      );
}
