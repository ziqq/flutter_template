/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 20 November 2025
 */

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/data/mappers/user_preferences_codec.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/user_preferences_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';

import '../../../../../util/test_util.mocks.dart';

/// Unit tests for [UserPreferencesDataProvider]: reading from and writing to
/// `SharedPreferences` through [UserPreferencesCodec], including handling of
/// missing/malformed JSON and the `use_ios26_liquid_theme` flag.
void main() {
  group('UserPreferencesDataProvider -', () {
    const key = '${Config.storageNamespace}.settings.user_preferences';
    late MockSharedPreferencesAsync sharedPreferences;
    late UserPreferencesDataProvider provider;

    setUp(() {
      sharedPreferences = MockSharedPreferencesAsync();
      provider = UserPreferencesDataProvider(sharedPreferences: sharedPreferences);
    });

    // Reading: decode stored JSON, fall back to empty preferences when absent,
    // and surface a FormatException for non-map or malformed JSON.
    group('read -', () {
      test('returns empty when no value', () async {
        when(sharedPreferences.getString(key)).thenAnswer((_) async => null);
        final result = await provider.read();
        expect(result, const UserPreferences.empty());
        verify(sharedPreferences.getString(key)).called(1);
      });

      test('decodes stored map', () async {
        const original = UserPreferences(
          useBeta: true,
          useDebug: true,
          useDevelopment: false,
          useExpiremental: true,
          useHapticFeedback: false,
        );
        final jsonStr = jsonEncode(const UserPreferencesCodec().encoder.convert(original));
        when(sharedPreferences.getString(key)).thenAnswer((_) async => jsonStr);

        final loaded = await provider.read();
        expect(loaded, original);
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

    // Writing: preferences are persisted as the codec-encoded JSON map.
    group('save -', () {
      test('writes encoded JSON', () async {
        when(sharedPreferences.setString(key, any)).thenAnswer((_) async => Future.value());
        const original = UserPreferences(
          useBeta: true,
          useDebug: false,
          useDevelopment: true,
          useExpiremental: false,
          useHapticFeedback: true,
          useIOS26LiquidTheme: true,
        );

        final stored = jsonEncode(const UserPreferencesCodec().encoder.convert(original));
        await provider.save(original);

        expect(stored, isNotNull);
        final decoded = jsonDecode(stored);
        expect(decoded, isA<Map<String?, Object?>>());
        expect(decoded['use_beta'], true);
        expect(decoded['use_debug'], false);
        expect(decoded['use_development'], true);
        expect(decoded['use_expiremental'], false);
        expect(decoded['use_haptic_feedback'], true);
        expect(decoded['use_ios26_liquid_theme'], true);

        verify(sharedPreferences.setString(key, any)).called(1);
      });
    });

    // Symmetry: a value saved through the provider reads back unchanged.
    group('symmetry -', () {
      test('save() then read() returns same object', () async {
        when(sharedPreferences.setString(key, any)).thenAnswer((_) async => Future.value());
        const original = UserPreferences(
          useBeta: true,
          useDebug: true,
          useDevelopment: true,
          useExpiremental: false,
          useHapticFeedback: false,
        );

        final stored = jsonEncode(const UserPreferencesCodec().encoder.convert(original));
        when(sharedPreferences.getString(key)).thenAnswer((_) async => stored);

        await provider.save(original);
        final loaded = await provider.read();

        expect(loaded, original);
        verify(sharedPreferences.setString(key, any)).called(1);
        verify(sharedPreferences.getString(key)).called(1);
      });
    });
  });
}
