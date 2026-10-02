import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/api_client/multipart_body.dart' show normalizeMultipartBody;
import 'package:http/http.dart' as http_package;
import 'package:meta/meta.dart' show internal;

/// A function that takes a [http_package.BaseRequest] and returns a [http_package.StreamedResponse].
/// The [context] parameter is a map that can be used to store data that should be available to all middleware.
typedef ApiClientHandler = Future<ApiClient$HTTP$Response> Function(
  ApiClient$HTTP$Request request,
  Map<String, Object?> context,
);

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
  /// Wraps a request whose body can be rebuilt for authorization replay.
  @internal
  factory ApiClient$HTTP$Request.replayable(
    http_package.BaseRequest request,
    http_package.BaseRequest Function() replayFactory,
  ) {
    _replayFactories[request] = replayFactory;
    return ApiClient$HTTP$Request(request);
  }

  static final Expando<http_package.BaseRequest Function()> _replayFactories =
      Expando<http_package.BaseRequest Function()>(r'ApiClient$HTTP$Request.replayFactory');

  /// Returns this logical request as a request cancelled by [abortTrigger].
  ///
  /// The original request remains untouched. Replayable multipart requests
  /// rebuild both their body streams and their abortable wrapper on every clone.
  ApiClient$HTTP$Request abortable(Future<void> abortTrigger) {
    final replayFactory = _replayFactories[_request];
    http_package.BaseRequest createAbortable(http_package.BaseRequest request) => switch (request) {
      http_package.MultipartRequest request => _createAbortableMultipartRequest(request, abortTrigger),
      http_package.Request request => _createAbortableRequest(request, abortTrigger),
      _ => throw UnsupportedError(
        r'ApiClient$HTTP$Request.abortable requires an http.Request or http.MultipartRequest.',
      ),
    };

    final request = createAbortable(_request);
    if (replayFactory == null) return ApiClient$HTTP$Request(request);
    http_package.BaseRequest createReplay() => createAbortable(replayFactory());
    return ApiClient$HTTP$Request.replayable(request, createReplay);
  }

  /// Cancellation trigger attached to the underlying request, if any.
  Future<void>? get abortTrigger => switch (_request) {
    http_package.Abortable(:final abortTrigger) => abortTrigger,
    _ => null,
  };

  /// Creates a replay-safe copy of the underlying request.
  ///
  /// JSON requests copy their materialized bytes. Multipart requests invoke
  /// their registered factory so every replay receives fresh file streams.
  ApiClient$HTTP$Request clone() {
    final replayFactory = _replayFactories[_request];
    if (replayFactory == null) {
      return switch (_request) {
        http_package.Request request => ApiClient$HTTP$Request(_cloneRequest(request)),
        _ => throw UnsupportedError(
          r'ApiClient$HTTP$Request.clone requires an http.Request or a registered replay factory.',
        ),
      };
    }

    final cloned = replayFactory();
    _copyRequestConfiguration(_request, cloned);
    return ApiClient$HTTP$Request.replayable(cloned, replayFactory);
  }

  /// Creates a deep copy of an [http_package.Request].
  http_package.Request _cloneRequest(http_package.Request request) {
    final cloned = switch (request) {
      http_package.Abortable(:final abortTrigger) => http_package.AbortableRequest(
        request.method,
        request.url,
        abortTrigger: abortTrigger,
      ),
      _ => http_package.Request(request.method, request.url),
    };
    return cloned
      ..encoding = request.encoding
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection
      ..headers.addAll(request.headers)
      ..bodyBytes = Uint8List.fromList(request.bodyBytes);
  }

  http_package.AbortableRequest _createAbortableRequest(http_package.Request request, Future<void> abortTrigger) =>
      http_package.AbortableRequest(request.method, request.url, abortTrigger: abortTrigger)
        ..encoding = request.encoding
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection
        ..headers.addAll(request.headers)
        ..bodyBytes = Uint8List.fromList(request.bodyBytes);

  http_package.AbortableMultipartRequest _createAbortableMultipartRequest(
    http_package.MultipartRequest request,
    Future<void> abortTrigger,
  ) => http_package.AbortableMultipartRequest(request.method, request.url, abortTrigger: abortTrigger)
    ..followRedirects = request.followRedirects
    ..maxRedirects = request.maxRedirects
    ..persistentConnection = request.persistentConnection
    ..headers.addAll(request.headers)
    ..fields.addAll(request.fields)
    ..files.addAll(request.files);

  /// Copies caller- and middleware-controlled request configuration.
  void _copyRequestConfiguration(http_package.BaseRequest source, http_package.BaseRequest target) {
    target
      ..followRedirects = source.followRedirects
      ..maxRedirects = source.maxRedirects
      ..persistentConnection = source.persistentConnection;
    target.headers
      ..clear()
      ..addAll(source.headers);
  }
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

  /// Encodes query parameters while preserving repeated keys for iterables.
  static String? _encodeQueryParameters(Map<String, Object?>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return null;
    }

    final buffer = StringBuffer();
    var isFirst = true;

    void append(String key, Object value) {
      if (!isFirst) buffer.write('&');
      isFirst = false;
      buffer
        ..write(Uri.encodeQueryComponent(key))
        ..write('=')
        ..write(Uri.encodeQueryComponent(value.toString()));
    }

    for (final entry in queryParameters.entries) {
      final value = entry.value;
      if (value == null) continue;

      if (value case Iterable<Object?> values) {
        for (final item in values) {
          if (item == null) continue;
          append(entry.key, item);
        }
        continue;
      }

      append(entry.key, value);
    }

    return buffer.isEmpty ? null : buffer.toString();
  }

  /// Merges the given [path] with the base URL.
  static Uri _mergePath(Uri base, String path, {Map<String, Object?>? queryParameters}) {
    final query = _encodeQueryParameters(queryParameters);

    final normalizedPath = path.startsWith('http')
        ? Uri.parse(path)
        : base.replace(
            pathSegments: <String>[
              ...base.pathSegments.where((segment) => segment.isNotEmpty),
              ...path.split('/').where((segment) => segment.isNotEmpty),
            ],
          );

    return normalizedPath.replace(query: query);
  }

  /// Sends a non-streaming [http_package.Request] and returns a non-streaming [http_package.Response].
  static Future<ApiClient$HTTP$Response> _sendUnstreamed({
    required ApiClientHandler handler,
    required String method,
    required Uri url,
    required Map<String, String>? headers,
    required Map<String, Object?>? body,
    required Map<String, Object?> context,
    Future<void>? abortTrigger,
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
      request.bodyBytes = bytes;
    }
    final wrapped = ApiClient$HTTP$Request(request);
    return handler(abortTrigger == null ? wrapped : wrapped.abortable(abortTrigger), context);
  }

  /// Builds and dispatches a replayable multipart request.
  ///
  /// Every multipart request opts out of generic retry and deduplication. Its
  /// rebuild factory remains available for the authentication middleware's
  /// bounded replay with freshly opened file streams.
  static Future<ApiClient$HTTP$Response> _sendMultipart({
    required ApiClientHandler handler,
    required String method,
    required Uri url,
    required Map<String, Object?> body,
    required Map<String, String>? headers,
    required Map<String, Object?>? context,
    Future<void>? abortTrigger,
  }) async {
    final parts = await normalizeMultipartBody(body);

    http_package.BaseRequest createRequest() {
      final request = http_package.MultipartRequest(method, url)..maxRedirects = 5;
      request.files.addAll(<http_package.MultipartFile>[
        for (final field in parts.fields) http_package.MultipartFile.fromString(field.key, field.value),
        for (final part in parts.files)
          http_package.MultipartFile(
            part.field,
            part.file.openRead(),
            part.length,
            filename: part.filename,
            contentType: switch (part.mimeType) {
              final String mimeType => http_package.MediaType.parse(mimeType),
              null => null,
            },
          ),
      ]);
      return request;
    }

    final request = createRequest();
    request.headers['Accept'] = 'application/json';
    if (headers != null) request.headers.addAll(headers);
    final wrapped = ApiClient$HTTP$Request.replayable(request, createRequest);
    return handler(abortTrigger == null ? wrapped : wrapped.abortable(abortTrigger), <String, Object?>{
      ...?context,
      'no-retry': true,
      'no-dedupe': true,
    });
  }

  /// Sends a GET request to the given [path].
  ///
  Future<ApiClient$HTTP$Response> get(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    Future<void>? abortTrigger,
    Map<String, String>? headers,
  }) => _sendUnstreamed(
    url: _mergePath(_baseUrl, path, queryParameters: queryParameters),
    handler: _handler,
    headers: headers,
    method: 'GET',
    body: null,
    context: <String, Object?>{...?context},
    abortTrigger: abortTrigger,
  );

  /// Sends a POST request to the given [path].
  ///
  /// Set [multipart] to encode [body] as form fields and platform-neutral file
  /// streams instead of JSON. Multipart requests force
  /// `context['no-retry']` and `context['no-dedupe']` to `true`; authentication
  /// replay remains available through a freshly rebuilt request.
  Future<ApiClient$HTTP$Response> post(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object?>? context,
    Future<void>? abortTrigger,
    Map<String, Object?>? body,
    bool multipart = false,
  }) => multipart
      ? _sendMultipart(
          url: _mergePath(_baseUrl, path, queryParameters: queryParameters),
          handler: _handler,
          headers: headers,
          method: 'POST',
          body: body ?? const <String, Object?>{},
          context: context,
          abortTrigger: abortTrigger,
        )
      : _sendUnstreamed(
          url: _mergePath(_baseUrl, path, queryParameters: queryParameters),
          handler: _handler,
          headers: headers,
          method: 'POST',
          body: body,
          context: <String, Object?>{...?context},
          abortTrigger: abortTrigger,
        );

  /// Sends a PUT request to the given [path].
  ///
  /// Set [multipart] to encode [body] as form fields and platform-neutral file
  /// streams instead of JSON. This always sends a real `PUT` request; endpoint
  /// method overrides belong to the calling repository, not this transport. If
  /// a verified legacy endpoint requires `_method=PUT`, call [post] with that
  /// field instead of expecting this method to rewrite the verb.
  ///
  /// Multipart requests force `context['no-retry']` and
  /// `context['no-dedupe']` to `true`; authentication replay remains available
  /// through a freshly rebuilt request.
  Future<ApiClient$HTTP$Response> put(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object?>? context,
    Future<void>? abortTrigger,
    Map<String, Object?>? body,
    bool multipart = false,
  }) => multipart
      ? _sendMultipart(
          url: _mergePath(_baseUrl, path, queryParameters: queryParameters),
          handler: _handler,
          headers: headers,
          method: 'PUT',
          body: body ?? const <String, Object?>{},
          context: context,
          abortTrigger: abortTrigger,
        )
      : _sendUnstreamed(
          url: _mergePath(_baseUrl, path, queryParameters: queryParameters),
          handler: _handler,
          headers: headers,
          method: 'PUT',
          body: body,
          context: <String, Object?>{...?context},
          abortTrigger: abortTrigger,
        );

  /// Sends a DELETE request to the given [path].
  ///
  Future<ApiClient$HTTP$Response> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, Object?>? context,
    Future<void>? abortTrigger,
    Map<String, Object?>? body,
  }) => _sendUnstreamed(
    url: _mergePath(_baseUrl, path),
    handler: _handler,
    headers: headers,
    method: 'DELETE',
    body: body,
    context: <String, Object?>{...?context},
    abortTrigger: abortTrigger,
  );
}

