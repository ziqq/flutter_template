/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 30 July 2026
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/src/components/border_radius.dart';
import 'package:ui/src/components/flyout.dart';
import 'package:ui/src/localization/localization.dart';
import 'package:ui/src/theme/theme.dart';

/// Coordinates an ordered sequence of [UIShowcase] targets.
///
/// Targets register while they are mounted. If an active target is temporarily
/// unavailable, the controller waits for [targetWaitTimeout] before advancing
/// instead of leaving an undismissable overlay sequence behind.
class UIShowcaseController extends ChangeNotifier {
  /// Creates a controller for an ordered showcase sequence.
  UIShowcaseController({this.targetWaitTimeout = const .new(seconds: 5), this.onStart, this.onComplete, this.onFinish});

  /// Maximum time an active step waits for its target to mount.
  final Duration targetWaitTimeout;

  /// Called when a step becomes active.
  final ValueChanged<Object>? onStart;

  /// Called when a step completes and the sequence advances.
  final ValueChanged<Object>? onComplete;

  /// Called after the last available step completes.
  final VoidCallback? onFinish;

  final Set<Object> _registeredSteps = <Object>{};
  List<Object> _steps = const <Object>[];

  Timer? _targetWaitTimer;
  int? _activeIndex;

  bool _disposed = false;

  /// The currently active step, or `null` when no sequence is running.
  Object? get activeStep {
    final activeIndex = _activeIndex;
    if (activeIndex == null || activeIndex < 0 || activeIndex >= _steps.length) return null;
    return _steps[activeIndex];
  }

  /// Whether a sequence currently has an active step.
  bool get isRunning => activeStep != null;

  /// Whether [step] is the active showcase target.
  bool isActive(Object step) => activeStep == step;

  /// Registers a mounted showcase target.
  void register(Object step) {
    if (_disposed) return;
    _registeredSteps.add(step);
    if (activeStep == step) _targetWaitTimer?.cancel();
  }

  /// Unregisters a showcase target that is no longer mounted.
  void unregister(Object step) {
    if (_disposed) return;
    _registeredSteps.remove(step);
    if (activeStep == step) _scheduleTargetWait();
  }

  /// Starts [steps] from the first entry, preserving their supplied order.
  void start(Iterable<Object> steps) {
    if (_disposed) return;

    final uniqueSteps = <Object>[];
    for (final step in steps) {
      if (!uniqueSteps.contains(step)) uniqueSteps.add(step);
    }

    _targetWaitTimer?.cancel();
    _steps = List<Object>.unmodifiable(uniqueSteps);
    _activeIndex = _steps.isEmpty ? null : 0;

    if (activeStep case final Object step) onStart?.call(step);
    _scheduleTargetWait();
    notifyListeners();
  }

  /// Completes the active step and advances to the next step.
  void next() {
    if (_disposed) return;
    final currentStep = activeStep;
    final activeIndex = _activeIndex;
    if (currentStep == null || activeIndex == null) return;

    _targetWaitTimer?.cancel();
    onComplete?.call(currentStep);

    final nextIndex = activeIndex + 1;
    if (nextIndex >= _steps.length) {
      _clear();
      notifyListeners();
      onFinish?.call();
      return;
    }

    _activeIndex = nextIndex;
    if (activeStep case final Object step) onStart?.call(step);
    _scheduleTargetWait();
    notifyListeners();
  }

  /// Dismisses the complete sequence without completing its active step.
  void dismiss() {
    if (_disposed || !isRunning) return;
    _clear();
    notifyListeners();
  }

  void _scheduleTargetWait() {
    _targetWaitTimer?.cancel();
    final step = activeStep;
    if (step == null || _registeredSteps.contains(step)) return;

    _targetWaitTimer = Timer(targetWaitTimeout, () {
      if (_disposed || activeStep != step || _registeredSteps.contains(step)) return;
      next();
    });
  }

  void _clear() {
    _targetWaitTimer?.cancel();
    _targetWaitTimer = null;
    _steps = const <Object>[];
    _activeIndex = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _targetWaitTimer?.cancel();
    super.dispose();
  }
}

