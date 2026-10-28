import 'dart:async';

import 'package:l/l.dart';

/// Releases registered resources once, in reverse registration order.
mixin Disposable {
  Future<void> Function() _dispose = () async {};
  Future<void>? _disposing;

  /// Registers cleanup next to resource acquisition.
  void disposable(FutureOr<void> Function() fn) {
    if (_disposing != null) throw StateError('Resources are already being disposed.');
    final previous = _dispose;
    _dispose = () async {
      Object? firstError;
      StackTrace? firstStackTrace;
      try {
        await fn();
      } on Object catch (error, stackTrace) {
        firstError = error;
        firstStackTrace = stackTrace;
        l.w('Disposable | Failed to dispose a resource: $error', stackTrace);
      }
      try {
        await previous();
      } on Object catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;
      }
      final error = firstError;
      final stackTrace = firstStackTrace;
      if (error != null && stackTrace != null) Error.throwWithStackTrace(error, stackTrace);
    };
  }

  /// Awaits every cleanup, then rethrows the first failure with its stack trace.
  Future<void> dispose() {
    final pending = _disposing;
    if (pending != null) return pending;

    final cleanup = _dispose;
    _dispose = () async {};

    return _disposing = Future<void>.microtask(cleanup);
  }
}
