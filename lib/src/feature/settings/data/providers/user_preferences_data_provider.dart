import 'dart:convert';

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/data/mappers/user_preferences_codec.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template user_preferences_data_provider}
/// [IUserPreferencesDataProvider] is an entry point to the user preferences data layer.
///
/// This is used to set and get user preferences settings.
/// {@endtemplate}
abstract interface class IUserPreferencesDataProvider {
  /// Read user preferences from cache
  Future<UserPreferences> read();

  /// Save user preferences to cache
  Future<void> save(UserPreferences preferences);
}

/// {@macro user_preferences_data_provider}
class UserPreferencesDataProvider implements IUserPreferencesDataProvider {
  /// {@macro user_preferences_data_provider}
  UserPreferencesDataProvider({required this.sharedPreferences, this.codec = const UserPreferencesCodec()});

  /// The instance of [SharedPreferences] used to read and write values.
  final SharedPreferencesAsync sharedPreferences;

  /// Codec for [UserPreferences]
  final UserPreferencesCodec codec;

  /// The key used to store the user preferences settings in the cache.
  static const String _key = '${Config.storageNamespace}.settings.user_preferences';

  @override
  Future<UserPreferences> read() async {
    final jsonString = await sharedPreferences.getString(_key);
    if (jsonString == null) return const UserPreferences.empty();

    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, Object?>) {
      return codec.decoder.convert(decoded);
    }

    throw const FormatException('Stored value is not a JSON object');
  }

  @override
  Future<void> save(UserPreferences preferences) async {
    final encoded = codec.encoder.convert(preferences);
    final jsonString = jsonEncode(encoded);
    await sharedPreferences.setString(_key, jsonString);
  }
}
