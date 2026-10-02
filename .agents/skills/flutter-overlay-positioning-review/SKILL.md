---
name: flutter-overlay-positioning-review
description: "Review Flutter dropdowns, tooltips, onboarding overlays, badges, and floating widgets that must follow an anchor through scroll, transform, or layout changes."
---

# Flutter Overlay Positioning Review

Source: Adapted for this template; informed by the author's layer-link workshop.

## Trigger

Use when a floating widget must remain attached to another widget across scrolling, transforms, resizing, nested overlays, or route changes.

## Review

- Prefer `CompositedTransformTarget` and `CompositedTransformFollower` with a shared `LayerLink` when the overlay should follow an anchor across layout and paint changes.
- Define anchor, follower, overlay ownership, `showWhenUnlinked`, alignment, offset, clipping, hit testing, semantics, and dismissal behavior before implementation.
- Keep the `OverlayEntry` lifecycle explicit: insert once, remove on dismissal/unmount, and do not retain a stale `BuildContext` or `LayerLink` after the anchor is gone.
- Test scrolling, transforms, keyboard/viewport changes, text scale, rotation, nested navigators, and anchor removal.
- Do not use global coordinates and manual `setState` polling when composited layers can express the relationship. Use global measurement only when the product contract truly needs it.
- Ensure the overlay remains accessible and does not trap focus or intercept taps outside its intended region.

## Output

Report the anchor/follower relationship, layer and overlay owners, coordinate assumptions, lifecycle path, dismissal/accessibility behavior, and the focused test that proves alignment.

## Validate

- Use widget tests with scroll, transform, resize, and unmount transitions.
- Verify overlays on the target platform and with long localized content where placement can overflow.
- Run `mise exec -- make format` and focused widget tests.

## Related

- [`flutter-adaptive-layout-review`](../flutter-adaptive-layout-review/SKILL.md)
- [`flutter-widget-lifecycle-review`](../flutter-widget-lifecycle-review/SKILL.md)
- [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
