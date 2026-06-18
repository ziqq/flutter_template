// Autor - <a.a.ustinoff@gmail.com> Anton Ustinoff, 22 August 2024

import 'package:flutter_test/flutter_test.dart';

import 'models/app_metadata_test.dart' as app_metadata_test;
import 'utils/debouncing_test.dart' as debouncing_test;
import 'utils/in_app_review_service_test.dart' as in_app_review_service_test;
import 'utils/middleware/authentication_middleware_test.dart' as authentication_middleware_test;
import 'utils/money_test.dart' as money_test;
import 'utils/price_util_test.dart' as price_util_test;

void main() => group('Common -', () {
  group('Models -', app_metadata_test.main);
  group('Utils -', () {
    authentication_middleware_test.main();
    in_app_review_service_test.main();
    debouncing_test.main();
    price_util_test.main();
    money_test.main();
  });
});
