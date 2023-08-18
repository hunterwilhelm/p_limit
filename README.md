Run multiple future-returning & async functions with limited concurrency

## Motivation

This is a port of [p-limit](https://www.npmjs.com/package/p-limit) from javascript to dart.

## Install

```
flutter pub add p_limit
```


## Usage

```dart
import 'package:p_limit/p_limit.dart';

void main() async {
  final limit = PLimit<string>(1);
  final input = [
    limit(() => fetchSomething('foo')),
    limit(() => fetchSomething('bar')),
    limit(() => doSomething())
  ];
  // Only one future is run at once
  final results = await Future.wait(input);
  print(results);
}

```

## API

### PLimit(concurrency)

Returns a `limit` function.

#### concurrency

Type: `number`\
Minimum: `1`\
Default: `Infinity`

Concurrency limit.

### limit(fn)

Returns the future returned by calling `fn()`.

#### fn

Type: `Function`

Future-returning/async function.

### limit.activeCount

The number of futures that are currently running.

### limit.pendingCount

The number of futures that are waiting to run (i.e. their internal `fn` was not called yet).

### limit.clearQueue()

Discard pending futures that are waiting to run.

This might be useful if you want to teardown the queue at the end of your program's lifecycle or discard any function calls referencing an intermediary state of your app.

Note: This does not cancel futures that are already running.

## FAQ

### How is this different from the [`async_task`](https://github.com/eneural-net/async_task) package?

This package is only about limiting the number of concurrent executions, while `async_task` is a fully featured queue implementation similar to classic thread pools and with lots of different options.

### But what about args?

You probably don't need this optimization unless you're pushing a lot of functions. If you are in need of this, make a pull request or an issue on [Github](https://github.com/hunterwilhelm/p_limit/issues).

## Related

- [async_task](https://pub.dev/packages/async_task) - Asynchronous tasks and parallel executors
- [concurrent_queue](https://pub.dev/packages/concurrent_queue) - Priority queue with concurrency control


## Additional information

If you have an issue, let me know on [Github issues](https://github.com/hunterwilhelm/p_limit/issues)

## Special Thanks

Since this is a port of [p-limit](https://www.npmjs.com/package/p-limit), I'd like to thank the creator for the amazing work and maintenance. 