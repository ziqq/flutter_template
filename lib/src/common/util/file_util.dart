// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/model/attachment_file.dart';
import 'package:flutter_template_name/src/common/util/bytes_util.dart';
import 'package:flutter_template_name/src/common/util/platform/file_storage.dart' as storage;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:intl/intl.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path_package;
import 'package:share_plus/share_plus.dart';

/// The accepted type groups for the files.
/* const List<file_selector.XTypeGroup> _kAcceptedTypeGroups = <file_selector.XTypeGroup>[
  file_selector.XTypeGroup(
    label: 'XLSs',
    uniformTypeIdentifiers: ['public.data'],
    extensions: <String>['xls', 'xlsx', 'gsheet'],
  ),
  file_selector.XTypeGroup(label: 'PDFs', extensions: <String>['pdf'], uniformTypeIdentifiers: ['public.data']),
  file_selector.XTypeGroup(label: 'CSVs', extensions: <String>['csv'], uniformTypeIdentifiers: ['public.data']),
  file_selector.XTypeGroup(label: 'TXTs', extensions: <String>['txt'], uniformTypeIdentifiers: ['public.plain-text']),
]; */

/// {@template file_extension_type}
/// FileExtensionType enumeration
///
/// The accepted type groups for the files.
///
/// The following types are supported:
/// - [FileExtensionType.jpg] - .jpg
/// - [FileExtensionType.jpeg] - .jpeg
/// - [FileExtensionType.png] - .png
/// - [FileExtensionType.heic] - .heic
/// - [FileExtensionType.webp] - .webp
/// - [FileExtensionType.pdf] - .pdf
/// - [FileExtensionType.xls] - .xls
/// - [FileExtensionType.xlsx] - .xlsx
/// - [FileExtensionType.csv] - .csv
/// - [FileExtensionType.txt] - .txt
/// {@endtemplate}
enum FileExtensionType implements Comparable<FileExtensionType> {
  /// .jpg
  jpg('jpg'),

  /// .jpeg
  jpeg('jpeg'),

  /// .png
  png('png'),

  /// .heic
  heic('heic'),

  /// .webp
  webp('webp'),

  /// .pdf
  pdf('pdf'),

  /// .xls
  xls('xls'),

  /// .xlsx
  xlsx('xlsx'),

  /// .csv
  csv('csv'),

  /// .txt
  txt('txt'),

  /// Unknown
  unknown('unknown');

  /// {@macro file_extension_type}
  const FileExtensionType(this.value);

  /// Creates a new instance of [FileExtensionType] from a given string.
  static FileExtensionType fromString(String? value, {FileExtensionType? fallback}) =>
      switch (value?.trim().toLowerCase()) {
        'jpg' => jpg,
        'jpeg' => jpeg,
        'png' => png,
        'heic' => heic,
        'webp' => webp,
        'pdf' => pdf,
        'xls' => xls,
        'xlsx' || 'gsheet' => xlsx,
        'csv' => csv,
        'txt' => txt,
        _ => fallback ?? unknown,
      };

  /// Creates a new instance of [FileExtensionType] from a given extension of file.
  static FileExtensionType fromExtension(String? value, {FileExtensionType? fallback}) =>
      switch (value?.trim().toLowerCase()) {
        '.jpg' => jpg,
        '.jpeg' => jpeg,
        '.png' => png,
        '.heic' => heic,
        '.webp' => webp,
        '.pdf' => pdf,
        '.xls' => xls,
        '.xlsx' || '.gsheet' => xlsx,
        '.csv' => csv,
        '.txt' => txt,
        _ => fallback ?? unknown,
      };

  /// Get the supported files.
  static List<String> get supportedFiles => [
    FileExtensionType.csv.value,
    FileExtensionType.pdf.value,
    FileExtensionType.txt.value,
    FileExtensionType.xls.value,
    FileExtensionType.xlsx.value,
  ];

  /// Value of the type
  final String value;

  /// Check type is file.
  bool get isFile => [
    FileExtensionType.csv,
    FileExtensionType.pdf,
    FileExtensionType.txt,
    FileExtensionType.xls,
    FileExtensionType.xlsx,
  ].contains(this);

