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
  Future<AppSettings> readSettings();

  /// Save app settings to cache
  Future<void> saveSettings(AppSettings settings);

  /// Read user preferences from cache
  Future<UserPreferences> readPreferences();

  /// Save user preferences to cache
  Future<void> savePreferences(UserPreferences preferences);
}

/// {@macro settings_repository}
class SettingsRepository implements ISettingsRepository {
  /// {@macro settings_repository}
  const SettingsRepository({
    required IAppSettingsDataProvider appSettingsDataProvider,
    required IUserPreferencesDataProvider userPreferencesDataProvider,
  }) : _appSettingsDataProvider = appSettingsDataProvider,
       _userPreferencesDataProvider = userPreferencesDataProvider;

  final IAppSettingsDataProvider _appSettingsDataProvider;
  final IUserPreferencesDataProvider _userPreferencesDataProvider;

  @override
  Future<AppSettings> readSettings() => _appSettingsDataProvider.read();

  @override
  Future<void> saveSettings(AppSettings settings) => _appSettingsDataProvider.save(settings);

  @override
  Future<UserPreferences> readPreferences() => _userPreferencesDataProvider.read();

  @override
  Future<void> savePreferences(UserPreferences preferences) => _userPreferencesDataProvider.save(preferences);
}
