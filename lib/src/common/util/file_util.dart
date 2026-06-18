// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:async';
import 'dart:developer' show log;
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/model/attachment_file.dart';
import 'package:flutter_template_name/src/common/util/bytes_util.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:intl/intl.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path_package;
import 'package:path_provider/path_provider.dart' as pp;
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
  /// {@macro file_util}
  const FileUtil._(); // coverage:ignore-line

  /// The allowed extensions for the files.
  static const _allowedExtensions = <String>['pdf', 'xls', 'xlsx', 'csv', 'txt'];

  /// Get the directory for the files.
  static Future<Directory> getDirectory([String? dirName = 'AppOrOrgName']) => _getDirectory(dirName);

  /// Fetch the file from the network.
  ///
  /// [url] - The file URL.
  ///
  /// [fileName] - The custom file name.
  /// Default file name is the current date and time.
  ///
  /// [dirName] - The directory name.
  /// The default directory name is `AppOrOrgName`.
  static Future<void> fetch(
    String url, {
    String? fileName,
    String? dirName = 'AppOrOrgName',
    void Function()? onDone,
    void Function()? onProcess,
    void Function(File file)? onSuccess,
    void Function(Object error, StackTrace stackTrace)? onError,
    ValueNotifier<Map<String, double>>? downloadingNotifier,
  }) async {
    try {
      if (url.isEmpty) {
        l.w('Fetch file error: URL is empty');
        return;
      }

      onProcess?.call();
      l.i('Fetching file: $url');
      final effectiveFileName = fileName ?? '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc())}.jpg';
      final directory = await _getDirectory(dirName);

      final path = path_package.join(directory.path, effectiveFileName);
      final file = File(path);
      if (file.existsSync()) {
        l.i('File already exists: $path');
        onSuccess?.call(file);
        return;
      }

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      final contentLength = response.contentLength ?? 0;
      final sink = file.openWrite();
      var receivedBytes = 0;

      await for (final chunk in response.stream) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        if (downloadingNotifier != null) {
          downloadingNotifier.value = {...downloadingNotifier.value, url: receivedBytes / contentLength};
        }
      }

      await sink.close();
      client.close();

      if (downloadingNotifier != null) {
        downloadingNotifier.value = {...downloadingNotifier.value, url: 1.0};
      }

      l.i('File fetched: $path');
      onSuccess?.call(file);
    } on Object catch (e, s) {
      l.e('Fetching file error: $e', s);
      onError?.call(e, s);
    } finally {
      onDone?.call();
    }
  }

  /// Delete the file.
  static Future<void> delete(File file) async {
    try {
      if (file.existsSync()) file.deleteSync(recursive: true);
    } on Object catch (e, s) {
      Error.throwWithStackTrace(e, s);
    }
  }

  /// Delete files from the device.
  static Future<void> deleteFiles(List<File> files) async {
    for (final file in files) await delete(file);
  }

  /// Save the file in the device.
  static Future<File> save(String path) async {
    final directory = await _getDirectory();
    final newPath = path_package.join(directory.path, path_package.basename(path));
    return File(path).copy(newPath);
  }

  /// Save files to the device
  /// The result of saving files to the device.
  /// [1][savedXFiles] - The saved files.
  /// [2][tempFiles] - The temporary files to be deleted.
  static Future<(List<XFile> savedXFiles, List<File> tempFiles)> saveXFiles(List<XFile> files) async {
    final savedXFiles = <XFile>[];
    final tempFiles = <File>[];
    for (final file in files) {
      final savedFile = await save(file.path);
      if (savedFile.existsSync()) {
        savedXFiles.add(XFile(savedFile.path));
        tempFiles.add(savedFile);
      } else {
        l.w('Save file error: ${file.path}');
      }
    }
    return (savedXFiles, tempFiles);
  }

  /// Share the file.
  static Future<ShareResult> share({
    required File file,
    required String fileName,
    int? length,
    String? mimeType,
    DateTime? updatedAt,
    void Function(ShareResult result)? onSuccess,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      final name = fileName.split('.').first;
      final xFile = XFile(
        file.path,
        name: name,
        length: length,
        mimeType: mimeType,
        lastModified: updatedAt,
        bytes: length != null ? Uint8List.fromList(intToBytes(length)) : null,
      );
      final result = await SharePlus.instance.share(ShareParams(files: <XFile>[xFile], subject: name));
      onSuccess?.call(result);
      return result;
    } on Object catch (e, s) {
      onError?.call(e, s);
      l.e('Share file error: $e', s);
      throw Error.throwWithStackTrace(e, s);
    }
  }

  /// Picks images from the specified source (camera or gallery) and performs
  /// a given function after the images are picked and saved.
  static void pickImages({
    required image_picker.ImageSource source,
    int limit = 1,
    int? skip,
    void Function()? onLimit,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<XFile> saved, List<File> temp)? onSuccess,
  }) => runZonedGuarded<void>(
    () async {
      // Check on limit
      if (skip != null && skip >= limit) {
        l.i('The images count is more than the max allowed');
        onLimit?.call();
        return;
      }

      final picker = image_picker.ImagePicker();
      final stopwatch = Stopwatch()..start();
      var images = <XFile>[];

      // Get images from camera or gallery
      try {
        switch (source) {
          case image_picker.ImageSource.camera:
            final image = await picker.pickImage(source: image_picker.ImageSource.camera);
            if (image != null) images.add(image);
            break;
          case image_picker.ImageSource.gallery:
            images = await picker.pickMultiImage(limit: limit);
            break;
        }
        if (images.isEmpty) return;
      } on Object catch (e, s) {
        l.w('Image picker not available: $e', s);
        return;
      } finally {
        final seconds = (stopwatch..stop()).elapsedMilliseconds / 1000000;
        l.i('Images picked: $seconds sec.');
      }

      // Save images to the device
      final (savedXFiles, tempFiles) = await saveXFiles(images);

      // Check if the images cout is more than the max allowed
      final imagesLength = (skip ?? 0) + savedXFiles.length;
      if (imagesLength > limit) {
        l.w('The images count is more than the max allowed');
        deleteFiles(tempFiles).ignore();
        onLimit?.call();
        return;
      }

      onSuccess?.call(savedXFiles, tempFiles);
    },
    (e, s) {
      l.e('Error while picking image: $e', s);
      onError?.call(e, s);
      // if (_disposed) return;
      // ignore: use_build_context_synchronously
      /* ErrorUtil.displayErrorSnackBar(context, e, s); */
    },
  );

  /// Picks files from the device, saves them, and processes them using the provided callback function.
  /* static void pickFiles({
    int? limit,
    int? skip,
    void Function()? onLimit,
    List<file_selector.XTypeGroup> acceptedTypeGroups = _kAcceptedTypeGroups,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<XFile> saved, List<File> temp, List<XFile> notSupported)? onSuccess,
  }) => runZonedGuarded<void>(
    () async {
      // Check on limit
      if (limit != null && skip != null && skip >= limit) {
        onLimit?.call();
        return;
      }

      final stopwatch = Stopwatch()..start();
      var files = <XFile>[];

      // Get files from the device
      try {
        files = await file_selector.openFiles(acceptedTypeGroups: acceptedTypeGroups);
      } on Object catch (e, s) {
        l.w('File selector not available: $e', s);
        onError?.call(e, s);
        return;
      } finally {
        final seconds = (stopwatch..stop()).elapsedMilliseconds / 1000;
        l.i('Files picked: $seconds sec.');
      }

      // Save files to the device
      final (savedXFiles, tempFiles) = await saveXFiles(files);

      // Check on not supported files
      final notSupportedXFiles = savedXFiles
          .where((e) {
            final ext = FileExtensionType.fromString(e.name.split('.').last);
            return !ext.isFile;
          })
          .toList(growable: false);

      // Check if the images cout is more than the max allowed
      final imagesLength = (skip ?? 0) + savedXFiles.length;
      if (limit != null && imagesLength > limit) {
        l.w('The files count is more than the max allowed');
        deleteFiles(tempFiles).ignore();
        onLimit?.call();
        return;
      }

      onSuccess?.call(savedXFiles, tempFiles, notSupportedXFiles);
    },
    (e, s) {
      l.e('Error while picking file: $e', s);
      onError?.call(e, s);
      // if (_disposed) return;
      // ignore: use_build_context_synchronously
      /* ErrorUtil.displayErrorSnackBar(context, e, s); */
    },
  ); */
  static void pickFiles({
    int? limit,
    int? skip,
    bool allowMultiple = true,
    List<String>? allowedExtensions = _allowedExtensions,
    void Function(file_picker.FilePickerStatus)? onFileLoading,
    void Function()? onLimit,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<XFile> saved, List<File> temp, List<XFile> notSupported)? onSuccess,
  }) => runZonedGuarded<void>(
    () async {
      if (limit != null && skip != null && skip >= limit) {
        onLimit?.call();
        return;
      }

      final stopwatch = Stopwatch()..start();
      try {
        final result = await file_picker.FilePicker.pickFiles(
          type: file_picker.FileType.custom,
          allowMultiple: allowMultiple,
          onFileLoading: onFileLoading,
          withData: false,
          allowedExtensions: allowedExtensions,
        );

        if (result == null || result.files.isEmpty) {
          l.i('No files selected');
          return;
        }

        var files = result.files
            .where((e) => e.path != null && e.path!.isNotEmpty)
            .map((e) => XFile(e.path!, name: e.name))
            .whereType<XFile>()
            .toList(growable: false);

        final notSupportedXFiles = files
            .where((e) {
              final fileExtension = e.name.split('.').last;
              final ext = FileExtensionType.fromString(fileExtension);
              log('fileExtension: $fileExtension');
              log('ext: $ext');
              final allowed = allowedExtensions == null || allowedExtensions.contains(fileExtension);
              log('allowed: $allowed');
              return !ext.isFile && !allowed;
            })
            .whereType<XFile>()
            .toList(growable: false);
        log('notSupportedXFiles: $notSupportedXFiles');

        files = files.where((e) => !notSupportedXFiles.contains(e)).toList(growable: false);
        log(
          'notSupportedXFiles: ${notSupportedXFiles.length}, '
          'files: ${files.length}',
        );
        if (files.isEmpty) {
          onSuccess?.call([], [], notSupportedXFiles);
          l.i('No supported files selected');
          return;
        }
        final (savedXFiles, tempFiles) = await saveXFiles(files);
        log(
          'notSupportedXFiles: ${notSupportedXFiles.length}, '
          'savedXFiles: ${savedXFiles.length}, '
          'tempFiles: ${tempFiles.length}, '
          'files: ${files.length}',
        );

        final filesLength = (skip ?? 0) + savedXFiles.length;
        if (limit != null && filesLength > limit) {
          l.w('The files count is more than the max allowed');
          deleteFiles(tempFiles).ignore();
          onLimit?.call();
          return;
        }

        onSuccess?.call(savedXFiles, tempFiles, notSupportedXFiles);
      } on Object catch (e, s) {
        l.w('File picker not available: $e', s);
        onError?.call(e, s);
      } finally {
        final seconds = (stopwatch..stop()).elapsedMilliseconds / 1000;
        l.i('Files picked: $seconds sec.');
      }
    },
    (e, s) {
      l.e('Error while picking file: $e', s);
      onError?.call(e, s);
    },
  );

  @experimental
  static void pickImagesV2({
    required image_picker.ImageSource source,
    int maxFileSize = 20 * 1024 * 1024, // 20 MB
    int limit = 1,
    int? skip,
    void Function()? onLimit,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<AttachmentFile> saved, List<File> temp)? onSuccess,
  }) => runZonedGuarded<void>(
    () async {
      // Check on limit
      if (skip != null && skip >= limit) {
        l.i('The images count is more than the max allowed');
        onLimit?.call();
        return;
      }

      final picker = image_picker.ImagePicker();
      final stopwatch = Stopwatch()..start();
      var images = <XFile>[];

      // Get images from camera or gallery
      try {
        switch (source) {
          case image_picker.ImageSource.camera:
            final image = await picker.pickImage(source: image_picker.ImageSource.camera);
            if (image != null) images.add(image);
            break;
          case image_picker.ImageSource.gallery:
            images = await picker.pickMultiImage(limit: limit);
            break;
        }
        if (images.isEmpty) {
          l.i('No images selected');
          return;
        }
      } on Object catch (e, s) {
        l.w('Image picker not available: $e', s);
        return;
      } finally {
        final seconds = (stopwatch..stop()).elapsedMilliseconds / 1000000;
        l.i('Images picked: $seconds sec.');
      }

      // Save images to the device
      final savedFiles = <AttachmentFile>[];
      final tempFiles = <File>[];
      for (final image in images) {
        if (stopwatch.elapsed > const Duration(milliseconds: 8)) {
          // Releave the event loop
          await Future<void>.delayed(Duration.zero);
          stopwatch.reset();
        }

        if (image.path.isEmpty) {
          l.i('Image path is empty, skipping...');
          continue;
        }

        final savedFile = await save(image.path);
        if (savedFile.existsSync()) {
          final name = path_package.basename(image.name);
          final createdAt = DateTime.now().toUtc();
          var extension = path_package.extension(name).toLowerCase();
          if (extension.startsWith('.')) extension = extension.substring(1);
          if (extension.isEmpty) extension = 'jpg';
          final type = AttachmentFile.extensionToType(extension);
          final mimeType = mime.lookupMimeType(image.path).toString();
          // final blurhash = await BlurhashFFI.encode(FileImage(savedFile));

          var bytes = Uint8List(0);
          try {
            bytes = await image.readAsBytes();
          } on Object catch (e, s) {
            l.w('Error getting file length: $e', s);
            continue;
          }
          if (bytes.length > maxFileSize) bytes = Uint8List(0);

          savedFiles.add(
            AttachmentFile(
              hash: BytesUtil.sha256(bytes),
              name: name,
              bytes: bytes,
              // blurhash: blurhash,
              size: bytes.length,
              createdAt: createdAt,
              path: savedFile.path,
              type: type,
              mimeType: mimeType,
              extension: extension,
            ),
          );
          tempFiles.add(savedFile);
        } else {
          l.w('Save image error: ${image.path}');
        }
      }

      // Check if the images cout is more than the max allowed
      final imagesLength = (skip ?? 0) + savedFiles.length;
      if (imagesLength > limit) {
        l.w('The images count is more than the max allowed');
        deleteFiles(tempFiles).ignore();
        onLimit?.call();
        return;
      }

      onSuccess?.call(savedFiles, tempFiles);
    },
    (e, s) {
      l.e('Error while picking image: $e', s);
      onError?.call(e, s);
      // if (_disposed) return;
      // ignore: use_build_context_synchronously
      /* ErrorUtil.displayErrorSnackBar(context, e, s); */
    },
  );

  @experimental
  static void pickFilesV2({
    int maxFileSize = 20 * 1024 * 1024, // 20 MB
    bool allowMultiple = true,
    int limit = 15,
    int? skip,
    void Function()? onLimit,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function(List<AttachmentFile> saved, List<File> temp, List<AttachmentFile> notSupported)? onSuccess,
  }) => runZonedGuarded<void>(
    () async {
      // Check on limit
      if (skip != null && skip >= limit) {
        l.i('The files count is more than the max allowed');
        onLimit?.call();
        return;
      }
      const allowedExtensions = <String>{'pdf', 'xls', 'xlsx', 'gsheet', 'csv', 'txt'};
      final file_picker.FilePickerResult? result;
      try {
        result = await file_picker.FilePicker.pickFiles(
          type: file_picker.FileType.custom,
          allowMultiple: allowMultiple, // allow multiple files to be selected
          // dialogTitle: _localization.chatInputTooltipAttachFile,
          readSequential: false,
          withReadStream: false,
          withData: true, // bytes for web/mobile preview
          allowedExtensions: allowedExtensions.toList(growable: false),
        );
      } on Object catch (e, s) {
        l.w('File picker not available: $e', s);
        onError?.call(e, s);
        return;
      }

      if (result == null || result.count < 1 || result.files.isEmpty) return;
      final createdAt = DateTime.now().toUtc();
      final stopwatch = Stopwatch()..start();
      final newFiles = await Stream<file_picker.PlatformFile>.fromIterable(result.files)
          .take(limit)
          .asyncMap<AttachmentFile>((e) async {
            if (stopwatch.elapsed > const Duration(milliseconds: 8)) {
              // Releave the event loop
              await Future<void>.delayed(Duration.zero);
              stopwatch.reset();
            }
            final name = path_package.basename(e.name);
            var extension = e.extension?.toLowerCase() ?? path_package.extension(name).toLowerCase();
            if (extension.startsWith('.')) extension = extension.substring(1);
            if (extension.isEmpty) extension = 'bin';
            final mimeType = e.path == null ? null : mime.lookupMimeType(e.path!).toString();
            final type = AttachmentFile.extensionToType(extension);
            var bytes = e.bytes ?? Uint8List(0);
            if (bytes.length > maxFileSize) bytes = Uint8List(0);
            return AttachmentFile(
              hash: BytesUtil.sha256(bytes),
              bytes: bytes,
              type: type,
              name: name,
              path: e.path,
              size: bytes.length,
              mimeType: mimeType,
              extension: extension,
              createdAt: createdAt,
            );
          })
          .where(
            (f) =>
                f.path != null &&
                f.path!.isNotEmpty &&
                f.name.isNotEmpty &&
                f.mimeType != null &&
                f.mimeType!.isNotEmpty &&
                f.size > 0 &&
                f.size <= maxFileSize,
          )
          .toList();
      stopwatch.stop();
      if ( /* _disposed || */ newFiles.isEmpty) return;

      // All previous attachments that are not in the new list
      // To avoid duplicates
      // final attachmentsMap = <String, AttachmentFile>{
      //   // Previous attachments
      //   for (final f in _attachments.value) f.hash: f,
      //   // New attachments
      //   for (final f in newFiles) f.hash: f,
      // };
      // var attachments = attachmentsMap.values.toList(growable: false)..sort((a, b) => b.attachedAt.compareTo(a.attachedAt));

      // if (_disposed) return;
      // if (attachments.length > maxFileCount) attachments = attachments.take(maxFileCount).toList(growable: false);
      // _attachments.value = attachments;

      // Save files to the device
      // final (savedXFiles, tempFiles) = await saveXFiles(newFiles);
      final savedFiles = <AttachmentFile>[];
      final tempFiles = <File>[];
      for (final file in newFiles) {
        final filePath = file.path;
        if (filePath == null || filePath.isEmpty) continue;
        final savedFile = await save(filePath);
        if (savedFile.existsSync()) {
          savedFiles.add(file.copyWith(path: savedFile.path));
          tempFiles.add(savedFile);
        } else {
          l.w('Save file error: ${file.path}');
        }
      }

      // Check on not supported files
      final notSupportedFiles = savedFiles.where((e) => !e.type.isFile).toList(growable: false);

      // Check if the images cout is more than the max allowed
      final imagesLength = (skip ?? 0) + savedFiles.length;
      if (imagesLength > limit) {
        onLimit?.call();
        deleteFiles(tempFiles).ignore();
        l.w('The files count is more than the max allowed');
        return;
      }

      onSuccess?.call(savedFiles, tempFiles, notSupportedFiles);
    },
    (e, s) {
      l.e('Error while picking file: $e', s);
      onError?.call(e, s);
      // if (_disposed) return;
      // ignore: use_build_context_synchronously
      /* ErrorUtil.displayErrorSnackBar(context, e, s); */
    },
  );

  /// Get the actual image size for file.
  static Future<Size> getSize(File file) async {
    try {
      if (file.existsSync()) {
        final decodedImage = await decodeImageFromList(file.readAsBytesSync());
        return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      }
      return Size.zero;
    } on Object catch (_) {
      return Size.zero;
    }
  }

  /// Convert the int to bytes.
  static Uint8List intToBytes(int value) {
    var byteCount = (value.bitLength + 7) >> 3;
    var bytes = Uint8List(byteCount);
    var tempValue = value;
    for (var i = 0; i < byteCount; i++) {
      bytes[byteCount - i - 1] = tempValue & 0xFF;
      tempValue = tempValue >> 8;
    }
    return bytes;
  }

  /// Get the app directory.
  ///
  /// If the directory does not exist, it will be created.
  ///
  /// [dirName] - The directory name.
  /// The default directory name is `AppOrOrgName`.
  static Future<Directory> _getDirectory([String? dirName = 'AppOrOrgName']) async {
    final directory = await pp.getApplicationDocumentsDirectory();
    final appDirectory = Directory('${directory.path}/$dirName/');
    if (!appDirectory.existsSync()) await appDirectory.create();
    return appDirectory;
  }
}
