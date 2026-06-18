import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Accent color.
const Color kAccentColor = Color(0xFF0A84FF);

/// {@template ui_colors}
/// The color scheme for the ui.
/// {@endtemplate}
@immutable
class UIColors implements ThemeExtension<UIColors> {
  /// {@macro ui_colors}
  const UIColors({
    required this.background,
    required this.onBackground,
    required this.secondaryBackground,
    required this.onSecondaryBackground,
    required this.tertiaryBackground,
    required this.onTertiaryBackground,
    required this.disabled,
    required this.onDisabled,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.accent,
    required this.onAccent,
    required this.ring,
    required this.surface,
    required this.onSurface,
    required this.selected,
    required this.snackbarBackgroundColor,
    required this.text,
    required this.textSecondary,
    this.brightness,
  });

  /// Creates a [UIColors] instance based on the current [BuildContext].
  factory UIColors.of(BuildContext context) {
    try {
      final theme = Theme.of(context);
      return theme.extension<UIColors>() ??
          switch (theme.brightness) {
            Brightness.light => UIColors.light,
            Brightness.dark => UIColors.dark,
          };
    } on Object {
      return UIColors.light;
    }
  }

  /// Creates a [UIColors] instance based on the given [brightness].
  static UIColors fromBrightness(Brightness brightness) => switch (brightness) {
    Brightness.light => UIColors.light,
    Brightness.dark => UIColors.dark,
  };

  /// The default light theme colors.
  ///
  /// {@macro ui_colors}
  static const UIColors light = UIColors(
    brightness: Brightness.light,
    background: Colors.white,
    onBackground: Color(0xFFF2F2F7),
    secondaryBackground: Color(0xFFF2F2F7), // F7F7F7
    onSecondaryBackground: Colors.white,
    tertiaryBackground: Color(0xFFF2F2F7),
    onTertiaryBackground: Colors.white,
    disabled: CupertinoColors.systemGrey5, // Color(0xFFEFEFEF)
    onDisabled: Color(0x99000000),
    border: Color(0xFFDEE3E7),
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.black54,
    onSecondary: Colors.white,
    accent: kAccentColor,
    onAccent: Colors.white,
    ring: kAccentColor,
    surface: Colors.white,
    onSurface: Colors.black,
    selected: CupertinoColors.systemGrey5,
    snackbarBackgroundColor: Color.fromRGBO(45, 45, 45, 0.8),
    text: Colors.black,
    textSecondary: Color.fromARGB(153, 60, 60, 67), // Color(0x99000000),
  );

  /// The default dark theme colors.
  ///
  /// {@macro ui_colors}
  static final UIColors dark = UIColors(
    brightness: Brightness.dark,
    background: const Color(0xFF1C1C1E),
    onBackground: const Color(0xFF2C2C2E),
    secondaryBackground: const Color(0xFF1C1C1E),
    onSecondaryBackground: const Color(0xFF2C2C2E),
    tertiaryBackground: const Color.fromARGB(255, 22, 22, 22),
    onTertiaryBackground: const Color(0xFF1C1C1E),
    disabled: CupertinoColors.systemGrey4.darkColor, // Color(0xFF323136)
    onDisabled: const Color(0x99EBEBF5),
    border: const Color(0xFF38383A),
    primary: const Color.fromARGB(255, 22, 22, 22),
    onPrimary: Colors.white,
    secondary: const Color.fromARGB(153, 235, 235, 245),
    onSecondary: Colors.white,
    accent: kAccentColor,
    onAccent: Colors.white,
    ring: kAccentColor,
    surface: const Color(0xFF2C2C2E),
    onSurface: const Color(0xFF3A3A3C),
    selected: const Color.fromARGB(255, 56, 56, 58),
    snackbarBackgroundColor: const Color.fromRGBO(11, 11, 11, 1), // const Color.fromRGBO(28, 28, 28, 1)
    text: const Color(0xFFFFFFFF),
    textSecondary: const Color.fromARGB(153, 235, 235, 245), // const Color(0x99EBEBF5),
  );

  /// Default accent color
  static Color defaultAccent = kAccentColor;

  /// The overall theme brightness.
  final Brightness? brightness;

  /// Default background color
  ///
  /// Use instead [Theme.of(context).scaffoldBackgroundColor]
  final Color background;

  /// Default on backgound color
  ///
  /// Use instead [Theme.of(context).colorScheme.surface]
  final Color onBackground;

  /// Secondary background color
  final Color secondaryBackground;

  /// Secondary on secondery background color
  final Color onSecondaryBackground;

  /// Tertiary background color
  final Color tertiaryBackground;

  /// Secondary on tertiary background color
  final Color onTertiaryBackground;

  /// Used for accents such as hover effects
  final Color accent;

  /// Used for accents such as hover effects
  final Color onAccent;

  /// Default border color
  final Color border;

  /// Muted backgrounds
  final Color disabled;

