import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_add_tenant_form/load_add_tenant_form_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_payment_options/load_payment_options_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_rent_change_info/load_rent_change_info_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_archived_tenants/watch_archived_tenants_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_tenant_detail/watch_tenant_detail_usecase.dart';

import '../harness.dart';

void main() {
  late Harness h;
  late WatchHomeUsecase watchHome;
  late WatchTenantDetailUsecase watchDetail;
  late WatchArchivedTenantsUsecase watchArchived;
  late LoadPaymentOptionsUsecase paymentOptions;
  late LoadRentChangeInfoUsecase rentChangeInfo;

  // The mockup's "today".
  setUp(() async {
    h = Harness(today: '2026-10-12');
    watchHome = WatchHomeUsecase(h.tenants, h.records, h.payments, h.clock);
    watchDetail = WatchTenantDetailUsecase(
        h.tenants, h.records, h.payments, h.history, h.clock);
    watchArchived = WatchArchivedTenantsUsecase(h.tenants, h.records);
    paymentOptions =
        LoadPaymentOptionsUsecase(h.tenants, h.records, h.payments, h.clock);
    rentChangeInfo = LoadRentChangeInfoUsecase(h.tenants, h.history, h.clock);
  });

  tearDown(() => h.close());

  /// The mockup's tenants (the ones needed here).
  Future<void> seedMockup() async {
    await seedTenant(h, id: 'ramesh', name: 'Ramesh Kumar', start: '2026-08', rent: 8000, dueDay: 15);
    await payTo(h, 'ramesh', '2026-08', 8000, '2026-08-10');
    await payTo(h, 'ramesh', '2026-09', 8000, '2026-09-14');

    await seedTenant(h, id: 'manju', name: 'Manjunath S', start: '2026-08', rent: 5500, dueDay: 5);
    await payTo(h, 'manju', '2026-08', 3000, '2026-08-04');
    await payTo(h, 'manju', '2026-08', 2500, '2026-09-12');
    await payTo(h, 'manju', '2026-09', 5500, '2026-09-05');
    await payTo(h, 'manju', '2026-10', 2000, '2026-10-02');

    await seedTenant(h, id: 'farida', name: 'Farida Begum', start: '2026-08', rent: 9000, dueDay: 5);
    await payTo(h, 'farida', '2026-08', 9000, '2026-08-03');
    await payTo(h, 'farida', '2026-09', 4000, '2026-09-06');

    await seedTenant(h, id: 'anita', name: 'Anita Rao', start: '2026-09', rent: 7000, dueDay: 20);
    await payTo(h, 'anita', '2026-09', 7000, '2026-09-18');
    await payTo(h, 'anita', '2026-10', 3000, '2026-10-06');
  }

  group('WatchHomeUsecase', () {
    test('no tenants: zero totals and an empty list', () async {
      final home = ok(await watchHome().first);

      expect(home.currentMonth, '2026-10');
      expect(home.rows, isEmpty);
      expect(home.received, 0);
      expect(home.toReceive, 0);
    });

    test('needs-attention first, old dues move a tenant up, then by name',
        () async {
      await seedMockup();
      final home = ok(await watchHome().first);

      expect(home.rows.map((r) => r.name), [
        'Farida Begum', // overdue, plus old dues
        'Manjunath S', // partial overdue
        'Anita Rao', // partial
        'Ramesh Kumar', // pending
      ]);
      expect(home.rows.map((r) => r.status), [
        MonthStatus.overdue,
        MonthStatus.partialOverdue,
        MonthStatus.partial,
        MonthStatus.pending,
      ]);
    });

    test('old dues: Farida owes 5000 for September, Manjunath cleared August',
        () async {
      await seedMockup();
      final home = ok(await watchHome().first);
      final dues = {for (final r in home.rows) r.name: r.oldDues};

      expect(dues['Farida Begum'], 5000);
      expect(dues['Manjunath S'], 0);
      expect(dues['Anita Rao'], 0);
      expect(dues['Ramesh Kumar'], 0);
    });

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

      final home = ok(await watchHome().first);
      expect(home.rows.map((r) => r.name), ['Arun', 'bala']);
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
      expect(home.rows.map((r) => r.name), isNot(contains('Farida Begum')));
      expect(home.rows, hasLength(3));
      expect(home.toReceive, 15500); // Farida's 9000 is gone from the total
    });

    test('a status follows the date: due day passes while paid in part',
        () async {
      await seedTenant(h, id: 't', start: '2026-10', rent: 5000, dueDay: 20);
      await payTo(h, 't', '2026-10', 1000, '2026-10-05');
      expect(ok(await watchHome().first).rows.single.status,
          MonthStatus.partial);

      h.clock.setToday('2026-10-21');
      expect(ok(await watchHome().first).rows.single.status,
          MonthStatus.partialOverdue);
    });

    test('a tenant with no record for this month is Pending, not in totals',
        () async {
      await seedTenant(h, id: 't', start: '2026-09', rent: 5000);
      h.clock.setToday('2026-11-02'); // November's record is not created yet

      final home = ok(await watchHome().first);
      expect(home.rows.single.status, MonthStatus.pending);
      expect(home.toReceive, 0);
      // September and October are both unpaid and now in the past.
      expect(home.rows.single.oldDues, 10000);
    });
  });

  group('WatchTenantDetailUsecase', () {
    setUp(() => seedMockup());

    test('active tenant: this month on top, earlier months newest first',
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
      expect(august.payments.map((p) => '${p.amount}@${p.paidOn}'),
          ['3000@2026-08-04', '2500@2026-09-12']);
    });

    test('overpayment shows as extra and the balance stays zero', () async {
      await payTo(h, 'anita', '2026-10', 9000, '2026-10-10'); // 12000 of 7000

      final top = ok(await watchDetail('anita').first).topMonth!;
      expect(top.paid, 12000);
      expect(top.balance, 0);
      expect(top.extra, 5000);
    });

    test('a rent change shows as pending until its month starts', () async {
      ok(await h.history.changeRent(
          tenantUuid: 'farida', effectiveFromMonth: '2026-11', amount: 9500));

      final d = ok(await watchDetail('farida').first);
      expect(d.pendingRentMonth, '2026-11');
      expect(d.pendingRentAmount, 9500);
      expect(d.currentRent, 9000);

      h.clock.setToday('2026-11-01');
      final next = ok(await watchDetail('farida').first);
      expect(next.pendingRentMonth, isNull);
    });

    test('re-emits when a rent change is made even though no record changes',
        () async {
      final notes = <String?>[];
      final sub = watchDetail('farida')
          .listen((r) => notes.add(ok(r).pendingRentMonth));
      await pumpEventQueue();

      ok(await h.history.changeRent(
          tenantUuid: 'farida', effectiveFromMonth: '2026-11', amount: 9500));
      await pumpEventQueue();

      expect(notes, [null, '2026-11']);
      await sub.cancel();
    });

    test('re-emits after a payment', () async {
      final balances = <int>[];
      final sub = watchDetail('farida')
          .listen((r) => balances.add(ok(r).topMonth!.balance));
      await pumpEventQueue();

      await payTo(h, 'farida', '2026-10', 4000, '2026-10-12');
      await pumpEventQueue();

      expect(balances, [9000, 5000]);
      await sub.cancel();
    });

    test('archived tenant is read-only, latest month on top, all months listed',
        () async {
      ok(await h.tenants.deleteTenant('farida', '2026-10'));

      final d = ok(await watchDetail('farida').first);
      expect(d.readOnly, isTrue);
      expect(d.deletedMonth, '2026-10');
      expect(d.topMonth!.month, '2026-10');
      expect(d.months.map((m) => m.month), ['2026-10', '2026-09', '2026-08']);
    });

    test('a tenant with no records yet takes the rent from history', () async {
      // Saved straight to the repository, so no records exist yet.
      ok(await h.tenants.addTenant(
          TenantModel(
            uuid: 'new',
            name: 'New',
            createdOn: h.clock.nowUtc(),
            dueDay: 10,
            startMonth: '2026-10',
          ),
          6000));

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
      await seedTenant(h, id: 'b', name: 'Bhaskar', start: '2026-09', rent: 7000);
      await seedTenant(h, id: 'c', name: 'Chitra', start: '2026-09', rent: 6000);
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

    test('months owing plus this month, newest first; this month is default',
        () async {
      final o = ok(await paymentOptions('farida'));

      expect(o.tenantName, 'Farida Begum');
      expect(o.today, '2026-10-12');
      expect(o.options.map((x) => x.month), ['2026-10', '2026-09']);
      expect(o.options.map((x) => x.balance), [9000, 5000]);
      expect(o.options.first.paid, 0);
      expect(o.options.first.requiredAmount, 9000);
      expect(o.defaultRentRecordUuid, o.options.first.rentRecordUuid);
    });

    test('when this month is paid, the default is the oldest month owing',
        () async {
      // Make August owe too, then pay October in full.
      await seedTenant(h, id: 'x', start: '2026-08', rent: 1000);
      await payTo(h, 'x', '2026-10', 1000, '2026-10-01');

      final o = ok(await paymentOptions('x'));
      // Newest first: October (paid, still offered), September, August.
      expect(o.options.map((p) => p.month), ['2026-10', '2026-09', '2026-08']);
      final oldest = o.options.last;
      expect(o.defaultRentRecordUuid, oldest.rentRecordUuid);
    });

    test('everything paid: only this month is offered, and it is the default',
        () async {
      final o = ok(await paymentOptions('ramesh'));
      // Ramesh: Aug and Sep paid, October unpaid -> October has a balance.
      expect(o.options.map((x) => x.month), ['2026-10']);

      await payTo(h, 'ramesh', '2026-10', 8000, '2026-10-12');
      final paid = ok(await paymentOptions('ramesh'));
      expect(paid.options.map((x) => x.month), ['2026-10']);
      expect(paid.options.single.balance, 0);
      expect(paid.defaultRentRecordUuid, paid.options.single.rentRecordUuid);
    });

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
      ok(await h.history.changeRent(
          tenantUuid: 'farida', effectiveFromMonth: '2026-11', amount: 9500));

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
