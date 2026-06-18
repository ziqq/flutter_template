/*
 * Date: 07 May 2026
 */

import 'package:ui/ui.dart';

/// Controls when the route behind the sheet is rasterized to a GPU texture
/// instead of being painted live.
///
/// Snapshotting replaces the background route's widget tree with a frozen
/// image, eliminating the cost of rebuilding and painting complex widgets
/// during sheet transitions and while the sheet is open.
///
/// See also:
///
///  * [SnapshotWidget], the Flutter widget that performs the rasterization.
enum RouteSnapshotMode {
  /// Always snapshot while the sheet is present.
  ///
  /// Maximum performance. The background is completely frozen for the lifetime
  /// of the sheet. Best for static background content.
  always,

  /// Never snapshot. The background route is always painted live.
  ///
  /// Use this when the content behind the sheet contains animations, video, or
  /// other dynamic content that must remain live at all times.
  never,

  /// Snapshot only while the sheet animation is playing (opening, closing,
  /// or being dragged). Reverts to the live widget tree when the animation
  /// settles.
  ///
  /// Good for cases where transition performance matters but background content
  /// must stay live when the sheet is idle.
  animating,

  /// Snapshot while the sheet is open and settled. Reverts to live during
  /// all animations (opening, closing, and drag gestures).
  ///
  /// Useful when the transition involves visual effects that don't rasterize
  /// well, but idle performance matters.
  settled,

  /// Snapshot while the sheet animates toward its fully-open (max extent)
  /// position, and while it is settled there. Reverts to the live widget tree
  /// during dismiss gestures, closing animations, and animations toward
  /// intermediate snap points.
  ///
  /// "Forward" only counts when the animation target is the maximum snapping
  /// point. Animations to intermediate snap points are not snapshotted.
  ///
  /// Best default for most sheets: maximum performance during the opening
  /// transition and while idle, with real content visible as the user drags to
  /// dismiss.
  openAndForward,
}

/// A modal route that displays a sheet that slides up from the bottom.
///
/// The sheet can be dismissed by dragging down or by tapping the barrier.
/// The animation supports spring physics for natural motion using the
///
///
/// By default, when a modal route is replaced by another, the previous route
/// remains in memory. To free all the resources when this is not necessary, set
/// [maintainState] to false.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.pop] when an optional
/// `result` can be provided.
///
/// See also:
///
///  * [UISheetTransitionMixin], for a mixin that provides sheet transition behavior for this modal route.
///  * [CupertinoModalPopupRoute], for a similar iOS-style modal popup.
class UISheetRoute<T> extends PopupRoute<T> with UISheetTransitionMixin<T>, UISheetController<T> {
  /// Creates a sheet route for displaying modal content.
  UISheetRoute({
    required this.child,
    super.settings,
    this.motion = const UISheetMotion(),
    this.barrierColor = const Color.fromRGBO(0, 0, 0, 0.2),
    this.barrierDismissible = true,
    this.barrierLabel,
    this.clearBarrierImmediately = true,
    this.onlyDragWhenScrollWasAtTop = true,
    this.callNavigatorUserGestureMethods = false,
    this.snappingConfig = SheetSnappingConfig.full,
    this.draggable = true,
    this.originateAboveBottomViewInset = false,
    this.dismissalMode = SheetDismissalMode.slide,
    this.backgroundSnapshotMode = RouteSnapshotMode.never,
  });

  @override
  final SheetMotion motion;

  /// The widget displayed inside the sheet.
  final Widget child;

  @override
  final Color? barrierColor;

  @override
  final bool barrierDismissible;

  @override
  final String? barrierLabel;

  @override
  final bool clearBarrierImmediately;

  @override
  final bool onlyDragWhenScrollWasAtTop;

  @override
  final bool callNavigatorUserGestureMethods;

  @override
  final SheetSnappingConfig snappingConfig;

  @override
  final bool draggable;

  @override
  final bool originateAboveBottomViewInset;

