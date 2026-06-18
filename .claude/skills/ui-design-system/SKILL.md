---
name: ui-design-system
description: "Use when: building, refactoring, or reviewing AppOrOrgName Flutter UI with packages/ui components, theme, icons, layout, accessibility, loading, empty, and error states."
---

# UI Design System

Source: AppOrOrgName-native; adapted from AppOrOrgName `packages/ui`, `docs/rules/ui.md`, `docs/rules/flutter.md`, selected ideas from UI UX Pro Max, Awesome DESIGN.md, Impeccable, and MDN ARIA translated into Flutter concerns.

Use this skill for UI implementation and UI review. The goal is not generic visual polish; the goal is to build screens that feel native to AppOrOrgName and reuse the app's own UI kit.

## First Sources To Inspect

- `packages/ui/lib/ui.dart` for public exports.
- `packages/ui/lib/src/theme/` for `UIThemeData`, `UITheme`, `UIColors`, typography, sizes, gradients, and theme helpers.
- `packages/ui/lib/src/widgets/_widgets.dart` for reusable widgets.
- `packages/ui/lib/src/widgets/layouts/` for app layout primitives.
- `packages/ui/lib/src/widgets/inputs/` for text, phone, password, search, and price input patterns.
- `packages/ui/lib/src/widgets/loaders/` for loading indicators and overlays.
- `packages/ui/lib/src/widgets/chips/`, `pickers/`, `sheets/`, `cupertino/`, `images/`, `icons/`, and `text/` before creating new variants.
- Existing feature widgets under `lib/src/feature/<domain>/widget/` for local screen composition examples.

## Core Rules

- Prefer `package:ui/ui.dart` exports over direct one-off Flutter styling.
- Use `UITheme.of(context)`, `Theme.of(context).uiTheme`, and `UIColors.of(context)` instead of hard-coded colors.
- Keep widgets immutable and compose complex UI from smaller private widget classes.
- Use project widgets for app bars, inputs, chips, pickers, sheets, avatars, loaders, grouped lists, images, and empty states before introducing local alternatives.
- Preserve responsive behavior across supported mobile, tablet, and desktop/web sizes where the screen is reachable.
- Avoid network calls, parsing, expensive work, and controller orchestration inside `build()`.
- Do not introduce new dependencies or visual systems for one screen unless the existing UI kit cannot support the requirement.

## Design Context

Borrow the useful part of DESIGN.md-style workflows: make the visual source of truth explicit and reusable.

- Treat `packages/ui` plus `docs/rules/ui.md` as the current AppOrOrgName design context.
- If the team later adds a dedicated `DESIGN.md`, read it before UI work and keep this skill pointed at it.
- For feature-specific UI exceptions, document only the exception in the feature doc instead of forking the design system in code.
- Before building a new UI surface, inspect nearby feature widgets and shared UI package examples for the local visual vocabulary.
- Do not generate a fresh palette, type scale, or component family unless the project intentionally changes its design system.

Use this lifecycle for non-trivial UI work:

1. Inspect local context: `packages/ui`, `docs/rules/ui.md`, nearby feature widgets, and feature docs.
2. Shape the surface: primary task, density, navigation exits, state model, and reusable components.
3. Build with the UI kit: theme tokens, existing widgets, icons, loaders, sheets, pickers, inputs, and text styles.
4. Critique the result: hierarchy, cognitive load, copy clarity, scanning, repeated work ergonomics, and anti-patterns.
5. Audit implementation quality: accessibility, focus, contrast, responsive layout, dark/light behavior, and performance.
6. Harden real-world cases: long localized strings, empty data, permission failures, 4xx/5xx, offline/retry, huge numbers, slow loading, and large lists.
7. Extract only proven patterns: move repeated same-intent UI into `packages/ui` or document it only after the pattern is real.

## State Coverage

Every user-facing flow should account for:

- Initial or idle state.
- Loading or processing state using existing loader components.
- Empty state using existing empty/not-found patterns where suitable.
- Error state with actionable copy and retry behavior when appropriate.
- Disabled or permission-denied state when user action is unavailable.

Do not hide missing states behind optimistic assumptions.

## Accessibility And Usability

Translate external accessibility guidance into Flutter-specific checks:

- Interactive controls must have clear labels, semantics, and reachable hit targets.
- Focus order must remain predictable for keyboard and accessibility users.
- Text and icons must meet contrast expectations from `docs/rules/ui.md`.
- Dynamic text should not overflow, clip important content, or break buttons and chips.
- Loading overlays, modal sheets, pickers, and navigation must not trap users without a clear exit.
- Motion and visual feedback should help interaction, not carry required information alone.
- Prefer native Flutter widgets with built-in semantics before adding custom `Semantics` wrappers. Bad semantics are worse than no custom semantics.
- When custom controls are necessary, verify label, role-like meaning, enabled/disabled state, current value, and keyboard/focus behavior together.
- Prefer visible labels or visible text that can also serve accessibility. Use hidden-only semantics labels mainly for icon-only actions and make them concise, action-first, and localized.
- Do not encode role words in labels when Flutter already announces the control type. Use `Close`, not `Close button`; use `Delete client`, not `Button delete client`.
- For icon-only actions, distinguish repeated controls by target, for example `Edit Ivan Petrov` instead of several identical `Edit` labels in a list.
- Keep focus and selected state visually distinct for tabs, filters, chips, lists, segmented controls, and toolbars.
- Avoid shortcut-only access. Keyboard shortcuts may speed up common work, but every function must still be reachable through visible controls and focus traversal.
- If a custom grouped control behaves like tabs, radio options, a listbox, a menu, or a toolbar, match the expected focus movement and activation behavior before shipping it.

