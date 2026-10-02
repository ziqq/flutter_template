import 'package:flutter_test/flutter_test.dart';

import 'router/app_navigator_test.dart' as app_navigator_test;
import 'router/app_route_parser_test.dart' as app_route_parser_test;
import 'router/page_test.dart' as page_test;
import 'router/route_parser_test.dart' as route_parser_test;
import 'widget/common_bottom_spacer_test.dart' as common_bottom_spacer_test;

// ignore: unnecessary_lambdas
void main() => group('Common -', () {
  app_navigator_test.main();
  app_route_parser_test.main();
  page_test.main();
  route_parser_test.main();
  common_bottom_spacer_test.main();
});
