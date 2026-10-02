import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// {@template text_input_formatter_price}
/// Price formatter.
/// Rules:
/// - Only digits, one optional leading minus sign and one optional decimal separator allowed.
/// - Output uses space as thousands separator and comma as decimal separator.
/// - Only one decimal separator kept (first encountered).
/// - Leading separator like ",5" becomes "0,5".
/// - Trailing zeros in fractional part trimmed (unless all zeros, then preserved for further input).
/// - Optional decimal digit limit (decimalDigits). If 0 -> no fraction allowed, if null -> unlimited.
/// - Caret preserved as close as possible to user intent.
/// {@endtemplate}
final class TextInputFormatter$Price extends TextInputFormatter {
  /// {@macro text_input_formatter_price}
  const TextInputFormatter$Price({this.decimalDigits = 2})
    : assert(decimalDigits == null || decimalDigits >= 0, 'Decimal digits must be nonnegative.');

  /// Limit of fraction digits.
  /// [null] - unlimited.
  /// [0] - forbid fraction.
  final int? decimalDigits;

  /// Format raw string (initial value).
  /// If empty, returns [TextEditingValue.empty].
  /// [cursor] - initial cursor position (default to end of string).
  /// [decimalDigits] - override instance decimal digits limit.
  /// Returns formatted [TextEditingValue] with updated text and cursor position.
  static TextEditingValue formatRaw(String raw, {int? cursor, int? decimalDigits = 2}) {
    if (decimalDigits != null && decimalDigits < 0) {
      throw ArgumentError.value(decimalDigits, 'decimalDigits', 'Must be nonnegative.');
    }
    if (raw.isEmpty) return TextEditingValue.empty;
    return _format(raw, cursor ?? raw.length, decimalDigits: decimalDigits);
  }

  /// Compatibility.
  /// See [formatRaw].
  static TextEditingValue formatInitial(String text, {int? decimalDigits = 2}) =>
      formatRaw(text, decimalDigits: decimalDigits);

  /// Apply formatting to existing [TextEditingController].
  static void apply(TextEditingController controller, {int? decimalDigits = 2}) {
    if (controller.text.isEmpty || !controller.value.composing.isCollapsed) return;
    final value = TextInputFormatter$Price(decimalDigits: decimalDigits)
        .formatEditUpdate(controller.value, controller.value);
    if (controller.value != value) controller.value = value;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // SDK formatters must leave active IME composition untouched.
    if (!newValue.composing.isCollapsed) return newValue;
    if (newValue.text.isEmpty) return TextEditingValue.empty;

    // If platform removed a space and moved caret left, restore text and keep caret where user wants.
    // Check if a space was removed (text became shorter by 1) and caret moved left by 1
    final spaceWasRemoved = oldValue.text.length == newValue.text.length + 1;
    final caretMovedLeft = newValue.selection.end == oldValue.selection.end - 1;

    // Check if the removed character was actually a space.
    // When backspace is pressed, we need to check character BEFORE the old caret position
    final removedCharWasSpace =
        spaceWasRemoved && oldValue.selection.end > 0 && oldValue.text.codeUnitAt(oldValue.selection.end - 1) == 0x20;

    if (spaceWasRemoved && caretMovedLeft && removedCharWasSpace) {
      // Don't just restore position, move caret one position LEFT over the space
      final targetCaretPosition = (oldValue.selection.end - 1).clamp(0, oldValue.text.length);
      return oldValue.copyWith(selection: TextSelection.collapsed(offset: targetCaretPosition));
    }

    final isCollapsedBackspace =
        oldValue.selection.isCollapsed &&
        newValue.selection.isCollapsed &&
        oldValue.text.length == newValue.text.length + 1 &&
        newValue.selection.end == oldValue.selection.end - 1;

    int? removedCodeUnit;
    if (isCollapsedBackspace && oldValue.selection.end > 0) {
      removedCodeUnit = oldValue.text.codeUnitAt(oldValue.selection.end - 1);
    }

    // Remove the first significant digit: if only zeros remain in integer part -> collapse to '0'.
    bool collapseToZero = false;
    if (isCollapsedBackspace && removedCodeUnit != null) {
      final negative = oldValue.text.startsWith('-');
      final firstDigitIndex = negative ? 1 : 0;
      final removedIndex = oldValue.selection.end - 1;
      final removedIsDigit = removedCodeUnit >= 48 && removedCodeUnit <= 57;
      if (removedIsDigit && removedIndex == firstDigitIndex) {
        final commaIdx = newValue.text.indexOf(',');
        final intPartRaw = (commaIdx == -1 ? newValue.text : newValue.text.substring(0, commaIdx))
            .replaceAll(' ', '')
            .replaceAll(RegExp('[^0-9]'), '');
        if (intPartRaw.isNotEmpty && RegExp(r'^0+$').hasMatch(intPartRaw)) {
          collapseToZero = true;
        }
      }
    }

    if (collapseToZero) {
      // Save fractional part if any
      final commaIdx = newValue.text.indexOf(',');
      final frac = commaIdx == -1 ? '' : newValue.text.substring(commaIdx + 1).replaceAll(RegExp('[^0-9]'), '');
      final raw = frac.isEmpty ? '0' : '0,$frac';
      final withSign = oldValue.text.startsWith('-') ? '-$raw' : raw;
      final formatted = _format(withSign, withSign.length, decimalDigits: decimalDigits, didBackspace: true);
      // Move caret to right position (after '0' and before comma if any)
      final caret = withSign.startsWith('-') ? 2 : 1;
      return formatted.copyWith(selection: TextSelection.collapsed(offset: caret));
    }

    final formatted = _format(
      newValue.text,
      newValue.selection.extentOffset,
      decimalDigits: decimalDigits,
      didBackspace: isCollapsedBackspace,
    );
    if (newValue.selection.isCollapsed || !newValue.selection.isValid) return formatted;
    final base = _format(
      newValue.text,
      newValue.selection.baseOffset,
      decimalDigits: decimalDigits,
    ).selection.extentOffset;
    return formatted.copyWith(
      selection: TextSelection(baseOffset: base, extentOffset: formatted.selection.extentOffset),
    );
  }

