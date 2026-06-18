import 'package:ui/ui.dart';

/// {@template border_radius}
/// UIBorderRadius widget.
///
/// Used to create a common border radius.
/// {@endtemplate}
class UIBorderRadius extends BorderRadius {
  /// {@macro border_radius}
  UIBorderRadius._(final double value) : super.all(Radius.circular(value));

  /// Regular border radius.
  ///
  /// `Default: 10.0`
  ///
  /// {@macro border_radius}
  factory UIBorderRadius.of(BuildContext context) => UIBorderRadius._(Theme.of(context).uiTheme.size.corner.regular);

  /// {@macro border_radius}
  ///
  /// `Default: 10.0`
  ///
  /// {@macro border_radius}
  factory UIBorderRadius.regular(BuildContext context) => UIBorderRadius.of(context);

  /// Large border radius.
  ///
  /// `Default: 20.0`
  ///
  /// {@macro border_radius}
  factory UIBorderRadius.large(BuildContext context) => UIBorderRadius._(Theme.of(context).uiTheme.size.corner.large);

  /// Medium border radius.
  ///
  /// `Default: 16.0`
  ///
  /// {@macro border_radius}
  factory UIBorderRadius.medium(BuildContext context) => UIBorderRadius._(Theme.of(context).uiTheme.size.corner.medium);

  /// Small border radius.
  ///
  /// `Default: 8.0`
  ///
  /// {@macro border_radius}
  factory UIBorderRadius.small(BuildContext context) => UIBorderRadius._(Theme.of(context).uiTheme.size.corner.small);

  /// Small border radius.
  ///
  /// `Default: 4.0`
  ///
  /// {@macro border_radius}
  factory UIBorderRadius.extraSmall(BuildContext context) =>
      UIBorderRadius._(Theme.of(context).uiTheme.size.corner.extraSmall);

  /// {@macro border_radius}
  static Widget widget(BuildContext context, {required Widget child, BorderRadius? borderRadius}) =>
      ClipRRect(borderRadius: borderRadius ?? UIBorderRadius.of(context), child: child);

  /// {@macro border_radius}
  static BoxDecoration decoration(
    BuildContext context, {
    Color? color,
    BoxBorder? border,
    Gradient? gradient,
    DecorationImage? image,
    List<BoxShadow>? boxShadow,
    BlendMode? backgroundBlendMode,
    BorderRadiusGeometry? borderRadius,
    BoxShape shape = BoxShape.rectangle,
  }) => BoxDecoration(
    borderRadius: borderRadius ?? UIBorderRadius.regular(context),
    backgroundBlendMode: backgroundBlendMode,
    boxShadow: boxShadow,
    gradient: gradient,
    border: border,
    color: color,
    image: image,
    shape: shape,
  );
}
