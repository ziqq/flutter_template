/*
 * Date: 02 February 2026
 */

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/api_client/log_sanitizer.dart';
import 'package:flutter_template_name/src/common/controller/app_controller.dart' show $currentSentryTransaction;
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template sentry_middleware}
/// Middleware for Sentry integration in API requests.
/// Captures HTTP requests and responses, creating a transaction
/// for each request to monitor performance and errors.
/// {@endtemplate}
@immutable
class SentryMiddleware {
  /// {@macro sentry_middleware}
  const SentryMiddleware();

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final sanitizedUri = sanitizeUriForLogging(request.url);
    final sanitizedQuery = sanitizeQueryParametersForLogging(request.url.queryParametersAll);
    final sanitizedHeaders = sanitizeHeadersForLogging(request.headers);
    // Build operation name
    final operation = context['operation']?.toString() ?? '[${request.method}] ${request.url.path}';

    // Start or continue a Sentry transaction/span
    final transaction =
        ($currentSentryTransaction?.startChild(
                'http.client',
                description: operation,
                startTimestamp: DateTime.now().toUtc(),
              ) ??
              Sentry.startTransaction(
                'http.client',
                operation,
                description: operation,
                bindToScope: true,
                startTimestamp: DateTime.now().toUtc(),
              ))
          ..setData('http.request.method', request.method)
          ..setData('url', sanitizedUri)
          ..setData('method', request.method)
          ..setData('path', request.url.path)
          ..setData('query', sanitizedQuery)
          ..setData('request_headers', sanitizedHeaders);

    // Store transaction in context for downstream middlewares
    context['sentry.transaction'] = transaction;

    try {
      // Perform the request
      final response = await innerHandler(request, context);

      // Record status code and finish transaction
      transaction.setData('http.response.status_code', response.statusCode.toString());
      if (!transaction.finished) {
        transaction.finish(status: const SpanStatus.ok()).ignore();
      }

      return response;
    } on Object catch (e, s) {
      // Capture exception in Sentry bound to this transaction
      await Sentry.captureException(
        e,
        stackTrace: s,
        withScope: (scope) => scope.span = transaction,
        hint: Hint.withMap({
          'method': request.method,
          'url': sanitizedUri,
          'path': request.url.path,
          'query': sanitizedQuery,
          'headers': sanitizedHeaders,
        }),
      );

      // Finish the transaction with appropriate span status
      if (!transaction.finished) {
        transaction
            .finish(
              status: switch (e) {
                ApiException(statusCode: 503) => const SpanStatus.unavailable(),
                ApiException(statusCode: 501) => const SpanStatus.unimplemented(),
                ApiException(statusCode: 500) => const SpanStatus.internalError(),
                ApiException(statusCode: 429) => const SpanStatus.resourceExhausted(),
                ApiException(statusCode: 409) => const SpanStatus.aborted(),
                ApiException(statusCode: 404) => const SpanStatus.notFound(),
                ApiException(statusCode: 403) => const SpanStatus.permissionDenied(),
                ApiException(statusCode: 401) => const SpanStatus.unauthenticated(),
                ApiException(statusCode: 400) => const SpanStatus.failedPrecondition(),
                ApiException(statusCode: < 400) => const SpanStatus.unknownError(),
                ApiException(:var statusCode) => SpanStatus.fromHttpStatusCode(statusCode),
                _ => null,
              },
              endTimestamp: DateTime.now().toUtc(),
            )
            .ignore();
      }

      rethrow;
    }
  };
}
