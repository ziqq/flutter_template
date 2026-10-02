/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 */

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:ui' as ui show FragmentProgram, FragmentShader;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:ui/ui.dart';

/// {@template shimmer}
/// Draws a moving highlight used to represent loading content.
///
/// Place related placeholders in a [UIShimmerGroup] to share one animation
/// clock and shader. Compose the skeleton with ordinary Flutter layout widgets
/// so it remains responsive without manually calculating paint coordinates.
///
/// {@tool snippet}
/// ```dart
/// const Shimmer(
///   size: Size(180, 16),
///   cornerRadius: 8,
///   alignment: Alignment.centerLeft,
/// )
/// ```
/// {@end-tool}
/// {@endtemplate}
/// {@category shaders}
class Shimmer extends StatefulWidget {
  /// {@macro shimmer}
  const Shimmer({
    this.color,
    this.backgroundColor,
    this.speed = 15 / 8000000,
    this.stripeWidth = .2,
    this.size = const Size(128, 28),
    this.cornerRadius = 8,
    this.initialSeed = .0,
    this.alignment = Alignment.center,
    this.maxFramesPerSecond = 60,
    bool? isSecondary,
    super.key,
  }) : assert(maxFramesPerSecond > 0 && maxFramesPerSecond <= 240, 'Shimmer frame rate must be between 1 and 240 FPS.'),
       _isSecondary = isSecondary ?? false;

  /// Shimmer with secondary colors.
  /// {@macro shimmer}
  const Shimmer.secondary({
    this.color,
    this.backgroundColor,
    this.speed = 15 / 8000000,
    this.stripeWidth = .2,
    this.size = const Size(128, 28),
    this.cornerRadius = 8,
    this.initialSeed = .0,
    this.alignment = Alignment.center,
    this.maxFramesPerSecond = 60,
    super.key,
  }) : assert(maxFramesPerSecond > 0 && maxFramesPerSecond <= 240, 'Shimmer frame rate must be between 1 and 240 FPS.'),
       _isSecondary = true;

  /// The asset path to the shader code.
  static const String _shaderAsset = 'packages/ui/lib/shaders/shimmer.frag';

  /// The color used for the moving highlight.
  final Color? color;

  /// The color painted behind the moving highlight.
  final Color? backgroundColor;

  /// The radius of the placeholder corners in logical pixels.
  final double cornerRadius;

  /// The normalized width of the moving highlight.
  final double stripeWidth;

  /// The initial phase of the animation.
  final double initialSeed;

  /// The phase advance per elapsed microsecond.
  final double speed;

  /// The placeholder size in logical pixels.
  final Size size;

  /// The alignment of the placeholder within its parent.
  final AlignmentGeometry alignment;

  /// Maximum number of repaint notifications emitted per second.
  ///
  /// The default keeps shimmer work at 60 FPS on high-refresh displays. When
  /// this shimmer belongs to a [UIShimmerGroup], the group's value takes
  /// precedence so every descendant stays on the same cadence.
  final int maxFramesPerSecond;

  final bool _isSecondary;

  /// The default height of a placeholder line.
  static double height = 12;

  /// Returns the primary shimmer color for the current theme.
  static Color getColor(BuildContext context, {bool isSecondary = false}) =>
      _resolveShimmerColor(Theme.of(context), isSecondary: isSecondary);

  /// Returns the background color used behind the shimmer highlight.
  static Color getBackgroundColor(BuildContext context, {bool isSecondary = false}) =>
      _resolveShimmerBackgroundColor(Theme.of(context), isSecondary: isSecondary);

  /// Returns the color used for child placeholders within the shimmer.
  static Color getChildrenColor(BuildContext context, {bool isSecondary = false}) {
    final theme = Theme.of(context);
    return isSecondary
        ? theme.uiTheme.color.secondaryBackground
        : (theme.brightness == Brightness.dark)
        ? theme.uiTheme.color.secondaryBackground
        : theme.uiTheme.color.background;
  }

  @override
  State<Shimmer> createState() => _ShimmerState();
}

