/*
 * Date: 04 March 2026
 */

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:collection/collection.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:money2/money2.dart';

/// {@template price_util}
/// PriceUtil class.
/// {@endtemplate}
final class PriceUtil {
  /// Convert [num] price to [Money] string with currency symbol.
  /// [price] - The price to convert.
  /// [isoCode] - The ISO code of the currency to use for conversion. Defaults to [Config.currency]'s ISO code.
  /// [showDecimalDigits] - Whether to show decimal digits if they are zero. Defaults to `false`.
  /// Example: `1234.00` with `RUB` currency becomes `1 234 ₽` if [showDecimalDigits] is `false`, otherwise `1 234,00 ₽`.
  static String fromNumToMoneyString(num price, {String? isoCode, bool showDecimalDigits = false}) {
    final $currency = Config.currencies.firstWhereOrNull((c) => c.isoCode == isoCode) ?? Config.currency;
    final moneyAsString = Money.fromNumWithCurrency(price, $currency).toString();
    if (!showDecimalDigits) return _stripTrailingZeroFraction(moneyAsString, currency: $currency);
    return moneyAsString;
  }

  /// Convert [num] price to [Money] string with currency symbol.
  /// [price] - The price to convert.
  /// [currency] - The currency to use for conversion. Defaults to [Config.currency].
  /// [showDecimalDigits] - Whether to show decimal digits if they are zero. Defaults to `false`.
  /// Example: `1234.00` with `RUB` currency becomes `1 234 ₽` if [showDecimalDigits] is `false`, otherwise `1 234,00 ₽`.
  static String fromNumWithCurrencyToMoneyString(num price, {Currency? currency, bool showDecimalDigits = false}) {
    final effectiveCurrency = currency ?? Config.currency;
    final moneyAsString = Money.fromNumWithCurrency(price, effectiveCurrency).toString();
    if (!showDecimalDigits) return _stripTrailingZeroFraction(moneyAsString, currency: effectiveCurrency);
    return moneyAsString;
  }

  // Removes a zero fractional part before any trailing currency text or symbol.
  static String _stripTrailingZeroFraction(String value, {required Currency currency}) {
    final zeroFractionSuffixPattern = RegExp('${RegExp.escape(currency.decimalSeparator)}00(?=\\D*\$)');
    return value.replaceFirst(zeroFractionSuffixPattern, '');
  }
}

/// Extension on [Money] to get absolute value of the amount while keeping the currency.
extension MoneyX on Money {
  /// Get the absolute value of the amount while keeping the currency.
  Money abs() => Money.fromDecimalWithCurrency(amount.toDecimal().abs(), currency);

  /// Convert [Money] to string with currency symbol,
  /// optionally removing decimal digits if they are zero.
  String toStringAsFixedZero() => PriceUtil._stripTrailingZeroFraction(toString(), currency: currency);
}
