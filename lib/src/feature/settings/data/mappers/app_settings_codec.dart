import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode, Locale, Color;
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';

/// Codec for [AppSettings]
const _appSettingsCodec = AppSettingsCodec();

/// Codec for [Locale]
const _localeCodec = _LocaleCodec();

/// Codec for [ThemeMode]
const _themeModeCodec = _ThemeModeCodec();

/// Codec for accent [Color]
const _accentColorCodec = _ThemeAccentColorCodec();

/// Codec: [AppSettings] <-> `Map<String,Object?>`.
/// Keys: theme_mode, accentColor?, locale, text_scale.
final class AppSettingsCodec extends Codec<AppSettings, Map<String, Object?>> {
  const AppSettingsCodec();

  @override
  Converter<AppSettings, Map<String, Object?>> get encoder => const _AppSettingsEncoder();

  @override
  Converter<Map<String, Object?>, AppSettings> get decoder => const _AppSettingsDecoder();
}

final class _AppSettingsDecoder extends Converter<Map<String, Object?>, AppSettings> {
  const _AppSettingsDecoder();

  @override
  AppSettings convert(Map<String, Object?> input) {
    final rawLocale = input['locale'];
    final rawAccent = input['accent_color'];
    final rawThemeMode = input['theme_mode'];
    final rawTextScale = input['text_scale'];

    final accent = switch (rawAccent) {
      Map<String, Object?> m => _accentColorCodec.decoder.convert(m),
      _ => null,
    };

    final locale = switch (rawLocale) {
      String s when s.isNotEmpty => _localeCodec.decoder.convert(
        _localeCodec.tryParseStringToMap(s) ?? <String, Object?>{'language_code': s},
      ),
      Map<String, Object?> m => _localeCodec.decoder.convert(m),
      Locale l => l,
      _ => Config.locale,
    };

    final textScale = switch (rawTextScale) {
      String s => double.tryParse(s) ?? 1.0,
      int i when i > 0 => i.toDouble(),
      double d when d > 0 => d,
      _ => 1.0,
    };

    final themeMode = switch (rawThemeMode) {
      String s => _themeModeCodec.decoder.convert(s),
      _ => ThemeMode.system,
    };

    return AppSettings(
      theme: AppTheme(themeMode: themeMode, accent: accent),
      textScale: textScale.clamp(0.5, 2.0),
      locale: locale,
    );
  }
}

final class _AppSettingsEncoder extends Converter<AppSettings, Map<String, Object?>> {
  const _AppSettingsEncoder();

  @override
  Map<String, Object?> convert(AppSettings input) {
    final accent = input.theme.accent;
    return <String, Object?>{
      if (accent != null) 'accent_color': _accentColorCodec.encoder.convert(accent),
      'locale': _localeCodec.encoder.convert(input.locale),
      'text_scale': input.textScale,
      'theme_mode': _themeModeCodec.encoder.convert(input.theme.themeMode),
    };
  }
}

/// [Locale] <-> `Map` codec (supports String `en`, `en-US`, `zh-Hant-TW`).
final class _LocaleCodec extends Codec<Locale, Map<String, Object?>> {
  const _LocaleCodec();

  @override
  Converter<Locale, Map<String, Object?>> get encoder => const _LocaleEncoder();

  @override
  Converter<Map<String, Object?>, Locale> get decoder => const _LocaleDecoder();

  /// Helper to parse a locale string into a map shape.
  Map<String, Object?>? tryParseStringToMap(String value) {
    final parts = value.trim().split(RegExp('[-_]')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    if (parts.length == 1) {
      return {'language_code': parts[0]};
    } else if (parts.length == 2) {
      return {'language_code': parts[0], 'country_code': parts[1]};
    } else if (parts.length >= 3) {
      return {'language_code': parts[0], 'script_code': parts[1], 'country_code': parts[2]};
    }
    return null;
  }
}

final class _LocaleDecoder extends Converter<Map<String, Object?>, Locale> {
  const _LocaleDecoder();

  @override
  Locale convert(Map<String, Object?> input) {
    final country = (input['country_code'] ?? input['countryCode'])?.toString();
    final lang = (input['language_code'] ?? input['languageCode'])?.toString();
    final script = (input['script_code'] ?? input['scriptCode'])?.toString();
    if (lang == null || lang.isEmpty) return Config.locale;
    return Locale.fromSubtags(languageCode: lang, scriptCode: script, countryCode: country);
  }
}

final class _LocaleEncoder extends Converter<Locale, Map<String, Object?>> {
  const _LocaleEncoder();

  @override
  Map<String, Object?> convert(Locale input) => <String, Object?>{
    'language_code': input.languageCode,
    if (input.scriptCode != null) 'script_code': input.scriptCode,
    if (input.countryCode != null) 'country_code': input.countryCode,
  };
}

/// Codec for [ThemeMode] <-> [String].
final class _ThemeModeCodec extends Codec<ThemeMode, String> {
  const _ThemeModeCodec();

  @override
  Converter<ThemeMode, String> get encoder => const _ThemeModeEncoder();

  @override
  Converter<String, ThemeMode> get decoder => const _ThemeModeDecoder();
}

final class _ThemeModeDecoder extends Converter<String, ThemeMode> {
  const _ThemeModeDecoder();

  @override
  ThemeMode convert(String input) => switch (input) {
    'ThemeMode.dark' => ThemeMode.dark,
    'ThemeMode.light' => ThemeMode.light,
    'ThemeMode.system' => ThemeMode.system,
    _ => throw ArgumentError.value(input, 'input', 'Cannot convert $input to ThemeMode'),
  };
}

final class _ThemeModeEncoder extends Converter<ThemeMode, String> {
  const _ThemeModeEncoder();

  @override
  String convert(ThemeMode input) => switch (input) {
    ThemeMode.dark => 'ThemeMode.dark',
    ThemeMode.light => 'ThemeMode.light',
    ThemeMode.system => 'ThemeMode.system',
  };
}

/// Codec for accent [Color] <-> `Map<String, Object?>`.
class _ThemeAccentColorCodec extends Codec<Color, Map<String, Object?>> {
  const _ThemeAccentColorCodec();

  @override
  Converter<Color, Map<String, Object?>> get encoder => const _ThemeAccentColorEncoder();

  @override
  Converter<Map<String, Object?>, Color> get decoder => const _ThemeAccentColorDecoder();
}

final class _ThemeAccentColorDecoder extends Converter<Map<String, Object?>, Color> {
  const _ThemeAccentColorDecoder();

  @override
  Color convert(Map<String, Object?>? input) {
    if (input case {'r': final double r, 'g': final double g, 'b': final double b, 'a': final double a}) {
      return Color.from(alpha: a, red: r, green: g, blue: b);
    }
    throw ArgumentError.value(input, 'input', 'Cannot convert to Color');
  }
}

final class _ThemeAccentColorEncoder extends Converter<Color, Map<String, Object?>> {
  const _ThemeAccentColorEncoder();

  @override
  Map<String, Object?> convert(Color input) => {'r': input.r, 'g': input.g, 'b': input.b, 'a': input.a};
}

/// Convenience extensions.
extension AppSettingsJson on AppSettings {
  Map<String, Object?> toJson() => _appSettingsCodec.encoder.convert(this);
  static AppSettings fromJson(Map<String, Object?> json) => _appSettingsCodec.decoder.convert(json);
}