/// {@template shimmer_group}
/// Hosts shimmer renderers on one animation clock and one shader instance.
///
/// The group publishes animation changes to one repaint boundary. Descendant
/// painters read the shared elapsed value during that paint instead of each
/// subscribing to the clock. The group isolates repaints from the surrounding
/// widget tree and stops its ticker when no shimmer descendants are attached,
/// [TickerMode] is disabled, the platform requests reduced motion, or its
/// repaint boundary is culled from painting. Equal speed and seed values keep
/// individual placeholders in phase. Descendants keep using normal Flutter
/// layout, so their dimensions and spacing adapt to constraints and text scale.
/// Set [constrained] from a measured device policy to cap the shared clock at
/// 30 FPS without changing placeholder geometry or synchronization.
///
/// {@tool snippet}
/// ```dart
/// const UIShimmerGroup(
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: <Widget>[
///       Shimmer(size: Size(220, 16)),
///       SizedBox(height: 12),
///       Shimmer(size: Size(160, 12)),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
/// {@endtemplate}
/// {@category shaders}
class UIShimmerGroup extends StatefulWidget {
  /// {@macro shimmer_group}
  const UIShimmerGroup({
    required this.child,
    this.maxFramesPerSecond = 60,
    this.constrained = false,
    this.pauseWhenNotPainted = true,
    super.key,
  }) : assert(maxFramesPerSecond > 0 && maxFramesPerSecond <= 240, 'Shimmer frame rate must be between 1 and 240 FPS.');

  /// The shimmer placeholders that should share rendering resources.
  final Widget child;

  /// Maximum number of repaint notifications emitted per second.
  ///
  /// Keep the default for loading placeholders. Raise this only when a measured
  /// interaction requires matching a high-refresh display.
  final int maxFramesPerSecond;

  /// Whether to cap this group at 30 FPS for a measured constrained device.
  ///
  /// The cap reduces animation publications without changing layout, phase
  /// synchronization, or the requested [maxFramesPerSecond] on other devices.
  /// Derive this signal from device performance measurements or rollout data.
  final bool constrained;

  /// Whether to pause the shared ticker while the group is not painted.
  ///
  /// The nearest scrollable viewport is observed without rebuilding the group.
  /// A group outside that viewport stops immediately. Paint tracking also
  /// stops work when an ancestor culls the render subtree. Disable this only
  /// when an ancestor intentionally reuses a retained layer without visiting
  /// the group's paint method.
  final bool pauseWhenNotPainted;

  int get _effectiveMaxFramesPerSecond => constrained ? math.min(maxFramesPerSecond, 30) : maxFramesPerSecond;

  @override
  State<UIShimmerGroup> createState() => _UIShimmerGroupState();
}

final class _ShimmerShaderLoader {
  ui.FragmentProgram? get program => _program;
  ui.FragmentProgram? _program;
  Future<bool>? _$load;

  Future<bool> ensureLoaded() => _$load ??= _load();

  Future<bool> _load() async {
    try {
      _program = await ui.FragmentProgram.fromAsset(Shimmer._shaderAsset).timeout(const Duration(seconds: 5));
      return true;
    } on Object catch (error, stackTrace) {
      if (!kReleaseMode && error is! UnsupportedError) {
        dev.log('Failed to load shader: $error', error: error, stackTrace: stackTrace, name: 'UIShimmer');
      }
      return false;
    }
  }
}

final _ShimmerShaderLoader _shimmerShader = _ShimmerShaderLoader();

const _shimmerDirectionX = .866;
const _shimmerDirectionY = .5;
const _shimmerPi = 3.1415;

final class _ShimmerAnimation extends ChangeNotifier {
  _ShimmerAnimation(TickerProvider vsync, {required int maxFramesPerSecond, this.pauseWhenNotPainted = false})
    : _cadence = ShimmerFrameCadence(maxFramesPerSecond) {
    _ticker = vsync.createTicker(_handleTick);
  }

  late final Ticker _ticker;
  final ShimmerFrameCadence _cadence;
  ui.FragmentShader? _shader;
  ui.FragmentShader? _configuredShader;
  bool _hasShaderConfiguration = false;
  Size _configuredSize = Size.zero;
  Color _configuredColor = Colors.transparent;
  Color _configuredBackgroundColor = Colors.transparent;
  double _configuredStripeWidth = 0;
  double? _configuredSeed;
  Duration _elapsed = Duration.zero;
  int _consumers = 0;
  bool _enabled = true;
  bool pauseWhenNotPainted;
  bool _paintedSinceLastPublication = true;
  bool _paintVisible = true;
  bool _viewportVisible = true;
  bool _disposed = false;
  Future<void>? _$initialization;

  Duration get elapsed => _elapsed;

  void attach() {
    _consumers++;
    if (_shader == null) unawaited(_$initialization ??= _initialize());
    _syncTicker();
  }

  void detach() {
    assert(_consumers > 0, 'A shimmer animation cannot detach more consumers than it attached.');
    if (_consumers == 0) return;
    _consumers--;
    _syncTicker();
  }

  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    _syncTicker();
  }

  void setMaxFramesPerSecond(int value) {
    _cadence.setMaxFramesPerSecond(value);
  }

  void setPauseWhenNotPainted(bool value) {
    if (pauseWhenNotPainted == value) return;
    pauseWhenNotPainted = value;
    _paintedSinceLastPublication = true;
    _paintVisible = true;
    _viewportVisible = true;
    _syncTicker();
  }

  void setViewportVisible(bool value) {
    if (_viewportVisible == value) return;
    _viewportVisible = value;
    if (value) {
      _paintVisible = true;
      _paintedSinceLastPublication = true;
    }
    _syncTicker();
  }

  void markPainted() {
    if (!pauseWhenNotPainted) return;
    _paintedSinceLastPublication = true;
    if (_paintVisible) return;
    _paintVisible = true;
    _syncTicker();
  }

  ui.FragmentShader? configureShader({
    required Size size,
    required double seed,
    required double stripeWidth,
    required Color color,
    required Color backgroundColor,
  }) {
    final shader = _shader;
    if (shader == null) return null;
    final shaderChanged = !identical(_configuredShader, shader);
    if (shaderChanged ||
        !_hasShaderConfiguration ||
        _configuredSize != size ||
        _configuredColor != color ||
        _configuredBackgroundColor != backgroundColor ||
        _configuredStripeWidth != stripeWidth) {
      _configuredShader = shader;
      _hasShaderConfiguration = true;
      _configuredSize = size;
      _configuredColor = color;
      _configuredBackgroundColor = backgroundColor;
      _configuredStripeWidth = stripeWidth;
      final projectionScale = stripeWidth * _shimmerPi;
      shader
        ..setFloat(0, _shimmerDirectionX * projectionScale / math.max(size.width, 1.0))
        ..setFloat(1, _shimmerDirectionY * projectionScale / math.max(size.height, 1.0))
        ..setFloat(3, color.r)
        ..setFloat(4, color.g)
        ..setFloat(5, color.b)
        ..setFloat(6, color.a)
        ..setFloat(7, backgroundColor.r)
        ..setFloat(8, backgroundColor.g)
        ..setFloat(9, backgroundColor.b)
        ..setFloat(10, backgroundColor.a);
    }
    if (shaderChanged || _configuredSeed != seed) {
      _configuredSeed = seed;
      shader.setFloat(2, seed);
    }
    return shader;
  }

  Future<void> _initialize() async {
    if (!await _shimmerShader.ensureLoaded() || _disposed || _shader != null) return;
    _shader = _shimmerShader.program!.fragmentShader();
    notifyListeners();
    _syncTicker();
  }

  void _handleTick(Duration value) {
    _elapsed = value;
    if (!_cadence.shouldPublish(value)) return;
    if (pauseWhenNotPainted) {
      if (!_paintedSinceLastPublication) {
        _paintVisible = false;
        _syncTicker();
        return;
      }
      _paintedSinceLastPublication = false;
    }
    notifyListeners();
  }

  void _syncTicker() {
    if (_disposed) return;
    final shouldTick =
        _enabled && _consumers > 0 && _shader != null && (!pauseWhenNotPainted || (_paintVisible && _viewportVisible));
    if (shouldTick) {
      if (!_ticker.isActive) {
        _elapsed = Duration.zero;
        _cadence.reset();
        _ticker.start();
      }
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.dispose();
    _configuredShader = null;
    _hasShaderConfiguration = false;
    _configuredSeed = null;
    _shader?.dispose();
    _shader = null;
    super.dispose();
  }
}

final class _ShimmerGroupScope extends InheritedWidget {
  const _ShimmerGroupScope({required this.animation, required super.child});

  final _ShimmerAnimation animation;

  static _ShimmerAnimation? animationOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerGroupScope>()?.animation;

  @override
  bool updateShouldNotify(_ShimmerGroupScope oldWidget) => !identical(animation, oldWidget.animation);
}

final class _ShimmerRepaintBoundary extends SingleChildRenderObjectWidget {
  const _ShimmerRepaintBoundary({required this.animation, required super.child, super.key});

  final _ShimmerAnimation animation;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderShimmerRepaintBoundary(animation);

  @override
  void updateRenderObject(BuildContext context, covariant _RenderShimmerRepaintBoundary renderObject) {
    renderObject.animation = animation;
  }
}

final class _RenderShimmerRepaintBoundary extends RenderProxyBox {
  _RenderShimmerRepaintBoundary(this._animation);

  _ShimmerAnimation _animation;

  _ShimmerAnimation get animation => _animation;

  set animation(_ShimmerAnimation value) {
    if (identical(value, _animation)) return;
    if (attached) _animation.removeListener(markNeedsPaint);
    _animation = value;
    if (attached) _animation.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    _animation.markPainted();
    super.paint(context, offset);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsPaint);
    super.detach();
  }
}

