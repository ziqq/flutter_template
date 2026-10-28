import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart'
    show ApiException$Authorization, ApiException$Network;
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/feature/initialization/data/initialization.dart';
import 'package:flutter_template_name/src/feature/initialization/data/initialize_dependencies.dart';
import 'package:flutter_test/flutter_test.dart' hide group;
import 'package:http/http.dart' as http;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:test/test.dart' show group;

void main() => group('HTTP configuration -', () {
  const connectivityChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const connectivityEvents = MethodChannel('dev.fluttercommunity.plus/connectivity_status');
  final platform = TargetPlatformVariant.only(TargetPlatform.linux);
  late io.Directory directory;
  late PathProviderPlatform previousPaths;
  SharedPreferencesAsyncPlatform? previousPreferences;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    directory = io.Directory.systemTemp.createTempSync('template-http-config-');
    previousPaths = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(directory.path);
    previousPreferences = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData({
      '${Config.storageNamespace}.authentication.session': jsonEncode({'id': 'test-user', 'token': 'old-token'}),
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(connectivityChannel, (_) async => ['wifi'])
      ..setMockMethodCallHandler(connectivityEvents, (_) async => null);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(connectivityChannel, null)
      ..setMockMethodCallHandler(connectivityEvents, null);
    SharedPreferencesAsyncPlatform.instance = previousPreferences;
    PathProviderPlatform.instance = previousPaths;
    await directory.delete(recursive: true);
  });

  Future<Dependencies> initialize(WidgetTester tester, _HttpClient client) async {
    final dependencies = (await tester.runAsync(
      () => io.IOOverrides.runZoned(
        () => http.runWithClient($initializeDependencies, () => client),
        socketConnect: _connectProbe,
      ),
    ))!;
    addTearDown(() => $disposeApp(dependencies));
    return dependencies;
  }

  testWidgets('releases the initialized graph and makes teardown repeatable', (tester) async {
    final client = _HttpClient((_) async => _json(200, {'data': 'ok'}));
    final dependencies = await initialize(tester, client);
    expect(dependencies.navigator.isDisposed, isFalse);
    expect(dependencies.authenticationController.isDisposed, isFalse);
    expect(dependencies.settingsController.isDisposed, isFalse);
    await tester.runAsync(() async {
      await dependencies.database.customSelect('SELECT 1').get();
      final disposal = $disposeApp(dependencies);
      expect($disposeApp(dependencies), same(disposal));
      await disposal;
      expect(dependencies.navigator.isDisposed, isTrue);
      expect(dependencies.authenticationController.isDisposed, isTrue);
      expect(dependencies.settingsController.isDisposed, isTrue);
      expect(client.closed, isTrue);
      await expectLater(dependencies.database.customSelect('SELECT 1').get(), throwsStateError);
      await $disposeApp(dependencies);
    });
  }, variant: platform);

  for (final savedUrl in <String?>[null, '', 'ftp://override.invalid/api', 'https://override.invalid/custom/api/']) {
    testWidgets(
      'uses one startup URL for requests and refresh with saved URL $savedUrl',
      (tester) => io.IOOverrides.runZoned(() async {
        final preferences = SharedPreferencesAsync();
        if (savedUrl != null) await preferences.setString('api_base_url', savedUrl);
        final requests = <http.BaseRequest>[];
        final client = _HttpClient((request) async {
          requests.add(request);
          return switch (requests.length) {
            1 => _json(401, {
              'errors': {'message': 'expired'},
            }),
            2 => _json(200, {'access_token': 'new-token'}),
            _ => _json(200, {'data': 'ok'}),
          };
        });
        final dependencies = await initialize(tester, client);
        // A preferences change after startup must not redirect either transport.
        await preferences.setString('api_base_url', 'https://changed.invalid/api');

        final response = await dependencies.client.get('/items', context: {'no-retry': true});

        final usesOverride =
            Config.environment.isDevelopment &&
            const bool.fromEnvironment('URL_FROM_LOCAL_STORAGE', defaultValue: true) &&
            savedUrl == 'https://override.invalid/custom/api/';
        final base = usesOverride
            ? 'https://override.invalid/custom/api'
            : Config.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
        expect(response.statusCode, 200);
        expect(requests.map((request) => request.url.toString()), [
          '$base/items',
          '$base/auth/v2/refresh-token',
          '$base/items',
        ]);
        expect(requests[1].headers['Authorization'], 'Bearer old-token');
        expect(requests[2].headers['Authorization'], 'Bearer new-token');
      }, socketConnect: _connectProbe),
      variant: platform,
    );
  }

  for (final phase in ['headers', 'body']) {
    testWidgets(
      'applies the configured client deadline to stalled $phase and aborts only that request',
      (tester) => io.IOOverrides.runZoned(() async {
        final headers = Completer<http.StreamedResponse>();
        final body = StreamController<List<int>>();
        var aborted = false;
        var calls = 0;
        final client = _HttpClient((request) {
          if (++calls > 1) return Future.value(_json(200, {'data': 'next'}));
          expectSync(request, isA<http.Abortable>());
          unawaited((request as http.Abortable).abortTrigger!.then((_) => aborted = true));
          return headers.future;
        });
        final dependencies = await initialize(tester, client);
        Object? failure;
        var completed = false;
        final result = dependencies.client
            .get('/slow', context: {'no-retry': true})
            .then<void>(
              (_) => completed = true,
              onError: (Object error) {
                failure = error;
                completed = true;
              },
            );
        await tester.pump();
        expect(calls, 1);
        final firstPart = Config.apiRequestTimeout ~/ 2;
        await tester.pump(firstPart);
        if (phase == 'body') {
          headers.complete(http.StreamedResponse(body.stream, 200, headers: {'content-type': 'application/json'}));
          body.add(utf8.encode('{"data":'));
          await tester.pump();
        }
        await tester.pump(Config.apiRequestTimeout - firstPart - const Duration(microseconds: 1));
        expect(completed, isFalse);
        expect(aborted, isFalse);

        await tester.pump(const Duration(microseconds: 1));
        expect(completed, isTrue);
        expect(aborted, isTrue);
        expect(failure, isA<ApiException$Network>().having((error) => error.code, 'code', 'timeout_error'));
        await result;
        if (phase == 'headers') {
          headers.complete(http.StreamedResponse(body.stream, 200, headers: {'content-type': 'application/json'}));
          body.add(utf8.encode('{"data":"late"}'));
        } else {
          body.add(utf8.encode('"late"}'));
        }
        unawaited(body.close());
        await tester.pump();

        expect(client.closed, isFalse);
        expect((await dependencies.client.get('/next', context: {'no-retry': true})).statusCode, 200);
        expect(calls, 2);
      }, socketConnect: _connectProbe),
      variant: platform,
    );
  }

  testWidgets(
    'passes the configured deadline to refresh independently of the outer request deadline',
    (tester) => io.IOOverrides.runZoned(() async {
      final refresh = Completer<http.StreamedResponse>();
      var refreshCalls = 0;
      var aborted = false;
      final client = _HttpClient((request) async {
        if (!request.url.path.endsWith('/auth/v2/refresh-token')) {
          return _json(401, {
            'errors': {'message': 'expired'},
          });
        }
        if (++refreshCalls > 1)
          return _json(401, {
            'errors': {'message': 'expired'},
          });
        expectSync(request, isA<http.Abortable>());
        unawaited((request as http.Abortable).abortTrigger!.then((_) => aborted = true));
        return refresh.future;
      });
      final dependencies = await initialize(tester, client);
      Object? failure;
      var completed = false;
      final result = dependencies.client
          .get('/items', context: {'no-retry': true, 'no-timeout': true})
          .then<void>(
            (_) => completed = true,
            onError: (Object error) {
              failure = error;
              completed = true;
            },
          );
      await tester.pump();
      expect(refreshCalls, 1);
      await tester.pump(Config.apiRequestTimeout - const Duration(microseconds: 1));
      expect(aborted, isFalse);
      expect(completed, isFalse);

      await tester.pump(const Duration(microseconds: 1));
      expect(aborted, isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(completed, isTrue);
      expect(failure, isA<ApiException$Authorization>());
      await result;
      expect(refreshCalls, 2);
      expect(dependencies.authenticationController.state.user.isAuthenticated, isFalse);
      refresh.complete(_json(200, {'access_token': 'late-token'}));
      await tester.pump();
      expect(dependencies.authenticationController.state.user.isAuthenticated, isFalse);
      expect(client.closed, isFalse);
    }, socketConnect: _connectProbe),
    variant: platform,
  );
}, tags: ['data']);

http.StreamedResponse _json(int statusCode, Map<String, Object?> body) => http.StreamedResponse(
  Stream.value(utf8.encode(jsonEncode(body))),
  statusCode,
  headers: {'content-type': 'application/json'},
);

class _HttpClient extends http.BaseClient {
  _HttpClient(this.handler);
  final Future<http.StreamedResponse> Function(http.BaseRequest) handler;
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => handler(request);
  @override
  void close() => closed = true;
}

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

Future<io.Socket> _connectProbe(
  Object? host,
  int port, {
  Object? sourceAddress,
  int sourcePort = 0,
  Duration? timeout,
}) async => _ProbeSocket();

class _ProbeSocket extends Fake implements io.Socket {
  @override
  void destroy() {}
}
