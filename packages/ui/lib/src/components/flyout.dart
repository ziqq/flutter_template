import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Builds flyout content using the resolved [placement].
typedef UIFlyoutBuilder = Widget Function(BuildContext context, UIFlyoutPlacement placement);

/// Builds the full-overlay layer behind a flyout.
///
/// The [targetRect] is expressed in the coordinate space of the nearest
/// [Overlay]. Use it for barriers, target highlights, or other anchored
/// decoration that must cover the overlay independently from the flyout.
typedef UIFlyoutBackdropBuilder = Widget Function(BuildContext context, Rect targetRect);

/// Describes whether overflow handling moved a flyout across its anchor.
@immutable
class UIFlyoutPlacement {
  /// Creates placement information for a flyout.
  const UIFlyoutPlacement({this.flippedHorizontally = false, this.flippedVertically = false});

  /// Whether the flyout moved to the opposite horizontal side of its target.
  final bool flippedHorizontally;

  /// Whether the flyout moved to the opposite vertical side of its target.
  final bool flippedVertically;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UIFlyoutPlacement &&
          other.flippedHorizontally == flippedHorizontally &&
          other.flippedVertically == flippedVertically;

  @override
  int get hashCode => Object.hash(flippedHorizontally, flippedVertically);
}

/// Defines the width behavior of the flyout.
enum UIFlyoutWidth {
  /// The flyout will hug the content regardless of the target.
  fixed,

  /// The flyout will match the target width.
  fill,
}

/// {@template ui_flyout_anchor}
/// Positioning configuration for a flyout with automatic overflow handling.
///
/// The flyout is positioned by aligning [flyoutAlignment] on the flyout
/// to [anchorAlignment] on the target widget, plus any [offset].
///
/// **Overflow behavior:**
/// 1. If the flyout overflows, it flips to the opposite side.
/// 2. If both sides overflow, it stays on the original side but shifts
///    to remain within bounds.
/// {@endtemplate}
@immutable
class UIFlyoutAnchor {
  /// {@macro ui_flyout_anchor}
  const UIFlyoutAnchor({
    this.offset = Offset.zero,
    this.anchorAlignment = AlignmentDirectional.bottomEnd,
    this.flyoutAlignment = AlignmentDirectional.topEnd,
  });

  /// The offset of the flyout from the anchor.
  final Offset offset;

  /// The point on the anchor to which the flyout is aligned.
  final AlignmentGeometry anchorAlignment;

  /// The point on the flyout that should be aligned with the anchor.
  final AlignmentGeometry flyoutAlignment;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UIFlyoutAnchor &&
        other.offset == offset &&
        other.anchorAlignment == anchorAlignment &&
        other.flyoutAlignment == flyoutAlignment;
  }

  @override
  int get hashCode => Object.hash(offset, anchorAlignment, flyoutAlignment);
}

/// {@template ui_flyout}
/// A headless, controlled overlay with anchor alignment, flipping, and width.
///
/// Uses [OverlayPortal.overlayChildLayoutBuilder] so the SDK recomputes target
/// bounds during layout, including scrolling and ordinary transforms. Do not
/// place it below a [CompositedTransformFollower]: that transform is established
/// after layout. The nearest overlay owns the portal; removing the anchor also
/// removes its overlay content.
///
/// Callers own focus, semantics, Escape/tap-outside dismissal, and styling.
/// [backdropBuilder] receives target bounds in overlay coordinates.
/// {@endtemplate}
class UIFlyout extends StatefulWidget {
  /// {@macro ui_flyout}
  const UIFlyout({
    required this.isOpen,
    required this.flyoutBuilder,
    required this.child,
    this.anchor = const UIFlyoutAnchor(),
    this.width = UIFlyoutWidth.fixed,
    this.backdropBuilder,
    super.key,
  });

  /// The anchor of the flyout, which is used to position it.
  final UIFlyoutAnchor anchor;

  /// The width behavior of the flyout.
  final UIFlyoutWidth width;

  /// Whether the flyout is open.
  final bool isOpen;

  /// The builder for the flyout content.
  final UIFlyoutBuilder flyoutBuilder;

