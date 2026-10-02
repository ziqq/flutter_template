---
name: dart-resource-lifecycle-review
description: "Review Dart and Flutter multi-step initialization, cancellation, rollback, and deterministic resource cleanup across async workflows."
---

# Dart Resource Lifecycle Review

Source: Adapted for this template; informed by the author's closure-chain resource-cleanup analysis.

## Trigger

Use when a workflow opens, subscribes to, starts, or allocates several resources and can fail or be cancelled before initialization completes. Typical resources include database handles, transactions, sockets, stream subscriptions, timers, controllers, and platform listeners.

## Review

- List every acquired resource, its owner, the acquisition point, and the matching cleanup action.
- Verify that cleanup covers only resources successfully acquired and runs in reverse dependency order.
- Prefer an explicit local cleanup scope for sequential initialization. A closure chain is acceptable when LIFO order, double-dispose protection, and composition are more valuable than inspectability; use a list or dedicated scope object when cleanup diagnostics or replacement are important.
- Make cleanup idempotent. Cancellation, error handling, normal completion, and widget disposal must not dispose the same resource twice.
- Check cancellation between awaited initialization steps and connect cancellation to teardown before entering a long-lived stream or socket phase.
- Distinguish rollback cleanup from commit cleanup. After a transaction commits, replace or disable rollback before the scope is closed.
- Ensure one cleanup failure does not prevent later cleanup. Preserve the original operation error and report cleanup failures deliberately instead of silently replacing the root cause.
- Do not apply a sequential cleanup pattern unchanged to parallel initialization. `Future.wait` needs explicit coordination for resources that may finish after a sibling has failed.

## Flutter Ownership

- Controllers, `FocusNode`, `TextEditingController`, animation tickers, subscriptions, and overlays need exactly one disposal owner.
- Widget-owned resources are created and disposed with the widget lifecycle; feature-owned resources follow the Scope/controller contract in `docs/rules/flutter.md`.
- Check `mounted` before late asynchronous callbacks touch widget state, but do not use `mounted` to hide an ownership or cancellation bug.

## Output

Report the acquisition graph, cleanup order, cancellation window, double-dispose risk, error-preservation behavior, and the smallest safe correction. State whether the flow is sequential or parallel.

## Validate

- Test failure after each meaningful initialization step.
- Test cancellation before, during, and after long-lived subscriptions.
- Test normal commit, rollback, repeated cleanup, and cleanup where one action throws.
- Run `mise exec -- make format`, the focused test, and the smallest applicable check selected by `project-verify-changes`.

## Related

- [`dart-async-review`](../dart-async-review/SKILL.md)
- [`flutter-widget-lifecycle-review`](../flutter-widget-lifecycle-review/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
