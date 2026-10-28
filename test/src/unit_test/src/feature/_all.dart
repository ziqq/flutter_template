/*
 * Date: 22 August 2024
 */

import 'package:flutter_test/flutter_test.dart';

import 'home/_all.dart' as home_feature_test;
import 'initialization/http_configuration_test.dart' as http_configuration_test;
import 'initialization/initialization_stats_test.dart' as initialization_stats_test;
import 'initialization/lifecycle_test.dart' as lifecycle_test;
import 'settings/_all.dart' as settings_feature_test;

void main() => group('Feature - ', () {
  home_feature_test.main();
  settings_feature_test.main();
  initialization_stats_test.main();
  http_configuration_test.main();
  lifecycle_test.main();
});
