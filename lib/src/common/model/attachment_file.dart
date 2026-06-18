import 'dart:typed_data';

import 'package:flutter_template_name/src/common/util/file_util.dart';
import 'package:meta/meta.dart';

/// {@template attachment_file_type}
/// AttachmentFileType enumeration
/// {@endtemplate}
enum AttachmentFileType implements Comparable<AttachmentFileType> {
  /// image
  image('image'),

  /// file
  file('file');

  /// {@macro attachment_file_type}
  const AttachmentFileType(this.value);

  /// Value of the enum
  final String value;

  /// Check if the type is image
  bool get isImage => this == AttachmentFileType.image;

  /// Check if the type is file
  bool get isFile => this == AttachmentFileType.file;

  /// Pattern matching
  T map<T>({required T Function() image, required T Function() file}) => switch (this) {
    AttachmentFileType.image => image(),
    AttachmentFileType.file => file(),
  };

  /// Pattern matching
  T maybeMap<T>({required T Function() orElse, T Function()? image, T Function()? file}) =>
      map<T>(image: image ?? orElse, file: file ?? orElse);

  /// Pattern matching
  T? maybeMapOrNull<T>({T Function()? image, T Function()? file, T Function()? c}) =>
      maybeMap<T?>(orElse: () => null, image: image, file: file);

  @override
  int compareTo(AttachmentFileType other) => index.compareTo(other.index);

  @override
  String toString() => value;
}

/// {@template attachment_file}
/// The [AttachmentFile] class is a data model that represents a attachment file.
/// {@endtemplate}
@immutable
class AttachmentFile {
  /// {@macro attachment_file}
  const AttachmentFile({
    required this.size,
    required this.name,
    required this.type,
    required this.createdAt,
    this.id,
    this.sort,
    this.bytes,
    this.blurhash,
    this.path,
    this.mimeType,
    this.extension,
    this.url,
    this.urlCrop,
    this.hash,
    this.updatedAt,
  });

  /// Creates an attachment_file instance from `Map<String, Object?>`.

  /// Creates an `AttachmentFile$Image` from `Map<String, Object?>`.
  factory AttachmentFile.fromJson(Map<String, Object?> json) {
    if (json.isEmpty) throw Error.throwWithStackTrace(Exception('Json is empty'), StackTrace.current);
    if (json case <String, Object?>{
      'id': int id,
      'sort': int sort,
      'size': int size,
      'name': String name,
      'url': String url,
      'urlCrop': String? urlCrop,
      'createdAt': String createdAt,
      'updatedAt': String? updatedAt,
      // 'mimeType': String? mimeType,
      // 'blurhash': String? blurhash,
      // 'hash': String? hash,
      // TODO(ziqq): Check type if not needed then remove from backend
      // 'type': String type,
    }) {
      final $mimeType = json['mimeType']?.toString() ?? json['mime_type']?.toString() ?? json['mimetype']?.toString();
      final $blurhash = json['blurhash']?.toString() ?? json['blur_hash']?.toString();
      final $extension = json['extension']?.toString() ?? name.split('.').last;
      final $hash = json['hash']?.toString();
      return AttachmentFile(
        id: id,
        sort: sort,
        size: size,
        name: name,
        url: url,
        urlCrop: urlCrop,
        extension: $extension,
        type: FileExtensionType.fromString(name.split('.').last),
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.tryParse(updatedAt.toString()),
        blurhash: $blurhash,
        mimeType: $mimeType,
        hash: $hash,
      );
    }
    throw Error.throwWithStackTrace(FormatException('Invalid json format', json), StackTrace.current);
  }

  /// Generate `AttachmentFile` from `Map<String, Object?>` from S3
  ///
  /// {@macro attachment_file}
  factory AttachmentFile.fromS3Json(Map<String, Object?> json) {
    if (json.isEmpty) throw Error.throwWithStackTrace(Exception('Json is empty'), StackTrace.current);
    if (json case <String, Object?>{
      'id': int id,
      'sort': int? sort,
      'size': int size,
      'name': String name,
      'url': String url,
      'createdAt': String createdAt,
      // 'updatedAt': String? updatedAt,
      // 'mimeType': String? mimeType,
      // 'blurhash': String? blurhash,
      // 'urlCrop': String? urlCrop,
      // 'hash': String? hash,
      // TODO(ziqq): Check type if not needed then remove from backend
      // 'type': String type,
    }) {
      return AttachmentFile(
        id: id,
        url: url,
        name: name,
        size: size,
        sort: sort ?? 0,
        hash: json['hash']?.toString() ?? '',
        createdAt: DateTime.parse(createdAt),
        mimeType: json['mimeType']?.toString(),
        blurhash: json['blurhash']?.toString(),
        type: FileExtensionType.fromString(name.split('.').last, fallback: FileExtensionType.unknown),
      );
    }
    throw Error.throwWithStackTrace(FormatException('Invalid json format', json), StackTrace.current);
  }

