import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_tenant_detail/watch_tenant_detail_return_model.dart';
import 'package:tenant_tracker/features/add_tenant/add_tenant_view_model.dart';
import 'package:tenant_tracker/features/app/app_view_model.dart';
import 'package:tenant_tracker/features/archived/archived_view_model.dart';
import 'package:tenant_tracker/features/change_rent/change_rent_view_model.dart';
import 'package:tenant_tracker/features/home/home_view_model.dart';
import 'package:tenant_tracker/features/record_payment/record_payment_view_model.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view_model.dart';
import 'package:tenant_tracker/features/welcome/welcome_view_model.dart';

import '../domain/harness.dart';
import 'feature_harness.dart';

String? _code(ViewState<Object?> s) => switch (s) {
  ViewStateError(failure: final f) => f.message,
  _ => null,
};

void main() {
  late Harness h;
  late AppDependencies deps;

  setUp(() async {
    h = Harness(today: '2026-03-15');
    deps = await buildDeps(h);
  });

  tearDown(() => h.close());

  group('WelcomeViewModel', () {
    test('steps through the pages and finishes', () async {
      var finished = 0;
      final vm = WelcomeViewModel(onFinish: () async => finished++);
      expect(vm.page.value, 0);
      expect(vm.isLast, isFalse);
      vm.next();
      vm.next();
      vm.next(); // already on the last page
      expect(vm.page.value, WelcomeViewModel.pageCount - 1);
      expect(vm.isLast, isTrue);
      await vm.finish();
      expect(finished, 1);
      vm.dispose();
    });
  });

  group('AppViewModel', () {
    AppViewModel build() => AppViewModel(
      loadSettings: deps.loadSettings,
      setLanguage: deps.setLanguage,
      setShowTips: deps.setShowTips,
      markWelcomeSeen: deps.markWelcomeSeen,
    );

    test('loads the defaults', () async {
      final vm = build();
      expect(vm.state.value, isA<ViewStateLoading<Object?>>());
      await vm.load();
      expect(vm.settings.languageCode, 'en');
      expect(vm.settings.showTips, isTrue);
      expect(vm.settings.seenWelcome, isFalse);
      vm.dispose();
    });

    test('changes language, tips and the welcome flag', () async {
      final vm = build();
      await vm.load();
      await vm.setLanguage('kn');
      expect(vm.settings.languageCode, 'kn');
      await vm.toggleLanguage();
      expect(vm.settings.languageCode, 'en');
      await vm.setShowTips(false);
      expect(vm.settings.showTips, isFalse);
      await vm.markWelcomeSeen();
      expect(vm.settings.seenWelcome, isTrue);
      vm.dispose();
    });

    test('an unsupported language leaves the settings unchanged', () async {
      final vm = build();
      await vm.load();
      await vm.setLanguage('fr');
      expect(vm.settings.languageCode, 'en');
      vm.dispose();
    });
  });

  group('HomeViewModel', () {
    HomeViewModel build() => HomeViewModel(
      ensureRentRecords: deps.ensureRentRecords,
      watchHome: deps.watchHome,
    );

    test(
      'starts Loading, then lists tenants after creating missing records',
      () async {
        // Added straight to the repository: no monthly records exist yet.
        await seedTenantWithoutRecords(
          h,
          id: 'a',
          start: '2026-01',
          rent: 8000,
        );
        final vm = build();
        expect(vm.state.value, isA<ViewStateLoading<Object?>>());
        await vm.refresh();
        final data = loaded(
          await waitFor(vm.state, (s) => s is ViewStateLoaded),
        );
        expect(data.currentMonth, '2026-03');
        expect(data.rows.single.name, 'a');
        // 15 March, due day 10, nothing paid.
        expect(data.rows.single.status, MonthStatus.overdue);
        // January and February were created and are owed.
        expect(data.rows.single.oldDues, 16000);
        vm.dispose();
      },
    );

    test('updates when a payment is recorded', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 5000);
      final vm = build();
      await vm.refresh();
      await waitFor(vm.state, (s) => s is ViewStateLoaded);
      expect(loaded(vm.state.value).received, 0);

      await payTo(h, 'a', '2026-03', 5000, '2026-03-05');
      final data = loaded(
        await waitFor(
          vm.state,
          (s) =>
              s is ViewStateLoaded<WatchHomeReturnModel> &&
              s.data.received == 5000,
        ),
      );
      expect(data.toReceive, 0);
      expect(data.rows.single.status, MonthStatus.completed);
      vm.dispose();
    });

    test('refresh again keeps one subscription and the latest data', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 5000);
      final vm = build();
      await vm.refresh();
      await vm.refresh();
      await waitFor(vm.state, (s) => s is ViewStateLoaded);
      // A new month: the second refresh creates April's record.
      h.clock.setToday('2026-04-02');
      await vm.refresh();
      final data = loaded(
        await waitFor(
          vm.state,
          (s) =>
              s is ViewStateLoaded<WatchHomeReturnModel> &&
              s.data.currentMonth == '2026-04',
        ),
      );
      expect(data.rows.single.oldDues, 5000); // March is now an old due
      vm.dispose();
    });

    test('dispose stops the stream', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 5000);
      final vm = build();
      await vm.refresh();
      await waitFor(vm.state, (s) => s is ViewStateLoaded);
      vm.dispose();
      // Would throw "used after dispose" if the subscription were still open.
      await payTo(h, 'a', '2026-03', 100, '2026-03-05');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    test('dispose during a pending refresh does not subscribe', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 5000);
      final vm = build();
      final pending = vm.refresh();
      vm.dispose();
      await pending;
      await payTo(h, 'a', '2026-03', 100, '2026-03-05');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  });

  group('AddTenantViewModel', () {
    AddTenantViewModel build() => AddTenantViewModel(
      loadForm: deps.loadAddTenantForm,
      addTenant: deps.addTenant,
    );

    test('form defaults: due day 10, current month, 12 months', () {
      final vm = build();
      expect(vm.dueDay.value, 10);
      expect(vm.startMonth.value, '2026-03');
      expect(vm.form.startMonthOptions.length, 12);
      expect(vm.saveState.value, isA<ViewStateIdle<Object?>>());
      vm.dispose();
    });

    test('a missing name or rent is an error and saves nothing', () async {
      final vm = build();
      await vm.onSave(name: '  ', rentText: '8000');
      expect(_code(vm.saveState.value), 'name_required');
      await vm.onSave(name: 'Ravi', rentText: '');
      expect(_code(vm.saveState.value), 'rent_invalid');
      await vm.onSave(name: 'Ravi', rentText: '0');
      expect(_code(vm.saveState.value), 'rent_invalid');
      expect(ok(await h.tenants.getActiveTenants()), isEmpty);
      vm.dispose();
    });

    test('saves with the chosen due day and start month', () async {
      final vm = build();
      vm.dueDay.value = 20;
      vm.startMonth.value = '2026-01';
      await vm.onSave(name: ' Ravi ', rentText: '7000');
      final uuid = loaded(vm.saveState.value);
      final tenant = ok(await h.tenants.getTenant(uuid))!;
      expect(tenant.name, 'Ravi');
      expect(tenant.dueDay, 20);
      expect(tenant.startMonth, '2026-01');
      expect(ok(await h.records.getRecords(uuid)).length, 3);
      vm.dispose();
    });

    test('a second save while the first runs is ignored', () async {
      final vm = build();
      final first = vm.onSave(name: 'Ravi', rentText: '7000');
      final second = vm.onSave(name: 'Ravi', rentText: '7000');
      await Future.wait([first, second]);
      expect(ok(await h.tenants.getActiveTenants()).length, 1);
      vm.dispose();
    });
  });

  group('TenantDetailViewModel', () {
    TenantDetailViewModel build(String id) => TenantDetailViewModel(
      bundle: TenantDetailBundle(tenantUuid: id),
      ensureRentRecords: deps.ensureRentRecords,
      watchTenantDetail: deps.watchTenantDetail,
      deleteTenant: deps.deleteTenant,
      renameTenant: deps.renameTenant,
      undoPayment: deps.undoPayment,
    );

    test('rename updates the loaded name', () async {
      await seedTenant(h, id: 'a', start: '2026-02', rent: 6000);
      final vm = build('a');
      await vm.refresh();
      await waitFor(vm.state, (s) => s is ViewStateLoaded);

      expect(await vm.rename('  Ravi Kumar '), isNull);

      final data = loaded(
        await waitFor(
          vm.state,
          (s) =>
              s is ViewStateLoaded<WatchTenantDetailReturnModel> &&
              s.data.name == 'Ravi Kumar',
        ),
      );
      expect(data.name, 'Ravi Kumar');
      vm.dispose();
    });

    test('rename with an empty name returns a failure', () async {
      await seedTenant(h, id: 'a', start: '2026-02', rent: 6000);
      final vm = build('a');
      final failure = await vm.rename('   ');
      expect(failure, isA<ValidationFailure>());
      vm.dispose();
    });

    test('loads the tenant with old dues', () async {
      await seedTenant(h, id: 'a', start: '2026-02', rent: 6000);
      final vm = build('a');
      await vm.refresh();
      final data = loaded(await waitFor(vm.state, (s) => s is ViewStateLoaded));
      expect(data.name, 'a');
      expect(data.readOnly, isFalse);
      expect(data.oldDues, 6000);
      expect(data.totalOwed, 12000);
      vm.dispose();
    });

    test('an unknown tenant is an error state', () async {
      final vm = build('nobody');
      await vm.refresh();
      await waitFor(vm.state, (s) => s is ViewStateError);
      expect(_code(vm.state.value), 'tenant_not_found');
      vm.dispose();
    });

    test('undo removes the payment and the list updates', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final id = await payTo(h, 'a', '2026-03', 6000, '2026-03-05');
      final vm = build('a');
      await vm.refresh();
      await waitFor(vm.state, (s) => s is ViewStateLoaded);
      final paidUp = loaded(vm.state.value);
      expect(paidUp.topMonth, isNull);
      expect(paidUp.months.first.paid, 6000);

      expect(await vm.undoPayment(id), isNull);
      final data = loaded(
        await waitFor(
          vm.state,
          (s) =>
              s is ViewStateLoaded<WatchTenantDetailReturnModel> &&
              s.data.topMonth?.paid == 0,
        ),
      );
      expect(data.topMonth!.balance, 6000);
      vm.dispose();
    });

    test('delete moves the tenant to the archive', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      expect(vm.deleteState.value, isA<ViewStateIdle<Object?>>());
      await vm.onDelete();
      expect(vm.deleteState.value, isA<ViewStateLoaded<Object?>>());
      expect(ok(await h.tenants.getActiveTenants()), isEmpty);
      vm.dispose();
    });

    test('a second delete while the first runs is ignored', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      final first = vm.onDelete();
      final second = vm.onDelete();
      await Future.wait([first, second]);
      expect(vm.deleteState.value, isA<ViewStateLoaded<Object?>>());
      vm.dispose();
    });

    test('an archived tenant shows read-only', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.onDelete();
      await vm.refresh();
      final data = loaded(
        await waitFor(
          vm.state,
          (s) =>
              s is ViewStateLoaded<WatchTenantDetailReturnModel> &&
              s.data.readOnly,
        ),
      );
      expect(data.deletedMonth, '2026-03');
      vm.dispose();
    });
  });

  group('RecordPaymentViewModel', () {
    RecordPaymentViewModel build(String id, {String? record}) =>
        RecordPaymentViewModel(
          bundle: RecordPaymentBundle(
            tenantUuid: id,
            initialRentRecordUuid: record,
          ),
          loadPaymentOptions: deps.loadPaymentOptions,
          recordPayment: deps.recordPayment,
        );

    test('loads the options and preselects the current month', () async {
      await seedTenant(h, id: 'a', start: '2026-02', rent: 6000);
      final vm = build('a');
      expect(vm.loadState.value, isA<ViewStateLoading<Object?>>());
      await vm.load();
      final data = loaded(vm.loadState.value);
      expect(data.options.map((o) => o.month), ['2026-03', '2026-02']);
      expect(vm.selectedOption!.month, '2026-03');
      expect(vm.date.value, '2026-03-15');
      expect(vm.fullBalance, 6000);
      vm.dispose();
    });

    test('a month from the bundle is preselected', () async {
      await seedTenant(h, id: 'a', start: '2026-02', rent: 6000);
      final feb = ok(
        await h.records.getRecords('a'),
      ).firstWhere((r) => r.month == '2026-02');
      final vm = build('a', record: feb.uuid);
      await vm.load();
      expect(vm.selectedOption!.month, '2026-02');
      vm.dispose();
    });

    test('the hint follows the amount and the chosen month', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.load();
      expect(vm.hint, isNull);
      vm.onAmountChanged('abc');
      expect(vm.hint, isNull);

      vm.onAmountChanged('2000');
      expect(vm.hint!.balanceAfter, 4000);
      expect(vm.hint!.fullyPaid, isFalse);

      vm.onAmountChanged('6000');
      expect(vm.hint!.fullyPaid, isTrue);
      expect(vm.hint!.extra, 0);

      vm.onAmountChanged('6500');
      expect(vm.hint!.fullyPaid, isTrue);
      expect(vm.hint!.extra, 500);
      vm.dispose();
    });

    test('a bad amount is an error and records nothing', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.load();
      await vm.onSave();
      expect(_code(vm.saveState.value), 'amount_invalid');
      vm.onAmountChanged('0');
      await vm.onSave();
      expect(_code(vm.saveState.value), 'amount_invalid');
      vm.dispose();
    });

    test('a future date is an error', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.load();
      vm.onAmountChanged('100');
      vm.onDateChanged('2026-03-16');
      await vm.onSave();
      expect(_code(vm.saveState.value), 'date_in_future');
      vm.dispose();
    });

    test('saves the payment against the chosen month', () async {
      await seedTenant(h, id: 'a', start: '2026-02', rent: 6000);
      final vm = build('a');
      await vm.load();
      final feb = vm.loadState.value is ViewStateLoaded
          ? loaded(
              vm.loadState.value,
            ).options.firstWhere((o) => o.month == '2026-02')
          : throw StateError('not loaded');
      vm.onMonthChanged(feb.rentRecordUuid);
      vm.onAmountChanged('2500');
      vm.onDateChanged('2026-03-10');
      await vm.onSave();
      final paymentUuid = loaded(vm.saveState.value);
      final payments = ok(
        await h.payments.getPaymentsOfRecord(feb.rentRecordUuid),
      );
      expect(payments.single.uuid, paymentUuid);
      expect(payments.single.amount, 2500);
      expect(payments.single.paidOn, '2026-03-10');
      vm.dispose();
    });

    test('an unknown tenant is an error state', () async {
      final vm = build('nobody');
      await vm.load();
      expect(_code(vm.loadState.value), 'tenant_not_found');
      vm.dispose();
    });

    test('a second save while the first runs is ignored', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.load();
      vm.onAmountChanged('100');
      await Future.wait([vm.onSave(), vm.onSave()]);
      final record = vm.selectedRecord.value!;
      expect(ok(await h.payments.getPaymentsOfRecord(record)).length, 1);
      vm.dispose();
    });
  });

  group('ChangeRentViewModel', () {
    ChangeRentViewModel build(String id) => ChangeRentViewModel(
      bundle: ChangeRentBundle(tenantUuid: id),
      loadInfo: deps.loadRentChangeInfo,
      changeRent: deps.changeRent,
    );

    test('loads the current rent and the start month of the change', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.load();
      final info = loaded(vm.loadState.value);
      expect(info.currentRent, 6000);
      expect(info.effectiveFromMonth, '2026-04');
      vm.dispose();
    });

    test('the hint says up, down or same', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.load();
      expect(vm.hint, isNull);
      vm.onRentChanged('6500');
      expect(vm.hint!.difference, 500);
      vm.onRentChanged('5000');
      expect(vm.hint!.difference, -1000);
      vm.onRentChanged('6000');
      expect(vm.hint!.difference, 0);
      vm.onRentChanged('0');
      expect(vm.hint, isNull);
      vm.dispose();
    });

    test('an empty rent is an error', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.load();
      await vm.onSave();
      expect(_code(vm.saveState.value), 'rent_invalid');
      vm.dispose();
    });

    test('saving changes next month, not this one', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      final vm = build('a');
      await vm.load();
      vm.onRentChanged('7000');
      await vm.onSave();
      expect(vm.saveState.value, isA<ViewStateLoaded<Object?>>());
      expect(ok(await h.history.getRentForMonth('a', '2026-03')), 6000);
      expect(ok(await h.history.getRentForMonth('a', '2026-04')), 7000);
      vm.dispose();
    });

    test('a deleted tenant cannot be loaded for a rent change', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      ok(await h.tenants.deleteTenant('a', '2026-03'));
      final vm = build('a');
      await vm.load();
      expect(_code(vm.loadState.value), 'tenant_deleted');
      vm.dispose();
    });
  });

  group('ArchivedViewModel', () {
    test('lists removed tenants and stops on dispose', () async {
      await seedTenant(h, id: 'a', start: '2026-03', rent: 6000);
      await seedTenant(h, id: 'b', start: '2026-03', rent: 5000);
      ok(await h.tenants.deleteTenant('a', '2026-03'));
      final vm = ArchivedViewModel(watchArchived: deps.watchArchivedTenants);
      expect(vm.state.value, isA<ViewStateLoading<Object?>>());
      final data = loaded(await waitFor(vm.state, (s) => s is ViewStateLoaded));
      expect(data.rows.map((r) => r.name), ['a']);
      expect(data.rows.single.lastRent, 6000);
      vm.dispose();
      ok(await h.tenants.deleteTenant('b', '2026-03'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  });
}
