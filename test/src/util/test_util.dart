// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:io' as io;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/database/database.dart';
import 'package:flutter_template_name/src/feature/authentication/data/authentication_repository.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/app_settings_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/user_preferences_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/data/settings_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'fixture.dart';
export 'mocks/_all.dart';
export 'test_util.mocks.dart';

@GenerateNiceMocks([
  //
  // Common
  //
  MockSpec<FirebaseMessaging>(),
  MockSpec<SharedPreferencesAsync>(),
  MockSpec<SimpleSelectStatement>(), // ignore: strict_raw_type
  MockSpec<InsertStatement>(), // ignore: strict_raw_type
  MockSpec<ApiClient$HTTP>(),
  MockSpec<Database>(),
  MockSpec<io.File>(),
  //
  // Authentication
  //
  MockSpec<AuthenticationRepository>(),
  //
  // Settings
  //
  MockSpec<SettingsRepository>(),
  MockSpec<AppSettingsDataProvider>(),
  MockSpec<UserPreferencesDataProvider>(),
])
void mocks() {}
