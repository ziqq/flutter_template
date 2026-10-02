---
name: flutter-state-management
description: "Choose, build, and review template Flutter state: AppController$Sequential controllers, sealed idle/processing/succeeded/failed states, StateConsumer, feature Scope InheritedModel aspects, and ValueNotifier/ChangeNotifier for local widget state."
---

# Flutter State Management

Source: Adapted for this template; derived from `docs/rules/flutter.md` (State Management, Scope), `lib/src/common/controller/app_controller.dart`, `package:control`, existing feature controllers, states, and scopes, and the author's SDK-native form-state analysis.

## Inspect First

- Read `docs/rules/flutter.md` sections **State Management** and **Scope (InheritedModel) Pattern** — the canonical templates live there.
- Read `lib/src/common/controller/app_controller.dart` for `AppController$Sequential` / `AppController$Concurrent` (Sentry-wrapped `StateController` from `package:control`).
- Inspect a nearby feature with the same interaction shape: controllers in `lib/src/feature/<domain>/controller/`, scopes in `lib/src/feature/<domain>/widget/<domain>_scope.dart`.
- Reference `reviews`, `client`, `calendar`, `settings`, and `notification` for style.
- No third-party state libraries. State primitives are Flutter built-ins plus `package:control`.

## Choose The Right Tool

Escalate from the cheapest primitive that fits:

| Situation | Use |
|---|---|
| One ephemeral value, single widget | `ValueNotifier<T>` + `ValueListenableBuilder` |
| Simple shared state, no async flow | `ChangeNotifier` + `ListenableBuilder` |
| Async fetch/mutate/batch flows with idle/processing/succeeded/failed | `AppController$Sequential<TState>` + `StateConsumer` |
| Feature-wide state injected into the widget tree | one feature **Scope** (`InheritedModel` + aspects) owning the controller |

For a complex local form, merge its field listenables with `Listenable.merge` and keep validity/error state close to the form. Read [`flutter-form-state-review`](../flutter-form-state-review/SKILL.md) before introducing a form package or promoting field state to an application controller.

Separate ephemeral widget state from application state. Do not reach for a controller when a `ValueNotifier` is enough, and do not thread controller instances through constructors when a Scope already publishes the state.

## Controllers

- Extend `AppController$Sequential<TState>` (sequential handler; `$Concurrent` exists but is currently unused — justify before choosing it).
- Seed `initialState` with the `idle` variant and pass a stable `name` (used for Sentry tags and logs).
- Run every async workflow through `handle(() async {…}, error:, done:, name:, meta:)`. Call `setState(...)` with a new immutable state; never mutate state in place.
- Return the Future from `handle` so callers can await completion. Add optional progress/result callbacks only when an actual caller needs them; preserve the existing controller contract.
- Format error messages with `ErrorUtil.formatMessage(e)`; keep `error` / `stackTrace` on the failed state.
- On failure, preserve the previous successful `data` when the contract restores idle with old data.
- **Controller boundaries:** do not inject one controller into another or read a foreign controller's state inside a controller. Cross-controller orchestration, platform stream subscriptions, and lifecycle-bound listeners belong in a widget or Scope with explicit `initState` / `dispose`.

## Sealed State

- `sealed class FooState extends _$FooStateBase` with `const factory` variants `idle` / `processing` / `succeeded` / `failed`; each concrete `final class FooState$Idle/...` overrides `type`.
- Keep an `@immutable abstract base class _$FooStateBase` holding shared fields (`data`, `message`, `error`, `stackTrace`), boolean flags (`isProcessing`/`isFailed`/`isIdle`), and `map` / `maybeMap` / `mapOrNull` matchers with an exhaustive `switch`.
- **`==` / `hashCode` contract:** use the same comparison semantics in both. `listEquals` ↔ `Object.hashAll`; `mapEquals` ↔ order-independent hashing; `identical(data, ...)` ↔ hash the `data` object itself, not its deep contents. Never mix shallow and deep semantics for one field.
- `message` is usually diagnostic. If it is excluded from `==`, exclude it from `hashCode` too.

## StateConsumer

- Render with `StateConsumer<FooController, FooState>(controller:, buildWhen:, builder:, listener:)`.
- Use `buildWhen` to rebuild only on the slice that matters (e.g. `previous.data != current.data`); use `listener` for one-shot side effects (snackbars, navigation), not rebuilds.
- Fan out UI with `state.map(idle:, processing:, succeeded:, failed:)` so every variant is handled.

## Scope (InheritedModel) Pattern

Publish feature state to the subtree through one Scope per feature. Follow the template in `docs/rules/flutter.md` exactly.

- Naming: `<Feature>Scope` (public `StatefulWidget`), `_<Feature>ScopeState`, `_Inherited<Feature>` (`InheritedModel<_<Feature>Aspect>`), `_<Feature>Aspect` (private enum).
- Aspect mapping: `none` → `getInheritedWidgetOfExactType` (read-only, for commands/writes); `state` → `dependOnInheritedWidgetOfExactType` (rebuild on any change); named slices → `InheritedModel.inheritFrom` with per-aspect checks in `updateShouldNotifyDependent`.
- Static helpers: `static T fooOf(BuildContext context, {bool listen = true})` where `listen: false` passes `_Aspect.none` and `listen: true` passes the matching aspect. `of(context)` returns the controller without subscribing. Command helpers delegate straight to the controller.
- `_onStateChanged` guards `if (!mounted) return;` and skips `setState` when the next state is `identical` to the cached one.
- Prefer `identical` for reference-equal checks; use `==` / `DeepCollectionEquality` only when the controller can emit structurally-equal but referentially-different objects.
- Out-of-scope lookup throws `ArgumentError(..., 'out_of_scope')` via `_notFoundInheritedWidgetOfExactType`.
- **One scope per feature.** Cross-feature data flows through constructor DI or a shared `Dependencies` object — never by nesting scopes inside each other's `build`.

## Tests

- Cover controller `name`, initial state, success path, failure path (previous data preserved), callback order, and the state visible during each callback.
- Test state derived getters, boolean flags, and `map` / `maybeMap` / `mapOrNull`; add `==` / `hashCode` / `toString` assertions only when that behavior is intentional and used downstream.
- Follow the controller/state template in `docs/rules/testing-preferences.md` and `flutter-widget-tests` for Scope/consumer widget tests. Prefer deterministic `$Fake` repositories over mocks.

## Completion

- Run `mise exec -- make format` before validation. Use `project-verify-changes` to pick the smallest falsifying check (`make test-feature FEATURE=<feature>`), then escalate by blast radius.
- Update feature docs when durable state shape, workflow, or contracts change.

## Related

- [`flutter-feature-module`](../flutter-feature-module/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md)
- [`flutter-repository-http-client`](../flutter-repository-http-client/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/architecture.md`](../../../docs/rules/architecture.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
