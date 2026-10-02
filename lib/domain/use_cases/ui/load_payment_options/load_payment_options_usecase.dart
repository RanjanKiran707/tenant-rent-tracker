import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/payment/payment_repository_interface.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository_interface.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_payment_options/load_payment_options_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/tenant_dues.dart';

/// Fills the "Money received" form: which months can be paid for and which one
/// is picked first. A one-time read; it never writes.
///
/// Validation errors: `tenant_not_found`, `tenant_deleted`.
class LoadPaymentOptionsUsecase {
  final TenantRepositoryInterface _tenants;
  final RentRecordRepositoryInterface _records;
  final PaymentRepositoryInterface _payments;
  final Clock _clock;

  LoadPaymentOptionsUsecase(
    this._tenants,
    this._records,
    this._payments,
    this._clock,
  );

  Future<Result<LoadPaymentOptionsReturnModel>> call(String tenantUuid) async {
    final found = await _tenants.getTenant(tenantUuid);
    final TenantModel tenant;
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value == null) {
          return const Err(ValidationFailure('tenant_not_found'));
        }
        if (value.isDeleted) {
          return const Err(ValidationFailure('tenant_deleted'));
        }
        tenant = value;
    }

    final records = await _records.getRecords(tenantUuid);
    final List<RentRecordModel> recordList;
    switch (records) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        recordList = value;
    }

    // `.first` turns the live stream into a one-time read.
    final payments = await _payments.watchPaymentsOfTenant(tenantUuid).first;
    final List<PaymentModel> paymentList;
    switch (payments) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        paymentList = value;
    }

    final today = _clock.today();
    final current = _clock.currentMonth();
    final byRecord = groupPaymentsByRecord(paymentList);

    // Oldest first, only months that have started.
    final visible =
        recordList
            .where(
              (r) =>
                  r.month.compareTo(current) <= 0 &&
                  r.month.compareTo(tenant.startMonth) >= 0,
            )
            .toList()
          ..sort((a, b) => a.month.compareTo(b.month));

    PaymentMonthOption optionOf(RentRecordModel r) {
      final paid = paidAsOf(byRecord[r.uuid] ?? const <PaymentModel>[], today);
      return PaymentMonthOption(
        rentRecordUuid: r.uuid,
        month: r.month,
        requiredAmount: r.requiredAmount,
        paid: paid,
        balance: balanceOf(r.requiredAmount, paid),
      );
    }

    final all = visible.map(optionOf).toList();
    final options = all
        .where((o) => o.balance > 0 || o.month == current)
        .toList();

    final currentOption = all.where((o) => o.month == current).firstOrNull;
    final oldestOwing = all.where((o) => o.balance > 0).firstOrNull;
    final String? defaultUuid;
    if (currentOption != null && currentOption.balance > 0) {
      defaultUuid = currentOption.rentRecordUuid;
    } else if (oldestOwing != null) {
      defaultUuid = oldestOwing.rentRecordUuid;
    } else {
      defaultUuid = currentOption?.rentRecordUuid;
    }

    return Ok(
      LoadPaymentOptionsReturnModel(
        tenantName: tenant.name,
        today: today,
        options: options.reversed.toList(),
        defaultRentRecordUuid: defaultUuid,
      ),
    );
  }
}
