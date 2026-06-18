import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template sentry_api_client_exception_cause_extractor}
/// Extracts nested causes from [ApiException.error].
/// {@endtemplate}
class SentryApiClientExceptionCauseExtractor extends ExceptionCauseExtractor<ApiException> {
  @override
  ExceptionCause? cause(ApiException error) {
    final innerCause = error.error;
    if (innerCause == null || identical(innerCause, error)) return null;

    final innerStackTrace = switch (innerCause) {
      Error _ => innerCause.stackTrace,
      _ => error.stackTrace,
    };

    return ExceptionCause(innerCause, innerStackTrace, source: 'error');
  }
}

/// {@template sentry_api_client_exception_stack_trace_extractor}
/// Extracts stack traces stored directly on [ApiException].
/// {@endtemplate}
class SentryApiClientExceptionStackTraceExtractor extends ExceptionStackTraceExtractor<ApiException> {
  @override
  StackTrace? stackTrace(ApiException error) => error.stackTrace;
}
