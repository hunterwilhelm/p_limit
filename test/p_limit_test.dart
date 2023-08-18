import 'dart:math';

import 'package:p_limit/p_limit.dart';
import 'package:test/test.dart';

void main() {
  test('concurrency: 1 - Value should be [2, 1, 3]', () async {
    final limit = PLimit<int>(2);

    const input = [
      [10, 300],
      [20, 200],
      [30, 100],
    ];
    final Stopwatch stopwatch = Stopwatch()..start();
    mapper(List<int> pair) => limit(() async {
          await Future.delayed(Duration(milliseconds: pair[1]));
          return pair[0];
        });

    final List<int> results = await Future.wait(input.map((x) => mapper(x)));
    final end = stopwatch.elapsedMilliseconds;
    expect(true, 290 <= end && end <= 350, reason: "end: $end");
    expect(
      results,
      [10, 20, 30],
    );
  });
  test('concurrency: 4', () async {
    const concurrency = 5;
    var running = 0;

    final limit = PLimit(concurrency);

    final input = List<Future<void>>.generate(
        100,
        (_) => limit.call(() async {
              running++;
              expect(running <= concurrency, true);
              await Future.delayed(Duration(milliseconds: 30 + Random().nextInt(170)));
              running--;
            }));

    await Future.wait(input);
  });

  test('continues after sync throw', () async {
    final limit = PLimit(1);
    var ran = false;

    final tasks = [
      limit(() {
        throw Exception('err');
      }),
      limit(() async {
        ran = true;
      }),
    ];

    try {
      await Future.wait(tasks);
    } catch (_) {}

    expect(ran, true);
  });

  test('does not ignore errors', () async {
    final limit = PLimit(1);
    const error = '🦄';

    final tasks = [
      limit.call(() async {
        await Future.delayed(const Duration(milliseconds: 30));
      }),
      limit.call(() async {
        await Future.delayed(const Duration(milliseconds: 80));
        throw error;
      }),
      limit.call(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      }),
    ];

    try {
      await Future.wait(tasks);
    } catch (e) {
      expect(e, error);
    }
  });

  test('activeCount and pendingCount properties', () async {
    final limit = PLimit(5);
    expect(limit.activeCount, 0);
    expect(limit.pendingCount, 0);

    final runningfuture1 = limit(() async {
      await Future.delayed(const Duration(milliseconds: 1000));
    });
    expect(limit.activeCount, 0);
    expect(limit.pendingCount, 1);

    await Future.delayed(const Duration(milliseconds: 1));
    expect(limit.activeCount, 1);
    expect(limit.pendingCount, 0);

    await runningfuture1;
    expect(limit.activeCount, 0);
    expect(limit.pendingCount, 0);

    final immediatefutures = List.generate(5, (_) => limit(() async => Future.delayed(const Duration(milliseconds: 1000))));
    final delayedfutures = List.generate(3, (_) => limit(() async => Future.delayed(const Duration(milliseconds: 1000))));

    await Future.delayed(const Duration(milliseconds: 1));
    expect(limit.activeCount, 5);
    expect(limit.pendingCount, 3);

    await Future.wait(immediatefutures);
    expect(limit.activeCount, 3);
    expect(limit.pendingCount, 0);

    await Future.wait(delayedfutures);

    expect(limit.activeCount, 0);
    expect(limit.pendingCount, 0);
  });

  test('clearQueue', () async {
    final limit = PLimit(1);

    List.generate(1, (_) => limit(() => Future.delayed(const Duration(milliseconds: 1000))));
    List.generate(3, (_) => limit(() => Future.delayed(const Duration(milliseconds: 1000))));

    await Future.delayed(const Duration(milliseconds: 1));
    expect(limit.pendingCount, 3);
    limit.clearQueue();
    expect(limit.pendingCount, 0);
  });

  test('throws on invalid concurrency argument', () {
    expect(() => PLimit(0), throwsA(isA<AssertionError>()));
    expect(() => PLimit(-1), throwsA(isA<AssertionError>()));
  });
}
