import 'util/analytics_consent_test.dart' as analytics_consent_test;
/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 22 August 2024
 */

import 'package:flutter_test/flutter_test.dart';

import 'model/app_metadata_test.dart' as app_metadata_test;
import 'util/debouncing_test.dart' as debouncing_test;
import 'util/file_storage_test.dart' as file_storage_test;
import 'util/in_app_review_service_test.dart' as in_app_review_service_test;
import 'util/middleware/authentication_middleware_test.dart' as authentication_middleware_test;
import 'util/money_test.dart' as money_test;
import 'util/price_util_test.dart' as price_util_test;

void main() => group('Common -', () {
  analytics_consent_test.main();
  group('Model -', app_metadata_test.main);
  group('Util -', () {
    group('Middleware -', authentication_middleware_test.main);
    file_storage_test.main();
    in_app_review_service_test.main();
    debouncing_test.main();
    price_util_test.main();
    money_test.main();
  });
});
