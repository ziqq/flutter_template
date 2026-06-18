import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/util/connectivity/connectivity_service.dart';
import 'package:ui/ui.dart';

/// {@template connectivity_scope}
/// ConnectivityScope widget.
/// Used to manage connectivity state and provide it to descendant widgets.
/// {@endtemplate}
class ConnectivityScope extends StatefulWidget {
  /// {@macro connectivity_scope}
  const ConnectivityScope({
    required this.child,
    this.lazy = false,
    super.key, // ignore: unused_element
  });

  /// Whether the controller should be initialized lazily.
  final bool lazy;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  State<ConnectivityScope> createState() => _ConnectivityScopeState();

  /// Get the connectivity status listenable.
  static ConnectivityStatusController of(BuildContext context) =>
      _InheritedConnectivity.of(context, aspect: _ConnectivityAspect.none).controller;

  /// Get the connectivity status.
  static Future<ConnectivityStatus> checkConnectivity(BuildContext context) =>
      _InheritedConnectivity.of(context).scope._service.check();
}

/// State for widget [ConnectivityScope].
class _ConnectivityScopeState extends State<ConnectivityScope> {
  late final IConnectivityService _service;

  @override
  void initState() {
    super.initState();
    _service = Dependencies.of(context).connectivityService;
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _InheritedConnectivity(scope: this, controller: _service.controller, child: widget.child);
}

/// Connectivity aspects for optimization.
enum _ConnectivityAspect {
  /// Do not notify about changes.
  none,

  /// Connection status changes.
  status,
}

/// Inherited widget for quick access in the element tree.
class _InheritedConnectivity extends InheritedModel<_ConnectivityAspect> {
  const _InheritedConnectivity({required this.controller, required this.scope, required super.child});

  /// The connectivity status listenable.
  final ConnectivityStatusController controller;

  /// The state of the [ConnectivityScope].
  final _ConnectivityScopeState scope;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// For example: `ConnectivityScope.maybeOf(context)`.
  static _InheritedConnectivity? maybeOf(
    BuildContext context, {
    _ConnectivityAspect aspect = _ConnectivityAspect.none,
  }) => switch (aspect) {
    // Do not notify about changes.
    _ConnectivityAspect.none => context.getInheritedWidgetOfExactType<_InheritedConnectivity>(),

    // Notify about changes in connectivity status.
    _ConnectivityAspect.status => InheritedModel.inheritFrom<_InheritedConnectivity>(
      context,
      aspect: _ConnectivityAspect.status,
    ),
  };

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a _InheritedConnectivity of the exact type',
    'out_of_scope',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `ConnectivityScope.of(context)`.
  static _InheritedConnectivity of(BuildContext context, {_ConnectivityAspect aspect = _ConnectivityAspect.none}) =>
      maybeOf(context, aspect: aspect) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant _InheritedConnectivity oldWidget) => controller != oldWidget.controller;

  @override
  bool updateShouldNotifyDependent(covariant _InheritedConnectivity oldWidget, Set<_ConnectivityAspect> dependencies) {
    for (final d in dependencies) {
      switch (d) {
        case _ConnectivityAspect.status when controller != oldWidget.controller:
          // Notify about changes in connectivity status.
          return true;
        default:
          continue;
      }
    }
    return false;
  }
}

/// A widget that wraps its child with connectivity status handling.
class ConnectivityWidget extends StatefulWidget {
  /// Creates a connectivity widget.
  const ConnectivityWidget({required this.child, super.key});

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

/// State for widget [ConnectivityWidget].
class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  /// Default animation duration.
  static const Duration _duration = Duration(milliseconds: 200);

  /// Default animation curve.
  static const Curve _curve = Curves.easeOut;

  /// Height of the banner
  final ValueNotifier<double> _bannerHeight = ValueNotifier<double>(0);

  @override
  void dispose() {
    _bannerHeight.dispose();
    super.dispose();
  }

  /// Callback when banner size changes.
  void _onBannerSize(Size s) {
    final h = s.height;
    if (h <= 0) return;

    // Avoid noisy updates (fractional changes).
    if ((h - _bannerHeight.value).abs() < 0.5) return;
    _bannerHeight.value = h;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ConnectivityScope.of(context);
    return ValueListenableBuilder<ConnectivityStatus>(
      valueListenable: controller,
      child: widget.child,
      builder: (context, state, child) {
        assert(child != null, 'Child must be passed as a parameter to avoid rebuilding');
        if (child == null) return const SizedBox.shrink();

        final offline = state == ConnectivityStatus.offline;
        final safeTop = MediaQuery.viewPaddingOf(context).top;

        return ValueListenableBuilder<double>(
          valueListenable: _bannerHeight,
          child: child,
          builder: (context, measuredHeight, child) {
            assert(child != null, 'Child must be passed as a parameter to avoid rebuilding');
            if (child == null) return const SizedBox.shrink();

            // Move the content only by the "visible" part of the banner (without safeTop),
            // otherwise, if there is a SafeArea in the screens, there will be a double indent.
            final shift = (measuredHeight - safeTop).clamp(0.0, double.infinity);

            return Stack(
              children: <Widget>[
                // Content smoothly shifts down/up in sync with the banner.
                AnimatedPadding(
                  padding: EdgeInsets.only(top: offline ? shift : 0),
                  duration: _duration,
                  curve: _curve,
                  child: child,
                ),

                // Optional: cover status-bar area with the same color while banner is animating,
                // so you won't see "black" through transparency.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: safeTop,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      curve: _curve,
                      duration: _duration,
                      opacity: offline ? 1 : 0,
                      child: ColoredBox(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),

                // --- Banner --- //
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: !offline,
                    child: AnimatedSlide(
                      curve: _curve,
                      duration: _duration,
                      offset: offline ? Offset.zero : const Offset(0, -1),
                      child: AnimatedOpacity(
                        curve: _curve,
                        duration: _duration,
                        opacity: offline ? 1 : 0,
                        child: MeasureSize(onChange: _onBannerSize, child: const _NoInternetBar()),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// A widget that displays a "No Internet Connection" bar.
class _NoInternetBar extends StatelessWidget {
  /// Creates a no internet bar.
  const _NoInternetBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final systemUIOverlayStyle = (theme.appBarTheme.systemOverlayStyle ?? SystemUiOverlayStyle.dark).copyWith(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: theme.uiTheme.color.background,
      systemNavigationBarIconBrightness: theme.brightness == .dark ? .light : .dark,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUIOverlayStyle,
      child: Material(
        color: theme.colorScheme.error,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.uiTheme.padding, vertical: theme.uiTheme.padding / 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  /* context.ext.l10n.app.noInternetConnectionTopBannerTitle */ 'No Internet Connection',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                Text(
                  /* context.ext.l10n.app.noInternetConnectionTopBannerSubtitle */ 'Please check your connection and try again',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: .8),
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that measures the size of its child and notifies when it changes.
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({required this.onChange, required Widget child, super.key}) : super(child: child);

  /// Change callback when size changes.
  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(BuildContext context, covariant RenderProxyBox renderObject) {
    if (renderObject case _RenderMeasureSize object) object.onChange = onChange;
  }
}

/// Render object for [MeasureSize].
class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}
