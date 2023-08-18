<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Install

```
$ flutter pub add p_limit
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

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