  @override
  final SheetDismissalMode dismissalMode;

  @override
  final RouteSnapshotMode backgroundSnapshotMode;

  @override
  DelegatedTransitionBuilder? get delegatedTransition => backgroundSnapshotMode == RouteSnapshotMode.never
      ? null
      : (_, _, _, _, child) => SnapshotWidget(
          controller: backgroundSnapshotController,
          mode: SnapshotMode.permissive,
          autoresize: true,
          child: child,
        );

  @override
  Widget buildContent(BuildContext context) => child;
}

/// Provides sheet transition, dragging, snapping, and dismissal behavior for a
/// [PopupRoute].
mixin UISheetTransitionMixin<T> on PopupRoute<T> {
  /// Builds the primary contents of the sheet.
  @protected
  Widget buildContent(BuildContext context);

  /// Spring motion used for opening, closing, and snapping.
  SheetMotion get motion;

  /// Resistance applied when the user drags beyond the allowed sheet range.
  double get overshootResistance => 100;

  /// Whether the modal barrier becomes non-interactive immediately after pop.
  bool get clearBarrierImmediately => true;

  /// Whether sheet dragging is allowed only when the scrollable started at top.
  bool get onlyDragWhenScrollWasAtTop => true;

  /// Whether the sheet can be dragged by the user.
  bool get draggable => true;

  /// Whether Navigator user gesture callbacks should be called during drag.
  bool get callNavigatorUserGestureMethods => false;

  /// Whether the sheet origin moves above the bottom view inset, such as the
  /// keyboard.
  bool get originateAboveBottomViewInset => false;

  /// The visual dismissal mode used by [SheetDismissalTransition].
  SheetDismissalMode get dismissalMode => SheetDismissalMode.slide;

  /// Controls when the background route is snapshotted.
  RouteSnapshotMode get backgroundSnapshotMode => RouteSnapshotMode.never;

  /// Controller used by [SnapshotWidget] for the route behind this sheet.
  @protected
  SnapshotController get backgroundSnapshotController => _backgroundSnapshotController;

  late final SnapshotController _backgroundSnapshotController = SnapshotController();

  SnapshotController? _coveredBySnapshotController;

  bool _isUserDragging = false;

  @override
  bool get allowSnapshotting => backgroundSnapshotMode != RouteSnapshotMode.never;

  SheetSnappingConfig? _snappingConfigOverride;

  /// Base snapping configuration for this sheet.
  @protected
  SheetSnappingConfig get snappingConfig;

  /// Current snapping configuration, including any runtime override.
  SheetSnappingConfig get effectiveSnappingConfig => _snappingConfigOverride ?? snappingConfig;

  double? _dragEndVelocity;
  double? _animationTargetValue;
  double? _stickingPoint;

  /// Updates background snapshotting according to route animation state.
  void _updateSnapshotState() {
    final mode = backgroundSnapshotMode;

    if (mode == RouteSnapshotMode.never) {
      _backgroundSnapshotController.allowSnapshotting = false;
      return;
    }

    if (mode == RouteSnapshotMode.always) {
      _backgroundSnapshotController.allowSnapshotting = true;
      return;
    }

    final isAnimating = controller?.isAnimating ?? false;
    final value = controller?.value ?? 0.0;
    final isVisible = value > 0.001;
    final isSettled = !isAnimating && !_isUserDragging && isVisible;
    final maxExtent = effectiveSnappingConfig.maxExtent;
    final isFullyOpen = (value - maxExtent).abs() < 0.001;

    final isTargetingMax = _animationTargetValue != null && (_animationTargetValue! - maxExtent).abs() < 0.001;

    final isMovingForward =
        isTargetingMax && ((controller?.status.isAnimating ?? false) || (_animationTargetValue! > value));

    _backgroundSnapshotController.allowSnapshotting = switch (mode) {
      RouteSnapshotMode.animating => isAnimating || _isUserDragging,
      RouteSnapshotMode.settled => isSettled,
      RouteSnapshotMode.openAndForward =>
        (isSettled && isFullyOpen) || (isAnimating && isMovingForward && !_isUserDragging),
      _ => false,
    };
  }

  @override
  Duration get transitionDuration => motion.duration;

  @override
  Duration get reverseTransitionDuration => motion.reverseDuration ?? motion.duration;

  @override
  Animation<double>? get animation => super.animation?.clamped;

  @override
  Animation<double>? get secondaryAnimation => super.secondaryAnimation?.clamped;

  @override
  Simulation? createSimulation({required bool forward}) {
    final velocity = _dragEndVelocity;
    _dragEndVelocity = null;

    final endValue = forward ? effectiveSnappingConfig.initialSnap : 0.0;

    _animationTargetValue = endValue;
    _stickingPoint = endValue;
    _updateSnapshotState();

    return motion.createSimulation(start: animation?.value ?? 0, end: endValue, velocity: -(velocity ?? 0));
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      AnimatedBuilder(
        animation: animation,
        builder: (context, child) => MediaQuery.removeViewInsets(
          context: context,
          removeBottom: originateAboveBottomViewInset,
          child: _RelativeGestureDetector(
            dismissalMode: dismissalMode,
            onlyDragWhenScrollWasAtTop: onlyDragWhenScrollWasAtTop,
            scrollableCanMoveBack: (_animationTargetValue ?? animation.value) < effectiveSnappingConfig.maxExtent,
            onRelativeDragStart: () => _handleDragStart(context),
            onRelativeDragUpdate: (relativeDelta, referenceHeight, wouldScroll) {
              _handleDragUpdate(context, relativeDelta, referenceHeight, wouldScroll);
            },
            onRelativeDragEnd: (relativeVelocity, referenceHeight, willScroll) {
              _handleDragEnd(context, relativeVelocity, referenceHeight, willScroll);
            },
            child: child!,
          ),
        ),
        child: buildContent(context),
      );

  @override
  AnimationController createAnimationController() {
    assert(!debugTransitionCompleted(), 'Cannot reuse a $runtimeType after disposing it.');

    return AnimationController.unbounded(
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
      debugLabel: debugLabel,
      vsync: navigator!,
    )..addStatusListener((_) => _updateSnapshotState());
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Flexible(
        child: SheetDismissalTransition(animation: controller!, dismissalMode: dismissalMode, child: child),
      ),
      if (originateAboveBottomViewInset) SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
    ],
  );

  final _poppedNotifier = ValueNotifier(false);

  @override
  Widget buildModalBarrier() => ValueListenableBuilder(
    valueListenable: _poppedNotifier,
    builder: (_, value, _) =>
        IgnorePointer(ignoring: value && clearBarrierImmediately, child: super.buildModalBarrier()),
  );

  @override
  @mustCallSuper
  bool didPop(T? result) {
    _poppedNotifier.value = true;
    _updateSnapshotState();
    return super.didPop(result);
  }

  void _handleDragStart(BuildContext context) {
    _isUserDragging = true;
    _updateSnapshotState();

    if (callNavigatorUserGestureMethods) {
      navigator?.didStartUserGesture();
    }
  }

  void _handleDragUpdate(BuildContext context, double delta, double referenceHeight, bool wouldScroll) {
    if (_poppedNotifier.value) return;

    final currentValue = controller?.value ?? 0;
    var adjustedDelta = delta;

    final maxExtent = effectiveSnappingConfig.maxExtent;
    final minSnap = effectiveSnappingConfig.minExtent;
    final cannotPop = popDisposition != RoutePopDisposition.pop;
    final belowMinAndCannotPop = cannotPop && currentValue < minSnap && delta > 0;

    final applyResistance = !draggable || currentValue > maxExtent || belowMinAndCannotPop;

    if (wouldScroll && (currentValue - delta) > maxExtent) {
      adjustedDelta = currentValue - maxExtent;
    } else if (applyResistance && delta != 0) {
      final stickingPoint = _stickingPoint ?? 1.0;
      final overshoot = (stickingPoint - currentValue).abs();
      final resistance = 1.0 / (1.0 + overshoot * overshootResistance);

      adjustedDelta = delta * resistance;
    }

    final newValue = currentValue - adjustedDelta;

    controller?.value = newValue;
    _animationTargetValue = newValue;
  }

  void _handleDragEnd(BuildContext context, double velocity, double referenceHeight, bool willScroll) {
    _isUserDragging = false;

    final currentValue = controller!.value;

    if (callNavigatorUserGestureMethods) {
      navigator?.didStopUserGesture();
    }

    if (_poppedNotifier.value) return;

    _dragEndVelocity = velocity;

    final maxExtent = effectiveSnappingConfig.maxExtent;
    final minSnap = effectiveSnappingConfig.minExtent;
    final cannotPop = popDisposition != RoutePopDisposition.pop;
    final belowMinAndCannotPop = cannotPop && currentValue < minSnap;

    if (currentValue > maxExtent || !draggable || belowMinAndCannotPop) {
      final stickingPoint = _stickingPoint ?? maxExtent;
      final snapTarget = currentValue > maxExtent ? maxExtent : stickingPoint;
      final overshoot = (currentValue - stickingPoint).abs();
      final resistance = 1.0 / (maxExtent + overshoot * overshootResistance);
      final adjustedVelocity = velocity * resistance;

      final simulation = motion.createSimulation(start: currentValue, end: snapTarget, velocity: -adjustedVelocity);

      controller!.animateWith(simulation);
      _dragEndVelocity = null;
    } else {
      final targetValue = _animationTargetValue = effectiveSnappingConfig.findTargetSnapPoint(
        position: currentValue,
        relativeVelocity: -velocity,
        absoluteVelocity: -velocity * referenceHeight,
        includeClosed: popDisposition == RoutePopDisposition.pop,
      );

      _stickingPoint = targetValue;

      if (targetValue <= 0.001) {
        navigator?.pop();
      } else {
        final simulation = motion.createSimulation(start: currentValue, end: targetValue, velocity: -_dragEndVelocity!);

        controller!.animateWith(simulation);
        _dragEndVelocity = null;
      }
    }

    _updateSnapshotState();
  }

  /// Wraps [child] in a [SnapshotWidget] if another sheet route with
  /// snapshotting is stacked above this route.
  @protected
  Widget maybeSnapshotChild(Widget child) {
    final controller = _coveredBySnapshotController;

    if (controller == null) return child;

    return SnapshotWidget(controller: controller, mode: SnapshotMode.permissive, autoresize: true, child: child);
  }

  @override
  @mustCallSuper
  void didChangeNext(Route<dynamic>? nextRoute) {
    super.didChangeNext(nextRoute);

    if (nextRoute is UISheetTransitionMixin) {
      _coveredBySnapshotController = nextRoute._backgroundSnapshotController;
    } else {
      _coveredBySnapshotController = null;
    }
  }

  @override
  @mustCallSuper
  void didPopNext(Route<dynamic> nextRoute) {
    super.didPopNext(nextRoute);
    _coveredBySnapshotController = null;
  }

  @override
  @mustCallSuper
  void dispose() {
    _backgroundSnapshotController.dispose();
    _poppedNotifier.dispose();
    super.dispose();
  }
}

