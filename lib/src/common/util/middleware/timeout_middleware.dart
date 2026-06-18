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
/// code `timeout` when the request does not complete in time. You can override
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

    try {
      return await innerHandler(request, context).timeout(timeout);
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
