import 'dart:convert';

import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';

const _userPreferencesCodec = UserPreferencesCodec();

/// Codec: [UserPreferences] <-> `Map<String,Object?>`.
final class UserPreferencesCodec extends Codec<UserPreferences, Map<String, Object?>> {
  const UserPreferencesCodec();

  @override
  Converter<UserPreferences, Map<String, Object?>> get encoder => const _UserPreferencesEncoder();

  @override
  Converter<Map<String, Object?>, UserPreferences> get decoder => const _UserPreferencesDecoder();
}

final class _UserPreferencesDecoder extends Converter<Map<String, Object?>, UserPreferences> {
  const _UserPreferencesDecoder();

  bool _bool(Object? v, bool fallback) => switch (v) {
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
    useBeta: _bool(input['use_beta'], false),
    useDebug: _bool(input['use_debug'], false),
    useDevelopment: _bool(input['use_development'], false),
    useExpiremental: _bool(input['use_expiremental'], false),
    useHapticFeedback: _bool(input['use_haptic_feedback'], true),
  );
}

final class _UserPreferencesEncoder extends Converter<UserPreferences, Map<String, Object?>> {
  const _UserPreferencesEncoder();

  @override
  Map<String, Object?> convert(UserPreferences input) => <String, Object?>{
    'use_beta': input.useBeta,
    'use_debug': input.useDebug,
    'use_development': input.useDevelopment,
    'use_expiremental': input.useExpiremental,
    'use_haptic_feedback': input.useHapticFeedback,
  };
}

/// Convenience extensions.
extension UserPreferencesJson on UserPreferences {
  Map<String, Object?> toJson() => _userPreferencesCodec.encoder.convert(this);
  static UserPreferences fromJson(Map<String, Object?> json) => _userPreferencesCodec.decoder.convert(json);
}
