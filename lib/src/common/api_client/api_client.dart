import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:http/http.dart' as http_package;

/// A function that takes a [http_package.BaseRequest] and returns a [http_package.StreamedResponse].
/// The [context] parameter is a map that can be used to store data that should be available to all middleware.
typedef ApiClientHandler =
    Future<ApiClient$HTTP$Response> Function(ApiClient$HTTP$Request request, Map<String, Object?> context);

/// A function that takes a [ApiClientHandler] and returns a [ApiClientHandler].
typedef ApiClientMiddleware = ApiClientHandler Function(ApiClientHandler innerHandler);

/// A wrapper for [ApiClientMiddleware] that allows for optional handlers.
extension type ApiClientMiddlewareWrapper._(ApiClientMiddleware _fn) {
  /// Creates a new [ApiClientMiddleware] from the given callbacks.
  factory ApiClientMiddlewareWrapper({
    Future<void> Function(ApiClient$HTTP$Request request, Map<String, Object?> context)? onRequest,
    Future<void> Function(ApiClient$HTTP$Response response, Map<String, Object?> context)? onResponse,
    Future<void> Function(Object error, StackTrace stackTrace, Map<String, Object?> context)? onError,
  }) => ApiClientMiddlewareWrapper._(
    (innerHandler) => (request, context) async {
      await onRequest?.call(request, context);
      try {
        final response = await innerHandler(request, context);
        await onResponse?.call(response, context);
        return response;
      } on Object catch (error, stackTrace) {
        await onError?.call(error, stackTrace, context);
        rethrow;
      }
    },
  );

  /// Merges the given [middlewares] into a single [ApiClientMiddleware].
  factory ApiClientMiddlewareWrapper.merge(List<ApiClientMiddleware> middlewares) => ApiClientMiddlewareWrapper._(
    middlewares.length == 1
        ? middlewares.single
        : (handler) => middlewares.reversed.fold(handler, (handler, middleware) => middleware(handler)),
  );

  /// Call the wrapped [ApiClientMiddleware] with the given [innerHandler].
  ApiClientHandler call(ApiClientHandler innerHandler) => _fn(innerHandler);
}

/// An HTTP request with a JSON-encoded body.
extension type ApiClient$HTTP$Request(http_package.BaseRequest _request) implements http_package.BaseRequest {
  ApiClient$HTTP$Request clone() => ApiClient$HTTP$Request(_request);
}

/// An HTTP response with a JSON-encoded body.
final class ApiClient$HTTP$Response {
  /// Create a new HTTP response with a JSON-encoded body.
  ApiClient$HTTP$Response.json(
    this.body, {
    required this.statusCode,
    required this.headers,
    required this.contentLength,
    required this.persistentConnection,
    required this.request,
  });

  final int statusCode;

  final Map<String, String> headers;

  final int contentLength;

  final Map<String, Object?> body;

  final bool persistentConnection;

  final ApiClient$HTTP$Request request;
}

/// {@template api_client}
/// An HTTP client that sends requests to a REST API.
/// {@endtemplate}
class ApiClient$HTTP /* with http_package.BaseClient implements http_package.Client */ {
  ApiClient$HTTP({required String baseURL, http_package.Client? client, Iterable<ApiClientMiddleware>? middlewares})
    : _baseUrl = Uri.parse(baseURL.endsWith('/') ? baseURL.substring(0, baseURL.length - 1) : baseURL),
      assert(!baseURL.endsWith('//'), 'Invalid base URL.') {
    // Create the HTTP client.
    final internalClient = client ?? http_package.Client();

    // Create the final middleware.
    final mw = ApiClientMiddlewareWrapper.merge([
      /* default middlewares before custom middlewares */
      ...?middlewares,
      /* default middlewares after custom middlewares */
    ]);

    // Create the handler.
    _handler = _createHandler(internalClient, mw.call);
  }

  final Uri _baseUrl;

  late final ApiClientHandler _handler;

  /// Merges the given [path] with the base URL.
  static Uri _mergePath(Uri base, String path) {
    if (path.startsWith('http')) return Uri.parse(path);
    var method = path;
    while (method.startsWith('/')) method = method.substring(1);
    return base.replace(path: '${base.path}/$method');
  }

  /// Sends a non-streaming [http_package.Request] and returns a non-streaming [http_package.Response].
  static Future<ApiClient$HTTP$Response> _sendUnstreamed({
    required ApiClientHandler handler,
    required String method,
    required Uri url,
    required Map<String, String>? headers,
    required Map<String, Object?>? body,
    required Map<String, Object?> context,
  }) {
    final request = http_package.Request(method, url)..maxRedirects = 5;
    request.headers['Accept'] = 'application/json';
    if (headers != null) request.headers.addAll(headers);
    if (body != null) {
      final bytes = const JsonEncoder().fuse(const Utf8Encoder()).convert(body);
      final contentLength = bytes.length;
      request.headers
        ..['Content-Type'] = 'application/json; charset=UTF-8'
        ..['Content-Length'] = contentLength.toString();
      request
        ..contentLength = contentLength
        ..bodyBytes = bytes;
    }
    return handler(ApiClient$HTTP$Request(request), context);
  }

  /// Sends a GET request to the given [path].
  Future<ApiClient$HTTP$Response> get(String path, {Map<String, String>? headers}) => _sendUnstreamed(
    handler: _handler,
    method: 'GET',
    url: _mergePath(_baseUrl, path),
    headers: headers,
    body: null,
    context: <String, Object?>{},
  );

