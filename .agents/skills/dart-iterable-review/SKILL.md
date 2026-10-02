---
name: dart-iterable-review
description: "Review Dart Iterable pipelines for lazy evaluation, repeated traversal, output order, allocation, and complexity when debugging or optimizing collection code."
---

# Dart Iterable Review

Source: Adapted for this template; see the [Dart iterable rules](../../../docs/rules/dart-language.md#8-iterable-pipelines).

## Trigger

Use when a task asks why a Dart collection prints a particular result, performs too many operations, allocates unexpectedly, or has unclear `Iterable` complexity.

## Review

- Identify the concrete collection type and every lazy or eager boundary.
- Mark terminal operations such as `toList`, `toSet`, `fold`, `reduce`, `first`, `single`, and `forEach`.
- Trace one element through the chain. Count callback invocations and collection passes separately; do not confuse multiple predicates with multiple full traversals.
- Predict observable output only after accounting for laziness and side effects. Treat `print` as a diagnostic example, never as production logging.
- Explain asymptotic complexity and allocation separately. A one-pass algorithm can still allocate, and an `O(n)` pipeline can have different constants from a manual loop.
- Recommend the smallest change: keep the lazy chain, add an intentional materialization boundary, cache a reusable result, choose a suitable collection, or write one explicit pass when the evidence justifies it.

## template Constraints

- Keep collection parsing sound and typed; do not introduce `dynamic` to simplify a pipeline.
- Preserve immutable model boundaries and `copyWith` semantics when changing collection code.
- Prefer readable pattern matching and exhaustive `switch` expressions over clever collection tricks.

## Output

Report:

1. the exact evaluation order;
2. callback and traversal counts;
3. complexity and allocation behavior;
4. the smallest safe alternative;
5. a focused test or executable example that falsifies the explanation.

## Validate

- Use a focused Dart test or a minimal DartPad reproduction for language behavior.
- Run `mise exec -- make format` and the smallest relevant test/check when code changes.
- Do not claim a performance improvement without a representative benchmark or profile.

## Related

- [`flutter-state-management`](../flutter-state-management/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/dart.md`](../../../docs/rules/dart.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
