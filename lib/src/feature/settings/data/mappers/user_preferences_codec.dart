/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 20 November 2025
 */
import 'dart:convert';

import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';

/// Shared [UserPreferencesCodec] instance used by the [UserPreferencesJson] helpers.
const _userPreferencesCodec = UserPreferencesCodec();

/// {@template user_preferences_codec}
/// Codec that converts [UserPreferences] to and from a persistable
/// `Map<String, Object?>` (snake_case keys such as `use_ios26_liquid_theme`).
///
/// The [decoder] is lenient: it accepts `bool`, `int` and `String`
/// representations of a flag and falls back to each field's default when the
/// value is missing or unrecognized.
/// {@endtemplate}
final class UserPreferencesCodec extends Codec<UserPreferences, Map<String, Object?>> {
  /// {@macro user_preferences_codec}
  const UserPreferencesCodec();

  @override
  Converter<UserPreferences, Map<String, Object?>> get encoder => const _UserPreferencesEncoder();

  @override
  Converter<Map<String, Object?>, UserPreferences> get decoder => const _UserPreferencesDecoder();
}

/// Decodes a raw `Map<String, Object?>` into a [UserPreferences] instance.
final class _UserPreferencesDecoder extends Converter<Map<String, Object?>, UserPreferences> {
  const _UserPreferencesDecoder();

  /// Coerce a raw stored value [v] into a `bool`.
  ///
  /// Accepts `bool`, `int` (`0` is `false`, any other value is `true`) and
  /// `String` (`'true'`/`'1'` and `'false'`/`'0'`, case- and space-insensitive).
  /// Returns [fallback] for `null` or any unrecognized value.
  bool _tryParseToBool(Object? v, bool fallback) => switch (v) {
    bool b => b,
    int i => i != 0,
    String s => switch (s.trim().toLowerCase()) {
      'true' || '1' => true,
      'false' || '0' => false,
      _ => fallback,
    },
    _ => fallback,
  };

  @override
  UserPreferences convert(Map<String, Object?> input) => UserPreferences(
    useBeta: _tryParseToBool(input['use_beta'], false),
    useDebug: _tryParseToBool(input['use_debug'], false),
    useDevelopment: _tryParseToBool(input['use_development'], false),
    useExpiremental: _tryParseToBool(input['use_expiremental'], false),
    useHapticFeedback: _tryParseToBool(input['use_haptic_feedback'], true),
    useIOS26LiquidTheme: _tryParseToBool(input['use_ios26_liquid_theme'], false),
    analyticsDataSendingEnabled: _tryParseToBool(input['analytics_data_sending_enabled'], true),
  );
}

/// Encodes a [UserPreferences] instance into a persistable `Map<String, Object?>`.
final class _UserPreferencesEncoder extends Converter<UserPreferences, Map<String, Object?>> {
  const _UserPreferencesEncoder();

  @override
  Map<String, Object?> convert(UserPreferences input) => <String, Object?>{
    'use_beta': input.useBeta,
    'use_debug': input.useDebug,
    'use_development': input.useDevelopment,
    'use_expiremental': input.useExpiremental,
    'use_haptic_feedback': input.useHapticFeedback,
    'use_ios26_liquid_theme': input.useIOS26LiquidTheme,
    'analytics_data_sending_enabled': input.analyticsDataSendingEnabled,
  };
}

/// Convenience Map<String, Object?> helpers around [UserPreferencesCodec].
extension UserPreferencesJson on UserPreferences {
  /// Encode these preferences into a Map<String, Object?>-compatible map.
  Map<String, Object?> toJson() => _userPreferencesCodec.encoder.convert(this);

  /// Decode [json] into a [UserPreferences] instance.
  static UserPreferences fromJson(Map<String, Object?> json) => _userPreferencesCodec.decoder.convert(json);
}
