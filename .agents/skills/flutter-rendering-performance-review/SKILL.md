---
name: flutter-rendering-performance-review
description: "Review Flutter rebuild, layout, paint, invalidation, canvas, and frame-performance behavior when a screen is janky or rendering code changes."
---

# Flutter Rendering Performance Review

Source: Adapted for this template; the implementation companion is [`flutter-canvas-painters`](../flutter-canvas-painters/SKILL.md), informed by the author's canvas-rendering and animation analyses.

## Trigger

Use for frame drops, expensive animations, large interactive scenes, `CustomPaint`, `RenderObject`, `setState`-driven drawing, repaint boundaries, or claims that a rendering change is faster.

## Review

- Separate build, layout, paint, raster, semantics, and hit-testing work before proposing a fix.
- Find the actual invalidation source. Do not use `setState`, `AnimatedBuilder`, or a state-management builder solely to request a paint update.
- Keep animation and paint-only changes on a `Listenable`/`repaint` path when the surrounding widget tree does not change.
- Inspect allocations, path/image creation, clipping, `saveLayer`, offscreen culling, batching, and spatial indexing in hot paths.
- Add `RepaintBoundary` only when repaint propagation and memory cost are measured; it is not a universal optimization.
- Require profile evidence from DevTools, `FrameTiming`, or a reproducible benchmark before claiming improvement.
- Treat refresh rate as part of the budget: 60 Hz and 120 Hz have different frame limits. Report the target device and mode rather than quoting a generic FPS number.
- Prefer a direct `repaint` listenable or render-object invalidation for paint-only motion; do not rebuild the widget tree simply to move pixels.

## Output

Report the affected pipeline phase, invalidation source, evidence, frame budget, proposed change, and remaining semantic/hit-test risks. Include device, renderer, profile mode, and representative data for performance claims.

## Validate

- Read [`flutter-canvas-painters`](../flutter-canvas-painters/SKILL.md) before changing custom rendering implementation.
- Add focused geometry/invalidation tests and a regression test for rebuild isolation when that is the contract.
- Run `mise exec -- make format`, focused tests, and profile representative motion where the change is performance-sensitive.

## Related

- [`flutter-canvas-painters`](../flutter-canvas-painters/SKILL.md)
- [`flutter-renderer-selection`](../flutter-renderer-selection/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
