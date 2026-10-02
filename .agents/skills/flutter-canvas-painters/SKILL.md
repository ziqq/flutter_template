---
name: flutter-canvas-painters
description: "Build, optimize, debug, or review template Flutter CustomPainter, Canvas, PictureRecorder, shader-adjacent painting, and custom RenderObject code. Use for animated painters, charts, calendars, icons, image composition, hit testing, repaint isolation, caching, batching, and frame-performance work."
---

# Build Canvas Painters

Source: Adapted for this template; derived from the repository's Flutter rendering rules, existing UI renderers, and the author's high-performance canvas analysis.

## Inspect First

- Read the `High-Performance Canvas Rendering` section in `docs/rules/flutter.md` and the applicable UI rules.
- Inspect nearby code in `packages/ui/lib/src/components/charts/`, `packages/ui/lib/src/components/`, and the owning feature.
- Identify layout inputs, paint-only inputs, animation sources, semantics, hit testing, and expected scene size before choosing an API.

## Choose The Rendering Path

- Prefer ordinary widgets for layout, semantics, focus, and small composited effects.
- Use `BackdropFilter` or a runtime shader when the effect must sample or refract the backdrop; a `CustomPainter` cannot read pixels behind itself.
- Use `CustomPaint` with a `CustomPainter(repaint: listenable)` for bounded scenes with simple layout and paint-only updates.
- Use `LeafRenderObjectWidget` with a custom `RenderBox` when the renderer owns layout, pointer forwarding, paint invalidation, or continuous per-frame state.
- For large interactive scenes, consider camera transforms, viewport culling, spatial indexing, and batched draw calls only when the scene shape justifies their complexity.
- Do not add a rendering dependency without explicit approval and a measured gap in Flutter primitives.

## Keep Repaints Local

- Drive paint-only motion through `AnimationController`, `ChangeNotifier`, or `ValueNotifier` passed to `repaint`.
- Never use `setState`, `AnimatedBuilder`, `ValueListenableBuilder`, or a state-management builder solely to repaint a canvas.
- In a `RenderBox`, mutate typed fields through setters and call `markNeedsLayout`, `markNeedsPaint`, or `markNeedsSemanticsUpdate` according to the affected phase.
- Add `RepaintBoundary` or override `isRepaintBoundary` only after measuring repaint propagation and memory cost.
- Keep semantics and pointer hit regions stable when visual content moves or scales.
- Keep a custom render object conditional: it is justified by custom layout/hit testing/invalidation or measured widget rebuild overhead, not by a blanket performance policy.

## Make The Hot Path Allocation-Light

- Resolve async data, images, paths, paragraphs, and scene models before `paint`.
- Keep painting inside the supplied bounds or define clipping explicitly. Do not call `setState`, `markNeedsLayout`, or
  mutate layout from `paint`.
- Reuse configured `Paint`, `Path`, `TextPainter`, and source/destination geometry when their inputs are unchanged.
- Cache expensive static or infrequently changing drawing in `Picture`; invalidate it only for size, scale, theme, or content changes that affect pixels.
- Batch homogeneous primitives with `drawRawAtlas`, `drawRawPoints`, or `drawVertices`; cull offscreen content before detailed drawing.
- Reuse camera/coordinate transforms and spatial-query structures outside `paint`; never build a quadtree, path index, or scene model inside the frame hot path.
- Use `drawImageRect` for scaled images and choose `FilterQuality` intentionally.
- Snap hairlines and grid coordinates to physical pixels when subpixel blur is visible.
- Split a long paint method into ordered helpers: background, content, overlays, debug.

## Preserve Canvas State

- Pair every `save` or `saveLayer` with `restore`, including early-return paths.
- Save before clipping or transforming. Prefer `clipRect` when rounded or arbitrary clipping is unnecessary.
- Avoid `saveLayer` unless blending requires an offscreen buffer; verify its raster cost in profile mode.
- Keep blend modes, shaders, filters, and anti-aliasing explicit. Do not leave mutable `Paint` state leaking between draw calls.

## Invalidation And Semantics

- Compare only pixel-affecting fields in `shouldRepaint`; compare semantic fields in `shouldRebuildSemantics`.
- Return `false` from `shouldRepaint` when the same painter instance receives paint changes exclusively through its `repaint` listenable.
- Use `identical` for intentionally identity-owned images or collections and value equality for immutable scalar inputs.
- Provide semantic nodes or an accessible widget alternative when canvas content represents actions, labels, values, or selection.
- Keep hit testing cheap: bounding boxes first, detailed path tests second. Introduce spatial indexing only for large interactive scenes.

## Validate

1. Add focused tests for geometry, invalidation, semantics, hit testing, clipping, and empty or extreme inputs.
2. Add a regression test that verifies animation does not rebuild the foreground or surrounding widget tree when that is a performance invariant.
3. Run `mise exec -- make format`, `mise exec -- make check`, and focused tests. Run `mise exec -- make test-unit-all` for shared `packages/ui` behavior.
4. Profile representative motion with `flutter run --profile`, DevTools, or a reproducible `FrameTiming` integration test.
5. Report frame count, build and raster p90/p99, missed budgets, device, renderer, and any system outliers. Use 16.67 ms for 60 Hz and 8.33 ms for 120 Hz as reference budgets.

## Review Checklist

- Correct rendering API selected; backdrop sampling is not forced into a painter.
- No widget rebuild is used only to request a repaint.
- No async work, logging, unbounded allocation, or repeated layout occurs inside `paint`.
- Canvas state is balanced and clipping is as cheap and tight as possible.
- Paint invalidation, layout invalidation, semantics, and hit testing are independently correct.
- Caching, batching, and repaint boundaries are justified by measurement.
- Light/dark themes, device pixel ratio, text scale, reduced motion, and supported platforms are covered where applicable.

## Related

- [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/ui.md`](../../../docs/rules/ui.md)
- [`packages/ui/lib/src/components/charts/`](../../../packages/ui/lib/src/components/charts/)
