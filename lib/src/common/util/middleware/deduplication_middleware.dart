/*
 * Date: 02 February 2026
 */

import 'dart:async';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:http/http.dart' as http_package;
import 'package:meta/meta.dart';

/// {@template deduplication_middleware}
/// Middleware that deduplicates concurrent identical API requests.
///
/// If multiple requests with the same key (method + url + body) are started
/// concurrently, only the first one will be executed and others will await
/// the same result. This reduces duplicated traffic and race conditions.
///
/// Behavior can be overridden via the request [context]:
/// - `no-dedupe` (bool) — when true, disables deduplication for this request.
/// {@endtemplate}
@immutable
class DeduplicationMiddleware {
  /// Create a new [DeduplicationMiddleware].
  ///
  /// [keyBuilder] can be provided to customize how requests are considered
  /// identical. By default the key is computed from method, url and body hash.
  DeduplicationMiddleware({this.keyBuilder}) : _inFlight = <String, Future<ApiClient$HTTP$Response>>{};

  /// Optional custom key builder for requests.
  final String Function(ApiClient$HTTP$Request request)? keyBuilder;

  /// In-flight requests map keyed by computed key.
  final Map<String, Future<ApiClient$HTTP$Response>> _inFlight;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    // Allow opt-out via context
    if (context['no-dedupe'] == true) return innerHandler(request, context);

    final key = keyBuilder?.call(request) ?? _defaultKey(request);

    // If there's an in-flight request for the same key — reuse it.
    final existing = _inFlight[key];
    if (existing != null) return await existing;

    // Run the actual request and store the future so other callers join it.
    final future = innerHandler(request.clone(), context);
    _inFlight[key] = future;

    try {
      final resp = await future;
      return resp;
    } on Object catch (e, _) {
      rethrow;
    } finally {
      // Clean up after completion (success or error).
      // Protect against race: only remove if the stored future is the one we set.
      if (_inFlight[key] == future) _inFlight.remove(key)?.ignore();
    }
  };

  String _defaultKey(ApiClient$HTTP$Request request) {
    // Use method and URL as base.
    final method = (request as http_package.BaseRequest).method;
    final url = (request as http_package.BaseRequest).url.toString();

    // Try to include a hash of the body for non-streaming requests.
    String? bodyHash;
    final baseReq = request as http_package.BaseRequest;
    if (baseReq is http_package.Request) {
      final bytes = baseReq.bodyBytes;
      if (bytes.isNotEmpty) {
        bodyHash = crypto.sha1.convert(bytes).toString();
      }
    }

    return '$method|$url|${bodyHash ?? ''}';
  }
}
