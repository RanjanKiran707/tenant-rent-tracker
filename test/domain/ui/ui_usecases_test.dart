import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_add_tenant_form/load_add_tenant_form_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_payment_options/load_payment_options_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_rent_change_info/load_rent_change_info_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_archived_tenants/watch_archived_tenants_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_group/watch_group_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_groups/watch_groups_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_tenant_detail/watch_tenant_detail_usecase.dart';

import '../harness.dart';

void main() {
  late Harness h;
  late WatchHomeUsecase watchHome;
  late WatchGroupUsecase watchGroup;
  late WatchGroupsUsecase watchGroups;
  late WatchTenantDetailUsecase watchDetail;
  late WatchArchivedTenantsUsecase watchArchived;
  late LoadPaymentOptionsUsecase paymentOptions;
  late LoadRentChangeInfoUsecase rentChangeInfo;

  // The mockup's "today".
  setUp(() async {
    h = Harness(today: '2026-10-12');
    watchHome = WatchHomeUsecase(
      h.groups,
      h.tenants,
      h.records,
      h.payments,
      h.clock,
    );
    watchGroup = WatchGroupUsecase(
      h.groups,
      h.tenants,
      h.records,
      h.payments,
      h.clock,
    );
    watchGroups = WatchGroupsUsecase(h.groups);
    watchDetail = WatchTenantDetailUsecase(
      h.tenants,
      h.groups,
      h.records,
      h.payments,
      h.history,
      h.clock,
    );
    watchArchived = WatchArchivedTenantsUsecase(h.tenants, h.records);
    paymentOptions = LoadPaymentOptionsUsecase(
      h.tenants,
      h.records,
      h.payments,
      h.clock,
    );
    rentChangeInfo = LoadRentChangeInfoUsecase(h.tenants, h.history, h.clock);
  });

  tearDown(() => h.close());

  /// The tenant rows (most urgent first) of the Uncategorized group, where
  /// [seedTenant] puts tenants unless told otherwise.
  Future<List<HomeTenantRow>> uncategorizedRows() async =>
      ok(await watchGroup(uncategorizedGroupUuid).first).rows;

  /// The mockup's tenants (the ones needed here).
  Future<void> seedMockup() async {
    await seedTenant(
      h,
      id: 'ramesh',
      name: 'Ramesh Kumar',
      start: '2026-08',
      rent: 8000,
      dueDay: 15,
    );
    await payTo(h, 'ramesh', '2026-08', 8000, '2026-08-10');
    await payTo(h, 'ramesh', '2026-09', 8000, '2026-09-14');

    await seedTenant(
      h,
      id: 'manju',
      name: 'Manjunath S',
      start: '2026-08',
      rent: 5500,
      dueDay: 5,
    );
    await payTo(h, 'manju', '2026-08', 3000, '2026-08-04');
    await payTo(h, 'manju', '2026-08', 2500, '2026-09-12');
    await payTo(h, 'manju', '2026-09', 5500, '2026-09-05');
    await payTo(h, 'manju', '2026-10', 2000, '2026-10-02');

    await seedTenant(
      h,
      id: 'farida',
      name: 'Farida Begum',
      start: '2026-08',
      rent: 9000,
      dueDay: 5,
    );
    await payTo(h, 'farida', '2026-08', 9000, '2026-08-03');
    await payTo(h, 'farida', '2026-09', 4000, '2026-09-06');

    await seedTenant(
      h,
      id: 'anita',
      name: 'Anita Rao',
      start: '2026-09',
      rent: 7000,
      dueDay: 20,
    );
    await payTo(h, 'anita', '2026-09', 7000, '2026-09-18');
    await payTo(h, 'anita', '2026-10', 3000, '2026-10-06');
  }

  group('WatchHomeUsecase', () {
    test('no tenants: zero totals and an empty list', () async {
      final home = ok(await watchHome().first);

      expect(home.currentMonth, '2026-10');
      expect(home.groups, isEmpty);
      expect(home.received, 0);
      expect(home.toReceive, 0);
    });

    test(
      'needs-attention first, old dues move a tenant up, then by name',
      () async {
        await seedMockup();
        final rows = await uncategorizedRows();

        expect(rows.map((r) => r.name), [
          'Farida Begum', // overdue, plus old dues
          'Manjunath S', // partial overdue
          'Anita Rao', // partial
          'Ramesh Kumar', // pending
        ]);
        expect(rows.map((r) => r.status), [
          MonthStatus.overdue,
          MonthStatus.partialOverdue,
          MonthStatus.partial,
          MonthStatus.pending,
        ]);
      },
    );

    test(
      'old dues: Farida owes 5000 for September, Manjunath cleared August',
      () async {
        await seedMockup();
        final rows = await uncategorizedRows();
        final dues = {for (final r in rows) r.name: r.oldDues};

        expect(dues['Farida Begum'], 5000);
        expect(dues['Manjunath S'], 0);
        expect(dues['Anita Rao'], 0);
        expect(dues['Ramesh Kumar'], 0);
      },
    );

    test('totals are for the current month only', () async {
      await seedMockup();
      final home = ok(await watchHome().first);

      // October received: 0 + 2000 + 0 + 3000. Still to receive:
      // 8000 + 3500 + 9000 + 4000. September's 5000 is old dues, not here.
      expect(home.received, 5000);
      expect(home.toReceive, 24500);
    });

    test('a tie on rank is broken by name, ignoring case', () async {
      await seedTenant(h, id: 'b', name: 'bala', start: '2026-10', rent: 1000);
      await seedTenant(h, id: 'a', name: 'Arun', start: '2026-10', rent: 1000);

      final rows = await uncategorizedRows();
      expect(rows.map((r) => r.name), ['Arun', 'bala']);
    });

    test('re-emits after a payment', () async {
      await seedMockup();
      final received = <int>[];
      final sub = watchHome().listen((r) => received.add(ok(r).received));
      await pumpEventQueue();

      await payTo(h, 'ramesh', '2026-10', 8000, '2026-10-12');
      await pumpEventQueue();

      expect(received, [5000, 13000]);
      await sub.cancel();
    });

    test('a deleted tenant leaves the list', () async {
      await seedMockup();
      ok(await h.tenants.deleteTenant('farida', '2026-10'));

      final home = ok(await watchHome().first);
      final rows = await uncategorizedRows();
      expect(rows.map((r) => r.name), isNot(contains('Farida Begum')));
      expect(rows, hasLength(3));
      expect(home.toReceive, 15500); // Farida's 9000 is gone from the total
    });

    test(
      'a status follows the date: due day passes while paid in part',
      () async {
        await seedTenant(h, id: 't', start: '2026-10', rent: 5000, dueDay: 20);
        await payTo(h, 't', '2026-10', 1000, '2026-10-05');
        expect(
          (await uncategorizedRows()).single.status,
          MonthStatus.partial,
        );

        h.clock.setToday('2026-10-21');
        expect(
          (await uncategorizedRows()).single.status,
          MonthStatus.partialOverdue,
        );
      },
    );

    test(
      'a tenant with no record for this month is Pending, not in totals',
      () async {
        await seedTenant(h, id: 't', start: '2026-09', rent: 5000);
        h.clock.setToday('2026-11-02'); // November's record is not created yet

        final home = ok(await watchHome().first);
        final row = (await uncategorizedRows()).single;
        expect(row.status, MonthStatus.pending);
        expect(home.toReceive, 0);
        // September and October are both unpaid and now in the past.
        expect(row.oldDues, 10000);
      },
    );
  });


  group('WatchHomeUsecase groups', () {
    /// The mockup tenants, with Farida and Ramesh moved into "Block A".
    Future<void> seedBlockA() async {
      await seedMockup();
      await seedGroup(h, id: 'a', name: 'Block A');
      ok(await h.tenants.setTenantGroup('farida', 'a'));
      ok(await h.tenants.setTenantGroup('ramesh', 'a'));
    }

    test('Uncategorized is hidden while empty; other groups are listed', () async {
      await seedGroup(h, id: 'a', name: 'Block A');

      final home = ok(await watchHome().first);
      expect(home.groups.map((g) => g.name), ['Block A']);
      expect(home.groups.single.tenantCount, 0);
      expect(home.groups.single.worstStatus, isNull);
    });

    test('Uncategorized is listed once it has a tenant', () async {
      await seedTenant(h, id: 't', start: '2026-10', rent: 1000);

      final home = ok(await watchHome().first);
      expect(home.groups.single.groupUuid, uncategorizedGroupUuid);
      expect(home.groups.single.isUncategorized, isTrue);
      expect(home.groups.single.tenantCount, 1);
    });

    test('a card rolls up the tenants of its group', () async {
      await seedBlockA();

      final home = ok(await watchHome().first);
      final blockA = home.groups.firstWhere((g) => g.groupUuid == 'a');
      expect(blockA.tenantCount, 2);
      expect(blockA.worstStatus, MonthStatus.overdue); // Farida
      expect(blockA.worstHasOldDues, isTrue);
      expect(blockA.oldDues, 5000); // Farida's September
      expect(blockA.toReceive, 17000); // 9000 + 8000

      final other = home.groups.firstWhere((g) => g.isUncategorized);
      expect(other.tenantCount, 2); // Manjunath, Anita
      expect(other.worstStatus, MonthStatus.partialOverdue); // Manjunath
      expect(other.oldDues, 0);
      expect(other.toReceive, 7500); // 3500 + 4000
    });

    test('the totals on top still cover every tenant', () async {
      await seedBlockA();

      final home = ok(await watchHome().first);
      expect(home.received, 5000);
      expect(home.toReceive, 24500);
    });

    test(
      'most urgent group first, empty groups last, ties by name ignoring case',
      () async {
        await seedBlockA();
        await seedGroup(h, id: 'z', name: 'zeta');
        await seedGroup(h, id: 'e', name: 'Alpha');

        final home = ok(await watchHome().first);
        expect(home.groups.map((g) => g.name), [
          'Block A', // overdue, with old dues
          'Uncategorized', // partial overdue
          'Alpha', // empty
          'zeta', // empty
        ]);
      },
    );

    test('a deleted group leaves Home', () async {
      await seedGroup(h, id: 'a', name: 'Block A');
      ok(await h.groups.deleteGroup('a', '2026-10'));

      expect(ok(await watchHome().first).groups, isEmpty);
    });

    test('re-emits when a tenant is moved to another group', () async {
      await seedGroup(h, id: 'a', name: 'Block A');
      await seedTenant(h, id: 't', start: '2026-10', rent: 1000);
      final seen = <List<String>>[];
      final sub = watchHome().listen(
        (r) => seen.add([
          for (final g in ok(r).groups) '${g.name}:${g.tenantCount}',
        ]),
      );
      await pumpEventQueue();

      ok(await h.tenants.setTenantGroup('t', 'a'));
      await pumpEventQueue();

      // The group with a tenant comes first; the empty one is last.
      expect(seen.first, ['Uncategorized:1', 'Block A:0']);
      expect(seen.last, ['Block A:1']);
      await sub.cancel();
    });
  });

  group('WatchGroupUsecase', () {
    test('shows only the tenants of that group, most urgent first', () async {
      await seedMockup();
      await seedGroup(h, id: 'a', name: 'Block A');
      ok(await h.tenants.setTenantGroup('farida', 'a'));
      ok(await h.tenants.setTenantGroup('ramesh', 'a'));

      final blockA = ok(await watchGroup('a').first);
      expect(blockA.name, 'Block A');
      expect(blockA.isUncategorized, isFalse);
      expect(blockA.currentMonth, '2026-10');
      expect(blockA.rows.map((r) => r.name), ['Farida Begum', 'Ramesh Kumar']);
      expect(blockA.received, 0);
      expect(blockA.toReceive, 17000);

      final other = ok(await watchGroup(uncategorizedGroupUuid).first);
      expect(other.isUncategorized, isTrue);
      expect(other.rows.map((r) => r.name), ['Manjunath S', 'Anita Rao']);
      expect(other.received, 5000);
      expect(other.toReceive, 7500);
    });

    test('an empty group has no rows and zero totals', () async {
      await seedGroup(h, id: 'a', name: 'Block A');

      final group = ok(await watchGroup('a').first);
      expect(group.rows, isEmpty);
      expect(group.received, 0);
      expect(group.toReceive, 0);
    });

    test('an unknown group is an error', () async {
      expect(errorOf(await watchGroup('nope').first), 'group_not_found');
    });

    test('a deleted group is an error', () async {
      await seedGroup(h, id: 'a', name: 'Block A');
      ok(await h.groups.deleteGroup('a', '2026-10'));

      expect(errorOf(await watchGroup('a').first), 'group_not_found');
    });

    test('re-emits with the new name after a rename', () async {
      await seedGroup(h, id: 'a', name: 'Block A');
      final names = <String>[];
      final sub = watchGroup('a').listen((r) => names.add(ok(r).name));
      await pumpEventQueue();

      ok(await h.groups.renameGroup('a', 'Block Z'));
      await pumpEventQueue();

      expect(names, ['Block A', 'Block Z']);
      await sub.cancel();
    });

    test('an archived tenant is not listed', () async {
      await seedTenant(h, id: 't', start: '2026-10', rent: 1000);
      ok(await h.tenants.deleteTenant('t', '2026-10'));

      expect(
        ok(await watchGroup(uncategorizedGroupUuid).first).rows,
        isEmpty,
      );
    });
  });

  group('WatchGroupsUsecase', () {
    test('lists Uncategorized and new groups, oldest first', () async {
      await seedGroup(h, id: 'a', name: 'Block A');

      final options = ok(await watchGroups().first);
      expect(options.map((g) => g.groupUuid), [uncategorizedGroupUuid, 'a']);
      expect(options.first.isUncategorized, isTrue);
      expect(options.last.name, 'Block A');
    });

    test('a deleted group is not offered', () async {
      await seedGroup(h, id: 'a', name: 'Block A');
      ok(await h.groups.deleteGroup('a', '2026-10'));

      final options = ok(await watchGroups().first);
      expect(options.map((g) => g.groupUuid), [uncategorizedGroupUuid]);
    });
  });

  group('WatchTenantDetailUsecase group', () {
    test('shows the tenant group and follows a move and a rename', () async {
      await seedTenant(h, id: 't', start: '2026-10', rent: 1000);
      await seedGroup(h, id: 'a', name: 'Block A');
      final seen = <String>[];
      final sub = watchDetail(
        't',
      ).listen((r) => seen.add('${ok(r).groupUuid}:${ok(r).groupName}'));
      await pumpEventQueue();

      ok(await h.tenants.setTenantGroup('t', 'a'));
      await pumpEventQueue();
      ok(await h.groups.renameGroup('a', 'Block Z'));
      await pumpEventQueue();

      expect(seen.first, '$uncategorizedGroupUuid:Uncategorized');
      expect(seen, contains('a:Block A'));
      expect(seen.last, 'a:Block Z');
      await sub.cancel();
    });

    test('an archived tenant still shows its deleted group', () async {
      await seedGroup(h, id: 'a', name: 'Block A');
      await seedTenant(h, id: 't', start: '2026-10', rent: 1000, group: 'a');
      ok(await h.tenants.deleteTenant('t', '2026-10'));
      ok(await h.groups.deleteGroup('a', '2026-10'));

      final d = ok(await watchDetail('t').first);
      expect(d.readOnly, isTrue);
      expect(d.groupUuid, 'a');
      expect(d.groupName, 'Block A');
    });
  });
  group('WatchTenantDetailUsecase', () {
    setUp(() => seedMockup());

    test(
      'active tenant: this month on top, history newest first',
      () async {
        final d = ok(await watchDetail('farida').first);

        expect(d.name, 'Farida Begum');
        expect(d.readOnly, isFalse);
        expect(d.topMonth!.month, '2026-10');
        expect(d.topMonth!.status, MonthStatus.overdue);
        expect(d.topMonth!.balance, 9000);
        expect(d.topMonth!.dueDate, '2026-10-05');
        expect(d.months.map((m) => m.month), ['2026-09', '2026-08']);
        expect(d.currentRent, 9000);
      },
    );

    test('a fully paid current month moves to History', () async {
      await payTo(h, 'farida', '2026-10', 9000, '2026-10-03');

      final d = ok(await watchDetail('farida').first);
      expect(d.topMonth, isNull);
      expect(d.months.map((m) => m.month), ['2026-10', '2026-09', '2026-08']);
      expect(d.months.first.balance, 0);
      expect(d.currentRent, 9000);
    });

    test('a part-paid current month stays on top', () async {
      await payTo(h, 'farida', '2026-10', 4000, '2026-10-03');

      final d = ok(await watchDetail('farida').first);
      expect(d.topMonth!.month, '2026-10');
      expect(d.topMonth!.balance, 5000);
      expect(d.months.map((m) => m.month), ['2026-09', '2026-08']);
    });
    test('old dues, the oldest month owing, and the total owed', () async {
      final d = ok(await watchDetail('farida').first);

      expect(d.oldDues, 5000);
      expect(d.oldestOwingMonth, '2026-09');
      expect(d.oldestOwingRentRecordUuid, isNotNull);
      expect(d.totalOwed, 14000); // 5000 old + 9000 this month
    });

    test('a tenant who owes nothing old has no oldest-owing month', () async {
      final d = ok(await watchDetail('ramesh').first);

      expect(d.oldDues, 0);
      expect(d.oldestOwingMonth, isNull);
      expect(d.oldestOwingRentRecordUuid, isNull);
      expect(d.totalOwed, 8000);
    });

    test('each month lists its payments, oldest first', () async {
      final d = ok(await watchDetail('manju').first);
      final august = d.months.firstWhere((m) => m.month == '2026-08');

      expect(august.status, MonthStatus.backlogCleared);
      expect(august.paid, 5500);
      expect(august.balance, 0);
      expect(august.payments.map((p) => '${p.amount}@${p.paidOn}'), [
        '3000@2026-08-04',
        '2500@2026-09-12',
      ]);
    });

    test('overpayment shows as extra and the balance stays zero', () async {
      await payTo(h, 'anita', '2026-10', 9000, '2026-10-10'); // 12000 of 7000

      final d = ok(await watchDetail('anita').first);
      expect(d.topMonth, isNull);
      final top = d.months.firstWhere((m) => m.month == '2026-10');
      expect(top.paid, 12000);
      expect(top.balance, 0);
      expect(top.extra, 5000);
    });

    test('a rent change shows as pending until its month starts', () async {
      ok(
        await h.history.changeRent(
          tenantUuid: 'farida',
          effectiveFromMonth: '2026-11',
          amount: 9500,
        ),
      );

      final d = ok(await watchDetail('farida').first);
      expect(d.pendingRentMonth, '2026-11');
      expect(d.pendingRentAmount, 9500);
      expect(d.currentRent, 9000);

      h.clock.setToday('2026-11-01');
      final next = ok(await watchDetail('farida').first);
      expect(next.pendingRentMonth, isNull);
    });

    test(
      're-emits when a rent change is made even though no record changes',
      () async {
        final notes = <String?>[];
        final sub = watchDetail(
          'farida',
        ).listen((r) => notes.add(ok(r).pendingRentMonth));
        await pumpEventQueue();

        ok(
          await h.history.changeRent(
            tenantUuid: 'farida',
            effectiveFromMonth: '2026-11',
            amount: 9500,
          ),
        );
        await pumpEventQueue();

        expect(notes, [null, '2026-11']);
        await sub.cancel();
      },
    );

    test('re-emits after a payment', () async {
      final balances = <int>[];
      final sub = watchDetail(
        'farida',
      ).listen((r) => balances.add(ok(r).topMonth!.balance));
      await pumpEventQueue();

      await payTo(h, 'farida', '2026-10', 4000, '2026-10-12');
      await pumpEventQueue();

      expect(balances, [9000, 5000]);
      await sub.cancel();
    });

    test(
      'archived tenant is read-only, latest month on top, all months listed',
      () async {
        ok(await h.tenants.deleteTenant('farida', '2026-10'));

        final d = ok(await watchDetail('farida').first);
        expect(d.readOnly, isTrue);
        expect(d.deletedMonth, '2026-10');
        expect(d.topMonth!.month, '2026-10');
        expect(d.months.map((m) => m.month), ['2026-10', '2026-09', '2026-08']);
      },
    );

    test('a tenant with no records yet takes the rent from history', () async {
      // Saved straight to the repository, so no records exist yet.
      ok(
        await h.tenants.addTenant(
          TenantModel(
            uuid: 'new',
            name: 'New',
            createdOn: h.clock.nowUtc(),
            dueDay: 10,
            startMonth: '2026-10',
          ),
          6000,
        ),
      );

      final d = ok(await watchDetail('new').first);
      expect(d.topMonth, isNull);
      expect(d.currentRent, 6000);
      expect(d.months, isEmpty);
    });

    test('unknown tenant: one tenant_not_found error', () async {
      expect(errorOf(await watchDetail('nope').first), 'tenant_not_found');
    });
  });

  group('WatchArchivedTenantsUsecase', () {
    test('newest deletion first, with the last rent', () async {
      await seedTenant(h, id: 'a', name: 'Anil', start: '2026-08', rent: 5000);
      await seedTenant(
        h,
        id: 'b',
        name: 'Bhaskar',
        start: '2026-09',
        rent: 7000,
      );
      await seedTenant(
        h,
        id: 'c',
        name: 'Chitra',
        start: '2026-09',
        rent: 6000,
      );
      ok(await h.tenants.deleteTenant('a', '2026-09'));
      ok(await h.tenants.deleteTenant('b', '2026-10'));

      final list = ok(await watchArchived().first).rows;

      expect(list.map((r) => r.name), ['Bhaskar', 'Anil']); // Chitra is active
      expect(list.map((r) => r.deletedMonth), ['2026-10', '2026-09']);
      expect(list.map((r) => r.lastRent), [7000, 5000]);
    });

    test('empty when nobody is archived', () async {
      await seedTenant(h, id: 'a', start: '2026-10', rent: 5000);
      expect(ok(await watchArchived().first).rows, isEmpty);
    });

    test('re-emits when a tenant is deleted', () async {
      await seedTenant(h, id: 'a', start: '2026-10', rent: 5000);
      final counts = <int>[];
      final sub = watchArchived().listen((r) => counts.add(ok(r).rows.length));
      await pumpEventQueue();

      ok(await h.tenants.deleteTenant('a', '2026-10'));
      await pumpEventQueue();

      expect(counts, [0, 1]);
      await sub.cancel();
    });
  });

  group('LoadPaymentOptionsUsecase', () {
    setUp(() => seedMockup());

    test(
      'months owing plus this month, newest first; this month is default',
      () async {
        final o = ok(await paymentOptions('farida'));

        expect(o.tenantName, 'Farida Begum');
        expect(o.today, '2026-10-12');
        expect(o.options.map((x) => x.month), ['2026-10', '2026-09']);
        expect(o.options.map((x) => x.balance), [9000, 5000]);
        expect(o.options.first.paid, 0);
        expect(o.options.first.requiredAmount, 9000);
        expect(o.defaultRentRecordUuid, o.options.first.rentRecordUuid);
      },
    );

    test(
      'when this month is paid, the default is the oldest month owing',
      () async {
        // Make August owe too, then pay October in full.
        await seedTenant(h, id: 'x', start: '2026-08', rent: 1000);
        await payTo(h, 'x', '2026-10', 1000, '2026-10-01');

        final o = ok(await paymentOptions('x'));
        // Newest first: October (paid, still offered), September, August.
        expect(o.options.map((p) => p.month), [
          '2026-10',
          '2026-09',
          '2026-08',
        ]);
        final oldest = o.options.last;
        expect(o.defaultRentRecordUuid, oldest.rentRecordUuid);
      },
    );

    test(
      'everything paid: only this month is offered, and it is the default',
      () async {
        final o = ok(await paymentOptions('ramesh'));
        // Ramesh: Aug and Sep paid, October unpaid -> October has a balance.
        expect(o.options.map((x) => x.month), ['2026-10']);

        await payTo(h, 'ramesh', '2026-10', 8000, '2026-10-12');
        final paid = ok(await paymentOptions('ramesh'));
        expect(paid.options.map((x) => x.month), ['2026-10']);
        expect(paid.options.single.balance, 0);
        expect(paid.defaultRentRecordUuid, paid.options.single.rentRecordUuid);
      },
    );

    test('a cleared old month is no longer offered', () async {
      await payTo(h, 'farida', '2026-09', 5000, '2026-10-12');
      final o = ok(await paymentOptions('farida'));
      expect(o.options.map((x) => x.month), ['2026-10']);
    });

    test('unknown and deleted tenants', () async {
      expect(errorOf(await paymentOptions('nope')), 'tenant_not_found');
      ok(await h.tenants.deleteTenant('farida', '2026-10'));
      expect(errorOf(await paymentOptions('farida')), 'tenant_deleted');
    });
  });

  group('LoadRentChangeInfoUsecase', () {
    setUp(() => seedMockup());

    test('current rent, this month and the month the change starts', () async {
      final info = ok(await rentChangeInfo('farida'));

      expect(info.tenantName, 'Farida Begum');
      expect(info.currentRent, 9000);
      expect(info.currentMonth, '2026-10');
      expect(info.effectiveFromMonth, '2026-11');
    });

    test('a pending change does not alter the current rent', () async {
      ok(
        await h.history.changeRent(
          tenantUuid: 'farida',
          effectiveFromMonth: '2026-11',
          amount: 9500,
        ),
      );

      expect(ok(await rentChangeInfo('farida')).currentRent, 9000);
    });

    test('effective month rolls into the next year', () async {
      h.clock.setToday('2026-12-05');
      expect(ok(await rentChangeInfo('farida')).effectiveFromMonth, '2027-01');
    });

    test('unknown and deleted tenants', () async {
      expect(errorOf(await rentChangeInfo('nope')), 'tenant_not_found');
      ok(await h.tenants.deleteTenant('farida', '2026-10'));
      expect(errorOf(await rentChangeInfo('farida')), 'tenant_deleted');
    });
  });

  group('LoadAddTenantFormUsecase', () {
    test('the last 12 months, oldest first, defaulting to this month', () {
      final form = LoadAddTenantFormUsecase(h.clock)();

      expect(form.startMonthOptions, hasLength(12));
      expect(form.startMonthOptions.first, '2025-11');
      expect(form.startMonthOptions.last, '2026-10');
      expect(form.defaultStartMonth, '2026-10');
      expect(form.defaultDueDay, 10);
    });
  });
}
