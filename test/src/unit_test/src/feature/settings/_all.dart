/*
 * Date: 09 September 2024
 */

import 'package:flutter_test/flutter_test.dart';

import 'controller/settings_controller_test.dart' as settings_controller_test;
import 'data/app_settings_codec_test.dart' as app_settings_codec_test;
import 'data/app_settings_data_provider_test.dart' as app_settings_data_provider_test;
import 'data/settings_repository_test.dart' as settings_repository_test;
import 'data/user_preferences_codec_test.dart' as user_preferences_codec_test;
import 'data/user_preferences_data_provider_test.dart' as user_preferences_data_provider_test;

void main() => group('Settings -', () {
  user_preferences_data_provider_test.main();
  user_preferences_codec_test.main();
  app_settings_data_provider_test.main();
  app_settings_codec_test.main();
  settings_repository_test.main();
  settings_controller_test.main();
});