final class _UIShimmerGroupState extends State<UIShimmerGroup> with SingleTickerProviderStateMixin {
  late final _ShimmerAnimation _animation = _ShimmerAnimation(
    this,
    maxFramesPerSecond: widget._effectiveMaxFramesPerSecond,
    pauseWhenNotPainted: widget.pauseWhenNotPainted,
  );
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  ScrollPosition? _scrollPosition;
  bool _viewportUpdateScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.setEnabled(
      TickerMode.valuesOf(context).enabled && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false),
    );
    final scrollPosition = Scrollable.maybeOf(context)?.position;
    if (!identical(_scrollPosition, scrollPosition)) {
      _scrollPosition?.removeListener(_scheduleViewportUpdate);
      _scrollPosition = scrollPosition;
      _scrollPosition?.addListener(_scheduleViewportUpdate);
    }
    _scheduleViewportUpdate();
  }

  @override
  void didUpdateWidget(covariant UIShimmerGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._effectiveMaxFramesPerSecond != widget._effectiveMaxFramesPerSecond) {
      _animation.setMaxFramesPerSecond(widget._effectiveMaxFramesPerSecond);
    }
    if (oldWidget.pauseWhenNotPainted != widget.pauseWhenNotPainted) {
      _animation.setPauseWhenNotPainted(widget.pauseWhenNotPainted);
      _scheduleViewportUpdate();
    }
  }

  void _scheduleViewportUpdate() {
    if (_viewportUpdateScheduled) return;
    _viewportUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewportUpdateScheduled = false;
      if (mounted) _syncViewportVisibility();
    });
  }

  void _syncViewportVisibility() {
    if (!widget.pauseWhenNotPainted) {
      _animation.setViewportVisible(true);
      return;
    }
    final renderObject = _repaintBoundaryKey.currentContext?.findRenderObject();
    final scrollPosition = _scrollPosition;
    final viewport = RenderAbstractViewport.maybeOf(renderObject);
    if (renderObject == null || !renderObject.attached || scrollPosition == null || viewport == null) {
      _animation.setViewportVisible(true);
      return;
    }
    final leadingOffset = viewport.getOffsetToReveal(renderObject, 0).offset;
    final trailingOffset = viewport.getOffsetToReveal(renderObject, 1).offset;
    final start = math.min(leadingOffset, trailingOffset);
    final end = math.max(leadingOffset, trailingOffset);
    final viewportStart = scrollPosition.pixels;
    final viewportEnd = viewportStart + scrollPosition.viewportDimension;
    _animation.setViewportVisible(end > viewportStart && start < viewportEnd);
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_scheduleViewportUpdate);
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ShimmerRepaintBoundary(
    key: _repaintBoundaryKey,
    animation: _animation,
    child: _ShimmerGroupScope(animation: _animation, child: widget.child),
  );
}

