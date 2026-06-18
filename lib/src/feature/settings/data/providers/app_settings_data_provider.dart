import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/feature/settings/data/mappers/app_settings_codec.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template app_settings_data_provider}
/// [AppSettingsDataProvider] is an entry point to the app settings data layer.
/// {@endtemplate}
abstract interface class IAppSettingsDataProvider {
  /// Read app settings from cache
  Future<AppSettings> read();

  /// Save app settings to cache
  Future<void> save(AppSettings settings);
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

  @override
  Future<AppSettings> read() async {
    final jsonString = await sharedPreferences.getString(_key);
    if (jsonString == null) return const AppSettings.empty();

    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, Object?>) {
      return codec.decoder.convert(decoded);
    }

    throw const FormatException('Stored value is not a JSON object');
  }

  @override
  Future<void> save(AppSettings settings) async {
    final encoded = codec.encoder.convert(settings);
    final jsonString = jsonEncode(encoded);
    await sharedPreferences.setString(_key, jsonString);
  }
}
