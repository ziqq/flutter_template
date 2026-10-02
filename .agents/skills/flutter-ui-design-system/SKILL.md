---
name: flutter-ui-design-system
description: "Build, refactor, or review template Flutter UI with packages/ui components, themes, icons, layouts, semantics, focus, accessibility, responsive behavior, and loading, empty, error, disabled, and permission states."
---

# UI Design System

Source: Adapted for this template; adapted from `packages/ui`, UI rules, and selected accessibility/design-review guidance translated to Flutter.

## Inspect First

- Read `packages/ui/lib/ui.dart`, `packages/ui/lib/ui.dart`, and `packages/ui/lib/src/theme/`.
- Inspect existing layouts, inputs, loaders, chips, pickers, sheets, images, icons, and text widgets before creating a variant.
- Read `docs/rules/ui.md`, `docs/rules/flutter.md`, the feature doc, and nearby feature widgets.

## Build With template

- Prefer public `package:ui/ui.dart` or `package:ui/ui.dart` exports over direct internal imports.
- Use `UITheme`, `UIColors`, and existing tokens instead of hard-coded colors, typography, spacing, shadows, or gradients.
- Compose complex surfaces from small immutable widgets and keep transport, parsing, and orchestration out of `build()`.
- Preserve supported phone, tablet, landscape, desktop/web, dark/light, and increased-text-scale behavior.
- Introduce a shared component only after repeated same-intent usage proves shared ownership.
- Do not add a dependency or parallel visual system for one screen without a concrete gap in `packages/ui`.

## UI Lifecycle

1. Inspect the design context and nearby implementations.
2. Define the primary task, information density, navigation exits, state model, and reusable components.
3. Build with existing theme tokens, widgets, icons, inputs, loaders, sheets, and pickers.
4. Critique hierarchy, scanability, copy clarity, cognitive load, and repeated-work ergonomics.
5. Audit accessibility, focus, contrast, responsive layout, theme behavior, and performance.
6. Harden long localized text, missing data, huge values, large lists, slow loading, offline/retry, permission, validation, and backend failures.
7. Extract or document only a proven repeated pattern.

## State And Accessibility

Cover applicable idle, processing, empty, error, disabled, permission-denied, and success states. Make retries and exits explicit where users can recover.

- Prefer native controls with built-in semantics.
- Give icon-only actions concise, localized, action-first labels and distinguish repeated targets.
- Keep focus order predictable and selected/focused/disabled/loading states visually distinct.
- Ensure visible controls remain reachable without keyboard shortcuts.
- Prevent text scaling and localization from clipping essential content.
- Keep touch targets stable and large enough across pressed, loading, and disabled states.
- Ensure sheets, dialogs, pickers, and loading overlays have an accessible exit and do not trap focus.

## Reject

- Nested decorative cards that reduce screen scanability.
- One-off styling that bypasses the UI kit.
- Layout-shifting interactions or motion that carries required information alone.
- Generic fallback copy for actionable errors, permissions, validation, or offline states.
- Novelty palettes, ornamental gradients, glow, glassmorphism, or generic SaaS styling that conflicts with the product.
- Mobile adaptations that remove essential workflow actions instead of reorganizing them.

## Validation

- Add focused widget tests for state rendering, actions, semantics, disabled behavior, and failures.
- Run `mise exec -- make format` and `mise exec -- make check` for Dart UI changes.
- Escalate to `mise exec -- make test-unit-all` for shared `packages/ui` changes or cross-package impact.

## Related

- [`project-pr-review`](../project-pr-review/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`docs/rules/ui.md`](../../../docs/rules/ui.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`packages/ui/lib/ui.dart`](../../../packages/ui/lib/ui.dart)
- [`packages/ui/lib/ui.dart`](../../../packages/ui/lib/ui.dart)
