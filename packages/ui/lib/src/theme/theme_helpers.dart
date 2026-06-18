/*
 * Date: 24 November 2024
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

/// Default `title` letter spacing
final _kDefaultTitleLetterSpacing = defaultTargetPlatform == .iOS ? -0.3 : .0;

/// Default `label` letters spacing
final _kDefaultLabelLetterSpacing = defaultTargetPlatform == .iOS ? -0.08 : .0;

/// Default `body` letter spacing
final _kDefaultBodyLetterSpacing = defaultTargetPlatform == .iOS ? -0.41 : .0;

// final lightAppColors = $generateUIColorsForBrightness(Brightness.light);
// final darkAppColors = $generateUIColorsForBrightness(Brightness.dark);

/// Generate a [UIColors] for the given [brightness].
UIColors $generateUIColorsForBrightness(Brightness brightness, {UIColors? light, UIColors? dark, Color? accent}) =>
    switch (brightness) {
      Brightness.light => (light ?? UIColors.light).copyWith(accent: accent),
      Brightness.dark => (dark ?? UIColors.dark).copyWith(accent: accent),
    };

/// Creates a [ThemeData] object based on the provided
/// [UIColors] and [CupertinoFormSectionTheme] and [SpeedDialTheme].
///
/// The [brightness] parameter is used to determine the brightness of the theme.
ThemeData $createThemeData({required Brightness brightness, Color? accent}) {
  final isDark = brightness == Brightness.dark;
  final colors = UIColors.fromBrightness(brightness).copyWith(accent: accent);
  final uiTheme = isDark ? UITheme.dark(colors: colors, accent: accent) : UITheme.light(colors: colors, accent: accent);

  /// Default font sizes are as follows:
  /// `displayLarge: 24`
  /// `displayMedium: 22`
  /// `displaySmall: 20`
  /// `headlineMedium: 18`
  /// `headlineSmall: 17`
  /// `bodyLarge: 17`
  /// `bodyMedium: 15`
  /// `bodySmall: 14`
  /// `labelSmall: 13`
  final textTheme = TextTheme(
    displayLarge: TextStyle(
      debugLabel: 'UI Theme displayLarge',
      // letterSpacing: _kDefaultTitleLetterSpacing,
      fontWeight: .bold,
      color: colors.text,
      fontSize: 24,
    ),
    displayMedium: TextStyle(
      debugLabel: 'UI Theme displayMedium',
      // letterSpacing: _kDefaultTitleLetterSpacing,
      fontWeight: .bold,
      color: colors.text,
      fontSize: 22,
    ),
    displaySmall: TextStyle(
      debugLabel: 'UI Theme displaySmall',
      // letterSpacing: _kDefaultTitleLetterSpacing,
      color: colors.text,
      fontWeight: .w600,
      fontSize: 20,
    ),
    headlineLarge: TextStyle(
      debugLabel: 'UI Theme headlineLarge',
      fontWeight: defaultTargetPlatform == .iOS ? .w700 : .w600,
      letterSpacing: _kDefaultTitleLetterSpacing,
      color: colors.text,
      fontSize: 20,
      height: 1.1,
    ),
    headlineMedium: TextStyle(
      debugLabel: 'UI Theme headlineMedium',
      fontWeight: defaultTargetPlatform == .iOS ? .w600 : .w500,
      letterSpacing: _kDefaultTitleLetterSpacing,
      color: colors.text,
      fontSize: 18,
      height: 1.1,
    ),
    headlineSmall: TextStyle(
      debugLabel: 'UI Theme headlineSmall',
      letterSpacing: _kDefaultBodyLetterSpacing,
      color: colors.text,
      fontWeight: .w500,
      fontSize: 17,
      height: 1.2,
    ),
    titleLarge: TextStyle(
      debugLabel: 'UI Theme titleLarge',
      fontWeight: defaultTargetPlatform == .iOS ? .w700 : .w600,
      letterSpacing: _kDefaultBodyLetterSpacing,
      color: colors.text,
      fontSize: 20,
      height: 1.1,
    ),
    titleMedium: TextStyle(
      debugLabel: 'UI Theme titleMedium',
      fontWeight: defaultTargetPlatform == .iOS ? .w600 : .w500,
      letterSpacing: _kDefaultBodyLetterSpacing,
      color: colors.text,
      fontSize: 18,
      height: 1.1,
    ),
    titleSmall: TextStyle(
      debugLabel: 'UI Theme titleSmall',
      letterSpacing: _kDefaultBodyLetterSpacing,
      color: colors.text,
      fontWeight: .w500,
      fontSize: 17,
      height: 1.2,
    ),
    bodyLarge: TextStyle(
      debugLabel: 'UI Theme bodyLarge',
      letterSpacing: _kDefaultBodyLetterSpacing,
      color: colors.text,
      fontWeight: .w400,
      fontSize: 17,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      debugLabel: 'UI Theme bodyMedium',
      letterSpacing: defaultTargetPlatform == .iOS ? -0.24 : 0,
      color: colors.text,
      fontWeight: .w400,
      fontSize: 15,
      height: 1.35,
    ),
    bodySmall: TextStyle(
      debugLabel: 'UI Theme bodySmall',
      letterSpacing: _kDefaultLabelLetterSpacing,
      fontSize: 14,
      fontWeight: .w400,
      height: 1.25,
      color: colors.textSecondary,
    ),
    labelLarge: TextStyle(
      debugLabel: 'UI Theme labelLarge',
      letterSpacing: _kDefaultLabelLetterSpacing,
      color: colors.textSecondary,
      fontWeight: .w400,
      fontSize: 15,
      height: 1.15,
    ),
    labelMedium: TextStyle(
      debugLabel: 'UI Theme labelMedium',
      letterSpacing: _kDefaultLabelLetterSpacing,
      color: colors.textSecondary,
      fontWeight: .w400,
      fontSize: 14,
      height: 1.15,
    ),
    labelSmall: TextStyle(
      debugLabel: 'UI Theme labelSmall',
      letterSpacing: _kDefaultLabelLetterSpacing,
      color: colors.textSecondary,
      fontWeight: .w300,
      fontSize: 13,
      height: 1.15,
    ),
  );
  final textSelectionTheme = TextSelectionThemeData(
    cursorColor: colors.text,
    selectionHandleColor: colors.accent,
    selectionColor: colors.accent.withValues(alpha: 0.4),
  );
  final hintColor = isDark ? const Color.fromARGB(76, 235, 235, 245) : const Color(0xFFC4C4C4);
  final unselectedWidgetColor = isDark ? colors.secondaryBackground : CupertinoColors.opaqueSeparator;
  final highlightColor = isDark ? CupertinoColors.systemGrey4.darkColor : CupertinoColors.systemGrey4;
  final shadowColor = isDark ? const Color.fromARGB(0, 0, 0, 0) : const Color.fromRGBO(103, 118, 140, 0.16);
  return ThemeData(
    brightness: brightness,
    visualDensity: .adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      elevation: 0,
      surfaceTintColor: colors.surface,
      backgroundColor: colors.background,
      iconTheme: IconThemeData(color: colors.text),
      systemOverlayStyle: isDark ? .light : .dark,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: .only(
          topLeft: .circular(uiTheme.size.corner.regular),
          topRight: .circular(uiTheme.size.corner.regular),
        ),
      ),
    ),
    cardColor: colors.surface,
    colorScheme: ColorScheme(
      primary: colors.accent, // accent color
      onPrimary: colors.onAccent,
      primaryContainer: colors.accent.withValues(alpha: 0.6),
      secondary: colors.accent, // accent color II
      onSecondary: colors.onAccent,
      secondaryContainer: colors.accent.withValues(alpha: 0.6),
      error: const Color(0XFFF4533B),
      onError: Colors.white,
      brightness: brightness,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainerHighest: isDark ? UIColors.dark.background : UIColors.light.secondaryBackground,
      tertiary: colors.tertiaryBackground,
    ),
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      primaryColor: colors.accent,
      brightness: colors.brightness,
      primaryContrastingColor: colors.accent,
      scaffoldBackgroundColor: colors.background,
      textTheme: CupertinoTextThemeData(
        primaryColor: colors.text,
        // --- As bodyLarge (button) text style --- //
        actionTextStyle: TextStyle(
          letterSpacing: _kDefaultBodyLetterSpacing,
          fontSize: textTheme.bodyLarge?.fontSize,
          color: colors.text,
          fontWeight: .w400,
          height: 1,
        ),
        // --- As bodyMedium text style --- //
        actionSmallTextStyle: TextStyle(
          letterSpacing: defaultTargetPlatform == .iOS ? -0.24 : 0,
          fontSize: textTheme.bodyMedium?.fontSize,
          color: colors.accent,
          fontWeight: .w400,
          height: 1,
        ),
        // --- As headlineMedium text style --- //
        navTitleTextStyle: TextStyle(
          fontWeight: defaultTargetPlatform == .iOS ? .w600 : .w500,
          fontSize: textTheme.headlineMedium?.fontSize,
          letterSpacing: _kDefaultTitleLetterSpacing,
          color: colors.text,
          height: 1,
        ),
        // --- As bodyLarge (button) text style --- //
        navActionTextStyle: TextStyle(
          letterSpacing: _kDefaultBodyLetterSpacing,
          fontSize: textTheme.bodyLarge?.fontSize,
          color: /* colors.text */ colors.accent,
          fontWeight: .w400,
          height: 1,
        ),
        // --- As bodyLarge text style --- //
        textStyle: TextStyle(
          letterSpacing: _kDefaultBodyLetterSpacing,
          fontSize: textTheme.bodyLarge?.fontSize,
          color: colors.text,
          fontWeight: .w400,
          height: 1.45,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.background,
      contentTextStyle: textTheme.bodySmall?.copyWith(height: 1.1, color: colors.textSecondary),
    ),
    disabledColor: colors.disabled,
    dividerColor: colors.border,
    dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
    iconTheme: IconThemeData(color: colors.text, size: uiTheme.size.icon.regular),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      shape: const CircleBorder(),
      backgroundColor: colors.accent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
    ),
    hintColor: hintColor,
    highlightColor: highlightColor,
    listTileTheme: ListTileThemeData(
      selectedTileColor: isDark ? CupertinoColors.quaternarySystemFill.darkColor : CupertinoColors.quaternarySystemFill,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(isDark ? CupertinoColors.separator.darkColor : CupertinoColors.separator),
    ),
    scaffoldBackgroundColor: colors.background,
    shadowColor: shadowColor,
    sliderTheme: SliderThemeData(
      inactiveTrackColor: colors.disabled,
      activeTrackColor: colors.accent,
      thumbColor: Colors.white,
      trackHeight: 1,
      thumbShape: RoundSliderThumbShape(
        elevation: 0,
        pressedElevation: 0,
        enabledThumbRadius: uiTheme.size.button.medium,
        disabledThumbRadius: uiTheme.size.button.medium,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.snackbarBackgroundColor,
      contentTextStyle: TextStyle(color: colors.text),
      actionTextColor: colors.accent,
    ),
    textSelectionTheme: textSelectionTheme,
    textTheme: textTheme,

    // Disabled ripple effect
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,

    unselectedWidgetColor: unselectedWidgetColor,

    // Custom theme extensions
    extensions: <ThemeExtension<Object?>>{
      uiTheme,
      /* CountryPickerTheme(
        radius: uiTheme.size.corner.regular,
        padding: uiTheme.padding,
        indent: uiTheme.indent,
        accentColor: colors.accent,
        dividerColor: colors.border,
        textStyle: textTheme.bodyLarge,
        backgroundColor: colors.background,
        secondaryBackgroundColor: colors.secondaryBackground,
      ), */
      /* PullDownButtonTheme(
        itemTheme: PullDownMenuItemTheme(
          textStyle: TextStyle(
            height: 1,
            color: colors.text,
            fontWeight: .w400,
            letterSpacing: _kDefaultBodyLetterSpacing,
            fontSize: textTheme.bodyLarge?.fontSize,
          ),
        ),
      ), */
    },
  );
}

