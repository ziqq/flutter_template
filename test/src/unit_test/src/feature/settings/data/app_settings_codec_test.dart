/*
 * Date: 20 November 2025
 */

import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/data/mappers/app_settings_codec.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettingsCodec -', () {
    const appSettingsCodec = AppSettingsCodec();

    group('encode -', () {
      test('encodes accent color when present', () {
        const accent = Color(0xFF112233);
        const settings = AppSettings(
          theme: AppTheme(themeMode: ThemeMode.dark, accent: accent),
          locale: Locale('en'),
          textScale: 1.0,
        );
        final map = appSettingsCodec.encoder.convert(settings);
        expect(map['accent_color'], isA<Map<String, Object?>>());
        expect(map['accent_color'], containsPair('r', accent.r));
        expect(map['accent_color'], containsPair('g', accent.g));
        expect(map['accent_color'], containsPair('b', accent.b));
        expect(map['accent_color'], containsPair('a', accent.a));
      });

      test('omits accent color when null', () {
        const settings = AppSettings(
          theme: AppTheme(themeMode: ThemeMode.light),
          locale: Locale('en'),
          textScale: 1.0,
        );
        final map = appSettingsCodec.encoder.convert(settings);
        expect(map.containsKey('accent_color'), isFalse);
      });

      test('encodes locale with language only', () {
        const settings = AppSettings(theme: AppTheme.empty(), locale: Locale('fr'), textScale: 1.0);
        final map = appSettingsCodec.encoder.convert(settings);
        expect(map['locale'], equals({'language_code': 'fr'}));
      });

      test('encodes locale with script & country', () {
        const settings = AppSettings(
          locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
          theme: AppTheme.empty(),
          textScale: 1.0,
        );
        final map = appSettingsCodec.encoder.convert(settings);
        expect(map['locale'], equals({'language_code': 'zh', 'script_code': 'Hant', 'country_code': 'TW'}));
      });

      test('accent components are normalized doubles (0..1)', () {
        const settings = AppSettings(
          theme: AppTheme(themeMode: ThemeMode.dark, accent: Color(0xFF336699)),
          locale: Locale('en'),
          textScale: 1.0,
        );
        final map = appSettingsCodec.encoder.convert(settings);
        final c = map['accent_color'] as Map<String, Object?>;
        for (final k in ['r', 'g', 'b', 'a']) {
          expect(c[k], isA<num>());
          expect((c[k] as num) >= 0, isTrue);
          expect((c[k] as num) <= 1, isTrue);
        }
      });

      test('text_scale preserved exactly when in range', () {
        const settings = AppSettings(theme: AppTheme.empty(), locale: Locale('en'), textScale: 1.75);
        final map = appSettingsCodec.encoder.convert(settings);
        expect(map['text_scale'], 1.75);
      });
    });

    group('decode -', () {
      test('decodes full locale map', () {
        final map = {
          'locale': {'language_code': 'zh', 'script_code': 'Hant', 'country_code': 'TW'},
          'theme_mode': 'ThemeMode.dark',
          'text_scale': 1.25,
        };
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.locale.languageCode, 'zh');
        expect(settings.locale.scriptCode, 'Hant');
        expect(settings.locale.countryCode, 'TW');
        expect(settings.theme.themeMode, ThemeMode.dark);
        expect(settings.textScale, 1.25);
      });

      test('decodes locale from string "en-US"', () {
        final map = {'locale': 'en-US', 'theme_mode': 'ThemeMode.system', 'text_scale': 1.0};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.locale.languageCode, 'en');
        expect(settings.locale.countryCode, 'US');
      });

      test('decodes locale from string with underscore "en_US"', () {
        final map = {'locale': 'en_US', 'theme_mode': 'ThemeMode.system', 'text_scale': 1.0};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.locale.languageCode, 'en');
        expect(settings.locale.countryCode, 'US');
      });

      test('decodes locale from string "zh-Hant-TW"', () {
        final map = {'locale': 'zh-Hant-TW', 'theme_mode': 'ThemeMode.system', 'text_scale': 1.0};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.locale.languageCode, 'zh');
        expect(settings.locale.scriptCode, 'Hant');
        expect(settings.locale.countryCode, 'TW');
      });

      test('decodes locale from script variant "sr-Cyrl-RS"', () {
        final map = {'locale': 'sr-Cyrl-RS', 'theme_mode': 'ThemeMode.light', 'text_scale': 1.0};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.locale.languageCode, 'sr');
        expect(settings.locale.scriptCode, 'Cyrl');
        expect(settings.locale.countryCode, 'RS');
      });

      test('falls back to Config.locale when invalid locale map', () {
        final map = {
          'locale': {'language_code': ''},
          'theme_mode': 'ThemeMode.system',
          'text_scale': 1.0,
        };
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.locale.languageCode, Config.locale.languageCode);
      });

      test('falls back to Config.locale when locale missing', () {
        final map = {'theme_mode': 'ThemeMode.system', 'text_scale': 1.0};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.locale.languageCode, Config.locale.languageCode);
      });

      test('clamps textScale lower bound', () {
        final map = {'locale': 'en', 'theme_mode': 'ThemeMode.light', 'text_scale': 0.1};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.textScale, 0.5);
      });

      test('clamps textScale upper bound', () {
        final map = {'locale': 'en', 'theme_mode': 'ThemeMode.light', 'text_scale': 5.0};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.textScale, 2.0);
      });

      test('parses textScale from string', () {
        final map = {'locale': 'en', 'theme_mode': 'ThemeMode.system', 'text_scale': '1.375'};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.textScale, 1.375);
      });

      test('parses textScale from int', () {
        final map = {'locale': 'en', 'theme_mode': 'ThemeMode.system', 'text_scale': 2};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.textScale, 2.0);
      });

      test('defaults textScale when missing', () {
        final map = {'locale': 'en', 'theme_mode': 'ThemeMode.system'};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.textScale, 1.0);
      });

      test('defaults themeMode when missing', () {
        final map = {'locale': 'en', 'text_scale': 1.0};
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.theme.themeMode, ThemeMode.system);
      });

      test('decodes accent color', () {
        final map = {
          'locale': 'en',
          'theme_mode': 'ThemeMode.dark',
          'text_scale': 1.0,
          'accent_color': {'r': 10.0, 'g': 20.0, 'b': 30.0, 'a': 255.0},
        };
        final settings = appSettingsCodec.decoder.convert(map);
        expect(settings.theme.accent, isNotNull);
      });

      test('invalid accent color map throws', () {
        final map = {
          'locale': 'en',
          'theme_mode': 'ThemeMode.dark',
          'text_scale': 1.0,
          'accent_color': {'x': 1},
        };
        expect(() => appSettingsCodec.decoder.convert(map), throwsArgumentError);
      });

      test('invalid theme_mode throws', () {
        final map = {'locale': 'en', 'theme_mode': 'bad-mode', 'text_scale': 1.0};
        expect(() => appSettingsCodec.decoder.convert(map), throwsArgumentError);
      });
    });

    group('symmetry', () {
      test('encode -> decode round trip (with accent & full locale)', () {
        const original = AppSettings(
          theme: AppTheme(themeMode: ThemeMode.dark, accent: Color(0xFF336699)),
          locale: Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
          textScale: 1.3,
        );
        final encoded = appSettingsCodec.encoder.convert(original);
        final decoded = appSettingsCodec.decoder.convert(encoded);
        expect(decoded.theme.themeMode, original.theme.themeMode);
        expect(decoded.locale.languageCode, original.locale.languageCode);
        expect(decoded.locale.countryCode, original.locale.countryCode);
        expect(decoded.textScale, original.textScale);
      });

      test('encode -> decode round trip (no accent)', () {
        const original = AppSettings(theme: AppTheme.empty(), locale: Locale('de'), textScale: 1.0);
        final encoded = appSettingsCodec.encoder.convert(original);
        final decoded = appSettingsCodec.decoder.convert(encoded);
        expect(decoded.theme.accent, isNull);
        expect(decoded.locale.languageCode, 'de');
        expect(decoded.theme.themeMode, ThemeMode.system);
      });

      test('round trip clamps oversized textScale', () {
        const original = AppSettings(theme: AppTheme.empty(), locale: Locale('en'), textScale: 5.0);
        final encoded = appSettingsCodec.encoder.convert(original);
        final decoded = appSettingsCodec.decoder.convert(encoded);
        expect(encoded['text_scale'], 5.0);
        expect(decoded.textScale, 2.0);
      });

      test('extension toJson/fromJson symmetry', () {
        const original = AppSettings(
          theme: AppTheme(themeMode: ThemeMode.light),
          locale: Locale('it'),
          textScale: 1.15,
        );
        final json = original.toJson();
        final parsed = AppSettingsJson.fromJson(json);
        expect(parsed.locale.languageCode, 'it');
        expect(parsed.theme.themeMode, ThemeMode.light);
        expect(parsed.textScale, 1.15);
      });
    });
  });
}