/// Creates a new [ApiClientHandler] from the given [internalClient] and [middleware].
ApiClientHandler _createHandler(http_package.Client internalClient, ApiClientMiddleware middleware) {
  // JSON decoder.
  final jsonDecoder = const Utf8Decoder().fuse(const JsonDecoder());

  // Completes the response future with a normalized package exception.
  void throwError(Completer<ApiClient$HTTP$Response> completer, Object e, StackTrace s) {
    if (completer.isCompleted) {
      return;
    } else if (e is ApiException) {
      completer.completeError(e, s);
    } else {
      completer.completeError(
        ApiException$Client(
          code: 'unknown_error',
          message: 'Unknown error.',
          statusCode: 0,
          error: e,
          stackTrace: s,
          data: null,
        ),
        s,
      );
    }
  }

  /// Decodes error information from the response body
  /// and maps it into an appropriate [ApiException] subtype based on the status code.
  String decodeErrorMessage(Map<String, Object?> body, int statusCode) => switch (body) {
    {'errors': {'message': Object message}} => message.toString(),
    {'errors': Map<String, Object?> errors} => switch (errors.values.firstOrNull) {
      [{'message': Object message}, ...] => message.toString(),
      _ => switch (statusCode) {
        > 499 => 'Internal server error.',
        401 || 403 => 'User is not authorized.',
        > 399 => 'Bad request.',
        > 299 => 'Request was redirected.',
        _ => 'Unknown error.',
      },
    },
    _ => switch (statusCode) {
      > 499 => 'Internal server error.',
      401 || 403 => 'User is not authorized.',
      > 399 => 'Bad request.',
      > 299 => 'Request was redirected.',
      _ => 'Unknown error.',
    },
  };

  Object? decodeErrorField(Map<String, Object?> body, String field) {
    final errors = body['errors'];
    if (errors is! Map<String, Object?>) return null;
    final direct = errors[field];
    if (direct != null) return direct;
    return switch (errors.values.firstOrNull) {
      [Map<Object?, Object?> value, ...] => value[field],
      _ => null,
    };
  }

  String? parseErrorCode(Object? value) => switch (value) {
    String code when code.isNotEmpty && int.tryParse(code) == null => code,
    _ => null,
  };

  /// Uses a non-numeric backend error code or the HTTP transport category.
  String decodeErrorCode(Map<String, Object?> body, int httpStatusCode) =>
      parseErrorCode(decodeErrorField(body, 'code')) ?? ApiException.codeForStatus(httpStatusCode);

  /// Maps HTTP status code errors into appropriate [ApiException] subtypes.
  ApiException mapStatusError({required int statusCode, required Map<String, Object?> body, required Object? data}) {
    final message = decodeErrorMessage(body, statusCode);
    final code = decodeErrorCode(body, statusCode);
    return switch (statusCode) {
      > 499 => ApiException$Network(
        code: code,
        message: message,
        statusCode: statusCode,
        error: null,
        data: data,
        stackTrace: StackTrace.current,
      ),
      401 || 403 => ApiException$Authorization(
        code: code,
        message: message,
        statusCode: statusCode,
        error: null,
        data: data,
        stackTrace: StackTrace.current,
      ),
      > 399 => ApiException$Client(
        code: code,
        message: message,
        statusCode: statusCode,
        error: null,
        data: data,
        stackTrace: StackTrace.current,
      ),
      > 299 => ApiException$Client(
        code: code,
        message: message,
        statusCode: statusCode,
        error: null,
        data: data,
        stackTrace: StackTrace.current,
      ),
      _ => throw StateError('Status is not an error: $statusCode'),
    };
  }

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
        } on http_package.RequestAbortedException catch (e, s) {
          throwError(
            completer,
            ApiException$Network(
              code: 'cancelled',
              message: 'Request was cancelled.',
              statusCode: 0,
              error: e,
              stackTrace: s,
              data: null,
            ),
            s,
          );
          return;
        } on Object catch (e, s) {
          throwError(
            completer,
            ApiException$Network(
              code: 'network_error',
              message: 'Failed to send request due to a network error.',
              statusCode: 0,
              error: e,
              stackTrace: s,
              data: null,
            ),
            s,
          );
          return;
        }

        final statusCode = streamedResponse.statusCode;

        // Read the response stream.
        int contentLength;
        Uint8List bytes;
        try {
          bytes = await streamedResponse.stream.toBytes();
          contentLength = bytes.length;

          if (bytes.isNotEmpty) {
            final contentType = streamedResponse.headers['content-type']?.toLowerCase() ?? '';
            if (statusCode < 300 && !contentType.contains('application/json')) {
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
          }
        } on http_package.RequestAbortedException catch (e, s) {
          throwError(
            completer,
            ApiException$Network(
              code: 'cancelled',
              message: 'Request was cancelled.',
              statusCode: streamedResponse.statusCode,
              error: e,
              stackTrace: s,
              data: null,
            ),
            s,
          );
          return;
        } on Object catch (e, s) {
          throwError(
            completer,
            ApiException$Network(
              code: 'body_stream_error',
              message: 'Failed to read response stream.',
              statusCode: streamedResponse.statusCode,
              stackTrace: s,
              error: e,
              data: null,
            ),
            s,
          );
          return;
        }

        // Decode the response.
        ApiClient$HTTP$Response response;
        try {
          Map<String, Object?> body;
          try {
            final decoded = bytes.isEmpty ? null : jsonDecoder.convert(bytes);
            body = switch (decoded) {
              null => <String, Object?>{},
              Map<String, Object?> value => value,
              Map<Object?, Object?> value => Map<String, Object?>.from(value),
              _ => throw FormatException('Response is not a JSON object.', decoded),
            };
          } on Object {
            if (statusCode < 300) rethrow;
            body = <String, Object?>{};
          }
          if (statusCode > 299) {
            throwError(completer, mapStatusError(statusCode: statusCode, body: body, data: body), StackTrace.current);
            return;
          }
          response = ApiClient$HTTP$Response.json(
            body,
            statusCode: streamedResponse.statusCode,
            headers: streamedResponse.headers,
            contentLength: contentLength,
            persistentConnection: streamedResponse.persistentConnection,
            request: request,
          );
        } on Object catch (e, s) {
          throwError(
            completer,
            ApiException$Client(
              code: 'decoding_error',
              message: 'Failed to decode response.',
              statusCode: streamedResponse.statusCode,
              stackTrace: s,
              error: e,
              data: bytes,
            ),
            s,
          );
          return;
        }

        // Complete the completer.
        if (!completer.isCompleted) completer.complete(response);
      },
      (e, s) {
        throwError(completer, e, s);
      },
    );
    return completer.future;
  }

  return middleware(httpHandler);
}
