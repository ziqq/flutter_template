/*
 * Date: 02 February 2026
 */

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:http/http.dart' as http_package;
import 'package:l/l.dart';

/// Unique name for log prefix.
const String _logPrefix = 'AuthenticationMiddleware |';

/// Default backoff delays for token refresh retries.
const _defaultRefreshRetryDelays = <Duration>[Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)];

/// {@template authentication_middleware}
/// Middleware that injects authorization headers and refreshes access tokens
/// for HTTP-based API requests.
///
/// The middleware adds an `Authorization` header when an access token is
/// available. When the downstream handler throws [ApiException$Authorization]
/// with status code `401`, it performs a refresh request against
/// `baseURL`, updates the stored token pair, and retries the
/// original request once with the new access token.
///
/// Concurrent `401` failures share a single refresh operation through the
/// internal [_refreshing] future. If refresh ultimately fails, the middleware
/// invokes [onTokenExpired] once and rethrows the original authorization error.
///
/// Refresh retries follow the same model as [RetryMiddleware]:
/// [retries] limits the number of retry attempts, [retryDelays] defines the
/// backoff schedule, and [retryEvaluator] can override the default retry
/// decision per error.
/// {@endtemplate}
final class AuthenticationMiddleware {
  /// {@macro authentication_middleware}
  ///
  /// The refresh endpoint is resolved as `auth/v2/refresh-token` relative to
  /// [baseUrl].
  AuthenticationMiddleware({
    required String baseURL,
    required Future<String?> Function() getToken,
    required Future<void> Function() onTokenExpired,
    required Future<void> Function(String accessToken) onUpdateToken,
    this.retries = 3,
    this.retryEvaluator,
    this.retryDelays = _defaultRefreshRetryDelays,
    http_package.Client? httpClient,
  }) : _baseUrl = baseURL,
       assert(retries >= 0, 'Retries must be non‐negative'),
       assert(
         retryDelays.isNotEmpty && retryDelays.every((d) => d >= Duration.zero),
         'Retry delays must not be empty and must be non‐negative',
       ),
       assert(retryDelays.length >= retries, 'Retry delays must be at least as many as retries'),
       _getToken = getToken,
       _onUpdateToken = onUpdateToken,
       _onTokenExpired = onTokenExpired,
       _internalClient = httpClient ?? http_package.Client();

  /// Base API URL used to resolve the refresh token endpoint.
  final String _baseUrl;

  /// Internal HTTP client used only for refresh token requests.
  final http_package.Client _internalClient;

  /// Returns the current access and refresh token pair.
  final Future<String?> Function() _getToken;

  /// Called once when refresh fails and the session must be invalidated.
  final Future<void> Function() _onTokenExpired;

  /// Persists a newly refreshed token pair.
  final Future<void> Function(String accessToken) _onUpdateToken;

  final int retries;

  /// Backoff delays used between refresh retry attempts.
  final List<Duration> retryDelays;

  /// Optional predicate that decides whether refresh should be retried.
  ///
  /// When omitted, [_retryIf] is used.
  final bool Function(Object error, int attempt)? retryEvaluator;

  /// Shared in-flight refresh operation for concurrent `401` failures.
  Future<String?>? _refreshing;

  /// Prevents duplicate logout calls while a failed refresh is being handled.
  bool _loggedOut = false;

  /// Wraps [innerHandler] with authorization header injection and token refresh.
  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    await _authorize(request);