/// Adds imperative control methods for routes using
/// [UISheetTransitionMixin].
mixin UISheetController<T> on UISheetTransitionMixin<T> {
  /// Returns the active sheet controller from a context inside the sheet route.
  static UISheetController<T>? maybeOf<T>(BuildContext context) {
    final route = ModalRoute.of(context);

    if (route case final UISheetController<T> route) {
      return route;
    }

    return null;
  }

  /// Animates the sheet to a relative position without closing it.
  TickerFuture animateToRelative(double relativePosition, {bool snap = false}) {
    assert(
      relativePosition > 0.0 && relativePosition <= 1.0,
      'Relative position must be larger than 0.0 and less than or equal to 1.0',
    );

    assert(controller != null, 'Controller is null. Make sure the route is pushed before calling.');

    if (!isCurrent) return TickerFuture.complete();

    final double target;

    if (snap) {
      final config = effectiveSnappingConfig;

      target = switch (config.findClosestSnapPoint(relativePosition)) {
        0.0 => config.points.first,
        final value => value,
      };
    } else {
      target = relativePosition;
    }

    final simulation = motion.createSimulation(start: controller!.value, end: target, velocity: controller!.velocity);

    _animationTargetValue = target;
    _stickingPoint = target;

    return controller!.animateWith(simulation);
  }

  /// Overrides the sheet snapping configuration at runtime.
  TickerFuture overrideSnappingConfig(SheetSnappingConfig? newConfig, {bool animateToComply = false}) {
    assert(controller != null, 'Controller is null. Make sure the route is pushed before calling.');

    _snappingConfigOverride = newConfig;

    if (animateToComply && isCurrent) {
      final currentPosition = controller!.value;
      final targetPosition = effectiveSnappingConfig.findClosestSnapPoint(currentPosition);

      if ((targetPosition - currentPosition).abs() < 0.001) {
        return TickerFuture.complete();
      }

      final simulation = motion.createSimulation(
        start: currentPosition,
        end: targetPosition,
        velocity: controller!.velocity,
      );

      _animationTargetValue = targetPosition;
      _stickingPoint = targetPosition;

      return controller!.animateWith(simulation);
    }

    return TickerFuture.complete();
  }
}

