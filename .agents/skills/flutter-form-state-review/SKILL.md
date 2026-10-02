---
name: flutter-form-state-review
description: "Review Flutter forms built from SDK Listenable primitives, including cross-field validation, controller ownership, focused rebuilds, and async field state."
---

# Flutter Form State Review

Source: Adapted for this template; informed by the author's SDK-native form-state analysis.

## Trigger

Use when a form combines text, focus, checkbox, selection, validation, custom field, or search state, or when a team proposes a form-management dependency.

## Default Shape

- Start with Flutter SDK primitives: `TextEditingController`, `FocusNode`, `ValueNotifier<T>`, `ChangeNotifier`, `Listenable.merge`, `ListenableBuilder`, and `ValueListenableBuilder`.
- Merge field listenables when one form-level validation or preview depends on several fields. The merged listenable observes its inputs; it does not own or dispose them.
- Keep cross-field validation in one explicit form-level function or controller so rules such as password confirmation are not scattered across widget builders.
- Use the smallest rebuild boundary: a submit button should listen to validity, an error banner to its error value, and a preview only to the combined state it needs.
- Use `AppController$Sequential` when submission or server mutation is a feature workflow. Do not turn every local field into an application controller.

## Review

- Identify the owner and disposal path for every controller, notifier, focus node, subscription, and debounce timer.
- Run initial validation once after all field controllers are wired, then update state from a controlled listener. Avoid feedback loops where validation writes to a field that immediately retriggers validation without a guard.
- Keep validation pure where possible. Separate validation results from submission side effects and server errors.
- For async custom fields, define debounce, cancellation, stale-result handling, loading, and error behavior before connecting them to the merged form listener.
- Check that focus changes are intentionally included. A `FocusNode` can drive hints and semantics, but should not cause the whole form to rebuild accidentally.
- Do not reject a package merely because it exists; reject it when it adds a second state model, code generation, or widget coupling without closing a demonstrated gap.
- Cover keyboard, localization, text scale, autofill, restoration, disabled/loading submission, and accessibility semantics through the existing UI rules.

## Output

Report the field-state graph, ownership/disposal table, validation boundary, rebuild scopes, async race behavior, and package decision. Include the smallest focused widget or controller test that can falsify the review.

## Validate

- Test initial validity, each cross-field rule, correction after an error, focus-driven UI, controller disposal, and submit loading/error/success.
- Test that stale async field results cannot overwrite newer input.
- Use the existing `pumpScreen` harness, feature Scopes, and deterministic fakes from `flutter-widget-tests`.
- Run `mise exec -- make format` and the focused feature tests.

## Related

- [`flutter-state-management`](../flutter-state-management/SKILL.md)
- [`flutter-state-layer-review`](../flutter-state-layer-review/SKILL.md)
- [`flutter-widget-lifecycle-review`](../flutter-widget-lifecycle-review/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`dart-package-audit`](../dart-package-audit/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
