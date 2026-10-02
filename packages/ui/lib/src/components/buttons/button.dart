/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 05 September 2026
 */

import 'package:flutter/foundation.dart' show Diagnosticable;
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

/// Declares the height scale shared by every [UIButton] variant.
///
/// Each entry resolves against `Theme.of(context).uiTheme.size.button`, so a
/// host that overrides the shared size scheme changes every button at once.
enum UIButtonSize {
  /// Height: `56`.
  large,

  /// Height: `44`.
  medium,

  /// Height: `38`.
  small,

  /// Height: `32`.
  extraSmall,
}

/// Declares the emphasis level of a [UIButton].
enum UIButtonVariant {
  /// A filled accent surface used for the primary action of a screen or sheet.
  primary,

  /// A tinted accent surface used for lower-emphasis actions.
  secondary,
}

/// {@template ui_button}
/// A themed button built on the Flutter [ButtonStyleButton] contract.
///
/// The visual style resolves through the standard cascade — the [style] passed
/// to the widget, then [FilledButtonTheme], then [defaultStyleOf] — so a caller
/// can override one property without restating the rest. Use
/// [UIButton.styleFrom] to build a partial [ButtonStyle].
///
/// A `null` `onPressed` is the only contract for the disabled state. Disabled
/// and [loading] buttons report disabled semantics, refuse activation, and
/// never invoke their callbacks.
///
/// The widget does not own its outer layout. Use an enclosing [Padding],
/// [SizedBox], or [Expanded] for margin and width instead of widget-level
/// layout parameters.
///
/// ```dart
/// UIButton(
///   onPressed: controller.save,
///   loading: controller.isProcessing,
///   child: const Text('Save'),
/// )
/// ```
/// {@endtemplate}
class UIButton extends ButtonStyleButton {
  /// Creates a filled accent button.
  ///
  /// {@macro ui_button}
  UIButton({
    required VoidCallback? onPressed,
    required Widget child,
    VoidCallback? onLongPress,
    super.onHover,
    super.onFocusChange,
    super.autofocus = false,
    super.style,
    super.focusNode,
    super.statesController,
    super.clipBehavior = Clip.none,
    this.size = UIButtonSize.large,
    this.loading = false,
    super.key,
  }) : variant = UIButtonVariant.primary,
       _iconOnly = false,
       super(
         onPressed: loading ? null : onPressed,
         onLongPress: loading ? null : onLongPress,
         child: _UIButton$Content(loading: loading, size: size, child: child),
       );

  /// Creates a tinted accent button for a lower-emphasis action.
  ///
  /// {@macro ui_button}
  UIButton.secondary({
    required VoidCallback? onPressed,
    required Widget child,
    VoidCallback? onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    Clip super.clipBehavior = Clip.none,
    super.statesController,
    this.size = UIButtonSize.large,
    this.loading = false,
    super.key,
  }) : variant = UIButtonVariant.secondary,
       _iconOnly = false,
       super(
         onPressed: loading ? null : onPressed,
         onLongPress: loading ? null : onLongPress,
         child: _UIButton$Content(loading: loading, size: size, child: child),
       );

  /// Creates a filled accent button with a leading [icon] and a [label].
  ///
  /// {@macro ui_button}
  UIButton.icon({
    required VoidCallback? onPressed,
    required Widget icon,
    Widget? label,
    VoidCallback? onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    Clip super.clipBehavior = Clip.none,
    super.statesController,
    this.size = UIButtonSize.large,
    this.loading = false,
    super.key,
  }) : variant = UIButtonVariant.primary,
       _iconOnly = label == null,
       super(
         onPressed: loading ? null : onPressed,
         onLongPress: loading ? null : onLongPress,
         child: _UIButton$Content(
           loading: loading,
           size: size,
           child: label == null ? icon : _UIButton$IconLabel(icon: icon, label: label),
         ),
       );

  /// Creates a tinted accent button with a leading [icon] and a [label].
  ///
  /// {@macro ui_button}
  UIButton.secondaryIcon({
    required VoidCallback? onPressed,
    required Widget icon,
    Widget? label,
    VoidCallback? onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    Clip super.clipBehavior = Clip.none,
    super.statesController,
    this.size = UIButtonSize.large,
    this.loading = false,
    super.key,
  }) : variant = UIButtonVariant.secondary,
       _iconOnly = label == null,
       super(
         onPressed: loading ? null : onPressed,
         onLongPress: loading ? null : onLongPress,
         child: _UIButton$Content(
           loading: loading,
           size: size,
           child: label == null ? icon : _UIButton$IconLabel(icon: icon, label: label),
         ),
       );

  /// The emphasis level used to resolve the default colors.
  final UIButtonVariant variant;

  /// The height scale used to resolve the default metrics.
  final UIButtonSize size;

  /// Whether the button renders an icon without a label.
  ///
  /// An icon-only button drops the horizontal padding and keeps the square
  /// minimum size of its [size] token. Give the icon its own
  /// `semanticLabel` so the action stays announceable.
  final bool _iconOnly;