/// Makes a [UIShowcaseController] available to descendant showcase targets.
class UIShowcaseScope extends InheritedWidget {
  /// Creates a showcase scope controlled by [controller].
  const UIShowcaseScope({required this.controller, required super.child, super.key});

  /// Controller shared by showcase targets in this scope.
  final UIShowcaseController controller;

  /// Returns the closest controller, or `null` outside a showcase scope.
  static UIShowcaseController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UIShowcaseScope>()?.controller;

  /// Returns the closest controller.
  ///
  /// Throws an [ArgumentError] when no [UIShowcaseScope] is available.
  static UIShowcaseController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) throw ArgumentError('No UIShowcaseScope found in context.', 'context');
    return controller;
  }

  @override
  bool updateShouldNotify(covariant UIShowcaseScope oldWidget) => controller != oldWidget.controller;
}

/// Owns a showcase controller and starts an ordered sequence after a delay.
///
/// Use this around a screen section containing [UIShowcase] targets. The delay
/// begins after the first frame, allowing asynchronous screen transitions and
/// initial layout to settle before an overlay appears.
class UIShowcaseSequence extends StatefulWidget {
  /// Creates an automatically started showcase sequence.
  const UIShowcaseSequence({
    required this.steps,
    required this.child,
    this.startDelay = Duration.zero,
    this.targetWaitTimeout = const Duration(seconds: 5),
    this.onFinish,
    super.key,
  });

  /// Ordered identifiers matching descendant [UIShowcase.step] values.
  final List<Object> steps;

  /// Delay after the first frame before the sequence starts.
  final Duration startDelay;

  /// Maximum time to wait for each target to mount.
  final Duration targetWaitTimeout;

  /// Called after every step has completed or timed out.
  final VoidCallback? onFinish;

  /// Widget subtree containing the showcase targets.
  final Widget child;

  @override
  State<UIShowcaseSequence> createState() => _UIShowcaseSequenceState();
}

class _UIShowcaseSequenceState extends State<UIShowcaseSequence> {
  late UIShowcaseController _controller;
  Timer? _startTimer;
  int _startRevision = 0;

  @override
  void initState() {
    super.initState();
    _createController();
    _scheduleStart();
  }

  @override
  void didUpdateWidget(covariant UIShowcaseSequence oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.steps, widget.steps) &&
        oldWidget.startDelay == widget.startDelay &&
        oldWidget.targetWaitTimeout == widget.targetWaitTimeout) {
      return;
    }

    _startTimer?.cancel();
    _controller.dispose();
    _createController();
    _scheduleStart();
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _createController() {
    _controller = UIShowcaseController(
      targetWaitTimeout: widget.targetWaitTimeout,
      onFinish: () => widget.onFinish?.call(),
    );
  }

  void _scheduleStart() {
    final revision = ++_startRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || revision != _startRevision || widget.steps.isEmpty) return;
      if (widget.startDelay == Duration.zero) {
        _controller.start(widget.steps);
        return;
      }
      _startTimer = Timer(widget.startDelay, () {
        if (!mounted || revision != _startRevision) return;
        _controller.start(widget.steps);
      });
    });
  }

  @override
  Widget build(BuildContext context) => UIShowcaseScope(controller: _controller, child: widget.child);
}

/// Describes an optional call to action rendered inside a [UIShowcase] tooltip.
///
/// Use [UIShowcaseAction.next] for actions such as “Next” or “Continue”. It
/// completes the active step and finishes the sequence when used on its last
/// step. Use [UIShowcaseAction.dismiss] for an explicit cancellation that must
/// not report the active step as completed.
@immutable
class UIShowcaseAction {
  /// Creates an action that completes the active step and advances the sequence.
  const UIShowcaseAction.next({required this.label, this.onPressed}) : _dismissesSequence = false;

  /// Creates an action that dismisses the complete sequence without completing the active step.
  const UIShowcaseAction.dismiss({required this.label, this.onPressed}) : _dismissesSequence = true;

  /// Visible, localized button label.
  final String label;

  /// Called after the controller has advanced or dismissed the sequence.
  final VoidCallback? onPressed;

