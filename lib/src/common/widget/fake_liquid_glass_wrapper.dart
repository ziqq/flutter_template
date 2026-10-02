/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 05 August 2026
 */

import 'dart:ui' as ui show ImageFilter, lerpDouble;

import 'package:flutter/material.dart' show Theme, Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:ui/ui.dart';

/// Adds liquid-glass styling and pointer feedback to an interactive foreground.
///
/// With the beta liquid theme enabled, the glass surface expands on hover and
/// press while only [child] fades. This keeps the circular highlight visible
/// around icons such as the common back button.
/// {@macro button}
class FakeLiquidGlassWrapper extends StatelessWidget {
  /// {@macro button}
  const FakeLiquidGlassWrapper({
    this.child,
    this.onTap,
    this.scale,
    this.borderRadius,
    this.opacity = .3,
    this.primary = true,
    this.useIOS26LiquidThemeOverride,
    super.key, // ignore: unused_element_parameter
  }) : assert(opacity >= 0 && opacity <= 1, 'Opacity must be in the range [0, 1].');

  /// {@macro button}
  const FakeLiquidGlassWrapper.secondary({
    this.child,
    this.onTap,
    this.scale,
    this.borderRadius,
    this.opacity = .3,
    this.useIOS26LiquidThemeOverride,
    super.key, // ignore: unused_element_parameter
  }) : assert(opacity >= 0 && opacity <= 1, 'Opacity must be in the range [0, 1].'),
       primary = false;

  /// Whether to use the iOS 26 liquid theme override.
  /// This is a temporary flag to enable the iOS 26 liquid theme for testing purposes.
  final bool? useIOS26LiquidThemeOverride;

  /// The border radius of the widget.
  final BorderRadius? borderRadius;

  /// The tap callback that is called when the widget is pressed.
  final VoidCallback? onTap;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// The intermediate [PressTransition] progress used while hovering.
  ///
  /// Values must be in the inclusive range from `0` to `1`.
  final double opacity;

  // TODO(ziqq): Provide a custom scale value?
  // Anton Ustinoff <a.a.ustinoff@gmail.com>, 05 August 2026
  final double? scale;

  /// Whether the glass surface uses the primary shadow treatment.
  final bool primary;

  static const double _hoverOpacity = .72;
  static const double _pressedOpacity = .35;

  double _resolveOpacity(double progress) {
    final normalizedProgress = progress.clamp(0.0, 1.0).toDouble();
    if (opacity == 0) return ui.lerpDouble(1, _pressedOpacity, normalizedProgress) ?? 1;
    if (normalizedProgress <= opacity) return ui.lerpDouble(1, _hoverOpacity, normalizedProgress / opacity) ?? 1;
    return ui.lerpDouble(_hoverOpacity, _pressedOpacity, (normalizedProgress - opacity) / (1 - opacity)) ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = SettingsScope.userPreferencesOf(context);
    // TODO(ziqq): Remove this check when the beta feature is stable.
    // Anton Ustinoff <a.a.ustinoff@gmail.com>, 05 August 2026
    if (useIOS26LiquidThemeOverride != true && !prefs.useIOS26LiquidTheme) {
      if (onTap == null) return child ?? const SizedBox.shrink();
      return PressTransition(
        builder: (_, progress, child) {
          final opacity = ui.lerpDouble(1.0, 0.6, progress) ?? 1.0;
          return Opacity(opacity: opacity, child: child);
        },
        onTap: onTap,
        child: child ?? const SizedBox.shrink(),
      );
    }
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? const BorderRadius.all(.circular(30));
    final borderColor = Colors.white.withValues(alpha: theme.brightness == .dark ? 0.1 : 0.35);
    final backgroundColor = theme.uiTheme.color.onBackground.withValues(alpha: theme.brightness == .dark ? 0.6 : 0.72);
    return PressTransition(
      builder: (_, progress, child) => Transform.scale(
        scale: ui.lerpDouble(1, scale ?? 1.07, progress),
        child: SizedBox(
          height: theme.uiTheme.size.button.medium,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              boxShadow: <BoxShadow>[
                if (theme.brightness == .light && primary) ...[
                  BoxShadow(
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                    color: theme.uiTheme.color.text.withValues(alpha: .05),
                  ),
                ],
              ],
            ),
            child: ClipRRect(
              borderRadius: effectiveBorderRadius,
              child: RepaintBoundary(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8, tileMode: .mirror),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: .all(color: borderColor),
                      borderRadius: effectiveBorderRadius,
                      color: backgroundColor.withValues(alpha: .65),
                    ),
                    child: Opacity(opacity: _resolveOpacity(progress), child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      onTap: onTap,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