/// Converts pixel drag updates from [ScrollDragDetector] into relative sheet
/// movement.
///
/// The sheet animation uses normalized values, where `1.0` is open and `0.0`
/// is closed. This adapter divides drag delta and velocity by the sheet's
/// reference height.
class _RelativeGestureDetector extends StatefulWidget {
  const _RelativeGestureDetector({
    required this.scrollableCanMoveBack,
    required this.onlyDragWhenScrollWasAtTop,
    required this.onRelativeDragStart,
    required this.onRelativeDragUpdate,
    required this.onRelativeDragEnd,
    required this.dismissalMode,
    required this.child,
  });

  final bool scrollableCanMoveBack;
  final bool onlyDragWhenScrollWasAtTop;
  final VoidCallback onRelativeDragStart;
  final void Function(double delta, double referenceHeight, bool wouldScroll) onRelativeDragUpdate;
  final void Function(double velocity, double referenceHeight, bool wouldScroll) onRelativeDragEnd;
  final SheetDismissalMode dismissalMode;
  final Widget child;

  @override
  State<_RelativeGestureDetector> createState() => _RelativeGestureDetectorState();
}

/// State for [_RelativeGestureDetector] widget.
class _RelativeGestureDetectorState extends State<_RelativeGestureDetector> {
  double? _referenceHeight;

  @override
  Widget build(BuildContext context) => ScrollDragDetector(
    onlyDragWhenScrollWasAtTop: widget.onlyDragWhenScrollWasAtTop,
    scrollableCanMoveBack: widget.scrollableCanMoveBack,
    onVerticalDragStart: (details, _) {
      _referenceHeight = SheetDismissalTransition.referenceHeightOf(context, widget.dismissalMode);
      widget.onRelativeDragStart();
    },
    onVerticalDragEnd: (details, willScroll) {
      if (_referenceHeight case final height?) {
        widget.onRelativeDragEnd(details.velocity.pixelsPerSecond.dy / height, height, willScroll);
      }
      _referenceHeight = null;
    },
    onVerticalDragUpdate: (details, wouldScroll) {
      if (_referenceHeight case final height?) {
        widget.onRelativeDragUpdate(details.primaryDelta! / height, height, wouldScroll);
      }
    },
    child: widget.child,
  );
}
