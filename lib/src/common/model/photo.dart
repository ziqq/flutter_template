import 'dart:convert';
import 'dart:io' as io;

import 'package:meta/meta.dart';

/// {@template crop}
/// Photo crop entity
/// {@endtemplate}
@immutable
class Crop {
  /// {@macro crop}
  const Crop({required this.x, required this.y, required this.width, required this.height});

  /// Empty entity of [Crop]
  /// {@macro crop}
  const Crop.empty() : x = .0, y = .0, width = .0, height = .0;

  /// Generate Class from `Map<String, Object?>`
  /// {@macro crop}
  factory Crop.fromJson(Map<String, Object?> json) => Crop(
    x: switch (json['x']) {
      double x => x,
      int x => x.toDouble(),
      String x => double.parse(x),
      _ => .0,
    },
    y: switch (json['y']) {
      double y => y,
      int y => y.toDouble(),
      String y => double.parse(y),
      _ => .0,
    },
    width: switch (json['width']) {
      double width => width,
      int width => width.toDouble(),
      String width => double.parse(width),
      _ => .0,
    },
    height: switch (json['height']) {
      double height => height,
      int height => height.toDouble(),
      String height => double.parse(height),
      _ => .0,
    },
  );

  /// The X positon of crop.
  final double x;

  /// The Y positon of crop.
  final double y;

  /// The width of crop.
  final double width;

  /// The height of crop.
  final double height;

  /// Generate `Map<String, Object?>` from class
  @useResult
  Map<String, Object?> toJson() => <String, Object?>{'x': x, 'y': y, 'width': width, 'height': height};

  /// To update json method
  @useResult
  Map<String, Object?> toUpdateJson({double? x, double? y, double? width, double? height}) => <String, Object?>{
    'x': x ?? this.x,
    'y': y ?? this.y,
    'width': width ?? this.width,
    'height': height ?? this.height,
  };

  /// Create a copy of this object with the given values.
  @useResult
  Crop copyWith({double? x, double? y, double? width, double? height}) =>
      Crop(x: x ?? this.x, y: y ?? this.y, width: width ?? this.width, height: height ?? this.height);

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Crop && x == other.x && y == other.y && width == other.width && height == other.height);

  @override
  String toString() => 'Crop{x: $x, y: $y, width: $width, height: $height}';
}

/// {@template photo}
/// Photo model
/// {@endtemplate}
@immutable
class Photo {
  /// {@macro photo}
  const Photo({
    this.isDelete = false,
    this.isUpdate = false,
    this.imageOriginal,
    this.image,
    this.file,
    this.crop,
    this.blurhash,
    this.rotate,
    this.uploadFilesID,
  });

  /// Empty entity of [Photo]
  /// {@macro photo}
  @literal
  const Photo.empty()
    : isDelete = false,
      isUpdate = false,
      imageOriginal = null,
      image = null,
      file = null,
      crop = null,
      blurhash = null,
      rotate = null,
      uploadFilesID = null;

  /// Generate Class from `Map<String, Object?>`
  /// {@macro photo}
  factory Photo.fromJson(Map<String, Object?> json) => Photo(
    imageOriginal: (json['imageOriginal'] ?? json['image_original'])?.toString(),
    image: json['image']?.toString(),
    blurhash: json['blurhash']?.toString(),
    crop: switch (json['crop']) {
      Map<String, Object?> crop => Crop.fromJson(crop),
      _ => null,
    },
    rotate: switch (json['rotate']) {
      String s when s.isNotEmpty => int.tryParse(s),
      double d when d >= 0 => d.toInt(),
      int i when i >= 0 => i,
      _ => null,
    },
    uploadFilesID: switch (json['uploadFilesID'] ?? json['upload_files_id']) {
      String ids => int.tryParse(ids),
      int ids => ids,
      _ => null,
    },
  );

  /// This flag use for deleting.
  final bool isDelete;

  /// This flag use for updating.
  final bool isUpdate;

  /// This file use for uploading.
  final io.File? file;

  /// This is showing image.
  final String? image;

  /// This is original image.
  final String? imageOriginal;

  /// This is blurhash of image.
  final String? blurhash;

  /// This is crop of image.
  final Crop? crop;

  /// This is rotate degrice of image.
  final int? rotate;

  /// This is upload file id.
  final int? uploadFilesID;

  /// Generate `Map<String, Object?>` from class
  @useResult
  Map<String, Object?> toJson() => <String, Object?>{
    'isDelete': isDelete,
    'isUpdate': isUpdate,
    'crop': isDelete ? null : crop?.toJson(),
    'imageOriginal': isDelete ? null : imageOriginal,
    'image': isDelete ? null : image,
    'blurhash': isDelete ? null : blurhash,
    'rotate': isDelete ? null : rotate,
    'uploadFilesID': uploadFilesID,
  };

  /// This method return [Map<String, Object?>] with [File].
  @useResult
  Map<String, Object?> toJsonWithFile() => <String, Object?>{
    'isDelete': isDelete,
    'isUpdate': isUpdate,
    'file': isDelete ? null : file,
    'rotate': isDelete ? null : rotate ?? 0,
    'crop': isDelete ? null : jsonEncode(crop?.toUpdateJson()),
    'uploadFilesID': uploadFilesID,
  };

  /// Create a copy of this object with the given values.
  @useResult
  Photo copyWith({
    bool? isDelete,
    bool? isUpdate,
    String? imageOriginal,
    String? image,
    String? blurhash,
    int? rotate,
    int? uploadFilesID,
    io.File? file,
    Crop? crop,
  }) => Photo(
    isDelete: isDelete ?? this.isDelete,
    isUpdate: isUpdate ?? this.isUpdate,
    imageOriginal: imageOriginal ?? this.imageOriginal,
    image: image ?? this.image,
    blurhash: blurhash ?? this.blurhash,
    rotate: rotate ?? this.rotate,
    uploadFilesID: uploadFilesID ?? this.uploadFilesID,
    file: file ?? this.file,
    crop: crop ?? this.crop,
  );

  @override
  int get hashCode =>
      Object.hash(isDelete, isUpdate, file, image, imageOriginal, blurhash, rotate, uploadFilesID, crop);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          isDelete == other.isDelete &&
          isUpdate == other.isUpdate &&
          file == other.file &&
          image == other.image &&
          imageOriginal == other.imageOriginal &&
          blurhash == other.blurhash &&
          rotate == other.rotate &&
          uploadFilesID == other.uploadFilesID &&
          crop == other.crop);

  @override
  String toString() =>
      'Photo{'
      'isDelete: $isDelete, '
      'isUpdate: $isUpdate, '
      'imageOriginal: $imageOriginal, '
      'image: $image, '
      'blurhash: $blurhash, '
      'crop: $crop, '
      'rotate: $rotate, '
      'uploadFilesID: $uploadFilesID'
      '}';
}