## Visual Review Checklist

- Does the screen use the shared theme, spacing, typography, icons, and components?
- Are controls visually obvious and consistent with similar AppOrOrgName screens?
- Are loading, empty, error, and disabled states designed, not just technically possible?
- Does the layout survive long localized text and real backend data?
- Does the UI avoid decorative complexity that harms scanning in a CRM/business tool?
- Are repeated items stable in size and behavior across state changes?
- Are focus, pressed, selected, disabled, loading, and error states visible where users need feedback?
- Does the implementation avoid AI-output cliches such as ornamental gradients, decorative card nesting, generic copy, and novelty styling that conflicts with the app?
- Are safe areas respected for fixed app bars, bottom bars, sheets, and CTA regions?
- Does scrollable content avoid being hidden under fixed/sticky controls?
- Are touch targets large enough and stable across pressed, loading, disabled, and selected states?
- Are dark and light theme states checked independently rather than inferred from one theme?

## Anti-Patterns To Catch

Reject UI that looks technically complete but ignores the product surface:

- Nested cards, card-heavy pages, and decorative panels that reduce scanning density.
- Hard-coded colors, ad-hoc spacing, one-off shadows, or local typography that bypass `packages/ui`.
- Layout-shifting pressed/hover states or animations that move neighboring content.
- Emoji or inconsistent asset styles used as structural icons.
- Every action styled as primary, unclear destructive actions, or disabled controls that look tappable.
- Copy that explains the UI instead of naming the user's task or next action.
- Empty, error, offline, permission, or validation states that only exist as generic fallback text.
- Mobile layouts that remove essential workflow capabilities instead of adapting them.
- Overly decorative gradients, glow, glassmorphism, novelty palettes, or generic SaaS styling that conflicts with AppOrOrgName's CRM/business-tool context.

## Hardening Cases

Before calling a non-trivial UI flow done, check representative messy data:

- Names, titles, addresses, comments, and service names at 1, 20, 60, and 200 characters.
- Long localized text and languages that expand UI copy.
- Empty lists, single-item lists, and large lists that should not jank while scrolling.
- Huge monetary values, negative values where possible, date ranges, and missing optional fields.
- Network failure, retry, stale data, validation errors, permission denied, and concurrent operations.
- Small phone, large phone, tablet, landscape, dark theme, and increased text scale when the screen supports those contexts.

## Testing And Verification

- For reusable widgets, add or update widget tests using `WidgetTestUtil.createWidgetUnderTest(...)`.
- For screens that depend on app scopes, use `WidgetTestUtil.appContext(...)` instead of hand-rolled app shells.
- Prefer focused tests for state rendering, actions, disabled controls, and error/empty/loading branches.
- Run `make format` and `make check` for Dart UI changes.
- Run focused widget tests first; escalate to `make test-unit-all` for shared UI kit changes or cross-package impact.

## External References

External design-system, critique, and accessibility sources are useful only as raw material. Keep the parts that improve AppOrOrgName UI behavior, then rewrite them in terms of Flutter widgets, `packages/ui`, semantics, theme usage, and local workflows. Drop web-only or stack-specific advice.

Useful ideas already merged here:

- UI UX Pro Max: priority-based review, stable interaction states, touch targets, safe areas, light/dark checks, accessibility labels, and pre-delivery review; not its stack-specific generators.
- Awesome DESIGN.md: a plain-text visual source of truth with colors, typography, components, layout, responsive behavior, do/don't rules, and agent guidance; adapted here as AppOrOrgName design context rather than copied as a root `DESIGN.md` yet.
- Impeccable: product-vs-brand register, context-first workflow, audit/critique split, hardening edge cases, and cautious extraction after repeated same-intent patterns; not its command structure.
- MDN ARIA and WAI APG: prefer native semantics, accessible names/descriptions, predictable focus, keyboard operation, and role/state/value consistency; translated to Flutter semantics, focus, and assistive technology behavior.

## Related

- [`verify-changes`](../verify-changes/SKILL.md)
- [`review-pr`](../review-pr/SKILL.md)
- [`docs/rules/ui.md`](../../../docs/rules/ui.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
- [`packages/ui/lib/ui.dart`](../../../packages/ui/lib/ui.dart)
- [`docs/agent-skill-authoring.md`](../../../docs/agent-skill-authoring.md)
