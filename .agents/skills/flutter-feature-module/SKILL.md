---
name: flutter-feature-module
description: "Add, change, or review template feature modules under lib/src/feature, including models, repositories, controllers, widgets, scopes, deterministic fakes, fixtures, tests, and feature documentation."
---

# Flutter Feature Module

Source: Adapted for this template; derived from feature implementations and architecture, Flutter, model, testing, and UI rules.

## Inspect First

- Read `docs/features/<feature>.md` when present.
- Read `docs/rules/architecture.md`, `docs/rules/flutter.md`, `docs/rules/models.md`, and relevant UI/testing rules.
- Inspect the existing feature folder and a nearby feature with the same interaction shape.
- Check server documentation and backend code before changing endpoint assumptions.

## Boundaries

- `model/`: immutable domain values, explicit parsing, enums, and `copyWith`.
- `data/`: repository interfaces, implementations, transport/persistence mapping, fakes, and fixtures.
- `controller/`: workflow orchestration and sealed idle/processing/failed states through `AppController$Sequential`.
- `widget/`: rendering, user input, scopes, and navigation without parsing or transport work.

Keep cross-feature dependencies explicit through constructors, scopes, or established shared packages. Do not reach across features through widget-tree shortcuts or create a shared abstraction before repeated ownership is proven.

## Implementation Rules

- Prefer `IFooRepository`, `FooRepository`, and `FooRepository$Fake` when the feature owns a repository contract.
- Prefer `ApiClient$HTTP` only for compatible JSON-object endpoints; retain legacy Dio for unsupported response contracts.
- Parse `Object?` with pattern matching and throw `FormatException` for malformed data; do not use `dynamic`.
- Parse enums with explicit `fromValue` switches, never `name` or `values.byName`.
- Keep models immutable and widgets small, const, and free of expensive orchestration in `build()`.
- Use one feature scope based on the established `InheritedModel` aspect pattern.
- Reuse `packages/ui` for theme, components, loading, empty, error, and disabled states.

## Completion

- Update fakes and fixtures with repository/model changes.
- Add focused model, data, controller, scope, and widget tests for changed behavior.
- Update feature docs for durable behavior, workflow, edge cases, or contracts.
- Use `project-verify-changes` to select checks and escalation.

## Related

- [`flutter-repository-http-client`](../flutter-repository-http-client/SKILL.md)
- [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/architecture.md`](../../../docs/rules/architecture.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/models.md`](../../../docs/rules/models.md)
