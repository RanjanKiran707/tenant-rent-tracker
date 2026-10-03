import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/settings/settings_repository.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_group/add_group_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_argument_model.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/change_rent/change_rent_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/delete_group/delete_group_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/delete_tenant/delete_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/edit_payment/edit_payment_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/ensure_rent_records/ensure_rent_records_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/move_tenant_to_group/move_tenant_to_group_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/record_payment/record_payment_argument_model.dart';
import 'package:tenant_tracker/domain/use_cases/business/record_payment/record_payment_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/rename_group/rename_group_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/rename_tenant/rename_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/settings/settings_usecases.dart';
import 'package:tenant_tracker/domain/use_cases/business/undo_payment/undo_payment_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';

import '../harness.dart';

void main() {
  late Harness h;
  late EnsureRentRecordsUsecase ensure;
  late AddTenantUsecase addTenant;
  late RecordPaymentUsecase recordPayment;
  late UndoPaymentUsecase undoPayment;
  late ChangeRentUsecase changeRent;
  late DeleteTenantUsecase deleteTenant;
  late AddGroupUsecase addGroup;
  late RenameGroupUsecase renameGroup;
  late DeleteGroupUsecase deleteGroup;
  late MoveTenantToGroupUsecase moveTenant;

  // Today is 2026-03-15 unless a test moves the clock.
  setUp(() {
    h = Harness();
    ensure = EnsureRentRecordsUsecase(h.tenants, h.history, h.records, h.clock);
    addTenant = AddTenantUsecase(h.tenants, h.groups, ensure, h.clock);
    addGroup = AddGroupUsecase(h.groups, h.clock);
    renameGroup = RenameGroupUsecase(h.groups);
    deleteGroup = DeleteGroupUsecase(h.groups, h.tenants, h.clock);
    moveTenant = MoveTenantToGroupUsecase(h.tenants, h.groups);
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
    String group = uncategorizedGroupUuid,
  }) => addTenant(
    AddTenantArgumentModel(
      name: name,
      rent: rent,
      dueDay: dueDay,
      startMonth: start,
      groupUuid: group,
    ),
  );

  Future<List<String>> monthsOf(String tenantUuid) async =>
      ok(await h.records.getRecords(tenantUuid)).map((r) => r.month).toList();

  Future<Map<String, int>> amountsOf(String tenantUuid) async => {
    for (final r in ok(await h.records.getRecords(tenantUuid)))
      r.month: r.requiredAmount,
  };

  group('AddTenantUsecase', () {
    test(
      'saves the tenant, its first rent and every month up to now',
      () async {
        final id = ok(await add(name: '  Ramesh  ', rent: 5000, dueDay: 15));

        final tenant = ok(await h.tenants.getTenant(id))!;
        expect(tenant.name, 'Ramesh'); // trimmed
        expect(tenant.dueDay, 15);
        expect(tenant.startMonth, '2026-01');
        expect(ok(await h.history.getRentForMonth(id, '2026-01')), 5000);
        expect(await monthsOf(id), ['2026-01', '2026-02', '2026-03']);
        expect((await amountsOf(id)).values, everyElement(5000));
      },
    );

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

    test(
      'validation failures are ValidationFailure, not storage errors',
      () async {
        expect(isValidation(await add(name: '')), isTrue);
      },
    );
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
      ok(
        await h.history.changeRent(
          tenantUuid: id,
          effectiveFromMonth: '2026-04',
          amount: 6000,
        ),
      );
      ok(
        await h.history.changeRent(
          tenantUuid: id,
          effectiveFromMonth: '2026-06',
          amount: 4000,
        ),
      );
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
        recordPayment(
          RecordPaymentArgumentModel(
            rentRecordUuid: recordId,
            amount: amount,
            paidOn: on,
          ),
        );

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
      final r = await recordPayment(
        const RecordPaymentArgumentModel(
          rentRecordUuid: 'nope',
          amount: 100,
          paidOn: '2026-03-10',
        ),
      );
      expect((r as Err<String>).failure, isA<StorageFailure>());
    });

    test('a payment for an older month is allowed (paying old dues)', () async {
      final id = ok(await add(name: 'old', start: '2026-01'));
      final january = ok(await h.records.getRecords(id)).first;

      ok(
        await recordPayment(
          RecordPaymentArgumentModel(
            rentRecordUuid: january.uuid,
            amount: 5000,
            paidOn: '2026-03-15',
          ),
        ),
      );

      expect(
        ok(await h.payments.getPaymentsOfRecord(january.uuid)),
        hasLength(1),
      );
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

    test(
      'applies from next month only: past and current months keep 5000',
      () async {
        ok(await changeRent(id, 7000));

        expect(await amountsOf(id), {
          '2026-01': 5000,
          '2026-02': 5000,
          '2026-03': 5000,
        });
        expect(ok(await h.history.getRentForMonth(id, '2026-03')), 5000);
        expect(ok(await h.history.getRentForMonth(id, '2026-04')), 7000);
      },
    );

    test(
      'the first month is not changed either, while its record exists',
      () async {
        final first = ok(await add(name: 'x', start: '2026-03', rent: 5000));

        ok(await changeRent(first, 9000));

        expect((await amountsOf(first))['2026-03'], 5000);
      },
    );

    test(
      'next month then gets the new rent when its record is created',
      () async {
        ok(await changeRent(id, 7000));
        h.clock.setToday('2026-04-01');
        ok(await ensure());

        expect((await amountsOf(id))['2026-04'], 7000);
      },
    );

    test('if next month\'s record already exists it is updated', () async {
      // Put an April record in place before the change.
      ok(
        await h.records.insertMissing([
          RentRecordModel(
            uuid: 'apr',
            tenantUuid: id,
            month: '2026-04',
            requiredAmount: 5000,
          ),
        ]),
      );

      ok(await changeRent(id, 7000));

      expect((await amountsOf(id))['2026-04'], 7000);
      expect((await amountsOf(id))['2026-03'], 5000);
    });

    test('several changes in the same month: the last one wins', () async {
      ok(await changeRent(id, 7000));
      ok(await changeRent(id, 6500));

      expect(ok(await h.history.getRentForMonth(id, '2026-04')), 6500);
      final history = ok(await h.history.getHistory(id));
      expect(
        history.where((e) => e.effectiveFromMonth == '2026-04'),
        hasLength(1),
      );
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
    test(
      'archives the tenant with the current month and keeps everything',
      () async {
        final id = ok(await add(start: '2026-02'));
        final first = ok(await h.records.getRecords(id)).first;
        ok(
          await recordPayment(
            RecordPaymentArgumentModel(
              rentRecordUuid: first.uuid,
              amount: 1000,
              paidOn: '2026-02-05',
            ),
          ),
        );

        ok(await deleteTenant(id));

        final tenant = ok(await h.tenants.getTenant(id))!;
        expect(tenant.deletedMonth, '2026-03');
        expect(ok(await h.tenants.getActiveTenants()), isEmpty);
        expect(await monthsOf(id), ['2026-02', '2026-03']);
        expect(
          ok(await h.payments.getPaymentsOfRecord(first.uuid)),
          hasLength(1),
        );
        expect(ok(await h.history.getHistory(id)), hasLength(1));
      },
    );

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

  group('RenameTenantUsecase', () {
    test('changes only the name, trimmed', () async {
      final id = ok(await add(start: '2026-02'));
      final before = ok(await h.tenants.getTenant(id))!;

      ok(await RenameTenantUsecase(h.tenants)(id, '  Ravi Kumar '));

      final after = ok(await h.tenants.getTenant(id))!;
      expect(after.name, 'Ravi Kumar');
      expect(after.dueDay, before.dueDay);
      expect(after.startMonth, before.startMonth);
      expect(after.deletedMonth, isNull);
      expect(await monthsOf(id), ['2026-02', '2026-03']);
    });

    test('empty name is rejected and the old name stays', () async {
      final id = ok(await add());
      final rename = RenameTenantUsecase(h.tenants);

      expect(errorOf(await rename(id, '   ')), 'name_required');
      expect(ok(await h.tenants.getTenant(id))!.name, isNot(''));
    });

    test('unknown tenant', () async {
      expect(
        errorOf(await RenameTenantUsecase(h.tenants)('nope', 'Ravi')),
        'tenant_not_found',
      );
    });

    test('an archived tenant cannot be renamed', () async {
      final id = ok(await add());
      final oldName = ok(await h.tenants.getTenant(id))!.name;
      ok(await deleteTenant(id));

      expect(
        errorOf(await RenameTenantUsecase(h.tenants)(id, 'Ravi')),
        'tenant_deleted',
      );
      expect(ok(await h.tenants.getTenant(id))!.name, oldName);
    });
  });


  group('AddTenantUsecase groups', () {
    test('a new tenant goes to Uncategorized unless a group is chosen', () async {
      final id = ok(await add());

      expect(
        ok(await h.tenants.getTenant(id))!.groupUuid,
        uncategorizedGroupUuid,
      );
    });

    test('the chosen group is saved on the tenant', () async {
      final group = ok(await addGroup('Block A'));
      final id = ok(await add(group: group));

      expect(ok(await h.tenants.getTenant(id))!.groupUuid, group);
    });

    test('an unknown group is rejected and nothing is saved', () async {
      expect(errorOf(await add(group: 'nope')), 'group_not_found');
      expect(ok(await h.tenants.getActiveTenants()), isEmpty);
    });

    test('a deleted group is rejected', () async {
      final group = ok(await addGroup('Block A'));
      ok(await deleteGroup(group));

      expect(errorOf(await add(group: group)), 'group_deleted');
      expect(ok(await h.tenants.getActiveTenants()), isEmpty);
    });
  });

  group('AddGroupUsecase', () {
    test('saves the group with a trimmed name', () async {
      final id = ok(await addGroup('  Block A  '));

      final group = ok(await h.groups.getGroup(id))!;
      expect(group.name, 'Block A');
      expect(group.isDeleted, isFalse);
      expect(group.isUncategorized, isFalse);
      expect(ok(await h.groups.getActiveGroups()).map((g) => g.uuid), [
        uncategorizedGroupUuid,
        id,
      ]);
    });

    test('an empty name is rejected', () async {
      expect(errorOf(await addGroup('   ')), 'group_name_required');
    });

    test(
      'a name used by another active group is rejected, ignoring case',
      () async {
        ok(await addGroup('Block A'));

        expect(errorOf(await addGroup('  block a ')), 'group_name_taken');
        // Block A and the built-in Uncategorized; nothing was added.
        expect(ok(await h.groups.getActiveGroups()), hasLength(2));
      },
    );

    test('the name of a deleted group can be used again', () async {
      final first = ok(await addGroup('Block A'));
      ok(await deleteGroup(first));

      ok(await addGroup('Block A'));
    });
  });

  group('RenameGroupUsecase', () {
    test('changes only the name, trimmed; tenants stay', () async {
      final group = ok(await addGroup('Block A'));
      final tenant = ok(await add(group: group));

      ok(await renameGroup(group, '  Block B '));

      expect(ok(await h.groups.getGroup(group))!.name, 'Block B');
      expect(ok(await h.tenants.getTenant(tenant))!.groupUuid, group);
    });

    test(
      'empty, taken, unknown, deleted and Uncategorized are rejected',
      () async {
        final a = ok(await addGroup('Block A'));
        final b = ok(await addGroup('Block B'));

        expect(errorOf(await renameGroup(a, '  ')), 'group_name_required');
        expect(errorOf(await renameGroup(a, 'block b')), 'group_name_taken');
        expect(errorOf(await renameGroup('nope', 'X')), 'group_not_found');
        expect(
          errorOf(await renameGroup(uncategorizedGroupUuid, 'X')),
          'group_default_locked',
        );
        ok(await deleteGroup(b));
        expect(errorOf(await renameGroup(b, 'Y')), 'group_deleted');
        expect(ok(await h.groups.getGroup(a))!.name, 'Block A');
      },
    );

    test('keeping the same name, with other capitals, is allowed', () async {
      final a = ok(await addGroup('Block A'));

      ok(await renameGroup(a, 'BLOCK A'));
      expect(ok(await h.groups.getGroup(a))!.name, 'BLOCK A');
    });
  });

  group('DeleteGroupUsecase', () {
    test('an empty group is soft deleted with the current month', () async {
      final group = ok(await addGroup('Block A'));

      ok(await deleteGroup(group));

      final saved = ok(await h.groups.getGroup(group))!; // the row is kept
      expect(saved.deletedMonth, '2026-03');
      expect(saved.isDeleted, isTrue);
      expect(ok(await h.groups.getActiveGroups()).map((g) => g.uuid), [
        uncategorizedGroupUuid,
      ]);
    });

    test('a group with an active tenant cannot be deleted', () async {
      final group = ok(await addGroup('Block A'));
      ok(await add(group: group));

      expect(errorOf(await deleteGroup(group)), 'group_not_empty');
      expect(ok(await h.groups.getGroup(group))!.isDeleted, isFalse);
    });

    test('after the tenant is moved out, the group can be deleted', () async {
      final group = ok(await addGroup('Block A'));
      final tenant = ok(await add(group: group));
      ok(await moveTenant(tenant, uncategorizedGroupUuid));

      ok(await deleteGroup(group));
    });

    test('an archived tenant does not block it and keeps its group', () async {
      final group = ok(await addGroup('Block A'));
      final tenant = ok(await add(group: group));
      ok(await deleteTenant(tenant));

      ok(await deleteGroup(group));

      expect(ok(await h.tenants.getTenant(tenant))!.groupUuid, group);
    });

    test(
      'Uncategorized, unknown and already deleted groups are rejected',
      () async {
        expect(
          errorOf(await deleteGroup(uncategorizedGroupUuid)),
          'group_default_locked',
        );
        expect(errorOf(await deleteGroup('nope')), 'group_not_found');

        final group = ok(await addGroup('Block A'));
        ok(await deleteGroup(group));
        h.clock.setToday('2026-05-01');
        expect(errorOf(await deleteGroup(group)), 'group_deleted');
        expect(ok(await h.groups.getGroup(group))!.deletedMonth, '2026-03');
      },
    );
  });

  group('MoveTenantToGroupUsecase', () {
    test('changes only the group', () async {
      final group = ok(await addGroup('Block A'));
      final id = ok(await add(start: '2026-01', rent: 5000));
      final first = ok(await h.records.getRecords(id)).first;
      ok(
        await recordPayment(
          RecordPaymentArgumentModel(
            rentRecordUuid: first.uuid,
            amount: 1000,
            paidOn: '2026-01-05',
          ),
        ),
      );
      final before = ok(await h.tenants.getTenant(id))!;

      ok(await moveTenant(id, group));

      final after = ok(await h.tenants.getTenant(id))!;
      expect(after.groupUuid, group);
      expect(after.name, before.name);
      expect(after.dueDay, before.dueDay);
      expect(after.startMonth, before.startMonth);
      expect(await monthsOf(id), ['2026-01', '2026-02', '2026-03']);
      expect(ok(await h.history.getHistory(id)), hasLength(1));
      expect(
        ok(await h.payments.getPaymentsOfRecord(first.uuid)),
        hasLength(1),
      );
    });

    test('moving to the group it is already in succeeds', () async {
      final id = ok(await add());

      ok(await moveTenant(id, uncategorizedGroupUuid));
      expect(
        ok(await h.tenants.getTenant(id))!.groupUuid,
        uncategorizedGroupUuid,
      );
    });

    test(
      'unknown or deleted tenant, unknown or deleted group are rejected',
      () async {
        final group = ok(await addGroup('Block A'));
        final id = ok(await add());

        expect(errorOf(await moveTenant('nope', group)), 'tenant_not_found');
        expect(errorOf(await moveTenant(id, 'nope')), 'group_not_found');

        ok(await deleteGroup(group));
        expect(errorOf(await moveTenant(id, group)), 'group_deleted');

        final other = ok(await addGroup('Block B'));
        ok(await deleteTenant(id));
        expect(errorOf(await moveTenant(id, other)), 'tenant_deleted');
        expect(
          ok(await h.tenants.getTenant(id))!.groupUuid,
          uncategorizedGroupUuid,
        );
      },
    );
  });

  group('EditPaymentUsecase', () {
    late EditPaymentUsecase editPayment;
    late String recordUuid;
    late String paymentUuid;

    // Ramesh rents from January, 5000 a month, due on the 10th. Today is
    // 2026-03-15. He paid January in full on the 5th.
    setUp(() async {
      editPayment = EditPaymentUsecase(h.payments, h.clock);
      final id = ok(await add(start: '2026-01', rent: 5000, dueDay: 10));
      recordUuid = ok(await h.records.getRecords(id)).first.uuid;
      paymentUuid = ok(
        await recordPayment(
          RecordPaymentArgumentModel(
            rentRecordUuid: recordUuid,
            amount: 5000,
            paidOn: '2026-01-05',
          ),
        ),
      );
    });

    test('changes the amount and the date, nothing else', () async {
      final before = ok(await h.payments.getPayment(paymentUuid))!;

      ok(await editPayment(paymentUuid, amount: 4000, paidOn: '2026-01-08'));

      final after = ok(await h.payments.getPayment(paymentUuid))!;
      expect(after.amount, 4000);
      expect(after.paidOn, '2026-01-08');
      expect(after.rentRecordUuid, before.rentRecordUuid);
      expect(after.createdOn, before.createdOn);
      expect(ok(await h.payments.getPaymentsOfRecord(recordUuid)), hasLength(1));
    });

    test('the month status follows the edit', () async {
      Future<MonthStatus> statusNow() async => computeMonthStatus(
        month: '2026-01',
        requiredAmount: 5000,
        dueDay: 10,
        payments: ok(await h.payments.getPaymentsOfRecord(recordUuid)),
        today: '2026-03-15',
      );
      // Fully paid on the 5th, before the due day: Completed.
      expect(await statusNow(), MonthStatus.completed);

      // Moved past the due day, still within the month: Late Completed.
      ok(await editPayment(paymentUuid, amount: 5000, paidOn: '2026-01-20'));
      expect(await statusNow(), MonthStatus.lateCompleted);

      // Moved past the month end: Backlog Cleared.
      ok(await editPayment(paymentUuid, amount: 5000, paidOn: '2026-02-03'));
      expect(await statusNow(), MonthStatus.backlogCleared);

      // Lowered: the month is no longer paid. Month ended: Backlog.
      ok(await editPayment(paymentUuid, amount: 3000, paidOn: '2026-01-05'));
      expect(await statusNow(), MonthStatus.backlog);
    });

    test('a zero or negative amount is rejected and nothing changes', () async {
      expect(
        errorOf(await editPayment(paymentUuid, amount: 0, paidOn: '2026-01-05')),
        'amount_invalid',
      );
      expect(
        errorOf(await editPayment(paymentUuid, amount: -5, paidOn: '2026-01-05')),
        'amount_invalid',
      );
      expect(ok(await h.payments.getPayment(paymentUuid))!.amount, 5000);
    });

    test('an invalid date is rejected', () async {
      expect(
        errorOf(await editPayment(paymentUuid, amount: 1000, paidOn: '2026-02-30')),
        'date_invalid',
      );
      expect(
        errorOf(await editPayment(paymentUuid, amount: 1000, paidOn: 'soon')),
        'date_invalid',
      );
      expect(ok(await h.payments.getPayment(paymentUuid))!.paidOn, '2026-01-05');
    });

    test('a date after today is rejected, today itself is allowed', () async {
      expect(
        errorOf(await editPayment(paymentUuid, amount: 1000, paidOn: '2026-03-16')),
        'date_in_future',
      );
      ok(await editPayment(paymentUuid, amount: 1000, paidOn: '2026-03-15'));
      expect(ok(await h.payments.getPayment(paymentUuid))!.paidOn, '2026-03-15');
    });

    test('an unknown payment is rejected', () async {
      expect(
        errorOf(await editPayment('nope', amount: 1000, paidOn: '2026-01-05')),
        'payment_not_found',
      );
    });

    test('an undone payment can no longer be edited', () async {
      ok(await undoPayment(paymentUuid));

      expect(
        errorOf(await editPayment(paymentUuid, amount: 1000, paidOn: '2026-01-05')),
        'payment_not_found',
      );
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
      expect(
        errorOf(await SetLanguageUsecase(settings)('fr')),
        'language_unsupported',
      );
      expect(ok(await LoadSettingsUsecase(settings)()).languageCode, 'en');
    });

    test('a simulated date changes the clock and can be cleared', () async {
      final clock = SimulatedClock(h.clock);
      final setDate = SetSimulatedDateUsecase(settings, clock);
      expect(clock.today(), '2026-03-15');

      ok(await setDate('2026-04-12'));
      expect(clock.today(), '2026-04-12');
      expect(clock.currentMonth(), '2026-04');
      expect(settings.simulatedDate, '2026-04-12');

      ok(await setDate(null));
      expect(clock.today(), '2026-03-15');
      expect(settings.simulatedDate, isNull);
    });

    test('an invalid simulated date is rejected and not applied', () async {
      final clock = SimulatedClock(h.clock);
      final setDate = SetSimulatedDateUsecase(settings, clock);

      expect(errorOf(await setDate('2026-02-30')), 'date_invalid');
      expect(clock.simulatedDate, isNull);
      expect(settings.simulatedDate, isNull);
    });
  });
}
