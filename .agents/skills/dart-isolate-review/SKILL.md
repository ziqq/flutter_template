---
name: dart-isolate-review
description: "Review Dart isolate concurrency, message ownership, spawning, cancellation, error handling, and watchdog behavior in Flutter or Dart code."
---

# Dart Isolate Review

Source: Adapted for this template; informed by the author's Dart isolate analysis.

## Trigger

Use when code moves CPU-heavy work off the UI isolate, creates an `Isolate`, uses `Isolate.run`/`compute`, coordinates ports, or needs watchdog and cancellation behavior.

## Review

- State why an isolate is needed: CPU contention, heavy synchronous parsing/decoding, blocking native work, throughput,
  or a measured frame problem. Ordinary asynchronous I/O alone does not require an isolate; verify Flutter Web semantics
  before assuming a separate UI thread.
- Treat each isolate as an independent heap. Do not assume a singleton, notifier, open database handle, controller, or mutable object is shared across isolates.
- Define the message protocol: accepted input, output, error, shutdown, timeout, cancellation, ordering, and backpressure.
- Send transferable or safely serializable data. Do not pass UI objects, `BuildContext`, platform-bound handles, or feature controllers into worker code.
- Own `ReceivePort`, `SendPort`, subscriptions, and the isolate lifecycle in one coordinator. Close ports and kill the isolate at the correct priority on success, error, timeout, and dispose.
- Add a watchdog only with a stated timeout and recovery policy. A timeout must not leave an orphan isolate or allow a late result to overwrite newer state.
- Keep parsing and domain mapping typed at the boundary; return a structured success/failure result instead of throwing unobservable errors across a port.

## Output

Report the concurrency reason, isolate/message lifecycle, ownership, data-transfer cost, cancellation path, stale-result risk, and the smallest safe design.

## Validate

- Test success, worker exception, startup failure, timeout, cancellation, late result, port closure, and widget/app disposal.
- Measure serialization and startup cost with representative payloads before claiming a speedup.
- Run focused tests and `mise exec -- make check` when shared infrastructure is affected.

## Related

- [`dart-async-review`](../dart-async-review/SKILL.md)
- [`quality-evidence-review`](../quality-evidence-review/SKILL.md)
- [`flutter-rendering-performance-review`](../flutter-rendering-performance-review/SKILL.md)
- [`flutter-widget-lifecycle-review`](../flutter-widget-lifecycle-review/SKILL.md)