  /// Whether the button is showing a progress indicator.
  ///
  /// A loading button is disabled: it reports disabled semantics and does not
  /// invoke `onPressed` or `onLongPress`. The label keeps its semantics and its
  /// layout bounds, so neither the button nor its neighbours move.
  final bool loading;

  /// Builds a partial [ButtonStyle] for [UIButton].
  ///
  /// Every argument is optional. Omitted properties fall through to
  /// [FilledButtonTheme] and then to [defaultStyleOf], which keeps a partial
  /// override from erasing the remaining UI defaults.
  ///
  /// Pass [gradient] to paint a gradient behind the label. It is suppressed
  /// while the button is disabled so the disabled surface stays recognizable.
  ///
  /// [gradient] and [backgroundBuilder] are mutually exclusive.
  static ButtonStyle styleFrom({
    Color? foregroundColor,
    Color? backgroundColor,
    Color? disabledForegroundColor,
    Color? disabledBackgroundColor,
    Color? shadowColor,
    Color? overlayColor,
    Color? iconColor,
    double? iconSize,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    BorderSide? side,
    OutlinedBorder? shape,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
    Gradient? gradient,
    ButtonLayerBuilder? backgroundBuilder,
    ButtonLayerBuilder? foregroundBuilder,
  }) {
    assert(
      <Object?>[gradient, backgroundBuilder].where((layer) => layer != null).length <= 1,
      'Use at most one of gradient or backgroundBuilder.',
    );

    // Finals so the closures below can rely on the null checks.
    final Gradient? effectiveGradient = gradient;
    final ButtonLayerBuilder? effectiveBackgroundBuilder;
    if (effectiveGradient != null) {
      effectiveBackgroundBuilder = (context, states, child) =>
          _UIButton$Gradient(gradient: effectiveGradient, states: states, child: child);
    } else {
      effectiveBackgroundBuilder = backgroundBuilder;
    }

    return ButtonStyle(
      textStyle: ButtonStyleButton.allOrNull<TextStyle>(textStyle),
      backgroundColor: ButtonStyleButton.defaultColor(backgroundColor, disabledBackgroundColor),
      foregroundColor: ButtonStyleButton.defaultColor(foregroundColor, disabledForegroundColor),
      overlayColor: ButtonStyleButton.allOrNull<Color>(overlayColor),
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      elevation: ButtonStyleButton.allOrNull<double>(elevation),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize),
      fixedSize: ButtonStyleButton.allOrNull<Size>(fixedSize),
      maximumSize: ButtonStyleButton.allOrNull<Size>(maximumSize),
      iconColor: ButtonStyleButton.allOrNull<Color>(iconColor),
      iconSize: ButtonStyleButton.allOrNull<double>(iconSize),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
      mouseCursor: switch ((enabledMouseCursor, disabledMouseCursor)) {
        (null, null) => null,
        _ => _UIButton$DefaultMouseCursor(enabledMouseCursor, disabledMouseCursor),
      },
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
      backgroundBuilder: effectiveBackgroundBuilder,
      foregroundBuilder: foregroundBuilder,
    );
  }

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.uiTheme.color;
    final sizes = theme.uiTheme.size;

    final height = switch (size) {
      UIButtonSize.large => sizes.button.large,
      UIButtonSize.medium => sizes.button.medium,
      UIButtonSize.small => sizes.button.small,
      UIButtonSize.extraSmall => sizes.button.extraSmall,
    };
    final horizontalPadding = switch (size) {
      UIButtonSize.large || UIButtonSize.medium => sizes.offset.regular,
      UIButtonSize.extraSmall || UIButtonSize.small => sizes.offset.small,
    };
    final textStyle = switch (size) {
      UIButtonSize.large || UIButtonSize.medium => theme.textTheme.bodyLarge,
      UIButtonSize.small || UIButtonSize.extraSmall => theme.textTheme.bodyMedium,
    };
    final iconSize = switch (size) {
      UIButtonSize.large || UIButtonSize.medium => sizes.icon.regular,
      UIButtonSize.small => sizes.icon.secondary ?? sizes.icon.regular,
      UIButtonSize.extraSmall => sizes.icon.extraSmall,
    };

    final background = switch (variant) {
      UIButtonVariant.primary => colors.accent,
      UIButtonVariant.secondary => colors.accent.withValues(alpha: .15),
    };
    final foreground = switch (variant) {
      UIButtonVariant.primary => colors.onAccent,
      UIButtonVariant.secondary => colors.accent,
    };

    return ButtonStyle(
      // The line height is inherited from the shared text theme. Overriding it
      // here clipped the descenders of the compact sizes.
      textStyle: WidgetStatePropertyAll<TextStyle?>(textStyle?.copyWith(fontWeight: FontWeight.w500)),
      backgroundColor: ButtonStyleButton.defaultColor(background, colors.disabled),
      foregroundColor: ButtonStyleButton.defaultColor(foreground, colors.onDisabled),
      iconColor: ButtonStyleButton.defaultColor(foreground, colors.onDisabled),
      overlayColor: _UIButton$DefaultOverlay(foreground),
      // A visible focus indicator that paints inside the existing bounds, so
      // gaining focus never moves the button or its neighbours.
      side: _UIButton$DefaultFocusRing(colors.ring),
      shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      elevation: const WidgetStatePropertyAll<double>(0),
      // An icon-only button drops the horizontal padding so the square minimum
      // size of its token is what the user sees.
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        _iconOnly ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: horizontalPadding),
      ),
      // A minimum rather than a fixed height: the button grows with the text
      // scale instead of clipping a long localized label.
      minimumSize: WidgetStatePropertyAll<Size>(Size(height, height)),
      maximumSize: const WidgetStatePropertyAll<Size>(Size.infinite),
      iconSize: WidgetStatePropertyAll<double>(iconSize),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(sizes.corner.regular)),
      ),
      mouseCursor: _UIButton$DefaultMouseCursor(SystemMouseCursors.click, SystemMouseCursors.basic),
      // The size tokens are the visual contract, so the layout box is not
      // inflated to the platform tap target. A dense surface that uses `small`
      // or `extraSmall` owns the surrounding spacing.
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      splashFactory: NoSplash.splashFactory,
      animationDuration: kThemeChangeDuration,
      alignment: .center,
      enableFeedback: true,
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) => FilledButtonTheme.of(context).style;
}

