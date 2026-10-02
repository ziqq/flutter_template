/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 13 August 2026
 */

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:meta/meta.dart' show internal;

/// Normalizes transport-neutral multipart values for the package clients.
///
/// Null values are omitted. Iterable values become repeated fields, and each
/// [XFile] keeps a known length so transports can create a fresh byte stream
/// for authorization replay without loading the complete file into memory.
@internal
Future<
  ({
    List<MapEntry<String, String>> fields,
    List<({String field, XFile file, String filename, int length, String? mimeType})> files,
  })
>
normalizeMultipartBody(Map<Object?, Object?> body) async {
  final fields = <MapEntry<String, String>>[];
  final files = <({String field, XFile file, String filename, int length, String? mimeType})>[];

  Future<void> addValue(String field, Object? value) async {
    if (value == null) return;
    if (value case XFile file) {
      files.add((
        field: field,
        file: file,
        filename: file.name.isEmpty ? 'upload' : file.name,
        length: await file.length(),
        mimeType: file.mimeType,
      ));
      return;
    }
    fields.add(MapEntry<String, String>(field, value.toString()));
  }

  for (final entry in body.entries) {
    final field = entry.key.toString();
    switch (entry.value) {
      case null:
        break;
      case Iterable<Object?> values:
        for (final value in values) {
          await addValue(field, value);
        }
      case final value:
        await addValue(field, value);
    }
  }

  return (fields: fields, files: files);
}

/// Whether [body] contains at least one picker-provided file at any supported
/// iterable depth.
@internal
bool containsMultipartFile(Map<Object?, Object?> body) {
  bool contains(Object? value) => switch (value) {
    XFile _ => true,
    Iterable<Object?> values => values.any(contains),
    _ => false,
  };

  return body.values.any(contains);
}
