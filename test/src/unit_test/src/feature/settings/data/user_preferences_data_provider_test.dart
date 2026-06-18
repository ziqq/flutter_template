/*
 * Date: 20 November 2025
 */

import 'dart:convert';

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/data/mappers/user_preferences_codec.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/user_preferences_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../util/test_util.mocks.dart';

void main() {
  group('UserPreferencesDataProvider -', () {
    const key = '${Config.storageNamespace}.settings.user_preferences';
    late MockSharedPreferencesAsync sharedPreferences;
    late UserPreferencesDataProvider provider;

    setUp(() {
      sharedPreferences = MockSharedPreferencesAsync();
      provider = UserPreferencesDataProvider(sharedPreferences: sharedPreferences);
    });

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

    group('save -', () {
      test('writes encoded JSON', () async {
        when(sharedPreferences.setString(key, any)).thenAnswer((_) async => Future.value());
        const original = UserPreferences(
          useBeta: true,
          useDebug: false,
          useDevelopment: true,
          useExpiremental: false,
          useHapticFeedback: true,
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

        verify(sharedPreferences.setString(key, any)).called(1);
      });
    });

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
