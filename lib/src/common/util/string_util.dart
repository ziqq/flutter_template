// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// Default locale
const String _kDefaultLocale = 'ru';

/// The currency type. Used to determine the currency type.
enum CurrencyType {
  /// RUB
  ruble('RUB'),

  /// USD
  dollar('USD');

  /// The currency type.
  const CurrencyType(this.value);

  /// The value of the currency.
  final String value;
}

/// {@template string_util}
/// String util
///
/// A utility class that provides commonly used string operations.
/// {@endtemplate}
final class StringUtil {
  /// {@macro string_util}
  const StringUtil._();

  /// Converts first characters in each word from string to cammel case
  static String toCapitilize(String? value) {
    if (value == null || value.isEmpty) return '';
    return value
        .toLowerCase()
        .split(' ')
        .map((word) {
          final leftText = (word.length > 1) ? word.substring(1, word.length) : '';
          return word[0].toUpperCase() + leftText;
        })
        .join(' ');
  }

  /// Convert to value with currency symbol
  /// [value] - the value to be converted
  /// [locale] - the locale to be used for formatting (default is 'ru')
  /// [name] - the name of the currency (e.g. 'RUB', 'USD')
  /// [symbol] - the symbol of the currency (e.g. '₽', '$')
  /// [decimalDigits] - the number of decimal digits to be used (default is 0)
  /// [isDecimalDigitsWithZeros] - whether to show decimal digits with trailing zeros (default is true)
  /// If [isDecimalDigitsWithZeros] is false, the number of decimal digits will be reduced to 0 if the value is a whole number
  /// Example:
  /// ```dart
  /// StringUtil.currency(
  ///   '1500',
  ///   locale: 'ru',
  ///   symbol: '₽',
  ///   decimalDigits: 2,
  ///   isDecimalDigitsWithZeros: false,
  /// ); // '1 500 ₽'
  /// ```
  static String currency(
    String value, {
    String locale = _kDefaultLocale,
    String? name,
    String? symbol,
    int decimalDigits = 0,
    bool isDecimalDigitsWithZeros = true,
  }) {
    final $price = value.isNotEmpty ? double.tryParse(value) ?? .0 : .0;
    var $decimalDigits = decimalDigits;

    if (decimalDigits > 0 && !isDecimalDigitsWithZeros) {
      $decimalDigits = ($price - $price.floor()) == 0 ? 0 : decimalDigits;
    }

    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: $decimalDigits,
      name: name ?? (locale == _kDefaultLocale ? '₽' : r'$'),
    ).format($price);
  }

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color colorFromHex(String? value) {
    if (value == null || value == '') return const Color(0xFFFFFFFF);
    final buffer = StringBuffer();
    if (value.length == 6 || value.length == 7) buffer.write('ff');
    buffer.write(value.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Return count of days to birthday.
  static int? daysUntilBirthday(String? birthday) {
    if (birthday == null) return null;

    final birthDateParts = birthday.split('-');
    final birthDay = int.parse(birthDateParts.last);
    final birthMonth = int.parse(birthDateParts[1]);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // без времени
    var nextBirthday = DateTime(now.year, birthMonth, birthDay);

    // если день рождения уже прошел в этом году
    if (nextBirthday.isBefore(today)) {
      nextBirthday = DateTime(now.year + 1, birthMonth, birthDay);
    }

    return nextBirthday.difference(today).inDays;
  }

  /// Return a [String] in the desired declension depending on the [number]
  /// [one] is [this]
  static String getNounBasedOnQuantity(
    String? value, {
    required int count,
    required String few,
    required String many,
    String? zero,
  }) {
    if (value == null || value.isEmpty) return '';

    var n = count.abs();
    n %= 100;

    if (n < 1 && zero != null && zero.isNotEmpty) return zero;
    if (n >= 5 && n <= 20) return many;

    n %= 10;

    if (n == 1) return value;
    if (n >= 2 && n <= 4) return few;

    return many;
  }
}

/// A utility with extensions for [String?].
extension StringExtension on String? {
  static const String _dateFormat = 'yyyy-MM-dd HH:mm:ss';

  /// Returns `true` if this is either type `int` or `double`.
  bool get isNumeric {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return switch (self) {
      String s when s.isNotEmpty && double.tryParse(s) != null => true,
      _ => false,
    };
  }

  /// Returns `true` if this nullable char sequence is either `null` or empty.
  bool isNullOrEmpty() => this == null || this!.isEmpty;

  /// Returns `false` if this nullable char sequence is either `null` or empty.
  bool isNotNullOrEmpty() => this != null && this!.isNotEmpty;

  /// Returns a progression that goes over the same range in the opposite direction with the same step.
  String reversed() {
    var res = '';
    for (var i = this!.length; i >= 0; --i) {
      res = this![i];
    }
    return res;
  }

  /// Converts first characters in each word from string to cammel case
  String toCapitilize() => StringUtil.toCapitilize(orEmpty());

  /// Приводит номер телефона к одной строке
  String flattenPhoneNumber() {
    final self = this;
    if (self == null || self.isEmpty) return '';
    return self.replaceAllMapped(RegExp(r'^(\+)|\D'), (m) => m[0] == '+' ? '+' : '');
  }

  /// Return a [String] in the desired declension depending on the [number]
  /// [one] is [this]
  String getNounBasedOnQuantity({required int count, required String few, required String many, String? zero}) =>
      StringUtil.getNounBasedOnQuantity(this, count: count, few: few, many: many, zero: zero);

  /// An extension for get string or empty string if null
  String orEmpty() => this ?? '';

  /// Convert to value with currency symbol
  String currency({
    String locale = _kDefaultLocale,
    String? name,
    String? symbol,
    int decimalDigits = 0,
    bool isDecimalDigitsWithZeros = true,
  }) => StringUtil.currency(
    this ?? '',
    locale: locale,
    name: name,
    symbol: symbol,
    decimalDigits: decimalDigits,
    isDecimalDigitsWithZeros: isDecimalDigitsWithZeros,
  );

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  Color colorFromHex() => StringUtil.colorFromHex(this);

  /// Convert to [Color] from hex [String] with alpha channel
  Color colorFromHexWithAlpha({String alphaChannel = 'FF'}) {
    if (this == null || this == '') return const Color(0xFFFFFFFF);
    return Color(int.parse(this!.replaceFirst('#', '0x$alphaChannel')));
  }

  /// Returns remaining day's as [int]
  int get remainingDays {
    final self = this;
    final isEmpty = self == null || self.isEmpty;
    return isEmpty ? 0 : DateFormat(_dateFormat).parse(self).difference(_formatedDateTimeNow).inDays;
  }

  /// Returns remaining hour's as [int]
  int get remainingHours {
    final self = this;
    final isEmpty = self == null || self.isEmpty;
    return isEmpty ? 0 : DateFormat(_dateFormat).parse(self).difference(_formatedDateTimeNow).inHours;
  }

  /// An extension for validating String is an email.
  bool get isValidEmail {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.emailRegex.hasMatch(self);
  }

  /// An extension for validating String is a name.
  bool get isValidName {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.nameRegex.hasMatch(self);
  }

  /// An extension for validating String is a contact.
  bool get isValidContact {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.contactRegex.hasMatch(self);
  }

  /// An extension for validating String is a contact.
  bool get isValidErp {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.erpRegex.hasMatch(self);
  }

  /// An extension for validating String is a zipcode.
  bool get isValidZipCode {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.zipCodeRegex.hasMatch(self);
  }

  /// An extension for validating String is a credit card number.
  bool get isValidCreditCardNumber {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.creditCardNumberRegex.hasMatch(self);
  }

  /// An extension for validating String is a credit card CVV.
  bool get isValidCreditCardCVV {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.creditCardCVVRegex.hasMatch(self);
  }

  /// An extension for validating String is a credit card expiry.
  bool get isValidCreditCardExpiry {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.creditCardExpiryRegex.hasMatch(self);
  }

  /// An extension for validating String is a valid OTP digit
  bool get isValidOtpDigit {
    final self = this;
    if (self == null || self.isEmpty) return false;
    return Regexes.otpDigitRegex.hasMatch(self);
  }

  DateTime get _formatedDateTimeNow => DateFormat(_dateFormat).parse(DateTime.now().toString());
}

/// A utility class that holds commonly used regular expressions
/// employed throughout the entire app.
@immutable
final class Regexes {
  const Regexes._();

  /// The regular expression for validating emails in the app.
  static RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\.]+\.(com|ru)+");

  /// The regular expression for validating contacts in the app.
  static RegExp contactRegex = RegExp(r'^(03|3)\d{9}$');

  /// The regular expression for validating erps in the app.
  static RegExp erpRegex = RegExp(r'^[1-9]{1}\d{4}$');

  /// The regular expression for validating names in the app.
  static RegExp nameRegex = RegExp(r'^[a-z A-Z]+$');

  /// The regular expression for validating zip codes in the app.
  static RegExp zipCodeRegex = RegExp(r'^\d{5}$');

  /// The regular expression for validating credit card numbers in the app.
  static RegExp creditCardNumberRegex = RegExp(r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14})$');

  /// The regular expression for validating credit card CVV in the app.
  static RegExp creditCardCVVRegex = RegExp(r'^[0-9]{3}$');

  /// The regular expression for validating credit card expiry in the app.
  static RegExp creditCardExpiryRegex = RegExp(r'(0[1-9]|10|11|12)/20[0-9]{2}$');

  /// The regular expression for validating credit card expiry in the app.
  static final RegExp otpDigitRegex = RegExp(r'^[0-9]{1}$');
}