  /// Builds a layer that fills the overlay behind the flyout.
  ///
  /// The backdrop is omitted when this is `null` and does not affect flyout
  /// measurement or positioning.
  final UIFlyoutBackdropBuilder? backdropBuilder;

  /// The target/anchor widget.
  final Widget child;

  @override
  State<UIFlyout> createState() => _UIFlyoutState();
}

class _UIFlyoutState extends State<UIFlyout> {
  late final OverlayPortalController _overlayPortalController;
  UIFlyoutPlacement _placement = const UIFlyoutPlacement();
  int _visibilityRevision = 0;

  @override
  void initState() {
    super.initState();
    _overlayPortalController = OverlayPortalController();
    _scheduleChangeVisibility();
  }

  @override
  void didUpdateWidget(covariant UIFlyout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen != widget.isOpen) _scheduleChangeVisibility();
  }

  /// Schedules the visibility change for the next frame.
  ///
  /// This is necessary because [OverlayPortal] does not allow toggling
  /// visibility during the same frame it is built.
  void _scheduleChangeVisibility() {
    final visibility = widget.isOpen;
    final revision = ++_visibilityRevision;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || revision != _visibilityRevision || visibility != widget.isOpen) return;

      if (visibility) {
        _overlayPortalController.show();
      } else {
        _overlayPortalController.hide();
      }
    });
  }

  void _handlePlacementChanged(UIFlyoutPlacement placement) {
    if (_placement == placement) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _placement == placement) return;
      setState(() => _placement = placement);
    });
  }

  @override
  Widget build(BuildContext context) => OverlayPortal.overlayChildLayoutBuilder(
    controller: _overlayPortalController,
    overlayChildBuilder: (flyoutContext, info) {
      final targetRect = MatrixUtils.transformRect(info.childPaintTransform, Offset.zero & info.childSize);
      return Stack(
        fit: StackFit.expand,
        children: [
          if (widget.backdropBuilder case UIFlyoutBackdropBuilder builder)
            Positioned.fill(child: builder(flyoutContext, targetRect)),
          CustomSingleChildLayout(
            delegate: _UiFlyoutDelegate(
              anchor: widget.anchor,
              targetRect: targetRect,
              direction: Directionality.of(flyoutContext),
              width: widget.width,
              onPlacementChanged: _handlePlacementChanged,
            ),
            child: widget.flyoutBuilder(flyoutContext, _placement),
          ),
        ],
      );
    },
    child: widget.child,
  );
}

class _UiFlyoutDelegate extends SingleChildLayoutDelegate {
  _UiFlyoutDelegate({
    required this.anchor,
    required this.targetRect,
    required this.direction,
    required this.width,
    required this.onPlacementChanged,
  });

  final UIFlyoutAnchor anchor;
  final Rect targetRect;
  final TextDirection direction;
  final UIFlyoutWidth width;
  final ValueChanged<UIFlyoutPlacement> onPlacementChanged;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => switch (width) {
    UIFlyoutWidth.fixed => constraints.loosen(),
    UIFlyoutWidth.fill => BoxConstraints(
      minWidth: targetRect.width.clamp(0, constraints.maxWidth),
      maxWidth: targetRect.width.clamp(0, constraints.maxWidth),
      maxHeight: constraints.maxHeight,
    ),
  };

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final anchorAlignment = anchor.anchorAlignment.resolve(direction);
    final flyoutAlignment = anchor.flyoutAlignment.resolve(direction);
    final offset = anchor.offset;

    var position = _calculatePosition(
      anchorAlignment: anchorAlignment,
      flyoutAlignment: flyoutAlignment,
      childSize: childSize,
      offset: offset,
    );
    final resolvedPosition = _flipIfOverflowing(
      position: position,
      anchorAlignment: anchorAlignment,
      flyoutAlignment: flyoutAlignment,
      offset: offset,
      childSize: childSize,
      availableSize: size,
    );
    position = resolvedPosition.position;
    position = _clampToAvailableSpace(position, childSize, size);