  final bool _dismissesSequence;
}

/// Highlights one target and presents an anchored instructional tooltip.
///
/// The widget is controlled by the nearest [UIShowcaseScope]. Barrier taps
/// advance the sequence, target taps either advance or run [onTargetTap], and
/// Escape dismisses the complete sequence. Outside a scope the [child] is
/// rendered unchanged.
class UIShowcase extends StatefulWidget {
  /// Creates a showcase target identified by [step].
  const UIShowcase({
    required this.step,
    required this.description,
    required this.child,
    this.onTargetTap,
    this.onTooltipTap,
    this.onBarrierTap,
    this.action,
    this.dismissOnTargetTap = false,
    this.targetBorderRadius,
    this.targetPadding = EdgeInsets.zero,
    this.barrierColor,
    this.tooltipColor,
    this.tooltipTextColor,
    this.tooltipMaxWidth = 280,
    this.tooltipGap = 8,
    this.semanticLabel,
    super.key,
  });

  /// Identifier used by [UIShowcaseController] to activate this target.
  final Object step;

  /// Instruction displayed in the anchored tooltip.
  final String description;

  /// Called when the highlighted target is tapped.
  ///
  /// When omitted, a target tap advances to the next sequence step.
  final VoidCallback? onTargetTap;

  /// Called when the tooltip is tapped.
  final VoidCallback? onTooltipTap;

  /// Called after a barrier tap advances the sequence.
  final VoidCallback? onBarrierTap;

  /// Optional call to action displayed below the tooltip description.
  ///
  /// The button owns its tap and accessibility semantics, so pressing it does
  /// not invoke [onTooltipTap].
  final UIShowcaseAction? action;

  /// Whether target or tooltip actions dismiss the complete sequence.
  final bool dismissOnTargetTap;

  /// Corner radius of the transparent target cutout.
  final BorderRadius? targetBorderRadius;

  /// Extra transparent space around the highlighted target.
  final EdgeInsets targetPadding;

  /// Color of the modal barrier outside the target cutout.
  final Color? barrierColor;

  /// Tooltip background color. Defaults to the active UI accent color.
  final Color? tooltipColor;

  /// Tooltip foreground color. Defaults to the color on the UI accent.
  final Color? tooltipTextColor;

  /// Maximum tooltip width before its text wraps.
  final double tooltipMaxWidth;

  /// Space between the highlighted target and tooltip.
  final double tooltipGap;

  /// Accessibility label for the highlighted target.
  final String? semanticLabel;

  /// Target widget rendered normally when this step is inactive.
  final Widget child;

  @override
  State<UIShowcase> createState() => _UIShowcaseState();
}

