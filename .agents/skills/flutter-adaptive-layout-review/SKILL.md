---
name: flutter-adaptive-layout-review
description: "Review Flutter adaptive layouts, constraints, breakpoints, device pixels, text scale, localization, and overflow across supported screen sizes and platforms."
---

# Flutter Adaptive Layout Review

Source: Adapted for this template; see the [Flutter adaptive-layout rules](../../../docs/rules/flutter-patterns.md#6-adaptive-layout)
and repository UI rules.

## Trigger

Use when a screen must work across mobile, tablet, desktop, web, orientation changes, large text, long localized content, or variable data density.

## Review

- Start from parent constraints and the component's job; do not infer placement from a size value alone.
- Prefer `LayoutBuilder`, `MediaQuery.sizeOf`, and existing responsive primitives when the decision genuinely depends on available constraints.
- Distinguish actual constraints from ambient metadata: `SizedBox`/`Expanded` affect layout, while
  `MediaQuery.copyWith(size: ...)` only changes what descendants observe.
- Distinguish logical layout pixels from physical pixels and use `devicePixelRatio` only for rendering or pixel-snapping concerns.
- Check whether breakpoints describe a real layout mode or merely hide an overflow problem.
- Test narrow, normal, wide, landscape, text-scaled, dark/light, empty, long-copy, and localized states.
- Keep loading, disabled, selected, and error states within stable layout bounds.
- Reuse `packages/ui` components and theme tokens before adding feature-local responsive variants.
- Do not scatter screen-width constants, nested `if` trees, or `Container`/`GestureDetector` wrappers without a semantic layout reason.

## Output

Report the constraint source, layout modes, unsupported states, overflow mechanism, affected semantics/focus order, and the smallest adaptive change. Include the exact widths, text scale, locale, and platform needed to reproduce a failure.

## Validate

- Prefer focused widget tests at representative constraints and text scales.
- Use the existing the existing `pumpScreen` harness harness and `packages/ui` components.
- Run `mise exec -- make format`, focused widget tests, and `make check` when shared UI or cross-feature behavior changes.

## Related

- [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`flutter-widget-lifecycle-review`](../flutter-widget-lifecycle-review/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/ui.md`](../../../docs/rules/ui.md)
