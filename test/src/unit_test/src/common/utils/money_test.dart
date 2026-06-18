/*
 * Date: 28 January 2026
 *
 * Test to check [Money] operations.
 */

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money2/money2.dart';

void main() => group('Money operations check -', () {
  group('default -', () {
    const result = 1000000;
    var value = .0;
    while (value < result) {
      value += .1;
    }
    test('expect $value to $result', () {
      expect(value, isNot(result));
    });
  });

  group('package -', () {
    final result = Money.fromIntWithCurrency(100000000, Config.currency);
    final oneTenth = Money.fromNumWithCurrency(.1, Config.currency);
    var value = Money.fromIntWithCurrency(0, Config.currency);
    while (value < result) {
      value += oneTenth;
    }
    test('expect $value to $result', () {
      expect(value, result);
    });
  });
});