/// Resolves the enabled and disabled mouse cursors of a [UIButton].
///
/// Mirrors the `_FilledButtonDefaultMouseCursor` shape used by the Material
/// buttons so the property stays diagnosable in a widget inspector.
class _UIButton$DefaultMouseCursor extends WidgetStateProperty<MouseCursor?> with Diagnosticable {
  _UIButton$DefaultMouseCursor(this.enabledCursor, this.disabledCursor);

  final MouseCursor? enabledCursor;
  final MouseCursor? disabledCursor;

  @override
  MouseCursor? resolve(Set<WidgetState> states) =>
      states.contains(WidgetState.disabled) ? disabledCursor : enabledCursor;
}

/// Resolves a visually distinct overlay for every interaction state.
///
/// The overlay paints inside the existing bounds, so no state changes the
/// layout of the button or of its neighbours.
class _UIButton$DefaultOverlay extends WidgetStateProperty<Color?> with Diagnosticable {
  _UIButton$DefaultOverlay(this.foreground);

  final Color foreground;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) return foreground.withValues(alpha: .18);
    if (states.contains(WidgetState.focused)) return foreground.withValues(alpha: .12);
    if (states.contains(WidgetState.hovered)) return foreground.withValues(alpha: .07);
    return null;
  }
}

/// Resolves the focus ring drawn on the button shape.
class _UIButton$DefaultFocusRing extends WidgetStateProperty<BorderSide?> with Diagnosticable {
  _UIButton$DefaultFocusRing(this.ring);

  final Color ring;

  @override
  BorderSide? resolve(Set<WidgetState> states) =>
      states.contains(WidgetState.focused) ? BorderSide(color: ring, width: 2) : BorderSide.none;
}

/// Paints a gradient behind the button content while the button is enabled.
class _UIButton$Gradient extends StatelessWidget {
  const _UIButton$Gradient({required this.gradient, required this.states, required this.child});

  final Gradient gradient;
  final Set<WidgetState> states;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (states.contains(WidgetState.disabled)) return child ?? const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Theme.of(context).uiTheme.size.corner.regular),
        gradient: gradient,
      ),
      child: child,
    );
  }
}

/// Lays out the leading icon and the label of an icon button.
class _UIButton$IconLabel extends StatelessWidget {
  const _UIButton$IconLabel({required this.icon, required this.label});

  final Widget icon;
  final Widget label;

  @override
  Widget build(BuildContext context) => Row(
    spacing: Theme.of(context).uiTheme.size.offset.extraExtraSmall,
    crossAxisAlignment: .center,
    mainAxisAlignment: .center,
    mainAxisSize: .min,
    children: <Widget>[
      icon,
      Flexible(child: label),
    ],
  );
}

/// Overlays a progress indicator without disturbing the label bounds.
///
/// The label stays in the tree with its semantics intact and only stops
/// painting, so the button keeps the same size in every state.
class _UIButton$Content extends StatelessWidget {
  const _UIButton$Content({required this.loading, required this.size, required this.child});

  final bool loading;
  final UIButtonSize size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!loading) return child;
    final sizes = Theme.of(context).uiTheme.size;
    final indicatorSize = switch (size) {
      .large || .medium => sizes.icon.secondary ?? sizes.icon.regular,
      .small || .extraSmall => sizes.icon.extraSmall,
    };
    return Stack(
      alignment: .center,
      children: <Widget>[
        Opacity(opacity: 0, alwaysIncludeSemantics: true, child: child),
        ExcludeSemantics(
          child: SizedBox.square(
            dimension: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color?>(IconTheme.of(context).color),
            ),
          ),
        ),
      ],
    );
  }
}
