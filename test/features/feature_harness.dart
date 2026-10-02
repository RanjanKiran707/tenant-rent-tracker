import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';

import '../domain/harness.dart';

/// Real use cases on the [Harness] database and clock, for ViewModel and
/// View tests.
Future<AppDependencies> buildDeps(Harness h) async {
  SharedPreferences.setMockInitialValues({});
  return AppDependencies.create(
    db: h.db,
    prefs: await SharedPreferences.getInstance(),
    clock: h.clock,
  );
}

/// Adds a tenant but creates no monthly records, like a tenant added long ago
/// whose months were never generated.
Future<void> seedTenantWithoutRecords(
  Harness h, {
  required String id,
  required String start,
  required int rent,
  int dueDay = 10,
}) async {
  ok(await h.tenants.addTenant(
    TenantModel(
      uuid: id,
      name: id,
      createdOn: h.clock.nowUtc(),
      dueDay: dueDay,
      startMonth: start,
    ),
    rent,
  ));
}

/// Waits until [listenable]'s value satisfies [test] (checks right away too).
Future<T> waitFor<T>(
  ValueListenable<T> listenable,
  bool Function(T value) test,
) {
  if (test(listenable.value)) return Future.value(listenable.value);
  final done = Completer<T>();
  void listener() {
    if (!done.isCompleted && test(listenable.value)) {
      done.complete(listenable.value);
    }
  }

  listenable.addListener(listener);
  return done.future
      .timeout(const Duration(seconds: 5))
      .whenComplete(() => listenable.removeListener(listener));
}

/// The data of a loaded state; fails the test for any other state.
T loaded<T>(ViewState<T> state) => switch (state) {
      ViewStateLoaded(data: final d) => d,
      _ => throw StateError('Expected Loaded, got $state'),
    };
