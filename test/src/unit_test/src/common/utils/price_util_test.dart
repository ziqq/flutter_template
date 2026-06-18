/*
 * Date: 17 April 2026
 */

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/util/price_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money2/money2.dart';

void main() => group('PriceUtil -', () {
  final usd = Config.getCurrencyByIsoCode('USD');
  final eur = Config.getCurrencyByIsoCode('EUR');
  final aed = Currency.create(
    'AED',
    2,
    symbol: 'AED',
    groupSeparator: ',',
    decimalSeparator: '.',
    pattern: '#,##0.00 S',
  );
  final rubText = Currency.create(
    'RUB_TEXT',
    2,
    symbol: 'руб.',
    groupSeparator: ' ',
    decimalSeparator: ',',
    pattern: '#,##0.00 S',
  );

  group('fromNumWithCurrencyToMoneyString -', () {
    test('removes trailing zero fraction for ruble symbol', () {
      expect(PriceUtil.fromNumWithCurrencyToMoneyString(1234, currency: Config.currency), '1 234 ₽');
    });

    test('removes trailing zero fraction for usd symbol', () {
      expect(PriceUtil.fromNumWithCurrencyToMoneyString(1234, currency: usd), r'1,234 $');
    });

    test('removes trailing zero fraction for euro symbol', () {
      expect(PriceUtil.fromNumWithCurrencyToMoneyString(1234, currency: eur), '1.234 €');
    });

    test('removes trailing zero fraction for multi-character currency suffix', () {
      expect(PriceUtil.fromNumWithCurrencyToMoneyString(1234, currency: aed), '1,234 AED');
    });

    test('keeps non-zero fraction untouched', () {
      expect(PriceUtil.fromNumWithCurrencyToMoneyString(1234.5, currency: usd), r'1,234.50 $');
    });
  });

  group('toStringAsFixedZero -', () {
    test('removes trailing zero fraction before text currency suffix', () {
      final money = Money.fromNumWithCurrency(1234, rubText);
      expect(money.toStringAsFixedZero(), '1 234 руб.');
    });
  });
});
