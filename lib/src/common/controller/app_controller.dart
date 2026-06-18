/*
 * Date: 1 August 2025
 */

import 'package:control/control.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class _AppContextContainer {
  ISentrySpan? transaction;
}

/// Return the current transaction from the context
ISentrySpan? get $currentSentryTransaction =>
    switch (HandlerContext.zoned()?.meta['_@container']) {
      _AppContextContainer container => container.transaction,
      _ => null,
    } ??
    Sentry.getSpan();

/// Default [StateController] for use with your app.
/// This controller is used to manage the application state.
base class AppController$Sequential<S extends Object> extends StateController<S> with SequentialControllerHandler {
  AppController$Sequential({required super.initialState, required this.name});

  @override
  final String name;

  @override
  Future<void> handle(
    Future<void> Function() handler, {
    Future<void> Function(Object e, StackTrace s)? error,
    Future<void> Function()? done,
    String? name,
    Map<String, Object?>? meta,
  }) async {
    final container = _AppContextContainer(); // ignore: unused_local_variable
    return super.handle(
      () async {
        // Start transaction
        /* container.transaction =
            Sentry.startTransaction(
                // name
                this.name, // 'controller'
                // operation
                '${this.name}.$name',
                bindToScope: true,
                startTimestamp: DateTime.now().toUtc(),
              )
              ..setTag('controller', this.name)
              ..setTag('handler', name ?? 'unknown'); */
        await handler();
      },
      error: (e, s) async {
        // Handle error
        await error?.call(e, s);
        // final span = container.transaction;
        // if (span != null && !span.finished) span.throwable = e; // Add error to span
      },
      done: () async {
        // End transaction
        await done?.call();
        // final span = container.transaction;
        // if (span != null && !span.finished) span.finish().ignore();
      },
      name: name,
      meta: meta,
    );
  }
}

/// Concurrent [StateController] for use with your app.
/// This controller is used to manage the application state.
base class AppController$Concurrent<S extends Object> extends StateController<S> with ConcurrentControllerHandler {
  AppController$Concurrent({required super.initialState, required this.name});

  @override
  final String name;

  @override
  Future<void> handle(
    Future<void> Function() handler, {
    Future<void> Function(Object e, StackTrace s)? error,
    Future<void> Function()? done,
    String? name,
    Map<String, Object?>? meta,
  }) async {
    final container = _AppContextContainer(); // ignore: unused_local_variable
    return super.handle(
      () async {
        // Start transaction
        /* container.transaction =
            Sentry.startTransaction(
                // name
                this.name, // 'controller'
                // operation
                '${this.name}.$name',
                bindToScope: true,
                startTimestamp: DateTime.now().toUtc(),
              )
              ..setTag('controller', this.name)
              ..setTag('handler', name ?? 'unknown'); */
        await handler();
      },
      error: (e, s) async {
        // Handle error
        await error?.call(e, s);
        // final span = container.transaction;
        // if (span != null && !span.finished) span.throwable = e; // Add error to span
      },
      done: () async {
        // End transaction
        await done?.call();
        // final span = container.transaction;
        // if (span != null && !span.finished) span.finish().ignore();
      },
      name: name,
      meta: meta,
    );
  }
}