    onPlacementChanged(
      UIFlyoutPlacement(
        flippedHorizontally: resolvedPosition.flippedHorizontally,
        flippedVertically: resolvedPosition.flippedVertically,
      ),
    );

    return position;
  }

  /// Tries flipping the flyout to the opposite side if it overflows.
  ///
  /// Only flips if the other side has no overflow; otherwise stays on the
  /// original side.
  ({Offset position, bool flippedHorizontally, bool flippedVertically}) _flipIfOverflowing({
    required Offset position,
    required Alignment anchorAlignment,
    required Alignment flyoutAlignment,
    required Offset offset,
    required Size childSize,
    required Size availableSize,
  }) {
    final needsHorizontalFlip = position.dx < 0 || position.dx + childSize.width > availableSize.width;
    final needsVerticalFlip = position.dy < 0 || position.dy + childSize.height > availableSize.height;

    if (!needsHorizontalFlip && !needsVerticalFlip) {
      return (position: position, flippedHorizontally: false, flippedVertically: false);
    }

    final flippedAnchorAlignment = Alignment(
      needsHorizontalFlip ? -anchorAlignment.x : anchorAlignment.x,
      needsVerticalFlip ? -anchorAlignment.y : anchorAlignment.y,
    );
    final flippedFlyoutAlignment = Alignment(
      needsHorizontalFlip ? -flyoutAlignment.x : flyoutAlignment.x,
      needsVerticalFlip ? -flyoutAlignment.y : flyoutAlignment.y,
    );
    final flippedOffset = Offset(
      needsHorizontalFlip ? -offset.dx : offset.dx,
      needsVerticalFlip ? -offset.dy : offset.dy,
    );

    final flippedPosition = _calculatePosition(
      anchorAlignment: flippedAnchorAlignment,
      flyoutAlignment: flippedFlyoutAlignment,
      childSize: childSize,
      offset: flippedOffset,
    );

    final flippedOverflow = _calculateOverflow(flippedPosition, childSize, availableSize);

    return flippedOverflow == 0
        ? (position: flippedPosition, flippedHorizontally: needsHorizontalFlip, flippedVertically: needsVerticalFlip)
        : (position: position, flippedHorizontally: false, flippedVertically: false);
  }

  Offset _clampToAvailableSpace(Offset position, Size childSize, Size availableSize) {
    var dx = position.dx;
    var dy = position.dy;

    if (dx + childSize.width > availableSize.width) {
      dx = availableSize.width - childSize.width;
    }
    if (dx < 0) dx = 0;

    if (dy + childSize.height > availableSize.height) {
      dy = availableSize.height - childSize.height;
    }
    if (dy < 0) dy = 0;

    return Offset(dx, dy);
  }

  Offset _calculatePosition({
    required Alignment anchorAlignment,
    required Alignment flyoutAlignment,
    required Size childSize,
    required Offset offset,
  }) {
    final anchorPoint = Offset(
      targetRect.left + targetRect.width * ((anchorAlignment.x + 1) / 2),
      targetRect.top + targetRect.height * ((anchorAlignment.y + 1) / 2),
    );

    final flyoutPoint = Offset(
      childSize.width * ((flyoutAlignment.x + 1) / 2),
      childSize.height * ((flyoutAlignment.y + 1) / 2),
    );

    return anchorPoint - flyoutPoint + offset;
  }

  double _calculateOverflow(Offset position, Size childSize, Size availableSize) {
    var overflow = 0.0;

    if (position.dx < 0) overflow += -position.dx;
    if (position.dy < 0) overflow += -position.dy;
    if (position.dx + childSize.width > availableSize.width) {
      overflow += position.dx + childSize.width - availableSize.width;
    }
    if (position.dy + childSize.height > availableSize.height) {
      overflow += position.dy + childSize.height - availableSize.height;
    }

    return overflow;
  }

  @override
  bool shouldRelayout(covariant _UiFlyoutDelegate oldDelegate) =>
      anchor != oldDelegate.anchor ||
      targetRect != oldDelegate.targetRect ||
      direction != oldDelegate.direction ||
      width != oldDelegate.width;
}