@experimental
/// Defaults tokens for the application theme.
class Defaults {
  const Defaults._();

  /// Default avatar sizes
  static const SizeScheme avatar = SizeScheme.avatar();

  /// Default button sizes
  static const SizeScheme button = SizeScheme.button();

  /// Default corner sizes
  static const SizeScheme radius = SizeScheme.corner();

  /// Default icon sizes
  static const SizeScheme icon = SizeScheme.icon();

  /// Default light colors scheme
  static const UIColors lightColors = UIColors.light;

  /// Default dark colors scheme
  static final UIColors darkColors = UIColors.dark;

  static final lightTextTheme = buildTextTheme(lightColors);
  static final darkTextTheme = buildTextTheme(darkColors);

  /// Builds the default text theme based on the provided colors.
  static TextTheme buildTextTheme(UIColors colors) => TextTheme(
    displayLarge: TextStyle(
      // letterSpacing: _kDefaultTitleLetterSpacing,
      fontWeight: .bold,
      color: colors.text,
      fontSize: 24,
    ),
    displayMedium: TextStyle(
      // letterSpacing: _kDefaultTitleLetterSpacing,
      fontWeight: .bold,
      color: colors.text,
      fontSize: 22,
    ),
    displaySmall: TextStyle(
      // letterSpacing: _kDefaultTitleLetterSpacing,
      fontWeight: .w600,
      color: colors.text,
      fontSize: 20,
    ),
    headlineLarge: TextStyle(
      fontWeight: defaultTargetPlatform == .iOS ? .w700 : .w600,
      letterSpacing: _kDefaultTitleLetterSpacing,
      color: colors.text,
      fontSize: 20,
      height: 1.1,
    ),
    headlineMedium: TextStyle(
      fontWeight: defaultTargetPlatform == .iOS ? .w600 : .w500,
      letterSpacing: _kDefaultTitleLetterSpacing,
      color: colors.text,
      fontSize: 18,
      height: 1.1,
    ),
    headlineSmall: TextStyle(
      letterSpacing: _kDefaultTitleLetterSpacing,
      fontWeight: .w500,
      color: colors.text,
      fontSize: 17,
      height: 1.2,
    ),
    titleLarge: TextStyle(
      fontWeight: defaultTargetPlatform == .iOS ? .w700 : .w600,
      letterSpacing: _kDefaultBodyLetterSpacing,
      color: colors.text,
      fontSize: 20,
      height: 1.1,
    ),
    titleMedium: TextStyle(
      fontWeight: defaultTargetPlatform == .iOS ? .w600 : .w500,
      letterSpacing: _kDefaultBodyLetterSpacing,
      color: colors.text,
      fontSize: 18,
      height: 1.1,
    ),
    titleSmall: TextStyle(
      letterSpacing: _kDefaultBodyLetterSpacing,
      fontWeight: .w500,
      color: colors.text,
      fontSize: 17,
      height: 1.2,
    ),
    bodyLarge: TextStyle(
      letterSpacing: _kDefaultBodyLetterSpacing,
      fontWeight: .w400,
      color: colors.text,
      fontSize: 17,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      letterSpacing: defaultTargetPlatform == .iOS ? -0.24 : 0,
      fontWeight: .w400,
      color: colors.text,
      fontSize: 15,
      height: 1.35,
    ),
    bodySmall: TextStyle(
      letterSpacing: _kDefaultLabelLetterSpacing,
      fontWeight: .w400,
      fontSize: 14,
      height: 1.25,
      color: colors.textSecondary,
    ),
    labelLarge: TextStyle(
      letterSpacing: _kDefaultLabelLetterSpacing,
      fontWeight: .w400,
      color: colors.textSecondary,
      fontSize: 15,
      height: 1.15,
    ),
    labelMedium: TextStyle(
      letterSpacing: _kDefaultLabelLetterSpacing,
      fontWeight: .w400,
      color: colors.textSecondary,
      fontSize: 14,
      height: 1.15,
    ),
    labelSmall: TextStyle(
      letterSpacing: _kDefaultLabelLetterSpacing,
      color: colors.textSecondary,
      fontWeight: .w300,
      fontSize: 13,
      height: 1.15,
    ),
  );

  /* static final tokens = Tokens(
    margin: margin,
    padding: padding,
    gutter: gutter,
    radius: radius,
    typography: lightTypography,
    colors: lightColors,
  ); */

  /* static final darkTokens = Tokens(
    margin: margin,
    padding: padding,
    gutter: gutter,
    radius: radius,
    typography: darkTypography,
    colors: darkColors,
  ); */

  // static final lightTheme = buildThemeData(tokens, Brightness.light);
  // static final darkTheme = buildThemeData(darkTokens, Brightness.dark);
}
