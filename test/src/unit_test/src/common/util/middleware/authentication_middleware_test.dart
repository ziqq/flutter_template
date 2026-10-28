/*
 * Date: 25 March 2026
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/util/middleware/authentication_middleware.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http_package;

import '../../../../../util/mocks/mock_service.dart';

void main() => group('AuthenticationMiddleware -', () {
  late Uri requestUri;
  late Uri refreshUri;

  setUp(() {
    requestUri = Uri.parse('https://example.com/api/items');
    refreshUri = Uri.parse('https://example.com/api/auth/v2/refresh-token');
  });

  test('adds Authorization header when access token exists', () async {
    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => MockService.token,
      onTokenExpired: () async {},
      onUpdateToken: (_) async {},
      httpClient: _FakeHttpClient((_) async => throw UnimplementedError()),
    );

    final handler = middleware.call((request, context) async {
      expect(request.headers['Authorization'], 'Bearer ${MockService.token}');
      return _successResponse(request);
    });

    final response = await handler(_postRequest(requestUri), <String, Object?>{});

    expect(response.statusCode, 200);
    expect(response.body, _successResponseBody);
  });

  test('does not add Authorization header when access token is missing', () async {
    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => null,
      onTokenExpired: () async {},
      onUpdateToken: (_) async {},
      httpClient: _FakeHttpClient((_) async => throw UnimplementedError()),
    );

    final handler = middleware.call((request, context) async {
      expect(request.headers.containsKey('Authorization'), isFalse);
      return _successResponse(request);
    });

    final response = await handler(_postRequest(requestUri), <String, Object?>{});

    expect(response.statusCode, 200);
  });

  test('does not refresh on non-401 authorization error', () async {
    var refreshCalls = 0;

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => MockService.token,
      onTokenExpired: () async {},
      onUpdateToken: (_) async {},
      httpClient: _FakeHttpClient((_) async {
        refreshCalls++;
        return _jsonResponse(200, _refreshSuccessResponse);
      }),
    );

    final handler = middleware.call((request, context) async {
      throw const ApiException$Authorization(statusCode: 403, message: 'forbidden', code: 'forbidden_error');
    });

    await expectLater(
      () => handler(_postRequest(requestUri), <String, Object?>{}),
      throwsA(isA<ApiException$Authorization>().having((e) => e.statusCode, 'statusCode', 403)),
    );

    expect(refreshCalls, 0);
  });

  test('refreshes token and retries request once', () async {
    final refreshedToken = (
      accessToken: _refreshSuccessResponse['access_token'].toString(),
      refreshToken: _refreshSuccessResponse['refresh_token'].toString(),
    );
    var storedToken = MockService.token;
    var requestCalls = 0;
    var refreshCalls = 0;
    var updateCalls = 0;

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => storedToken,
      onTokenExpired: () async {},
      onUpdateToken: (token) async {
        storedToken = token;
        updateCalls++;
      },
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        expect(request.url, refreshUri);
        expect(request.headers['Authorization'], 'Bearer ${MockService.token}');
        expect((request as http_package.Request).body, MockService.token);
        return _jsonResponse(200, _refreshSuccessResponse);
      }),
    );

    final handler = middleware.call((request, context) async {
      requestCalls++;
      expect((request as http_package.Request).body, jsonEncode(<String, Object?>{'name': 'item'}));

      if (requestCalls == 1) {
        expect(request.headers['Authorization'], 'Bearer ${MockService.token}');
        throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
      }

      expect(request.headers['Authorization'], 'Bearer ${refreshedToken.accessToken}');
      return _successResponse(request);
    });

    final response = await handler(_postRequest(requestUri), <String, Object?>{});

    expect(storedToken, refreshedToken.accessToken);
    expect(response.statusCode, 200);
    expect(requestCalls, 2);
    expect(refreshCalls, 1);
    expect(updateCalls, 1);
  });

  test('uses resolved refresh url from base path and preserves base query parameters', () async {
    var storedToken = MockService.token;
    var requestCalls = 0;
    final refreshedToken = (
      accessToken: _refreshSuccessResponse['access_token'].toString(),
      refreshToken: _refreshSuccessResponse['refresh_token'].toString(),
    );
    final httpClient = _FakeHttpClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/auth/v2/refresh-token');
      expect(request.url.queryParameters['locale'], 'ru');
      expect(request.headers['Authorization'], 'Bearer ${MockService.token}');
      expect((request as http_package.Request).body, MockService.token);
      return _jsonResponse(200, _refreshSuccessResponse);
    });

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api?locale=ru',
      getToken: () async => storedToken,
      onTokenExpired: () async {},
      onUpdateToken: (token) async {
        storedToken = token;
      },
      httpClient: httpClient,
    );

    final handler = middleware.call((request, context) async {
      requestCalls++;
      if (requestCalls == 1) {
        throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
      }

      expect(request.headers['Authorization'], 'Bearer ${refreshedToken.accessToken}');
      return _successResponse(request);
    });

    final response = await handler(_postRequest(requestUri), <String, Object?>{});

    expect(response.statusCode, 200);
    expect(requestCalls, 2);
    expect(storedToken, refreshedToken.accessToken);
  });

  test('shares one refresh attempt and logs out once when refresh fails', () async {
    final refreshCompleter = Completer<http_package.StreamedResponse>();
    var refreshCalls = 0;
    var logoutCalls = 0;

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => MockService.token,
      onTokenExpired: () async {
        logoutCalls++;
      },
      onUpdateToken: (_) async {},
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        expect(request.url, refreshUri);
        return refreshCompleter.future;
      }),
    );

    final handler = middleware.call((request, context) async {
      throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
    });

    final first = handler(_postRequest(requestUri), <String, Object?>{});
    final second = handler(_postRequest(requestUri), <String, Object?>{});

    refreshCompleter.complete(
      _jsonResponse(401, <String, Object?>{
        'errors': <String, Object?>{'code': 401, 'message': 'expired'},
      }),
    );

    await expectLater(first, throwsA(isA<ApiException$Authorization>()));
    await expectLater(second, throwsA(isA<ApiException$Authorization>()));

    expect(refreshCalls, 1);
    expect(logoutCalls, 1);
  });

  for (final stalledPhase in <String>['headers', 'body']) {
    testWidgets('aborts refresh with stalled $stalledPhase at the configured deadline and ignores late success', (
      tester,
    ) async {
      const timeout = Duration(milliseconds: 100);
      const unauthorized = ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
      final headers = Completer<http_package.StreamedResponse>();
      final body = StreamController<List<int>>();
      final bytes = utf8.encode(jsonEncode(_refreshSuccessResponse));
      var aborted = false;
      var completed = false;
      var refreshCalls = 0;
      var logoutCalls = 0;
      var updateCalls = 0;
      Object? refreshError;
      Object? requestError;
      final middleware = AuthenticationMiddleware(
        baseURL: 'https://example.com/api',
        requestTimeout: timeout,
        getToken: () async => MockService.token,
        onTokenExpired: () async {
          logoutCalls++;
        },
        onUpdateToken: (_) async {
          updateCalls++;
        },
        retryEvaluator: (error, _) {
          refreshError = error;
          return false;
        },
        httpClient: _FakeHttpClient((request) {
          refreshCalls++;
          expectSync(request, isA<http_package.AbortableRequest>());
          if (request case http_package.AbortableRequest(:final abortTrigger?)) {
            unawaited(abortTrigger.then((_) => aborted = true));
          }
          return headers.future;
        }),
      );
      final handler = middleware.call((request, context) async => throw unauthorized);
      final result = handler(_postRequest(requestUri), <String, Object?>{}).then<void>(
        (_) => completed = true,
        onError: (Object error) {
          requestError = error;
          completed = true;
        },
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      if (stalledPhase == 'body') {
        headers.complete(http_package.StreamedResponse(body.stream, 200));
        body.add(bytes.sublist(0, bytes.length - 1));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 59));
      expect(aborted, isFalse);
      expect(completed, isFalse);
      expect(logoutCalls, 0);

      await tester.pump(const Duration(milliseconds: 1));
      expect(aborted, isTrue);
      expect(completed, isTrue);
      expect(requestError, same(unauthorized));
      expect(logoutCalls, 1);
      expect(refreshCalls, 1);
      expect(
        refreshError,
        isA<ApiException$Network>().having(
          (error) => error.error,
          'cause',
          isA<TimeoutException>().having((error) => error.duration, 'duration', timeout),
        ),
      );
      await result;

      if (stalledPhase == 'headers') {
        headers.complete(http_package.StreamedResponse(body.stream, 200));
        body.add(bytes);
      } else {
        body.add(bytes.sublist(bytes.length - 1));
      }
      unawaited(body.close());
      await tester.pump();
      expect(updateCalls, 0);
      expect(logoutCalls, 1);
    });
  }

  testWidgets('gives each refresh retry its own deadline and does not abort a successful attempt', (tester) async {
    const timeout = Duration(milliseconds: 100);
    final firstResponse = Completer<http_package.StreamedResponse>();
    final retryResponse = Completer<http_package.StreamedResponse>();
    final abortedAttempts = <int>[];
    var refreshCalls = 0;
    var requestCalls = 0;
    var logoutCalls = 0;
    final updatedTokens = <String>[];
    final refreshedToken = _refreshSuccessResponse['access_token'].toString();
    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      requestTimeout: timeout,
      retries: 1,
      retryDelays: const <Duration>[Duration.zero],
      getToken: () async => MockService.token,
      onTokenExpired: () async {
        logoutCalls++;
      },
      onUpdateToken: (token) async {
        updatedTokens.add(token);
      },
      httpClient: _FakeHttpClient((request) {
        final attempt = ++refreshCalls;
        expectSync(request, isA<http_package.AbortableRequest>());
        if (request case http_package.AbortableRequest(:final abortTrigger?)) {
          unawaited(abortTrigger.then((_) => abortedAttempts.add(attempt)));
        }
        return attempt == 1 ? firstResponse.future : retryResponse.future;
      }),
    );
    final handler = middleware.call((request, context) async {
      if (++requestCalls == 1) {
        throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
      }
      expectSync(request.headers['Authorization'], 'Bearer $refreshedToken');
      return _successResponse(request);
    });
    ApiClient$HTTP$Response? response;
    Object? requestError;
    final result = handler(_postRequest(requestUri), <String, Object?>{}).then<void>(
      (value) => response = value,
      onError: (Object error) {
        requestError = error;
      },
    );

    await tester.pump();
    await tester.pump(timeout);
    expect(refreshCalls, 2);
    expect(abortedAttempts, <int>[1]);
    expect(updatedTokens, isEmpty);
    expect(logoutCalls, 0);

    await tester.pump(const Duration(milliseconds: 99));
    retryResponse.complete(_jsonResponse(200, _refreshSuccessResponse));
    await tester.pump();
    await result;
    expect(requestError, isNull);
    expect(response?.statusCode, 200);
    expect(updatedTokens, <String>[refreshedToken]);
    expect(requestCalls, 2);

    firstResponse.complete(_jsonResponse(200, <String, Object?>{'access_token': 'late-token'}));
    await tester.pump(timeout);
    expect(abortedAttempts, <int>[1]);
    expect(updatedTokens, <String>[refreshedToken]);
    expect(logoutCalls, 0);
    expect(refreshCalls, 2);
  });

  test('retries refresh request on network error using retry policy', () async {
    final refreshedToken = (
      accessToken: _refreshSuccessResponse['access_token'].toString(),
      refreshToken: _refreshSuccessResponse['refresh_token'].toString(),
    );
    var storedToken = MockService.token;
    var refreshCalls = 0;
    var updateCalls = 0;
    var requestCalls = 0;

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => storedToken,
      onTokenExpired: () async {},
      onUpdateToken: (token) async {
        storedToken = token;
        updateCalls++;
      },
      retryDelays: const <Duration>[Duration.zero, Duration.zero, Duration.zero],
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        expect(request.url, refreshUri);
        if (refreshCalls < 3) {
          throw const SocketException('network error');
        }
        return _jsonResponse(200, _refreshSuccessResponse);
      }),
    );

    final handler = middleware.call((request, context) async {
      requestCalls++;
      if (requestCalls == 1) {
        throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
      }
      expect(request.headers['Authorization'], 'Bearer ${refreshedToken.accessToken}');
      return _successResponse(request);
    });

    final response = await handler(_postRequest(requestUri), <String, Object?>{});

    expect(response.statusCode, 200);
    expect(refreshCalls, 3);
    expect(updateCalls, 1);
    expect(requestCalls, 2);
    expect(storedToken, refreshedToken.accessToken);
  });

  test('logs out when refresh response payload is invalid', () async {
    var refreshCalls = 0;
    var logoutCalls = 0;
    var updateCalls = 0;

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => MockService.token,
      onTokenExpired: () async {
        logoutCalls++;
      },
      onUpdateToken: (_) async {
        updateCalls++;
      },
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        expect(request.url, refreshUri);
        return _jsonResponse(200, <String, Object?>{
          'errors': <String, Object?>{'code': 101, 'message': 'expired'},
        });
      }),
    );

    final handler = middleware.call((request, context) async {
      throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
    });

    await expectLater(
      () => handler(_postRequest(requestUri), <String, Object?>{}),
      throwsA(isA<ApiException$Authorization>().having((e) => e.statusCode, 'statusCode', 401)),
    );

    expect(refreshCalls, 1);
    expect(logoutCalls, 1);
    expect(updateCalls, 0);
  });

  test('logs out when refresh response body is not valid json', () async {
    var logoutCalls = 0;
    var updateCalls = 0;
    final httpClient = _FakeHttpClient((request) async {
      expect(request.url.path, '/api/auth/v2/refresh-token');
      final bytes = utf8.encode('not-json');
      return http_package.StreamedResponse(
        Stream<List<int>>.value(bytes),
        200,
        contentLength: bytes.length,
        headers: const <String, String>{'content-type': 'application/json'},
      );
    });

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => MockService.token,
      onTokenExpired: () async {
        logoutCalls++;
      },
      onUpdateToken: (_) async {
        updateCalls++;
      },
      httpClient: httpClient,
    );

    final handler = middleware.call((request, context) async {
      throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
    });

    await expectLater(
      () => handler(_postRequest(requestUri), <String, Object?>{}),
      throwsA(isA<ApiException$Authorization>().having((e) => e.statusCode, 'statusCode', 401)),
    );

    expect(logoutCalls, 1);
    expect(updateCalls, 0);
  });

  test('uses custom defaultRetryEvaluator to retry refresh after client decoding error', () async {
    var refreshCalls = 0;
    var requestCalls = 0;
    var updateCalls = 0;
    var storedToken = MockService.token;
    final httpClient = _FakeHttpClient((request) async {
      refreshCalls++;
      expect(request.url, refreshUri);
      if (refreshCalls == 1) {
        final bytes = utf8.encode('not-json');
        return http_package.StreamedResponse(
          Stream<List<int>>.value(bytes),
          200,
          contentLength: bytes.length,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }
      return _jsonResponse(200, _refreshSuccessResponse);
    });
    final refreshedToken = (
      accessToken: _refreshSuccessResponse['access_token'].toString(),
      refreshToken: _refreshSuccessResponse['refresh_token'].toString(),
    );

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => storedToken,
      onUpdateToken: (token) async {
        storedToken = token;
        updateCalls++;
      },
      onTokenExpired: () async {},
      httpClient: httpClient,
      retryDelays: const <Duration>[Duration.zero, Duration.zero, Duration.zero],
      retryEvaluator: (error, attempt) => error is ApiException$Client && attempt == 0,
    );

    final handler = middleware.call((request, context) async {
      requestCalls++;
      if (requestCalls == 1) {
        throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
      }
      expect(request.headers['Authorization'], 'Bearer ${refreshedToken.accessToken}');
      return _successResponse(request);
    });

    final response = await handler(_postRequest(requestUri), <String, Object?>{});

    expect(response.statusCode, 200);
    expect(refreshCalls, 2);
    expect(requestCalls, 2);
    expect(updateCalls, 1);
    expect(storedToken, refreshedToken.accessToken);
  });

  test('does not retry refresh request when refresh endpoint returns 401', () async {
    var refreshCalls = 0;
    var logoutCalls = 0;

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => MockService.token,
      onTokenExpired: () async {
        logoutCalls++;
      },
      onUpdateToken: (_) async {},
      retryDelays: const <Duration>[Duration.zero, Duration.zero, Duration.zero],
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        expect(request.url, refreshUri);
        return _jsonResponse(401, <String, Object?>{
          'errors': <String, Object?>{'code': 401, 'message': 'expired'},
        });
      }),
    );

    final handler = middleware.call((request, context) async {
      throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
    });

    await expectLater(
      () => handler(_postRequest(requestUri), <String, Object?>{}),
      throwsA(isA<ApiException$Authorization>().having((e) => e.statusCode, 'statusCode', 401)),
    );

    expect(refreshCalls, 1);
    expect(logoutCalls, 1);
  });

  test('shares one successful refresh attempt between concurrent 401 requests', () async {
    final refreshedToken = (
      accessToken: _refreshSuccessResponse['access_token'].toString(),
      refreshToken: _refreshSuccessResponse['refresh_token'].toString(),
    );
    final refreshCompleter = Completer<http_package.StreamedResponse>();
    var storedToken = MockService.token;
    var refreshCalls = 0;
    var updateCalls = 0;
    final seenAuthHeaders = <String>[];

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => storedToken,
      onTokenExpired: () async {},
      onUpdateToken: (token) async {
        storedToken = token;
        updateCalls++;
      },
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        expect(request.url, refreshUri);
        return refreshCompleter.future;
      }),
    );

    final requestAttempts = <String, int>{};
    final handler = middleware.call((request, context) async {
      final key = request.url.queryParameters['id']!;
      requestAttempts.update(key, (value) => value + 1, ifAbsent: () => 1);

      if (requestAttempts[key] == 1) {
        expect(request.headers['Authorization'], 'Bearer ${MockService.token}');
        throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
      }

      seenAuthHeaders.add(request.headers['Authorization']!);
      return _successResponse(request);
    });

    final firstFuture = handler(
      _postRequest(requestUri.replace(queryParameters: <String, String>{'id': '1'})),
      <String, Object?>{},
    );
    final secondFuture = handler(
      _postRequest(requestUri.replace(queryParameters: <String, String>{'id': '2'})),
      <String, Object?>{},
    );

    refreshCompleter.complete(_jsonResponse(200, _refreshSuccessResponse));

    final results = await Future.wait<ApiClient$HTTP$Response>(<Future<ApiClient$HTTP$Response>>[
      firstFuture,
      secondFuture,
    ]);

    expect(results.every((response) => response.statusCode == 200), isTrue);
    expect(refreshCalls, 1);
    expect(updateCalls, 1);
    expect(storedToken, refreshedToken.accessToken);
    expect(seenAuthHeaders, <String>['Bearer ${refreshedToken.accessToken}', 'Bearer ${refreshedToken.accessToken}']);
  });

  test('logs out and rethrows original authorization error when retried request returns 401 again', () async {
    var refreshCalls = 0;
    var logoutCalls = 0;
    var requestCalls = 0;

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => MockService.token,
      onTokenExpired: () async {
        logoutCalls++;
      },
      onUpdateToken: (_) async {},
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        expect(request.url, refreshUri);
        return _jsonResponse(200, _refreshSuccessResponse);
      }),
    );

    final handler = middleware.call((request, context) async {
      requestCalls++;
      throw const ApiException$Authorization(statusCode: 401, message: 'still expired', code: 'unauthorized_error');
    });

    await expectLater(
      () => handler(_postRequest(requestUri), <String, Object?>{}),
      throwsA(
        isA<ApiException$Authorization>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', 'still expired'),
      ),
    );

    expect(refreshCalls, 1);
    expect(logoutCalls, 1);
    expect(requestCalls, 2);
  });

  test('rejects immediately after logout without starting another refresh', () async {
    String? storedToken = MockService.token;
    var refreshCalls = 0;
    var logoutCalls = 0;

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => storedToken,
      onTokenExpired: () async {
        logoutCalls++;
        storedToken = null;
      },
      onUpdateToken: (_) async {},
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        expect(request.url, refreshUri);
        return _jsonResponse(401, <String, Object?>{
          'errors': <String, Object?>{'code': 401, 'message': 'expired'},
        });
      }),
    );

    final handler = middleware.call((request, context) async {
      throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
    });

    await expectLater(
      () => handler(_postRequest(requestUri), <String, Object?>{}),
      throwsA(isA<ApiException$Authorization>().having((e) => e.statusCode, 'statusCode', 401)),
    );
    await expectLater(
      () => handler(_postRequest(requestUri), <String, Object?>{}),
      throwsA(isA<ApiException$Authorization>().having((e) => e.statusCode, 'statusCode', 401)),
    );

    expect(refreshCalls, 1);
    expect(logoutCalls, 1);
  });

  test('allows refresh again after logout once a new access token is available', () async {
    String? storedToken = MockService.token;
    var refreshCalls = 0;
    var logoutCalls = 0;
    final refreshedToken = (
      accessToken: _refreshSuccessResponse['access_token'].toString(),
      refreshToken: _refreshSuccessResponse['refresh_token'].toString(),
    );

    final middleware = AuthenticationMiddleware(
      baseURL: 'https://example.com/api',
      getToken: () async => storedToken,
      onTokenExpired: () async {
        logoutCalls++;
        storedToken = null;
      },
      onUpdateToken: (token) async {
        storedToken = token;
      },
      httpClient: _FakeHttpClient((request) async {
        refreshCalls++;
        if (refreshCalls == 1) {
          return _jsonResponse(401, <String, Object?>{
            'errors': <String, Object?>{'code': 401, 'message': 'expired'},
          });
        }
        return _jsonResponse(200, _refreshSuccessResponse);
      }),
    );

    final requestAttempts = <String, int>{};
    final handler = middleware.call((request, context) async {
      final key = request.url.queryParameters['id']!;
      requestAttempts.update(key, (value) => value + 1, ifAbsent: () => 1);

      if (requestAttempts[key] == 1) {
        throw const ApiException$Authorization(statusCode: 401, message: 'expired', code: 'unauthorized_error');
      }

      expect(request.headers['Authorization'], 'Bearer ${refreshedToken.accessToken}');
      return _successResponse(request);
    });

    await expectLater(
      () => handler(
        _postRequest(requestUri.replace(queryParameters: <String, String>{'id': 'first'})),
        <String, Object?>{},
      ),
      throwsA(isA<ApiException$Authorization>().having((e) => e.statusCode, 'statusCode', 401)),
    );

    storedToken = MockService.token;

    final response = await handler(
      _postRequest(requestUri.replace(queryParameters: <String, String>{'id': 'second'})),
      <String, Object?>{},
    );

    expect(response.statusCode, 200);
    expect(refreshCalls, 2);
    expect(logoutCalls, 1);
    expect(storedToken, refreshedToken.accessToken);
  });
});

ApiClient$HTTP$Request _postRequest(Uri uri) => ApiClient$HTTP$Request(
  http_package.Request('POST', uri)
    ..headers['Content-Type'] = 'application/json'
    ..body = jsonEncode(<String, Object?>{'name': 'item'}),
);

ApiClient$HTTP$Response _successResponse(ApiClient$HTTP$Request request) => ApiClient$HTTP$Response.json(
  _successResponseBody,
  statusCode: 200,
  headers: const <String, String>{'content-type': 'application/json'},
  contentLength: 1,
  persistentConnection: false,
  request: request,
);

const _successResponseBody = <String, Object?>{'data': 'ok', 'errors': null};

const _refreshSuccessResponse = <String, Object?>{
  'access_token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vYmVhdXR5Ym94LXN0YWdlLnJ1L2FwaS9hdXRoL3YyL3JlZnJlc2gtdG9rZW4iLCJqdGkiOiIya2tWbzRxMkdURDhma1FWIiwiaWF0IjoxNzc0NDE4OTU2LCJuYmYiOjE3NzQ0MTg5NTYsImV4cCI6MTc3NTI4Mjk1Niwic3ViIjoiNDgxODgiLCJwcnYiOiI0ZDNkNjlmZGJhNGExMGZhMjc4YjgxZmM3ZmVkMzdmNjVmN2RjMDIwIiwidXNlcklEIjo0ODE4OCwiYWRkcmVzc0lEIjo0MTIwNywic2VjcmV0IjoiQXVYSmZIWmJzTXp4Q0FLUCJ9.HWf23yTtcYQV5lEz-2BlobWbPjOzvV6L0Nb4JNteEp8',
  'refresh_token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vYmVhdXR5Ym94LXN0YWdlLnJ1L2FwaS9hdXRoL3YyL3JlZnJlc2gtdG9rZW4iLCJqdGkiOiIya2tWbzRxMkdURDhma1FWIiwiaWF0IjoxNzc0NDE4OTU2LCJuYmYiOjE3NzQ0MTg5NTYsImV4cCI6MTc3NTI4Mjk1Niwic3ViIjoiNDgxODgiLCJwcnYiOiI0ZDNkNjlmZGJhNGExMGZhMjc4YjgxZmM3ZmVkMzdmNjVmN2RjMDIwIiwidXNlcklEIjo0ODE4OCwiYWRkcmVzc0lEIjo0MTIwNywic2VjcmV0IjoiQXVYSmZIWmJzTXp4Q0FLUCJ9.HWf23yTtcYQV5lEz-2BlobWbPjOzvV6L0Nb4JNteEp8',
  'token_type': 'bearer',
  'expires_in': 14400,
  'expires_refresh_in': 24400,
};

http_package.StreamedResponse _jsonResponse(int statusCode, Map<String, Object?> body) {
  final bytes = utf8.encode(jsonEncode(body));
  return http_package.StreamedResponse(
    Stream<List<int>>.value(bytes),
    statusCode,
    contentLength: bytes.length,
    headers: const <String, String>{'content-type': 'application/json'},
  );
}

final class _FakeHttpClient extends http_package.BaseClient {
  _FakeHttpClient(this._handler);

  final Future<http_package.StreamedResponse> Function(http_package.BaseRequest request) _handler;

  @override
  Future<http_package.StreamedResponse> send(http_package.BaseRequest request) => _handler(request);
}
