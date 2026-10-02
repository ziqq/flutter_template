---
name: flutter-widget-lifecycle-review
description: "Review Flutter StatefulWidget lifecycle, BuildContext lookups, inherited dependencies, widget updates, subscriptions, and disposal for ordering and stale-state bugs."
---

# Flutter Widget Lifecycle Review

Source: Adapted for this template; see the [Flutter lifecycle rules](../../../docs/rules/flutter-patterns.md#8-lifecycle-and-navigation)
and canonical Flutter rules.

## Trigger

Use when code reads `widget` or `BuildContext` in lifecycle methods, subscribes to inherited state or streams, owns a controller, or behaves incorrectly after its configuration changes.

## Review Order

- In `initState`, allow access to the initial `widget` configuration and initialize objects that do not require inherited dependencies.
- Do not establish subscriptions through inherited lookups such as `MediaQuery`, `Theme`, or a feature Scope in `initState`. Move dependency-based setup to `didChangeDependencies` and make it idempotent.
- When a constructor value from `widget` affects an owned object, compare old and new values in `didUpdateWidget` and update or recreate the object deliberately.
- Cancel subscriptions, dispose controllers, and detach listeners in `dispose`; ensure every ownership path has exactly one disposal owner.
- Check `mounted` before asynchronous callbacks update widget-owned state.
- Distinguish widget configuration, Element identity, State-owned mutable data, and RenderObject layout/paint state. Do not repair a layer-boundary problem with another lifecycle callback.

## Output

Report the lifecycle owner, the earliest valid initialization point, update/replacement behavior, disposal path, and any stale-context or duplicate-listener risk. Provide the smallest focused widget test that exercises configuration replacement and teardown.

## Validate

- Use the existing `pumpScreen` harness and existing feature scopes; do not hand-roll app infrastructure.
- Test initial mount, dependency change, widget configuration replacement, unmount, and late async completion where relevant.
- Run `mise exec -- make format` and the focused widget test.

## Related

- [`flutter-state-management`](../flutter-state-management/SKILL.md)
- [`flutter-state-layer-review`](../flutter-state-layer-review/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
