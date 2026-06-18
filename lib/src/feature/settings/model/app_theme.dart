import 'package:flutter/foundation.dart'
    show Diagnosticable, DiagnosticPropertiesBuilder, EnumProperty, DiagnosticsProperty;
import 'package:flutter/material.dart' show ThemeMode, Color, Brightness, ThemeData;
import 'package:flutter_template_name/src/common/model/option.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart' show $createThemeData;

/// {@template app_theme}
/// An immutable class that holds properties needed
/// to build a [ThemeData] for the app.
/// {@endtemplate}
@immutable
final class AppTheme with Diagnosticable {
  /// {@macro app_theme}
  const AppTheme({required this.themeMode, this.accent});

  /// Creates an empty [AppTheme] instance.
  /// This is useful when you want to create a theme without any specific properties.
  /// {@macro app_theme}
  @literal
  const AppTheme.empty() : themeMode = ThemeMode.system, accent = null;

  /// The type of theme to use.
  final ThemeMode themeMode;

  /// The accent color to use.
  final Color? accent;

  /// Copy the [AppTheme] with new values.
  @useResult
  AppTheme copyWith({ThemeMode? themeMode, Option<Color?>? accent}) =>
      AppTheme(themeMode: themeMode ?? this.themeMode, accent: accent?.isAbsent ?? true ? this.accent : accent?.value);

  /// Builds a [ThemeData] based on the [themeMode] and [seed].
  ///
  /// This can also be used to add additional properties to the [ThemeData],
  /// such as extensions or custom properties.
  ThemeData buildThemeData(Brightness brightness) => $createThemeData(brightness: brightness, accent: accent);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<ThemeMode>('themeMode', themeMode))
      ..add(DiagnosticsProperty<Color>('accent', accent));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppTheme && runtimeType == other.runtimeType && themeMode == other.themeMode && accent == other.accent;

  @override
  int get hashCode => themeMode.hashCode ^ accent.hashCode;
}
