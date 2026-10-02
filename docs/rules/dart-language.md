# Dart Language

Portable guidance adapted from the source application. Detailed SDK and project conventions remain in [Flutter rules](flutter.md), [Dart rules](dart.md), and [workflow rules](workflow.md).

## 1. Start from the contract

Define inputs, outputs, ownership, failure, cancellation, and platform support before selecting syntax or abstractions.

## 2. Sound types and null safety

Parse `Object?` using typed patterns. Avoid `dynamic`, unchecked casts, and null assertions at external boundaries. Distinguish missing, null, empty, and malformed values.

## 3. Immutable values and explicit state

Use immutable models and explicit state variants. Equality and hashCode must use the same fields; ordering must be deterministic. Copy collections at ownership boundaries.

## 4. Records and pattern matching

Use records for small local tuples and named models for durable domain contracts. Prefer exhaustive sealed-state switches and explicit JSON shape checks.

## 5. Futures streams and queues

A Future represents one result; a Stream represents repeated events. Observe errors and define completion. Broadcast streams do not replay missed state. Keep subscriptions with a lifecycle owner.

## 6. Sequencing and cancellation

Choose sequential, concurrent, restartable, or droppable work deliberately. A timeout does not cancel underlying work. Guard stale responses and close queues safely.

## 7. Isolates and CPU work

Measure CPU work first. Define message types, transferable data, cancellation, error forwarding, watchdogs, and worker shutdown. Web execution can differ from native isolates.

## 8. Iterable pipelines

Lazy iterables recompute on traversal. Materialize only at an intentional ownership or reuse boundary. Check complexity, repeated scans, side effects, ordering, and allocation before rewriting a pipeline.

## 9. Extension types for constrained primitives

Use extension types when static separation of primitives helps a real contract. They are not runtime validation or a substitute for parsing.

## 10. Errors and boundaries

Malformed payloads become FormatException. Preserve typed transport failures and stack traces; let the UI owner decide recovery. Do not silently convert every error to empty data.

## 11. Resource ownership

Every subscription, controller, timer, stream, file handle, and isolate has an owner. Release in reverse acquisition order, including partial initialization failure. Test dispose during pending work.

## 12. Package policy

Compare dependencies with SDK and existing template primitives. Inspect source, maintenance, licensing, transitive dependencies, supported platforms, and failure behavior; verify versioned claims.

## 13. Dart review checklist

Check contracts, exhaustiveness, equality, async errors, cancellation, disposal, complexity, and focused tests. Profile runtime claims in the target build mode.