/// State for a [UIShowcase] widget.
class _UIShowcaseState extends State<UIShowcase> {
  UIShowcaseController? _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'UIShowcase');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateController(UIShowcaseScope.maybeOf(context));
  }

  @override
  void didUpdateWidget(covariant UIShowcase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step == widget.step) return;
    _controller
      ?..unregister(oldWidget.step)
      ..register(widget.step);
  }

  @override
  void dispose() {
    _controller?.unregister(widget.step);
    _focusNode.dispose();
    super.dispose();
  }

  void _updateController(UIShowcaseController? controller) {
    if (identical(_controller, controller)) return;
    if (_controller == controller) return;
    _controller?.unregister(widget.step);
    _controller = controller;
    _controller?.register(widget.step);
  }

  void _onTargetTap() {
    final controller = _controller;
    if (controller == null) return;

    final callback = widget.onTargetTap;
    if (callback == null) {
      controller.next();
      return;
    }

    if (widget.dismissOnTargetTap) controller.dismiss();
    callback();
  }

  void _onTooltipTap() {
    if (widget.dismissOnTargetTap) _controller?.dismiss();
    widget.onTooltipTap?.call();
  }

  void _onBarrierTap() {
    _controller?.next();
    widget.onBarrierTap?.call();
  }

  void _onActionTap() {
    final action = widget.action;
    final controller = _controller;
    if (controller == null || action == null) return;

    if (action._dismissesSequence) {
      controller.dismiss();
    } else {
      controller.next();
    }
    action.onPressed?.call();
  }

  Widget _buildBackdrop(BuildContext context, Rect targetRect) {
    final targetBorderRadius = widget.targetBorderRadius ?? UIBorderRadius.medium(context);
    final highlightedRect = Rect.fromLTRB(
      targetRect.left - widget.targetPadding.left,
      targetRect.top - widget.targetPadding.top,
      targetRect.right + widget.targetPadding.right,
      targetRect.bottom + widget.targetPadding.bottom,
    );

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () => _controller?.dismiss(),
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Semantics(
          container: true,
          scopesRoute: true,
          explicitChildNodes: true,
          label: widget.semanticLabel ?? widget.description,
          child: Stack(
            fit: .expand,
            children: <Widget>[
              BlockSemantics(
                child: Semantics(
                  button: true,
                  label: UILocalizations.of(context).actionNext,
                  onTap: _onBarrierTap,
                  child: GestureDetector(
                    excludeFromSemantics: true,
                    behavior: .opaque,
                    onTap: _onBarrierTap,
                    child: ClipPath(
                      clipper: _UIShowcaseBarrierClipper(
                        targetRect: highlightedRect,
                        targetBorderRadius: targetBorderRadius,
                      ),
                      child: ColoredBox(
                        color:
                            widget.barrierColor ?? CupertinoDynamicColor.resolve(kCupertinoModalBarrierColor, context),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: highlightedRect,
                child: Semantics(
                  button: true,
                  label: widget.semanticLabel ?? widget.description,
                  child: GestureDetector(
                    behavior: .opaque,
                    onTap: _onTargetTap,
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, UIFlyoutPlacement placement) {
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;
    final tooltipColor = widget.tooltipColor ?? uiTheme.color.accent;
    final tooltipTextColor = widget.tooltipTextColor ?? uiTheme.color.onAccent;
    final availableWidth = math.max(0.0, MediaQuery.widthOf(context) - uiTheme.size.offset.small * 2);

    return _UIShowcaseTooltip(
      color: tooltipColor,
      actionColor: tooltipTextColor,
      description: widget.description,
      actionLabel: widget.action?.label,
      textStyle: theme.textTheme.labelSmall?.copyWith(color: tooltipTextColor, fontWeight: .normal, height: 1),
      maxWidth: math.min(widget.tooltipMaxWidth, availableWidth),
      borderRadius: UIBorderRadius.regular(context),
      padding: .all(uiTheme.size.offset.small),
      pointsUp: !placement.flippedVertically,
      onTap: widget.onTooltipTap == null ? null : _onTooltipTap,
      onActionTap: widget.action == null ? null : _onActionTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isOpen = controller.isActive(widget.step);
        if (isOpen && !_focusNode.hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && controller.isActive(widget.step)) _focusNode.requestFocus();
          });
        }

        return UIFlyout(
          isOpen: isOpen,
          anchor: UIFlyoutAnchor(
            anchorAlignment: .bottomCenter,
            flyoutAlignment: .topCenter,
            offset: Offset(0, widget.tooltipGap),
          ),
          backdropBuilder: _buildBackdrop,
          flyoutBuilder: _buildTooltip,
          child: widget.child,
        );
      },
    );
  }
}

/// Clips a rectangular barrier with a rounded rectangle cutout for the highlighted target.
class _UIShowcaseBarrierClipper extends CustomClipper<Path> {
  const _UIShowcaseBarrierClipper({required this.targetRect, required this.targetBorderRadius});

  final Rect targetRect;
  final BorderRadius targetBorderRadius;

  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addRRect(targetBorderRadius.toRRect(targetRect));

  @override
  bool shouldReclip(covariant _UIShowcaseBarrierClipper oldClipper) =>
      targetRect != oldClipper.targetRect || targetBorderRadius != oldClipper.targetBorderRadius;
}

/// Displays the animated instructional content anchored to a showcase target.
class _UIShowcaseTooltip extends StatefulWidget {
  /// Creates tooltip content whose width is determined by [description].
  const _UIShowcaseTooltip({
    required this.description,
    required this.actionLabel,
    required this.color,
    required this.actionColor,
    required this.textStyle,
    required this.padding,
    required this.borderRadius,
    required this.maxWidth,
    required this.pointsUp,
    required this.onTap,
    required this.onActionTap,
  });

  /// Instructional copy displayed for the highlighted target.
  final String description;

  /// Optional localized label for the tooltip action.
  final String? actionLabel;

  /// Background color shared by the tooltip body and arrow.
  final Color color;

  /// Foreground color used by the optional action.
  final Color actionColor;

  /// Typography applied to [description].
  final TextStyle? textStyle;

  /// Insets between the tooltip boundary and its content.
  final EdgeInsets padding;

  /// Shape applied to the tooltip body and action background.
  final BorderRadius borderRadius;

  /// Maximum width available to the instructional copy.
  final double maxWidth;

  /// Whether the arrow points upward toward the target.
  final bool pointsUp;

  /// Called when the instructional copy is tapped.
  final VoidCallback? onTap;

  /// Called when the optional action is tapped.
  final VoidCallback? onActionTap;

  @override
  State<_UIShowcaseTooltip> createState() => _UIShowcaseTooltipState();
}

/// State for a [_UIShowcaseTooltip] widget.
class _UIShowcaseTooltipState extends State<_UIShowcaseTooltip> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  /// Arrow pointing to the highlighted target.
  late final _arrow = CustomPaint(
    size: const Size(16, 8),
    painter: _UIShowcaseArrowPainter(color: widget.color, pointsUp: widget.pointsUp),
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _opacity = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationController.isAnimating || _animationController.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _animationController.value = 1;
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = Text(
      widget.description,
      style: widget.textStyle,
      textAlign: .start,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    final interactiveDescription = switch (widget.onTap) {
      final onTap? => Semantics(
        button: true,
        child: GestureDetector(excludeFromSemantics: true, behavior: .opaque, onTap: onTap, child: description),
      ),
      _ => description,
    };
    final actionButton = switch ((widget.actionLabel, widget.onActionTap)) {
      (final actionLabel?, final onActionTap?) => SizedBox(
        height: theme.uiTheme.size.button.extraExtraSmall,
        child: CupertinoButton(
          onPressed: onActionTap,
          borderRadius: widget.borderRadius,
          foregroundColor: widget.actionColor,
          color: widget.actionColor.withValues(alpha: 0.16),
          padding: .symmetric(horizontal: theme.uiTheme.size.offset.small),
          minimumSize: Size.square(theme.uiTheme.size.button.extraExtraSmall),
          child: Center(
            widthFactor: 1,
            child: Text(
              actionLabel,
              textAlign: .center,
              style: theme.textTheme.labelSmall?.copyWith(color: widget.actionColor, fontWeight: .w500, height: 1),
            ),
          ),
        ),
      ),
      _ => null,
    };
    final content = switch (actionButton) {
      final actionButton? => Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Padding(
            padding: .only(bottom: theme.uiTheme.size.button.extraExtraSmall + theme.uiTheme.size.offset.small),
            child: interactiveDescription,
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: Align(alignment: .centerEnd, child: actionButton),
          ),
        ],
      ),
      _ => interactiveDescription,
    };
    final body = Material(
      color: widget.color,
      borderRadius: widget.borderRadius,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: Padding(padding: widget.padding, child: content),
      ),
    );

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        alignment: widget.pointsUp ? .topCenter : .bottomCenter,
        child: Semantics(
          container: true,
          liveRegion: true,
          explicitChildNodes: true,
          child: Column(
            mainAxisSize: .min,
            children: widget.pointsUp ? <Widget>[_arrow, body] : <Widget>[body, _arrow],
          ),
        ),
      ),
    );
  }
}

class _UIShowcaseArrowPainter extends CustomPainter {
  const _UIShowcaseArrowPainter({required this.color, required this.pointsUp});

  final Color color;
  final bool pointsUp;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _UIShowcaseArrowPainter oldDelegate) =>
      color != oldDelegate.color || pointsUp != oldDelegate.pointsUp;
}
