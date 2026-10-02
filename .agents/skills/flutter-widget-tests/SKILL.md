---
name: flutter-widget-tests
description: "Write, refactor, debug, or review template Flutter widget tests using WidgetTestUtil, feature scopes, deterministic fakes, fixtures, focused pumping, navigation harnesses, and UI state assertions."
---

# Widget Test Patterns

Source: Adapted for this template; derived from testing rules, `the existing test harness`, and existing widget tests.

## Inspect First

- Read `docs/rules/testing-preferences.md` and nearby tests under `test/src/widget_test/src/feature/<domain>/`.
- Inspect `test/widget_test.dart`, relevant scopes, fakes, and repository fixtures.
- Choose the smallest harness that exposes the behavior under test.

## Harness

- Use `WidgetTestUtil.createWidgetUnderTest(builder: ...)` from `test/src/util/test_util.dart` for localized app widgets. Use `WidgetTester.pumpScreen(...)` for isolated layout tests.
- Supply dependencies to the existing harness when settings/authentication scopes are needed; authenticated-only screens need an authenticated test user.
- Use the existing context/localization helpers for context-only assertions.
- Do not rebuild `MaterialApp`, localization, theme, settings, and auth scopes in each test.
- Prefer a small fixture page over a full route unless navigation or route behavior is the subject.

## Test Shape

- Group tests by behavior or state branch and use Arrange-Act-Assert or Given-When-Then.
- Assert rendered behavior and user outcomes, not private widget structure.
- Cover relevant loading, empty, error, disabled, permission, and success states.
- Prefer deterministic fakes and shared fixtures over mocks and large inline payloads.
- Use targeted `pump` calls; use `pumpAndSettle` only when the full animation queue must settle.
- Control animation timing and nested navigators explicitly to prevent incidental flakiness.
- For `InheritedModel` scopes, verify the relevant aspect observes or rebuilds for the expected state slice.

## Validation

- Run the smallest test file or feature-tagged entrypoint first.
- Run `mise exec -- make format` and `mise exec -- make check` after Dart test edits.
- Escalate to `mise exec -- make test-unit-all` for shared harnesses, app scopes, `packages/ui`, or cross-package behavior.

## Related

- [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
