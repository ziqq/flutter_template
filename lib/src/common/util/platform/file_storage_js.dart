import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart' show XFile;

/// Browsers do not expose an application documents directory.
Future<String> directoryPath(String directoryName) =>
    Future<String>.error(UnsupportedError('Application directories are unavailable in a browser.'));

/// Retains the picker-provided browser file without triggering a download.
Future<XFile> saveFile(XFile file, String directoryName) async => file;

/// Browser downloads have no native application cache.
Future<XFile?> findFile(String fileName, String directoryName) async => null;

/// Collects downloaded browser content in a Blob-backed XFile.
Future<XFile> saveStream(Stream<List<int>> stream, String fileName, String directoryName, String? mimeType) async {
  final bytes = BytesBuilder(copy: false);
  await stream.forEach(bytes.add);
  return XFile.fromData(bytes.takeBytes(), name: fileName, mimeType: mimeType);
}

/// Browser files remain owned by their picker or in-memory source.
Future<void> deleteFile(XFile file) async {}

/// Downloads an export; browsers cannot append to an existing local file.
Future<void> appendText(String text, String fileName, String directoryName) =>
    XFile.fromData(utf8.encode(text), name: fileName, mimeType: 'text/plain').saveTo(fileName);
