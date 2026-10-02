import 'dart:async';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/api_client/log_sanitizer.dart';
import 'package:flutter_template_name/src/common/controller/app_controller.dart';
import 'package:flutter_template_name/src/common/model/attachment_file.dart';
import 'package:flutter_template_name/src/common/model/photo.dart';
import 'package:flutter_template_name/src/common/util/file_util.dart';
import 'package:flutter_template_name/src/common/util/middleware/retry_middleware.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient -', () {
    test('reads JSON when the server does not send Content-Length', () async {
      final transport = MockClient.streaming(
        (request, body) async => http.StreamedResponse(
          Stream.value(utf8.encode('{"ok":true}')),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );
      addTearDown(transport.close);
      final client = ApiClient$HTTP(baseURL: 'https://example.com', client: transport);
      expect((await client.get('/items')).body, {'ok': true});
    });

    test('preserves authorization and retry status when errors are not JSON', () async {
      final transport = MockClient(
        (request) async => http.Response('<html>Error</html>', int.parse(request.url.pathSegments.last)),
      );
      addTearDown(transport.close);
      final client = ApiClient$HTTP(baseURL: 'https://example.com', client: transport);
      await expectLater(client.get('/401'), throwsA(isA<ApiException$Authorization>()));
      await expectLater(
        client.get('/503'),
        throwsA(
          isA<ApiException$Network>().having((error) => defaultRetryEvaluator$HTTP(error, 0), 'retryable', isTrue),
        ),
      );
    });

    test('does not retry cancelled response streams even with a transient HTTP status', () {
      expect(
        defaultRetryEvaluator$HTTP(
          const ApiException$Network(statusCode: 503, code: 'cancelled', message: 'Cancelled'),
          0,
        ),
        isFalse,
      );
    });

    test('retries a consumed JSON request with independent bytes and headers', () async {
      final requests = <http.Request>[];
      final transport = MockClient((request) async {
        requests.add(request);
        return http.Response(
          '{"ok":true}',
          requests.length == 1 ? 503 : 200,
          headers: {'content-type': 'application/json'},
        );
      });
      addTearDown(transport.close);
      final client = ApiClient$HTTP(
        baseURL: 'https://example.com/api',
        client: transport,
        middlewares: [
          RetryMiddleware(retries: 1, retryDelays: const [Duration.zero]).call,
        ],
      );
      final response = await client.post('/items', body: {'name': 'example'}, headers: {'X-Test': 'preserved'});
      expect(response.body, {'ok': true});
      expect(requests, hasLength(2));
      expect(requests.map((request) => request.body), everyElement('{"name":"example"}'));
      expect(requests.map((request) => request.headers['X-Test']), everyElement('preserved'));
      expect(identical(requests.first, requests.last), isFalse);
    });

    test('rebuilds multipart streams for authorization replay and forces upload safeguards', () async {
      final bodies = <String>[];
      final transport = MockClient((request) async {
        bodies.add(request.body);
        return http.Response('{}', bodies.length == 1 ? 401 : 200, headers: {'content-type': 'application/json'});
      });
      addTearDown(transport.close);
      final client = ApiClient$HTTP(
        baseURL: 'https://example.com',
        client: transport,
        middlewares: [
          (next) => (request, context) async {
            expect(context['no-retry'], isTrue);
            expect(context['no-dedupe'], isTrue);
            try {
              return await next(request, context);
            } on ApiException$Authorization {
              return next(request.clone(), context);
            }
          },
        ],
      );
      await client.post(
        '/upload',
        multipart: true,
        context: {'no-retry': false, 'no-dedupe': false},
        body: {
          'description': 'attachment',
          'file': XFile.fromData(
            utf8.encode('file-content'),
            path: 'report.txt',
            name: 'report.txt',
            mimeType: 'text/plain',
          ),
        },
      );
      expect(bodies, hasLength(2));
      for (final body in bodies) {
        expect(body, contains('filename="report.txt"'));
        expect(body, contains('file-content'));
        expect(body, contains('attachment'));
      }
    });

    test('does not retry multipart requests even when the caller opts in', () async {
      var attempts = 0;
      final transport = MockClient((request) async {
        attempts++;
        return http.Response('{}', 503, headers: {'content-type': 'application/json'});
      });
      addTearDown(transport.close);
      final client = ApiClient$HTTP(
        baseURL: 'https://example.com',
        client: transport,
        middlewares: [
          RetryMiddleware(retries: 1, retryDelays: const [Duration.zero]).call,
        ],
      );
      await expectLater(
        client.post(
          '/upload',
          multipart: true,
          context: {'no-retry': false},
          body: {'file': XFile.fromData(utf8.encode('content'), path: 'file.txt', name: 'file.txt')},
        ),
        throwsA(isA<ApiException$Network>()),
      );
      expect(attempts, 1);
    });

    test('cancels during retry backoff without sending another request', () async {
      final cancelled = Completer<void>();
      var attempts = 0;
      final handler = RetryMiddleware(retries: 1, retryDelays: const [Duration(milliseconds: 100)]).call((
        request,
        context,
      ) async {
        attempts++;
        cancelled.complete();
        throw const ApiException$Network(statusCode: 503, code: 'unavailable', message: 'Unavailable');
      });
      final request = ApiClient$HTTP$Request(http.Request('GET', Uri.parse('https://example.com')))
          .abortable(cancelled.future);
      await expectLater(
        handler(request, {}),
        throwsA(isA<ApiException>().having((error) => error.code, 'code', 'cancelled')),
      );
      expect(attempts, 1);
    });
  });

  group('Transport metadata -', () {
    test('redacts credentials, repeated tokens and presigned URLs without mutating requests', () {
      final uri = Uri.parse(
        'https://user:password@example.com/upload?token=one&token=two&X-Amz-Signature=secret&name=photo',
      );
      final headers = <String, String>{
        'Authorization': 'Bearer private',
        'Cookie': 'session=secret',
        'Accept': 'application/json',
      };
      final sanitized = Uri.parse(sanitizeUriForLogging(uri));
      expect(sanitized.queryParametersAll['token'], [kRedactedTransportLogValue, kRedactedTransportLogValue]);
      expect(sanitized.queryParameters['X-Amz-Signature'], kRedactedTransportLogValue);
      expect(sanitized.queryParameters['name'], 'photo');
      expect(sanitized.userInfo, isNot(contains('password')));
      expect(sanitizeHeadersForLogging(headers)['Authorization'], kRedactedTransportLogValue);
      expect(sanitizeHeadersForLogging(headers)['Cookie'], kRedactedTransportLogValue);
      expect(sanitizeHeadersForLogging(headers)['Accept'], 'application/json');
      expect(sanitizeQueryParametersForLogging(uri.queryParametersAll)['token'], kRedactedTransportLogValue);
      expect(headers['Authorization'], 'Bearer private');
      expect(uri.queryParametersAll['token'], ['one', 'two']);
    });
  });

  test('control handlers return typed results and remain sequential', () async {
    final controller = AppController$Sequential<int>(initialState: 0, name: 'test');
    addTearDown(controller.dispose);
    final gate = Completer<void>();
    final order = <String>[];
    final first = controller.handle<int>(() async {
      order.add('first');
      await gate.future;
      return 1;
    });
    final second = controller.handle<int>(() async {
      order.add('second');
      return 2;
    });
    await Future<void>.delayed(Duration.zero);
    expect(order, ['first']);
    gate.complete();
    expect(await first, 1);
    expect(await second, 2);
    expect(order, ['first', 'second']);
  });

  test('photo and attachment models retain in-memory file content', () async {
    final file = XFile.fromData(
      utf8.encode('content'),
      path: 'attachment.txt',
      name: 'attachment.txt',
      mimeType: 'text/plain',
    );
    final photo = Photo(file: file);
    expect(photo.copyWith(isUpdate: true).file, same(file));
    expect(photo.toJsonWithFile()['file'], same(file));
    expect(photo.toJson(), isNot(contains('file')));
    final attachment = AttachmentFile(
      size: 7,
      name: 'attachment.txt',
      type: FileExtensionType.txt,
      createdAt: DateTime.utc(2026),
      bytes: utf8.encode('content'),
      mimeType: 'text/plain',
    );
    expect(attachment.path, isNull);
    expect(await attachment.xFile!.readAsString(), 'content');
    expect(attachment.xFile!.name, 'attachment.txt');
  });
}