  /// Pattern matching
  T map<T>({
    required T Function() jpg,
    required T Function() jpeg,
    required T Function() png,
    required T Function() heic,
    required T Function() webp,
    required T Function() pdf,
    required T Function() xls,
    required T Function() xlsx,
    required T Function() csv,
    required T Function() txt,
    required T Function() unknown,
  }) => switch (this) {
    FileExtensionType.jpg => jpg(),
    FileExtensionType.jpeg => jpeg(),
    FileExtensionType.png => png(),
    FileExtensionType.heic => heic(),
    FileExtensionType.webp => webp(),
    FileExtensionType.pdf => pdf(),
    FileExtensionType.xls => xls(),
    FileExtensionType.xlsx => xlsx(),
    FileExtensionType.csv => csv(),
    FileExtensionType.txt => txt(),
    FileExtensionType.unknown => unknown(),
  };

  /// Pattern matching
  T maybeMap<T>({
    required T Function() orElse,
    T Function()? jpg,
    T Function()? jpeg,
    T Function()? png,
    T Function()? heic,
    T Function()? webp,
    T Function()? pdf,
    T Function()? xls,
    T Function()? xlsx,
    T Function()? csv,
    T Function()? txt,
    T Function()? unknown,
  }) => map<T>(
    jpg: jpg ?? orElse,
    jpeg: jpeg ?? orElse,
    png: png ?? orElse,
    heic: heic ?? orElse,
    webp: webp ?? orElse,
    pdf: pdf ?? orElse,
    xls: xls ?? orElse,
    xlsx: xlsx ?? orElse,
    csv: csv ?? orElse,
    txt: txt ?? orElse,
    unknown: unknown ?? orElse,
  );

  /// Pattern matching
  T? maybeMapOrNull<T>({
    T Function()? jpg,
    T Function()? jpeg,
    T Function()? png,
    T Function()? heic,
    T Function()? webp,
    T Function()? pdf,
    T Function()? xls,
    T Function()? xlsx,
    T Function()? csv,
    T Function()? txt,
    T Function()? unknown,
  }) => maybeMap<T?>(
    orElse: () => null,
    jpg: jpg,
    jpeg: jpeg,
    png: png,
    heic: heic,
    webp: webp,
    pdf: pdf,
    xls: xls,
    xlsx: xlsx,
    csv: csv,
    txt: txt,
    unknown: unknown,
  );

  @override
  int compareTo(FileExtensionType other) => index.compareTo(other.index);

  @override
  String toString() => value;
}

/// {@template file_util}
/// File utility class.
///
/// The class provides methods for working with files.
/// {@endtemplate}
@immutable
final class FileUtil {
  const FileUtil._();

  static const _allowedExtensions = <String>['pdf', 'xls', 'xlsx', 'csv', 'txt'];

  /// Returns the native application directory; unavailable in browsers.
  static Future<String> getDirectory([String? dirName = 'AppOrOrgName']) =>
      storage.directoryPath(dirName ?? 'AppOrOrgName');

  /// Appends a native text export or downloads the supplied text in a browser.
  static Future<void> appendText(String text, String fileName) => storage.appendText(text, fileName, 'AppOrOrgName');

