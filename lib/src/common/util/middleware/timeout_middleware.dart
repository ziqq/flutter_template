/*
 * Date: 02 February 2026
 */

import 'dart:async';

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart' show ApiException$Network;
import 'package:meta/meta.dart';

/// {@template timeout_middleware}
/// Middleware that enforces a maximum duration for API requests.
///
/// By default the middleware will throw an [ApiException$Network] with
/// code `timeout_error` and abort the request when headers and body do not complete
/// in time. The shared HTTP client remains open. You can override
/// the timeout on a per-request basis by setting `context['timeout']` to a
/// [Duration] or an integer number of milliseconds. To opt-out of the timeout
/// for a specific request set `context['no-timeout'] = true`.
/// {@endtemplate}
@immutable
class TimeoutMiddleware {
  /// Create a [TimeoutMiddleware].
  const TimeoutMiddleware({this.duration = const Duration(seconds: 30)});

  /// Default duration timeout for requests.
  final Duration duration;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    // Allow opt-out
    if (context['no-timeout'] == true || context['sse'] == true) return innerHandler(request, context);

    // Resolve timeout from context if provided.
    final timeout = switch (context['timeout']) {
      double milliseconds => Duration(milliseconds: milliseconds.round()),
      int milliseconds => Duration(milliseconds: milliseconds),
      Duration duration => duration,
      _ => duration,
    };

    final abort = Completer<void>();
    final externalAbort = request.abortTrigger;
    final abortableRequest = request.abortable(
      externalAbort == null ? abort.future : Future.any<void>([abort.future, externalAbort]),
    );

    try {
      return await innerHandler(abortableRequest, context).timeout(
        timeout,
        onTimeout: () {
          abort.complete();
          throw TimeoutException('Request timed out.', timeout);
        },
      );
    } on TimeoutException catch (e, s) {
      throw ApiException$Network(
        message: 'Request timed out.',
        code: 'timeout_error',
        statusCode: 0,
        stackTrace: s,
        error: e,
        data: null,
      );
    }
  };
}
