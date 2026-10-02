/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 05 January 2024
 */

import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/app_settings_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/user_preferences_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';

/// {@template settings_repository}
/// Settings repository interface.
/// Provides access to user preferences, locale, and theme data.
/// {@endtemplate}
abstract interface class ISettingsRepository {
  /// Read app settings from cache
  /// [userID] - The user associated with the settings, if applicable. Needed for accent color settings.
  Future<AppSettings> readSettings({UserID? userID});

  /// Save app settings to cache
  /// [settings] - The app settings to be saved.
  /// [userID] - The user associated with the settings, if applicable. Needed for accent color settings.
  Future<void> saveSettings({required AppSettings settings, UserID? userID});

  /// Read user preferences from cache
  Future<UserPreferences> readPreferences();

  /// Save user preferences to cache
  Future<void> savePreferences(UserPreferences preferences);
}

/// {@macro settings_repository}
class SettingsRepository implements ISettingsRepository {
  /// {@macro settings_repository}
  const SettingsRepository({required this._appSettingsDataProvider, required this._userPreferencesDataProvider});

  final IAppSettingsDataProvider _appSettingsDataProvider;
  final IUserPreferencesDataProvider _userPreferencesDataProvider;

  @override
  Future<AppSettings> readSettings({UserID? userID}) => _appSettingsDataProvider.read(userID: userID);

  @override
  Future<void> saveSettings({required AppSettings settings, UserID? userID}) =>
      _appSettingsDataProvider.save(settings: settings, userID: userID);

  @override
  Future<UserPreferences> readPreferences() => _userPreferencesDataProvider.read();

  @override
  Future<void> savePreferences(UserPreferences preferences) => _userPreferencesDataProvider.save(preferences);
}
