// Автор - <a.a.ustinoff@gmail.com> Anton Ustinoff, 14 декабря 2023

import 'package:meta/meta.dart';

/// {@template api_exception}
/// Base class for API exceptions.
/// {@endtemplate}
@immutable
base class ApiException implements Exception {
  /// {@macro api_exception}
  const ApiException({
    required this.statusCode,
    required this.message,
    required this.code,
    this.error,
    this.stackTrace,
    this.data,
  });

  /// HTTP status code.
  /// If the request was not sent, this will be 0.
  @nonVirtual
  final int statusCode;

  /// Error code.
  @nonVirtual
  final String code;

  /// Error message.
  @nonVirtual
  final String message;

  /// The error object associated with the exception.
  @nonVirtual
  final Object? error;

  /// The stack trace associated with the exception.
  @nonVirtual
  final StackTrace? stackTrace;

  /// Additional data.
  final Object? data;

  @override
  String toString() {
    final buffer = StringBuffer('ApiException{')
      ..write('statusCode: $statusCode, ')
      ..write('code: $code')
      ..write('message: $message');
    if (error != null) buffer.write(', error: $error');
    if (stackTrace != null) buffer.write(', stackTrace: $stackTrace');
    buffer.write('}');
    return buffer.toString();
  }
}

/// Exception thrown when the device is offline.
/// {@macro api_exception}
final class ApiException$Offline extends ApiException {
  /// {@macro api_exception}
  const ApiException$Offline({
    super.message = 'Request blocked: offline',
    super.code = 'network_error',
    super.statusCode = 0,
    super.error,
    super.stackTrace,
    super.data,
  });

  static String get type => r'ApiException$Offline';

  @override
  String toString() {
    final buffer = StringBuffer(r'ApiException$Offline(')
      ..write('message: $message, ')
      ..write('statusCode: $statusCode')
      ..write(', code: $code');
    if (error != null) buffer.write(', error: $error');
    if (stackTrace != null) buffer.write(', stackTrace: $stackTrace');
    buffer.write(')');
    return buffer.toString();
  }
}

/// Exception thrown when the connection is invalid.
///
/// [statusCode] is 522.
/// {@macro api_exception}
final class ApiException$Network extends ApiException {
  /// {@macro api_exception}
  const ApiException$Network({
    required super.statusCode,
    required super.message,
    required super.code,
    super.error,
    super.stackTrace,
    super.data,
  });

  static String get type => r'ApiException$Network';

  @override
  String toString() {
    final buffer = StringBuffer(r'ApiException$Network(')
      ..write('message: $message, ')
      ..write('statusCode: $statusCode')
      ..write(', code: $code');
    if (error != null) buffer.write(', error: $error');
    if (stackTrace != null) buffer.write(', stackTrace: $stackTrace');
    buffer.write(')');
    return buffer.toString();
  }
}

/// Exception thrown when the response is not found.
///
/// [statusCode] is 404.
/// {@macro api_exception}
final class ApiException$Client extends ApiException {
  /// {@macro api_exception}
  const ApiException$Client({
    required super.statusCode,
    required super.message,
    required super.code,
    super.error,
    super.stackTrace,
    super.data,
  });

  static String get type => r'ApiException$Client';

  @override
  String toString() {
    final buffer = StringBuffer(r'ApiException$Client(')
      ..write('message: $message, ')
      ..write('statusCode: $statusCode')
      ..write(', code: $code');
    if (error != null) buffer.write(', error: $error');
    if (stackTrace != null) buffer.write(', stackTrace: $stackTrace');
    buffer.write(')');
    return buffer.toString();
  }
}

/// Exception thrown when the token is invalid.
///
/// [statusCode] is 401.
/// {@macro api_exception}
final class ApiException$Authorization extends ApiException {
  /// {@macro api_exception}
  const ApiException$Authorization({
    required super.statusCode,
    required super.message,
    required super.code,
    super.error,
    super.stackTrace,
    super.data,
  });

  static String get type => r'ApiException$Authorization';

  @override
  String toString() {
    final buffer = StringBuffer(r'ApiException$Authorization(')
      ..write('message: $message, ')
      ..write('statusCode: $statusCode')
      ..write(', code: $code')
      ..write(', error: $error');
    if (stackTrace != null) buffer.write(', stackTrace: $stackTrace');
    buffer.write(')');
    return buffer.toString();
  }
}
