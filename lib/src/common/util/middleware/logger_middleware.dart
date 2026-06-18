/*
 * Date: 02 February 2026
 */

import 'dart:developer' as developer;

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';

/// {@template logger_middleware}
/// Middleware that logs HTTP requests and responses.
/// {@endtemplate}
@immutable
class LoggerMiddleware {
  const LoggerMiddleware({this.logRequest = false, this.logResponse = true, this.logError = true});

  final bool logRequest;
  final bool logResponse;
  final bool logError;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (logRequest) {
        developer.log('[${request.method}] ${request.url.path}', name: 'http', time: DateTime.now(), level: 300);
      }
      final response = await innerHandler(request, context);
      if (logResponse) {
        l.v4(
          'HTTP '
          '[${request.method}] '
          '${request.url.path} '
          '-> ${response.statusCode} ' // '-> success '
          '| ${stopwatch.elapsedMilliseconds}ms',
        );
      }
      return response;
    } on Object catch (e, s) {
      if (logError) {
        l.w(
          'HTTP '
          '[${request.method}] '
          '${request.url.path} '
          '-> ${switch (e) {
            ApiException(:var code) => code,
            _ => 'error',
          }}'
          '| ${stopwatch.elapsedMilliseconds}ms',
          s,
        );
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  };
}
