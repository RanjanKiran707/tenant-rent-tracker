import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/settings/settings_repository.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_argument_model.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/change_rent/change_rent_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/delete_tenant/delete_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/ensure_rent_records/ensure_rent_records_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/record_payment/record_payment_argument_model.dart';
import 'package:tenant_tracker/domain/use_cases/business/record_payment/record_payment_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/settings/settings_usecases.dart';
import 'package:tenant_tracker/domain/use_cases/business/undo_payment/undo_payment_usecase.dart';

import '../harness.dart';

void main() {
  late Harness h;
  late EnsureRentRecordsUsecase ensure;
  late AddTenantUsecase addTenant;
  late RecordPaymentUsecase recordPayment;
  late UndoPaymentUsecase undoPayment;
  late ChangeRentUsecase changeRent;
  late DeleteTenantUsecase deleteTenant;

  // Today is 2026-03-15 unless a test moves the clock.
  setUp(() {
    h = Harness();
    ensure = EnsureRentRecordsUsecase(h.tenants, h.history, h.records, h.clock);
    addTenant = AddTenantUsecase(h.tenants, ensure, h.clock);
    recordPayment = RecordPaymentUsecase(h.payments, h.clock);
    undoPayment = UndoPaymentUsecase(h.payments);
    changeRent = ChangeRentUsecase(h.tenants, h.history, h.clock);
    deleteTenant = DeleteTenantUsecase(h.tenants, h.clock);
  });

  tearDown(() => h.close());

  Future<Result<String>> add({
    String name = 'Ramesh',
    int rent = 5000,
    int dueDay = 10,
    String start = '2026-01',
  }) =>
      addTenant(AddTenantArgumentModel(
        name: name,
        rent: rent,
        dueDay: dueDay,
        startMonth: start,
      ));

  Future<List<String>> monthsOf(String tenantUuid) async =>
      ok(await h.records.getRecords(tenantUuid)).map((r) => r.month).toList();

  Future<Map<String, int>> amountsOf(String tenantUuid) async => {
        for (final r in ok(await h.records.getRecords(tenantUuid)))
          r.month: r.requiredAmount,
      };

  group('AddTenantUsecase', () {
    test('saves the tenant, its first rent and every month up to now',
        () async {
      final id = ok(await add(name: '  Ramesh  ', rent: 5000, dueDay: 15));

      final tenant = ok(await h.tenants.getTenant(id))!;
      expect(tenant.name, 'Ramesh'); // trimmed
      expect(tenant.dueDay, 15);
      expect(tenant.startMonth, '2026-01');
      expect(ok(await h.history.getRentForMonth(id, '2026-01')), 5000);
      expect(await monthsOf(id), ['2026-01', '2026-02', '2026-03']);
      expect((await amountsOf(id)).values, everyElement(5000));
    });

    test('starting this month creates one record', () async {
      final id = ok(await add(start: '2026-03'));
      expect(await monthsOf(id), ['2026-03']);
    });

    test('a blank name is rejected and nothing is saved', () async {
      expect(errorOf(await add(name: '   ')), 'name_required');
      expect(ok(await h.tenants.getActiveTenants()), isEmpty);
    });

    test('rent must be above zero', () async {
      expect(errorOf(await add(rent: 0)), 'rent_invalid');
      expect(errorOf(await add(rent: -100)), 'rent_invalid');
    });

    test('due day must be 1 to 31', () async {
      expect(errorOf(await add(dueDay: 0)), 'due_day_invalid');
      expect(errorOf(await add(dueDay: 32)), 'due_day_invalid');
      ok(await add(dueDay: 1, name: 'a'));
      ok(await add(dueDay: 31, name: 'b'));
    });

    test('start month must be a real month', () async {
      expect(errorOf(await add(start: '2026-13')), 'start_month_invalid');
      expect(errorOf(await add(start: 'March')), 'start_month_invalid');
      expect(errorOf(await add(start: '2026-3')), 'start_month_invalid');
    });

    test('start month cannot be after the current month', () async {
      expect(errorOf(await add(start: '2026-04')), 'start_month_in_future');
      ok(await add(start: '2026-03'));
    });

    test('validation failures are ValidationFailure, not storage errors',
        () async {
      expect(isValidation(await add(name: '')), isTrue);
    });
  });

  group('EnsureRentRecordsUsecase', () {
    test('running it again creates no duplicates', () async {
      final id = ok(await add());
      ok(await ensure());
      ok(await ensure());

      expect(await monthsOf(id), ['2026-01', '2026-02', '2026-03']);
    });

    test('creates the new month when the month rolls over', () async {
      final id = ok(await add());
      h.clock.setToday('2026-04-02');
      ok(await ensure());

      expect(await monthsOf(id), ['2026-01', '2026-02', '2026-03', '2026-04']);
    });

    test('after a long gap every skipped month is created', () async {
      final id = ok(await add(start: '2026-03'));
      h.clock.setToday('2026-08-01');
      ok(await ensure());

      expect(await monthsOf(id), [
        '2026-03',
        '2026-04',
        '2026-05',
        '2026-06',
        '2026-07',
        '2026-08',
      ]);
    });

    test('each month takes the rent that was in force for it', () async {
      final id = ok(await add(start: '2026-01', rent: 5000));
      // Rent changes from April, and from June.
      ok(await h.history
          .changeRent(tenantUuid: id, effectiveFromMonth: '2026-04', amount: 6000));
      ok(await h.history
          .changeRent(tenantUuid: id, effectiveFromMonth: '2026-06', amount: 4000));
      h.clock.setToday('2026-07-01');
      ok(await ensure());

      expect(await amountsOf(id), {
        '2026-01': 5000,
        '2026-02': 5000,
        '2026-03': 5000,
        '2026-04': 6000,
        '2026-05': 6000,
        '2026-06': 4000,
        '2026-07': 4000,
      });
    });

    test('an existing record keeps its snapshot', () async {
      final id = ok(await add());
      // Make March's snapshot differ from what the history says (5000).
      ok(await h.records.updateRequiredAmount(id, '2026-03', 1234));

      ok(await ensure());

      expect((await amountsOf(id))['2026-03'], 1234);
    });

    test('for one tenant only when a uuid is given', () async {
      final a = ok(await add(name: 'a', start: '2026-03'));
      final b = ok(await add(name: 'b', start: '2026-03'));
      h.clock.setToday('2026-04-01');

      ok(await ensure(tenantUuid: a));

      expect(await monthsOf(a), ['2026-03', '2026-04']);
      expect(await monthsOf(b), ['2026-03']);
    });

    test('an unknown tenant is a validation error', () async {
      expect(errorOf(await ensure(tenantUuid: 'nope')), 'tenant_not_found');
    });

    test('deleted tenants get no new months', () async {
      final id = ok(await add(start: '2026-03'));
      ok(await deleteTenant(id));
      h.clock.setToday('2026-06-01');

      ok(await ensure());
      ok(await ensure(tenantUuid: id));

      expect(await monthsOf(id), ['2026-03']);
    });

    test('with no tenants it succeeds and does nothing', () async {
      ok(await ensure());
    });
  });

  group('RecordPaymentUsecase', () {
    late String recordId;

    setUp(() async {
      final id = ok(await add(start: '2026-03'));
      recordId = ok(await h.records.getRecords(id)).single.uuid;
    });

    Future<Result<String>> pay({int amount = 2000, String on = '2026-03-12'}) =>
        recordPayment(RecordPaymentArgumentModel(
          rentRecordUuid: recordId,
          amount: amount,
          paidOn: on,
        ));

    test('saves the payment and returns its uuid', () async {
      final paymentId = ok(await pay());

      final saved = ok(await h.payments.getPaymentsOfRecord(recordId));
      expect(saved.single.uuid, paymentId);
      expect(saved.single.amount, 2000);
      expect(saved.single.paidOn, '2026-03-12');
    });

    test('paying today is allowed', () async {
      ok(await pay(on: '2026-03-15'));
    });

    test('a future date is rejected and nothing is saved', () async {
      expect(errorOf(await pay(on: '2026-03-16')), 'date_in_future');
      expect(ok(await h.payments.getPaymentsOfRecord(recordId)), isEmpty);
    });

    test('a malformed or impossible date is rejected', () async {
      expect(errorOf(await pay(on: '15/03/2026')), 'date_invalid');
      expect(errorOf(await pay(on: '2026-02-30')), 'date_invalid');
      expect(errorOf(await pay(on: '2026-03')), 'date_invalid');
    });

    test('amount must be above zero', () async {
      expect(errorOf(await pay(amount: 0)), 'amount_invalid');
      expect(errorOf(await pay(amount: -5)), 'amount_invalid');
    });

    test('an unknown month record comes back as a StorageFailure', () async {
      final r = await recordPayment(const RecordPaymentArgumentModel(
        rentRecordUuid: 'nope',
        amount: 100,
        paidOn: '2026-03-10',
      ));
      expect((r as Err<String>).failure, isA<StorageFailure>());
    });

    test('a payment for an older month is allowed (paying old dues)',
        () async {
      final id = ok(await add(name: 'old', start: '2026-01'));
      final january = ok(await h.records.getRecords(id)).first;

      ok(await recordPayment(RecordPaymentArgumentModel(
        rentRecordUuid: january.uuid,
        amount: 5000,
        paidOn: '2026-03-15',
      )));

      expect(ok(await h.payments.getPaymentsOfRecord(january.uuid)), hasLength(1));
    });

    test('Undo removes exactly that payment', () async {
      final first = ok(await pay(amount: 1000));
      final second = ok(await pay(amount: 2000));

      ok(await undoPayment(second));

      final left = ok(await h.payments.getPaymentsOfRecord(recordId));
      expect(left.map((p) => p.uuid), [first]);
    });

    test('Undo of an unknown payment is harmless', () async {
      ok(await undoPayment('nope'));
    });
  });

  group('ChangeRentUsecase', () {
    late String id;

    // Tenant starts 2026-01 at 5000, so Jan, Feb and Mar records exist.
    setUp(() async {
      id = ok(await add(start: '2026-01', rent: 5000));
    });

    test('applies from next month only: past and current months keep 5000',
        () async {
      ok(await changeRent(id, 7000));

      expect(await amountsOf(id), {
        '2026-01': 5000,
        '2026-02': 5000,
        '2026-03': 5000,
      });
      expect(ok(await h.history.getRentForMonth(id, '2026-03')), 5000);
      expect(ok(await h.history.getRentForMonth(id, '2026-04')), 7000);
    });

    test('the first month is not changed either, while its record exists',
        () async {
      final first = ok(await add(name: 'x', start: '2026-03', rent: 5000));

      ok(await changeRent(first, 9000));

      expect((await amountsOf(first))['2026-03'], 5000);
    });

    test('next month then gets the new rent when its record is created',
        () async {
      ok(await changeRent(id, 7000));
      h.clock.setToday('2026-04-01');
      ok(await ensure());

      expect((await amountsOf(id))['2026-04'], 7000);
    });

    test('if next month\'s record already exists it is updated', () async {
      // Put an April record in place before the change.
      ok(await h.records.insertMissing([
        RentRecordModel(
          uuid: 'apr',
          tenantUuid: id,
          month: '2026-04',
          requiredAmount: 5000,
        ),
      ]));

      ok(await changeRent(id, 7000));

      expect((await amountsOf(id))['2026-04'], 7000);
      expect((await amountsOf(id))['2026-03'], 5000);
    });

    test('several changes in the same month: the last one wins', () async {
      ok(await changeRent(id, 7000));
      ok(await changeRent(id, 6500));

      expect(ok(await h.history.getRentForMonth(id, '2026-04')), 6500);
      final history = ok(await h.history.getHistory(id));
      expect(history.where((e) => e.effectiveFromMonth == '2026-04'), hasLength(1));
    });

    test('a decrease does not reduce backlog', () async {
      ok(await changeRent(id, 1000));

      expect((await amountsOf(id)).values, everyElement(5000));
    });

    test('next month is computed across a year end', () async {
      h.clock.setToday('2026-12-20');
      ok(await changeRent(id, 7000));

      expect(ok(await h.history.getRentForMonth(id, '2027-01')), 7000);
      expect(ok(await h.history.getRentForMonth(id, '2026-12')), 5000);
    });

    test('rent must be above zero', () async {
      expect(errorOf(await changeRent(id, 0)), 'rent_invalid');
      expect(errorOf(await changeRent(id, -1)), 'rent_invalid');
    });

    test('unknown tenant', () async {
      expect(errorOf(await changeRent('nope', 7000)), 'tenant_not_found');
    });

    test('a deleted tenant cannot get a rent change', () async {
      ok(await deleteTenant(id));
      expect(errorOf(await changeRent(id, 7000)), 'tenant_deleted');
    });
  });

  group('DeleteTenantUsecase', () {
    test('archives the tenant with the current month and keeps everything',
        () async {
      final id = ok(await add(start: '2026-02'));
      final first = ok(await h.records.getRecords(id)).first;
      ok(await recordPayment(RecordPaymentArgumentModel(
        rentRecordUuid: first.uuid,
        amount: 1000,
        paidOn: '2026-02-05',
      )));

      ok(await deleteTenant(id));

      final tenant = ok(await h.tenants.getTenant(id))!;
      expect(tenant.deletedMonth, '2026-03');
      expect(ok(await h.tenants.getActiveTenants()), isEmpty);
      expect(await monthsOf(id), ['2026-02', '2026-03']);
      expect(ok(await h.payments.getPaymentsOfRecord(first.uuid)), hasLength(1));
      expect(ok(await h.history.getHistory(id)), hasLength(1));
    });

    test('deleting a tenant that still owes money is allowed', () async {
      final id = ok(await add(start: '2026-01'));
      ok(await deleteTenant(id));
    });

    test('unknown tenant', () async {
      expect(errorOf(await deleteTenant('nope')), 'tenant_not_found');
    });

    test('deleting twice is rejected and keeps the first month', () async {
      final id = ok(await add());
      ok(await deleteTenant(id));
      h.clock.setToday('2026-05-01');

      expect(errorOf(await deleteTenant(id)), 'tenant_deleted');
      expect(ok(await h.tenants.getTenant(id))!.deletedMonth, '2026-03');
    });
  });

  group('settings use cases', () {
    late SettingsRepository settings;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      settings = SettingsRepository(await SharedPreferences.getInstance());
    });

    test('defaults, then language, tips and welcome round trip', () async {
      expect(ok(await LoadSettingsUsecase(settings)()).languageCode, 'en');

      ok(await SetLanguageUsecase(settings)('kn'));
      ok(await SetShowTipsUsecase(settings)(false));
      ok(await MarkWelcomeSeenUsecase(settings)());

      final loaded = ok(await LoadSettingsUsecase(settings)());
      expect(loaded.languageCode, 'kn');
      expect(loaded.showTips, isFalse);
      expect(loaded.seenWelcome, isTrue);
    });

    test('an unsupported language is rejected and not saved', () async {
      expect(errorOf(await SetLanguageUsecase(settings)('fr')),
          'language_unsupported');
      expect(ok(await LoadSettingsUsecase(settings)()).languageCode, 'en');
    });
  });
}
