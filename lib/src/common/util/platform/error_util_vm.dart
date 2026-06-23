// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:io' show HttpException;

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Converts a map of hints (with arbitrary value types) into a `Hint` object,
/// formatting each value as a `String`. Returns `null` if the input is `null` or empty.
Hint? _hintFromMap(Map<String, Object?>? hints) {
  if (hints == null || hints.isEmpty) return null;
  return Hint.withMap({
    for (final entry in hints.entries)
      entry.key: switch (entry.value) {
        String value => value,
        int value => value,
        double value => value,
        bool value => value,
        List<Object?> value => '[${value.map((e) => e.toString()).join(', ')}]',
        Map<String, Object?> value => value.entries.map((e) => '${e.key}: ${e.value}').join(', '),
        _ => entry.value.toString(),
      },
  });
}

/// Sends an exception to Sentry with optional hints and a fatal flag.
// ignore: unused_element
Future<void> _$captureException(Object exception, StackTrace stackTrace, Map<String, Object?>? hints, bool fatal) =>
    Sentry.captureException(exception, stackTrace: stackTrace, hint: _hintFromMap(hints));

/// Sends a message to Sentry with optional stack trace, hints, and warning flag.
// ignore: unused_element
Future<void> _$captureMessage(String message, StackTrace? stackTrace, Map<String, Object?>? hints, bool warning) =>
    Sentry.captureMessage(
      message,
      level: warning ? SentryLevel.warning : SentryLevel.info,
      hint: _hintFromMap(hints),
      params: <String>[if (stackTrace != null) 'StackTrace: $stackTrace'],
    );

/*
 * Sentry.captureException(exception, stackTrace: stackTrace, hint: hint);
 * FirebaseCrashlytics.instance.recordError(
 *    exception,
 *    stackTrace ?? StackTrace.current,
 *    reason: hint,
 *    fatal: fatal,
 * );
 *
 */
/// Sends an exception to Sentry with optional hints and a fatal flag.
Future<void> $captureException(Object exception, StackTrace stackTrace, Map<String, Object?>? hints, bool fatal) =>
    Sentry.captureException(exception, stackTrace: stackTrace, hint: _hintFromMap(hints));

/*
 * Sentry.captureMessage(
 *   message,
 *   level: warning ? SentryLevel.warning : SentryLevel.info,
 *   hint: hint,
 *   params: <String>[
 *     ...?params,
 *     if (stackTrace != null) 'StackTrace: $stackTrace',
 *   ],
 * );
 * (warning || stackTrace != null)
 *   ? FirebaseCrashlytics.instance.recordError(message, stackTrace ?? StackTrace.current);
 *   : FirebaseCrashlytics.instance.log('$message${hint != null ? '\r\n$hint' : ''}');
 *
 */
/// Sends a message to Sentry with optional stack trace, hints, and warning flag.
Future<void> $captureMessage(String message, StackTrace? stackTrace, Map<String, Object?>? hints, bool warning) =>
    Sentry.captureMessage(
      message,
      hint: _hintFromMap(hints),
      level: warning ? SentryLevel.warning : SentryLevel.info,
      params: <String>[if (stackTrace != null) 'StackTrace: $stackTrace'],
    );

/// Converts an error to a user‐friendly string based on environment.
// ignore: unused_element
String $errorToString(Object error) {
  final isProduction = Config.environment.isProduction;
  return switch (error) {
    HttpException value => isProduction ? 'A network error occurred' : value.message,
    _ => isProduction ? 'An error occurred' : error.toString(),
  };
}
