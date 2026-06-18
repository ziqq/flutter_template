/*
 * Date: 20 November 2025
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/data/mappers/app_settings_codec.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/app_settings_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../util/test_util.mocks.dart';

void main() {
  group('AppSettingsDataProvider -', () {
    const key = '${Config.storageNamespace}.settings';
    late MockSharedPreferencesAsync sharedPreferences;
    late AppSettingsDataProvider provider;

    setUp(() {
      sharedPreferences = MockSharedPreferencesAsync();
      provider = AppSettingsDataProvider(sharedPreferences: sharedPreferences);
    });

    group('read -', () {
      test('returns empty when no value', () async {
        when(sharedPreferences.getString(key)).thenAnswer((_) async => null);
        final result = await provider.read();
        expect(result, const AppSettings.empty());
        verify(sharedPreferences.getString(key)).called(1);
      });

      test('decodes stored map (accent)', () async {
        const original = AppSettings(
          theme: AppTheme(themeMode: ThemeMode.dark, accent: Color(0xFF112233)),
          locale: Locale('en'),
          textScale: 1.25,
        );
        final jsonStr = jsonEncode(const AppSettingsCodec().encoder.convert(original));
        when(sharedPreferences.getString(key)).thenAnswer((_) async => jsonStr);
        final loaded = await provider.read();
        expect(loaded.theme.themeMode, ThemeMode.dark);
        expect(loaded.theme.accent, isNotNull);
        expect(loaded.locale.languageCode, 'en');
        expect(loaded.textScale, 1.25);
        verify(sharedPreferences.getString(key)).called(1);
      });

      test('decodes stored map (no accent)', () async {
        const original = AppSettings(theme: AppTheme.empty(), locale: Locale('fr'), textScale: 1.0);
        final jsonStr = jsonEncode(const AppSettingsCodec().encoder.convert(original));
        when(sharedPreferences.getString(key)).thenAnswer((_) async => jsonStr);
        final loaded = await provider.read();
        expect(loaded.theme.accent, isNull);
        expect(loaded.locale.languageCode, 'fr');
        verify(sharedPreferences.getString(key)).called(1);
      });

      test('throws FormatException for non-map JSON', () async {
        when(sharedPreferences.getString(key)).thenAnswer((_) async => jsonEncode(['x']));
        expect(provider.read(), throwsFormatException);
      });

      test('throws FormatException for malformed JSON', () async {
        when(sharedPreferences.getString(key)).thenAnswer((_) async => '{bad');
        expect(provider.read(), throwsFormatException);
      });
    });

    group('save -', () {
      test('writes encoded JSON', () async {
        when(sharedPreferences.setString(key, any)).thenAnswer((_) async => Future.value());
        const original = AppSettings(
          theme: AppTheme(themeMode: ThemeMode.light),
          locale: Locale('de'),
          textScale: 1.4,
        );
        final stored = jsonEncode(const AppSettingsCodec().encoder.convert(original));
        await provider.save(original);
        expect(stored, isNotNull);
        final decoded = jsonDecode(stored);
        expect(decoded, isA<Map<String?, Object?>>());
        expect(decoded['theme_mode'], 'ThemeMode.light');
        expect(decoded['locale'], containsPair('language_code', 'de'));
        expect(decoded['text_scale'], 1.4);
        verify(sharedPreferences.setString(key, any)).called(1);
      });
    });

    group('symmetry -', () {
      test('save() then read() returns same object', () async {
        when(sharedPreferences.setString(key, any)).thenAnswer((_) async => Future.value());
        const original = AppSettings(
          theme: AppTheme(themeMode: ThemeMode.dark, accent: Color(0xFF336699)),
          locale: Locale('it'),
          textScale: 1.15,
        );
        final stored = jsonEncode(const AppSettingsCodec().encoder.convert(original));
        when(sharedPreferences.getString(key)).thenAnswer((_) async => stored);
        await provider.save(original);
        final loaded = await provider.read();
        expect(loaded.textScale, original.textScale);
        expect(loaded.theme.accent, original.theme.accent);
        expect(loaded.theme.themeMode, original.theme.themeMode);
        expect(loaded.locale.languageCode, original.locale.languageCode);
        verify(sharedPreferences.getString(key)).called(1);
        verify(sharedPreferences.setString(key, any)).called(1);
      });
    });
  });
}