  /// Downloads a file and exposes it through the same interface on every platform.
  static Future<void> fetch(
    String url, {
    String? fileName,
    String? dirName = 'AppOrOrgName',
    void Function()? onDone,
    void Function()? onProcess,
    void Function(XFile file)? onSuccess,
    void Function(Object error, StackTrace stackTrace)? onError,
    ValueNotifier<Map<String, double>>? downloadingNotifier,
  }) async {
    final client = http.Client();
    try {
      if (url.isEmpty) {
        l.w('Fetch file error: URL is empty');
        return;
      }
      onProcess?.call();
      l.i('Fetching file: $url');
      final name = fileName ?? '${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now().toUtc())}.jpg';
      final directory = dirName ?? 'AppOrOrgName';
      final cached = await storage.findFile(name, directory);
      if (cached != null) {
        l.i('File already exists: ${cached.path}');
        onSuccess?.call(cached);
        return;
      }
      final response = await client.send(http.Request('GET', Uri.parse(url)));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await response.stream.drain<void>();
        throw http.ClientException('Download failed with HTTP ${response.statusCode}.', Uri.parse(url));
      }
      final length = response.contentLength;
      var receivedBytes = 0;
      final stream = response.stream.map((chunk) {
        receivedBytes += chunk.length;
        if (downloadingNotifier != null && length != null && length > 0) {
          downloadingNotifier.value = {...downloadingNotifier.value, url: (receivedBytes / length).clamp(.0, 1.0)};
        }
        return chunk;
      });
      final saved = await storage.saveStream(stream, name, directory, response.headers['content-type']);
      if (downloadingNotifier != null) downloadingNotifier.value = {...downloadingNotifier.value, url: 1.0};
      l.i('File fetched: ${saved.path}');
      onSuccess?.call(saved);
    } on Object catch (e, s) {
      l.e('Fetching file error: $e', s);
      onError?.call(e, s);
    } finally {
      client.close();
      onDone?.call();
    }
  }

  /// Deletes a native temporary file; browser content remains source-owned.
  static Future<void> delete(XFile file) => storage.deleteFile(file);

  static Future<void> deleteFiles(List<XFile> files) async {
    for (final file in files) await delete(file);
  }

  static Future<XFile> save(XFile file) => storage.saveFile(file, 'AppOrOrgName');

  /// Copies native files into application storage and retains browser files.
  static Future<(List<XFile> savedXFiles, List<XFile> tempFiles)> saveXFiles(List<XFile> files) async {
    final saved = <XFile>[];
    final temporary = <XFile>[];
    try {
      for (final file in files) {
        final stored = await save(file);
        saved.add(stored);
        if (!kIsWeb && stored.path != file.path) temporary.add(stored);
      }
      return (saved, temporary);
    } on Object {
      await deleteFiles(temporary);
      rethrow;
    }
  }

  /// Shares the actual file content without converting its path to a native File.
  static Future<ShareResult> share({
    required XFile file,
    required String fileName,
    int? length,
    String? mimeType,
    DateTime? updatedAt,
    void Function(ShareResult result)? onSuccess,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(files: <XFile>[file], fileNameOverrides: <String>[fileName], subject: fileName),
      );
      onSuccess?.call(result);
      return result;
    } on Object catch (e, s) {
      onError?.call(e, s);
      l.e('Share file error: $e', s);
      Error.throwWithStackTrace(e, s);
    }
  }

  static Future<List<XFile>> _pickImages(image_picker.ImageSource source, int limit) async {
    final picker = image_picker.ImagePicker();
    if (source == image_picker.ImageSource.camera || limit == 1) {
      final image = await picker.pickImage(source: source);
      return <XFile>[?image];
    }
    return picker.pickMultiImage(limit: limit);
  }

  static void pickImages({
    required image_picker.ImageSource source,
    int limit = 1,
    int? skip,
    void Function()? onLimit,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<XFile> saved, List<XFile> temp)? onSuccess,
  }) => runZonedGuarded<void>(
    () async {
      final available = limit - (skip ?? 0);
      if (available <= 0) {
        onLimit?.call();
        return;
      }
      final images = await _pickImages(source, available);
      if (images.isEmpty) return;
      if (images.length > available) {
        onLimit?.call();
        return;
      }
      final (saved, temporary) = await saveXFiles(images);
      onSuccess?.call(saved, temporary);
    },
    (e, s) {
      l.e('Error while picking image: $e', s);
      onError?.call(e, s);
    },
  );

  static void pickFiles({
    int? limit,
    int? skip,
    List<String>? allowedExtensions = _allowedExtensions,
    void Function()? onLimit,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<XFile> saved, List<XFile> temp, List<XFile> notSupported)? onSuccess,
  }) => runZonedGuarded<void>(
    () async {
      final available = limit == null ? null : limit - (skip ?? 0);
      if (available != null && available <= 0) {
        onLimit?.call();
        return;
      }
      final type = allowedExtensions == null ? file_picker.FileType.any : file_picker.FileType.custom;
      final List<file_picker.PlatformFile> selected;
      if (available == 1) {
        final file = await file_picker.FilePicker.pickFile(type: type, allowedExtensions: allowedExtensions);
        selected = <file_picker.PlatformFile>[?file];
      } else {
        selected = await file_picker.FilePicker.pickFiles(type: type, allowedExtensions: allowedExtensions);
      }
      if (selected.isEmpty) return;
      final files = <XFile>[for (final file in selected) file.xFile];
      if (available != null && files.length > available) {
        onLimit?.call();
        return;
      }
      final supported = <XFile>[];
      final unsupported = <XFile>[];
      for (final file in files) {
        final extension = path_package.extension(file.name).replaceFirst('.', '').toLowerCase();
        if (allowedExtensions == null || allowedExtensions.contains(extension)) {
          supported.add(file);
        } else {
          unsupported.add(file);
        }
      }
      final (saved, temporary) = await saveXFiles(supported);
      onSuccess?.call(saved, temporary, unsupported);
    },
    (e, s) {
      l.e('Error while picking file: $e', s);
      onError?.call(e, s);
    },
  );

  static Future<AttachmentFile?> _attachment(XFile file, int maxFileSize) async {
    final length = await file.length();
    if (length <= 0 || length > maxFileSize) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || bytes.length > maxFileSize) return null;
    final extension = path_package.extension(file.name).replaceFirst('.', '').toLowerCase();
    return AttachmentFile(
      size: bytes.length,
      name: file.name,
      type: FileExtensionType.fromString(extension),
      createdAt: DateTime.now().toUtc(),
      path: file.path,
      bytes: bytes,
      hash: BytesUtil.sha256(bytes),
      mimeType: file.mimeType ?? mime.lookupMimeType(file.name, headerBytes: bytes),
      extension: extension,
    );
  }

  @experimental
  static void pickImagesV2({
    required image_picker.ImageSource source,
    int maxFileSize = 20 * 1024 * 1024,
    int limit = 1,
    int? skip,
    void Function()? onLimit,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<AttachmentFile> saved, List<XFile> temp)? onSuccess,
  }) => pickImages(
    source: source,
    limit: limit,
    skip: skip,
    onLimit: onLimit,
    onError: onError,
    onSuccess: (files, temporary) async {
      try {
        final attachments = <AttachmentFile>[];
        for (final file in files) {
          final attachment = await _attachment(file, maxFileSize);
          if (attachment != null) attachments.add(attachment);
        }
        onSuccess?.call(attachments, temporary);
      } on Object catch (e, s) {
        await deleteFiles(temporary);
        onError?.call(e, s);
      }
    },
  );

  @experimental
  static void pickFilesV2({
    int maxFileSize = 20 * 1024 * 1024,
    int limit = 1,
    int? skip,
    List<String>? allowedExtensions = _allowedExtensions,
    void Function()? onLimit,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<AttachmentFile> saved, List<XFile> temp, List<AttachmentFile> notSupported)? onSuccess,
  }) => pickFiles(
    limit: limit,
    skip: skip,
    allowedExtensions: allowedExtensions,
    onLimit: onLimit,
    onError: onError,
    onSuccess: (files, temporary, unsupported) async {
      try {
        final attachments = <AttachmentFile>[];
        final rejected = <AttachmentFile>[];
        for (final file in files) {
          final attachment = await _attachment(file, maxFileSize);
          if (attachment != null) attachments.add(attachment);
        }
        for (final file in unsupported) {
          final attachment = await _attachment(file, maxFileSize);
          if (attachment != null) rejected.add(attachment);
        }
        onSuccess?.call(attachments, temporary, rejected);
      } on Object catch (e, s) {
        await deleteFiles(temporary);
        onError?.call(e, s);
      }
    },
  );

  /// Decodes image dimensions from any XFile source and releases the decoder image.
  static Future<Size> getSize(XFile file) async {
    try {
      final image = await decodeImageFromList(await file.readAsBytes());
      try {
        return Size(image.width.toDouble(), image.height.toDouble());
      } finally {
        image.dispose();
      }
    } on Object catch (_) {
      return Size.zero;
    }
  }

  static Uint8List intToBytes(int value) {
    final bytes = Uint8List((value.bitLength + 7) >> 3);
    var remaining = value;
    for (var index = bytes.length - 1; index >= 0; index--) {
      bytes[index] = remaining & 0xFF;
      remaining >>= 8;
    }
    return bytes;
  }
}
