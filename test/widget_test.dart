import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/main.dart';

import 'domain/harness.dart';
import 'features/feature_harness.dart';

/// Lets real async work (the in-memory database) run, then redraws, until
/// [finder] matches.
Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Never found $finder');
}

/// Runs the database work of a tap, then redraws.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

void main() {
  late Harness h;

  setUp(() async {
    h = Harness(today: '2026-10-12');
    AppDependencies.instance = await buildDeps(h);
  });

  Future<void> start(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await pumpUntil(tester, find.text('Skip'));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => h.close());
  }

  testWidgets('first run shows the welcome guide, Skip opens an empty home', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('Welcome!'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Add your tenants'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await pumpUntil(tester, find.textContaining('No tenants yet'));
    expect(find.text('This month – Oct 2026'), findsOneWidget);
    expect(find.text('Tenants (0)'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget); // bottom tab
    await finish(tester);
  });

  testWidgets('the language button switches the screen to Kannada', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('ಕನ್ನಡ'));
    await pumpUntil(tester, find.text('ಸ್ವಾಗತ!'));
    expect(find.text('Welcome!'), findsNothing);
    expect(
      find.text('English'),
      findsOneWidget,
    ); // the button now offers English
    await finish(tester);
  });

  testWidgets('add a tenant: validation, save, then the tenant page', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Skip'));
    await pumpUntil(tester, find.text('+ Add a tenant'));

    await tester.tap(find.text('+ Add a tenant'));
    await pumpUntil(tester, find.byKey(const Key('nameField')));

    // Empty name.
    await tester.enterText(find.byKey(const Key('rentField')), '8000');
    await tester.tap(find.text('Save'));
    await pumpUntil(tester, find.text('Please type a name.'));

    // Fill the name; empty rent.
    await tester.enterText(find.byKey(const Key('nameField')), 'Ramesh Kumar');
    await tester.enterText(find.byKey(const Key('rentField')), '');
    await tester.tap(find.text('Save'));
    await pumpUntil(tester, find.textContaining('Please type the rent amount'));

    // Save for real.
    await tester.enterText(find.byKey(const Key('rentField')), '8000');
    await tester.tap(find.text('Save'));
    await pumpUntil(tester, find.text('Money received'));
    expect(find.text('Ramesh Kumar'), findsWidgets);
    expect(find.text('₹8,000 per month'), findsOneWidget);
    expect(find.text('Ramesh Kumar added'), findsOneWidget); // snackbar
    expect(find.text('Pending'), findsNothing); // 12 Oct, due day 10: overdue
    expect(find.text('Overdue'), findsWidgets);
    await finish(tester);
  });

  testWidgets('record money for a tenant, see it on the page, undo it', (
    tester,
  ) async {
    await seedTenant(
      h,
      id: 'ramesh',
      name: 'Ramesh Kumar',
      start: '2026-10',
      rent: 8000,
    );
    await start(tester);
    await tester.tap(find.text('Skip'));
    await pumpUntil(tester, find.text('Ramesh Kumar'));

    await tester.tap(find.text('Ramesh Kumar'));
    await pumpUntil(tester, find.text('Money received'));
    expect(find.text('Received ₹0 of ₹8,000'), findsOneWidget);

    await tester.tap(find.text('Money received'));
    await pumpUntil(tester, find.byKey(const Key('amountField')));
    await tester.enterText(find.byKey(const Key('amountField')), '3000');
    await tester.pump();
    expect(
      find.text('After this, the balance will be ₹5,000.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Save'));
    await pumpUntil(tester, find.text('Received ₹3,000 of ₹8,000'));
    expect(find.text('₹3,000 saved'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await pumpUntil(tester, find.text('Received ₹0 of ₹8,000'));
    await finish(tester);
  });

  testWidgets(
    'removing a tenant asks first, shows what is owed, then archives',
    (tester) async {
      await seedTenant(
        h,
        id: 'ramesh',
        name: 'Ramesh Kumar',
        start: '2026-09',
        rent: 8000,
      );
      await start(tester);
      await tester.tap(find.text('Skip'));
      await pumpUntil(tester, find.text('Ramesh Kumar'));
      expect(find.text('Old dues: ₹8,000'), findsOneWidget);

      await tester.tap(find.text('Ramesh Kumar'));
      await pumpUntil(tester, find.text('Remove this tenant'));
      await tester.ensureVisible(find.text('Remove this tenant'));
      await tester.tap(find.text('Remove this tenant'));
      await pumpUntil(tester, find.text('Remove Ramesh Kumar?'));
      expect(
        find.text('Please note: ₹16,000 is still unpaid.'),
        findsOneWidget,
      );

      await tester.tap(find.text('No, keep'));
      await settle(tester);
      expect(find.text('Remove Ramesh Kumar?'), findsNothing);

      await tester.tap(find.text('Remove this tenant'));
      await pumpUntil(tester, find.text('Remove Ramesh Kumar?'));
      await tester.tap(find.text('Yes, remove'));
      await pumpUntil(tester, find.text('Ramesh Kumar removed'));
      await pumpUntil(tester, find.textContaining('No tenants yet'));
      await finish(tester);
    },
  );

  testWidgets('settings: the archive tile lists removed tenants read-only', (
    tester,
  ) async {
    await seedTenant(
      h,
      id: 'ramesh',
      name: 'Ramesh Kumar',
      start: '2026-09',
      rent: 8000,
    );
    ok(await h.tenants.deleteTenant('ramesh', '2026-10'));
    await start(tester);
    await tester.tap(find.text('Skip'));
    await pumpUntil(tester, find.textContaining('No tenants yet'));

    await tester.tap(find.text('Settings'));
    await pumpUntil(tester, find.text('Show tips'));
    await tester.tap(find.text('Archive'));
    await pumpUntil(tester, find.text('Ramesh Kumar'));
    expect(find.text('Removed in Oct 2026 · ₹8,000 per month'), findsOneWidget);

    await tester.tap(find.text('Ramesh Kumar'));
    await pumpUntil(tester, find.text('Removed in Oct 2026'));
    // Read-only: no action buttons.
    expect(find.text('Money received'), findsNothing);
    expect(find.text('Change rent'), findsNothing);
    expect(find.text('Remove this tenant'), findsNothing);
    await finish(tester);
  });
}
