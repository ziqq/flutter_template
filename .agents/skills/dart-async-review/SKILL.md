---
name: dart-async-review
description: "Choose and review Dart asynchronous primitives, streams, queues, Pub/Sub flows, cancellation, errors, and lifecycle ownership in Flutter features."
---

# Dart Async Review

Source: Adapted for this template; see the [Dart async rules](../../../docs/rules/dart-language.md#5-futures-streams-and-queues).

## Trigger

Use when a task involves `Future`, `Stream`, `StreamController`, `Queue`, event buses, Pub/Sub, subscriptions, or asynchronous coordination between Flutter objects.

## Choose The Primitive

- Use `Future` for one result or one completion/failure.
- Use `Stream` for an ordered sequence of events that consumers can observe over time.
- Use `Queue` for owned work items that one coordinator must drain; do not expose it as a substitute for an event stream.
- Use `StreamController` only when the producer owns a clear lifecycle and the stream's single-subscription or broadcast semantics are deliberate.
- Use `ValueNotifier`/`ChangeNotifier` for local synchronous state, not as a replacement for an event protocol.

## Review

- Identify the producer, consumers, ownership, and lifecycle of every subscription.
- Check whether a stream is single-subscription or broadcast, whether late subscribers are expected to receive history, and whether events can be dropped or duplicated.
- Verify cancellation in `dispose`, error propagation, completion behavior, reentrancy, and ordering under concurrent producers.
- Separate state snapshots from commands/events. Do not make a controller read another controller's state or coordinate controllers through hidden callbacks.
- Keep cross-controller orchestration, platform listeners, and lifecycle-bound subscriptions in a widget, Scope, or composition root with explicit start/stop ownership.
- Ask whether a finite queue, a state controller, or a stream is the simplest correct model before adding an event bus.

## Output

Report the event contract, ownership diagram in prose, lifecycle holes, ordering/error risks, and the smallest safe replacement. Include a focused test for cancellation, ordering, duplicate delivery, and failure where applicable.

## Validate

- Prefer deterministic fakes and a controlled event source.
- Test subscription setup and disposal, not only the happy-path values.
- Run `mise exec -- make format`, focused tests, and the smallest applicable `make check` gate for code changes.

## Related

- [`flutter-state-management`](../flutter-state-management/SKILL.md)
- [`flutter-state-layer-review`](../flutter-state-layer-review/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`docs/rules/dart.md`](../../../docs/rules/dart.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