  /// The size of the file in bytes.
  final int size;

  /// The sort order of the file.
  final int? sort;

  /// The unique identifier of the file.
  final int? id;

  /// The name of the file.
  final String name;

  /// The cropped url of the file, if available.
  final String? urlCrop;

  /// The raw bytes of the file, if available.
  final Uint8List? bytes;

  /// The type of the file.
  final FileExtensionType type;

  /// The creation date of the file.
  final DateTime createdAt;

  /// The last update date of the file.
  final DateTime? updatedAt;

  /// The mime type of the file like `image/png` or `application/pdf`.
  final String? mimeType;

  /// The file extension like `png` or `pdf`.
  final String? extension;

  /// The url of the file.
  final String? url;

  /// The local file path of the file, if available.
  final String? path;

  /// The hash of the file.
  final String? hash;

  /// The blurhash of the file, if available.
  final String? blurhash;

  /// The size of the attachment_file in MB.
  String get sizeInMb => (size / (1024 * 1024)).toStringAsFixed(2);

  /// Check if the attachment_file is an image
  bool get isImage => !type.isFile;

  /// Convert file extension to [FileExtensionType]
  static FileExtensionType extensionToType(String? extension) {
    if (extension == null || extension.isEmpty) return FileExtensionType.unknown;
    return FileExtensionType.fromExtension(extension, fallback: FileExtensionType.unknown);
  }

  /// Generate `Map<String, Object?>` from class
  @useResult
  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'hash': hash,
    'type': type.value,
    'mimeType': mimeType,
    'extension': extension,
    'size': size,
    'sort': sort,
    'createdAt': createdAt.toUtc().toIso8601String(),
    // 'createdAt': intl.DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
  };

  /// Generate `Map<String, Object?>` from class to s3
  @useResult
  Map<String, Object?> toS3() => <String, Object?>{'name': name, 'mimeType': mimeType};

  @useResult
  AttachmentFile copyWith({
    int? id,
    int? sort,
    int? size,
    String? name,
    String? extension,
    String? url,
    String? urlCrop,
    Uint8List? bytes,
    FileExtensionType? type,
    DateTime? createdAt,
    String? mimeType,
    String? path,
    String? blurhash,
    String? hash,
  }) => AttachmentFile(
    id: id ?? this.id,
    sort: sort ?? this.sort,
    size: size ?? this.size,
    name: name ?? this.name,
    url: url ?? this.url,
    urlCrop: urlCrop ?? this.urlCrop,
    type: type ?? this.type,
    mimeType: mimeType ?? this.mimeType,
    extension: extension ?? this.extension,
    bytes: bytes ?? this.bytes,
    createdAt: createdAt ?? this.createdAt,
    path: path ?? this.path,
    blurhash: blurhash ?? this.blurhash,
    hash: hash ?? this.hash,
    updatedAt: updatedAt,
  );

  @useResult
  AttachmentFile merge(AttachmentFile? other) => copyWith(
    id: other?.id,
    sort: other?.sort,
    size: other?.size,
    name: other?.name,
    url: other?.url,
    urlCrop: other?.urlCrop,
    bytes: other?.bytes,
    createdAt: other?.createdAt,
    type: other?.type,
    mimeType: other?.mimeType,
    extension: other?.extension,
    path: other?.path,
    blurhash: other?.blurhash,
    hash: other?.hash,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttachmentFile &&
        id == other.id &&
        sort == other.sort &&
        size == other.size &&
        name == other.name &&
        url == other.url &&
        urlCrop == other.urlCrop &&
        type == other.type &&
        mimeType == other.mimeType &&
        extension == other.extension &&
        bytes == other.bytes &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        path == other.path &&
        hash == other.hash &&
        blurhash == other.blurhash;
  }

  @override
  int get hashCode => Object.hash(
    id,
    sort,
    size,
    bytes,
    name,
    url,
    urlCrop,
    type,
    mimeType,
    extension,
    createdAt,
    updatedAt,
    path,
    hash,
    blurhash,
  );

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('AttachmentFile.$id{')
      ..write('sort: $sort, ')
      ..write('size: $size, ')
      ..write('name: $name, ');
    if (extension != null) buffer.write('extension: $extension, ');
    buffer
      ..write('type: $type, ')
      ..write('mimeType: $mimeType, ')
      ..write('url: $url, ');
    if (urlCrop != null) buffer.write('urlCrop: $urlCrop, ');
    if (bytes != null) buffer.write('bytes: ${bytes?.length}, ');
    buffer
      ..write('createdAt: $createdAt, ')
      ..write('updatedAt: $updatedAt, ')
      ..write('path: $path, ')
      ..write('hash: $hash, ')
      ..write('blurhash: $blurhash')
      ..write('}');
    return buffer.toString();
  }
}
