import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_template_name/src/common/util/platform/file_storage_vm.dart' as storage;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() => group('Native XFile storage -', () {
  late Directory directory;
  late PathProviderPlatform previousProvider;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('template-files-');
    previousProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _PathProvider(directory.path);
  });

  tearDown(() async {
    PathProviderPlatform.instance = previousProvider;
    await directory.delete(recursive: true);
  });

  test('preserves same-name attachments and never overwrites their source', () async {
    final original = await File(path.join(directory.path, 'report.txt')).writeAsString('original');
    final files = await Future.wait([
      storage.saveFile(XFile(original.path), 'files'),
      storage.saveFile(
        XFile.fromData(utf8.encode('second'), path: 'report.txt', name: 'report.txt', mimeType: 'text/plain'),
        'files',
      ),
    ]);
    expect(files.map((file) => file.path).toSet(), hasLength(2));
    expect(files.map((file) => file.name), everyElement('report.txt'));
    expect(await files.first.readAsString(), 'original');
    expect(await files.last.readAsString(), 'second');
    expect(files.last.mimeType, 'text/plain');
    await storage.deleteFile(files.first);
    await storage.deleteFile(files.last);
    expect(await original.readAsString(), 'original');
  });

  test('does not cache partial downloads and preserves complete streamed bytes', () async {
    Stream<List<int>> failingDownload() async* {
      yield utf8.encode('partial');
      throw const HttpException('interrupted');
    }

    await expectLater(
      storage.saveStream(failingDownload(), 'report.txt', 'files', 'text/plain'),
      throwsA(isA<HttpException>()),
    );
    expect(await storage.findFile('report.txt', 'files'), isNull);
    final saved = await storage.saveStream(
      Stream.fromIterable([utf8.encode('complete '), utf8.encode('download')]),
      'report.txt',
      'files',
      'text/plain',
    );
    expect(await saved.readAsString(), 'complete download');
    expect((await storage.findFile('report.txt', 'files'))?.path, saved.path);
  });
});

class _PathProvider extends PathProviderPlatform {
  _PathProvider(this.directory);
  final String directory;
  @override
  Future<String?> getApplicationDocumentsPath() async => directory;
}
