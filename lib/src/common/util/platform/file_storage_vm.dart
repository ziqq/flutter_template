import 'dart:io';

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Returns the native directory used for application files.
Future<String> directoryPath(String directoryName) async {
  final documents = await getApplicationDocumentsDirectory();
  final directory = Directory(path.join(documents.path, directoryName));
  if (!directory.existsSync()) await directory.create(recursive: true);
  return directory.path;
}

/// Copies a file into application storage while preserving its metadata.
Future<XFile> saveFile(XFile file, String directoryName) async {
  final directory = await directoryPath(directoryName);
  final copyDirectory = await Directory(directory).createTemp('attachment-');
  final destination = path.join(copyDirectory.path, file.name.isEmpty ? 'file' : path.basename(file.name));
  try {
    await file.saveTo(destination);
    return XFile(destination, mimeType: file.mimeType);
  } on Object {
    await copyDirectory.delete(recursive: true);
    rethrow;
  }
}

/// Returns a previously downloaded file without fetching it again.
Future<XFile?> findFile(String fileName, String directoryName) async {
  final file = File(path.join(await directoryPath(directoryName), path.basename(fileName)));
  return file.existsSync() ? XFile(file.path) : null;
}

/// Streams a download directly to native storage without buffering it in memory.
Future<XFile> saveStream(Stream<List<int>> stream, String fileName, String directoryName, String? mimeType) async {
  final directory = Directory(await directoryPath(directoryName));
  final temporary = await directory.createTemp('download-');
  final file = File(path.join(temporary.path, path.basename(fileName)));
  try {
    await stream.pipe(file.openWrite());
    final saved = await file.rename(path.join(directory.path, path.basename(fileName)));
    return XFile(saved.path, mimeType: mimeType);
  } finally {
    await temporary.delete(recursive: true);
  }
}

/// Deletes an application-owned native file if it still exists.
Future<void> deleteFile(XFile file) async {
  final nativeFile = File(file.path);
  if (nativeFile.existsSync()) await nativeFile.delete();
}

/// Appends text to a named export in native application storage.
Future<void> appendText(String text, String fileName, String directoryName) async {
  final directory = await directoryPath(directoryName);
  await File(path.join(directory, path.basename(fileName))).writeAsString(text, mode: FileMode.append);
}
