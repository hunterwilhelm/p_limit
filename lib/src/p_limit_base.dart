import 'dart:async';
import 'dart:collection';

/// Run multiple future-returning & async functions with limited concurrency.
class PLimit<T> {
  /// The number of futures that are currently running.
  int get activeCount => _activeCount;

  // The number of futures that are waiting to run (i.e. their internal fn was not called yet).
  int get pendingCount => _queue.length;

  /// Run multiple future-returning & async functions with limited concurrency.
  ///
  /// [concurrency] - Concurrency limit. Minimum: `1`.
  ///
  /// returns A `limit` function.
  PLimit(
    int concurrency,
  )   : _concurrency = concurrency,
        assert(concurrency.isFinite),
        assert(concurrency > 0) {
    _queue = Queue();
  }

  late Queue<Future<void> Function()> _queue;
  int _activeCount = 0;
  final int _concurrency;

  void _next() {
    _activeCount--;

    if (_queue.isNotEmpty) {
      final first = _queue.first;
      _queue.removeFirst();
      first();
    }
  }

  Future<void> _run(Future<T> Function() fn, void Function([FutureOr<T>? value]) resolve, Function(Object error, [StackTrace? stackTrace]) reject) async {
    _activeCount++;

    final result = (() async => fn())();
    resolve(result);
    try {
      await result;
    } catch (_) {}

    _next();
  }

  void _enqueue(Future<T> Function() fn, void Function([FutureOr<T>? value]) resolve, void Function(Object error, [StackTrace? stackTrace]) reject) {
    _queue.add(() => _run(fn, resolve, reject));

    Future.microtask(() async {
      // This function needs to wait until the next microtask before comparing
      // `activeCount` to `concurrency`, because `activeCount` is updated asynchronously
      // when the run function is dequeued and called. The comparison in the if-statement
      // needs to happen asynchronously as well to get an up-to-date value for `activeCount`.
      await Future(() {});

      if (_activeCount < _concurrency && _queue.isNotEmpty) {
        final first = _queue.first;
        _queue.removeFirst();
        first();
      }
    });
  }

  /// Returns the future returned by calling fn().
  Future<T> call(Future<T> Function() fn) async {
    final completer = Completer<T>();
    _enqueue(fn, completer.complete, completer.completeError);
    return completer.future;
  }

  /// Discard pending futures that are waiting to run.
  ///
  /// This might be useful if you want to teardown the queue at the end of your program's lifecycle or discard any function calls referencing an intermediary state of your app.
  ///
  /// Note: This does not cancel futures that are already running.
  void clearQueue() {
    _queue.clear();
  }
}
