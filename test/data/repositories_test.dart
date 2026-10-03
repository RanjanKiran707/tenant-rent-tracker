import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/data/payment/payment_repository.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_repository.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository.dart';
import 'package:tenant_tracker/data/settings/settings_repository.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_model.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository.dart';

T ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => throw TestFailure('Expected Ok, got $failure'),
};

TenantModel tenant(String uuid, {String start = '2026-01', DateTime? at}) =>
    TenantModel(
      uuid: uuid,
      name: 'Tenant $uuid',
      createdOn: at ?? DateTime.utc(2026, 1, 1),
      dueDay: 10,
      startMonth: start,
    );

void main() {
  late AppDatabase db;
  late TenantGroupRepository groups;
  late TenantRepository tenants;
  late RentHistoryRepository history;
  late RentRecordRepository records;
  late PaymentRepository payments;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    groups = TenantGroupRepository(db);
    tenants = TenantRepository(db);
    history = RentHistoryRepository(db);
    records = RentRecordRepository(db);
    payments = PaymentRepository(db);
  });

  tearDown(() => db.close());

  group('TenantRepository', () {
    test('addTenant saves the tenant and its first rent', () async {
      ok(await tenants.addTenant(tenant('t1', start: '2026-03'), 5000));

      expect(ok(await tenants.getTenant('t1'))?.name, 'Tenant t1');
      final h = ok(await history.getHistory('t1'));
      expect(h, hasLength(1));
      expect(h.single.effectiveFromMonth, '2026-03');
      expect(h.single.amount, 5000);
    });

    test('addTenant with a bad rent saves nothing (transaction)', () async {
      final result = await tenants.addTenant(tenant('t1'), 0);

      expect(result, isA<Err<void>>());
      expect(ok(await tenants.getTenant('t1')), isNull);
    });

    test(
      'duplicate uuid becomes Err(StorageFailure), not an exception',
      () async {
        ok(await tenants.addTenant(tenant('t1'), 5000));
        final result = await tenants.addTenant(tenant('t1'), 5000);

        expect((result as Err).failure, isA<StorageFailure>());
      },
    );

    test('deleteTenant moves a tenant from active to archived', () async {
      ok(await tenants.addTenant(tenant('t1'), 5000));
      ok(await tenants.addTenant(tenant('t2'), 6000));
      ok(await tenants.deleteTenant('t1', '2026-05'));

      final active = ok(await tenants.watchActiveTenants().first);
      final archived = ok(await tenants.watchArchivedTenants().first);
      expect(active.map((t) => t.uuid), ['t2']);
      expect(archived.map((t) => t.uuid), ['t1']);
      expect(archived.single.deletedMonth, '2026-05');
    });

    test('active tenants are listed oldest first', () async {
      ok(
        await tenants.addTenant(
          tenant('b', at: DateTime.utc(2026, 2, 1)),
          1000,
        ),
      );
      ok(
        await tenants.addTenant(
          tenant('a', at: DateTime.utc(2026, 1, 1)),
          1000,
        ),
      );

      final active = ok(await tenants.watchActiveTenants().first);
      expect(active.map((t) => t.uuid), ['a', 'b']);
    });

    test('getActiveTenants skips archived tenants, oldest first', () async {
      ok(
        await tenants.addTenant(
          tenant('b', at: DateTime.utc(2026, 2, 1)),
          1000,
        ),
      );
      ok(
        await tenants.addTenant(
          tenant('a', at: DateTime.utc(2026, 1, 1)),
          1000,
        ),
      );
      ok(
        await tenants.addTenant(
          tenant('c', at: DateTime.utc(2026, 3, 1)),
          1000,
        ),
      );
      ok(await tenants.deleteTenant('c', '2026-04'));

      final active = ok(await tenants.getActiveTenants());
      expect(active.map((t) => t.uuid), ['a', 'b']);
    });

    test('the stream re-emits when a tenant is added', () async {
      final emissions = <int>[];
      final sub = tenants.watchActiveTenants().listen(
        (r) => emissions.add(ok(r).length),
      );
      await pumpEventQueue();

      ok(await tenants.addTenant(tenant('t1'), 5000));
      await pumpEventQueue();

      expect(emissions, [0, 1]);
      await sub.cancel();
    });
  });

  group('RentHistoryRepository', () {
    setUp(() async {
      ok(await tenants.addTenant(tenant('t1'), 5000));
    });

    // Tenant t1 starts 2026-01 at 5000.
    Future<Result<void>> change(String month, int amount) => history.changeRent(
      tenantUuid: 't1',
      effectiveFromMonth: month,
      amount: amount,
    );

    Future<void> addRecord(String id, String month, int amount) async {
      ok(
        await records.insertMissing([
          RentRecordModel(
            uuid: id,
            tenantUuid: 't1',
            month: month,
            requiredAmount: amount,
          ),
        ]),
      );
    }

    test('rent for a month uses the latest change at or before it', () async {
      ok(await change('2026-04', 6000));

      expect(ok(await history.getRentForMonth('t1', '2026-01')), 5000);
      expect(ok(await history.getRentForMonth('t1', '2026-03')), 5000);
      expect(ok(await history.getRentForMonth('t1', '2026-04')), 6000);
      expect(ok(await history.getRentForMonth('t1', '2027-01')), 6000);
    });

    test(
      'watchHistory re-emits after a rent change, even with no record',
      () async {
        final emissions = <List<int>>[];
        final sub = history
            .watchHistory('t1')
            .listen((r) => emissions.add(ok(r).map((h) => h.amount).toList()));
        await pumpEventQueue();

        ok(await change('2026-04', 6000));
        await pumpEventQueue();

        expect(emissions, [
          [5000],
          [5000, 6000],
        ]);
        await sub.cancel();
      },
    );

    test('rent before the first change is null', () async {
      expect(ok(await history.getRentForMonth('t1', '2025-12')), isNull);
    });

    test('a second change in the same month replaces the first', () async {
      ok(await change('2026-04', 6000));
      ok(await change('2026-04', 7000));

      final h = ok(await history.getHistory('t1'));
      expect(h.map((e) => e.effectiveFromMonth), ['2026-01', '2026-04']);
      expect(ok(await history.getRentForMonth('t1', '2026-04')), 7000);
    });

    test(
      'a month with an existing record updates history and record',
      () async {
        await addRecord('r1', '2026-03', 5000);
        await addRecord('r2', '2026-04', 5000);

        ok(await change('2026-04', 6000));

        expect(ok(await history.getRentForMonth('t1', '2026-04')), 6000);
        final amounts = ok(
          await records.getRecords('t1'),
        ).map((r) => r.requiredAmount).toList();
        expect(amounts, [5000, 6000]); // March snapshot untouched
      },
    );

    test('a month with no record yet changes history only', () async {
      await addRecord('r1', '2026-03', 5000);

      ok(await change('2026-04', 6000));

      expect(ok(await history.getRentForMonth('t1', '2026-04')), 6000);
      expect(ok(await records.getRecords('t1')), hasLength(1));
    });

    test(
      'a bad amount saves nothing, history and record stay in step',
      () async {
        await addRecord('r2', '2026-04', 5000);

        final result = await change('2026-04', 0);

        expect(result, isA<Err<void>>());
        expect(ok(await history.getHistory('t1')), hasLength(1));
        expect(ok(await records.getRecords('t1')).single.requiredAmount, 5000);
      },
    );

    test('an unknown tenant is rejected (foreign key)', () async {
      final result = await history.changeRent(
        tenantUuid: 'nobody',
        effectiveFromMonth: '2026-04',
        amount: 6000,
      );

      expect(result, isA<Err<void>>());
    });
  });

  group('RentRecordRepository', () {
    setUp(() async {
      ok(await tenants.addTenant(tenant('t1'), 5000));
      ok(await tenants.addTenant(tenant('t2'), 8000));
    });

    RentRecordModel rec(String id, String tenantUuid, String month, int amt) =>
        RentRecordModel(
          uuid: id,
          tenantUuid: tenantUuid,
          month: month,
          requiredAmount: amt,
        );

    test('insertMissing keeps existing records untouched', () async {
      ok(await records.insertMissing([rec('r1', 't1', '2026-01', 5000)]));
      ok(
        await records.insertMissing([
          rec('r1b', 't1', '2026-01', 9999), // already exists: ignored
          rec('r2', 't1', '2026-02', 5000),
        ]),
      );

      final list = ok(await records.getRecords('t1'));
      expect(list.map((r) => r.uuid), ['r1', 'r2']);
      expect(list.first.requiredAmount, 5000);
    });

    test('getRecords returns one tenant, oldest month first', () async {
      ok(
        await records.insertMissing([
          rec('r2', 't1', '2026-02', 5000),
          rec('r1', 't1', '2026-01', 5000),
          rec('x', 't2', '2026-01', 8000),
        ]),
      );

      final list = ok(await records.getRecords('t1'));
      expect(list.map((r) => r.month), ['2026-01', '2026-02']);
      expect(ok(await records.watchAllRecords().first), hasLength(3));
    });

    test('updateRequiredAmount changes one month only', () async {
      ok(
        await records.insertMissing([
          rec('r1', 't1', '2026-01', 5000),
          rec('r2', 't1', '2026-02', 5000),
        ]),
      );
      ok(await records.updateRequiredAmount('t1', '2026-02', 6000));
      ok(await records.updateRequiredAmount('t1', '2030-01', 1)); // no row

      final list = ok(await records.getRecords('t1'));
      expect(list.map((r) => r.requiredAmount), [5000, 6000]);
    });

    test('a record for an unknown tenant is rejected (foreign key)', () async {
      final result = await records.insertMissing([
        rec('r1', 'nobody', '2026-01', 5000),
      ]);

      expect(result, isA<Err<void>>());
    });
  });

  group('PaymentRepository', () {
    PaymentModel pay(String id, String recordUuid, int amt, String paidOn) =>
        PaymentModel(
          uuid: id,
          rentRecordUuid: recordUuid,
          amount: amt,
          paidOn: paidOn,
          createdOn: DateTime.utc(2026, 1, 1),
        );

    setUp(() async {
      ok(await tenants.addTenant(tenant('t1'), 5000));
      ok(await tenants.addTenant(tenant('t2'), 8000));
      ok(
        await records.insertMissing([
          RentRecordModel(
            uuid: 'r1',
            tenantUuid: 't1',
            month: '2026-01',
            requiredAmount: 5000,
          ),
          RentRecordModel(
            uuid: 'r2',
            tenantUuid: 't1',
            month: '2026-02',
            requiredAmount: 5000,
          ),
          RentRecordModel(
            uuid: 'x1',
            tenantUuid: 't2',
            month: '2026-01',
            requiredAmount: 8000,
          ),
        ]),
      );
    });

    test('getPayment reads one payment, or null when unknown', () async {
      ok(await payments.addPayment(pay('p1', 'r1', 3000, '2026-01-05')));

      final saved = ok(await payments.getPayment('p1'))!;
      expect(saved.amount, 3000);
      expect(saved.paidOn, '2026-01-05');
      expect(ok(await payments.getPayment('nope')), isNull);
    });

    test('updatePayment changes only the amount and the date', () async {
      ok(await payments.addPayment(pay('p1', 'r1', 3000, '2026-01-05')));
      ok(await payments.addPayment(pay('p2', 'r1', 1000, '2026-01-06')));

      ok(await payments.updatePayment('p1', amount: 3500, paidOn: '2026-01-09'));

      final p1 = ok(await payments.getPayment('p1'))!;
      expect(p1.amount, 3500);
      expect(p1.paidOn, '2026-01-09');
      expect(p1.rentRecordUuid, 'r1');
      // drift hands back local time; compare the instant, not the zone.
      expect(p1.createdOn.isAtSameMomentAs(DateTime.utc(2026, 1, 1)), isTrue);
      // The other payment is untouched.
      expect(ok(await payments.getPayment('p2'))!.amount, 1000);
    });

    test('updatePayment re-sorts the month by the new date', () async {
      ok(await payments.addPayment(pay('p1', 'r1', 3000, '2026-01-05')));
      ok(await payments.addPayment(pay('p2', 'r1', 2000, '2026-01-20')));

      ok(await payments.updatePayment('p1', amount: 3000, paidOn: '2026-01-25'));

      expect(
        ok(await payments.getPaymentsOfRecord('r1')).map((p) => p.uuid),
        ['p2', 'p1'],
      );
    });

    test('updatePayment refuses an amount of zero (check constraint)', () async {
      ok(await payments.addPayment(pay('p1', 'r1', 3000, '2026-01-05')));

      final result = await payments.updatePayment(
        'p1',
        amount: 0,
        paidOn: '2026-01-05',
      );

      expect(result, isA<Err<void>>());
      expect(ok(await payments.getPayment('p1'))!.amount, 3000);
    });

    test('the payment list follows an update', () async {
      ok(await payments.addPayment(pay('p1', 'r1', 3000, '2026-01-05')));
      final seen = <int>[];
      final sub = payments.watchPaymentsOfTenant('t1').listen(
        (r) => seen.add(ok(r).fold(0, (sum, p) => sum + p.amount)),
      );
      await pumpEventQueue();

      ok(await payments.updatePayment('p1', amount: 4000, paidOn: '2026-01-05'));
      await pumpEventQueue();

      expect(seen, [3000, 4000]);
      await sub.cancel();
    });

    test('payments of a record come back in paidOn order', () async {
      ok(await payments.addPayment(pay('p2', 'r1', 2000, '2026-01-20')));
      ok(await payments.addPayment(pay('p1', 'r1', 3000, '2026-01-05')));

      final list = ok(await payments.getPaymentsOfRecord('r1'));
      expect(list.map((p) => p.uuid), ['p1', 'p2']);
    });

    test(
      'watchPaymentsOfTenant covers all months of that tenant only',
      () async {
        ok(await payments.addPayment(pay('p1', 'r1', 3000, '2026-01-05')));
        ok(await payments.addPayment(pay('p2', 'r2', 5000, '2026-02-08')));
        ok(await payments.addPayment(pay('p3', 'x1', 8000, '2026-01-09')));

        final mine = ok(await payments.watchPaymentsOfTenant('t1').first);
        expect(mine.map((p) => p.uuid), ['p1', 'p2']);
        expect(ok(await payments.watchAllPayments().first), hasLength(3));
      },
    );

    test('deletePayment removes it (Undo)', () async {
      ok(await payments.addPayment(pay('p1', 'r1', 3000, '2026-01-05')));
      ok(await payments.deletePayment('p1'));

      expect(ok(await payments.getPaymentsOfRecord('r1')), isEmpty);
    });

    test('a payment of 0 or for an unknown record is rejected', () async {
      expect(
        await payments.addPayment(pay('p1', 'r1', 0, '2026-01-05')),
        isA<Err<void>>(),
      );
      expect(
        await payments.addPayment(pay('p2', 'nope', 100, '2026-01-05')),
        isA<Err<void>>(),
      );
    });
  });

  group('TenantGroupRepository', () {
    TenantGroupModel group(String uuid, {String? name, DateTime? at}) =>
        TenantGroupModel(
          uuid: uuid,
          name: name ?? 'Group $uuid',
          createdOn: at ?? DateTime.utc(2026, 1, 2),
        );

    test('a new database already has the Uncategorized group', () async {
      final saved = ok(await groups.getGroup(uncategorizedGroupUuid))!;

      expect(saved.name, 'Uncategorized');
      expect(saved.isUncategorized, isTrue);
      expect(saved.isDeleted, isFalse);
    });

    test('addGroup saves it and getGroup reads it back', () async {
      ok(await groups.addGroup(group('g1', name: 'Block A')));

      final saved = ok(await groups.getGroup('g1'))!;
      expect(saved.name, 'Block A');
      expect(saved.deletedMonth, isNull);
      expect(saved.isUncategorized, isFalse);
    });

    test('getGroup returns null for an unknown uuid', () async {
      expect(ok(await groups.getGroup('nope')), isNull);
    });

    test('active groups are oldest first, deleted ones are left out', () async {
      ok(await groups.addGroup(group('g2', at: DateTime.utc(2026, 3, 1))));
      ok(await groups.addGroup(group('g1', at: DateTime.utc(2026, 2, 1))));
      ok(await groups.addGroup(group('g3', at: DateTime.utc(2026, 4, 1))));
      ok(await groups.deleteGroup('g3', '2026-05'));

      expect(ok(await groups.getActiveGroups()).map((g) => g.uuid), [
        uncategorizedGroupUuid,
        'g1',
        'g2',
      ]);
      expect(ok(await groups.watchActiveGroups().first).map((g) => g.uuid), [
        uncategorizedGroupUuid,
        'g1',
        'g2',
      ]);
    });

    test('watchAllGroups includes deleted groups', () async {
      ok(await groups.addGroup(group('g1')));
      ok(await groups.deleteGroup('g1', '2026-05'));

      final all = ok(await groups.watchAllGroups().first);
      expect(all.map((g) => g.uuid), [uncategorizedGroupUuid, 'g1']);
      expect(all.last.isDeleted, isTrue);
    });

    test('renameGroup changes only the name', () async {
      ok(await groups.addGroup(group('g1', name: 'Block A')));

      ok(await groups.renameGroup('g1', 'Block B'));

      final saved = ok(await groups.getGroup('g1'))!;
      expect(saved.name, 'Block B');
      expect(saved.deletedMonth, isNull);
    });

    test('deleteGroup keeps the row and sets the month', () async {
      ok(await groups.addGroup(group('g1')));

      ok(await groups.deleteGroup('g1', '2026-05'));

      final saved = ok(await groups.getGroup('g1'))!;
      expect(saved.deletedMonth, '2026-05');
      expect(saved.isDeleted, isTrue);
    });

    test('the group list follows changes', () async {
      final seen = <int>[];
      final sub = groups.watchActiveGroups().listen(
        (r) => seen.add(ok(r).length),
      );
      await pumpEventQueue();

      ok(await groups.addGroup(group('g1')));
      await pumpEventQueue();

      expect(seen, [1, 2]);
      await sub.cancel();
    });
  });

  group('Tenant groups on the tenant', () {
    test('a tenant is in Uncategorized unless saved with a group', () async {
      ok(await tenants.addTenant(tenant('t1'), 5000));

      expect(
        ok(await tenants.getTenant('t1'))!.groupUuid,
        uncategorizedGroupUuid,
      );
    });

    test('a tenant is saved with its group', () async {
      ok(
        await groups.addGroup(
          TenantGroupModel(
            uuid: 'g1',
            name: 'Block A',
            createdOn: DateTime.utc(2026, 1, 2),
          ),
        ),
      );

      ok(
        await tenants.addTenant(
          TenantModel(
            uuid: 't1',
            groupUuid: 'g1',
            name: 'Ravi',
            createdOn: DateTime.utc(2026, 1, 1),
            dueDay: 10,
            startMonth: '2026-01',
          ),
          5000,
        ),
      );

      expect(ok(await tenants.getTenant('t1'))!.groupUuid, 'g1');
    });

    test('a tenant in a group that does not exist is rejected', () async {
      final result = await tenants.addTenant(
        TenantModel(
          uuid: 't1',
          groupUuid: 'nope',
          name: 'Ravi',
          createdOn: DateTime.utc(2026, 1, 1),
          dueDay: 10,
          startMonth: '2026-01',
        ),
        5000,
      );

      expect(result, isA<Err<void>>()); // foreign key
      expect(ok(await tenants.getTenant('t1')), isNull);
    });

    test('setTenantGroup moves the tenant and nothing else', () async {
      ok(
        await groups.addGroup(
          TenantGroupModel(
            uuid: 'g1',
            name: 'Block A',
            createdOn: DateTime.utc(2026, 1, 2),
          ),
        ),
      );
      ok(await tenants.addTenant(tenant('t1', start: '2026-03'), 5000));
      final before = ok(await tenants.getTenant('t1'))!;

      ok(await tenants.setTenantGroup('t1', 'g1'));

      final after = ok(await tenants.getTenant('t1'))!;
      expect(after.groupUuid, 'g1');
      expect(after.name, before.name);
      expect(after.dueDay, before.dueDay);
      expect(after.startMonth, before.startMonth);
      expect(after.deletedMonth, before.deletedMonth);
      expect(ok(await history.getHistory('t1')), hasLength(1));
    });

    test('setTenantGroup to a group that does not exist is rejected', () async {
      ok(await tenants.addTenant(tenant('t1'), 5000));

      final result = await tenants.setTenantGroup('t1', 'nope');

      expect(result, isA<Err<void>>());
      expect(
        ok(await tenants.getTenant('t1'))!.groupUuid,
        uncategorizedGroupUuid,
      );
    });

    test('watchTenant emits again after a move and a delete', () async {
      ok(
        await groups.addGroup(
          TenantGroupModel(
            uuid: 'g1',
            name: 'Block A',
            createdOn: DateTime.utc(2026, 1, 2),
          ),
        ),
      );
      ok(await tenants.addTenant(tenant('t1'), 5000));
      final seen = <String>[];
      final sub = tenants.watchTenant('t1').listen((r) {
        final t = ok(r)!;
        seen.add('${t.groupUuid}:${t.deletedMonth}');
      });
      await pumpEventQueue();

      ok(await tenants.setTenantGroup('t1', 'g1'));
      await pumpEventQueue();
      ok(await tenants.deleteTenant('t1', '2026-05'));
      await pumpEventQueue();

      expect(seen, [
        '$uncategorizedGroupUuid:null',
        'g1:null',
        'g1:2026-05',
      ]);
      await sub.cancel();
    });
  });

  group('SettingsRepository', () {
    test('defaults when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SettingsRepository(await SharedPreferences.getInstance());

      final s = ok(await repo.load());
      expect(s.languageCode, 'en');
      expect(s.showTips, isTrue);
      expect(s.seenWelcome, isFalse);
    });

    test('saved values are read back', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SettingsRepository(await SharedPreferences.getInstance());

      ok(await repo.setLanguage('kn'));
      ok(await repo.setShowTips(false));
      ok(await repo.setSeenWelcome(true));

      final s = ok(await repo.load());
      expect(s.languageCode, 'kn');
      expect(s.showTips, isFalse);
      expect(s.seenWelcome, isTrue);
    });
  });
}