mixin _ShimmerAnimationStateMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  _ShimmerAnimation? _animation;
  _ShimmerAnimation? _localAnimation;
  _ShimmerAnimation? _groupAnimation;

  _ShimmerAnimation get shimmerAnimation => _animation!;
  bool get usesShimmerGroup => _groupAnimation != null;

  void configureShimmerAnimation({required int maxFramesPerSecond}) {
    final groupAnimation = _ShimmerGroupScope.animationOf(context);
    if (_animation != null && identical(_groupAnimation, groupAnimation)) {
      _localAnimation?.setMaxFramesPerSecond(maxFramesPerSecond);
      _syncShimmerAnimationMode();
      return;
    }

    _groupAnimation?.detach();
    _localAnimation?.dispose();
    _localAnimation = null;
    _groupAnimation = groupAnimation;
    _animation = groupAnimation ?? (_localAnimation = _ShimmerAnimation(this, maxFramesPerSecond: maxFramesPerSecond));
    _animation!.attach();
    _syncShimmerAnimationMode();
  }

  void updateLocalShimmerFrameRate(int maxFramesPerSecond) {
    _localAnimation?.setMaxFramesPerSecond(maxFramesPerSecond);
  }

  void disposeShimmerAnimation() {
    _groupAnimation?.detach();
    _localAnimation?.dispose();
    _animation = null;
    _groupAnimation = null;
    _localAnimation = null;
  }

  void _syncShimmerAnimationMode() {
    if (_groupAnimation != null) return;
    _animation?.setEnabled(
      TickerMode.valuesOf(context).enabled && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false),
    );
  }
}

