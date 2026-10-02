# Flutter Patterns

Portable guidance adapted from the source application. Detailed SDK and project conventions remain in [Flutter rules](flutter.md), [Dart rules](dart.md), and [workflow rules](workflow.md).

## 1. Feature-first structure

Use model/data/controller/widget under each feature. Keep shared code in common only when ownership is actually shared. Do not add empty layers for symmetry.

## 2. Choose the smallest state owner

Use local State or ValueNotifier for local state, ChangeNotifier for synchronous shared state, and AppController$Sequential for asynchronous workflows.

## 3. Controller boundaries

Controllers accept repositories and values, never BuildContext or another controller. A scope or widget owns cross-controller coordination and platform listeners.

## 4. Scopes and InheritedModel

Use one feature scope with explicit aspects and static helpers with listen=true. Subscribe and dispose symmetrically. Notify each aspect only when its observable value changes.

## 5. Forms and cross-field validation

Keep field controllers and focus nodes with a widget lifecycle. Model dependent validation explicitly and prevent stale async validation. Cover submit, errors, disabled fields, and focus traversal.

## 6. Adaptive layout

Choose layout from constraints, not device labels. Check narrow/wide windows, landscape, keyboard, safe areas, localization, and increased text scale. Keep actions reachable.

## 7. Renderer selection

Start with widgets. Choose CustomPaint for drawing and a RenderObject for custom layout, hit testing, or invalidation. Require measured evidence before trading away semantics and SDK behavior.

## 8. Lifecycle and navigation

Acquire dependencies at the appropriate lifecycle phase and update subscriptions when inputs change. Keep initialization in its owned pipeline. Use typed AppPage navigation; see ../common/navigation.md for parser boundaries.

## 9. Rendering performance

Separate build, layout, paint, and raster cost. Use repaint isolation, caching, and batching only with measured benefit. Profile representative data in profile/release mode on the target device.

## 10. Flutter review checklist

Check ownership, loading/error/empty states, focus, semantics, navigation exits, keyboard behavior, disposal, and tests for changed contracts.

## Source references

- [Form State Management](https://plugfox.dev/form-state-management/) — SDK listenables and explicit form ownership.
- [High-Performance Canvas Rendering](https://plugfox.dev/high-performance-canvas-rendering/) — rendering choices and measured repaint isolation.
