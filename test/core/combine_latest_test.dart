import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/combine_latest.dart';

void main() {
  late StreamController<Result<int>> a;
  late StreamController<Result<int>> b;
  late StreamController<Result<int>> c;
  late List<Result<String>> out;
  late StreamSubscription<Result<String>> sub;

  setUp(() {
    a = StreamController<Result<int>>();
    b = StreamController<Result<int>>();
    c = StreamController<Result<int>>();
    out = [];
    sub = combineLatest3<int, int, int, String>(
      a.stream,
      b.stream,
      c.stream,
      (x, y, z) => '$x-$y-$z',
    ).listen(out.add);
  });

  tearDown(() async {
    await sub.cancel();
    // Not awaited: close() on a controller nobody listens to never completes.
    unawaited(a.close());
    unawaited(b.close());
    unawaited(c.close());
  });

  List<Object?> shown() =>
      out.map((r) => r.fold((f) => 'err:${f.message}', (v) => v)).toList();

  test('emits nothing until all three sources have emitted', () async {
    a.add(const Ok(1));
    b.add(const Ok(2));
    await pumpEventQueue();
    expect(out, isEmpty);

    c.add(const Ok(3));
    await pumpEventQueue();
    expect(shown(), ['1-2-3']);
  });

  test('emits again with the latest values when any source changes', () async {
    a.add(const Ok(1));
    b.add(const Ok(2));
    c.add(const Ok(3));
    await pumpEventQueue();
    // Delivery order across different controllers is not guaranteed, so
    // let each event land before adding the next.
    b.add(const Ok(20));
    await pumpEventQueue();
    a.add(const Ok(10));
    await pumpEventQueue();

    expect(shown(), ['1-2-3', '1-20-3', '10-20-3']);
  });

  test('an Err from a source is emitted, and the stream recovers', () async {
    a.add(const Ok(1));
    b.add(const Ok(2));
    c.add(const Ok(3));
    b.add(const Err(StorageFailure('boom')));
    b.add(const Ok(5));
    await pumpEventQueue();

    expect(shown(), ['1-2-3', 'err:boom', '1-5-3']);
  });

  test('cancelling cancels all three sources', () async {
    expect(a.hasListener && b.hasListener && c.hasListener, isTrue);

    await sub.cancel();

    expect(a.hasListener, isFalse);
    expect(b.hasListener, isFalse);
    expect(c.hasListener, isFalse);
  });

  test('combineLatest2 waits for both, then follows either', () async {
    final x = StreamController<Result<int>>();
    final y = StreamController<Result<int>>();
    final got = <Object?>[];
    final s = combineLatest2<int, int, String>(
      x.stream,
      y.stream,
      (p, q) => '$p+$q',
    ).listen((r) => got.add(r.fold((f) => 'err:${f.message}', (v) => v)));

    x.add(const Ok(1));
    await pumpEventQueue();
    expect(got, isEmpty);

    y.add(const Ok(2));
    await pumpEventQueue();
    x.add(const Err(StorageFailure('boom')));
    await pumpEventQueue();
    x.add(const Ok(3));
    await pumpEventQueue();

    expect(got, ['1+2', 'err:boom', '3+2']);
    await s.cancel();
    expect(x.hasListener || y.hasListener, isFalse);
    unawaited(x.close());
    unawaited(y.close());
  });

  test('completes when all sources are done', () async {
    var done = false;
    final s = combineLatest3<int, int, int, int>(
      Stream.value(const Ok(1)),
      Stream.value(const Ok(2)),
      Stream.value(const Ok(3)),
      (x, y, z) => x + y + z,
    );
    final values = <Result<int>>[];
    s.listen(values.add, onDone: () => done = true);
    await pumpEventQueue();

    expect(values.single.fold((_) => -1, (v) => v), 6);
    expect(done, isTrue);
  });
}
