---
name: flutter-feature-module
description: "Use when: adding, changing, or reviewing AppOrOrgName feature modules under lib/src/feature with model, data, controller, widget, scope, fake repository, tests, and docs updates."
---

# Flutter Feature Module

Source: AppOrOrgName-native; derived from `AGENTS.md`, `CLAUDE.md`, `docs/rules/architecture.md`, `docs/rules/flutter.md`, `docs/rules/models.md`, and existing `lib/src/feature/**` modules.

Use this skill for feature-level work that crosses model, data, controller, widget, scope, tests, or docs. Keep edits scoped to the feature unless a shared abstraction already exists or the repeated pattern is proven.

## First Sources To Inspect

- Existing feature folder: `lib/src/feature/<domain>/`.
- Feature docs: `docs/features/<feature>.md` when present.
- `docs/rules/architecture.md` for layering and repository conventions.
- `docs/rules/flutter.md` for controller, scope, and widget rules.
- `docs/rules/models.md` for immutable models, JSON parsing, and enums.
- Nearby tests under `test/unit_test/src/feature/<domain>/` and `test/widget_test/src/feature/<domain>/`.

## Folder Shape

Standard feature structure:

- `controller/` for orchestration, async mutation flow, and UI-facing state.
- `data/` for repositories, data sources, adapters, and persistence boundaries.
- `model/` for immutable domain and transport-safe entities.
- `widget/` for rendering, user interaction, and feature scopes.

Shared cross-cutting code belongs in `lib/src/common` or packages only when multiple features already need the same concept.

## Layer Rules

- Models know how to parse and serialize domain data.
- Repositories hide transport and persistence and expose caller-oriented methods.
- Controllers orchestrate operations and state transitions; they should not depend on other controllers or read foreign controller state.
- Widgets render state, dispatch user actions, and own lifecycle-bound listeners that coordinate scopes or platform streams.
- Feature scopes expose controllers and selected state slices through `InheritedModel` aspects.
- Do not reach across features through widget-tree shortcuts; use constructor DI, scope accessors, or shared dependencies.

## Controller Pattern

- Use `AppController$Sequential<TState>` for complex async flows.
- Use sealed immutable states with idle, processing, and failed variants.
- Preserve previous useful data while moving into processing or failed state when the UI should not blank out.
- Use `handle(...)` with meaningful operation names and metadata.
- Keep callbacks such as `onProcessing`, `onSucceeded`, `onError`, and `onDone` only when callers genuinely need lifecycle hooks.
- Avoid hidden global state and controller-to-controller coupling.

## Scope Pattern

- Place feature scopes at `lib/src/feature/<domain>/widget/<domain>_scope.dart`.
- Use a public `<Feature>Scope`, private state, private inherited model, and private aspect enum.
- Static helpers should accept `{bool listen = true}`.
- `of(context)` should return the controller without subscribing when possible.
- Typed accessors should subscribe only to the aspect they need.
- Diff previous and next state before calling `setState` in the scope listener.

## Models And Repositories

- Keep models immutable with `const` constructors where possible.
- Parse JSON through typed pattern matching and throw `FormatException` for invalid payloads.
- Do not use `dynamic` in parsing.
- Use explicit enum `fromValue` switches.
- Repositories should have `I<Name>Repository`, `<Name>Repository`, and `$Fake` implementations when tests or fake mode need them.
- Prefer `ApiClient$HTTP` for new and migrated repositories, following `repository-http-client` rules.

## Widgets

- Prefer small private widget classes over private methods returning widgets.
- Keep widgets immutable and move expensive work out of `build()`.
- Use `package:ui/ui.dart`, `UITheme`, and `UIColors` before local styling.
- Cover initial, loading, empty, error, disabled, and success states.
- Keep UI dense and scannable for CRM/business workflows; avoid decorative detours.

## Tests And Docs

- Add unit tests for models, repositories, and controller state transitions when behavior changes.
- Add widget tests for scopes, rendering branches, and user actions using `WidgetTestUtil`.
- Keep fake repositories and JSON fixtures aligned.
- Update `docs/features/<feature>.md` when behavior, workflow, edge cases, or user-visible contracts change.
- Use `verify-changes` to choose focused tests first, then escalate based on blast radius.

## Related

- [`repository-http-client`](../repository-http-client/SKILL.md)
- [`widget-test-patterns`](../widget-test-patterns/SKILL.md)
- [`ui-design-system`](../ui-design-system/SKILL.md)
- [`verify-changes`](../verify-changes/SKILL.md)
- [`docs/rules/architecture.md`](../../../docs/rules/architecture.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/models.md`](../../../docs/rules/models.md)
