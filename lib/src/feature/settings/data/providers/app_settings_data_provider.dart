import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/settings/data/mappers/app_settings_codec.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';

/// {@template app_settings_data_provider}
/// [AppSettingsDataProvider] is an entry point to the app settings data layer.
/// {@endtemplate}
abstract interface class IAppSettingsDataProvider {
  /// Read app settings from cache
  Future<AppSettings> read({UserID? userID});

  /// Save app settings to cache
  Future<void> save({required AppSettings settings, UserID? userID});
}

/// {@macro app_settings_data_provider}
class AppSettingsDataProvider implements IAppSettingsDataProvider {
  /// {@macro app_settings_data_provider}
  AppSettingsDataProvider({required this.sharedPreferences, this.codec = const AppSettingsCodec()});

  /// The instance of [SharedPreferences] used to read and write values.
  final SharedPreferencesAsync sharedPreferences;

  /// Codec for [ThemeMode]
  final AppSettingsCodec codec;

  /// The key used to store the app settings in the cache.
  final _key = '${Config.storageNamespace}.settings';

  /// Resolves the key for storing specific app settings in the cache to current user.
  String _resolveKey(UserID? userID) => userID != null ? '$_key.$userID' : _key;

  @override
  Future<AppSettings> read({UserID? userID}) async {
    final jsonString = await sharedPreferences.getString(_resolveKey(userID));
    if (jsonString == null) return const AppSettings.empty();

    final decoded = jsonDecode(jsonString);
    if (decoded case Map<String, Object?> json) return codec.decoder.convert(json);

    throw FormatException('AppSettingsDataProvider.read | Stored value is not a Map<String, Object?> object', decoded);
  }

  @override
  Future<void> save({required AppSettings settings, UserID? userID}) async {
    final encoded = codec.encoder.convert(settings);
    final jsonString = jsonEncode(encoded);
    await sharedPreferences.setString(_resolveKey(userID), jsonString);
  }
}
