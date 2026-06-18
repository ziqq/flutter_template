/*
 * Date: 20 November 2025
 */
import 'package:flutter_template_name/src/feature/settings/data/mappers/user_preferences_codec.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserPreferencesCodec -', () {
    const codec = UserPreferencesCodec();

    group('encode -', () {
      test('encodes all boolean fields', () {
        const prefs = UserPreferences(
          useBeta: true,
          useDebug: true,
          useDevelopment: true,
          useExpiremental: true,
          useHapticFeedback: false,
        );
        final map = codec.encoder.convert(prefs);
        expect(map['use_beta'], true);
        expect(map['use_debug'], true);
        expect(map['use_development'], true);
        expect(map['use_expiremental'], true);
        expect(map['use_haptic_feedback'], false);
      });

      test('extension toJson matches encoder', () {
        const prefs = UserPreferences(useBeta: true);
        expect(prefs.toJson(), codec.encoder.convert(prefs));
      });
    });

    group('decode -', () {
      test('decodes bool values directly', () {
        final prefs = codec.decoder.convert({
          'use_beta': true,
          'use_debug': false,
          'use_development': true,
          'use_expiremental': false,
          'use_haptic_feedback': true,
        });
        expect(prefs.useBeta, true);
        expect(prefs.useDebug, false);
        expect(prefs.useDevelopment, true);
        expect(prefs.useExpiremental, false);
        expect(prefs.useHapticFeedback, true);
      });

      test('decodes int values (1/0)', () {
        final prefs = codec.decoder.convert({
          'use_beta': 1,
          'use_debug': 0,
          'use_development': 1,
          'use_expiremental': 0,
          'use_haptic_feedback': 1,
        });
        expect(prefs.useBeta, true);
        expect(prefs.useDebug, false);
        expect(prefs.useDevelopment, true);
        expect(prefs.useExpiremental, false);
        expect(prefs.useHapticFeedback, true);
      });

      test('decodes string truthy/falsy', () {
        final prefs = codec.decoder.convert({
          'use_beta': 'true',
          'use_debug': 'FALSE',
          'use_development': '1',
          'use_expiremental': '0',
          'use_haptic_feedback': 'True',
        });
        expect(prefs.useBeta, true);
        expect(prefs.useDebug, false);
        expect(prefs.useDevelopment, true);
        expect(prefs.useExpiremental, false);
        expect(prefs.useHapticFeedback, true);
      });

      test('unknown string falls back', () {
        final prefs = codec.decoder.convert({
          'use_beta': 'maybe',
          'use_debug': 'yes',
          'use_development': 'nope',
          'use_expiremental': 'x',
          'use_haptic_feedback': '???',
        });
        expect(prefs.useBeta, false);
        expect(prefs.useDebug, false);
        expect(prefs.useDevelopment, false);
        expect(prefs.useExpiremental, false);
        expect(prefs.useHapticFeedback, true);
      });

      test('missing keys -> defaults', () {
        final prefs = codec.decoder.convert({});
        expect(prefs.useBeta, false);
        expect(prefs.useDebug, false);
        expect(prefs.useDevelopment, false);
        expect(prefs.useExpiremental, false);
        expect(prefs.useHapticFeedback, true);
      });
    });

    group('symmetry -', () {
      test('round trip preserves values', () {
        const original = UserPreferences(
          useBeta: true,
          useDebug: true,
          useDevelopment: false,
          useExpiremental: true,
          useHapticFeedback: false,
        );
        final map = codec.encoder.convert(original);
        final restored = codec.decoder.convert(map);
        expect(restored, original);
      });

      test('extension fromJson/toJson round trip', () {
        const original = UserPreferences(useDebug: true, useHapticFeedback: false);
        final json = original.toJson();
        final restored = UserPreferencesJson.fromJson(json);
        expect(restored, original);
      });
    });

    group('robustness -', () {
      test('numeric strings treated as truthy/falsy', () {
        final prefs = codec.decoder.convert({
          'use_beta': '1',
          'use_debug': '0',
          'use_development': ' 1 ',
          'use_expiremental': ' 0 ',
          'use_haptic_feedback': '1',
        });
        expect(prefs.useBeta, true);
        expect(prefs.useDebug, false);
        expect(prefs.useDevelopment, true);
        expect(prefs.useExpiremental, false);
        expect(prefs.useHapticFeedback, true);
      });

      test('mixed types still fallback correctly', () {
        final prefs = codec.decoder.convert({
          'use_beta': null,
          'use_debug': [],
          'use_development': {},
          'use_expiremental': 7, // int != 0 -> true
        });
        expect(prefs.useBeta, false);
        expect(prefs.useDebug, false);
        expect(prefs.useDevelopment, false);
        expect(prefs.useExpiremental, true);
        expect(prefs.useHapticFeedback, true); // fallback true
      });
    });
  });
}