  static TextEditingValue _format(String raw, int selectionEnd, {int? decimalDigits = 2, bool didBackspace = false}) {
    final rawToSanitized = List<int>.filled(raw.length + 1, 0);
    final selEnd = selectionEnd.clamp(0, raw.length);
    final buffer = StringBuffer();
    bool isNegative = false;
    bool hasDot = false;
    final bool forbidFraction = decimalDigits != null && decimalDigits <= 0;
    // When true we ignore remaining chars (fraction forbidden and separator encountered)
    bool terminatedInt = false;
    for (var i = 0; i < raw.length; i++) {
      final c = raw[i];
      final code = c.codeUnitAt(0);
      final isDigit = code >= 48 && code <= 57;
      if (terminatedInt) {
        // We already encountered a separator with fraction forbidden: ignore rest.
        rawToSanitized[i + 1] = buffer.length;
        continue;
      }
      if (c == '-' && buffer.isEmpty && !isNegative) {
        isNegative = true;
        rawToSanitized[i + 1] = buffer.length; // Sign not included in sanitized buffer
        continue;
      }
      if (isDigit) {
        buffer.write(c);
        rawToSanitized[i + 1] = buffer.length;
        continue;
      }
      if ((c == ',' || c == '.') && !hasDot) {
        if (forbidFraction) {
          // Stop further parsing entirely (drop separator and following digits)
          terminatedInt = true;
          rawToSanitized[i + 1] = buffer.length; // Separator ignored
          continue;
        }
        if (decimalDigits == null || decimalDigits != 0) {
          hasDot = true;
          buffer.write('.');
          rawToSanitized[i + 1] = buffer.length;
          continue;
        }
      }
      rawToSanitized[i + 1] = buffer.length; // ignored
    }

    final sanitized = buffer.toString();
    if (sanitized.isEmpty) {
      // For forbidden fraction mode we still want a "0" placeholder so user sees numeric context.
      if (forbidFraction) {
        if (isNegative) {
          return const TextEditingValue(
            text: '-0',
            selection: TextSelection.collapsed(offset: 2),
            composing: TextRange.empty,
          );
        }
        return const TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: 1),
          composing: TextRange.empty,
        );
      }
      if (isNegative) {
        return const TextEditingValue(
          text: '-',
          selection: TextSelection.collapsed(offset: 1),
          composing: TextRange.empty,
        );
      }
      return TextEditingValue.empty;
    }

    final cursorSanitizedPos = rawToSanitized[selEnd];
    final dotIndex = sanitized.indexOf('.');
    String fracPart = '';
    String intPart;
    int cursorIntFracBoundary;
    if (dotIndex == -1) {
      intPart = sanitized;
      cursorIntFracBoundary = sanitized.length;
    } else {
      intPart = sanitized.substring(0, dotIndex);
      fracPart = sanitized.substring(dotIndex + 1);
      cursorIntFracBoundary = dotIndex;
    }

    if (intPart.isEmpty) intPart = '0';

    // Apply decimal limit (truncate) BEFORE trimming zeros so user can't exceed
    if (decimalDigits != null) {
      if (decimalDigits <= 0) {
        // No decimals permitted: drop any fractional intent entirely (even if user typed separator first)
        fracPart = '';
        // Also if user started with a separator like ",5" produce just integer part (already ensured intPart fallback '0').
      } else if (fracPart.length > decimalDigits) {
        fracPart = fracPart.substring(0, decimalDigits);
      }
    }

    // Trim trailing zeros only when decimal limit is not set (free typing mode)
    if (fracPart.isNotEmpty && decimalDigits == null) {
      final hasNonZero = fracPart.contains(RegExp('[1-9]'));
      if (hasNonZero) {
        var end = fracPart.length;
        while (end > 0 && fracPart[end - 1] == '0') {
          end--;
        }
        fracPart = fracPart.substring(0, end);
      }
    }

    final originalIntDigits = intPart.replaceAll(RegExp('[^0-9]'), '');
    int firstNonZero = -1;
    for (var i = 0; i < originalIntDigits.length; i++) {
      if (originalIntDigits.codeUnitAt(i) != 48) {
        firstNonZero = i;
        break;
      }
    }
    String intDigits;
    int leadingZerosRemoved;
    intDigits = firstNonZero <= 0
        ? (firstNonZero == -1 ? '0' : originalIntDigits)
        : originalIntDigits.substring(firstNonZero);
    leadingZerosRemoved = firstNonZero <= 0 ? 0 : firstNonZero;
    final groupedBuffer = StringBuffer();
    final insertionPositions = <int>[];
    for (var i = 0; i < intDigits.length; i++) {
      final digitsRemaining = intDigits.length - i;
      if (i > 0 && digitsRemaining % 3 == 0) groupedBuffer.write(' ');
      insertionPositions.add(groupedBuffer.length);
      groupedBuffer.write(intDigits[i]);
    }
    final groupedInt = groupedBuffer.toString();

    final hadDot = dotIndex != -1 && (decimalDigits == null || decimalDigits != 0);
    final trailingDot =
        hadDot && fracPart.isEmpty && sanitized.endsWith('.') && (decimalDigits == null || decimalDigits > 0);
    final showDecimal = (decimalDigits == null || decimalDigits != 0) && (fracPart.isNotEmpty || trailingDot);

    final coreText = showDecimal ? (fracPart.isNotEmpty ? '$groupedInt,$fracPart' : '$groupedInt,') : groupedInt;
    final finalText = isNegative ? '-$coreText' : coreText;

    int newCursor;
    if (cursorSanitizedPos <= cursorIntFracBoundary) {
      int digitsBefore = cursorSanitizedPos;
      // Adjust for trimmed leading zeros.
      digitsBefore -= leadingZerosRemoved;
      if (digitsBefore < 0) digitsBefore = 0;
      if (digitsBefore > intDigits.length) digitsBefore = intDigits.length;
      newCursor = digitsBefore == intDigits.length ? groupedInt.length : insertionPositions[digitsBefore];
    } else {
      if (!showDecimal) {
        newCursor = groupedInt.length;
      } else if (trailingDot && fracPart.isEmpty) {
        newCursor = groupedInt.length + 1;
      } else {
        final digitsInFracBefore = cursorSanitizedPos - cursorIntFracBoundary - 1;
        final clamped = digitsInFracBefore.clamp(0, fracPart.length);
        newCursor = groupedInt.length + 1 + clamped;
      }
    }

    // Shift cursor for leading minus sign
    if (isNegative) {
      newCursor += 1;
    }

    // Always skip thousands separators on backspace so user doesn't need extra press.
    if (didBackspace) {
      while (newCursor > 0 && finalText.codeUnitAt(newCursor - 1) == 0x20) {
        newCursor--;
      }
    }

    if (newCursor < 0) newCursor = 0;
    if (newCursor > finalText.length) newCursor = finalText.length;

    return TextEditingValue(
      text: finalText,
      composing: TextRange.empty,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}
