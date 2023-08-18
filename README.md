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
  // Only one promise is run at once
  final results = await Future.wait(input);
  print(results);

  limit.
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

Returns the promise returned by calling `fn()`.

#### fn

Type: `Function`

Promise-returning/async function.

### limit.activeCount

The number of promises that are currently running.

### limit.pendingCount

The number of promises that are waiting to run (i.e. their internal `fn` was not called yet).

### limit.clearQueue()

Discard pending promises that are waiting to run.

This might be useful if you want to teardown the queue at the end of your program's lifecycle or discard any function calls referencing an intermediary state of your app.

Note: This does not cancel promises that are already running.

## FAQ

### How is this different from the [`async_task`](https://github.com/eneural-net/async_task) package?

This package is only about limiting the number of concurrent executions, while `async_task` is a fully featured queue implementation similar to classic thread pools and with lots of different options.

## Related

- [async_task](https://github.com/eneural-net/async_task) - Asynchronous tasks and parallel executors

## Additional information

If you have an issue, let me know on [Github issues](https://github.com/hunterwilhelm/p_limit/issues)