class _ShimmerState extends State<Shimmer> with TickerProviderStateMixin, _ShimmerAnimationStateMixin<Shimmer> {
  late final ValueNotifier<_ShimmerPaintConfiguration> _configuration;
  bool _configurationInitialized = false;
  late CustomPainter _painter;
  _ShimmerAnimation? _painterAnimation;
  bool? _painterUsesShimmerGroup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    configureShimmerAnimation(maxFramesPerSecond: widget.maxFramesPerSecond);
    _syncPaintConfiguration();
    _configurePainter();
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateLocalShimmerFrameRate(widget.maxFramesPerSecond);
    _syncPaintConfiguration();
  }

  @override
  void dispose() {
    disposeShimmerAnimation();
    if (_configurationInitialized) _configuration.dispose();
    super.dispose();
  }

  void _syncPaintConfiguration() {
    final theme = Theme.of(context);
    final next = (
      color: widget.color ?? _resolveShimmerColor(theme, isSecondary: widget._isSecondary),
      backgroundColor:
          widget.backgroundColor ?? _resolveShimmerBackgroundColor(theme, isSecondary: widget._isSecondary),
      cornerRadius: widget.cornerRadius,
      stripeWidth: widget.stripeWidth,
      initialSeed: widget.initialSeed,
      speed: widget.speed,
    );
    if (_configurationInitialized) {
      _configuration.value = next;
    } else {
      _configuration = ValueNotifier<_ShimmerPaintConfiguration>(next);
      _configurationInitialized = true;
    }
  }

  void _configurePainter() {
    if (identical(_painterAnimation, shimmerAnimation) && _painterUsesShimmerGroup == usesShimmerGroup) return;
    _painterAnimation = shimmerAnimation;
    _painterUsesShimmerGroup = usesShimmerGroup;
    _painter = _ShimmerPainter(
      animation: shimmerAnimation,
      configurationListenable: _configuration,
      animationDrivenByAncestor: usesShimmerGroup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = SizedBox.fromSize(
      size: widget.size,
      child: CustomPaint(size: widget.size, painter: _painter, willChange: true),
    );
    return Align(
      alignment: widget.alignment,
      child: usesShimmerGroup ? result : RepaintBoundary(child: result),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({
    required this.animation,
    required this.configurationListenable,
    required bool animationDrivenByAncestor,
  }) : super(
         repaint: animationDrivenByAncestor
             ? configurationListenable
             : Listenable.merge(<Listenable>[animation, configurationListenable]),
       );

  final _ShimmerAnimation animation;
  final ValueListenable<_ShimmerPaintConfiguration> configurationListenable;
  final Paint _paint = Paint();
  Size? _cachedSize;
  double? _cachedCornerRadius;
  RRect _rrect = RRect.zero;

  @override
  void paint(Canvas canvas, Size size) {
    final configuration = configurationListenable.value;
    if (_cachedSize != size || _cachedCornerRadius != configuration.cornerRadius) {
      _cachedSize = size;
      _cachedCornerRadius = configuration.cornerRadius;
      _rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(configuration.cornerRadius));
    }
    _configureShimmerPaint(
      paint: _paint,
      animation: animation,
      size: size,
      seed: configuration.initialSeed + animation.elapsed.inMicroseconds * configuration.speed,
      stripeWidth: configuration.stripeWidth,
      color: configuration.color,
      backgroundColor: configuration.backgroundColor,
    );
    canvas.drawRRect(_rrect, _paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) =>
      !identical(oldDelegate.animation, animation) ||
      !identical(oldDelegate.configurationListenable, configurationListenable);
}

typedef _ShimmerPaintConfiguration = ({
  Color color,
  Color backgroundColor,
  double cornerRadius,
  double stripeWidth,
  double initialSeed,
  double speed,
});

void _configureShimmerPaint({
  required Paint paint,
  required _ShimmerAnimation animation,
  required Size size,
  required double seed,
  required double stripeWidth,
  required Color color,
  required Color backgroundColor,
}) {
  final shader = animation.configureShader(
    size: size,
    seed: seed,
    stripeWidth: stripeWidth,
    color: color,
    backgroundColor: backgroundColor,
  );
  if (shader == null) {
    paint
      ..shader = null
      ..color = backgroundColor;
    return;
  }
  paint
    ..color = Colors.white
    ..shader = shader;
}

Color _resolveShimmerColor(ThemeData theme, {required bool isSecondary}) => isSecondary
    ? theme.brightness == Brightness.dark
          ? theme.uiTheme.color.onBackground.darken(0.03)
          : theme.uiTheme.color.onSecondaryBackground
    : theme.uiTheme.color.onBackground.darken(0.03);

Color _resolveShimmerBackgroundColor(ThemeData theme, {required bool isSecondary}) => isSecondary
    ? theme.brightness == Brightness.dark
          ? theme.uiTheme.color.onBackground.lighten(0.01)
          : theme.uiTheme.color.secondaryBackground.lighten(0.015)
    : theme.uiTheme.color.onBackground.lighten(0.01);

/// Controls when a shimmer animation publishes a new visual frame.
///
/// This type is internal to the UI package. Its name remains accessible to the
/// package test suite so cadence can be verified without coupling the test to a
/// GPU renderer or a forced widget-test paint cycle.
@internal
final class ShimmerFrameCadence {
  /// Creates a cadence capped at [maxFramesPerSecond].
  ShimmerFrameCadence(int maxFramesPerSecond)
    : assert(maxFramesPerSecond > 0 && maxFramesPerSecond <= 240, 'Shimmer frame rate must be between 1 and 240 FPS.'),
      _minimumFrameIntervalUs = _frameIntervalInMicrosecondsFor(maxFramesPerSecond);

  int _minimumFrameIntervalUs;
  int _nextPublicationElapsedUs = 0;
  bool _hasPublishedFrame = false;

  /// Updates the maximum publication rate and starts a new cadence window.
  void setMaxFramesPerSecond(int value) {
    assert(value > 0 && value <= 240, 'Shimmer frame rate must be between 1 and 240 FPS.');
    final intervalUs = _frameIntervalInMicrosecondsFor(value);
    if (_minimumFrameIntervalUs == intervalUs) return;
    _minimumFrameIntervalUs = intervalUs;
    reset();
  }

  /// Returns whether a frame at [elapsed] should be published.
  bool shouldPublish(Duration elapsed) {
    final elapsedUs = elapsed.inMicroseconds;
    if (_hasPublishedFrame && elapsedUs < _nextPublicationElapsedUs) return false;
    _hasPublishedFrame = true;
    _nextPublicationElapsedUs = ((elapsedUs ~/ _minimumFrameIntervalUs) + 1) * _minimumFrameIntervalUs;
    return true;
  }

  /// Resets the cadence for a newly started ticker.
  void reset() {
    _nextPublicationElapsedUs = 0;
    _hasPublishedFrame = false;
  }
}

int _frameIntervalInMicrosecondsFor(int framesPerSecond) => Duration.microsecondsPerSecond ~/ framesPerSecond;
