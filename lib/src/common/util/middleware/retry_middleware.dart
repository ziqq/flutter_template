/*
 * Date: 02 February 2026
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:meta/meta.dart';

/// {@template retry_middleware}
/// Middleware that retries failed HTTP requests using a configurable backoff.
///
/// The middleware repeats a request when [defaultRetryEvaluator] allows it, waiting
/// according to [retryDelays] between attempts. The retry count can be
/// overridden per request through `context['retries']`.
///
/// Retries are skipped when:
/// - `context['no-retry'] == true`
/// - `context['sse'] == true`
/// - the resolved retry count is less than `1`
/// {@endtemplate}
@immutable
class RetryMiddleware {
  /// {@macro retry_middleware}
  ///
  /// [retries] defines the maximum number of retry attempts, while
  /// [retryDelays] provides the backoff schedule used between attempts.
  RetryMiddleware({this.retries = 3, this.defaultRetryEvaluator, this.retryDelays = kDefaultRefreshRetryDelays})
    : assert(retries >= 0, 'Retries must be non‐negative'),
      assert(
        retryDelays.isNotEmpty && retryDelays.every((d) => d >= Duration.zero),
        'Retry delays must not be empty and must be non‐negative',
      ),
      assert(retryDelays.length >= retries, 'Retry delays must be at least as many as retries');

  /// Number of retry attempts.
  final int retries;

  /// Callback to decide per‐error whether to retry.
  final bool Function(Object error, int attempt)? defaultRetryEvaluator;

  /// Backoff delays between retries.
  final List<Duration> retryDelays;

  /// Wraps the inner handler with retry logic.
  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    // Respect a per-request retry override, but never exceed configured delays.
    final maxRetries = math.min(switch (context['retries']) {
      int r when r >= 0 => r,
      _ => retries,
    }, retryDelays.length);

    // Skip retries for explicitly opted-out requests and streaming scenarios.
    final shouldNotRetry =
        context['no-retry'] == true ||
        context['stream'] == true ||
        context['sse'] == true ||
        maxRetries < 1 ||
        retryDelays.isEmpty;
    if (shouldNotRetry) {
      return innerHandler(request, context);
    }

    var attempt = 0;
    var clonedRequest = request;

    // Retry the same logical request until it succeeds or the policy stops it.
    while (true) {
      try {
        return await innerHandler(clonedRequest, context);
      } catch (e) {
        // Stop when the retry budget is exhausted or the policy rejects retry.
        if (attempt >= maxRetries ||
            !(defaultRetryEvaluator?.call(e, attempt) ?? defaultRetryEvaluator$HTTP(e, attempt))) {
          rethrow;
        }

        // Wait for the next backoff window, then replay the request.
        final delay = retryDelays[math.min(attempt, retryDelays.length - 1)];
        await Future<void>.delayed(delay);
        attempt++;
        clonedRequest = clonedRequest.clone();
      }
    }
  };
}

/// Canonical client-side error codes treated as terminal failures.
///
/// These codes represent malformed requests, decoding problems, cancellation,
/// or other situations where repeating the same request is expected to fail in
/// the same way.
const Set<String> kDefaultNonRetryableCodes = <String>{
  'canceled',
  'aborted',
  'cancel',
  'cancelled',
  'abort',
  'bad_request_error',
  'redirection_error',
  'invalid_content_type_error',
  'decoding_error',
  'response_too_large',
  'body_stream_error',
  'unexpected_error',
  'unknown_error',
};

/// HTTP status codes considered transient enough for the default retry policy.
///
/// Package defaults stay conservative: only standard timeout, rate-limit, and
/// server-side infrastructure failures are retried automatically. Business
/// validation and conflict-style `4xx` responses must be opted into explicitly
/// by a custom application retry evaluator.
const Set<int> kDefaultRetryableStatusCodes = <int>{408, 429, 502, 503, 504};

/// Default backoff schedule used for token refresh retries.
///
/// The same delays are reused by package-owned retry helpers so transport paths
/// do not silently drift from each other.
const kDefaultRefreshRetryDelays = <Duration>[Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)];

/// Default retry predicate for Dio requests.
///
/// Returns `true` only for transient transport failures and retryable response
/// statuses. Authorization failures and explicitly offline errors are always
/// treated as terminal.
/* bool defaultRetryEvaluator$Dio(DioException error, int attempt) {
  if (error.error is ApiException$Offline || error.response?.statusCode == 401) return false;

  return switch (error.type) {
    DioExceptionType.badResponse => kDefaultRetryableStatusCodes.contains(error.response?.statusCode),
    DioExceptionType.connectionTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.unknown => true,
    _ => false,
  };
} */

/// Default retry predicate for HTTP middleware requests.
///
/// This policy is used for `ApiClient$HTTP` middleware chains. It mirrors the
/// package Dio policy where possible, while also understanding package-native
/// [ApiException] variants and [TimeoutException].
bool defaultRetryEvaluator$HTTP(Object error, int attempt) => switch (error) {
  ApiException$Offline() => false,
  ApiException$Authorization() => false,
  TimeoutException() => true,
  ApiException$Client() => false,
  ApiException$Network(:final statusCode) => kDefaultRetryableStatusCodes.contains(statusCode),
  _ => true,
};

/// Default retry predicate for token refresh operations.
///
/// Refresh retries are intentionally stricter than generic request retries:
/// network failures and transient transport issues are retried, but `401`
/// means the session is invalid and should not be retried.
bool defaultRetryEvaluator$Refresh(Object error, int attempt) => switch (error) {
  ApiException$Network() => true,
  ApiException(statusCode: 401) => false,
  /* DioException error
      when error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.unknown =>
    true, */
  _ => false,
};