    try {
      return await innerHandler(request, context);
    } on ApiException$Authorization catch (error, stackTrace) {
      if (error.statusCode != 401 || _loggedOut) Error.throwWithStackTrace(error, stackTrace);

      final refreshFuture = _refreshing ??= _refreshTokenPair();
      refreshFuture.whenComplete(() {
        if (identical(_refreshing, refreshFuture)) _refreshing = null;
      }).ignore();

      try {
        final token = await refreshFuture;
        if (token == null) {
          await _logout();
          Error.throwWithStackTrace(error, stackTrace);
        }

        return await _retryRequest(innerHandler: innerHandler, request: request, context: context, token: token);
      } on ApiException$Authorization catch (retryError, retryStackTrace) {
        if (retryError.statusCode == 401) {
          await _logout();
          Error.throwWithStackTrace(error, stackTrace);
        }
        Error.throwWithStackTrace(retryError, retryStackTrace);
      } finally {
        _loggedOut = false;
      }
    }
  };

  /// Adds the current access token to the outgoing request when it exists.
  Future<void> _authorize(ApiClient$HTTP$Request request) async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Runs the refresh flow with retry policy compatible with [RetryMiddleware].
  Future<String?> _refreshTokenPair() async {
    final maxRetries = math.min(retries, retryDelays.length);
    if (maxRetries < 1 || retryDelays.isEmpty) return _refreshTokenPairOnce();

    var attempt = 0;
    try {
      l.i('$_logPrefix Refreshing token...');
      while (true) {
        try {
          return await _refreshTokenPairOnce();
        } on Object catch (error, stackTrace) {
          if (attempt >= maxRetries || !(retryEvaluator?.call(error, attempt) ?? _retryIf(error))) {
            l.e('$_logPrefix Refresh token failed | $error', stackTrace);
            return null;
          }

          final delay = retryDelays[math.min(attempt, retryDelays.length - 1)];
          await _onRetry(error, attempt, delay);
          await Future<void>.delayed(delay);
          attempt++;
        }
      }
    } on Object catch (error, stackTrace) {
      l.e('$_logPrefix Refresh token failed | $error', stackTrace);
      return null;
    }
  }

  /// Executes a single refresh attempt and persists the new token pair.
  Future<String?> _refreshTokenPairOnce() async {
    final token = await _sendRefreshRequest();
    if (token == null) {
      l.i('$_logPrefix Refresh token failed, token is null');
      return null;
    }

    l.i('$_logPrefix Updating token...');
    await _onUpdateToken(token);
    return token;
  }

  /// Sends the refresh token request and extracts a valid [String] from the response.
  Future<String?> _sendRefreshRequest({int? ttl}) async {
    try {
      l.i('$_logPrefix Getting refresh token...');
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        l.w('$_logPrefix Refresh token is null or empty');
        return null;
      }

      l.i('$_logPrefix Sending refresh request...');
      final request = http_package.Request('POST', _resolveRefreshUrl(ttl))
        ..headers.addAll(<String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..body = token;

      final response = await _internalClient.send(request);
      final bytes = await response.stream.toBytes();
      final data = _decodeRefreshResponse(bytes, response.statusCode);
      final errors = data['errors'];

      int? code;
      String? message;
      if (errors case Map<Object?, Object?> error) {
        if (error['code'] case int value) code = value;
        if (error['message'] case String value) message = value;
      }

      final accessToken = data['access_token']?.toString();
      // final newRefreshToken = data['refresh_token']?.toString();
      final success =
          errors == null &&
          accessToken != null &&
          accessToken
              .isNotEmpty /* &&
          newRefreshToken != null &&
          newRefreshToken.isNotEmpty */;

      if (success) {
        l.i('$_logPrefix Token refreshed');
        return accessToken;
      }

      l.v(
        '$_logPrefix Refresh failed | '
        'code: $code, '
        'errors: $errors, '
        'message: $message, '
        'statusCode: ${response.statusCode}',
      );
      return null;
    } on ApiException {
      rethrow;
    } on Object catch (error, stackTrace) {
      throw ApiException$Network(
        message: 'Failed to refresh token due to a network error.',
        code: 'refresh_token_network_error',
        statusCode: 0,
        error: error,
        stackTrace: stackTrace,
        data: null,
      );
    }
  }

  /// Resolves the refresh endpoint relative to the configured base API URL.
  Uri _resolveRefreshUrl(int? ttl) {
    final baseUri = Uri.parse(_baseUrl);
    final normalizedPath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final refreshUri = baseUri.replace(path: '$normalizedPath/auth/v2/refresh-token');
    if (ttl == null) return refreshUri;
    return refreshUri.replace(queryParameters: <String, String>{...refreshUri.queryParameters, 'ttl': '$ttl'});
  }

  /// Decodes the refresh response body into a JSON map or throws a client error.
  Map<String, Object?> _decodeRefreshResponse(List<int> bytes, int statusCode) {
    if (bytes.isEmpty) return <String, Object?>{};
    try {
      final json = jsonDecode(utf8.decode(bytes));
      if (json is Map<String, Object?>) return json;
      if (json is Map<Object?, Object?>) return Map<String, Object?>.from(json);
      throw const FormatException('Refresh response is not a JSON');
    } on Object catch (error, stackTrace) {
      throw ApiException$Client(
        code: 'decoding_error',
        message: 'Failed to decode refresh response.',
        data: bytes,
        error: error,
        statusCode: statusCode,
        stackTrace: stackTrace,
      );
    }
  }

  /// Replays the original request once with the refreshed access token.
  Future<ApiClient$HTTP$Response> _retryRequest({
    required ApiClientHandler innerHandler,
    required ApiClient$HTTP$Request request,
    required Map<String, Object?> context,
    required String token,
  }) async {
    final retriedRequest = request.clone();
    retriedRequest.headers['Authorization'] = 'Bearer $token';

    l.i('$_logPrefix Retrying request | url: ${retriedRequest.url}...');
    return innerHandler(retriedRequest, Map<String, Object?>.from(context));
  }

  /// Default retry predicate for refresh failures when [retryEvaluator] is not provided.
  bool _retryIf(Object error) => switch (error) {
    ApiException$Network() => true,
    ApiException(statusCode: 401) => false,
    _ => false,
  };

  /// Logs the scheduled refresh retry attempt.
  Future<void> _onRetry(Object error, int attempt, Duration delay) async => l.i(
    '$_logPrefix Retrying request | '
    'attempt: ${attempt + 1}, '
    'delay: ${delay.inMilliseconds}ms '
    '$error',
  );

  /// Invalidates the session once after refresh is determined to have failed.
  Future<void> _logout() async {
    if (_loggedOut) return;
    _loggedOut = true;
    l.i('$_logPrefix Logging out...');
    await _onTokenExpired();
  }
}
