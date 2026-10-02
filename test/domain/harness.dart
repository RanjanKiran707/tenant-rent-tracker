import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/payment/payment_repository.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_repository.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository.dart';
import 'package:tenant_tracker/domain/use_cases/business/ensure_rent_records/ensure_rent_records_usecase.dart';

/// A clock the test moves by hand.
class FakeClock implements Clock {
  FakeClock(this._today);
  String _today;

  /// Move "today"; the time of day stays at noon UTC.
  void setToday(String date) => _today = date;

  @override
  String today() => _today;

  @override
  DateTime nowUtc() => DateTime.parse('${_today}T12:00:00Z');
}

/// Real repositories on an in-memory database plus a [FakeClock], so use case
/// tests exercise the real transactions and streams.
class Harness {
  final AppDatabase db;
  final FakeClock clock;
  final TenantRepository tenants;
  final RentHistoryRepository history;
  final RentRecordRepository records;
  final PaymentRepository payments;

  Harness._(this.db, this.clock)
    : tenants = TenantRepository(db),
      history = RentHistoryRepository(db),
      records = RentRecordRepository(db),
      payments = PaymentRepository(db);

  factory Harness({String today = '2026-03-15'}) => Harness._(
    AppDatabase.forTesting(NativeDatabase.memory()),
    FakeClock(today),
  );

  Future<void> close() => db.close();
}

/// Adds a tenant and creates its monthly records up to the clock's month.
/// Returns the tenant uuid (equal to [id]).
Future<String> seedTenant(
  Harness h, {
  required String id,
  String? name,
  required String start,
  required int rent,
  int dueDay = 10,
}) async {
  ok(
    await h.tenants.addTenant(
      TenantModel(
        uuid: id,
        name: name ?? id,
        createdOn: h.clock.nowUtc(),
        dueDay: dueDay,
        startMonth: start,
      ),
      rent,
    ),
  );
  ok(
    await EnsureRentRecordsUsecase(h.tenants, h.history, h.records, h.clock)(
      tenantUuid: id,
    ),
  );
  return id;
}

int _paymentCounter = 0;

/// Records a payment straight into the repository, so tests can place a
/// payment on any date without moving the clock.
Future<String> payTo(
  Harness h,
  String tenantUuid,
  String month,
  int amount,
  String paidOn,
) async {
  final record = ok(
    await h.records.getRecords(tenantUuid),
  ).firstWhere((r) => r.month == month);
  final id = 'pay${_paymentCounter++}';
  ok(
    await h.payments.addPayment(
      PaymentModel(
        uuid: id,
        rentRecordUuid: record.uuid,
        amount: amount,
        paidOn: paidOn,
        createdOn: DateTime.utc(2026, 1, 1, 0, 0, _paymentCounter),
      ),
    ),
  );
  return id;
}

/// The value of an `Ok`; fails the test on an `Err`.
T ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => throw TestFailure(
    'Expected Ok, got ${failure.message}',
  ),
};

/// The message of an `Err`; fails the test on an `Ok`.
String errorOf<T>(Result<T> r) => switch (r) {
  Err(:final failure) => failure.message,
  Ok() => throw TestFailure('Expected Err, got Ok'),
};

/// True when the failure is a [ValidationFailure].
bool isValidation<T>(Result<T> r) =>
    r is Err<T> && r.failure is ValidationFailure;
