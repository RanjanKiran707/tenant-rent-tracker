import 'dart:async';

import 'package:tenant_tracker/core/errors/result.dart';

/// Same rules as [combineLatest3], for two sources.
Stream<Result<R>> combineLatest2<A, B, R>(
  Stream<Result<A>> a,
  Stream<Result<B>> b,
  R Function(A, B) combine,
) {
  // A third source that has already emitted and is done changes nothing.
  return combineLatest3<A, B, void, R>(
    a,
    b,
    Stream.value(const Ok(null)),
    (x, y, _) => combine(x, y),
  );
}

/// Combines three result streams into one.
///
/// Emits once all three sources have emitted, then again whenever any of them
/// emits. If the latest value of any source is an `Err`, that `Err` is
/// emitted instead (the stream keeps running and recovers on the next `Ok`).
/// Cancelling the returned stream cancels all three sources.
Stream<Result<R>> combineLatest3<A, B, C, R>(
  Stream<Result<A>> a,
  Stream<Result<B>> b,
  Stream<Result<C>> c,
  R Function(A, B, C) combine,
) {
  late final StreamController<Result<R>> controller;
  final subscriptions = <StreamSubscription<Object?>>[];

  Result<A>? latestA;
  Result<B>? latestB;
  Result<C>? latestC;
  var openSources = 3;

  void emit() {
    final ra = latestA, rb = latestB, rc = latestC;
    if (ra == null || rb == null || rc == null) return;
    if (ra is Err<A>) return controller.add(Err(ra.failure));
    if (rb is Err<B>) return controller.add(Err(rb.failure));
    if (rc is Err<C>) return controller.add(Err(rc.failure));
    controller.add(
      Ok(
        combine((ra as Ok<A>).value, (rb as Ok<B>).value, (rc as Ok<C>).value),
      ),
    );
  }

  void sourceDone() {
    openSources--;
    if (openSources == 0) controller.close();
  }

  controller = StreamController<Result<R>>(
    onListen: () {
      subscriptions.add(
        a.listen((v) {
          latestA = v;
          emit();
        }, onDone: sourceDone),
      );
      subscriptions.add(
        b.listen((v) {
          latestB = v;
          emit();
        }, onDone: sourceDone),
      );
      subscriptions.add(
        c.listen((v) {
          latestC = v;
          emit();
        }, onDone: sourceDone),
      );
    },
    onCancel: () async {
      await Future.wait(subscriptions.map((s) => s.cancel()));
    },
  );
  return controller.stream;
}
