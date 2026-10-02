---
name: flutter-renderer-selection
description: "Choose between ordinary Flutter widgets, CustomPaint, and RenderObject/LeafRenderObjectWidget from layout, interaction, lifecycle, scene-size, and measured performance requirements."
---

# Flutter Renderer Selection

Source: Adapted for this template; informed by the author's high-performance canvas analysis and [`flutter-canvas-painters`](../flutter-canvas-painters/SKILL.md).

## Trigger

Use when someone asks whether a Flutter surface needs ordinary widgets, `CustomPaint`, a custom `RenderBox`, or `LeafRenderObjectWidget`.

## Decision Tree

1. Use ordinary widgets when the problem is standard layout, semantics, focus, forms, accessibility, or ordinary interaction.
2. Use `CustomPaint` with a `CustomPainter(repaint: listenable)` when drawing is custom but layout and lifecycle are simple and bounded.
3. Use `RenderObject`/`LeafRenderObjectWidget` when the component owns custom layout, hit testing, semantics, pointer forwarding, continuous per-frame state, or independent paint/layout invalidation.
4. Escalate toward a custom render object for large or frequently changing scenes only when the simpler path cannot meet measured frame or interaction requirements.
5. For a complex scene, compare `CustomPaint` and a custom render object against scene size, update frequency, layout ownership, hit testing, semantics, and measured rebuild/paint/raster cost. Do not infer the winner from API level alone.
6. Keep state ownership separate from rendering ownership. A render object must not become a hidden application controller or data repository.

## Guardrails

- Never choose `RenderObject` merely because it is lower-level or sounds faster.
- Never choose `CustomPaint` merely to avoid understanding layout constraints.
- "Always use `RenderObject`" is not a valid project rule. It is a conditional escalation for a demonstrated rendering or ownership requirement.
- Start with the simplest correct implementation when no measured bottleneck or custom layout contract exists.
- Preserve semantics, focus, hit testing, device-pixel behavior, and disposal regardless of the rendering API.

## Output

State the requirements, selected API, rejected alternatives, expected invalidation path, and the measurement or test that can disprove the choice. If the choice depends on missing scene size, update frequency, or interaction requirements, stop and request that context.

## Related

- [`flutter-canvas-painters`](../flutter-canvas-painters/SKILL.md)
- [`flutter-rendering-performance-review`](../flutter-rendering-performance-review/SKILL.md)
- [`dart-benchmark-review`](../dart-benchmark-review/SKILL.md)
- [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