  /// Color for text on disabled backgrounds
  final Color onDisabled;

  /// Primary colors
  final Color primary;

  /// Color for text on primary colors
  final Color onPrimary;

  /// Secondary colors
  final Color secondary;

  /// Color for text on secondary colors
  final Color onSecondary;

  /// The ring color of the app, used for focus rings.
  final Color ring;

  /// The surface color of the app, used for elements that are above the main background.
  final Color surface;

  /// The on surface color of the app, used for elements that are above the surface.
  final Color onSurface;

  /// Color for selected items
  final Color selected;

  /// The background color of snack bars.
  final Color snackbarBackgroundColor;

  /// The text color of the app, used for base text color.
  ///
  /// E.g:, display..Large..Medium..Small, body..Large..Medium, etc.
  final Color text;

  /// The secondary text color of the app, used for secondary text color.
  ///
  /// E.g: bodySmall, lableSmall, etc.
  final Color textSecondary;

  @override
  Object get type => UIColors;

  /// Returns `true` if the brightness is [Brightness.light].
  bool get isLight => brightness == Brightness.light;

  /// Returns `true` if the brightness is [Brightness.dark].
  bool get isDark => brightness == Brightness.dark;

  /// Returns [ThemeMode] of the closest [Theme] ancestor.
  ///
  /// {@macro ui_colors}
  static ThemeMode themeModeOf(BuildContext context) {
    final theme = Theme.of(context);
    return switch (theme.brightness) {
      Brightness.light => ThemeMode.light,
      Brightness.dark => ThemeMode.dark,
    };
  }

  /// Pattern matching on the brightness of the [UIColors].
  T map<T>({required T Function() light, required T Function() dark}) => isLight ? light() : dark();

  @useResult
  @override
  UIColors copyWith({
    Brightness? brightness,
    Color? background,
    Color? onBackground,
    Color? secondaryBackground,
    Color? onSecondaryBackground,
    Color? tertiaryBackground,
    Color? onTertiaryBackground,
    Color? disabled,
    Color? onDisabled,
    Color? border,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? accent,
    Color? onAccent,
    Color? surface,
    Color? onSurface,
    Color? selected,
    Color? snackbarBackgroundColor,
    Color? text,
    Color? textSecondary,
  }) => UIColors(
    brightness: brightness ?? this.brightness,
    background: background ?? this.background,
    onBackground: onBackground ?? this.onBackground,
    secondaryBackground: secondaryBackground ?? this.secondaryBackground,
    onSecondaryBackground: onSecondaryBackground ?? this.onSecondaryBackground,
    tertiaryBackground: tertiaryBackground ?? this.tertiaryBackground,
    onTertiaryBackground: onTertiaryBackground ?? this.onTertiaryBackground,
    disabled: disabled ?? this.disabled,
    onDisabled: onDisabled ?? this.onDisabled,
    border: border ?? this.border,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    secondary: secondary ?? this.secondary,
    onSecondary: onSecondary ?? this.onSecondary,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    surface: surface ?? this.surface,
    onSurface: onSurface ?? this.onSurface,
    selected: selected ?? this.selected,
    snackbarBackgroundColor: snackbarBackgroundColor ?? this.snackbarBackgroundColor,
    ring: accent ?? ring,
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
  );

  @override
  ThemeExtension<UIColors> lerp(covariant ThemeExtension<UIColors>? other, double t) {
    if (other == null || other is! UIColors) return this;
    return UIColors(
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      secondaryBackground: Color.lerp(secondaryBackground, other.secondaryBackground, t)!,
      onSecondaryBackground: Color.lerp(onSecondaryBackground, other.onSecondaryBackground, t)!,
      tertiaryBackground: Color.lerp(tertiaryBackground, other.tertiaryBackground, t)!,
      onTertiaryBackground: Color.lerp(onTertiaryBackground, other.onTertiaryBackground, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      onDisabled: Color.lerp(onDisabled, other.onDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      snackbarBackgroundColor: Color.lerp(snackbarBackgroundColor, other.snackbarBackgroundColor, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }

  @useResult
  Map<String, Color> toMap() => {
    'background': background,
    'onBackground': onBackground,
    'secondaryBackground': secondaryBackground,
    'onSecondaryBackground': onSecondaryBackground,
    'tertiaryBackground': tertiaryBackground,
    'onTertiaryBackground': onTertiaryBackground,
    'disabled': disabled,
    'onDisabled': onDisabled,
    'border': border,
    'primary': primary,
    'onPrimary': onPrimary,
    'secondary': secondary,
    'onSecondary': onSecondary,
    'accent': accent,
    'onAccent': onAccent,
    'ring': ring,
    'surface': surface,
    'onSurface': onSurface,
    'selected': selected,
    'snackbarBackgroundColor': snackbarBackgroundColor,
    'text': text,
    'textSecondary': textSecondary,
  };
}