  /// Sends a POST request to the given [path].
  Future<ApiClient$HTTP$Response> post(String path, {Map<String, String>? headers, Map<String, Object?>? body}) =>
      _sendUnstreamed(
        handler: _handler,
        method: 'POST',
        url: _mergePath(_baseUrl, path),
        headers: headers,
        body: body,
        context: <String, Object?>{},
      );
}

/// Creates a new [ApiClientHandler] from the given [internalClient] and [middleware].
ApiClientHandler _createHandler(http_package.Client internalClient, ApiClientMiddleware middleware) {
  // Check if the completer is completed and throw an error if it is.
  void throwError(Completer<ApiClient$HTTP$Response> completer, Object error, StackTrace stackTrace) {
    if (completer.isCompleted)
      return;
    else if (error is ApiException)
      completer.completeError(error, stackTrace);
    else
      completer.completeError(
        ApiException$Client(
          code: 'unknown_error',
          message: 'Unknown error.',
          statusCode: 0,
          error: error,
          stackTrace: stackTrace,
          data: null,
        ),
        stackTrace,
      );
  }

  // JSON decoder.
  final jsonDecoder = const Utf8Decoder().fuse(const JsonDecoder()).cast<Object?, Map<String, Object?>>();

  // HTTP handler.
  Future<ApiClient$HTTP$Response> httpHandler(ApiClient$HTTP$Request request, Map<String, Object?> context) {
    final completer = Completer<ApiClient$HTTP$Response>();
    // Handle top level errors.
    runZonedGuarded<void>(
      () async {
        assert(request.url.scheme.startsWith('http'), 'Invalid URL: ${request.url}');

        // Send a base request.
        final http_package.StreamedResponse streamedResponse;
        try {
          streamedResponse = await internalClient.send(request._request);
        } on Object catch (error, stackTrace) {
          throwError(
            completer,
            ApiException$Network(
              code: 'network_error',
              message: 'Failed to send request due to a network error.',
              statusCode: 0,
              error: error,
              stackTrace: stackTrace,
              data: null,
            ),
            stackTrace,
          );
          return;
        }

        // Check response.
        int statusCode;
        try {
          statusCode = streamedResponse.statusCode;
          switch (statusCode) {
            case > 499:
              throw ApiException$Network(
                code: 'internal_server_error',
                message: 'Internal server error.',
                statusCode: statusCode,
                error: null,
                data: null,
                stackTrace: StackTrace.current,
              );
            case 401 || 403:
              throw ApiException$Authorization(
                code: 'unauthorized_error',
                message: 'User is not authorized.',
                statusCode: statusCode,
                error: null,
                data: null,
                stackTrace: StackTrace.current,
              );
            case > 399:
              throw ApiException$Client(
                code: 'bad_request_error',
                message: 'Bad request.',
                statusCode: statusCode,
                error: null,
                data: null,
                stackTrace: StackTrace.current,
              );
            case > 299:
              throw ApiException$Client(
                code: 'redirection_error',
                message: 'Request was redirected.',
                statusCode: statusCode,
                error: null,
                data: null,
                stackTrace: StackTrace.current,
              );
            default:
              break;
          }
        } on Object catch (error, stackTrace) {
          throwError(completer, error, stackTrace);
          return;
        }

        // Read the response stream.
        int contentLength;
        Uint8List bytes;
        try {
          contentLength = streamedResponse.contentLength ?? 0;
          if (contentLength > 0) {
            final contentType = streamedResponse.headers['content-type']?.toLowerCase() ?? '';
            if (!contentType.contains('application/json')) {
              throwError(
                completer,
                ApiException$Client(
                  code: 'invalid_content_type_error',
                  message: 'Response content type is not application/json.',
                  statusCode: statusCode,
                  error: null,
                  data: null,
                  stackTrace: StackTrace.current,
                ),
                StackTrace.current,
              );
              return;
            }
            bytes = await streamedResponse.stream.toBytes();
          } else {
            bytes = Uint8List(0);
          }
        } on Object catch (error, stackTrace) {
          throwError(
            completer,
            ApiException$Network(
              code: 'body_stream_error',
              message: 'Failed to read response stream.',
              statusCode: streamedResponse.statusCode,
              stackTrace: stackTrace,
              error: error,
              data: null,
            ),
            stackTrace,
          );
          return;
        }

        // Decode the response.
        ApiClient$HTTP$Response response;
        try {
          final body = bytes.isEmpty ? <String, Object?>{} : jsonDecoder.convert(bytes);
          response = ApiClient$HTTP$Response.json(
            body,
            statusCode: streamedResponse.statusCode,
            headers: streamedResponse.headers,
            contentLength: contentLength,
            persistentConnection: streamedResponse.persistentConnection,
            request: request,
          );
        } on Object catch (error, stackTrace) {
          throwError(
            completer,
            ApiException$Client(
              code: 'decoding_error',
              message: 'Failed to decode response.',
              statusCode: streamedResponse.statusCode,
              stackTrace: stackTrace,
              error: error,
              data: bytes,
            ),
            stackTrace,
          );
          return;
        }

        // Complete the completer.
        if (!completer.isCompleted) completer.complete(response);
      },
      (error, stackTrace) {
        throwError(completer, error, stackTrace);
      },
    );
    return completer.future;
  }

  return middleware(httpHandler);
}
