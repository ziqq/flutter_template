---
name: widget-test-patterns
description: "Use when: writing, refactoring, or reviewing AppOrOrgName widget tests, WidgetTestUtil harnesses, scope tests, fakes, fixtures, and UI state assertions."
---

# Widget Test Patterns

Source: AppOrOrgName-native; derived from `docs/rules/testing-preferences.md`, existing `test/widget_test/**` patterns, `WidgetTestUtil`, and repository memory about widget-test pitfalls.

Use this skill when a change needs widget coverage or when a widget test is flaky, over-scoped, or using a hand-rolled app harness.

## First Sources To Inspect

- `docs/rules/testing-preferences.md` for baseline testing rules.
- `test/widget_test.dart` for the app widget-test entrypoint.
- Nearby tests under `test/widget_test/src/feature/<domain>/` before inventing a new shape.
- Existing scope tests such as `employees_scope_test.dart` or client/client-notification tests when testing feature scopes.
- `test/unit_test/src/feature/<domain>/data/fixtures/*.json` when fake repositories or transport fixtures are involved.

## Harness Rules

- Prefer `WidgetTestUtil.createWidgetUnderTest(...)` for normal widget tests.
- Use `WidgetTestUtil.appContext(...)` when the widget needs project dependencies, settings, authentication, or app scopes.
- Use `WidgetTestUtil.getContextUnderTest(...)` or `WidgetTestUtil.getLocalizationsAndContextUnderTests(...)` for context-only and localization-only assertions.
- Do not hand-roll `MaterialApp`, localization delegates, UI theme, settings scope, or authentication scope in each test.
- Local helpers may wrap `WidgetTestUtil`, but should stay small and named after the behavior under test.
- Prefer a small test page or fixture widget over a real feature screen unless the real screen behavior is what the test verifies.

## Test Shape

- Group tests semantically by the method, getter, state branch, or widget behavior under test.
- Use Given-When-Then or Arrange-Act-Assert structure.
- Assert behavior and rendered state, not implementation details such as private widget structure.
- Test loading, empty, error, disabled, and success branches when the widget exposes them.
- Prefer deterministic fakes/stubs over mocks; keep mocks minimal when they are unavoidable.
- Keep pump/settle calls purposeful. Avoid broad `pumpAndSettle` loops when a targeted `pump` is enough.
- When testing nested navigators, put the nested navigator in normal page content rather than app bar/action slots to avoid accidental toolbar `Hero` behavior.

## Scope Tests

- Use scope static helpers with `{listen: false}` when asserting state from a captured context.
- Verify command helpers delegate to the controller only when that is the behavior under test.
- For `InheritedModel` aspects, prefer tests that prove the relevant subscriber rebuilds or observes the expected state slice.
- Keep controller orchestration out of widget tests unless the widget owns lifecycle wiring that cannot be tested at a lower layer.

## Fixtures And Fakes

- Align fake repository payloads with JSON fixtures used by repository tests so app fakes and mocked transport responses drift together.
- Prefer getter-based `MockService` fixtures for static data. Use builder methods only when variable input is genuinely part of the scenario.
- Avoid duplicating large payloads inline in widget tests; import fixtures or fakes already used by the feature.
- If a fake needs multiple backend-like responses, follow the larger fake repository patterns such as `SaleRepository$Fake`.

## Focused Validation

- For one feature, prefer `fvm flutter test --tags="<feature>" test/unit_test.dart test/widget_test.dart` when the tag exists.
- For an isolated widget file, run the smallest test file or entrypoint that covers it before escalating.
- Run `make format` and `make check` after Dart test edits.
- Escalate to `make test-unit-all` when shared test utilities, `packages/ui`, app scopes, or cross-package behavior changes.

## Common Failure Modes

- Creating a fresh app shell per test instead of using `WidgetTestUtil`.
- Testing navigation or toolbar behavior accidentally while trying to test a feature widget.
- Letting fake repositories diverge from repository fixtures.
- Depending on animation timing without controlling frames.
- Missing assertions for disabled/error/empty states.
- Using route-level harnesses when a small local widget would cover the behavior.

## Related

- [`verify-changes`](../verify-changes/SKILL.md)
- [`ui-design-system`](../ui-design-system/SKILL.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
