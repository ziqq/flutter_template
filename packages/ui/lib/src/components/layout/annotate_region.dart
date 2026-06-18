/*
 * Date: 04 June 2026
 */

import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:ui/ui.dart';

/// {@template annotate_region}
/// A helper widget to keep system UI icons readable.
///
/// On Android 15+, system bar colors are controlled by edge-to-edge rendering.
/// Use this widget together with normal Flutter backgrounds and safe-area
/// padding instead of relying on platform bar colors.
/// {@endtemplate}
class UIAnnotateRegion extends StatelessWidget {
  /// {@macro annotate_region}
  const UIAnnotateRegion({required this.child, this.color, super.key}) : _secondary = false;

  /// {@macro annotate_region}
  const UIAnnotateRegion.secondary({required this.child, this.color, super.key}) : _secondary = true;

  /// Background color that can be used behind the navigation area.
  final Color? color;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Whether to use secondary background color from the theme.
  /// This is useful when the annotated region is a secondary surface, such as a bottom sheet or a dialog.
  final bool _secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveColor =
        color ?? (_secondary ? theme.uiTheme.color.secondaryBackground : theme.uiTheme.color.background);

    final brightness = theme.brightness == .dark ? Brightness.light : Brightness.dark;
    final systemOverlayStyle = theme.appBarTheme.systemOverlayStyle;

    if (systemOverlayStyle == null) return child;

    final overlayStyle = systemOverlayStyle.copyWith(
      statusBarBrightness: theme.colorScheme.brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarIconBrightness: brightness,

      // Не задаём цвета системных баров.
      //
      // На Android 15+ эти API deprecated / игнорируются в edge-to-edge.
      // На старых Android можешь оставить, если нужна обратная совместимость,
      // но предупреждение Play Console может всё равно видеть вызов из Flutter.
      statusBarColor: null,
      systemNavigationBarColor: null,
      systemNavigationBarDividerColor: null,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: ColoredBox(color: effectiveColor, child: child),
    );
  }
}
