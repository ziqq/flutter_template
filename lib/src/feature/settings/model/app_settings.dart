import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';
import 'package:meta/meta.dart';

/// {@template app_settings}
/// Application settings
/// {@endtemplate}
@immutable
final class AppSettings with Diagnosticable {
  /// {@macro app_settings}
  const AppSettings({required this.theme, required this.locale, required this.textScale});

  /// Creates an empty [AppSettings] instance.
  @literal
  const AppSettings.empty() : theme = const AppTheme.empty(), locale = Config.locale, textScale = 1;

  /// The theme of the app,
  final AppTheme theme;

  /// The locale of the app.
  final Locale locale;

  /// The text scale of the app.
  /// Default is `1.0`, which means no scaling.
  final double textScale;

  /// Copy the [AppSettings] with new values.
  AppSettings copyWith({AppTheme? theme, Locale? locale, double? textScale}) =>
      AppSettings(theme: theme ?? this.theme, locale: locale ?? this.locale, textScale: textScale ?? this.textScale);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings && other.theme == theme && other.locale == locale && other.textScale == textScale;
  }

  @override
  int get hashCode => Object.hash(theme, locale, textScale);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<AppTheme>('theme', theme))
      ..add(DiagnosticsProperty<Locale>('locale', locale))
      ..add(DoubleProperty('textScale', textScale));
    super.debugFillProperties(properties);
  }
}
