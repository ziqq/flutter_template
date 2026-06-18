/*
 * Date: 22 August 2024
 */

import 'package:flutter_test/flutter_test.dart';

import 'home/_all.dart' as home_feature_test;
import 'settings/_all.dart' as settings_feature_test;

void main() => group('Feature - ', () {
  home_feature_test.main();
  settings_feature_test.main();
});
